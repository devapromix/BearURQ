unit BearURQ.Player;

interface

uses
  BearURQ.Scenes,
  BearURQ.Buttons,
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
    procedure UpdateTitle;
  public
    constructor Create;
    destructor Destroy; override;
    property Terminal: TTerminal read FTerminal;
    property Scenes: TScenes read FScenes;
    property Buttons: TButtons read FButtons;
    procedure DoMainLoop;
    property Version: string read FVersion;
    property FileName: string read FFileName write FFileName;
    property IsDebug: Boolean read FIsDebug;
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
begin
  // Debug mode -d
  FIsDebug := (ParamCount > 0) and (Trim(ParamStr(1)) = '-d');
  //
  FVersion := 'v.0.1';
  FileName := 'Test.qst';
  Randomize();
  FTerminal := TTerminal.Create;
  FButtons := TButtons.Create;
  FScenes := TScenes.Create(FTerminal, FButtons);
  UpdateTitle;


  //
  FButtons.Append('1', 'But 1');
  FButtons.Append('2', 'But 2');
  FButtons.Append('3', 'But 3');



  FKey := 0;
  FIsRender := True;
  FCanClose := False;
  DoMainLoop;
end;

destructor TPlayer.Destroy;
begin
  FreeAndNil(FButtons);
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
