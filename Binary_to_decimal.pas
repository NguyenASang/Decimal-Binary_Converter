uses crt,sysutils;
var s,result,res,digit_sum,digit_plus,dividend,divisor,power,sum_power,ano_sum_power,num:ansistring;
    e,f,i,u,t,w,cnt,sep:longint;
    decimal,esc,remem,negative:boolean;
    key:char;

procedure Decimal_part;
begin
u:=0;
res:=''; result:=''; digit_sum:='0.0';
for i:=sep + 1 to length(s) do
  begin
  if length(res) = 0 then dividend:='1'

  else begin
    dividend:=res; res:='';
    end;

  w:=0;
  remem:=false; esc:=false;
  while esc = false do
    begin
    inc(w);
    if dividend[w] <> '.' then
      begin
      if StrToInt(dividend[w]) mod 2 <> 0 then
        begin
        if remem = false then
          begin
          res:=concat(res,IntToStr(StrToInt(dividend[w]) div 2)); remem:=true;
          if w = length(dividend) then dividend:=concat(dividend,'1');
          end

        else begin
          if w <> length(dividend) then
            begin
            res:=concat(res,IntToStr((10 + StrToInt(dividend[w])) div 2));
            if (10 + StrToInt(dividend[w])) mod 2 = 0 then remem:=false else remem:=true;
            end

          else begin
            res:=concat(res,IntToStr((9 + StrToInt(dividend[w])) div 2));
            if (9 + StrToInt(dividend[w])) mod 2 = 0 then remem:=false else remem:=true;
            end;
          end;
        end

      else begin
        if remem = false then res:=concat(res,IntToStr(StrToInt(dividend[w]) div 2))

        else begin
          if w <> length(dividend) then
            begin
            res:=concat(res,IntToStr((10 + StrToInt(dividend[w])) div 2));
            if (10 + StrToInt(dividend[w])) mod 2 = 0 then remem:=false else remem:=true;
            end

          else begin
            res:=concat(res,IntToStr((9 + StrToInt(dividend[w])) div 2));
            if (9 + StrToInt(dividend[w])) mod 2 = 0 then remem:=false else remem:=true;
            end;
          end;
        end;
      end;

    if dividend[w] = '.' then res:=concat(res,'.');

    if w + 1 > length(dividend) then
      begin
      cnt:=0;
      for w:=1 to length(res) do
        begin
        if res[w] = '.' then inc(cnt);
        end;

      if cnt = 0 then
        begin
        for w:=length(res) downto 2 do res:=concat(res,res[w]);
        res[2]:='.';
        end;

      esc:=true;
      end;
    end;

  if s[i] <> '0' then
    begin
    digit_plus:=res;
    if length(result) > 0 then
      begin
      digit_sum:=result; result:='';
      end;

    if length(digit_plus) > length(digit_sum) then
      begin
      for e:=length(digit_sum) to length(digit_plus) - 1 do digit_sum:=concat(digit_sum,'0');
      end;

    if length(digit_plus) < length(digit_sum) then
      begin
      for e:=length(digit_plus) to length(digit_sum) - 1 do digit_plus:=concat(digit_plus,'0');
      end;

    remem:=false;
    for e:=length(digit_sum) downto 1 do
      begin
      if (digit_sum[e] <> '.') and (digit_plus[e] <> '.') then
        begin
        if StrToInt(digit_sum[e]) + StrToInt(digit_plus[e]) < 10 then
          begin
          if remem = true then
            begin
            if StrToInt(digit_sum[e]) + StrToInt(digit_plus[e]) + 1 > 9 then
              begin
              result:=concat(IntToStr((StrToInt(digit_sum[e]) + StrToInt(digit_plus[e]) + 1) mod 10),result);
              remem:=true
              end

            else begin
              result:=concat(IntToStr(StrToInt(digit_sum[e]) + StrToInt(digit_plus[e]) + 1),result);
              remem:=false;
              end;
            end

          else begin
            result:=concat(IntToStr(StrToInt(digit_sum[e]) + StrToInt(digit_plus[e])),result);
            end;
          end

        else begin
          if remem = true then
            begin
            if StrToInt(digit_sum[e]) + StrToInt(digit_plus[e]) + 1 > 9 then
              begin
              result:=concat(IntToStr((StrToInt(digit_sum[e]) + StrToInt(digit_plus[e]) + 1) mod 10),result);
              remem:=true
              end

            else begin
              result:=concat(IntToStr(StrToInt(digit_sum[e]) + StrToInt(digit_plus[e]) + 1),result);
              remem:=false;
              end;
            end

          else begin
            result:=concat(IntToStr((StrToInt(digit_sum[e]) + StrToInt(digit_plus[e])) mod 10),result);
            end;

          remem:=true;
          end;
        end;

      if (digit_sum[e] = '.') and (digit_plus[e] = '.') then result:=concat('.',result);
      end;
    end;
  end;

esc:=false;
i:=length(result);
repeat
  if result[i] = '0' then delete(result,i,1);
  if result[i - 1] <> '0' then esc:=true else esc:=false;
  dec(i);
until esc = true;

for i:=2 to length(result) do write(result[i]);
end;

procedure Integer_part;
begin
w:=sep - 1;
num:='0';
for i:=0 to sep - 2 do
  begin
  dec(w);
  if s[i + 1] <> '0' then
    begin
    cnt:=w; power:='1'; sum_power:='';
    for t:=1 to cnt do
      begin
      if length(sum_power) > 0 then
        begin
        power:=sum_power; sum_power:='';
        end;

      remem:=false;
      for f:=length(power) downto 1 do
        begin
        inc(cnt);
        if StrToInt(power[f]) * 2 < 10 then
          begin
          if remem = true then
            begin
            sum_power:=concat(IntToStr(StrToInt(power[f]) * 2 + 1),sum_power);
            if StrToInt(power[f]) * 2 + 1 > 10 then remem:=true else remem:=false;
            end

          else sum_power:=concat(IntToStr(StrToInt(power[f]) * 2),sum_power);
          end

        else begin
          if remem = true then
            begin
            sum_power:=concat(IntToStr((StrToInt(power[f]) * 2 + 1) mod 10),sum_power);
            end

          else begin
            sum_power:=concat(IntToStr((StrToInt(power[f]) * 2) mod 10),sum_power);
            remem:=true;
            end;
          end;

        if (f = 1) and (remem = true) then sum_power:=concat('1',sum_power);
        end;
      end;

    if w = 0 then sum_power:='1';

    ano_sum_power:=num; num:='';
    if length(ano_sum_power) < length(sum_power) then
      begin
      for t:=length(ano_sum_power) to length(sum_power) - 1 do ano_sum_power:=concat('0',ano_sum_power);
      end;

    if length(ano_sum_power) > length(sum_power) then
      begin
      for t:=length(sum_power) to length(ano_sum_power) - 1 do sum_power:=concat('0',sum_power);
      end;

    remem:=false;
    for t:=length(sum_power) downto 1 do
      begin
      if StrToInt(sum_power[t]) + StrToInt(ano_sum_power[t]) < 10 then
        begin
        if remem = true then
          begin
          if StrToInt(sum_power[t]) + StrToInt(ano_sum_power[t]) + 1 < 10 then
            begin
            num:=concat(IntToStr(StrToInt(sum_power[t]) + StrToInt(ano_sum_power[t]) + 1),num);
            remem:=false;
            end

          else begin
            num:=concat(IntToStr((StrToInt(sum_power[t]) + StrToInt(ano_sum_power[t]) + 1) mod 10),num);
            if t = 1 then num:=concat('1',num);
            end;
          end

        else begin
          num:=concat(IntToStr(StrToInt(sum_power[t]) + StrToInt(ano_sum_power[t])),num);
          end;
        end

      else begin
        if remem = true then
          begin
          num:=concat(IntToStr((StrToInt(sum_power[t]) + StrToInt(ano_sum_power[t]) + 1) mod 10),num);
          if t = 1 then num:=concat('1',num);
          end

        else begin
          num:=concat(IntToStr((StrToInt(sum_power[t]) + StrToInt(ano_sum_power[t])) mod 10),num); remem:=true;
          if t = 1 then num:=concat('1',num);
          end;
        end;
      end;
    end;
  end;

write(num);

if decimal = true then Decimal_part;
end;

Procedure Input;
begin
clrscr;
write('Enter binary to convert: ');

GotoXY(1,3);

TextColor(yellow);
write('Tip: ');

TextColor(White);
write('Ctrl + C = Copy | Right click = Paste');

GotoXY(26,1);

//Note: 13 = Enter | 8 = Backspace

repeat
  if length(s) = 255 then
    begin
    clrscr;
    GotoXY(1,1);
    write('Enter binary to convert: ',s);
    end;

  key:=readkey;

  if (key in ['0'..'1']) or (key = '-') and (length(s) = 0) or (key = '.') and (length(s) > 0) and (decimal = false) then
    begin
    if key = '-' then negative:=true;

    if key = '.' then decimal:=true;

    s:=concat(s,key);

    write(key);
    end;

  if length(s) = 1 then
    begin
    clrscr;
    write('Enter binary to convert: ',s);
    end;

  if (ord(key) = 8) and (length(s) <> 0) then
    begin
    if s[length(s)] = '.' then decimal:=false;

    if s[length(s)] = '-' then negative:=false;

    if WhereX = 1 then
      begin
      GotoXY(26 + length(s),WhereY - 1);
      write(' ');
      GotoXY(26 + length(s),WhereY - 1);
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

    if s[length(s)] = '.' then delete(s,length(s),1);

    if (length(s) > 1) and (decimal = true) and (s[length(s)] = '0') then
      begin
      i:=length(s) + 1;
      repeat
        dec(i);
        if s[i] = '.' then decimal:=false;
        delete(s,i,1);
      until s[i - 1] = '1';
      end;

    if (length(s) > 1) and (s[1] = '0') and (s[2] <> '.') then
      begin
      i:=1;
      repeat
        delete(s,i,1);
      until (s[i] = '0') and (s[i + 1] = '.') or (s[i] = '1');
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

  TextColor(green);
  write('back');

  TextColor(White);
  write(' | Esc to ');

  TextColor(Red);
  write('exit');

  TextColor(White);

  decimal:=false; negative:=false;
  s:='';
until ord(readkey) = 27;

exit;

readln;
end.
