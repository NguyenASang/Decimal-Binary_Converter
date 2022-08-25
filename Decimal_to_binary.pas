uses keyboard, process, regexpr, strutils, sysutils, windows;

const Green       = $2;
      LightYellow = $E;
      Red         = $4;
      White       = $7;

var s, num_bin, num_div, num_res, dec_mul, dec_res, compare, result, limit: ansistring;
    decimal, remem, negative, loop, show_loop, ctrl_c: boolean;
    i, sep, cnt: longint;
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

if (Regex(strpas(StrData),'^[-]?((\d+(\.\d*)?)|(\.\d+))$') = false) or (pos('.',strpas(strData)) <> 0) and (decimal = true) or (pos('-',strpas(strData)) <> 0) and (negative = true) then
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

Procedure CopyToClip;
var pchData, StrData: pchar;
    hClipData: HGlobal;
begin
if (decimal = true) then result:=concat(num_res, '.', result) else result:=num_res;

Openclipboard(0);
  EmptyClipboard;

  strData:=Stralloc(length(result) + 1);
  StrPCopy(strData, result);

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
if (dwCtrlType = CTRL_C_EVENT) and (ctrl_c = true) then CopyToClip;
end;

Function New_Terminal: boolean;
var command_res: ansistring;
begin
runcommand('cmd', ['/c', 'tasklist /v /fi "ImageName eq WindowsTerminal.exe"'], command_res);
if pos(ParamStr(0), command_res) <> 0 then New_Terminal:=true else New_Terminal:=false;
end;

Procedure Decimal_part;
begin
write('.');

cnt:=0;
loop:=false;
dec_res:='0' + Copy(s, sep, length(s));

repeat
  inc(cnt);
  remem:=false;
  dec_mul:=dec_res; dec_res:='';

  for i:=length(dec_mul) downto 1 do
    begin
    if (dec_mul[i] <> '.') and (i <> 1) then
      begin
      if (StrToInt(dec_mul[i]) * 2 < 10) then
        begin
        if (remem = true) then
          begin
          dec_res:=concat(IntToStr(StrToInt(dec_mul[i]) * 2 + 1), dec_res);
          remem:=false;
          end

        else begin
          dec_res:=concat(IntToStr(StrToInt(dec_mul[i]) * 2), dec_res);
          end;
        end

      else begin
        if (remem = true) then
          begin
          dec_res:=concat(IntToStr((StrToInt(dec_mul[i]) * 2 + 1) mod 10), dec_res);
          end

        else begin
          dec_res:=concat(IntToStr((StrToInt(dec_mul[i]) * 2) mod 10), dec_res);
          remem:=true;
          end;
        end;
      end;

    if (dec_mul[i] = '.') then dec_res:=concat('0.', dec_res);

    if (i = 1) then
      begin
      if (compare = dec_res) and (cnt <> length(s) - sep + 1) then loop:=true;

      if (cnt = length(s) - sep + 1) and (show_loop = true) then
        begin
        compare:=dec_res;
        TextColor(Green);
        end;

      if (loop = false) then
        begin
        if (remem = true) then
          begin
          result:=concat(result,'1');
          dec_res[1]:='1';
          write(1);
          end

        else begin
          result:=concat(result,'0');
          dec_res[1]:='0';
          write(0);
          end;
        end;

      if (show_loop = false) and (IntToStr(length(result)) = limit) then write('...');

      if (GetAsyncKeyState(27) < 0) then
        begin
        pre_pos:=WhereXY;

        Writeln(TextColor(White), '...');

        Write(TextColor(Red), #13#10'Warning: ');

        writeln(TextColor(White), 'The converter has been paused');

        write(#13#10'Press any key to ');

        write(TextColor(Green),'continue ');

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
      end;
    end;
until ('1.0' + dupestring('0', length(dec_res) - 3) = dec_res) or (loop = true) or (IntToStr(length(result)) = limit) and (show_loop = false);

if (loop = true) then
  begin
  writeln(TextColor(White), '...');

  write(TextColor(Red), #13#10'Note: ');

  write(TextColor(Green), 'Green part ');

  write(TextColor(White), 'is the forever loop part');
  end;
end;

Procedure Integer_part;
begin
num_res:=''; num_div:='';
num_bin:=Copy(s, 1, sep - 1);

repeat
  if (num_div <> '') then num_bin:=num_div;

  num_div:='';

  if (StrToInt(num_bin[length(num_bin)]) mod 2 <> 0) then
    begin
    num_bin:=concat(num_bin, IntToStr(StrToInt(num_bin[length(num_bin)]) - 1));
    delete(num_bin, length(num_bin) - 1, 1);
    num_res:=concat('1', num_res);
    end

  else begin
    num_res:=concat('0', num_res);
    end;

  remem:=false;
  for i:=1 to length(num_bin) do
    begin
    if (StrToInt(num_bin[i]) mod 2 <> 0) then
      begin
      if (remem = true) then
        begin
        num_div:=concat(num_div, IntToStr((10 + StrToInt(num_bin[i])) div 2));
        end

      else begin
        if (num_bin[i] = '1') and (i <> 1) then
          begin
          num_div:=concat(num_div, IntToStr(StrToInt(num_bin[i]) div 2));
          end;

        if (num_bin[i] <> '1') then
          begin
          num_div:=concat(num_div, IntToStr(StrToInt(num_bin[i]) div 2));
          end;

        remem:=true;
        end;
      end

    else begin
      if (remem = true) then
        begin
        num_div:=concat(num_div, IntToStr((10 + StrToInt(num_bin[i])) div 2));
        remem:=false;
        end

      else begin
        num_div:=concat(num_div, IntToStr(StrToInt(num_bin[i]) div 2));
        end;
      end;
    end;
until (num_div = '0');

if (negative = true) then num_res:=concat('-', num_res);

write(num_res);

if (decimal = true) then Decimal_part;
end;

Function Input(check_dec, check_neg: boolean): ansistring;
begin
input:='';

repeat
  key:=readkey;
                             //===== Prevent Ctrl + V from being treated as normal input =====//
  if (key in ['0'..'9']) and (GetAsyncKeyState(VK_CONTROL) >= 0) and (GetAsyncKeyState(86) >= 0) or (key = '-') and (length(input) = 0) and (check_neg = true) or (key = '.') and (length(input) > 0) and (decimal = false) and (check_dec = true) then
    begin
    if (key = '-') then negative:=true;

    if (key = '.') then
      begin
      decimal:=true;
      sep:=length(input) + 1;
      end;

    input:=concat(input, key);

    write(key);
    end;

  if (GetAsyncKeyState(VK_CONTROL) < 0) and (GetAsyncKeyState(86) < 0) then
    begin
    i:=length(input);
    input:=concat(input, PasteFromClip);

    write(Copy(input, i + 1, length(input)));

    if (pos('.', input) <> 0) then decimal:=true;

    if (pos('-', input) <> 0) then negative:=true;
    end;

  if (key = #8) and (length(input) > 0) then
    begin
    if (input[length(input)] = '.') then decimal:=false;

    if (input[length(input)] = '-') then negative:=false;

    if WhereXY.x = 0 then
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

    delete(input, length(input), 1);
    end;

  if (key = #13) and (length(input) > 0) then
    begin
    if (negative = true) and (check_neg = true) then delete(input, 1, 1);

    if (input[length(input)] = '.') then
      begin
      decimal:=false;
      delete(input, length(input), 1);
      end;

    if (input[1] = '.') then input:=concat('0',input);

    if (length(input) > 1) and (decimal = true) and (input[length(input)] = '0') and (check_dec = true) then
      begin
      i:=length(input) + 1;
      repeat
        dec(i);
        if (input[i] = '.') then decimal:=false;
        delete(input, i, 1);
      until (input[i - 1] in ['1'..'9']);
      end;

    if (length(input) > 1) and (input[1] = '0') and (input[2] <> '.') then
      begin
      i:=1;
      repeat
        delete(input, i, 1);
      until (input[i] = '0') and (input[i + 1] = '.') or (input[i] in ['1'..'9']);
      end;

    if (decimal = false) then sep:=length(input) + 1

    else begin
      for i:=1 to length(input) do
        begin
        if (input[i] = '.') then sep:=i;
        end;
      end;
    end;
until (key = #13) and (length(input) > 0);

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

begin
if (New_Terminal = false) then
  begin
  repeat
    ctrl_c:=false;
    SetconsoleCtrlHandler(@handlerRoutine, TRUE);

    clear(0, 0, ScreenXY.x * ScreenXY.y, 0, 0);
    write('Enter decimal to convert: ');

    s:=Input(true, true);

    writeln(#13#10#13#10'Convert to decimal: ');

    Integer_part;

    ctrl_c:=true;

    Write(TextColor(LightYellow), #13#10#13#10'Tip: ');

    writeln(TextColor(White), 'You can copy the result by pressing Ctrl + C');

    write(#13#10'Press any key to ');

    write(TextColor(Green), 'back ');

    write(TextColor(White), '| Esc to ');

    write(TextColor(Red), 'exit');

    repeat
      key:=readkey;
      if (key = #3) then CopyToClip;
    until (key <> #3);

    TextColor(White);

    result:='';
    decimal:=false; negative:=false;
  until (key = #27);
  end

else begin
  Write(TextColor(Red), 'Attention: ');

  write(TextColor(White), 'Seem like you''re running this program with the new Microsoft Terminal. Since there are many errors that can be caused in this new Terminal, I recommend you to use the default terminal by running this program as administrator');

  repeat until (readkey <> '');
  end;
end.
