{$IFDEF FPC}
{$IFDEF Windows}
{$APPTYPE GUI}
{$ENDIF}
{$ENDIF}
program BearURQ;

uses
  SysUtils,
  BearLibTerminal in 'sources\BearLibTerminal\BearLibTerminal.pas',
  BearURQ.Buttons in 'sources\BearURQ.Buttons.pas';

var
  Key: Word = 0;
  BearURQVersion: string = '0.1';
  IsRender: Boolean = True;
  CanClose: Boolean = False;

begin
  Randomize();
{$IFNDEF FPC}
{$IF COMPILERVERSION >= 18}
  ReportMemoryLeaksOnShutdown := True;
{$IFEND}
{$ENDIF}
  terminal_open();
  repeat
    if IsRender then
    begin
      terminal_clear();
      terminal_print(1, 1, 'BearURQ â.' + BearURQVersion);
      terminal_refresh;
    end;
    Key := 0;
    if terminal_has_input() then
    begin
      Key := terminal_read();
      IsRender := True;
      Continue;
    end;
    terminal_delay(10);
    IsRender := False;
  until CanClose or (Key = TK_CLOSE);
  terminal_close();

end.
