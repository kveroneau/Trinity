unit NewPassWindow;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TNewPassForm }

  TNewPassForm = class(TForm)
    AppTitle: TEdit;
    AddBtn: TButton;
    PassLen: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    SPN: TEdit;
    Label1: TLabel;
    procedure AddBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  NewPassForm: TNewPassForm;

implementation

{$R *.lfm}

{ TNewPassForm }

procedure TNewPassForm.FormShow(Sender: TObject);
begin
  SPN.Text:=IntToStr(Random(999999));
  AppTitle.Text:='';
end;

procedure TNewPassForm.AddBtnClick(Sender: TObject);
begin

  Close;
end;

end.

