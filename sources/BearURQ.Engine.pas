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
  private
    FLocCount: Integer;
    FTerminal: TTerminal;
    FLocation: TLocation;
    FButtons: TButtons;
    FVars: TVars;
    FQuest: TQuest;
  public
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
    function LoadFromFile(const AFileName: string; DefCode: string)
      : string; overload;
    procedure GoToLocation(const ALocName: string);
    procedure Run(const ACode: string);
  end;

implementation

uses
  SysUtils,
  Vcl.Dialogs,
  BearURQ.Utils;

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
procedure TEngine.GoToLocation(const ALocName: string);
var
  CurrLocName: string;
  I, A, C, CurLocCount: Integer;
  B: Boolean;
  SL: TStringList;
begin
  CurrLocName := AdvLowerCase(Trim(ALocName));
  if (CurrLocName = '') then
    A := 0
  else
    A := FQuestList.IndexOf(':' + CurrLocName);
  if (A < 0) then
    Exit;
  // Счетчик заходов на локацию
  CurLocCount := Vars.GetVarValue('count_' + CurrLocName, 0);
  Vars.SetVarValue('count_' + CurrLocName, CurLocCount + 1);
  //
  SL := TStringList.Create;
  try
    // Грузим локацию COMMON

    // Грузим текущую локацию
    SL.Clear;
    for I := A to FQuestList.Count - 1 do
    begin
      try
        // if ((FQuestList[I][1] = 'e') or (FQuestList[I][1] = 'E')) and
        // ((FQuestList[I][2] = 'n') or (FQuestList[I][2] = 'N')) and
        // ((FQuestList[I][3] = 'd') or (FQuestList[I][3] = 'D')) then
        // Break;
        SL.Append(FQuestList[I]);
      except
      end;
    end;
    // Удаляем все метки внутри локации
    for I := SL.Count - 1 downto 0 do
      if (SL[I][1] = ':') then
        SL.Delete(I);
    // Сохраняем имя текущей локации в переменной
    Vars.SetVarValue('location', CurrLocName);
    // Выполняем комманды
    Run(SL.Text);
    FIsGoTo := False;
  finally
    SL.Free;
  end;
end;

// Загрузить квест из файла
procedure TEngine.LoadFromFile(const AFileName: string);
var
  I, J, A, B, C: Integer;
  SL: array [1 .. 3] of TStringList;
  F: string;
label BR;
begin
  // Текущий квест
  FQuestFileName := Trim(AFileName);
  // Путь к папке квеста
  Vars.SetVarValue('quest_path', ExtractFilePath(FQuestFileName));
  Vars.SetVarValue('previous_loc', '');
  FLocCount := 0;
  FIsGoTo := False;
  FQuestList.Clear;
  FQuestList.Text := LoadFromFile(FQuestFileName, '');
  // Вставки Include
  for J := 1 to 3 do
    SL[J] := TStringList.Create;
  try
  BR: // Начало проверки на наличие вставок Include
    for I := 0 to FQuestList.Count - 1 do
    begin
      if Copy(FQuestList[I], 1, 7) = 'include' then
      begin
        for J := 1 to 3 do
          SL[J].Clear;

        for B := 0 to I - 1 do
          SL[1].Append(FQuestList[B]);
        F := Trim(Copy(FQuestList[I], 8, Length(FQuestList[I])));
        SL[2].Text := LoadFromFile(ExtractFilePath(FQuestFileName) + F, '');
        for C := I + 1 to FQuestList.Count - 1 do
          SL[3].Append(FQuestList[C]);
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
      SL.LoadFromFile(AFileName);
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
procedure TEngine.Run(const ACode: string);
begin
  ShowMessage(ACode);
end;

end.
