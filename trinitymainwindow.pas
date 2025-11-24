unit TrinityMainWindow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, PairSplitter,
  StdCtrls, WelcomeWindow, ZeroWindow, NewPassWindow, passutil
  {$IFDEF PRO}, BlowFish, keysys{$ENDIF};

type

  PMetadata = ^TMetadata;
  TMetadata = record
    title: string[40];
    spn, len: LongWord;
  end;

  { TTrinityForm }

  TTrinityForm = class(TForm)
    CopyMenu: TMenuItem;
    DoubleMenu: TMenuItem;
    Password: TMemo;
    ShowContentMenu: TMenuItem;
    PasswordMenu: TMenuItem;
    PasswordList: TListBox;
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    DelPassMenu: TMenuItem;
    ExitMenu: TMenuItem;
    NoStoreMenu: TMenuItem;
    NewPassMenu: TMenuItem;
    PairSplitter: TPairSplitter;
    LeftPane: TPairSplitterSide;
    RightPane: TPairSplitterSide;
    Separator1: TMenuItem;
    Separator2: TMenuItem;
    procedure CopyMenuClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LeftPaneResize(Sender: TObject);
    procedure NewPassMenuClick(Sender: TObject);
    procedure NoStoreMenuClick(Sender: TObject);
    procedure PasswordListDblClick(Sender: TObject);
    procedure RightPaneResize(Sender: TObject);
    procedure ShowContentMenuClick(Sender: TObject);
  private
    FMetadata: Array of PMetadata;
    procedure SaveMetadata;
    procedure LoadMetadata;
  public

  end;

var
  TrinityForm: TTrinityForm;

implementation

{$IFDEF PRO}
type
  PTrinityHeader = ^TTrinityHeader;
  TTrinityHeader = record
    sig: string[4];
    count: LongWord;
  end;
{$ENDIF}

const
  {$IFDEF BASIC}
  TRINITY_FILE = 'Trinity.dat';
  {$ENDIF}
  {$IFDEF PRO}
  TRINITY_FILE = 'Trinity.dta';
  TRINITY_SIG = 'TRI*';
  {$ENDIF}

{$R *.lfm}

{ TTrinityForm }

procedure TTrinityForm.LeftPaneResize(Sender: TObject);
begin
  PasswordList.Width:=LeftPane.ClientWidth;
  PasswordList.Height:=LeftPane.ClientHeight;
end;

procedure TTrinityForm.NewPassMenuClick(Sender: TObject);
var
  i: Integer;
begin
  with NewPassForm do
  begin
    ShowModal;
    if SPN.Text = '' then
      Exit;
    PasswordList.Items.Add(AppTitle.Text);
    Password.Text:=GetPass(StrToInt(PassLen.Text), StrToInt(SPN.Text));
    Password.SelectAll;
    Password.CopyToClipboard;
    ShowMessage('New Password copied to clipboard.');
    i:=Length(FMetadata);
    SetLength(FMetadata, i+1);
    New(FMetadata[i]);
    with FMetadata[i]^ do
    begin
      title:=AppTitle.Text;
      len:=StrToInt(PassLen.Text);
    end;
    FMetadata[i]^.spn:=StrToInt(SPN.Text);
    SaveMetadata;
  end;
end;

procedure TTrinityForm.NoStoreMenuClick(Sender: TObject);
begin
  ZeroForm.PassManBtn.Visible:=False;
  ZeroForm.ShowModal;
end;

procedure TTrinityForm.PasswordListDblClick(Sender: TObject);
begin
  with FMetadata[PasswordList.ItemIndex]^ do
    Password.Text:=GetPass(len, spn);
  if DoubleMenu.Checked then
    CopyMenuClick(Sender);
end;

procedure TTrinityForm.CopyMenuClick(Sender: TObject);
begin
  Password.SelectAll;
  Password.CopyToClipboard;
end;

procedure TTrinityForm.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  for i:=0 to Length(FMetadata)-1 do
    Dispose(FMetadata[i]);
  SetLength(FMetadata,0);
end;

procedure TTrinityForm.FormResize(Sender: TObject);
begin
  PairSplitter.Width:=ClientWidth;
  PairSplitter.Height:=ClientHeight;
end;

procedure TTrinityForm.FormShow(Sender: TObject);
var
  r: TModalResult;
begin
  SetLength(FMetadata, 0);
  WelcomeForm.Configured:=False;
  WelcomeForm.ShowModal;
  if not WelcomeForm.Configured then
    Application.Terminate;
  if FileExists(TRINITY_FILE) then
  begin
    LoadMetadata;
    if PasswordList.Count > 0 then
      Exit;
  end;
  r:=ZeroForm.ShowModal;
  if r<>mrOK then
    Application.Terminate;
end;

procedure TTrinityForm.RightPaneResize(Sender: TObject);
begin
  Password.Width:=RightPane.ClientWidth;
  Password.Height:=RightPane.ClientHeight;
end;

procedure TTrinityForm.ShowContentMenuClick(Sender: TObject);
begin
  Password.Visible:=ShowContentMenu.Checked;
end;

procedure TTrinityForm.SaveMetadata;
var
  i: Integer;
  {$IFDEF BASIC}
  f: File of TMetadata;
  {$ENDIF}
  {$IFDEF PRO}
  key: PBlowFishKey;
  f: TFileStream;
  bf: TBlowFishEncryptStream;
  hdr: PTrinityHeader;
  {$ENDIF}
begin
  {$IFDEF BASIC}
  system.Assign(f, TRINITY_FILE);
  Rewrite(f);
  for i:=0 to Length(FMetadata)-1 do
    Write(f, FMetadata[i]^);
  system.Close(f);
  {$ENDIF}
  {$IFDEF PRO}
  key:=DoubleKey(StrToInt(WelcomeForm.TIN.Text), WelcomeForm.Passphrase.Text);
  try
    f:=TFileStream.Create(TRINITY_FILE, fmCreate);
    bf:=TBlowFishEncryptStream.Create(key^, SizeOf(key^), f);
    New(hdr);
    try
      hdr^.sig:=TRINITY_SIG;
      hdr^.count:=Length(FMetadata);
      bf.Write(hdr^, SizeOf(hdr^));
      for i:=0 to Length(FMetadata)-1 do
        bf.Write(FMetadata[i]^, SizeOf(FMetadata[i]^));
    finally
      Dispose(hdr);
      bf.Free;
      f.Free;
    end;
  finally
    Dispose(key);
  end;
  {$ENDIF}
end;

procedure TTrinityForm.LoadMetadata;
var
  i: Integer;
  {$IFDEF BASIC}
  f: File of TMetadata;
  {$ENDIF}
  {$IFDEF PRO}
  key: PBlowFishKey;
  f: TFileStream;
  bf: TBlowFishDeCryptStream;
  hdr: PTrinityHeader;
  {$ENDIF}
begin
  PasswordList.Clear;
  {$IFDEF BASIC}
  system.Assign(f, TRINITY_FILE);
  Reset(f);
  i:=0;
  repeat
    SetLength(FMetadata, i+1);
    New(FMetadata[i]);
    Read(f, FMetadata[i]^);
    PasswordList.Items.Add(FMetadata[i]^.title);
    Inc(i);
  until EOF(f);
  system.Close(f);
  {$ENDIF}
  {$IFDEF PRO}
  key:=DoubleKey(StrToInt(WelcomeForm.TIN.Text), WelcomeForm.Passphrase.Text);
  try
    f:=TFileStream.Create(TRINITY_FILE, fmOpenRead);
    bf:=TBlowFishDeCryptStream.Create(key^, SizeOf(key^), f);
    New(hdr);
    try
      bf.Read(hdr^, SizeOf(hdr^));
      if hdr^.sig <> TRINITY_SIG then
      begin
        ShowMessage('Unable to decrypt the metadata vault.');
        ZeroForm.PassManBtn.Enabled:=False;
        Exit;
      end;
      SetLength(FMetadata, hdr^.count);
      for i:=0 to Length(FMetadata)-1 do
      begin
        New(FMetadata[i]);
        bf.Read(FMetadata[i]^, SizeOf(FMetadata[i]^));
        PasswordList.Items.Add(FMetadata[i]^.title);
      end;
    finally
      Dispose(hdr);
      bf.Free;
      f.Free;
    end;
  finally
    Dispose(key);
  end;
  {$ENDIF}
end;

end.

