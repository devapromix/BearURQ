unit BearURQ.Scenes;

interface

uses
  BearURQ.Engine;

type
  TSceneEnum = (scTitle, scGame);

type
  TScene = class(TObject)
  private
    FEngine: TEngine;
    procedure Print(const X, Y: Word; const S: string); overload;
    procedure Print(const Y: Word; const S: string); overload;
  public
    constructor Create(AEngine: TEngine);
    procedure Render; virtual; abstract;
    procedure Update(var Key: Word); virtual; abstract;
    property Engine: TEngine read FEngine write FEngine;
  end;

type
  TScenes = class(TScene)
  private
    FSceneEnum: TSceneEnum;
    FScene: array [TSceneEnum] of TScene;
    FPrevSceneEnum: TSceneEnum;
  public
    constructor Create(AEngine: TEngine);
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
    constructor Create(AEngine: TEngine);
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

type
  TSceneGame = class(TScene)
  public
    constructor Create(AEngine: TEngine);
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Jump(const Index: Integer);
  end;

var
  Scenes: TScenes;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal;

{ TScene }

constructor TScene.Create(AEngine: TEngine);
begin
  FEngine := AEngine;
end;

// Печать текста на экране терминала
procedure TScene.Print(const X, Y: Word; const S: string);
begin
  terminal_print(X, Y, S);
end;

procedure TScene.Print(const Y: Word; const S: string);
begin
  terminal_print(Engine.Terminal.Width div 2, Y, TK_ALIGN_CENTER, S);
end;

{ TScenes }

constructor TScenes.Create(AEngine: TEngine);
var
  I: TSceneEnum;
begin
  inherited Create(AEngine);
  for I := Low(TSceneEnum) to High(TSceneEnum) do
    case I of
      scTitle:
        FScene[I] := TSceneTitle.Create(AEngine);
      scGame:
        FScene[I] := TSceneGame.Create(AEngine);
    end;
  // Экран приветствия
  SceneEnum := scTitle;
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

constructor TSceneTitle.Create(AEngine: TEngine);
begin
  inherited Create(AEngine);
end;

procedure TSceneTitle.Render;
begin
  Self.Print(10, 'Добро пожаловать в BearURQ!');
end;

procedure TSceneTitle.Update(var Key: Word);
begin

end;

{ TSceneGame }

constructor TSceneGame.Create(AEngine: TEngine);
begin
  inherited Create(AEngine);
end;

// Переход по кнопке
procedure TSceneGame.Jump(const Index: Integer);
var
  CurrButText, CurrLoc: string;
begin
  if (Index > Engine.Buttons.Count - 1) then Exit;
  // Ссылка на текущую локацию
  CurrLoc := Trim(Engine.Buttons.GetLabel(Index));
  // Сохраняем в переменной текст последней нажатой кнопки
  CurrButText := Trim(Engine.Buttons.GetName(Index));
  Engine.Vars.SetVarValue('last_btn_caption', CurrButText);
  // Переход на локацию
  Engine.Clear;
  Engine.FIsGoTo := False;
  Engine.FExitFlag := False;
  Engine.FLocBtnCnt := 0;
  Engine.GoToLocation(CurrLoc);
  // Сохраняем в переменных имена текущей и последней локаций
  if (Trim(Engine.Vars.GetVarValue('previous_loc', '')) = '') then
    Engine.Vars.SetVarValue('previous_loc', CurrLoc)
  else
    Engine.Vars.SetVarValue('previous_loc',
      Engine.Vars.GetVarValue('current_loc', ''));
  Engine.Vars.SetVarValue('current_loc', CurrLoc);
  Self.Render;
end;

procedure TSceneGame.Render;
var
  I: Integer;
begin
  // Показываем содержимое окна локации
  Print(0, 0, Engine.Location.Content);
  // Показываем инвентарь

  // Показываем все кнопки на локации
  for I := 0 to Engine.Buttons.Count - 1 do
  begin
    Print(0, Engine.Terminal.Height - (Engine.Buttons.Count - I),
      IntToStr(I + 1) + '. ' + Engine.Buttons.GetName(I));
  end;
end;

procedure TSceneGame.Update(var Key: Word);
var
  Index: Integer;
begin
  case Key of
    TK_1 .. TK_9:
      begin
        Index := Key - TK_1;
        Self.Jump(Index);
      end;
  end;
end;

end.
