uses crt,sysutils;
var i,sep,cnt:longint;
    s,num_bin,num_div,num_res,dec_mul,dec_res,dec_out,compare:ansistring;
    decimal,remem,negative,loop,show_loop,pass:boolean;
    key:char;
    file_out:text;

procedure Decimal_part;
begin
write('.');

dec_res:=''; dec_mul:=''; compare:=''; dec_out:='';
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
          dec_res:=concat(IntToStr((StrToInt(dec_mul[i]) * 2) mod 10),dec_res);
          remem:=true;
          end;
        end;
      end;

    if dec_mul[i] = '.' then
      begin
      dec_res:=concat('0.',dec_res);
      end;

    if i = 1 then
      begin
      if (compare = dec_res) and (cnt <> length(s) - sep + 1) and (show_loop = true) or (cnt = 100) and (show_loop = false) then
        begin
        loop:=true;

        if length(dec_out) + length(num_res) + 1 >= 2550 then
          begin
          writeln(file_out,')...');
          end

        else begin
          TextColor(White);
          writeln('...');
          end;

        if (show_loop = true) and (length(dec_out) + length(num_res) + 1 < 2550) then
          begin
          TextColor(Red);
          write(sLineBreak,'Note: ');

          TextColor(Green);
          write('Green part');

          TextColor(White);
          write(' is the forever loop part');
          end;

        break;
        end;

      if cnt = length(s) - sep + 1 then
        begin
        repeat
          pass:=false;

          clrscr;
          writeln('Enter decimal to convert: ',s);

          writeln(slineBreak,'Convert to decimal: ',sLineBreak,num_res,'.',dec_out);

          write(sLineBreak, 'Do you want to show looping part ?');

          writeln(' Y = Yes | N = No | L = Learn more');

          case readkey of
            'y', 'Y' : begin
                       show_loop:=true;
                       pass:=true;
                       end;

            'n', 'N' : begin
                       show_loop:=false;
                       pass:=true;
                       end;

            'l', 'L' : begin
                       clrscr;
                       writeln('Enter decimal to convert: ',s);

                       writeln(slineBreak,'Convert to decimal: ',sLineBreak,num_res,'.',dec_out);

                       TextColor(Yellow);
                       writeln(sLineBreak, 'Learn more: ');

                       TextColor(White);
                       writeln('- Showing the loop part gives you more accurate results, but sometimes takes long time to display.');
                       writeln('- If you do not want to display looping part, it will only display first 100 characters of the result.');
                       readln;
                       end;
          end;
        until pass = true;

        clrscr;
        writeln('Enter decimal to convert: ',s);

        write(slineBreak,'Convert to decimal: ',sLineBreak,num_res,'.',dec_out);

        if show_loop = true then TextColor(Green);

        compare:=dec_res;
        end;

      if remem = true then
        begin
        dec_res[1]:='1';
        dec_out:=concat(dec_out,'1');
        if length(dec_out) + length(num_res) + 1 > 2550 then write(file_out,1) else write(1);
        end

      else begin
        dec_res[1]:='0';
        dec_out:=concat(dec_out,'0');
        if length(dec_out) + length(num_res) + 1 > 2550 then write(file_out,0) else write(0);
        end;
      end;
    end;

  inc(cnt);

  if length(dec_out) + length(num_res) + 1 = 2550 then
  begin
  clrscr;

  TextColor(Red);
  write('Alert: ');

  TextColor(White);
  write('Output is in text file because the result was too long');

  Insert('(',dec_out,length(s) - sep + 1);

  assign(file_out,'output.txt'); rewrite(file_out);

  write(file_out,'Convert to decimal: ',sLineBreak,num_res,'.',dec_out);
  end;
until (round(StrToFloat(dec_res)) - StrToFloat(dec_res) = 0) or (loop = true);

if length(dec_out) + length(num_res) + 1 >= 2550 then
  begin

  write(file_out,sLineBreak,'Note: Numbers in bracket is the looping forever part');

  close(file_out);

  executeprocess('notepad.exe',['output.txt']);
  end;
end;

procedure Integer_part;
begin
num_bin:=''; num_res:='';
for i:=1 to sep - 1 do num_bin:=concat(num_bin,s[i]);

num_div:=s;
repeat
  if num_div <> s then num_bin:=num_div;

  num_div:='';

  if StrToInt(num_bin[length(num_bin)]) mod 2 <> 0 then
    begin
    num_bin:=concat(num_bin,IntToStr(StrToInt(num_bin[length(num_bin)]) - 1));
    delete(num_bin,length(num_bin) - 1,1);
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

procedure Input;
begin
clrscr;
write('Enter decimal to convert: ');

GotoXY(1,3);

TextColor(yellow);
write('Tip: ');

TextColor(White);
write('Ctrl + C = Copy | Right click = Paste');

GotoXY(27,1);

//Note: 13 = Enter | 8 = Backspace

repeat
  key:=readkey;

  if (key in ['0'..'9']) or (key = '-') and (length(s) = 0) or (key = '.') and (length(s) > 0) and (decimal = false) then
    begin
    if key = '-' then negative:=true;

    if key = '.' then
      begin
      decimal:=true; sep:=length(s) + 1;
      end;

    s:=concat(s,key);

    write(key);
    end;

  if length(s) = 1 then
    begin
    clrscr;
    write('Enter decimal to convert: ',s);
    end;

  if (ord(key) = 8) and (length(s) <> 0) then
    begin
    if s[length(s)] = '.' then decimal:=false;

    if s[length(s)] = '-' then negative:=false;

    if WhereX = 1 then
      begin
      GotoXY((length(s) + 26) div (WhereY - 1),WhereY - 1);
      write(' ');
      GotoXY((length(s) + 26) div (WhereY - 1),WhereY - 1);
      end

    else begin
      GotoXY(WhereX - 1,WhereY);
      write(' ');
      GotoXY(WhereX - 1,WhereY);
      end;

    delete(s,length(s),1);
    end;

  if ord(key) = 13 then
    begin
    if negative  = true then delete(s,1,1);

    if s[length(s)] = '.' then
      begin
      decimal:=false;
      delete(s,length(s),1);
      end;

    if (length(s) > 1) and (decimal = true) and (s[length(s)] = '0') then
      begin
      i:=length(s) + 1;
      repeat
        dec(i);
        if s[i] = '.' then decimal:=false;
        delete(s,i,1);
      until s[i - 1] in ['1'..'9'];
      end;

    if (length(s)> 1) and (s[1] = '0') and (s[2] <> '.') then
      begin
      i:=1;
      repeat
        delete(s,i,1);
      until (s[i] = '0') and (s[i + 1] = '.') or (s[i] in ['1'..'9']);
      end;

    if decimal = false then sep:=length(s) + 1

    else begin
      for i:=1 to length(s) do
        begin
        if s[i] = '.' then sep:=i;
        end;
      end;

    writeln(sLineBreak,slineBreak,'Convert to decimal: ');
    end;
until ord(key) = 13;

Integer_part;
end;

begin
repeat
  Input;

  write(sLineBreak,sLineBreak,'Press any key to ');

  TextColor(Green);
  write('back');

  TextColor(White);
  write(' | Esc to ');

  TextColor(Red);
  write('exit');

  TextColor(White);

  decimal:=false; negative:=false; loop:=false;
  s:='';
until ord(readkey) = 27;

exit;

readln;
end.
