uses crt,sysutils;
var s,result,res,digit_sum,digit_plus,dividend,divisor,power,sum_power,ano_sum_power,num:ansistring;
    e,f,i,u,t,w,cnt,sep,wrong:longint;
    decimal,esc,remem:boolean;

procedure Decimal_part;
begin
u:=0; digit_sum:='0.0'; w:=0; res:='';
for i:=sep+1 to length(s) do
  begin

  if length(res) = 0 then dividend:='1'

  else begin
    dividend:=res; res:='';
    end;

  remem:=false; w:=0; esc:=false;
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

          else result:=concat(IntToStr(StrToInt(digit_sum[e]) + StrToInt(digit_plus[e])),result);
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

          else result:=concat(IntToStr((StrToInt(digit_sum[e]) + StrToInt(digit_plus[e])) mod 10),result);

          remem:=true;
          end;
        end;

      if (digit_sum[e] = '.') and (digit_plus[e] = '.') then result:=concat('.',result);
      end;
    end;
  end;

esc:=false; i:=length(result);
repeat
  if result[i] = '0' then delete(result,i,1);
  if result[i-1] <> '0' then esc:=true else esc:=false;
  dec(i);
until esc = true;

for i:=2 to length(result) do write(result[i]);
end;

procedure Integer_part;
begin
w:=u; num:='0';
for i:=0 to u - 1 do
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

          if remem = true then sum_power:=concat(IntToStr((StrToInt(power[f]) * 2 + 1) mod 10),sum_power)

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

begin
clrscr;
write('Enter the binary to convert:  '); readln(s);

wrong:=2;
while wrong > 1 do
  begin

  wrong:=0; decimal:=false;
  for i:=1 to length(s) do
    begin

    if s[i] = '.' then
      begin
      inc(wrong);
      decimal:=true;
      end;

    if (s[i] <> '.') and (s[i] <> '0') and (s[i] <> '1') then inc(wrong);
    end;

  if wrong > 1 then
    begin
    write('Invalid binary entered, re-enter: '); readln(s);
    end;
  end;

writeln(sLineBreak,'Convert to decimal: ');

for i:=1 to length(s) do
  begin
  if s[i] = '.' then sep:=i;
  end;

if decimal = true then u:=sep - 1 else u:=length(s);

Integer_part;

readln;
end.
