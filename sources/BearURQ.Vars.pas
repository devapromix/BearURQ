unit BearURQ.Vars;

interface

uses
  Classes;

type
  TVars = class(TObject)
  private
    FName: TStringList;
    FValue: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure ClearInvVars;
    function Count: Integer;
    function IsVar(const AVarName: string): Boolean;
    function GetVarValue(const AVarName: string;
      const ADefVarValue: string = ''): string; overload;
    function GetVarValue(const AVarName: string;
      const ADefVarValue: Integer = 0): Integer; overload;
    procedure SetVarValue(const AVarName, AVarValue: string); overload;
    procedure SetVarValue(const AVarName: string;
      const AVarValue: Integer); overload;
    procedure SaveToFile(const AFileName: string);
  end;

implementation

uses
  SysUtils;

{ TVars }

procedure TVars.Clear;
begin
  FName.Clear;
  FValue.Clear;
end;

procedure TVars.ClearInvVars;
var
  I: Integer;
begin
  for I := FName.Count - 1 downto 0 do
    if (Copy(Trim(FName[I]), 1, 4) = 'inv_') then
      FValue[I] := '0';
end;

function TVars.Count: Integer;
begin
  Result := FName.Count;
end;

constructor TVars.Create;
begin
  FName := TStringList.Create;
  FValue := TStringList.Create;
  Clear;
end;

destructor TVars.Destroy;
begin
  FName.Free;
  FValue.Free;
  inherited;
end;

function TVars.GetVarValue(const AVarName: string;
  const ADefVarValue: string = ''): string;
var
  Index: Integer;
begin
  Index := FName.IndexOf(AVarName);
  if Index < 0 then
    Result := ''
  else
    Result := FValue[Index];
  if (Result = '') and (ADefVarValue <> '') then
    Result := ADefVarValue;
end;

function TVars.GetVarValue(const AVarName: string;
  const ADefVarValue: Integer = 0): Integer;
var
  Value: string;
begin
  Value := Trim(GetVarValue(AVarName, ''));
  Result := StrToIntDef(Value, ADefVarValue);
end;

function TVars.IsVar(const AVarName: string): Boolean;
begin
  Result := FName.IndexOf(Trim(AVarName)) >= 0;
end;

procedure TVars.SaveToFile(const AFileName: String);
var
  I: Integer;
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    for I := 0 to FName.Count - 1 do
      SL.Append(FName[I] + ', ' + FValue[I]);
    SL.SaveToFile(AFileName);
  finally
    FreeAndNil(SL);
  end;
end;

procedure TVars.SetVarValue(const AVarName, AVarValue: string);
var
  Index: Integer;
begin
  Index := FName.IndexOf(AVarName);
  if Index < 0 then
  begin
    FName.Append(AVarName);
    FValue.Append(AVarValue);
  end
  else
    FValue[Index] := AVarValue;
end;

procedure TVars.SetVarValue(const AVarName: string; const AVarValue: Integer);
begin
  SetVarValue(AVarName, IntToStr(AVarValue));
end;

end.
