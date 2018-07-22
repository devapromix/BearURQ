unit BearURQ.Location;

interface

type
  TLocation = class(TObject)
  private
    FTitle: string;
    FContent: string;
  public
    constructor Create;
    destructor Destroy; override;
    property Title: string read FTitle write FTitle;
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
  FTitle := '';
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
