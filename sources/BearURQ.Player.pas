unit BearURQ.Player;

interface

uses
  BearURQ.Scenes,
  BearURQ.Buttons,
  BearURQ.Location,
  BearURQ.Terminal;

type
  TPlayer = class(TObject)
  private
    FKey: Word;
    FIsRender: Boolean;
    FCanClose: Boolean;
    FTerminal: TTerminal;
    FScenes: TScenes;
    FFileName: string;
    FVersion: string;
    FIsDebug: Boolean;
    FButtons: TButtons;
    FLocation: TLocation;
    procedure UpdateTitle;
    procedure DoMainLoop;
  public
    constructor Create;
    destructor Destroy; override;
    property Terminal: TTerminal read FTerminal;
    property Scenes: TScenes read FScenes;
    property Buttons: TButtons read FButtons;
    property Location: TLocation read FLocation;
    property Version: string read FVersion;
    property FileName: string read FFileName write FFileName;
    property IsDebug: Boolean read FIsDebug;
    procedure RunQuest(const FileName: string);
    procedure Render;
  end;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal;

var
  Player: TPlayer;

  { TPlayer }

constructor TPlayer.Create;
var
  FEntScene: TEntScene;

  procedure ChParams;
  var
    I, N: Integer;
  begin
    FileName := '';
    if ParamCount > 0 then
    begin
      N := 1;
      // Debug mode -d
      if (Trim(ParamStr(1)) = '-d') then
      begin
        N := 2;
        FIsDebug := True;
        // Box('-d');
      end;
      if ParamCount > 0 then
      begin
        for I := N to ParamCount do
          FileName := Trim(FileName + ' ' + ParamStr(I));
        RunQuest(Trim(FileName));
        Exit;
      end;
    end;

  end;

begin
  Randomize();
  // Debug mode -d
  FIsDebug := (ParamCount > 0) and (Trim(ParamStr(1)) = '-d');
  //
  FVersion := 'v.0.1';

  FTerminal := TTerminal.Create;
  FButtons := TButtons.Create;
  FLocation := TLocation.Create;

  FEntScene.Buttons := FButtons;
  FEntScene.Location := FLocation;
  FScenes := TScenes.Create(FTerminal, FEntScene);

  ChParams;
  UpdateTitle;

  FKey := 0;
  FIsRender := True;
  FCanClose := False;
  DoMainLoop;
end;

destructor TPlayer.Destroy;
begin
  FreeAndNil(FButtons);
  FreeAndNil(FLocation);
  FreeAndNil(FScenes);
  FreeAndNil(FTerminal);
  inherited;
end;

procedure TPlayer.DoMainLoop;
begin
  repeat
    if FIsRender then
      Render;
    FKey := 0;
    if terminal_has_input() then
    begin
      FKey := terminal_read();
      FIsRender := True;
      if Assigned(Scenes) then
        Scenes.Update(FKey);
      Continue;
    end;
    terminal_delay(10);
    FIsRender := False;
  until FCanClose or (FKey = TK_CLOSE);
end;

procedure TPlayer.Render;
begin
  FTerminal.Clear;
  Scenes.Render;
  FTerminal.Refresh;
end;

procedure TPlayer.RunQuest(const FileName: string);
begin
  // Очищаем все переменные, весь инвентарь, все кнопки и т.д.
  FLocation.Clear;
  FButtons.Clear;
  // Добавляем системные переменные

  // Открываем квест
  FLocation.Append('Первая строка!'+#13#10+'Вторая строка!');
  FButtons.Append('1', 'But 1');
  FButtons.Append('2', 'But 2');
  FButtons.Append('3', 'But 3');
end;

procedure TPlayer.UpdateTitle;
var
  Debug: string;
begin
  Debug := '';
  if IsDebug then
    Debug := '[DEBUG]';
  terminal_set(Format('window.title=%s %s %s',
    [Trim(Format('%s %s', [FileName, 'BearURQ'])), FVersion, Debug]));
end;

initialization

Player := TPlayer.Create;

finalization

FreeAndNil(Player);

end.
