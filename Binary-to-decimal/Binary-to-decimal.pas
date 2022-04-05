uses crt,math,sysutils;
var s,result,num_str,digit_sum,digit_plus,dividend,divisor:ansistring;
    i,u,e,wrong,sep,cnt,rest:longint;
    num:extended;
    a:array[1..100000000] of longint;
    decimal,remem:boolean;

procedure deci;
begin
num_str:=concat(FloatToStr(num),'.');
u:=0; digit_sum:='0.0';
for i:=sep+1 to length(s) do
  begin
  inc(u);
  if s[i]<>'0' then
    begin

    dividend:='1';
    divisor:=IntToStr(round(exp(u*ln(2))));
    digit_plus:='0.';
    rest:=1;

    while rest<>0 do
      begin
      cnt:=0;
      while StrToInt(dividend)<StrToInt(divisor) do
        begin
        inc(cnt); dividend:=concat(dividend,'0');
        if cnt>1 then digit_plus:=concat(digit_plus,'0');
        end;

      digit_plus:=concat(digit_plus,IntToStr(StrToInt(dividend) div StrToInt(divisor)));
      rest:=StrToInt(dividend) mod StrToInt(divisor);
      dividend:=IntToStr(rest);
      end;


    if length(result)>0 then
      begin
      digit_sum:=result;
      result:='';
      end;

    if length(digit_plus)>length(digit_sum) then
      begin
      for e:=length(digit_sum) to length(digit_plus)-1 do digit_sum:=concat(digit_sum,'0');
      end;

    if length(digit_plus)<length(digit_sum) then
      begin
      for e:=length(digit_plus) to length(digit_sum)-1 do digit_plus:=concat(digit_plus,'0');
      end;

    remem:=false;
    for e:=length(digit_sum) downto 1 do
      begin
      if (digit_sum[e]<>'.') and (digit_plus[e]<>'.') then
        begin
        if StrToInt(digit_sum[e]) + StrToInt(digit_plus[e])<10 then
          begin
          if remem=true then
            begin

            if StrToInt(digit_sum[e]) + StrToInt(digit_plus[e]) + 1>9 then
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
            if StrToInt(digit_sum[e]) + StrToInt(digit_plus[e]) + 1>9 then
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

write(round(num));
for i:=2 to length(result) do write(result[i]);
end;


begin
clrscr;
write('Enter the binary to convert:  '); readln(s);

wrong:=2;
while wrong>1 do
  begin
  wrong:=0; decimal:=false;
  for i:=1 to length(s) do
    begin
    if s[i]='.' then
      begin
      inc(wrong); decimal:=true;
      end;

    if (s[i] in ['a'..'z']) or (s[i] in ['A'..'Z']) or (s[i] in ['2'..'9']) or (s[i]=',') then inc(wrong);
    end;

  if wrong>1 then
    begin
    write('Invaild binary entered, re-enter: '); readln(s);
    end;
  end;

writeln(sLineBreak,'Convert to decimal: ');

for i:=1 to length(s) do
  begin
  if s[i]='.' then sep:=i;
  end;



if decimal=true then
  begin
  u:=sep-1;
  for i:=1 to u do
    begin
    dec(u);
    num:=num + StrToInt(s[i])*(exp(u*ln(2)));
    end;
  deci;
  end

else begin
  num:=0; u:=length(s);
  for i:=1 to u do
    begin
    dec(u);
    num:=num + StrToInt(s[i])*(exp(u*ln(2)));
    end;
  write(num:0:0);
  end;

readln;
end.
