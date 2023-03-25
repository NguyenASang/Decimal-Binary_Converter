uses jwapsapi, keyboard, regexpr, strutils, sysutils, windows;

const Div_2  : array [0..1, 48..57] of char = (('0', '0', '1', '1', '2', '2', '3', '3', '4', '4'),
                                               ('5', '5', '6', '6', '7', '7', '8', '8', '9', '9'));
      Mul_2  : array [0..1, 48..57] of char = (('0', '2', '4', '6', '8', '0', '2', '4', '6', '8'),
                                               ('1', '3', '5', '7', '9', '1', '3', '5', '7', '9'));
      Green  = $2;
      Red    = $4;
      White  = $7;
      Yellow = $E;

var auto_copy, ask_trunc, decimal, negative: boolean;
    s, result: ansistring;
    i, u, sep: cardinal;
    key: char;

//====================== Alternative functions for Crt ======================//

Function Color(attr: byte): string;
begin
SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), attr);

Color:='';
end;

Function Screen: coord;
var size: TConsoleScreenBufferInfo;
begin
GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), size);
Screen:=size.dwSize;
end;

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

Procedure Clear(x, y, area, des_x, des_y: cardinal);
var written: dword;
    pos: coord;
begin
pos.x:=x; pos.y:=y;
FillConsoleOutputCharacter(GetStdHandle(STD_OUTPUT_HANDLE), ' ', area, pos, written);

GotoXY(des_x, des_y);
end;

Function Readkey: char;
var key: TKeyEvent;
begin
InitKeyBoard;

key:=TranslateKeyEvent(GetKeyEvent);
Readkey:=GetKeyEventChar(key);

//Catch Ctrl + V
if (GetAsyncKeyState(VK_CONTROL) < 0) and (GetAsyncKeyState(86) < 0) then readkey:=#22;

DoneKeyBoard;
end;

//=========================== Utilities functions ===========================//

Procedure CopyClip(text: pchar);
var PchData: pchar;
    data: hglobal;
begin
data:=GlobalAlloc(GMEM_MOVEABLE, length(text) + 1);
PchData:=GlobalLock(data);
strcopy(PchData, LPCSTR(text));
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

Function PasteClip: ansistring;
var data: hglobal;
begin
OpenClipboard(0);
data:=GetClipboardData(CF_TEXT);
PasteClip:=strpas(GlobalLock(data));
GlobalUnLock(data);
CloseClipboard;
end;

Function Pause(pos: coord): boolean;
begin
write(Color(White), '...');

write(Color(Red), #13#10#13#10'Warning: ');

write(Color(White), 'The converter has been paused'#13#10#13#10'Press any key to ');

write(Color(Green), 'continue ');

write(Color(White), '| Esc to ');

write(Color(Red), 'stop ');

write(Color(White), 'the converter');

Pause:=readkey = #27;

Clear(pos.x + byte(Pause) * 3, pos.y, Screen.x * 5, pos.x + byte(Pause) * 3, pos.y);
end;

Function HandlerRoutine(CtrlType: dword): winbool; stdcall;
begin
if (result <> '') and (CtrlType = CTRL_C_EVENT) then CopyClip(Pchar(result));
end;

Function IsFocus: boolean;
var PidConsole, PidFocus: dword;
begin
GetWindowThreadProcessId(GetForegroundWindow, PidFocus);
GetWindowThreadProcessId(GetConsoleWindow, PidConsole);

IsFocus:=PidFocus = PidConsole;
end;

Function NewTerm: boolean;
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

Function Input(CharSet: TSysCharSet; chk_spec: boolean): ansistring;
var str: ansistring;
begin
Input:='';

repeat
  key:=readkey;

  if (key = #22) then
    begin
    str:=ReplaceRegExpr('[^01' + DupeString('\d', 1 - byte(CharSet = ['0', '1'])) + '\.-]+', PasteClip, '', true);

    while (PosEx('-', str, 1 + byte(chk_spec and (Input = ''))) > 0) do delete(str, RPos('-', str), 1);

    while (NPos('.', str, 1 + byte(not decimal)) > 0) do delete(str, RPos('.', str), 1);

    write(str);

    Input:=Input + str;

    decimal:=(pos('.', str) > 0) or (decimal);
    negative:=(pos('-', str) > 0) or (negative);
    end;

  if (key in CharSet) or (chk_spec) and ((Input + key = '-') or (key = '.') and (not decimal)) then
    begin
    write(key);

    Input:=Input + key;

    decimal:=(key = '.') or (decimal);
    negative:=(key = '-') or (negative);
    end;

  if (key = #8) and (length(Input) > 0) then
    begin
    if (Cursor.x > 0) then write(#8, ' ', #8)

    else begin
      GotoXY(Screen.x - 1, Cursor.y - 1);
      write(' ');
      GotoXY(Screen.x - 1, Cursor.y - 1);
      end;

    if (Input[length(Input)] = '.') then decimal:=false;

    if (Input[length(Input)] = '-') then negative:=false;

    delete(Input, length(Input), 1);
    end;

  if (key = #27) then exit('');
until (length(Input) > 0) and (key = #13);

if (chk_spec) and (negative) then delete(Input, 1, 1);

if (Input = '') or (Input[1] = '.') then Input:='0' + Input;

while (Input <> '0') and (Input[1] = '0') and (Input[2] <> '.') do delete(Input, 1, 1);

if (negative) and (Input[1] = '0') then negative:=false;

if (chk_spec) and (decimal) then
  begin
  while (Input[length(Input)] in ['0', '.']) and (decimal) and (Input <> '0') do
    begin
    if (Input[length(Input)] = '.') then decimal:=false;

    delete(Input, length(Input), 1);
    end;
  end;

if (chk_spec) then if (decimal) then sep:=pos('.', Input) else sep:=length(Input) + 1;
end;

//============================ Binary to Integer ============================//

Function BinToInt: ansistring;
begin
BinToInt:='00';

for i:=1 to sep - 1 do
  begin
  BinToInt:=StringOfChar('0', byte(BinToInt[1] in ['5'..'9'])) + BinToInt;

  for u:=1 to length(BinToInt) - 1 do BinToInt[u]:=Mul_2[byte(ord(BinToInt[u + 1]) > 52), ord(BinToInt[u])];

  BinToInt[u]:=char(ord(BinToInt[u]) - 48 + ord(s[i]));

  if (GetAsyncKeyState(27) < 0) and (IsFocus) then if (Pause(Cursor)) then exit('');
  end;

delete(BinToInt, u + 1, 1);

if (negative) then BinToInt:='-' + BinToInt;
end;

//============================ Binary to Decimal ============================//

Function BinToDec: ansistring;
const mod_10: array [0..19] of char = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                                       '0', '1', '2', '3', '4', '5', '6', '7', '8', '9');
var div_res, dec_sum: ansistring;
    remem: byte = 0;
begin
BinToDec:=StringOfChar('0', 1 + byte(sep < length(s))); div_res:='05';

for i:=sep + 1 to length(s) do
  begin
  if (s[i] = '1') then
    begin
    dec_sum:=BinToDec; BinToDec:=div_res;

    for u:=length(dec_sum) downto 1 do
      begin
      BinToDec[u]:=mod_10[(ord(div_res[u]) - 48 + ord(dec_sum[u]) - 48 + remem)];

      remem:=byte(ord(BinToDec[u]) < Max(ord(div_res[u]), ord(dec_sum[u])));
      end;
    end;

  div_res:=div_res + '5';

  for u:=length(div_res) - 1 downto 2 do div_res[u]:=Div_2[ord(div_res[u - 1]) and 1, ord(div_res[u])];

  if (GetAsyncKeyState(27) < 0) and (IsFocus) then if (Pause(Cursor)) then exit;
  end;

BinToDec[1]:=(''[0] + StringOfChar('.', byte(BinToDec <> '0')))[1 + byte(BinToDec <> '0')];
end;

//============================ Integer to Binary ============================//

Function IntToBin(num_div: ansistring): ansistring;
begin
num_div:=ReverseString(num_div) + '0'; IntToBin:='';

repeat
  IntToBin:=char(ord(num_div[1]) and 1 + 48) + IntToBin;

  for i:=1 to length(num_div) - 1 do num_div[i]:=Div_2[ord(num_div[i + 1]) and 1, ord(num_div[i])];

  delete(num_div, i, byte(num_div[i] = '0'));

  if (GetAsyncKeyState(27) < 0) and (IsFocus) then if (Pause(Cursor)) then exit('');
until (num_div = '0');

if (negative) then IntToBin:='-' + IntToBin;
end;

//============================ Decimal to Binary ============================//

Function DecToBin(dec_mul: ansistring): ansistring;
var compare, limit: ansistring;
    split: cardinal;
    pre_pos: coord;
begin
if (ask_trunc) then
  begin
  Clear(0, Cursor.y - 1, Screen.x, 0, Cursor.y - 1);

  pre_pos:=Cursor;

  writeln('How many digits do you want to display ?');

  limit:=Input(['0'..'9'], false);

  Clear(0, pre_pos.y, Screen.x * (Screen.y - pre_pos.y), 0, pre_pos.y);

  write('Convert to binary:'#13#10, result);
  end;

if (limit = '0') or (limit = '') and (ask_trunc) or (dec_mul = '') then exit;

split:=abs(length(dec_mul) - pos('1', ReverseString(IntToBin(dec_mul))) + 1);
dec_mul:=dec_mul + '0';
DecToBin:='.';

repeat
  if (not ask_trunc) then
    begin
    if (compare = dec_mul) then break;

    if (length(DecToBin) - 1 = split) then compare:=dec_mul;
    end;

  if (dec_mul[1] in ['5'..'9']) then DecToBin:=DecToBin + '1' else DecToBin:=DecToBin + '0';

  delete(dec_mul, length(dec_mul) - 1, byte(dec_mul[length(dec_mul) - 1] = '0'));

  for i:=1 to length(dec_mul) - 1 do dec_mul[i]:=Mul_2[byte(ord(dec_mul[i + 1]) > 52), ord(dec_mul[i])];

  if (GetAsyncKeyState(27) < 0) and (IsFocus) then
    begin
    if (Pause(Cursor)) then exit;

    if (not ask_trunc) and (length(DecToBin) - 1 >= split) then Color(Green);
    end;
until (dec_mul = '00') or (ask_trunc) and (length(DecToBin) - 1 = StrToInt(limit));

if (ask_trunc) then
  begin
  DecToBin:=Copy(DecToBin, 1, Min(length(DecToBin), StrToInt(limit) + 1));

  write(DecToBin);

  exit;
  end;

write(Copy(DecToBin, 1, split + 1));

if (dec_mul <> '00') then
  begin
  write(Color(Green), Copy(DecToBin, split + 2, length(DecToBin)));

  write(Color(White), '...');

  write(Color(Red), #13#10#13#10'Note: ');

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

repeat
  if (not auto_copy) then key:=readkey else auto_copy:=false;

  if (key = #3) xor (auto_copy) then CopyClip(Pchar(result));
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
  if (key <> #8) then key:=readkey

  else begin
    Clear(0, 0, Screen.x * Screen.y, 0, 0);

    if (u = 0) then key:='1' else key:='2';

    u:=0;
    end;

  case key of
    '1': begin
         Clear(0, 0, Screen.x * 30, 0, 0);

         write(Color(White), 'Enter decimal to convert: ');

         s:=Input(['0'..'9'], true);

         if (s = '') then break;

         writeln(#13#10#13#10'Convert to binary: ');

         result:=IntToBin(Copy(s, 1, sep - 1));

         if (not ask_trunc) then write(result);

         result:=result + DecToBin(Copy(s, sep + 1, length(s)));

         End_Screen;

         break;
         end;

    '2': begin
         Clear(0, 0, Screen.x * 30, 0, 0);

         write(Color(White), 'Enter binary to convert: ');

         s:=Input(['0', '1'], true);

         if (s = '') then break;

         writeln(#13#10#13#10'Convert to decimal: ');

         result:=BinToInt + BinToDec;

         write(result);

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
  result:='';

  Main_menu;
until (false);
end.
