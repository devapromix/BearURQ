unit BearURQ.Engine;

interface

uses
  Classes,
  BearURQ.Terminal,
  BearURQ.Location,
  BearURQ.Vars,
  BearURQ.Quest,
  BearURQ.Buttons;

type
  TEngine = class(TObject)
  private type
    IfResult = record
      If1, If2, If3, If4: string;
    end;
  private
    FLocCount: Integer;
    FTerminal: TTerminal;
    FLocation: TLocation;
    FButtons: TButtons;
    FVars: TVars;
    FQuest: TQuest;
    function LoadFromFile(const AFileName: string; DefCode: string)
      : string; overload;
    procedure ReplaceVars(var Code: string);
    function GetCode(Code: string): string;
    function GetLeksemsFromString(Text: String): TStringList;
    function GetIf(S: string): IfResult;
    procedure GetVars(A, B: string; Id: Integer = 0);
  public
    FIsClick: Boolean; // Щелчек, выбор локации
    FIsGoTo: Boolean; // Для перехода по GoTo
    FirstText: Boolean; // Новый текст
    FLocBtnCnt: Byte; // Счетчик кнопок на локации
    FExitFlag: Boolean; // Флаг выхода из вложенности вызовов
    FQuestFileName: string;
    FQuestList: TStringList;
    constructor Create;
    destructor Destroy; override;
    property Terminal: TTerminal read FTerminal write FTerminal;
    property Location: TLocation read FLocation write FLocation;
    property Buttons: TButtons read FButtons write FButtons;
    property Vars: TVars read FVars write FVars;
    property Quest: TQuest read FQuest write FQuest;
    procedure Clear;
    procedure LoadFromFile(const AFileName: string); overload;
    procedure GoToLocation(const ALocName: string);
    procedure RunCode(const ACode: string);
  end;

implementation

uses
  SysUtils,
  Vcl.Dialogs,
  BearURQ.Utils,
  BearURQ.Math;

{ TEngine }

procedure TEngine.Clear;
begin
  FTerminal.Clear;
  FLocation.Clear;
  FButtons.Clear;
  FVars.Clear;
  FQuest.Clear;
end;

constructor TEngine.Create;
begin
  FTerminal := TTerminal.Create;
  FLocation := TLocation.Create;
  FButtons := TButtons.Create;
  FVars := TVars.Create;
  FQuest := TQuest.Create;
  FQuestFileName := '';
  FQuestList := TStringList.Create;
end;

destructor TEngine.Destroy;
begin
  FreeAndNil(FQuestList);
  FreeAndNil(FQuest);
  FreeAndNil(FVars);
  FreeAndNil(FButtons);
  FreeAndNil(FLocation);
  FreeAndNil(FTerminal);
  inherited;
end;

// Переход на метку локации
function TEngine.GetCode(Code: string): string;
var
  I, J, V1, U: Integer;
  SS, LX, LT, LR, LL: String;
  HF: TSplitResult;
  LS: TStringList;
  B: Boolean;
begin
  // Выполнить инструкции URQL и вернуть результат
  B := False;
  // Строковые переменные
  if (Code[1] = '%') then
  begin
    // Это точно строка
    Delete(Code, 1, 1);
    // Конкатенация строк
    // Загружаем список лексем
    LS := GetLeksemsFromString(Code);
    Code := '';
    // Перебираем лексемы и склеиваем строки
    SS := '';
    for I := 0 to LS.Count - 1 do
      if not Math.IsDelimiter(LS[I]) then
        if Vars.IsVar(LS[I]) then
          SS := SS + Vars.GetVarValue(LS[I], '')
        else
          SS := SS + LS[I];
    if (SS = '0') then
      SS := '';
    ReplaceVars(SS);
    Result := SS;
    Exit;
  end;

  // Использовать текстовые переменные в кавычках без instr
  if (Code[1] = '"') then
  begin
    SS := '';
    HF := Explode('+', Code);
    for I := 0 to High(HF) do
    begin
      LL := Trim(HF[I]);
      Delete(LL, 1, 1);
      J := Length(LL);
      Delete(LL, J, J);
      SS := SS + LL;
    end;
    ReplaceVars(SS);
    Result := SS;
    Exit;
  end;

  // Приводим код к удобному выражению
  LS := TStringList.Create;
  // Загружаем список лексем
  LS := GetLeksemsFromString(Code);
  Code := '';
  for I := 0 to LS.Count - 1 do
    // Если лексема не число ...
    if not Math.IsNumber(LS[I])
    // ... и не символ ...
      and not Math.IsDelimiter(LS[I])
    // ... и не функция ...
      and not Math.IsFunction(LS[I]) then
    begin
      // Возможно это функция URQL RAND?
      LS[I] := AdvLowerCase(LS[I]);
      if (Copy(LS[I], 1, 3) = 'rnd') then
      begin
        LS[I] := Trim(Copy(LS[I], 4, Length(LS[I])));
        U := StrToIntDef(LS[I], 0);
        Randomize;
        LS[I] := IntToStr(Random(U) + 1)
      end
      else // Это переменная
        // Отмечаем, что это строковая переменная
        if not Math.IsNumber(Vars.GetVarValue(LS[I], '')) then
          B := True;
      // Конкатенация строк
      if not Vars.IsVar(LS[I]) then
        if (Trim(LS[I]) <> '') then
          Continue;
      // Заменяем переменные их значениями
      LS[I] := Vars.GetVarValue(LS[I], '');
    end;

  // Заполняем измененную строку для интерпретации выражения
  for I := 0 to LS.Count - 1 do
    Code := Code + LS[I];
  LS.Free;
  Result := Code;
  // Результат для строк
  if B then
  begin
    Result := StrReplace(Code, '+', '');
    Result := StrReplace(Result, '"', '');
    ReplaceVars(Result);
    // Exit;
  end;
end;

function TEngine.GetIf(S: string): IfResult;
var
  Z: array [0 .. 5] of string;
  E: TSplitResult;
  I: Byte;
  K: String;
  C: Integer;
begin
  Result.If1 := '';
  Result.If2 := '';
  Result.If3 := '';
  Result.If4 := '';
  if (Pos('not ', S) > 0) then
    Result.If4 := 'NOT';
  S := StrReplace(S, 'not ', '');
  Z[0] := '<>';
  Z[1] := '>=';
  Z[2] := '<=';
  Z[3] := '=';
  Z[4] := '>';
  Z[5] := '<';
  // Условия
  for I := 0 to High(Z) do
    if (Pos(Z[I], S) > 0) then
    begin
      E := Explode(Z[I], S);
      Result.If1 := Trim(E[0]);
      Result.If2 := Z[I];
      Result.If3 := Trim(E[1]);
      Exit;
    end;
  // Условия для предметов
  E := Explode(',', S);
  K := Trim(E[0]);
  if High(E) > 0 then
    C := StrToIntDef(E[1], 1)
  else
    C := 1;
  Result.If1 := K;
  Result.If2 := '#';
  Result.If3 := IntToStr(C);
end;

function TEngine.GetLeksemsFromString(Text: String): TStringList;
var
  I, P: Integer;
  S: string;

  procedure AddLexem(F: string);
  begin
    if (F <> '') then
    begin
      Result.Append(F);
      S := '';
    end;
  end;

begin
  S := '';
  P := 0;
  Result := TStringList.Create;
  for I := 1 to Length(Text) do
  begin
    if (Text[I] in [' ', '&', '=', '+', '-', '*', '/', '^', '(', ')', '<', '>',
      '#', '%', '$', '{', '}', '"']) then
    begin
      AddLexem(S);
      AddLexem(Text[I]);
      Continue;
    end;
    S := S + Text[I];
  end;
  AddLexem(S);
end;

procedure TEngine.GetVars(A, B: string; Id: Integer);
var
  E: TSplitResult;
  I, X: Integer;
  H: string;
begin
  E := Explode(',', A);
  for I := 0 to High(E) do
  begin
    H := Trim(E[I]);
    Vars.SetVarValue(H, B);
  end;
end;

procedure TEngine.GoToLocation(const ALocName: string);
var
  CurrLocName: string;
  I, CurrLocIndex: Integer; // Нач. индекс тек. локации
  CommLocIndex: Integer; // Нач. индекс локации COMMON
  CurrLocCount: Integer; // Счетчик заходов на тек. локацию
  SL: TStringList;
begin
  CurrLocName := AdvLowerCase(Trim(ALocName));
  if (CurrLocName = '') then
    CurrLocIndex := 0
  else
    CurrLocIndex := FQuestList.IndexOf(':' + CurrLocName);
  if (CurrLocIndex < 0) then
    Exit;
  // Счетчик заходов на локацию
  CurrLocCount := Vars.GetVarValue('count_' + CurrLocName, 0);
  Vars.SetVarValue('count_' + CurrLocName, CurrLocCount + 1);
  //
  SL := TStringList.Create;
  try
    // Грузим локацию COMMON
    if FIsClick then
    begin
      FIsClick := False;
      CommLocIndex := FQuestList.IndexOf(':common');
      if (CommLocIndex >= 0) then
        for I := CommLocIndex to FQuestList.Count - 1 do
        begin
          if CompText(FQuestList[I], 'end') then
            Break;
          SL.Append(FQuestList[I]);
        end;
      RunCode(SL.Text);
      FIsGoTo := False;
    end;
    // Грузим текущую локацию
    SL.Clear;
    for I := CurrLocIndex to FQuestList.Count - 1 do
    begin
      if CompText(FQuestList[I], 'end') then
        Break;
      SL.Append(FQuestList[I]);
    end;
    // Удаляем все метки внутри локации
    for I := SL.Count - 1 downto 0 do
      if (SL[I][1] = ':') then
        SL.Delete(I);
    // Сохраняем имя текущей локации в переменной
    Vars.SetVarValue('location', CurrLocName);
    // Выполняем комманды
    RunCode(SL.Text);
    FIsGoTo := False;
  finally
    SL.Free;
  end;
end;

// Загрузить квест из файла
procedure TEngine.LoadFromFile(const AFileName: string);
var
  I, J, B, C: Integer;
  SL: array [1 .. 3] of TStringList;
  F: string;
label BR;
begin
  // Текущий квест
  FQuestFileName := Trim(AFileName);
  // Путь к папке квеста
  Vars.SetVarValue('quest_path', ExtractFilePath(ParamStr(0)) + FQuestFileName);
  Vars.SetVarValue('previous_loc', '');
  FLocCount := 0;
  FIsGoTo := False;
  FIsClick := False;
  FQuestList.Clear;
  FQuestList.Text := LoadFromFile(FQuestFileName, '');
  // Вставки Include
  for J := 1 to 3 do
    SL[J] := TStringList.Create;
  try
  BR: // Начало проверки на наличие вставок Include
    for I := 0 to FQuestList.Count - 1 do
    begin
      if CompText(FQuestList[I], 'include') then
      begin
        for J := 1 to 3 do
          SL[J].Clear;
        for B := 0 to I - 1 do
          SL[1].Append(FQuestList[B]);
        F := Trim(Copy(FQuestList[I], 8, Length(FQuestList[I])));
        SL[2].Text := LoadFromFile(ExtractFilePath(ParamStr(0)) +
          ExtractFilePath(FQuestFileName) + F, '');
        for C := I + 1 to FQuestList.Count - 1 do
          SL[3].Append(FQuestList[C]);
        // Добавляем код инклюда в код квеста и проверяем снова код
        // на наличие инклюдов
        FQuestList.Text := SL[1].Text + SL[2].Text + SL[3].Text;
        GoTo BR;
        Break;
      end;
    end;
  finally
    for J := 1 to 3 do
      FreeAndNil(SL[J]);
  end;

  // Обнуляем счетчик кнопок локации
  FLocBtnCnt := 0;
  // Переходим на первую локацию квеста
  GoToLocation('');
  // Тест
  FQuestList.SaveToFile('test.qqqst');
end;

// Загрузить доп. файлы (Include)
function TEngine.LoadFromFile(const AFileName: string; DefCode: string): string;
var
  I, J, L, A, B: Integer;
  SL: TStringList;
  S, T: String;
  Mark: Boolean;
  H: TSplitResult;
begin
  Mark := False;
  SL := TStringList.Create;
  try
    if FileExists(AFileName) then
    begin
      SL.LoadFromFile(AFileName, TEncoding.UTF8);
      // Многострочный комментарий /* */
      T := SL.Text;
      L := Length(T);
      for I := 1 to L do
      begin
        if (T[I] = '/') and (T[I + 1] = '*') then
          Mark := True;
        if (T[I] = '*') and (T[I + 1] = '/') then
        begin
          T[I] := #1;
          T[I + 1] := #1;
          Mark := False;
        end;
        if Mark then
          T[I] := #1;
      end;
      SL.Text := StrReplace(T, #1, '');
      // Пустые строки и строчный комментарий ;
      for I := (SL.Count - 1) downto 0 do
      begin
        SL[I] := Trim(SL[I]);
        if ((SL[I] = '') or (SL[I][1] = ';')) then
        begin
          SL.Delete(I);
          Continue;
        end;
        A := Pos(';', SL[I]);
        if (A > 0) then
        begin
          SL[I] := Copy(SL[I], 1, A - 1);
          SL[I] := Trim(SL[I]);
        end;
      end;
      //
    end;
    Result := Trim(SL.Text);
    if Result = '' then
      Result := DefCode;
  finally
    SL.Free;
  end;
end;

// Разбор кода
procedure TEngine.ReplaceVars(var Code: string);
var
  I, L, P1, P2: Integer;
  S, F: string;
  AddTextFlag: Boolean;
begin
  // Подстановки
  // Пробел
  Code := StrReplace(Code, '#$', ' ');
  // Выполняем комманды в подстановках
  AddTextFlag := False;
  S := '';
  F := Code;
  L := Length(F);
  Code := '';
  if (L > 0) then
    for I := 1 to L do
    begin
      if AddTextFlag then
      begin
        if F[I] = '$' then
        begin
          Code := Code + GetCode(S);
          AddTextFlag := False;
          S := '';
          Continue;
        end;
        S := S + F[I];
      end
      else if (F[I] <> '#') or (F[I + 1] = '/') then
        Code := Code + F[I]
      else
        AddTextFlag := True;
    end;
end;

procedure TEngine.RunCode(const ACode: string);
var
  I, P, J, D, C, L, N, U, SR, AP: Integer;
  A, G, S, CS, K, V, R, LX, LT, LR, E1, E2, F1, TU, SS, LL: string;
  E, H, W, B, M, T, HF: TSplitResult;
  DoOrCnt, DoCnt: Byte;
  F: IfResult;
  V1, V2, V3: Integer;
  Z: TStringList;
begin
  if (ACode = '') then
    Exit;
  Z := TStringList.Create;
  try
    try
      Z.Text := ACode;
      for I := 0 to Z.Count - 1 do
      begin
        // Если это был GOTO, то пропускаются все комманды после него
        if FIsGoTo then
          Continue;
        S := Trim(Z[I]);
        if (Copy(S, 1, 3) <> 'if ') then
          if (Pos('&', S) > 0) then
          begin
            H := Explode('&', S);
            for U := 0 to High(H) do
              if not FExitFlag then
                RunCode(Trim(H[U]));
            Continue;
          end;
        // Выход из вложенности операторами quit и end
        if FExitFlag then
          Exit;
        {
          if (Copy(S, 1, 3) = 'inv') then
          begin
          U := 1;
          while (U < Length(V)) do
          begin
          if (S[U] = '+') or (S[U] = '-') then begin Inc(U, 2); Continue; end;
          if (S[U] = ' ') then Delete(S, U, 1) else Inc(U);
          end;
          end;
        }
        P := Pos(' ', S);
        if (P <= 0) then
          P := Length(S);
        K := AdvLowerCase(Trim(Copy(S, 1, P)));
        V := Copy(S, P + 1, Length(S));
        begin
          { // TextAlign
            case Vars.GIVar('textalign') of
            3:
            TextAlign := 1;
            else
            TextAlign := 0;
            end; }
          // Sellect
          if (K = 'quit') or (K = 'end') then
          begin
            FExitFlag := True;
            Exit;
          end
          else if (K = 'perkill') then
            Vars.Clear
          else if (K = 'invkill') then
            // Inv.Clear
          else if (K = 'cls') then
          begin
            // Очистить экран
            Location.Clear;
            Buttons.Clear;
            FirstText := True;
          end
          else
            // PROC и GOTO не выполняют COMMON!
            if (K = 'proc') then
            begin
              GoToLocation(Trim(V));
              FIsGoTo := False;
            end
            else if (K = 'goto') then
            begin
              GoToLocation(Trim(V));
              FIsGoTo := True;
            end
            else if (K = 'p') or (K = 'print') then
            begin
              ReplaceVars(V);
              E := Explode('#/$', V);
              if (High(E) >= 0) then
                for U := 0 to High(E) do
                  Location.Append(E[U]);
            end
            else if (K = 'pln') or (K = 'println') then
            begin
              ReplaceVars(V);
              E := Explode('#/$', V);
              if (High(E) >= 0) then
                for U := 0 to High(E) do
                begin
                  Location.Append(E[U]);
                  Location.Append(#13#10);
                end;
            end
            else
              // Кнопки
              if (K = 'btn') then
              begin
                ReplaceVars(V);
                E := Explode(',', V);
                R := E[1];
                if (High(E) > 1) then
                  for U := 2 to High(E) do
                    R := R + ',' + E[U];
                // Добавляем кнопку в список
                Buttons.Append(Trim(E[0]), Trim(R));
              end
              else
                // Записываем текст в переменные
                if (K = 'instr') then
                begin
                  ReplaceVars(V);
                  E := Explode('=', V);
                  GetVars(E[0], E[1]);
                end
                else
                  // Конструкция IF
                  if (K = 'if') then
                  begin
                    // if Pos(' then ', V) <= 0 then
                    // ShowMessage('После IF oтсутствует оператор THEN!');
                    A := Trim(GetINIKey(V, 'then'));
                    G := Trim(GetINIValue(V, 'then'));
                    E1 := Trim(GetINIKey(G, 'else'));
                    E2 := Trim(GetINIValue(G, 'else'));
                    DoOrCnt := 0;
                    V := Trim(A);
                    T := Explode(' or ', V);
                    for N := 0 to High(T) do
                    begin
                      DoCnt := 0;
                      B := Explode(' and ', T[N]);
                      for J := 0 to High(B) do
                      begin
                        F := GetIf(Trim(B[J]));
                        // Разбор условий
                        if Vars.IsVar(F.If3) then
                          F.If3 := Vars.GetVarValue(F.If3, '');
                        if (F.If4 = '') then
                        begin
                          if (F.If2 = '<>') then
                            if (Vars.GetVarValue(F.If1, 0) <>
                              StrToIntDef(F.If3, 0)) then
                              Inc(DoCnt);
                          if (F.If2 = '>=') then
                            if (Vars.GetVarValue(F.If1, 0) >=
                              StrToIntDef(F.If3, 0)) then
                              Inc(DoCnt);
                          if (F.If2 = '<=') then
                            if (Vars.GetVarValue(F.If1, 0) <=
                              StrToIntDef(F.If3, 0)) then
                              Inc(DoCnt);
                          if (F.If2 = '=') then
                            if (Vars.GetVarValue(F.If1, 0)
                              = StrToIntDef(F.If3, 0)) then
                              Inc(DoCnt);
                          if (F.If2 = '>') then
                            if (Vars.GetVarValue(F.If1, 0) >
                              StrToIntDef(F.If3, 0)) then
                              Inc(DoCnt);
                          if (F.If2 = '<') then
                            if (Vars.GetVarValue(F.If1, 0) <
                              StrToIntDef(F.If3, 0)) then
                              Inc(DoCnt);
                        end
                        else
                        begin
                          // NOT!
                          if (F.If2 = '<>') then
                            if not(Vars.GetVarValue(F.If1, 0) <>
                              StrToIntDef(F.If3, 0)) then
                              Inc(DoCnt);
                          if (F.If2 = '>=') then
                            if not(Vars.GetVarValue(F.If1, 0) >=
                              StrToIntDef(F.If3, 0)) then
                              Inc(DoCnt);
                          if (F.If2 = '<=') then
                            if not(Vars.GetVarValue(F.If1, 0) <=
                              StrToIntDef(F.If3, 0)) then
                              Inc(DoCnt);
                          if (F.If2 = '=') then
                            if not(Vars.GetVarValue(F.If1, 0)
                              = StrToIntDef(F.If3, 0)) then
                              Inc(DoCnt);
                          if (F.If2 = '>') then
                            if not(Vars.GetVarValue(F.If1, 0) >
                              StrToIntDef(F.If3, 0)) then
                              Inc(DoCnt);
                          if (F.If2 = '<') then
                            if not(Vars.GetVarValue(F.If1, 0) <
                              StrToIntDef(F.If3, 0)) then
                              Inc(DoCnt);
                        end;
                        // Предметы в условиях
                        if (F.If2 = '#') then
                        begin
                          // Снача приводим к обычному виду форму типа "30 семян"
                          F1 := F.If1;
                          if Math.IsNumber(F1[1]) then
                          begin
                            SR := Pos(' ', F1);
                            F.If3 := Trim(Copy(F1, 1, SR));
                            F.If1 := Trim(Copy(F1, SR + 1, Length(F1)));
                          end;
                          //
                          { if ((F.If4 = '') and
                            (Inv.IsItem(F.If1, StrToInt(F.If3)))) or
                            ((F.If4 = 'NOT') and
                            (not Inv.IsItem(F.If1, StrToInt(F.If3)))) then
                            Inc(DoCnt); }
                        end;
                      end;
                      // DO IF .. THEN .. ELSE ..
                      if (DoCnt - 1 = High(B)) then
                      begin
                        if (E1 <> '') then
                          RunCode(E1);
                      end
                      else
                      begin
                        if (E2 <> '') then
                          RunCode(E2);
                      end;
                    end;
                  end
                  else
                    // Inventory
                    if ((K = 'inv+') or (K = 'inv-')) then
                    begin
                      ReplaceVars(V);
                      if Pos(',', V) <= 0 then
                      begin
                        R := V;
                        C := 1;
                      end
                      else
                      begin
                        R := Trim(GetINIValue(V, ',', ''));
                        C := StrToIntDef(GetINIKey(V, ','), 1);
                      end;
                      if (C < 1) then
                        C := 1;
                      if (K = 'inv+') and (R <> '') then
                        // Inv.Add(R, C)
                      else if (K = 'inv-') and (R <> '') then
                        // Inv.Del(R, C);
                    end
                    else
                      // Записываем данные в переменные
                      //if (Pos('=', S) > 0) then
                      begin
                        //E := Explode('=', S);
                        //R := Trim(E[1]);
                        //ShowMessage(E[0]);
                        //GetVars(Trim(E[0]), GetCode(R));
                        { // Считываем значения переменных инвентаря и перезаписываем их новое значение
                          for U := 0 to Vars.Count - 1 do
                          if (Copy(Trim(Vars.FID[U]), 1, 4) = 'inv_') then
                          begin
                          R := Trim(Copy(Trim(Vars.FID[U]), 5,
                          Length(Vars.FID[U])));
                          Inv.Let(R, StrToIntDef(Vars.FValue[U], 0));
                          end; }
                      end;
        end; // IF
      end;
    finally
      Z.Free;
    end;
    // Сохраняем в переменную количество слотов в инвентаре
    // Vars.SetVarValue('urq_inv', Inv.Count);
    // Vars.SaveToFile('vars.txt'); // Тест
  except
  end;
end;

end.
