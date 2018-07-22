program BearURQ;

{$IFDEF FPC}
{$IFDEF Windows}
{$APPTYPE GUI}
{$ENDIF}
{$ENDIF}

uses
  SysUtils,
  BearLibTerminal in 'sources\BearLibTerminal\BearLibTerminal.pas',
  BearURQ.Terminal in 'sources\BearURQ.Terminal.pas',
  BearURQ.Buttons in 'sources\BearURQ.Buttons.pas',
  BearURQ.Scenes in 'sources\BearURQ.Scenes.pas',
  BearURQ.Player in 'sources\BearURQ.Player.pas',
  BearURQ.Location in 'sources\BearURQ.Location.pas',
  BearURQ.Vars in 'sources\BearURQ.Vars.pas',
  BearURQ.Engine in 'sources\BearURQ.Engine.pas';

begin
{$IFNDEF FPC}
{$IF COMPILERVERSION >= 18}
  ReportMemoryLeaksOnShutdown := True;
{$IFEND}
{$ENDIF}

end.
