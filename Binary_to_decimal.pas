uses keyboard, process, regexpr, strutils, sysutils, windows;

const Green       = $2;
      LightYellow = $E;
      Red         = $4;
      White       = $7;

var s, num_mul, num_res, dividend, div_res, dec_plus, dec_sum, dec_res: ansistring;
    ctrl_c, decimal, negative, remem: boolean;
    i, u, sep: longint;
    pre_pos: coord;
    key: char;

Function WhereXY: coord;
var cursor_pos: TConsoleScreenBufferInfo;
begin
GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), cursor_pos);
WhereXY:=cursor_pos.dwCursorPosition;
end;

Procedure GoToXY(x, y: longint);
var cursor_pos: coord;
begin
cursor_pos.x:=x;
cursor_pos.y:=y;
SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), cursor_pos);
end;

Function TextColor(Color: Byte): ansistring;
var ConsoleInfo: TConsoleScreenBufferInfo;
begin
SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), Color);
TextColor:='';
end;

Function Readkey: char;
var k: TKeyEvent;
begin
InitKeyBoard;
  k:=TranslateKeyEvent(GetKeyEvent);
  readkey:=GetKeyEventChar(k);
DoneKeyBoard;
end;

Function ScreenXY: coord;
var ScreenSize: TConsoleScreenBufferInfo;
begin
GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), ScreenSize);
ScreenXY:=ScreenSize.dwSize;
end;

Procedure Clear(start_x, start_y, area, end_x, end_y: longint);
var dwNumWritten: dword;
    pos: coord;
begin
pos.x:=start_x;
pos.y:=start_y;
FillConsoleOutputCharacter(GetStdHandle(STD_OUTPUT_HANDLE), ' ', area, pos, &dwNumWritten);
GotoXY(end_x, end_y);
end;

Function Regex(str_match, reg: ansistring): boolean;
var expr: TRegExpr;
begin
expr:=TRegExpr.Create;
expr.Expression:=reg;

if (expr.Exec(str_match)) then Regex:=true
else Regex:=false;

expr.Free;
end;

Function PasteFromClip: ansistring;
var hClipData: handle;
    StrData: pchar;
begin
OpenClipboard(0);
  hClipdata:=GetClipboardData(CF_TEXT);
  StrData:=GlobalLock(hClipData);
  GlobalUnlock(hClipData);
CloseClipboard;

if (Regex(strpas(StrData), '^[-]?(([01]+(\.[01]*)?)|(\.[01]+))$') = false) or (pos('.', strpas(strData)) <> 0) and (decimal = true) or (pos('-', strpas(strData)) <> 0) and (length(s) <> 0) then
  begin
  pre_pos:=WhereXY;

  write(TextColor(Red), #13#10#13#10'Warning: ');

  write(TextColor(White), 'Your clipboard contains invalid characters');

  repeat until (readkey = #13); // <- Alternative to readln

  Clear(pre_pos.x, pre_pos.y, ScreenXY.x * 3, pre_pos.x, pre_pos.y);

  PasteFromClip:='';
  end

else PasteFromClip:=Strpas(strdata);
end;

Procedure CopyToClip(text: ansistring);
var pchData, StrData: pchar;
    hClipData: HGlobal;
begin
Openclipboard(0);
  EmptyClipboard;

  strData:=Stralloc(length(text) + 1);
  StrPCopy(strData, text);

  hClipData:=GlobalAlloc(GMEM_MOVEABLE, length(strData) + 1);
  pchData:=GlobalLock(hClipData);
  strcopy(pchData, LPCSTR(StrData));
  GlobalUnlock(hClipData);

  SetClipboardData(CF_TEXT, hclipData);
CloseClipboard;

Clear(0, WhereXY.y - 2, ScreenXY.x, 0, WhereXY.y - 2);

write(TextColor(Green), 'Status: ');

write(TextColor(LightYellow), 'Copied');
end;

Function HandlerRoutine(dwCtrlType: DWORD): WINBOOL; stdcall;
begin
if (dwCtrlType = CTRL_C_EVENT) and (ctrl_c = true) then CopyToClip(num_res + dec_res);
end;

Function New_Terminal: boolean;
var command_res: ansistring;
begin
runcommand('cmd', ['/c', 'tasklist /v /fi "ImageName eq WindowsTerminal.exe"'], command_res);
if (pos(ParamStr(0), command_res) <> 0) then New_Terminal:=true else New_Terminal:=false;
end;

Procedure Decimal_part;
begin
div_res:=''; dec_res:=''; dec_sum:='0.0';

for i:=sep + 1 to length(s) do
  begin
  if (length(div_res) = 0) then dividend:='1'

  else begin
    dividend:=div_res; div_res:='';
    end;

  remem:=false;
  for u:=1 to length(dividend) + 1 do
    begin
    if (dividend[u] <> '.') then
      begin
      if (StrToInt(dividend[u]) mod 2 <> 0) then
        begin
        if (remem = false) then
          begin
          remem:=true;
          if (u = length(dividend)) then dividend:=concat(dividend, '1');
          div_res:=concat(div_res, IntToStr(StrToInt(dividend[u]) div 2));
          end

        else begin
          if (u <> length(dividend)) then
            begin
            div_res:=concat(div_res, IntToStr((10 + StrToInt(dividend[u])) div 2));
            if ((10 + StrToInt(dividend[u])) mod 2 = 0) then remem:=false else remem:=true;
            end

          else begin
            div_res:=concat(div_res, IntToStr((9 + StrToInt(dividend[u])) div 2));
            if ((9 + StrToInt(dividend[u])) mod 2 = 0) then remem:=false else remem:=true;
            end;
          end;
        end

      else begin
        if (remem = false) then div_res:=concat(div_res, IntToStr(StrToInt(dividend[u]) div 2))

        else begin
          if (u <> length(dividend)) then
            begin
            div_res:=concat(div_res, IntToStr((10 + StrToInt(dividend[u])) div 2));
            if ((10 + StrToInt(dividend[u])) mod 2 = 0) then remem:=false else remem:=true;
            end

          else begin
            div_res:=concat(div_res, IntToStr((9 + StrToInt(dividend[u])) div 2));
            if ((9 + StrToInt(dividend[u])) mod 2 = 0) then remem:=false else remem:=true;
            end;
          end;
        end;
      end;

    if (dividend[u] = '.') then div_res:=concat(div_res, '.');

    if (u = length(dividend)) then
      begin
      if (pos('.', div_res) = 0) then
        begin
        insert('.', div_res, pos('0', div_res) + 1);
        end;
      end;
    end;

  if (s[i] <> '0') then
    begin
    dec_plus:=div_res;

    if (length(dec_res) > 0) then
      begin
      dec_sum:=dec_res; dec_res:='';
      end;

    if (length(dec_plus) > length(dec_sum)) then
      begin
      dec_sum:=concat(dec_sum, dupestring('0', length(dec_plus) - length(dec_sum)));
      end

    else begin
      dec_plus:=concat(dec_plus, dupestring('0', length(dec_sum) - length(dec_plus)));
      end;

    remem:=false;
    for u:=length(dec_sum) downto 1 do
      begin
      if (dec_sum[u] <> '.') and (dec_plus[u] <> '.') then
        begin
        if (StrToInt(dec_sum[u]) + StrToInt(dec_plus[u]) < 10) then
          begin
          if (remem = true) then
            begin
            if (StrToInt(dec_sum[u]) + StrToInt(dec_plus[u]) + 1 > 9) then
              begin
              dec_res:=concat(IntToStr((StrToInt(dec_sum[u]) + StrToInt(dec_plus[u]) + 1) mod 10), dec_res);
              remem:=true
              end

            else begin
              dec_res:=concat(IntToStr(StrToInt(dec_sum[u]) + StrToInt(dec_plus[u]) + 1), dec_res);
              remem:=false;
              end;
            end

          else begin
            dec_res:=concat(IntToStr(StrToInt(dec_sum[u]) + StrToInt(dec_plus[u])), dec_res);
            end;
          end

        else begin
          if (remem = true) then
            begin
            if (StrToInt(dec_sum[u]) + StrToInt(dec_plus[u]) + 1 > 9) then
              begin
              dec_res:=concat(IntToStr((StrToInt(dec_sum[u]) + StrToInt(dec_plus[u]) + 1) mod 10), dec_res);
              remem:=true
              end

            else begin
              dec_res:=concat(IntToStr(StrToInt(dec_sum[u]) + StrToInt(dec_plus[u]) + 1), dec_res);
              remem:=false;
              end;
            end

          else begin
            dec_res:=concat(IntToStr((StrToInt(dec_sum[u]) + StrToInt(dec_plus[u])) mod 10), dec_res);
            end;

          remem:=true;
          end;
        end

      else dec_res:=concat('.', dec_res);
      end;
    end;
  end;

delete(dec_res, 1, 1);

write(dec_res);
end;

Procedure Integer_part;
begin
num_res:=''; num_mul:='0';

for i:=1 to sep - 1 do
  begin
  remem:=false;

  for u:=length(num_mul) downto 1 do
    begin
    if (StrToInt(num_mul[u]) * 2 < 10) then
      begin
      if (remem = true) then
        begin
        num_res:=concat(IntToStr(StrToInt(num_mul[u]) * 2 + 1), num_res);
        if (StrToInt(num_mul[u]) * 2 + 1 > 10) then remem:=true else remem:=false;
        end

      else num_res:=concat(IntToStr(StrToInt(num_mul[u]) * 2), num_res);
      end

    else begin
      if (remem = true) then
        begin
        num_res:=concat(IntToStr((StrToInt(num_mul[u]) * 2 + 1) mod 10), num_res);
        end

      else begin
        num_res:=concat(IntToStr((StrToInt(num_mul[u]) * 2) mod 10), num_res);
        remem:=true;
        end;
      end;

    if (u = 1) and (remem = true) then num_res:=concat('1', num_res);
    end;

  if (s[i] = '1') then
    begin
    num_res:=concat(num_res, IntToStr(StrToInt(num_res[length(num_res)]) + 1));
    delete(num_res, length(num_res) - 1, 1);
    end;

  num_mul:=num_res;

  if (i <> sep - 1) then num_res:='';
  end;

if (negative = true) then num_res:=concat('-', num_res);

write(num_res);

if (decimal = true) then Decimal_part;
end;

Procedure Input;
begin
Clear(0, 0, ScreenXY.x * ScreenXY.y, 0, 0);
write('Enter binary to convert: ');

repeat
  key:=readkey;
                             //===== Prevent Ctrl + V from being treated as normal input =====//
  if (key in ['0'..'1']) and (GetAsyncKeyState(VK_CONTROL) >= 0) and (GetAsyncKeyState(86) >= 0) or (key = '-') and (length(s) = 0) or (key = '.') and (decimal = false) then
    begin
    if (key = '-') then negative:=true;

    if (key = '.') then decimal:=true;

    s:=concat(s, key);

    write(key);
    end;

  if (GetAsyncKeyState(VK_CONTROL) < 0) and (GetAsyncKeyState(86) < 0) then
    begin
    i:=length(s);
    s:=concat(s, PasteFromClip);

    write(Copy(s, i + 1, length(s)));

    if (pos('.', s) <> 0) then decimal:=true;

    if (pos('-', s) <> 0) then negative:=true;
    end;

  if (key = #8) and (length(s) <> 0) then
    begin
    if (s[length(s)] = '.') then decimal:=false;

    if (s[length(s)] = '-') then negative:=false;

    if (WhereXY.x = 0) then
      begin
      GotoXY(ScreenXY.x - 1, WhereXY.y - 1);
      write(' ');
      GotoXY(ScreenXY.x - 1, WhereXY.y);
      end

    else begin
      GotoXY(WhereXY.x - 1, WhereXY.y);
      write(' ');
      GotoXY(WhereXY.x - 1, WhereXY.y);
      end;

    delete(s, length(s), 1);
    end;

  if (key = #13) and (length(s) <> 0) then
    begin
    if (negative = true) then delete(s, 1, 1);

    if (s[length(s)] = '.') then
      begin
      decimal:=false;
      delete(s, length(s), 1);
      end;

    if (s[1] = '.') then s:=concat('0', s);

    if (length(s) > 1) and (decimal = true) and (s[length(s)] = '0') then
      begin
      i:=length(s) + 1;
      repeat
        dec(i);
        if (s[i] = '.') then decimal:=false;
        delete(s, i, 1);
      until (s[i - 1] = '1');
      end;

    if (length(s) > 1) and (s[1] = '0') and (s[2] <> '.') then
      begin
      i:=1;
      repeat
        delete(s, i, 1);
      until (s[i] = '0') and (s[i + 1] = '.') or (s[i] = '1');
      end;

    if (decimal = false) then sep:=length(s) + 1

    else begin
      for i:=1 to length(s) do
        begin
        if (s[i] = '.') then sep:=i;
        end;
      end;

    writeln(#13#10#13#10'Convert to decimal: ');
    end;
until (key = #13) and (length(s) <> 0);

Integer_part;
end;

begin
if (New_Terminal = false) then
  begin
  repeat
    ctrl_c:=false;
    SetconsoleCtrlHandler(@handlerRoutine, TRUE);

    Input;

    ctrl_c:=true;

    write(TextColor(LightYellow), #13#10#13#10'Tip: ');

    writeln(TextColor(White), 'You can copy the result by pressing Ctrl + C');

    write(#13#10'Press any key to ');

    write(TextColor(Green), 'back ');

    write(TextColor(White), '| Esc to ');

    write(TextColor(Red), 'exit');

    repeat
      key:=readkey;
      if (key = #3) then CopyToClip(num_res + dec_res);
    until (key <> #3);

    TextColor(White);

    s:=''; dec_res:='';
    decimal:=false; negative:=false;
  until (key = #27);
  end

else begin
  Write(TextColor(Red), 'Attention: ');

  write(TextColor(White), 'Seem like you''re running this program with the new Microsoft Terminal. Since there are many errors that can be caused in this new Terminal, I recommend you to use the default terminal by running this program as administrator');

  repeat until (readkey <> '');
  end;
end.
