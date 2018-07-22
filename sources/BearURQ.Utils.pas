unit BearURQ.Utils;

interface

type
  TSplitResult = array of string;

function AdvLowerCase(const s: string): string;
function StrReplace(const s, Srch, Replace: string): string;
function Explode(const cSeparator, vString: string): TSplitResult;
function Implode(const cSeparator: string; const cArray: TSplitResult): string;
function StrLeft(s: string; I: Integer): string;
function StrRight(s: string; I: Integer): string;
function GetINIKey(s, Key: string): string;
function GetINIValue(s, Key: string; Default: string = ''): string;

implementation

// В нижний регистр
function AdvLowerCase(const s: string): string;
var
  I: Integer;
begin
  result := s;
  for I := 1 to length(result) do
    if (result[I] in ['A' .. 'Z', 'А' .. 'Я']) then
      result[I] := chr(ord(result[I]) + 32)
    else if (result[I] in ['І']) then
      result[I] := 'і';
end;

// Замена в строке
function StrReplace(const s, Srch, Replace: string): string;
var
  I: Integer;
  Source: string;
begin
  Source := s;
  result := '';
  repeat
    I := Pos(AdvLowerCase(Srch), AdvLowerCase(Source));
    if I > 0 then
    begin
      result := result + Copy(Source, 1, I - 1) + Replace;
      Source := Copy(Source, I + length(Srch), MaxInt);
    end
    else
      result := result + Source;
  until I <= 0;
end;

// Разбить строку в массив TSplitResult, аналог Split
function Explode(const cSeparator, vString: string): TSplitResult;
var
  I: Integer;
  s: String;
begin
  s := vString;
  SetLength(result, 0);
  I := 0;
  while Pos(cSeparator, s) > 0 do
  begin
    SetLength(result, length(result) + 1);
    result[I] := Copy(s, 1, Pos(cSeparator, s) - 1);
    Inc(I);
    s := Copy(s, Pos(cSeparator, s) + length(cSeparator), length(s));
  end;
  SetLength(result, length(result) + 1);
  result[I] := Copy(s, 1, length(s));
end;

// Соединить массив TSplitResult в одну строку, аналог Join
function Implode(const cSeparator: string; const cArray: TSplitResult): string;
var
  I: Integer;
begin
  result := '';
  for I := 0 to length(cArray) - 1 do
  begin
    result := result + cSeparator + cArray[I];
  end;
  System.Delete(result, 1, length(cSeparator));
end;

// Копия строки слева
function StrLeft(s: string; I: Integer): string;
begin
  result := Copy(s, 1, I);
end;

// Копия строки справа
function StrRight(s: string; I: Integer): string;
var
  L: Integer;
begin
  L := length(s);
  result := Copy(s, L - I + 1, L);
end;

// Ключ
function GetINIKey(s, Key: string): string;
var
  P: Integer;
begin
  P := Pos(Key, s);
  if (P <= 0) then
  begin
    result := s;
    Exit;
  end;
  result := StrLeft(s, P - 1);
end;

// Значение ключа
function GetINIValue(s, Key: string; Default: string = ''): string;
var
  L, P, K: Integer;
begin
  P := Pos(Key, s);
  if (P <= 0) then
  begin
    result := Default;
    Exit;
  end;
  L := length(s);
  K := length(Key);
  result := StrRight(s, L - P - K + 1);
end;

end.
