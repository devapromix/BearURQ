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
begin

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
        SL[2].Text := LoadFromFile(F, '');
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

// Загрузить Include
function TEngine.LoadFromFile(const AFileName: string; DefCode: string): string;
var
  I, J, L, A, B: Integer;
  FL: TStringList;
  S, FLT: String;
  Mark: Boolean;
  H: TSplitResult;
begin
  Mark := False;
  FL := TStringList.Create;
  try
    if FileExists(AFileName) then
    begin
      FL.LoadFromFile(AFileName);
      // Многострочный комментарий /* */
      FLT := FL.Text;
      L := Length(FLT);
      for I := 1 to L do
      begin
        if (FLT[I] = '/') and (FLT[I + 1] = '*') then
          Mark := True;
        if (FLT[I] = '*') and (FLT[I + 1] = '/') then
        begin
          FLT[I] := #1;
          FLT[I + 1] := #1;
          Mark := False;
        end;
        if Mark then
          FLT[I] := #1;
      end;
      FL.Text := StrReplace(FLT, #1, '');
      // Пустые строки и строчный комментарий ;
      for I := (FL.Count - 1) downto 0 do
      begin
        FL[I] := Trim(FL[I]);
        if ((FL[I] = '') or (FL[I][1] = ';')) then
        begin
          FL.Delete(I);
          Continue;
        end;
        A := Pos(';', FL[I]);
        if (A > 0) then
        begin
          FL[I] := Copy(FL[I], 1, A - 1);
          FL[I] := Trim(FL[I]);
        end;
      end;
      //
    end;
    Result := FL.Text;
  finally
    FL.Free;
  end;
end;

// Разбор кода
procedure TEngine.Run(const ACode: string);
begin

end;

end.
