uses crt,sysutils;
var i,right,sep,u,cnt:longint;
    s,num_bin,num_div,num_res,dec_res,dec_bin:string;
    decimal,remem,wrong,negative:boolean;

procedure Decimal_part;
begin
dec_res:='';
for i:=sep - 1 to length(s) do
  begin
  if i < sep then dec_res:=concat('0',dec_res) else dec_res:=concat(dec_res,s[i]);
  end;

write('.');

repeat
  dec_bin:=dec_res; dec_res:=''; remem:=false;
  for i:=length(dec_bin) downto 1 do
    begin
    if (dec_bin[i] <> '.') and (i <> 1) then
      begin
      if StrToInt(dec_bin[i]) * 2 < 10 then
        begin
        if remem = true then
          begin
          dec_res:=concat(IntToStr(StrToInt(dec_bin[i]) * 2 + 1),dec_res);
          remem:=false;
          end

        else begin
          dec_res:=concat(IntToStr(StrToInt(dec_bin[i]) * 2),dec_res);
          end;
        end

      else begin
        if remem = true then
          begin
          dec_res:=concat(IntToStr((StrToInt(dec_bin[i]) * 2 + 1) mod 10),dec_res);
          end

        else begin
          dec_res:=concat(IntToStr((StrToInt(dec_bin[i]) * 2) mod 10),dec_res); remem:=true;
          end;
        end;
      end;

    if dec_bin[i] = '.' then
      begin
      dec_res:=concat('0.',dec_res);
      end;

    if (i = 1) and (remem = true) then
      begin
      dec_res[1]:='1';
      write(1); inc(cnt);
      end;

    if (i = 1) and (remem = false) then
      begin
      dec_res[1]:='0';
      write(0); inc(cnt);
      end;
    end;

if cnt = 100 then
  begin
  write('...');   //  Temporary solution
  end;

until (round(StrToFloat(dec_res)) - StrToFloat(dec_res) = 0) or (cnt = 100);
end;

procedure Integer_part;
begin
if decimal = true then
  begin
  for i:=1 to sep-1 do num_bin:=concat(num_bin,s[i]);
  end

else begin
  for i:=1 to sep do num_bin:=concat(num_bin,s[i]);
  end;

if negative = true then delete(num_bin,length(num_bin),1);

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

if decimal = true then Decimal_part;
end;

begin
clrscr;
write('Enter the decimal to convert: '); readln(s);

wrong:=true;
while wrong = true do
  begin
  wrong:=false; negative:=false; decimal:=false;
  for i:=1 to length(s) do
   begin
   if (i = 1) and (s[i] = '-') and (negative = false) then negative:=true;

   if (i <> 1) and (s[i] = '-') or (i <> 1) and (s[i] = '-') and (negative = true) then wrong:=true;

   if (s[i] = '.') and (decimal = true) then wrong:=true;

   if (s[i] = '.') and (decimal = false) then decimal:=true
   end;

  if wrong = true then
    begin
    write('Invalid decimal entered, re-enter: '); readln(s);
    end;
  end;


for i:=1 to length(s) do
  begin
  if s[i] = '.' then
     begin
     sep:=i; decimal:=true;
     end;

  if (i = length(s)) and (decimal = false) then sep:=length(s);
  end;

if negative = true then
  begin
  write('-');
  delete(s,1,1);
  end;

Integer_part;

readln;
end.
