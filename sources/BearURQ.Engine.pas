unit BearURQ.Engine;

interface

uses
  BearURQ.Terminal,
  BearURQ.Location,
  BearURQ.Vars,
  BearURQ.Buttons;

type
  TEngine = class
  private
    FTerminal: TTerminal;
    FLocation: TLocation;
    FButtons: TButtons;
    FVars: TVars;
  public
    constructor Create;
    destructor Destroy; override;
    property Terminal: TTerminal read FTerminal write FTerminal;
    property Location: TLocation read FLocation write FLocation;
    property Buttons: TButtons read FButtons write FButtons;
    property Vars: TVars read FVars write FVars;
    procedure Clear;
  end;

implementation

uses
  SysUtils;

{ TEngine }

procedure TEngine.Clear;
begin
  FTerminal.Clear;
  FLocation.Clear;
  FButtons.Clear;
  FVars.Clear;
end;

constructor TEngine.Create;
begin
  FTerminal := TTerminal.Create;
  FLocation := TLocation.Create;
  FButtons := TButtons.Create;
  FVars := TVars.Create;
end;

destructor TEngine.Destroy;
begin
  FreeAndNil(FVars);
  FreeAndNil(FButtons);
  FreeAndNil(FLocation);
  FreeAndNil(FTerminal);
  inherited;
end;

end.
