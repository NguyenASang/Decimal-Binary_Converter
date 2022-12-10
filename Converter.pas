{$ASMMODE INTEL}

uses keyboard, process, regexpr, strutils, sysutils, windows;

const Green       = $2;
      LightYellow = $E;
      Red         = $4;
      White       = $7;

var ctrl_c, auto_copy, ask_trunc, show_tip, decimal, negative, remem: boolean;
    s, num_res, dec_res: ansistring;
    i, u, sep: longint;
    pre_pos: coord;
    key: char;

//Thanks John O'Harrow from The Fastcode Challenges for this genius function

Function CharPos(Ch : Char; const Str : AnsiString) : Longint; nostackframe assembler;
asm
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

// Both functions below are inspired by @svecon's code

Function ChrToInt(c: char): byte; assembler;
asm
sub al, '0'
end;

Function IntToChr(b: byte): char; assembler;
asm
add al, '0'
end;

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

if (Regex(strpas(StrData), '^[-]?((\d+(\.\d*)?)|(\.\d+))$') = false) or (CharPos('.', strpas(strData)) > 0) and (decimal = true) or (CharPos('-', strpas(strData)) > 0) and ((negative = true) or (length(s) > 0)) then
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

if (show_tip = true) then Clear(0, WhereXY.y - 2, ScreenXY.x, 0, WhereXY.y - 2)

else begin
  Clear(0, WhereXY.y, ScreenXY.x, 0, WhereXY.y);

  GotoXY(0, WhereXY.y + 2);

  write(TextColor(White), 'Press backspace to ');

  write(TextColor(Green), 'back ');

  write(TextColor(White), '| Esc to ');

  write(TextColor(Red), 'exit');

  GotoXY(0, WhereXY.y - 2);
  end;

write(TextColor(Green), 'Status: ');

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

//============================ Input check ============================//

Function Input(check_dec, check_neg: boolean; char_check: array of ansistring): ansistring;
begin
input:='';

if (check_dec = true) and (check_neg = true) then
  begin
  decimal:=false; negative:=false;
  end;

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

    if (decimal = false) and (CharPos('.', input) > 0) then decimal:=true;

    if (negative = false) and (CharPos('-', input) > 0) then negative:=true;
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
        if (decimal = true) then sep:=CharPos('.', input)

        else sep:=length(input) + 1;
        end;
      end;
    end;
until (length(input) > 0) and (key = #13);
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

    else if (ChrToInt(dividend[u]) mod 2 = 1) then
      begin
      if (remem = true) then
        begin
        div_res:=div_res + IntToChr((10 + ChrToInt(dividend[u])) div 2);

        if ((10 + ChrToInt(dividend[u])) mod 2 = 1) then remem:=true else remem:=false;
        end

      else begin
        remem:=true;
        div_res:=div_res + IntToChr(ChrToInt(dividend[u]) div 2);

        if (u = length(dividend)) then dividend:=dividend + '0';
        end;
      end

    else begin
      if (remem = true) then
        begin
        remem:=false;
        div_res:=div_res + IntToChr((10 + ChrToInt(dividend[u])) div 2);
        end

      else begin
        div_res:=div_res + IntToChr((ChrToInt(dividend[u]) div 2));
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
        if (ChrToInt(div_res[u]) + ChrToInt(dec_sum[u]) < 10) then
          begin
          if (remem = true) then
            begin
            if (ChrToInt(div_res[u]) + ChrToInt(dec_sum[u]) + 1 = 10) then
              begin
              dec_res:='0' + dec_res;
              end

            else begin
              remem:=false;
              dec_res:=IntToChr(ChrToInt(div_res[u]) + ChrToInt(dec_sum[u]) + 1) + dec_res;
              end;
            end

          else begin
            dec_res:=IntToChr(ChrToInt(div_res[u]) + ChrToInt(dec_sum[u])) + dec_res;
            end;
          end

        else begin
          if (remem = true) then
            begin
            dec_res:=IntToChr((ChrToInt(div_res[u]) + ChrToInt(dec_sum[u]) + 1) mod 10) + dec_res
            end

          else begin
            dec_res:=IntToChr((ChrToInt(div_res[u]) + ChrToInt(dec_sum[u])) mod 10) + dec_res;
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

//============================ Binary to Integer ============================//

Procedure Binary_to_Integer;
var num_mul: ansistring;
begin
num_mul:='0'; num_res:='';

for i:=1 to sep - 1 do
  begin
  remem:=false;

  for u:=length(num_mul) downto 1 do
    begin
    if (ChrToInt(num_mul[u]) * 2 < 10) then
      begin

      if (remem = true) then
        begin
        num_res:=IntToChr(ChrToInt(num_mul[u]) * 2 + 1) + num_res;
        if (ChrToInt(num_mul[u]) * 2 + 1 > 10) then remem:=true else remem:=false;
        end

      else num_res:=IntToChr(ChrToInt(num_mul[u]) * 2) + num_res;
      end

    else begin
      if (remem = true) then
        begin
        num_res:=IntToChr((ChrToInt(num_mul[u]) * 2 + 1) mod 10) + num_res;
        end

      else begin
        remem:=true;
        num_res:=IntToChr(ChrToInt(num_mul[u]) * 2 mod 10) + num_res;
        end;
      end;

    if (u = 1) and (remem = true) then num_res:='1' + num_res;
    end;

  if (s[i] = '1') then
    begin
    num_res[length(num_res)]:=IntToChr(ChrToInt(num_res[length(num_res)]) + 1);
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
var dec_mul, compare, limit: ansistring;
    show_loop: boolean = true;
begin
if (ask_trunc = true) then
  begin
  clear(0, WhereXY.y - 1, ScreenXY.x * 6, 0, WhereXY.y - 1);

  pre_pos:=WhereXY;

  writeln('How many digits do you want to display ?');

  limit:=Input(false, false, ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']);

  clear(0, pre_pos.y, ScreenXY.x * (ScreenXY.y - pre_pos.y), 0, pre_pos.y);

  write('Convert to binary:'#13#10, num_res);

  show_loop:=false;
  end;

write('.');

dec_mul:='0' + Copy(s, sep, length(s)); dec_res:='.';

repeat
  remem:=false;

  for i:=length(dec_mul) downto 3 do
    begin
    if (ChrToInt(dec_mul[i]) * 2 > 9) then
      begin
      if (remem = true) then
        begin
        dec_mul[i]:=IntToChr((ChrToInt(dec_mul[i]) * 2 + 1) mod 10);
        end

      else begin
        remem:=true;
        dec_mul[i]:=IntToChr((ChrToInt(dec_mul[i]) * 2) mod 10);
        end;
      end

    else begin
      if (remem = true) then
        begin
        remem:=false;
        dec_mul[i]:=IntToChr(ChrToInt(dec_mul[i]) * 2 + 1);
        end

      else begin
        dec_mul[i]:=IntToChr(ChrToInt(dec_mul[i]) * 2);
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

if (show_loop = true) and (dec_mul <> '0') then
  begin
  writeln(TextColor(White), '...');

  write(TextColor(Red), #13#10'Note: ');

  write(TextColor(Green), 'Green part ');

  write(TextColor(White), 'is the forever loop part');
  end;
end;

//============================ Integer to Binary ============================//

Procedure Integer_to_Binary;
var num_div: ansistring;
begin
num_div:=Copy(s, 1, sep - 1); num_res:='';

repeat
  delete(num_div, CharPos(' ', num_div), 1);

  if (ChrToInt(num_div[length(num_div)]) mod 2 = 1) then
    begin
    num_div[length(num_div)]:=IntToChr(ChrToInt(num_div[length(num_div)]) - 1);
    num_res:='1' + num_res;
    end

  else begin
    num_res:='0' + num_res;
    end;

  remem:=false;

  for i:=1 to length(num_div) do
    begin
    if (ChrToInt(num_div[i]) mod 2 = 1) then
      begin
      if (remem = true) then
        begin
        num_div[i]:=IntToChr((10 + ChrToInt(num_div[i])) div 2);
        end

      else begin
        remem:=true;
        if (i = 1) and (num_div[i] = '1') then num_div[i]:=' '

        else num_div[i]:=IntToChr(ChrToInt(num_div[i]) div 2);
        end;
      end

    else begin
      if (remem = true) then
        begin
        remem:=false;
        num_div[i]:=IntToChr((10 + ChrToInt(num_div[i])) div 2);
        end

      else begin
        num_div[i]:=IntToChr(ChrToInt(num_div[i]) div 2);
        end;
      end;
    end;
until (num_div = '0');

if (negative = true) then num_res:='-' + num_res;

write(num_res);

if (decimal = true) then Decimal_to_Binary;
end;

//============================ User interface ============================//

Procedure End_screen;
begin
ctrl_c:=true;

if (show_tip = true) then
  begin
  write(TextColor(LightYellow), #13#10#13#10'Tip: ');

  write(TextColor(White), 'You can copy the result by pressing Ctrl + C');
  end;

write(#13#10#13#10'Press backspace to ');

write(TextColor(Green), 'back ');

write(TextColor(White), '| Esc to ');

write(TextColor(Red), 'return ');

write(TextColor(White), 'to main menu');

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

//This design is inspired by https://github.com/abbodi1406/KMS_VL_ALL_AIO
writeln(TextColor(White), '  ', dupestring('_', 59));

writeln(#13#10'      Main options:'#13#10);

writeln('  [1] Decimal to Binary');
writeln('  [2] Binary To Decimal');

writeln('  ', dupestring('_', 59));

writeln(#13#10'      Configuration:'#13#10);

write('  [3] Show tips                                         ');
if (show_tip = false) then writeln(TextColor(Red), '[No]') else writeln('[Yes]');

write(TextColor(White), '  [4] Auto copy result to clipboard                     ');
if (auto_copy = true) then writeln(TextColor(Green), '[Yes]') else writeln('[No]');

write(TextColor(White), '  [5] Ask for truncating (Decimal to Binary)            ');
if (ask_trunc = true) then writeln(TextColor(Green), '[Yes]') else writeln('[No]');

writeln(TextColor(White), '  ', dupestring('_', 59), #13#10);

writeln('      Other options:'#13#10);

writeln('  [I] What is the forever loop part (Decimal to Binary) ?');

writeln('  ', dupestring('_', 59), #13#10);

write('  Press key to choose options or Esc key to Exit: ');

repeat
  if (key = #8) and (s <> '') then
    begin
    if (u = 0) then key:='1' else key:='2';
    end

  else key:=readkey;

  case lowercase(key) of
    '1': begin
         u:=0;

         Clear(0, 0, ScreenXY.x * (ScreenXY.y - WhereXY.y), 0, 0);

         write(TextColor(White), 'Enter decimal to convert: ');

         s:=Input(true, true, ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']);

         writeln(#13#10#13#10'Convert to binary: ');

         Integer_to_Binary;

         End_screen;
         end;

    '2': begin
         Clear(0, 0, ScreenXY.x * (ScreenXY.y - WhereXY.y), 0, 0);

         write(TextColor(White), 'Enter binary to convert: ');

         s:=Input(true, true, ['0', '1']);

         writeln(#13#10#13#10'Convert to decimal: ');

         Binary_to_Integer;

         End_screen;
         end;

    '3': begin
         Clear(2, WhereXY.y + 8, ScreenXY.x, WhereXY.x, WhereXY.y);

         if (show_tip = false) then
           begin
           show_tip:=true;

           GotoXY(WhereXY.x + 6, WhereXY.y - 10);
           write(TextColor(Green), '[Yes]');
           GotoXY(WhereXY.x - 11, WhereXY.y + 10);
           end

         else begin
           show_tip:=false;

           GotoXY(WhereXY.x + 6, WhereXY.y - 10);
           write(TextColor(Red), '[No] ');
           GotoXY(WhereXY.x - 11, WhereXY.y + 10);
           end;
         end;

    '4': begin
         Clear(2, WhereXY.y + 8, ScreenXY.x, WhereXY.x, WhereXY.y);

         if (auto_copy = false) then
           begin
           auto_copy:=true;

           GotoXY(WhereXY.x + 6, WhereXY.y - 9);
           write(TextColor(Green), '[Yes]');
           GotoXY(WhereXY.x - 11, WhereXY.y + 9);
           end

         else begin
           auto_copy:=false;

           GotoXY(WhereXY.x + 6, WhereXY.y - 9);
           write(TextColor(Red), '[No] ');
           GotoXY(WhereXY.x - 11, WhereXY.y + 9);
           end;
         end;

    '5': begin
         if (ask_trunc = false) then
           begin
           ask_trunc:=true;

           GotoXY(WhereXY.x + 6, WhereXY.y - 8);
           write(TextColor(Green), '[Yes]');

           if (show_tip = true) then
             begin
             GotoXY(2, WhereXY.y + 16);

             Clear(WhereXY.x, WhereXY.y, ScreenXY.x, WhereXY.x, WhereXY.y);

             write(TextColor(LightYellow), 'Tip: ');

             write(TextColor(White), 'To get good accuracy for your result, I recommend choosing at least 20 digits');

             GotoXY(WhereXY.x - 34, WhereXY.y - 8)
             end

           else GotoXY(WhereXY.x - 11, WhereXY.y + 8);
           end

         else begin
           ask_trunc:=false;

           GotoXY(WhereXY.x + 6, WhereXY.y - 8);
           write(TextColor(Red), '[No] ');

           if (show_tip = true) then
             begin
             GotoXY(2, WhereXY.y + 16);

             write(TextColor(LightYellow), 'Tip: ');

             write(TextColor(White), 'Some decimals may take a long time to display as binary, you can always pause the converter by pressing ESC key');

             GotoXY(WhereXY.x - 68, WhereXY.y - 8);
             end

           else GotoXY(WhereXY.x - 11, WhereXY.y + 8);
           end;
         end;

    'i': ShellExecute(HInstance, 'open', PChar('https://github.com/NguyenASang/Decimal-Binary_Converter/wiki#what-is-the-part-that-loops-forever-when-converting-decimal-to-binary-'), nil, nil, SW_NORMAL);

    #27: halt;
  end;
until (key = #27);
end;

//============================ Main part ============================//

begin
if (New_Terminal = false) then
  begin
  show_tip:=true;

  repeat
    ctrl_c:=false;
    SetconsoleCtrlHandler(@handlerRoutine, TRUE);

    Welcome_screen;
  until (false);
  end

else begin
  write(TextColor(Red), 'Attention: ');

  write(TextColor(White), 'Seem like you''re running this program with the new Microsoft Terminal. Since there are many errors that can be caused in this new Terminal, I recommend you to use the default terminal by running this program as administrator');

  repeat until (readkey <> '');
  end;
end.
