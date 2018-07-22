unit BearURQ.Utils;

interface

type
  TSplitResult = array of string;

function Explode(const cSeparator, vString: string): TSplitResult;
function Implode(const cSeparator: string; const cArray: TSplitResult): string;
function StrLeft(S: string; I: Integer): string;
function StrRight(S: string; I: Integer): string;
function GetINIKey(S, Key: string): string;
function GetINIValue(S, Key: string; Default: string = ''): string;

implementation

// Разбить строку в массив TSplitResult, аналог Split
function Explode(const cSeparator, vString: string): TSplitResult;
var
  I: Integer;
  S: String;
begin
  S := vString;
  SetLength(Result, 0);
  I := 0;
  while Pos(cSeparator, S) > 0 do
  begin
    SetLength(Result, Length(Result) + 1);
    Result[I] := Copy(S, 1, Pos(cSeparator, S) - 1);
    Inc(I);
    S := Copy(S, Pos(cSeparator, S) + Length(cSeparator), Length(S));
  end;
  SetLength(Result, Length(Result) + 1);
  Result[I] := Copy(S, 1, Length(S));
end;

// Соединить массив TSplitResult в одну строку, аналог Join
function Implode(const cSeparator: string; const cArray: TSplitResult): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Length(cArray) - 1 do
  begin
    Result := Result + cSeparator + cArray[I];
  end;
  System.Delete(Result, 1, Length(cSeparator));
end;

// Копия строки слева
function StrLeft(S: string; I: Integer): string;
begin
  Result := Copy(S, 1, I);
end;

// Копия строки справа
function StrRight(S: string; I: Integer): string;
var
  L: Integer;
begin
  L := Length(S);
  Result := Copy(S, L - I + 1, L);
end;

// Ключ
function GetINIKey(S, Key: string): string;
var
  P: Integer;
begin
  P := Pos(Key, S);
  if (P <= 0) then
  begin
    Result := S;
    Exit;
  end;
  Result := StrLeft(S, P - 1);
end;

// Значение ключа
function GetINIValue(S, Key: string; Default: string = ''): string;
var
  L, P, K: Integer;
begin
  P := Pos(Key, S);
  if (P <= 0) then
  begin
    Result := Default;
    Exit;
  end;
  L := Length(S);
  K := Length(Key);
  Result := StrRight(S, L - P - K + 1);
end;

end.
