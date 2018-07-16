unit BearURQ.Terminal;

interface

type
  TTerminal = class(TObject)
  private
    FKey: Word;
    FWidth: Integer;
    FHeight: Integer;
    FIsRender: Boolean;
    FCanClose: Boolean;
    FVersion: string;
    FFileName: string;
    FIsDebug: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Refresh;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property Version: string read FVersion;
    property FileName: string read FFileName write FFileName;
    property IsDebug: Boolean read FIsDebug;
    procedure UpdateTitle;
    procedure Render;
    procedure MainLoop;
  end;

var
  Terminal: TTerminal;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal;

{ TTerminal }

procedure TTerminal.Clear;
begin
  terminal_clear();
end;

constructor TTerminal.Create;
begin
  // Debug mode -d
  FIsDebug := (ParamCount > 0) and (Trim(ParamStr(1)) = '-d');
  //
  FVersion := '0.1';
  FileName := 'Test.qst';
  Randomize();
  FWidth := 80;
  FHeight := 25;
  terminal_open();
  terminal_set(Format('window.size=%dx%d', [Width, Height]));
  UpdateTitle;
  terminal_refresh();
  FKey := 0;
  FIsRender := True;
  FCanClose := False;
  MainLoop;
end;

destructor TTerminal.Destroy;
begin
  terminal_close();
  inherited;
end;

procedure TTerminal.MainLoop;
begin
{$IFNDEF FPC}
{$IF COMPILERVERSION >= 18}
  ReportMemoryLeaksOnShutdown := True;
{$IFEND}
{$ENDIF}
  repeat
    if FIsRender then
      Render;
    FKey := 0;
    if terminal_has_input() then
    begin
      FKey := terminal_read();
      FIsRender := True;
      Continue;
    end;
    terminal_delay(10);
    FIsRender := False;
  until FCanClose or (FKey = TK_CLOSE);
end;

procedure TTerminal.Refresh;
begin
  terminal_refresh;
end;

procedure TTerminal.Render;
begin
  Clear;
  terminal_print(0, 0, 'Добро пожаловать в BearURQ!');
  Refresh;
end;

procedure TTerminal.UpdateTitle;
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

Terminal := TTerminal.Create;

finalization

FreeAndNil(Terminal);

end.
