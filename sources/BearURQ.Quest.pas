unit BearURQ.Quest;

interface

type
  TQuest = class(TObject)
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
  end;

implementation

{ TQuest }

procedure TQuest.Clear;
begin

end;

constructor TQuest.Create;
begin

end;

destructor TQuest.Destroy;
begin

  inherited;
end;

end.
