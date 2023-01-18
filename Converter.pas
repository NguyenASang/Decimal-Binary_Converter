{$ASMMODE INTEL}

uses jwapsapi, keyboard, regexpr, strutils, sysutils, windows;

const Div_even  : array [0..9] of char = ('0', '0', '1', '1', '2', '2', '3', '3', '4', '4');
      Div_odd   : array [0..9] of char = ('5', '5', '6', '6', '7', '7', '8', '8', '9', '9');
      Mul_big   : array [0..9] of char = ('1', '3', '5', '7', '9', '1', '3', '5', '7', '9');
      Mul_small : array [0..9] of char = ('0', '2', '4', '6', '8', '0', '2', '4', '6', '8');
      Green     = $2;
      Red       = $4;
      White     = $7;
      Yellow    = $E;

var auto_copy, ask_trunc, decimal, negative: bool;
    s, num_res, dec_res: ansistring;
    i, u, sep: cardinal;
    pre_pos: coord;
    key: char;

//====================== Alternative functions for Crt ======================//

Function Cursor: coord;
var pos: TConsoleScreenBufferInfo;
begin
GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), pos);
Cursor:=pos.dwCursorPosition;
end;

Procedure GotoXY(x, y: cardinal);
var pos: coord;
begin
pos.x:=x; pos.y:=y;
SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), pos);
end;

Function Color(attr: byte): string;
begin
SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), attr);
Color:='';
end;

Function Readkey: char;
var k: TKeyEvent;
begin
InitKeyBoard;
k:=TranslateKeyEvent(GetKeyEvent);
Readkey:=GetKeyEventChar(k);

//Catch Ctrl + V
if (GetAsyncKeyState(VK_CONTROL) < 0) and (GetAsyncKeyState(86) < 0) then readkey:=#22;
DoneKeyBoard;
end;

Function Screen: coord;
var size: TConsoleScreenBufferInfo;
begin
GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), size);
Screen:=size.dwSize;
end;

Procedure Clear(x, y, area, des_x, des_y: cardinal);
var written: dword;
    pos: coord;
begin
pos.x:=x; pos.y:=y;
FillConsoleOutputCharacter(GetStdHandle(STD_OUTPUT_HANDLE), ' ', area, pos, written);

GotoXY(des_x, des_y);
end;

//=========================== Utilities functions ===========================//

Function ChrToInt(c: char): byte; assembler;
asm
sub al, '0'
end;

Function IntToChr(b: byte): char; assembler;
asm
add al, '0'
end;

Function IsFocus: bool;
var PidConsole, PidFocus: dword;
begin
GetWindowThreadProcessId(GetForegroundWindow, PidFocus);
GetWindowThreadProcessId(GetConsoleWindow, PidConsole);

IsFocus:=PidFocus = PidConsole;
end;

Function RPosSet(CharSet: TSysCharSet; str: ansistring): cardinal;
begin
for RPosSet:=length(str) downto 1 do
  begin
  if (str[RPosSet] in CharSet) then exit;
  end;

RPosSet:=0;
end;

Function Format(str: ansistring; CharSet: TSysCharSet; chk_spec, is_clip: bool): ansistring;
begin
if (is_clip) then
  begin
  while ((not chk_spec) or (negative) or (decimal)) and (pos('-', str) > 0) or (Rpos('-', str) > 1) do delete(str, RPos('-', str), 1);

  while ((not chk_spec) or (decimal)) and (pos('.', str) > 0) or (NPos('.', str, 2) > 0) do delete(str, RPos('.', str), 1);

  while (CharSet = ['0', '1']) and (PosSet(['2'..'9'], str) > 0) do delete(str, PosSet(['2'..'9'], str), 1);

  exit(str);
  end;

if (chk_spec) and (negative) then delete(str, 1, 1);

if (str = '') or (str[1] = '.') then str:='0' + str;

while (str <> '') and ((str[1] in ['0', '.']) and (str <> '0') and ((str[2] <> '.') or (not decimal))) do delete(str, 1, 1);

if (negative) and (str[1] = '0') then negative:=false;

if (chk_spec) and (decimal) then
  begin
  while (str <> '0') and (decimal) and (str[length(str)] in ['0', '.']) do
    begin
    if (str[length(str)] = '.') then decimal:=false;

    delete(str, length(str), 1);
    end;
  end;

Format:=str;
end;

Function PasteClip(CharSet: TSysCharSet; chk_spec: bool): ansistring;
var data: handle;
    expr: TRegExpr;
begin
OpenClipboard(0);
data:=GetClipboardData(CF_TEXT);
PasteClip:=strpas(GlobalLock(data));
GlobalUnlock(data);
CloseClipboard;

expr:=TRegExpr.Create;
expr.Expression:='[^\d\.-]+';

PasteClip:=Format(ReplaceRegExpr(expr.Expression, PasteClip, '', true), CharSet, chk_spec, true);

expr.Free;

write(PasteClip);
end;

Procedure CopyClip(text: ansistring);
var PchData, StrData: pchar;
    data: handle;
begin
StrData:=Pchar(text);
data:=GlobalAlloc(GMEM_MOVEABLE, length(StrData) + 1);
PchData:=GlobalLock(data);
strcopy(PchData, LPCSTR(StrData));
GlobalUnlock(data);

Openclipboard(0);
EmptyClipboard;
SetClipboardData(CF_TEXT, data);
CloseClipboard;

Clear(0, Cursor.y - 2, Screen.x, 0, Cursor.y - 2);

write(Color(Green), 'Status: ');

write(Color(Yellow), 'Copied');

GotoXY(52, Cursor.y + 2);
end;

Function HandlerRoutine(CtrlType: dword): bool; stdcall;
begin
if (num_res <> '') and (CtrlType = CTRL_C_EVENT) then CopyClip(num_res + dec_res);
end;

Function NewTerm: bool;
var path: ansistring;
    proc: handle;
    pid: dword;
begin
GetWindowThreadProcessId(GetForegroundWindow, pid);

proc:=OpenProcess(PROCESS_ALL_ACCESS, false, pid);

setlength(path, MAX_PATH);
GetProcessImageFileName(proc, Pchar(path), MAX_PATH);

NewTerm:=pos('WindowsTerminal.exe', path) > 0;
end;

//=============================== Check input ===============================//

Function Input(CharSet: TSysCharSet; chk_spec: bool): ansistring;
begin
input:='';

repeat
  key:=readkey;

  if (key = #22) then
    begin
    input:=input + PasteClip(CharSet, chk_spec);

    decimal:=pos('.', input) > 0;
    negative:=pos('-', input) > 0;
    end;

  if (key in CharSet) or (chk_spec) and ((key = '-') and (input = '') or (key = '.') and (not decimal)) then
    begin
    if (key = '-') then negative:=true;

    if (key = '.') then decimal:=true;

    input:=input + key;

    write(key);
    end;

  if (key = #8) and (length(input) > 0) then
    begin
    if (Cursor.x > 0) then write(#8, ' ', #8)

    else begin
      GotoXY(Screen.x - 1, Cursor.y - 1);
      write(' ');
      GotoXY(Screen.x - 1, Cursor.y - 1);
      end;

    if (input[length(input)] = '.') then decimal:=false;

    if (input[length(input)] = '-') then negative:=false;

    delete(input, length(input), 1);
    end;

  if (key = #27) then exit('');
until (length(input) > 0) and (key = #13);

input:=Format(input, CharSet, chk_spec, false);

if (chk_spec) then if (decimal) then sep:=pos('.', input) else sep:=length(input) + 1;
end;

//============================ Binary to Integer ============================//

Function BinToInt: ansistring;
begin
BinToInt:='00';

for i:=1 to sep - 1 do
  begin
  if (BinToInt[1] in ['5'..'9']) then BinToInt:='0' + BinToInt;

  for u:=1 to length(BinToInt) - 1 do
    begin
    if (BinToInt[u + 1] in ['5'..'9']) then BinToInt[u]:=Mul_big[ChrToInt(BinToInt[u])]

    else BinToInt[u]:=Mul_small[ChrToInt(BinToInt[u])];
    end;

  BinToInt[u]:=IntToChr(ChrToInt(BinToInt[u]) + ChrToInt(s[i]));
  end;

delete(BinToInt, u + 1, 1);

if (negative) then BinToInt:='-' + BinToInt;
end;

//============================ Binary to Decimal ============================//

Procedure BinToDec;
var div_res, dec_sum: ansistring;
    remem: byte;
begin
div_res:='5'; dec_res:='';

for i:=sep + 1 to length(s) do
  begin
  if (s[i] = '1') then
    begin
    remem:=0;
    dec_sum:=dec_res + StringOfChar('0', length(div_res) - length(dec_sum)); dec_res:='';

    for u:=length(dec_sum) downto 1 do
      begin
      dec_res:=IntToChr((ChrToInt(div_res[u]) + ChrToInt(dec_sum[u]) + remem) mod 10) + dec_res;

      if (ChrToInt(div_res[u]) + ChrToInt(dec_sum[u]) + remem < 10) then remem:=0 else remem:=1;
      end;
    end;

  div_res:='0' + div_res + '5';

  for u:=length(div_res) - 1 downto 2 do
    begin
    if (div_res[u - 1] in ['1', '3', '5', '7', '9']) then div_res[u]:=Div_odd[ChrToInt(div_res[u])]

    else div_res[u]:=Div_even[ChrToInt(div_res[u])];
    end;

  delete(div_res, 1, 1);
  end;

dec_res:='.' + dec_res;

write(dec_res)
end;

//============================ Integer to Binary ============================//

Function IntToBin(num_div: ansistring): ansistring;
begin
num_div:='0' + num_div; IntToBin:='';

repeat
  IntToBin:=IntToChr(ChrToInt(num_div[length(num_div)]) mod 2) + IntToBin;

  for i:=length(num_div) downto 2 do
    begin
    if (num_div[i - 1] in ['1', '3', '5', '7', '9']) then num_div[i]:=Div_odd[ChrToInt(num_div[i])]

    else num_div[i]:=Div_even[ChrToInt(num_div[i])];
    end;

  if (num_div[2] = '0') then delete(num_div, 1, 1);
until (num_div = '0');

if (negative) then IntToBin:='-' + IntToBin;
end;

//============================ Decimal to Binary ============================//

Procedure DecToBin(dec_mul: ansistring);
var compare: ansistring;
    split: cardinal;
    limit: variant;
begin
if (ask_trunc) then
  begin
  Clear(0, Cursor.y - 1, Screen.x, 0, Cursor.y - 1);

  pre_pos:=Cursor;

  writeln('How many digits do you want to display ?');

  limit:=Format(Input(['0'..'9'], false), ['0'..'9'], false, false);

  Clear(0, pre_pos.y, Screen.x * (Screen.y - pre_pos.y), 0, pre_pos.y);

  write('Convert to binary:'#13#10, num_res);
  end;

if (limit = '0') then exit else write('.');

split:=abs(length(dec_mul) - pos('1', ReverseString(IntToBin(dec_mul))) + 1); dec_res:='.';

repeat
  if (not ask_trunc) then
    begin
    if (compare = dec_mul) then break;

    if (length(dec_res) - 1 = split) then
      begin
      Color(Green);
      compare:=dec_mul;
      end;
    end;

  if (dec_mul[1] in ['5'..'9']) then
    begin
    write(1);
    dec_res:=dec_res + '1';
    end

  else begin
    write(0);
    dec_res:=dec_res + '0';
    end;

  dec_mul:=dec_mul + '0';

  for i:=1 to length(dec_mul) - 1 do
    begin
    if (dec_mul[i + 1] in ['5'..'9']) then dec_mul[i]:=Mul_big[ChrToInt(dec_mul[i])]

    else dec_mul[i]:=Mul_small[ChrToInt(dec_mul[i])];
    end;

  delete(dec_mul, RPosSet(['1'..'9'], dec_mul) + 1, i);

  if (GetAsyncKeyState(27) < 0) and (IsFocus) then
    begin
    pre_pos:=Cursor;

    writeln(Color(White), '...');

    write(Color(Red), #13#10'Warning: ');

    write(Color(White), 'The converter has been paused'#13#10#13#10'Press any key to ');

    write(Color(Green), 'continue ');

    write(Color(White), '| Esc to ');

    write(Color(Red), 'stop ');

    write(Color(White), 'the converter');

    if (readkey = #27) then
      begin
      Clear(pre_pos.x + 3, pre_pos.y, Screen.x * 5, pre_pos.x + 3, pre_pos.y);
      exit;
      end;

    Clear(pre_pos.x, pre_pos.y, Screen.x * 5, pre_pos.x, pre_pos.y);

    if (not ask_trunc) and (length(dec_res) - 1 >= split) then Color(Green);
    end;
until (dec_mul = '0') or (ask_trunc) and (length(dec_res) - 1 = limit);

if (not ask_trunc) and (dec_mul <> '0') then
  begin
  writeln(Color(White), '...');

  write(Color(Red), #13#10'Note: ');

  write(Color(Green), 'Green part ');

  write(Color(White), 'is the part that repeats forever');
  end;
end;

//============================ User interface ============================//

Procedure End_screen;
begin
write(Color(Yellow), #13#10#13#10'Tip: ');

write(Color(White), 'You can copy result by pressing Ctrl + C'#13#10#13#10'Press backspace to ');

write(Color(Green), 'back ');

write(Color(White), '| Esc to ');

write(Color(Red), 'return ');

write(Color(White), 'to main menu');

if (auto_copy) then CopyClip(num_res + dec_res);

repeat
  key:=readkey;

  if (key = #3) then CopyClip(num_res + dec_res);
until (key in [#27, #8]);
end;

Procedure Main_menu;
begin
Clear(0, 0, Screen.x * Screen.y, 0, 0);

//This design is inspired of https://github.com/abbodi1406/KMS_VL_ALL_AIO

write(Color(White), '  _______________________________________________________'#13#10#13#10);

write(Color(White), '      Main options:                                      '#13#10#13#10);

write(Color(White), '  [1] Decimal to Binary                                        '#13#10);

write(Color(White), '  [2] Binary to Decimal                                        '#13#10);

write(Color(White), '  _______________________________________________________'#13#10#13#10);

write(Color(White), '      Configuration:                                     '#13#10#13#10);

write(Color(White), '  [3] Auto copy result to clipboard                 ');

if (auto_copy) then writeln(Color(Green), '[Yes]') else writeln('[Nah]');

write(Color(White), '  [4] Ask for truncating (Decimal to Binary)        ');

if (ask_trunc) then writeln(Color(Green), '[Yes]') else writeln('[Nah]');

write(Color(White), '  _______________________________________________________'#13#10#13#10);

write(Color(White), '  Press key to choose option or Esc key to Exit: ');

repeat
  if (key = #8) then
    begin
    Clear(0, 0, Screen.x * Screen.y, 0, 0);

    if (u = 0) then key:='1' else key:='2';

    u:=0;
    end

  else key:=readkey;

  case key of
    '1': begin
         Clear(0, 0, Screen.x * 30, 0, 0);

         write(Color(White), 'Enter decimal to convert: ');

         s:=Input(['0'..'9'], true);

         if (s = '') then break;

         writeln(#13#10#13#10'Convert to binary: ');

         num_res:=IntToBin(Copy(s, 1, sep - 1));

         if (not ask_trunc) or (not decimal) then write(num_res);

         if (decimal) then DecToBin(Copy(s, sep + 1, length(s)));

         End_Screen;

         break;
         end;

    '2': begin
         Clear(0, 0, Screen.x * 30, 0, 0);

         write(Color(White), 'Enter binary to convert: ');

         s:=Input(['0', '1'], true);

         if (s = '') then break;

         writeln(#13#10#13#10'Convert to decimal: ');

         num_res:=BinToInt;

         write(num_res);

         if (decimal) then BinToDec;

         End_Screen;

         break;
         end;

    '3': begin
         Clear(0, 29, Screen.x, Cursor.x, Cursor.y);

         GotoXY(Cursor.x + 3, Cursor.y - 4);

         auto_copy:=not auto_copy;

         if (not auto_copy) then write(Color(Red), '[Nah]') else write(Color(Green), '[Yes]');

         GotoXY(Cursor.x - 8, Cursor.y + 4);
         end;

    '4': begin
         Clear(0, 29, Screen.x, Cursor.x, Cursor.y);

         GotoXY(Cursor.x + 3, Cursor.y - 3);

         ask_trunc:=not ask_trunc;

         if (not ask_trunc) then
           begin
           write(Color(Red), '[Nah]');

           GotoXY(0, 29);

           write(Color(Yellow), 'Tip: ');

           write(Color(White), 'Longer decimals take longer to calculate, you can always pause the converter with the ESC key');

           GotoXY(Cursor.x - 49, Cursor.y - 15);
           end

         else begin
           write(Color(Green), '[Yes]');

           GotoXY(0, 29);

           write(Color(Yellow), 'Tip: ');

           write(Color(White), 'For good accuracy I recommend choosing at least 20 digits');

           GotoXY(Cursor.x - 13, Cursor.y - 15);
           end;
         end;

    #08: key:=#0;

    #27: halt;
    end;
until (false);
end;

//================================ Main part ================================//

begin
SetconsoleCtrlHandler(@handlerRoutine, true);

if (NewTerm) then
  begin
  write(Color(Red), 'Attention: ');

  write(Color(White), 'I recommend using the default terminal to avoid some bugs by running this program as administrator.');

  repeat until (readkey <> ''); halt;
  end;

repeat
  decimal:=false; negative:=false;
  num_res:=''; dec_res:='';

  Main_menu;
until (false);
end.
