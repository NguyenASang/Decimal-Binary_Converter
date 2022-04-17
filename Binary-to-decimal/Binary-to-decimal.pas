uses crt,sysutils;
var s,result,res,num_str,digit_sum,digit_plus,dividend,divisor:ansistring;
    i,u,e,wrong,sep,cnt,w:longint;
    num:extended;
    a:array[1..100000000] of longint;
    decimal,remem,esc:boolean;

procedure deci;
begin
num_str:=concat(FloatToStr(num),'.');
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
        if remem=false then
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

    if w+1 > length(dividend) then
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
        for e:=length(digit_sum) to length(digit_plus)-1 do digit_sum:=concat(digit_sum,'0');
        end;

    if length(digit_plus) < length(digit_sum) then
      begin
      for e:=length(digit_plus) to length(digit_sum)-1 do digit_plus:=concat(digit_plus,'0');
      end;

    remem:=false;
    for e:=length(digit_sum) downto 1 do
      begin
      if (digit_sum[e] <> '.') and (digit_plus[e] <> '.') then
        begin
        if StrToInt(digit_sum[e]) + StrToInt(digit_plus[e]) < 10 then
          begin
          if remem=true then
            begin

            if StrToInt(digit_sum[e]) + StrToInt(digit_plus[e]) + 1 > 9 then
              begin
              result:=concat(IntToStr((StrToInt(digit_sum[e]) + StrToInt(digit_plus[e])+1) mod 10),result);
              remem:=true
              end

            else begin
              result:=concat(IntToStr(StrToInt(digit_sum[e]) + StrToInt(digit_plus[e])+1),result);
              remem:=false;
              end;
            end

          else result:=concat(IntToStr(StrToInt(digit_sum[e]) + StrToInt(digit_plus[e])),result);
          end

        else begin
          if remem=true then
            begin
            if StrToInt(digit_sum[e]) + StrToInt(digit_plus[e]) + 1 > 9 then
              begin
              result:=concat(IntToStr((StrToInt(digit_sum[e]) + StrToInt(digit_plus[e])+1) mod 10),result);
              remem:=true
              end

            else begin
              result:=concat(IntToStr(StrToInt(digit_sum[e]) + StrToInt(digit_plus[e])+1),result);
              remem:=false;
              end;
            end

          else begin
            result:=concat(IntToStr((StrToInt(digit_sum[e]) + StrToInt(digit_plus[e])) mod 10),result);
            end;

          remem:=true;
          end;
        end;

      if (digit_sum[e]='.') and (digit_plus[e]='.') then result:=concat('.',result);
      end;
    end;
  end;

for i:=2 to length(result) do write(result[i]);
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

if decimal = true then u:=sep-1 else u:=length(s);

num:=0;
for i:=1 to u do
  begin
  dec(u);
  num:=num + StrToInt(s[i])*(exp(u*ln(2)));
  end;

write(num:0:0);

if decimal = true then deci;

readln;
end.
