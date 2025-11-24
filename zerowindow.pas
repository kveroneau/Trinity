unit ZeroWindow;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  passutil;

type

  { TZeroForm }

  TZeroForm = class(TForm)
    PassManBtn: TButton;
    ShowPass: TCheckBox;
    Password: TEdit;
    GoBtn: TSpeedButton;
    Label6: TLabel;
    CopyBtn: TSpeedButton;
    SPN: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure CopyBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GoBtnClick(Sender: TObject);
    procedure ShowPassClick(Sender: TObject);
  private

  public

  end;

var
  ZeroForm: TZeroForm;

implementation

{$R *.lfm}

{ TZeroForm }

procedure TZeroForm.GoBtnClick(Sender: TObject);
begin
  Password.Text:=GetPass(15, StrToInt(SPN.Text));
end;

procedure TZeroForm.CopyBtnClick(Sender: TObject);
begin
  Password.SelectAll;
  Password.CopyToClipboard;
end;

procedure TZeroForm.FormShow(Sender: TObject);
begin
  SPN.Text:='';
  Password.Text:='';
end;

procedure TZeroForm.ShowPassClick(Sender: TObject);
begin
  if ShowPass.Checked then
    Password.PasswordChar:=#0
  else
    Password.PasswordChar:='*';
end;

end.

