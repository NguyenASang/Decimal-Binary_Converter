uses keyboard, process, regexpr, strutils, sysutils, windows;

const Green       = $2;
      LightYellow = $E;
      Red         = $4;
      White       = $7;

var s, num_res, dec_res, limit: ansistring;
    ctrl_c, decimal, negative, remem, show_loop, dec_to_bin: boolean;
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

Function TextColor(Color: byte): ansistring;
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

if (expr.Exec(str_match)) then Regex:=true else Regex:=false;

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

if (Regex(strpas(StrData), '^[-]?((\d+(\.\d*)?)|(\.\d+))$') = false) or (pos('.', strpas(strData)) > 0) and (decimal = true) or (pos('-', strpas(strData)) > 0) and ((negative = true) or (length(s) > 0)) then
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
StrData:=Pchar(text);

Openclipboard(0);
  EmptyClipboard;

  hClipData:=GlobalAlloc(GMEM_MOVEABLE, length(strData) + 1);
  pchData:=GlobalLock(hClipData);
  strcopy(pchData, LPCSTR(StrData));
  GlobalUnlock(hClipData);

  SetClipboardData(CF_TEXT, hclipData);
CloseClipboard;

Clear(0, WhereXY.y - 2, ScreenXY.x, 0, WhereXY.y - 2);

Write(TextColor(Green), 'Status: ');

write(TextColor(LightYellow), 'Copied');
end;

Function HandlerRoutine(dwCtrlType: DWORD): WINBOOL; stdcall;
begin
if (ctrl_c = true) and (dwCtrlType = CTRL_C_EVENT) then CopyToClip(num_res + dec_res);
end;

Function New_Terminal: boolean;
var command_res: ansistring;
begin
runcommand('cmd', ['/c', 'tasklist /v /fi "ImageName eq WindowsTerminal.exe"'], command_res);
if (pos(ParamStr(0), command_res) <> 0) then New_Terminal:=true else New_Terminal:=false;
end;

//============================ Binary to Decimal ============================//

Procedure Binary_to_Decimal;
var dividend, div_res, dec_sum: ansistring;
begin
div_res:='1.0'; dec_sum:='0.0'; dec_res:='';

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
    remem:=false;
    dec_sum:=dec_sum + dupestring('0', length(div_res) - length(dec_sum)); dec_res:='';

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
            dec_res:=IntToStr(StrToInt(div_res[u]) + StrToInt(dec_sum[u]) + 1)[2] + dec_res
            end

          else begin
            dec_res:=IntToStr(StrToInt(div_res[u]) + StrToInt(dec_sum[u]))[2] + dec_res;
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

Procedure Binary_to_Integer;
var num_mul: ansistring;
begin
num_mul:='0'; num_res:='';

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
        num_res:=IntToStr(StrToInt(num_mul[u]) * 2 + 1)[2] + num_res;
        end

      else begin
        remem:=true;
        num_res:=IntToStr(StrToInt(num_mul[u]) * 2)[2] + num_res;
        end;
      end;

    if (u = 1) and (remem = true) then num_res:='1' + num_res;
    end;

  if (s[i] = '1') then
    begin
    num_res[length(num_res)]:=IntToStr(StrToInt(num_res[length(num_res)]) + 1)[1];
    end;

  num_mul:=num_res;

  if (i < sep - 1) then num_res:='';
  end;

if (negative = true) then num_res:='-' + num_res;

write(num_res);

if (decimal = true) then Binary_to_Decimal;
end;

//============================ Decimal to Binary ============================//

Procedure Decimal_to_Binary;
var dec_mul, compare: ansistring;
begin
write('.');

dec_mul:='0' + Copy(s, sep, length(s)); dec_res:='.';

repeat
  remem:=false;

  for i:=length(dec_mul) downto 3 do
    begin
    if (StrToInt(dec_mul[i]) * 2 > 9) then
      begin
      if (remem = true) then
        begin
        dec_mul[i]:=IntToStr(StrToInt(dec_mul[i]) * 2 + 1)[2];
        end

      else begin
        remem:=true;
        dec_mul[i]:=IntToStr(StrToInt(dec_mul[i]) * 2)[2];
        end;
      end

    else begin
      if (remem = true) then
        begin
        remem:=false;
        dec_mul[i]:=IntToStr(StrToInt(dec_mul[i]) * 2 + 1)[1];
        end

      else begin
        dec_mul[i]:=IntToStr(StrToInt(dec_mul[i]) * 2)[1];
        end;
      end;
    end;

  if (dec_mul[length(dec_mul)] = '0') then
    begin
    repeat
      delete(dec_mul, length(dec_mul), 1);
    until (dec_mul[length(dec_mul)] in ['1'..'9']) or (dec_mul = '0');
    end;

  if (remem = true) then
    begin
    write('1');
    dec_res:=dec_res + '1';
    end

  else begin
    write('0');
    dec_res:=dec_res + '0';
    end;

  if (show_loop = true) then
    begin
    if (length(dec_res) - 1 = length(s) - sep) then
      begin
      TextColor(Green);
      compare:=dec_mul;
      end

    else if (compare = dec_mul) then break;
    end;

  if (GetAsyncKeyState(27) < 0) then
    begin
    pre_pos:=WhereXY;

    writeln(TextColor(White), '...');

    write(TextColor(Red), #13#10'Warning: ');

    writeln(TextColor(White), 'The converter has been paused');

    write(#13#10'Press any key to ');

    write(TextColor(Green), 'continue ');

    write(TextColor(White), '| Esc to ');

    write(TextColor(Red), 'stop ');

    write(TextColor(White), 'the converter');

    repeat
      key:=readkey;

      if (key = #27) then
        begin
        Clear(pre_pos.x + 3, pre_pos.y, ScreenXY.x * 5, pre_pos.x + 3, pre_pos.y);
        exit;
        end

      else begin
        Clear(pre_pos.x, pre_pos.y, ScreenXY.x * 5, pre_pos.x, pre_pos.y);

        if (show_loop = true) then TextColor(Green);
        break;
        end
    until (key <> '');
    end;
until (dec_mul = '0') or (show_loop = false) and (IntToStr(length(dec_res) - 1) = limit);

if (dec_mul <> '0') then
  begin
  writeln(TextColor(White), '...');

  write(TextColor(Red), #13#10'Note: ');

  write(TextColor(Green), 'Green part ');

  write(TextColor(White), 'is the forever loop part');
  end;
end;

Procedure Integer_to_Binary;
var num_div: ansistring;
begin
num_div:=Copy(s, 1, sep - 1); num_res:='';

repeat
  delete(num_div, pos(' ', num_div), 1);

  if (StrToInt(num_div[length(num_div)]) mod 2 = 1) then
    begin
    num_div[length(num_div)]:=IntToStr(StrToInt(num_div[length(num_div)]) - 1)[1];
    num_res:='1' + num_res;
    end

  else begin
    num_res:='0' + num_res;
    end;

  remem:=false;

  for i:=1 to length(num_div) do
    begin
    if (StrToInt(num_div[i]) mod 2 = 1) then
      begin
      if (remem = true) then
        begin
        num_div[i]:=IntToStr((10 + StrToInt(num_div[i])) div 2)[1];
        end

      else begin
        remem:=true;
        if (i > 1) or (i = 1) and (num_div[i] <> '1') then num_div[i]:=IntToStr(StrToInt(num_div[i]) div 2)[1]

        else num_div[i]:=' ';
        end;
      end

    else begin
      if (remem = true) then
        begin
        remem:=false;
        num_div[i]:=IntToStr((10 + StrToInt(num_div[i])) div 2)[1];
        end

      else begin
        num_div[i]:=IntToStr(StrToInt(num_div[i]) div 2)[1];
        end;
      end;
    end;
until (num_div = '0');

if (negative = true) then num_res:='-' + num_res;

write(num_res);

if (decimal = true) then Decimal_to_Binary;
end;

//============================ Input check ============================//

Function Input(check_dec, check_neg: boolean): ansistring;
var char_check: array of ansistring;
begin
input:='';

if (dec_to_bin = true) then char_check:=['0', '1', '2', '3', '4', '5', '6', '7', '8', '8', '9'] else char_check:=['0', '1'];

repeat
  key:=readkey;
                             //===== Prevent Ctrl + V from being treated as normal input =====//
  if (AnsiMatchText(key, char_check) = true) and (GetAsyncKeyState(VK_CONTROL) >= 0) and (GetAsyncKeyState(86) >= 0) or (check_neg = true) and (length(input) = 0) and (key = '-') or (check_dec = true) and (decimal = false) and (key = '.') then
    begin
    if (key = '-') then negative:=true;

    if (key = '.') then decimal:=true;

    input:=input + key;

    write(key);
    end;

  if (GetAsyncKeyState(VK_CONTROL) < 0) and (GetAsyncKeyState(86) < 0) then
    begin
    i:=length(input);
    input:=input + PasteFromClip;

    write(Copy(input, i + 1, length(input)));

    if (pos('.', input) > 0) then decimal:=true;

    if (pos('-', input) > 0) then negative:=true;
    end;

  if (length(input) > 0) then
    begin
    if (key = #8) then
      begin
      if (WhereXY.x = 0) then
        begin
        GotoXY(ScreenXY.x - 1, WhereXY.y - 1);
        write(' ');
        GotoXY(ScreenXY.x - 1, WhereXY.y - 1);
        end

      else begin
        GotoXY(WhereXY.x - 1, WhereXY.y);
        write(' ');
        GotoXY(WhereXY.x - 1, WhereXY.y);
        end;

      if (input[length(input)] = '.') then decimal:=false;

      if (input[length(input)] = '-') then negative:=false;

      delete(input, length(input), 1);
      end;

    if (key = #13) then
      begin
      if (check_neg = true) and (negative = true) then delete(input, 1, 1);

      if (check_dec = true) and (decimal = true) and (input[length(input)] in ['0', '.']) then
        begin
        repeat
          if (input[length(input)] = '.') then decimal:=false;

          delete(input, length(input), 1);
        until (AnsiMatchText(input[length(input)], char_check) = true) or (decimal = false);
        end;

      if (length(input) > 1) and (input[1] in ['0', '.']) then
        begin
        repeat
          if (input[1] = '.') then input:='0' + input

          else delete(input, 1, 1);
        until (AnsiMatchText(input[1], char_check) = true) or (input[2] = '.') or (input = '0');
        end;

      if (check_dec = true) and (check_neg = true) then
        begin
        if (decimal = true) then sep:=pos('.', input)

        else sep:=length(input) + 1;
        end;

      if (decimal = true) and (check_dec = true) then
        begin
        write(#13#10#13#10'Do you want to show looping part of the decimal part ? ');

        writeln('Y = Yes | N = No');

        write(TextColor(Red), #13#10'Warning: ');

        writeln(TextColor(White), 'Choosing "Yes" will provide more accurate results, but it can sometimes take some time to calculate.');

        writeln('         Choosing "No" will give you an option to choose how many digits you want to display.');

        write(TextColor(LightYellow), #13#10'Tip: ');

        write(TextColor(White), 'You can pause the converter by pressing Esc while it''s converting');

        repeat
          key:=readkey;

          case lowercase(key) of
            'y' : begin
                  clear(0, WhereXY.y - 5, ScreenXY.x * 6, 0, WhereXY.y - 7);

                  show_loop:=true;
                  exit;
                  end;

            'n' : begin
                  clear(0, WhereXY.y - 5, ScreenXY.x * 6, 0, WhereXY.y - 5);

                  pre_pos:=WhereXY;

                  writeln('How many digits do you want to display ?');

                  limit:=Input(false, false);

                  clear(0, pre_pos.y, ScreenXY.x * (ScreenXY.y - pre_pos.y), 0, pre_pos.y - 2);

                  show_loop:=false;
                  exit;
                  end;
          end;
        until (false); // <- Trick to repeat forever without condition
        end;
      end;
    end;
until (length(input) > 0) and (key = #13);
end;

begin
if (New_Terminal = false) then
  begin
  repeat
    ctrl_c:=false;
    SetconsoleCtrlHandler(@handlerRoutine, TRUE);

    clear(0, 0, ScreenXY.x * ScreenXY.y, 0, 0);
    write(TextColor(White), 'Choose a converter: ');

    write(#13#10, '[1] Decimal to binary ');
    writeln(#13#10, '[2] Binary to decimal');

    repeat
      key:=readkey;
      case key of
        '1': dec_to_bin:=true;
        '2': dec_to_bin:=false;
        end;
    until (key in ['1', '2']);

    Clear(0, 0, ScreenXY.x * (ScreenXY.y - WhereXY.y), 0, 0);

    if (dec_to_bin = true) then write(TextColor(White), 'Enter decimal to convert: ')

    else write(TextColor(White), 'Enter binary to convert: ');

    s:=Input(true, true);

    if (dec_to_bin = true ) then
      begin
      writeln(#13#10#13#10'Convert to binary: ');
      Integer_to_Binary;
      end

    else begin
      writeln(#13#10#13#10'Convert to decimal: ');
      Binary_to_Integer;
      end;

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

    decimal:=false; negative:=false;
  until (key = #27);
  end

else begin
  write(TextColor(Red), 'Attention: ');

  write(TextColor(White), 'Seem like you''re running this program with the new Microsoft Terminal. Since there are many errors that can be caused in this new Terminal, I recommend you to use the default terminal by running this program as administrator');

  repeat until (readkey <> '');
  end;
end.
