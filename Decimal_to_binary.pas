uses crt,sysutils;
var i,sep,cnt:longint;
    s,num_bin,num_div,num_res,dec_mul,dec_res,compare:ansistring;
    decimal,remem,negative,loop:boolean;
    key:char;

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

      if cnt = length(s) - sep + 1 then
        begin
        compare:=dec_res;
        TextColor(Green);
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
    num_bin:=num_div;
    num_div:='';
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
write('Enter decimal to convert: ');

//Note: 13 = Enter | 8 = Backspace

repeat
  if length(s) = 255 then
    begin
    clrscr;
    GotoXY(1,1);
    write('Enter decimal to convert: ',s);
    end;

  key:=readkey;

  if (key in ['0'..'9']) or (key = '-') and (length(s) = 0) or (key = '.') and (decimal = false) then
    begin
    if key = '-' then negative:=true;
    if key = '.' then
      begin
      decimal:=true; sep:=length(s) + 1;
      end;

    s:=concat(s,key);

    write(key);
    end;

  if (ord(key) = 8) and (length(s) <> 0) then
    begin
    if s[length(s)] = '.' then decimal:=false;
    if s[length(s)] = '-' then negative:=false;

    if WhereX = 1 then
      begin
      GotoXY(length(s) + 26,WhereY - 1);
      write(' ');
      GotoXY(length(s) + 26,WhereY - 1);
      end

    else begin
      GotoXY(WhereX - 1,WhereY);
      write(' ');
      GotoXY(WhereX - 1,WhereY);
      end;

    delete(s,length(s),1)
    end;

  if (ord(key) = 13) then
    begin
    writeln;
    writeln(slineBreak,'Convert to binary: ');

    if decimal = true then
      begin
      i:=length(s) + 2;
      repeat
        dec(i);
      until (s[i - 1] in ['1'..'9']);

      delete(s,i,length(s) - i + 1);

      if sep = i then decimal:=false;
      end;

    if decimal = false then sep:=length(s);

    if negative = true then
      begin
      write('-');
      delete(s,1,1);
      dec(sep);
      end;

    if (s[1] = '0') then
      begin
      i:=0;
      repeat
       inc(i);
      until (s[i + 1] in ['1'..'9']) or (s[i] = '0') and (s[i + 1] = '.');

      if (s[i] = '0') and (s[i + 1] = '.') then dec(i);

      delete(s,1,i); sep:=sep - i;
      end;
    end;
until ord(key) = 13;

Integer_part;

readln;
end.
