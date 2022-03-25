uses crt,math,sysutils;
var wrong,e,i,u,k,sep,j,h:longint;
    digit_sum,m,n,d,w:extended;
    s,num,deci:string;
    a,digit:array[1..100000000] of longint;
    decimal,smaller_0:boolean;

////////////////////// DECIMAL PART /////////////////////////////

procedure digit_part;
begin
write('.');

e:=0;
for i:=sep+1 to length(s) do
  begin
  inc(e); deci[e]:=s[i];
  end;

u:=1; n:=0;
for i:=1 to e do
  begin
  n:=n + StrToInt(deci[i])/(exp(u*ln(10)));
  inc(u);
  end;

w:=m+n; d:=m; i:=-1; j:=0;
repeat
  if d+(exp(i*ln(2))) > w then
    begin
    inc(j); digit[j]:=0;
    write(0);
    end;

  if d+(exp(i*ln(2))) < w then
    begin
    d:=d+(exp(i*ln(2)));
    inc(j); digit[j]:=1;
    write(1);
    end;

  if d+(exp(i*ln(2))) = w then
    begin
    d:=d+(exp(i*ln(2)));
    inc(j); digit[j]:=1;
    write(1);
    end;

  dec(i);
until d=w;

h:=-1; digit_sum:=0;
for i:=1 to j do
  begin
  digit_sum:=digit_sum+(digit[i]*(exp(h*ln(2))));
  dec(h);
  end;

if Frac(digit_sum)<>n then write('...');
end;

////////////////////// INTEGER PART /////////////////////////////

procedure num_part;
begin
e:=0; smaller_0:=false;
for i:=1 to sep-1 do
  begin
  if s[i]='-' then  smaller_0:=true;
  if s[i]<>'-' then
    begin
    inc(e); num[e]:=s[i];
    end;
  end;

u:=e-1; m:=0;
for i:=1 to e do
  begin
  if u=0 then m:=m + StrToInt(num[i])*1 else m:=m + StrToInt(num[i])*(exp(u*ln(10)));
  dec(u);
  end;

k:=round(m); u:=0;
repeat
  inc(u);
  if k mod 2 = 1 then a[u]:=1 else a[u]:=0;
  k:=k div 2;
until k=0;

if smaller_0=true then write('-');
for i:=u downto 1 do write(a[i]);
end;

////////////////////// MAIN PART /////////////////////////////

begin
clrscr;
write('Enter the decimal to convert: '); readln(s);

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

    if (s[i] in ['a'..'z']) or (s[i] in ['A'..'Z']) then inc(wrong);
    end;

  if wrong>1 then
    begin
    write('Invalid decimal entered, re-enter: '); readln(s);
    end;
  end;

writeln(sLineBreak,'Convert to binary code:');

if decimal=true then
  begin
  for i:=1 to length(s) do
    begin
    if (s[i]='.') or (s[i]=',') then sep:=i;
    end;
  end
else sep:=length(s)+1;

num_part;
if decimal=true then digit_part;

readln;
end.
