uses crt,math,sysutils;
var s,digit,digit_pre:string;
    i,u,wrong,sep,cnt:longint;
    binary:extended;
    a:array[1..100000000] of longint;
    decimal:boolean;

begin
clrscr;
write('Enter the binary to convert: '); readln(s);

wrong:=2;
while wrong>1 do
  begin
  wrong:=0; decimal:=false;
  for i:=1 to length(s) do
    begin
    if (s[i]='.') or (s[i]=',') then
      begin
      inc(wrong); decimal:=true;
      end;

    if (s[i] in ['a'..'z']) or (s[i] in ['A'..'Z']) or (s[i] in ['2'..'9']) then inc(wrong);
    end;

  if wrong>1 then
    begin
    write('Invalid binary entered, re-enter: '); readln(s);
    end;
  end;

writeln(sLineBreak,'Convert to decimal: ');

for i:=1 to length(s) do
  begin
  if (s[i]='.') or (s[i]=',') then sep:=i;
  end;

if decimal=true then u:=sep-1 else u:=length(s);

binary:=0;
for i:=1 to length(s) do
  begin
  if (s[i]<>'.') and (s[i]<>',') then
    begin
    dec(u); cnt:=1;
    binary:=binary + StrToInt(s[i])*(exp(u*ln(2)));
    
    digit:=FloatToStr(binary);
    if length(digit)>length(digit_pre) then digit_pre:=FloatToStr(binary);
    end;
  end;

if length(digit)<length(digit_pre) then write(digit_pre,'...');
if length(digit)=length(digit_pre) then write(digit_pre);
readln;
end.
