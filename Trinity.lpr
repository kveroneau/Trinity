program Trinity;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, TrinityMainWindow, WelcomeWindow, ZeroWindow, passutil, NewPassWindow
  { you can add units after this };

{$R *.res}

begin
  Randomize;
  RequireDerivedFormResource:=True;
  Application.Title:='Trinity Password Manager';
  Application.Scaled:=True;
  {$PUSH}{$WARN 5044 OFF}
  Application.MainFormOnTaskbar:=True;
  {$POP}
  Application.Initialize;
  Application.CreateForm(TTrinityForm, TrinityForm);
  Application.CreateForm(TWelcomeForm, WelcomeForm);
  Application.CreateForm(TZeroForm, ZeroForm);
  Application.CreateForm(TNewPassForm, NewPassForm);
  Application.Run;
end.

