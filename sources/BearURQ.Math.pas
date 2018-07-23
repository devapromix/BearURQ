unit BearURQ.Math;

interface

type
  Math = class
    class function IsDelimiter(const S: string): Boolean;
    class function IsNumber(const S: string): Boolean;
    class function IsFunction(const S: string): Boolean;
  end;

implementation

uses
  SysUtils;

{ Math }

// Строка разделитель или нет?
class function Math.IsDelimiter(const S: string): Boolean;
begin
  Result := (S[1] in ['&', '=', '+', '-', '*', '/', '^', '(', ')', '<', '>',
    '#', '%', '$']);
end;

// Строка число или нет?
class function Math.IsFunction(const S: string): Boolean;
begin
  Result := False;
end;

class function Math.IsNumber(const S: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to Length(S) do
    if not(S[I] in ['0' .. '9']) then
      Exit;
  Result := True;
end;

end.
