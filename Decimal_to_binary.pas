uses crt,sysutils,math;
var i,sep,cnt:longint;
    s,num_bin,num_div,num_res,dec_mul,dec_res,compare:ansistring;
    decimal,remem,wrong,negative,loop:boolean;

procedure Decimal_part;
begin
write('.');
loop:=false; dec_res:='';
for i:=sep - 1 to length(s) do
  begin
  if i < sep then dec_res:=concat('0',dec_res) else dec_res:=concat(dec_res,s[i]);
  end;

compare:=''; cnt:=1; loop:=false;
repeat
  dec_mul:=dec_res; dec_res:=''; remem:=false;
  for i:=length(dec_mul) downto 1 do
    begin
    if (dec_mul[i] <> '.') and (i <> 1) then
      begin
      if StrToInt(dec_mul[i]) * 2 < 10 then
        begin
        if remem = true then
          begin
          dec_res:=concat(IntToStr(StrToInt(dec_mul[i]) * 2 + 1),dec_res);
          remem:=false;
          end

        else begin
          dec_res:=concat(IntToStr(StrToInt(dec_mul[i]) * 2),dec_res);
          end;
        end

      else begin
        if remem = true then
          begin
          dec_res:=concat(IntToStr((StrToInt(dec_mul[i]) * 2 + 1) mod 10),dec_res);
          end

        else begin
          dec_res:=concat(IntToStr((StrToInt(dec_mul[i]) * 2) mod 10),dec_res); remem:=true;
          end;
        end;
      end;

    if dec_mul[i] = '.' then
      begin
      dec_res:=concat('0.',dec_res);
      end;

    if i = 1 then
      begin
      if (compare = dec_res) and (cnt <> length(s) - length(num_bin)) then
        begin
        loop:=true;

        TextColor(White);
        writeln('...');

        TextColor(Red);
        write(sLineBreak,'Note: ');

        TextColor(Green);
        write('Green part');

        TextColor(White);
        write(' is the forever loop part');

        break;
        end;

      if cnt = length(s) - length(IntToStr(round(Int(StrToFloat(s))))) then
        begin
        compare:=dec_res; TextColor(Green);
        end;

      if remem = true then
          begin
          dec_res[1]:='1';
          write(1);
          end;

      if remem = false then
        begin
        dec_res[1]:='0';
        write(0);
        end;
      end;
    end;

  inc(cnt);
until (round(StrToFloat(dec_res)) - StrToFloat(dec_res) = 0) or (loop = true);
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

num_div:=s;
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
  num_res:=concat('1',num_res);
  end

else begin
  num_res:=concat('0',num_res);
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

write(num_res);

if decimal = true then Decimal_part;
end;

begin
clrscr;
write('Enter decimal to convert: '); readln(s);

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

writeln(SlineBreak,'Convert to binary: ');

if negative = true then
  begin
  write('-');
  delete(s,1,1);
  end;

for i:=1 to length(s) do
  begin
  if s[i] = '.' then
     begin
     sep:=i; decimal:=true;
     end;

  if (i = length(s)) and (decimal = false) then sep:=length(s);
  end;

Integer_part;

readln;
end.
