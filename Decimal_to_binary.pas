uses crt,sysutils;
var i,sep,cnt,limit,first,mul,last,split,cnt_split,u,e:longint;
    s,num_bin,num_div,num_res,dec_bin,dec_mul,loop_find,compare,save,dec_res,dec_float,dec_float_save:ansistring;
    decimal,remem,wrong,negative,loop:boolean;

procedure Decimal_part;
begin
write('.');
loop:=false; dec_mul:='';
for i:=sep - 1 to length(s) do
  begin
  if i < sep then dec_mul:=concat('0',dec_mul) else dec_mul:=concat(dec_mul,s[i]);
  end;

dec_res:=''; compare:=''; dec_float:=''; split:=1; cnt:=1; cnt_split:=1;
repeat
  dec_bin:=dec_mul; dec_mul:=''; remem:=false;
  for i:=length(dec_bin) downto 1 do
    begin
    if (dec_bin[i] <> '.') and (i <> 1) then
      begin
      if StrToInt(dec_bin[i]) * 2 < 10 then
        begin
        if remem = true then
          begin
          dec_mul:=concat(IntToStr(StrToInt(dec_bin[i]) * 2 + 1),dec_mul);
          remem:=false;
          end

        else begin
          dec_mul:=concat(IntToStr(StrToInt(dec_bin[i]) * 2),dec_mul);
          end;
        end

      else begin
        if remem = true then
          begin
          dec_mul:=concat(IntToStr((StrToInt(dec_bin[i]) * 2 + 1) mod 10),dec_mul);
          end

        else begin
          dec_mul:=concat(IntToStr((StrToInt(dec_bin[i]) * 2) mod 10),dec_mul); remem:=true;
          end;
        end;
      end;

    if dec_bin[i] = '.' then
      begin
      dec_mul:=concat('0.',dec_mul);
      end;

    if (i = 1) and (remem = true) then
      begin
      dec_mul[1]:='1';
      dec_res:=concat(dec_res,'1');
      end;

    if (i = 1) and (remem = false) then
      begin
      dec_mul[1]:='0';
      dec_res:=concat(dec_res,'0');
      end;
    end;

  if length(dec_float) > 0 then
    begin
    i:=0; loop:=false; dec_float_save:='';
    repeat
      inc(i);
      if (dec_float[i] = ' ')  then
        begin
        u:=i; compare:=''; cnt_split:=1;
        repeat
          dec(u);
          compare:=concat(dec_float[u],compare);
        until (dec_float[u - 1] = ' ') or (u = 2);

        for e:=i downto 1 do
          begin
          save:=concat(dec_float[e],save);
          delete(dec_float,e,1);
        end;


        dec_float_save:=concat(dec_float_save,save); save:='';

        inc(cnt_split);

        if (compare = dec_mul) or (FloatToStr((STrToFloat(compare) + 1)) = dec_mul) or (FloatToStr((STrToFloat(dec_mul) + 1)) = compare) then
          begin
          first:=cnt_split; last:=cnt; loop:=true;
          end;

        i:=0;
        end;
    until length(dec_float) = 0;

    if loop = false then
      begin
      dec_float_save:=concat(dec_float_save,dec_mul,' ');
      end;

    dec_float:=concat(dec_float,dec_float_save);
    end

  else begin
    dec_float:=concat(dec_float,dec_mul,' ');
    end;

  inc(cnt);
until (round(StrToFloat(dec_mul)) - StrToFloat(dec_mul) = 0) or (loop = true); //or (length(dec_res) >= 255);

if loop = true then
  begin
  for i:=1 to last do
    begin
    if i = first then
      begin
      TextColor(Green);
      write(dec_res[i]);
      end

    else write(dec_res[i]);
    end;

  TextColor(White);
  writeln('...');

  TextColor(Red);
  write(sLineBreak,'Note: ');

  TextColor(Green);
  write('Green part');

  TextColor(White);
  write(' is the loop forever part');
  end

else write(dec_res);
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
