uses crt,sysutils;
var i,n,right,sep,u:longint;
    s,num_bin,num_div,num_res:string;
    decimal,remem:boolean;

procedure Decimal_part;
begin
//WIP
end;

procedure Integer_part;
begin
for i:=1 to sep do num_bin:=concat(num_bin,s[i]);

num_div:=s; u:=0;
repeat
if num_div <> s then
  begin
  num_bin:=num_div; num_div:='';
  end

else num_div:='';

if StrToInt(num_bin[length(num_bin)]) mod 2 <> 0 then
  begin
  num_bin:=concat(num_bin,IntToStr(StrToInt(num_bin[length(num_bin)]) - 1));
  delete(num_bin,length(num_bin)-1,1);
  inc(u); num_res[u]:='1';
  end

else begin
  inc(u); num_res[u]:='0';
  end;

remem:=false;
for i:=1 to length(num_bin) do
  begin
  if StrToInt(num_bin[i]) mod 2 <> 0 then
    begin
    if remem = true then
      begin
      num_div:=concat(num_div,IntToStr((10 + StrToInt(num_bin[i])) div 2));
      end

    else begin
      if (num_bin[i] = '1') and (i <> 1) then
        begin
        num_div:=concat(num_div,IntToStr(StrToInt(num_bin[i]) div 2));
        end;

      if num_bin[i] <> '1' then
        begin
        num_div:=concat(num_div,IntToStr(StrToInt(num_bin[i]) div 2));
        end;

      remem:=true;
      end;
    end

  else begin
    if remem = true then
      begin
      num_div:=concat(num_div,IntToStr((10 + StrToInt(num_bin[i])) div 2));
      remem:=false;
      end

    else begin
      num_div:=concat(num_div,IntToStr(StrToInt(num_bin[i]) div 2));
      end;
    end;
  end;

until (length(num_div) = 1) and (num_div ='0');

for i:=u downto 1 do write(num_res[i]);
end;

begin
clrscr;
write('Enter the decimal to convert: '); readln(s);

decimal:=false;
while right <> length(s) do
  begin
  right:=0;
  for i:=1 to length(s) do
    begin
    if s[i] = '.' then
      begin
      if decimal = false then
        begin
        inc(right); decimal:=true;
        end

      else inc(right,2);
      end;

    if s[i] in ['0'..'9'] then inc(right);
    end;

  if right <> length(s) then
    begin
    write('Invalid decimal entered, re-enter: '); readln(s);
    end;
  end;

for i:=1 to length(s) do
  begin
  if s[i] = '.' then
     begin
     sep:=i-1; decimal:=true;
     end;

  if (i = length(s)) and (decimal = false) then sep:=length(s);
  end;

Integer_part;

readln;
end.
