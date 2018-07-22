unit BearURQ.Player;

interface

uses
  BearURQ.Scenes,
  BearURQ.Engine;

type
  TPlayer = class(TObject)
  private
    FKey: Word;
    FIsRender: Boolean;
    FCanClose: Boolean;
    FEngine: TEngine;
    FScenes: TScenes;
    FFileName: string;
    FVersion: string;
    FIsDebug: Boolean;
    procedure UpdateTitle;
    procedure DoMainLoop;
  public
    constructor Create;
    destructor Destroy; override;
    property Engine: TEngine read FEngine;
    property Scenes: TScenes read FScenes;
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

  FEngine := TEngine.Create;
  FScenes := TScenes.Create(FEngine);

  ChParams;
  UpdateTitle;

  FKey := 0;
  FIsRender := True;
  FCanClose := False;
  DoMainLoop;
end;

destructor TPlayer.Destroy;
begin
  FreeAndNil(FEngine);
  FreeAndNil(FScenes);
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
  Engine.Terminal.Clear;
  Scenes.Render;
  Engine.Terminal.Refresh;
end;

procedure TPlayer.RunQuest(const FileName: string);
begin
  // Очищаем все переменные, весь инвентарь, все кнопки и т.д.
  Engine.Clear;
  // Добавляем системные переменные

  // Открываем квест
  Engine.Location.Append('Первая строка!' + #13#10 + 'Вторая строка!');
  Engine.Buttons.Append('1', 'But 1');
  Engine.Buttons.Append('2', 'But 2');
  Engine.Buttons.Append('3', 'But 3');
  // Сцена игры
  Scenes.SetScene(scGame);
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
