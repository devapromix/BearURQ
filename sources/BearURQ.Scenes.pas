unit BearURQ.Scenes;

interface

uses
  BearURQ.Terminal,
  BearURQ.Location,
  BearURQ.Vars,
  BearURQ.Buttons;

type
  TSceneEnum = (scTitle, scGame);

type
  TEntScene = record
    Location: TLocation;
    Buttons: TButtons;
    Vars: TVars;
  end;

type
  TScene = class(TObject)
  private
    FTerminal: TTerminal;
    FButtons: TButtons;
    FLocation: TLocation;
    FVars: TVars;
    procedure Print(const X, Y: Word; const S: string); overload;
    procedure Print(const Y: Word; const S: string); overload;
  public
    constructor Create(ATerminal: TTerminal; AEntScene: TEntScene);
    property Terminal: TTerminal read FTerminal;
    procedure Render; virtual; abstract;
    procedure Update(var Key: Word); virtual; abstract;
  end;

type
  TScenes = class(TScene)
  private
    FSceneEnum: TSceneEnum;
    FScene: array [TSceneEnum] of TScene;
    FPrevSceneEnum: TSceneEnum;
  public
    constructor Create(ATerminal: TTerminal;AEntScene: TEntScene);
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    property SceneEnum: TSceneEnum read FSceneEnum write FSceneEnum;
    property PrevSceneEnum: TSceneEnum read FPrevSceneEnum;
    function GetScene(I: TSceneEnum): TScene;
    procedure SetScene(ASceneEnum: TSceneEnum); overload;
    procedure SetScene(ASceneEnum, CurrSceneEnum: TSceneEnum); overload;
    property PrevScene: TSceneEnum read FPrevSceneEnum write FPrevSceneEnum;
    procedure GoBack;
  end;

type
  TSceneTitle = class(TScene)
  public
    constructor Create(ATerminal: TTerminal; AEntScene: TEntScene);
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

type
  TSceneGame = class(TScene)
  public
    constructor Create(ATerminal: TTerminal;AEntScene: TEntScene);
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

var
  Scenes: TScenes;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal;

{ TScene }

procedure TScene.Print(const X, Y: Word; const S: string);
begin
  terminal_print(X, Y, S);
end;

constructor TScene.Create(ATerminal: TTerminal; AEntScene: TEntScene);
begin
  FTerminal := ATerminal;
  FButtons := AEntScene.Buttons;
  FLocation := AEntScene.Location;
  FVars := AEntScene.Vars;
end;

procedure TScene.Print(const Y: Word; const S: string);
begin
  terminal_print(FTerminal.Width div 2, Y, TK_ALIGN_CENTER, S);
end;

{ TScenes }

constructor TScenes.Create(ATerminal: TTerminal; AEntScene: TEntScene);
var
  I: TSceneEnum;
begin
  inherited Create(ATerminal, AEntScene);
  for I := Low(TSceneEnum) to High(TSceneEnum) do
    case I of
      scTitle:
        FScene[I] := TSceneTitle.Create(ATerminal, AEntScene);
      scGame:
        FScene[I] := TSceneGame.Create(ATerminal, AEntScene);
    end;
  SceneEnum := scGame;
end;

destructor TScenes.Destroy;
var
  I: TSceneEnum;
begin
  for I := Low(TSceneEnum) to High(TSceneEnum) do
    FreeAndNil(FScene[I]);
  inherited;
end;

function TScenes.GetScene(I: TSceneEnum): TScene;
begin
  Result := FScene[I];
end;

procedure TScenes.GoBack;
begin
  Self.SceneEnum := FPrevSceneEnum;
end;

procedure TScenes.Render;
begin
  if (FScene[SceneEnum] <> nil) then
    FScene[SceneEnum].Render;
end;

procedure TScenes.SetScene(ASceneEnum, CurrSceneEnum: TSceneEnum);
begin
  FPrevSceneEnum := CurrSceneEnum;
  SetScene(ASceneEnum);
end;

procedure TScenes.SetScene(ASceneEnum: TSceneEnum);
begin
  SceneEnum := ASceneEnum;
  Render;
end;

procedure TScenes.Update(var Key: Word);
begin
  if (FScene[SceneEnum] <> nil) then
  begin
    FScene[SceneEnum].Update(Key);
  end;
end;

{ TSceneTitle }

constructor TSceneTitle.Create(ATerminal: TTerminal; AEntScene: TEntScene);
begin
  inherited Create(ATerminal, AEntScene);
end;

procedure TSceneTitle.Render;
begin
  Self.Print(10, 'Добро пожаловать в BearURQ!');
end;

procedure TSceneTitle.Update(var Key: Word);
begin

end;

{ TSceneGame }

constructor TSceneGame.Create(ATerminal: TTerminal;AEntScene: TEntScene);
begin
  inherited Create(ATerminal, AEntScene);
end;

procedure TSceneGame.Render;
var
  I: Integer;
begin
  // Показываем содержимое окна локации
  Print(0, FLocation.Title);
  Print(0, 2, FLocation.Content);
  // Показываем инвентарь
  // Показываем все кнопки на локации
  for I := 0 to FButtons.Count - 1 do
  begin
    Print(0, Terminal.Height - (FButtons.Count - I), IntToStr(I + 1) + '. ' +
      FButtons.GetName(I));
  end;
end;

procedure TSceneGame.Update(var Key: Word);
begin

end;

end.
