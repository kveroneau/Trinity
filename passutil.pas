unit passutil;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, WelcomeWindow;

function GetPass(len, iter: integer): string;

implementation

function RandChar: char;
var
  b: byte;
begin
  b:=Random(128);
  if b>122 then
    Dec(b,122);
  if b<48 then
    Inc(b,48);
  Result:=chr(b);
end;

function GetPass(len, iter: integer): string;
var
  old_seed, seed: Cardinal;
  i: Integer;
  pwd: string;
begin
  old_seed:=RandSeed;
  seed:=StrToInt(WelcomeForm.TIN.Text);
  for i:=1 to Length(WelcomeForm.Passphrase.Text) do
    seed:=seed xor ord(WelcomeForm.Passphrase.Text[i]);
  RandSeed:=seed;
  for i:=1 to iter do
    seed:=seed xor Random(2048);
  RandSeed:=seed;
  SetLength(pwd, len);
  for i:=1 to len do
    pwd[i]:=RandChar;
  RandSeed:=old_seed;
  Result:=pwd;
  FillByte(pwd[1], len, 0);
end;

end.

