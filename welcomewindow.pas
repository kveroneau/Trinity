unit WelcomeWindow;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TWelcomeForm }

  TWelcomeForm = class(TForm)
    BeginBtn: TButton;
    Version: TLabel;
    Label9: TLabel;
    SeePhrase: TCheckBox;
    Passphrase: TEdit;
    Label8: TLabel;
    TIN: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    procedure BeginBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SeePhraseClick(Sender: TObject);
  private

  public
    Configured: boolean;
  end;

var
  WelcomeForm: TWelcomeForm;

implementation

{$R *.lfm}

{ TWelcomeForm }

procedure TWelcomeForm.SeePhraseClick(Sender: TObject);
begin
  if SeePhrase.Checked then
    Passphrase.PasswordChar:=#0
  else
    Passphrase.PasswordChar:='!';
end;

procedure TWelcomeForm.BeginBtnClick(Sender: TObject);
begin
  if Length(TIN.Text) < 5 then
  begin
    ShowMessage('Please choose a TIN with 5 or more digits.');
    TIN.SetFocus;
    Exit;
  end;
  if Length(Passphrase.Text) < 8 then
  begin
    ShowMessage('Please choose a longer passphrase, as 8 or even 10 is considered too low.');
    Passphrase.SetFocus;
    Exit;
  end;
  Configured:=True;
  Close;
end;

procedure TWelcomeForm.FormShow(Sender: TObject);
begin
  {$IFDEF BASIC}
  Version.Caption:='Basic';
  {$ENDIF}
  {$IFDEF PRO}
  Version.Caption:='Pro';
  {$ENDIF}
  {$IFDEF DEBUG}
  Version.Caption:='DEBUG';
  {$ENDIF}
end;

end.

