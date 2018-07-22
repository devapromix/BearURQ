unit BearURQ.Vars;

interface

uses Classes;

type
  TVars = class(TObject)
  private

  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
  end;

implementation

{ TVars }

procedure TVars.Clear;
begin

end;

constructor TVars.Create;
begin
  Clear;
end;

destructor TVars.Destroy;
begin

  inherited;
end;

end.
