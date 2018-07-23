unit BearURQ.Location;

interface

type
  TLocation = class(TObject)
  private
    FContent: string;
  public
    constructor Create;
    destructor Destroy; override;
    property Content: string read FContent write FContent;
    procedure Append(const S: string);
    procedure Clear;
  end;

implementation

{ TLocation }

procedure TLocation.Append(const S: string);
begin
  FContent := FContent + S;
end;

procedure TLocation.Clear;
begin
  FContent := '';
end;

constructor TLocation.Create;
begin
  Clear;
end;

destructor TLocation.Destroy;
begin

  inherited;
end;

end.
