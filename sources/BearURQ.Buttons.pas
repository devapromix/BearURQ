unit BearURQ.Buttons;

interface

uses Classes;

type
  TButtons = class
  private
    FLabelList: TStringList;
    FNameList: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Count: Integer;
    procedure Append(const ALabel, AName: string);
    function GetLabel(const I: Integer): string;
    function GetName(const I: Integer): string;
  end;

implementation

{ TButtons }

procedure TButtons.Append(const ALabel, AName: string);
begin
  FLabelList.Append(ALabel);
  FNameList.Append(AName);
end;

procedure TButtons.Clear;
begin
  FLabelList.Clear;
  FNameList.Clear;
end;

function TButtons.Count: Integer;
begin
  Result := FLabelList.Count;
end;

constructor TButtons.Create;
begin
  FLabelList := TStringList.Create;
  FNameList := TStringList.Create;
  Self.Clear;
end;

destructor TButtons.Destroy;
begin
  FLabelList.Free;
  FNameList.Free;
  inherited;
end;

function TButtons.GetLabel(const I: Integer): string;
begin
  Result := FLabelList[I];
end;

function TButtons.GetName(const I: Integer): string;
begin
  Result := FNameList[I];
end;

end.
