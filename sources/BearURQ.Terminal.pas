unit BearURQ.Terminal;

interface

type
  TTerminal = class(TObject)
  private
    FWidth: Integer;
    FHeight: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Refresh;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
  end;

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
  FWidth := 80;
  FHeight := 25;
  terminal_open();
  terminal_set(Format('window.size=%dx%d', [Width, Height]));
  terminal_refresh();
end;

destructor TTerminal.Destroy;
begin
  terminal_close();
  inherited;
end;

procedure TTerminal.Refresh;
begin
  terminal_refresh;
end;

end.
