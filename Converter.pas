{$ASMMODE INTEL}

uses process, regexpr, strutils, sysutils, windows;

const Div_even  : array [0..9] of char = ('0', '0', '1', '1', '2', '2', '3', '3', '4', '4');
      Div_odd   : array [0..9] of char = ('5', '5', '6', '6', '7', '7', '8', '8', '9', '9');
      Mul_small : array [0..9] of char = ('0', '2', '4', '6', '8', '0', '2', '4', '6', '8');
      Mul_big   : array [0..9] of char = ('1', '3', '5', '7', '9', '1', '3', '5', '7', '9');
      Green     = $2;
      Yellow    = $E;
      Red       = $4;
      White     = $7;

var allow_copy, auto_copy, ask_trunc, show_tip, decimal, negative: boolean;
    s, num_res, dec_res: ansistring;
    i, u, sep: cardinal;
    pre_pos: coord;
    key: char;

//=========================== Optimized functions ===========================//

//Credit to John O'Harrow from The Fastcode Challenges

Function ChrPos(ch: char; str: ansistring): cardinal; nostackframe assembler;
asm
  test      edx, edx
  jz        @@NullString
  mov       ecx, [edx - 4]
  push      ebx
  mov       ebx, eax
  cmp       ecx, 16
  jl        @@Small

@@NotSmall:
  mov       ah, al
  movd      xmm1, eax
  pshuflw   xmm1, xmm1, 0
  pshufd    xmm1, xmm1, 0

@@First16:
  movups    xmm0, [edx]
  pcmpeqb   xmm0, xmm1
  pmovmskb  eax, xmm0
  test      eax, eax
  jnz       @@FoundStart
  cmp       ecx, 32
  jl        @@Medium

@@Align:
  sub       ecx, 16
  push      ecx
  mov       eax, edx
  neg       eax
  and       eax, 15
  add       edx, ecx
  neg       ecx
  add       ecx, eax

@@Loop:
  movaps    xmm0, [edx + ecx]
  pcmpeqb   xmm0, xmm1
  pmovmskb  eax, xmm0
  test      eax, eax
  jnz       @@Found
  add       ecx, 16
  jle       @@Loop
  pop       eax
  add       edx, 16
  add       eax, ecx
  jmp       dword ptr [@@JumpTable2 + ecx * 4]
  nop
  nop

@@NullString:
  xor       eax, eax
  ret
  nop

@@FoundStart:
  bsf       eax, eax
  pop       ebx
  inc       eax
  ret
  nop
  nop

@@Found:
  pop       edx
  bsf       eax, eax
  add       edx, ecx
  pop       ebx
  lea       eax, [eax + edx + 1]
  ret

@@Medium:
  add       edx, ecx
  mov       eax, 16
  jmp       dword ptr [@@JumpTable1 - 64 + ecx * 4]
  nop
  nop

@@Small:
  add       edx, ecx
  xor       eax, eax
  jmp       dword ptr [@@JumpTable1 + ecx * 4]
  nop

@@JumpTable1:
  dd        @@NotFound, @@01, @@02, @@03, @@04, @@05, @@06, @@07
  dd        @@08, @@09, @@10, @@11, @@12, @@13, @@14, @@15, @@16

@@JumpTable2:
  dd        @@16, @@15, @@14, @@13, @@12, @@11, @@10, @@09, @@08
  dd        @@07, @@06, @@05, @@04, @@03, @@02, @@01, @@NotFound

@@16:
  add       eax, 1
  cmp       bl, [edx - 16]
  je        @@Done

@@15:
  add       eax, 1
  cmp       bl, [edx - 15]
  je        @@Done

@@14:
  add       eax, 1
  cmp       bl, [edx - 14]
  je        @@Done

@@13:
  add       eax, 1
  cmp       bl, [edx - 13]
  je        @@Done

@@12:
  add       eax, 1
  cmp       bl, [edx - 12]
  je        @@Done

@@11:
  add       eax, 1
  cmp       bl, [edx - 11]
  je        @@Done

@@10:
  add       eax, 1
  cmp       bl, [edx - 10]
  je        @@Done

@@09:
  add       eax, 1
  cmp       bl, [edx - 9]
  je        @@Done

@@08:
  add       eax, 1
  cmp       bl, [edx - 8]
  je        @@Done

@@07:
  add       eax, 1
  cmp       bl, [edx - 7]
  je        @@Done

@@06:
  add       eax, 1
  cmp       bl, [edx - 6]
  je        @@Done

@@05:
  add       eax, 1
  cmp       bl, [edx - 5]
  je        @@Done

@@04:
  add       eax, 1
  cmp       bl, [edx - 4]
  je        @@Done

@@03:
  add       eax, 1
  cmp       bl, [edx - 3]
  je        @@Done

@@02:
  add       eax, 1
  cmp       bl, [edx - 2]
  je        @@Done

@@01:
  add       eax, 1
  cmp       bl, [edx - 1]
  je        @@Done

@@NotFound:
  xor       eax, eax
  pop       ebx
  ret

@@Done:
  pop       ebx
end;

//Both functions below are inspired by @svecon's code

Function ChrToInt(c: char): byte; assembler;
asm
sub al, '0'
end;

Function IntToChr(b: byte): char; assembler;
asm
add al, '0'
end;

//====================== Alternative functions for Crt ======================//

Function WhereXY: coord;
var cursor_pos: TConsoleScreenBufferInfo;
begin
GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), cursor_pos);
WhereXY:=cursor_pos.dwCursorPosition;
end;

Procedure GoToXY(x, y: cardinal);
var cursor_pos: coord;
begin
cursor_pos.x:=x;
cursor_pos.y:=y;
SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), cursor_pos);
end;

Function Color(attr: word): string;
begin
SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), attr);
Color:='';
end;

Function Readkey: char;
var Event      : TInputrecord;
    EventsRead : dword;
begin
readkey:=#0;

repeat
  ReadConsoleInput(GetStdhandle(STD_INPUT_HANDLE), Event, 1, EventsRead);

  if (Event.Eventtype = key_Event) and (Event.Event.KeyEvent.bKeyDown) then
    begin
    // Prevent Ctrl key from being captured
    if (Event.Event.KeyEvent.wVirtualKeyCode <> 17) then Readkey:=Event.Event.KeyEvent.asciichar;
    end;

  // Trap Ctrl + V event
  if (GetAsyncKeyState(VK_CONTROL) < 0) and (GetAsyncKeyState(86) < 0) then Readkey:=#22;
until (Readkey <> #0);
end;

Function ScreenXY: coord;
var ScreenSize: TConsoleScreenBufferInfo;
begin
GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), ScreenSize);
ScreenXY:=ScreenSize.dwSize;
end;

Procedure Clear(start_x, start_y, area, end_x, end_y: cardinal);
var dwNumWritten: dword;
    pos: coord;
begin
pos.x:=start_x;
pos.y:=start_y;
FillConsoleOutputCharacter(GetStdHandle(STD_OUTPUT_HANDLE), ' ', area, pos, &dwNumWritten);
GotoXY(end_x, end_y);
end;

//=========================== Utilities functions ===========================//

Function Regex(str_match, reg: ansistring): boolean;
var expr: TRegExpr;
begin
expr:=TRegExpr.Create;
expr.Expression:=reg;

if (expr.Exec(str_match)) then Regex:=true else Regex:=false;

expr.Free;
end;

Function RPosSet(CharSet: TSysCharSet; str: ansistring): cardinal;
begin
for RPosSet:=length(str) downto 1 do
  begin
  if (str[RPosSet] in CharSet) then exit;
  end;

RPosSet:=0;
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

if (Regex(strpas(StrData), '^[-]?((\d+(\.\d*)?)|(\.\d+))$') = false) or (ChrPos('.', strpas(strData)) > 0) and (decimal = true) or (ChrPos('-', strpas(strData)) > 0) and ((negative = true) or (length(s) > 0)) then
  begin
  pre_pos:=WhereXY;

  write(Color(Red), #13#10#13#10'Warning: ');

  write(Color(White), 'Your clipboard contains invalid characters');

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

if (show_tip = true) then Clear(0, WhereXY.y - 2, ScreenXY.x, 0, WhereXY.y - 2)

else begin
  Clear(0, WhereXY.y, ScreenXY.x, 0, WhereXY.y);

  GotoXY(0, WhereXY.y + 2);

  write(Color(White), 'Press backspace to ');

  write(Color(Green), 'back ');

  write(Color(White), '| Esc to ');

  write(Color(Red), 'exit');

  GotoXY(0, WhereXY.y - 2);
  end;

write(Color(Green), 'Status: ');

write(Color(Yellow), 'Copied');
end;

Function HandlerRoutine(dwCtrlType: DWORD): WINBOOL; stdcall;
begin
if (allow_copy = true) and (dwCtrlType = CTRL_C_EVENT) then CopyToClip(num_res + dec_res);
end;

Function New_Terminal: boolean;
var command_res: ansistring;
begin
runcommand('cmd', ['/c', 'tasklist /v /fi "ImageName eq WindowsTerminal.exe"'], command_res);
if (pos(ParamStr(0), command_res) <> 0) then New_Terminal:=true else New_Terminal:=false;
end;

//============================ Input check ============================//

Function Input(CharSet: TSysCharSet; check_dec, check_neg: boolean): ansistring;
begin
input:='';

if (check_dec = true) and (check_neg = true) then
  begin
  decimal:=false; negative:=false;
  end;

repeat
  key:=readkey;

  if (key in CharSet) or (check_neg = true) and (length(input) = 0) and (key = '-') or (check_dec = true) and (decimal = false) and (key = '.') then
    begin
    if (key = '-') then negative:=true;

    if (key = '.') then decimal:=true;

    input:=input + key;

    write(key);
    end;

  if (key = #22) then
    begin
    i:=length(input);
    input:=input + PasteFromClip;

    write(Copy(input, i + 1, length(input)));

    if (decimal = false) and (ChrPos('.', input) > 0) then decimal:=true;

    if (negative = false) and (ChrPos('-', input) > 0) then negative:=true;
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
        until (input[length(input)] in CharSet) or (decimal = false);
        end;

      if (length(input) > 1) and (input[1] in ['0', '.']) then
        begin
        repeat
          if (input[1] = '.') then input:='0' + input

          else delete(input, 1, 1);
        until (input[1] in CharSet) or (input[2] = '.') or (input = '0');
        end;

      if (check_dec = true) and (check_neg = true) then
        begin
        if (decimal = true) then sep:=ChrPos('.', input)

        else sep:=length(input) + 1;
        end;
      end;
    end;
until (length(input) > 0) and (key = #13) or (key = #27);

if (key = #27) then input:='';
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

delete(BinToInt, length(BinToInt), 1);

if (negative = true) then BinToInt:='-' + BinToInt;
end;

//============================ Binary to Decimal ============================//

Procedure BinToDec;
var div_res, dec_sum: ansistring;
    remem: byte;
begin
div_res:='5';

for i:=sep + 1 to length(s) do
  begin
  if (s[i] = '1') then
    begin
    remem:=0;
    dec_sum:=dec_res + dupestring('0', length(div_res) - length(dec_sum)); dec_res:='';

    for u:=length(dec_sum) downto 1 do
      begin
      if (ChrToInt(div_res[u]) + ChrToInt(dec_sum[u]) + remem < 10) then
        begin
        dec_res:=IntToChr(ChrToInt(div_res[u]) + ChrToInt(dec_sum[u]) + remem) + dec_res;
        remem:=0;
        end

      else begin
        dec_res:=IntToChr((ChrToInt(div_res[u]) + ChrToInt(dec_sum[u]) + remem) mod 10) + dec_res;
        remem:=1;
        end;
      end;
    end;

  div_res:='0' + div_res + '0';

  for u:=length(div_res) downto 2 do
    begin
    if (div_res[u - 1] in ['1', '3', '5', '7', '9'])  then div_res[u]:=Div_odd[ChrToInt(div_res[u])]

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

if (negative = true) then IntToBin:='-' + IntToBin;
end;

//============================ Decimal to Binary ============================//

Procedure DecToBin(dec_mul: ansistring);
var show_loop: boolean = true;
    compare: ansistring;
    split: cardinal;
    limit: variant;
begin
if (ask_trunc = true) then
  begin
  clear(0, WhereXY.y - 1, ScreenXY.x * 6, 0, WhereXY.y - 1);

  pre_pos:=WhereXY;

  writeln('How many digits do you want to display ?');

  limit:=Input(['0'..'9'], false, false);

  clear(0, pre_pos.y, ScreenXY.x * (ScreenXY.y - pre_pos.y), 0, pre_pos.y);

  write('Convert to binary:'#13#10, num_res);

  show_loop:=false;
  end;

write('.');

split:=abs(length(dec_mul) - ChrPos('1', ReverseString(IntToBin(dec_mul))) + 1); dec_res:='.';

repeat
  if (show_loop = true) then
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
    write('1');
    dec_res:=dec_res + '1';
    end

  else begin
    write('0');
    dec_res:=dec_res + '0';
    end;

  dec_mul:=dec_mul + '0';

  for i:=1 to length(dec_mul) - 1 do
    begin
    if (dec_mul[i + 1] in ['5'..'9']) then dec_mul[i]:=Mul_big[ChrToInt(dec_mul[i])]

    else dec_mul[i]:=Mul_small[ChrToInt(dec_mul[i])];
    end;

  delete(dec_mul, RPosSet(['1'..'9'], dec_mul) + 1, length(dec_mul));

  if (GetAsyncKeyState(27) < 0) then
    begin
    pre_pos:=WhereXY;

    writeln(Color(White), '...');

    write(Color(Red), #13#10'Warning: ');

    writeln(Color(White), 'The converter has been paused');

    write(#13#10'Press any key to ');

    write(Color(Green), 'continue ');

    write(Color(White), '| Esc to ');

    write(Color(Red), 'stop ');

    write(Color(White), 'the converter');

    repeat
      key:=readkey;

      if (key = #27) then
        begin
        Clear(pre_pos.x + 3, pre_pos.y, ScreenXY.x * 5, pre_pos.x + 3, pre_pos.y);
        exit;
        end

      else begin
        Clear(pre_pos.x, pre_pos.y, ScreenXY.x * 5, pre_pos.x, pre_pos.y);

        if (show_loop = true) then Color(Green);
        break;
        end
    until (key <> '');
    end;
until (dec_mul = '') or (show_loop = false) and (length(dec_res) - 1 = limit);

if (show_loop = true) and (dec_mul <> '') then
  begin
  writeln(Color(White), '...');

  write(Color(Red), #13#10'Note: ');

  write(Color(Green), 'Green part ');

  write(Color(White), 'is the forever loop part');
  end;
end;

//============================ User interface ============================//

Procedure End_screen;
begin
allow_copy:=true;

if (show_tip = true) then
  begin
  write(Color(Yellow), #13#10#13#10'Tip: ');

  write(Color(White), 'You can copy the result by pressing Ctrl + C');
  end;

write(#13#10#13#10'Press backspace to ');

write(Color(Green), 'back ');

write(Color(White), '| Esc to ');

write(Color(Red), 'return ');

write(Color(White), 'to main menu');

if (auto_copy = false) then
  begin
  repeat
    key:=readkey;
    if (key = #3) then CopyToClip(num_res + dec_res);
  until (key = #27) or (key = #8);
  end

else begin
  CopyToClip(num_res + dec_res);
  repeat key:=readkey until (key <> '');
  end;
end;

procedure Welcome_screen;
begin
clear(0, 0, ScreenXY.x * ScreenXY.y, 0, 0);

//This design is inspired of https://github.com/abbodi1406/KMS_VL_ALL_AIO

write(Color(White), '  _______________________________________________________'#13#10#13#10);

write(Color(White), '      Main options:                                      '#13#10#13#10);

write(Color(White), '  [1] Decimal to Binary                                        '#13#10);
write(Color(White), '  [2] Binary To Decimal                                        '#13#10);

write(Color(White), '  _______________________________________________________'#13#10#13#10);

write(Color(White), '      Configuration:                                     '#13#10#13#10);

write(Color(White), '  [3] Show tips                                     ');

if (show_tip = false) then writeln(Color(Red), '[Nah]') else writeln('[Yes]');

write(Color(White), '  [4] Auto copy result to clipboard                 ');

if (auto_copy = true) then writeln(Color(Green), '[Yes]') else writeln('[Nah]');

write(Color(White), '  [5] Ask for truncating (Decimal to Binary)        ');

if (ask_trunc = true) then writeln(Color(Green), '[Yes]') else writeln('[Nah]');

write(Color(White), '  _______________________________________________________'#13#10#13#10);

write(Color(White), '  Press key to choose options or Esc key to Exit: ');

repeat
  if (key = #8) then
    begin
    Clear(0, 0, ScreenXY.x * ScreenXY.y, 0, 0);

    if (u = 0) then key:='1' else key:='2';
    end

  else begin
    key:=readkey;

    if (key in ['1'..'2']) then Clear(0, 0, ScreenXY.x * 30, 0, 0);

    if (key in ['3'..'5']) then Clear(0, 29, ScreenXY.x, WhereXY.x, WhereXY.y);
    end;

  case key of
    '1': begin
         u:=0;

         write(Color(White), 'Enter decimal to convert: ');

         s:=Input(['0'..'9'], true, true);

         if (s <> '') then
           begin
           writeln(#13#10#13#10'Convert to binary: ');

           num_res:=IntToBin(Copy(s, 1, sep - 1));

           write(num_res);

           dec_res:='';

           if (decimal = true) then DecToBin(Copy(s, sep + 1, length(s)));

           End_Screen;
           end;

         break;
         end;

    '2': begin
         write(Color(White), 'Enter binary to convert: ');

         s:=Input(['0', '1'], true, true);

         if (s <> '') then
           begin
           writeln(#13#10#13#10'Convert to decimal: ');

           num_res:=BinToInt;

           write(num_res);

           dec_res:='';

           if (decimal = true) then BinToDec;

           End_Screen;
           end;

         break;
         end;

    '3': begin
         Clear(WhereXY.x + 2, WhereXY.y - 5, 5, WhereXY.x + 2, WhereXY.y - 5);

         show_tip:=not show_tip;

         if (show_tip = false) then write(Color(Red), '[Nah]') else write(Color(Green), '[Yes]');

         GotoXY(WhereXY.x - 7, WhereXY.y + 5);
         end;

    '4': begin
         Clear(WhereXY.x + 2, WhereXY.y - 4, 5, WhereXY.x + 2, WhereXY.y - 4);

         auto_copy:=not auto_copy;

         if (auto_copy = false) then write(Color(Red), '[Nah]') else write(Color(Green), '[Yes]');

         GotoXY(WhereXY.x - 7, WhereXY.y + 4);
         end;

    '5': begin
         Clear(WhereXY.x + 2, WhereXY.y - 3, 5, WhereXY.x + 2, WhereXY.y - 3);

         ask_trunc:=not ask_trunc;

         if (ask_trunc = false) then
           begin
           write(Color(Red), '[Nah]');

           GotoXY(0, 29);

           write(Color(Yellow), 'Tip: ');

           write(Color(White), 'Some decimals may take a long time to display as binary, you can always pause the converter by pressing ESC key.');

           GoToXY(WhereXY.x - 67, WhereXY.y - 14);
           end

         else begin
           write(Color(Green), '[Yes]');

           GotoXY(0, 29);

           write(Color(Yellow), 'Tip: ');

           write(Color(White), 'To get good accuracy for your result, I recommend choosing at least 20 digits.');

           GoToXY(WhereXY.x - 33, WhereXY.y - 14);
           end;
         end;

    #08: key:=#0;

    #27: halt;
    end;
until (false);
end;

//============================ Main part ============================//

begin
if (New_Terminal = false) then
  begin
  show_tip:=true;

  repeat
    allow_copy:=false;
    SetconsoleCtrlHandler(@handlerRoutine, TRUE);

    Welcome_screen;
  until (false);
  end

else begin
  write(Color(Red), 'Attention: ');

  write(Color(White), 'Seem like you''re running this program with the new Microsoft Terminal. Since there are many errors that can be caused in this new Terminal, I recommend you to use the default terminal by running this program as administrator');

  repeat until (readkey <> '');
  end;
end.
