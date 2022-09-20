uses keyboard, process, regexpr, strutils, sysutils, windows;

const Green       = $2;
      LightYellow = $E;
      Red         = $4;
      White       = $7;

var s, num_mul, num_res, dividend, div_res, dec_sum, dec_res: ansistring;
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
dec_sum:='0.0'; div_res:='1.0'; dec_res:='';

for i:=sep + 1 to length(s) do
  begin
  u:=0;
  remem:=false;
  dividend:=div_res; div_res:='';

  repeat
    inc(u);

    if (dividend[u] = '.') then div_res:=div_res + '.'

    else if (StrToInt(dividend[u]) mod 2 = 1) then
      begin
      if (remem = true) then
        begin
        div_res:=div_res + IntToStr((10 + StrToInt(dividend[u])) div 2);

        if ((10 + StrToInt(dividend[u])) mod 2 = 1) then remem:=true else remem:=false;
        end

      else begin
        remem:=true;
        div_res:=div_res + IntToStr(StrToInt(dividend[u]) div 2);

        if (u = length(dividend)) then dividend:=dividend + '0';
        end;
      end

    else begin
      if (remem = true) then
        begin
        remem:=false;
        div_res:=div_res + IntToStr((10 + StrToInt(dividend[u])) div 2);
        end

      else begin
        div_res:=div_res + IntToStr((StrToInt(dividend[u]) div 2));
        end;
      end;
  until (u = length(dividend));

  if (s[i] <> '0') then
    begin
    dec_res:='';
    remem:=false;

    if (length(div_res) > length(dec_sum)) then
      begin
      dec_sum:=dec_sum + dupestring('0', length(div_res) - length(dec_sum));
      end

    else begin
      div_res:=div_res + dupestring('0', length(dec_sum) - length(div_res));
      end;

    for u:=length(dec_sum) downto 2 do
      begin
      if (div_res[u] <> '.') and (dec_sum[u] <> '.') then
        begin
        if (StrToInt(div_res[u]) + StrToInt(dec_sum[u]) < 10) then
          begin
          if (remem = true) then
            begin
            if (StrToInt(div_res[u]) + StrToInt(dec_sum[u]) + 1 = 10) then
              begin
              dec_res:='0' + dec_res;
              end

            else begin
              remem:=false;
              dec_res:=IntToStr(StrToInt(div_res[u]) + StrToInt(dec_sum[u]) + 1) + dec_res;
              end;
            end

          else begin
            dec_res:=IntToStr(StrToInt(div_res[u]) + StrToInt(dec_sum[u])) + dec_res;
            end;
          end

        else begin
          if (remem = true) then
            begin
            dec_res:=IntToStr((StrToInt(div_res[u]) + StrToInt(dec_sum[u]) + 1) mod 10) + dec_res
            end

          else begin
            dec_res:=IntToStr((StrToInt(div_res[u]) + StrToInt(dec_sum[u])) mod 10) + dec_res;
            end;

          remem:=true;
          end;
        end

      else dec_res:='.' + dec_res;
      end;

    dec_sum:='0' + dec_res;
    end;
  end;

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
        num_res:=IntToStr(StrToInt(num_mul[u]) * 2 + 1) + num_res;
        if (StrToInt(num_mul[u]) * 2 + 1 > 10) then remem:=true else remem:=false;
        end

      else num_res:=IntToStr(StrToInt(num_mul[u]) * 2) + num_res;
      end

    else begin
      if (remem = true) then
        begin
        num_res:=IntToStr((StrToInt(num_mul[u]) * 2 + 1) mod 10) + num_res;
        end

      else begin
        num_res:=IntToStr((StrToInt(num_mul[u]) * 2) mod 10) + num_res;
        remem:=true;
        end;
      end;

    if (u = 1) and (remem = true) then num_res:='1' + num_res;
    end;

  if (s[i] = '1') then
    begin
    num_res:=IntToStr(StrToInt(num_res[length(num_res)]) + 1)[1];
    end;

  num_mul:=num_res;

  if (i < sep - 1) then num_res:='';
  end;

if (negative = true) then num_res:='-' + num_res;

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

    s:=s + key;

    write(key);
    end;

  if (GetAsyncKeyState(VK_CONTROL) < 0) and (GetAsyncKeyState(86) < 0) then
    begin
    i:=length(s);
    s:=s + PasteFromClip;

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

  if (length(s) > 0) and (key = #13) then
    begin
    if (negative = true) then delete(s, 1, 1);

    if (decimal = true) and (s[length(s)] in ['0', '.']) then
      begin
      repeat
        if (s[length(s)] = '.') then decimal:=false;

        delete(s, length(s), 1);
      until (s[length(s)] = '1') or (decimal = false);
      end;

    if (length(s) > 1) and (s[1] in ['0', '.']) then
      begin
      repeat
        if (s[1] = '.') then s:='0' + s

        else delete(s, 1, 1);
       until (s = '0') or (s[1] = '1') or (s[2] = '.');
       end;

    if (decimal = true) then sep:=pos('.', s)

    else sep:=length(s) + 1;

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

    s:='';
    decimal:=false; negative:=false;
  until (key = #27);
  end

else begin
  Write(TextColor(Red), 'Attention: ');

  write(TextColor(White), 'Seem like you''re running this program with the new Microsoft Terminal. Since there are many errors that can be caused in this new Terminal, I recommend you to use the default terminal by running this program as administrator');

  repeat until (readkey <> '');
  end;
end.
