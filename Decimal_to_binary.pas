uses windows,sysutils,keyboard,strutils,regexpr;
var s,num_bin,num_div,num_res,dec_mul,dec_res,compare,result,limit: ansistring;
    decimal,remem,negative,loop,show_loop,pass,ctrl_c: boolean;
    i,sep,cnt: longint;
    pre_pos: coord;
    key: char;

Function WhereXY: coord;
var cursor_pos: TConsoleScreenBufferInfo;
begin
GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), cursor_pos);
WhereXY:=cursor_pos.dwCursorPosition;
end;

Procedure GoToXY(x,y: longint);
var cursor_pos: coord;
begin
cursor_pos.x:=x;
cursor_pos.y:=y;
SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), cursor_pos);
end;

Procedure TextColor(Color: Byte);
begin
SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), Color);
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

if expr.Exec(str_match) then Regex:=true
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

if (Regex(strpas(StrData),'^[-]?((\d+(\.\d*)?)|(\.\d+))$') = false) or (pos('.',strpas(strData)) <> 0) and (decimal = true) or (pos('-',strpas(strData)) <> 0) and (negative = true) then
  begin
  pre_pos:=WhereXY;

  TextColor($4);
  write(slinebreak,slinebreak,'Warning: ');

  TextColor($7);
  write('Your clipboard contains invalid characters');

  repeat until readkey = #13;  // <- replace for readln

  Clear(pre_pos.x, pre_pos.y, ScreenXY.x * 3, pre_pos.x, pre_pos.y);

  PasteFromClip:='';
  end

else PasteFromClip:=Strpas(strdata);
end;

Procedure CopyToClip;
var pchData,StrData: pchar;
    hClipData: HGlobal;
begin
if decimal = true then result:=concat(num_res,'.',result) else result:=num_res;

Openclipboard(0);
  EmptyClipboard;

  strData:=Stralloc(length(result) + 1);
  StrPCopy(strData,result);

  hClipData:=GlobalAlloc(GMEM_MOVEABLE,length(strData) + 1);
  pchData:=GlobalLock(hClipData);
  strcopy(pchData, LPCSTR(StrData));
  GlobalUnlock(hClipData);

  SetClipboardData(CF_TEXT,hclipData);
CloseClipboard;

Clear(0, WhereXY.y - 2, ScreenXY.x, 0, WhereXY.y - 2);

TextColor($2);
write('Status: ');

TextColor($E);
write('Copied');
end;

Function HandlerRoutine(dwCtrlType: DWORD): WINBOOL; stdcall;
begin
if (dwCtrlType = CTRL_C_EVENT) and (ctrl_c = true) then CopyToClip;
end;

Procedure Decimal_part;
begin
cnt:=0;
loop:=false;
dec_res:='0' + Copy(s,sep,length(s));

write('.');

repeat
  inc(cnt);
  remem:=false;
  dec_mul:=dec_res; dec_res:='';

  for i:=length(dec_mul) downto 1 do
    begin
    if (dec_mul[i] <> '.') and (i <> 1) then
      begin
      if StrToInt(dec_mul[i]) * 2 < 10 then
        begin
        if remem = true then
          begin
          dec_res:=concat(IntToStr(StrToInt(dec_mul[i]) * 2 + 1),dec_res);
          remem:=false;
          end

        else begin
          dec_res:=concat(IntToStr(StrToInt(dec_mul[i]) * 2),dec_res);
          end;
        end

      else begin
        if remem = true then
          begin
          dec_res:=concat(IntToStr((StrToInt(dec_mul[i]) * 2 + 1) mod 10),dec_res);
          end

        else begin
          dec_res:=concat(IntToStr((StrToInt(dec_mul[i]) * 2) mod 10),dec_res);
          remem:=true;
          end;
        end;
      end;

    if dec_mul[i] = '.' then
      begin
      dec_res:=concat('0.',dec_res);
      end;

    if i = 1 then
      begin
      if (compare = dec_res) and (cnt <> length(s) - sep + 1) then
        begin
        loop:=true
        end;

      if (cnt = length(s) - sep + 1) and (show_loop = true) then
        begin
        compare:=dec_res;
        Textcolor($2);
        end;

      if (loop = false) then
        begin
        if (remem = true) then
          begin
          dec_res[1]:='1';
          write(1);
          result:=concat(result,'1');
          end

        else begin
          dec_res[1]:='0';
          write(0);
          result:=concat(result,'0');
          end;
        end;

      if (show_loop = false) and (IntToStr(length(result)) = limit) then write('...');

      if GetAsyncKeyState(27) < 0 then
        begin
        repeat until readkey <> ''; // <- prevent auto exit this procedure

        pre_pos:=WhereXY;

        TextColor($7);
        write('...');

        TextColor($4);
        write(slinebreak,slinebreak,'Warning: ');

        TextColor($7);
        write('The converter has been paused');

        write(slinebreak,slinebreak,'Press any key to ');

        TextColor($2);
        write('continue ');

        TextColor($7);
        write('| Esc to ');

        TextColor($4);
        write('stop ');

        TextColor($7);
        write('the converter');

        repeat
          key:=readkey;

          // for some reasons pre_pos.y is broken here, I have no idea about this
          if key = #27 then
            begin
            GotoXY(pre_pos.x + 3,WhereXY.y - 4);
            Clear(WhereXY.x,WhereXY.y,ScreenXY.x * 5,WhereXY.x,WhereXY.y);
            exit;
            end

          else begin
            GotoXY(pre_pos.x,WhereXY.y - 4);
            Clear(WhereXY.x,WhereXY.y,ScreenXY.x * 5,WhereXY.x,WhereXY.y);
            TextColor($2);
            break;
            end
        until key <> '';
        end;
      end;
    end;
until ('1.0' + dupestring('0',length(dec_res) - 3) = dec_res) or (loop = true) or (IntToStr(length(result)) = limit) and (show_loop = false);

if loop = true then
  begin
  TextColor($7);
  writeln('...');

  Textcolor($4);
  write(sLineBreak,'Note: ');

  Textcolor($2);
  write('Green part');

  Textcolor($7);
  write(' is the forever loop part');
  end;
end;

Procedure Integer_part;
begin
num_bin:=Copy(s, 1, sep - 1);
num_res:=''; num_div:='';

repeat
  if num_div <> '' then num_bin:=num_div;

  num_div:='';

  if StrToInt(num_bin[length(num_bin)]) mod 2 <> 0 then
    begin
    num_bin:=concat(num_bin,IntToStr(StrToInt(num_bin[length(num_bin)]) - 1));
    delete(num_bin,length(num_bin) - 1,1);
    num_res:=concat('1',num_res);
    end

  else begin
    num_res:=concat('0',num_res);
    end;

  remem:=false;
  for i:=1 to length(num_bin) do
    begin
    if StrToInt(num_bin[i]) mod 2 <> 0 then
      begin
      if remem = true then
        begin
        num_div:=concat(num_div,IntToStr((10 + StrToInt(num_bin[i])) div 2));
        end

      else begin
        if (num_bin[i] = '1') and (i <> 1) then
          begin
          num_div:=concat(num_div,IntToStr(StrToInt(num_bin[i]) div 2));
          end;

        if num_bin[i] <> '1' then
          begin
          num_div:=concat(num_div,IntToStr(StrToInt(num_bin[i]) div 2));
          end;

        remem:=true;
        end;
      end

    else begin
      if remem = true then
        begin
        num_div:=concat(num_div,IntToStr((10 + StrToInt(num_bin[i])) div 2));
        remem:=false;
        end

      else begin
        num_div:=concat(num_div,IntToStr(StrToInt(num_bin[i]) div 2));
        end;
      end;
    end;
until (num_div = '0');

if negative = true then num_res:=concat('-',num_res);

write(num_res);

if decimal = true then Decimal_part;
end;

Function Input(check_dec, check_neg: boolean): ansistring;
begin
input:='';

repeat
  key:=readkey;

  if (key in ['0'..'9']) and (GetAsyncKeyState(VK_CONTROL) >= 0) and (GetAsyncKeyState(86) >= 0) or (key = '-') and (length(input) = 0) and (check_neg = true) or (key = '.') and (length(input) > 0) and (decimal = false) and (check_dec = true) then
    begin
    if key = '-' then negative:=true;

    if key = '.' then
      begin
      decimal:=true;
      sep:=length(input) + 1;
      end;

    input:=concat(input,key);

    write(key);
    end;

  if (key = #22) or (GetAsyncKeyState(VK_CONTROL) < 0) and (GetAsyncKeyState(86) < 0) then
    begin
    i:=length(input);
    input:=concat(input,PasteFromClip);

    write(Copy(input, i + 1,length(input)));

    if pos('.',input) <> 0 then decimal:=true;

    if pos('-',input) <> 0 then negative:=true;
    end;

  if (key = #8) and (length(input) <> 0) then
    begin
    if input[length(input)] = '.' then decimal:=false;

    if input[length(input)] = '-' then negative:=false;

    if WhereXY.x = 0 then
      begin
      GotoXY(ScreenXY.x - 1,WhereXY.y - 1);
      write(' ');
      GotoXY(ScreenXY.x - 1,WhereXY.y);
      end

    else begin
      GotoXY(WhereXY.x - 1,WhereXY.y);
      write(' ');
      GotoXY(WhereXY.x - 1,WhereXY.y);
      end;

    delete(input,length(input),1);
    end;

  if (key = #13) and (length(input) <> 0) then
    begin
    if (negative = true) and (check_neg = true) then delete(input,1,1);

    if input[length(input)] = '.' then
      begin
      decimal:=false;
      delete(input,length(input),1);
      end;

    if input[1] = '.' then
      begin
      input:=concat('0',input);
      end;

    if (length(input) > 1) and (decimal = true) and (input[length(input)] = '0') and (check_dec = true) then
      begin
      i:=length(input) + 1;
      repeat
        dec(i);
        if input[i] = '.' then decimal:=false;
        delete(input,i,1);
      until input[i - 1] in ['1'..'9'];
      end;

    if (length(input) > 1) and (input[1] = '0') and (input[2] <> '.') then
      begin
      i:=1;
      repeat
        delete(input,i,1);
      until (input[i] = '0') and (input[i + 1] = '.') or (input[i] in ['1'..'9']);
      end;

    if decimal = false then sep:=length(input) + 1

    else begin
      for i:=1 to length(input) do
        begin
        if input[i] = '.' then sep:=i;
        end;
      end;
    end;
until (key = #13) and (length(input) <> 0);

if (decimal = true) and (check_dec = true) then
  begin
  write(slinebreak,sLineBreak, 'Do you want to show looping part of the decimal part ?');

  writeln(' Y = Yes | N = No');

  TextColor($4);
  write(slinebreak,'Warning: ');

  TextColor($7);
  writeln('Choose "Yes" will provide more precision result but sometimes it cans take some times to calculate.');
  write('         Choose "No" will provide to you an option to choose how many digits do you want to display.');

  repeat
    case lowercase(readkey) of
      'y' : begin
            clear(0, WhereXY.y - 3, ScreenXY.x * 4, 0, WhereXY.y - 5);

            show_loop:=true; pass:=true;
            end;

      'n' : begin
            clear(0, WhereXY.y - 3, ScreenXY.x * 4, 0, WhereXY.y - 4);

            pre_pos:=WhereXY;

            write(slinebreak,'Enter how many digits do you want to display: ');

            limit:=Input(false,false);

            clear(0, pre_pos.y, ScreenXY.x * (ScreenXY.y - pre_pos.y), 0, pre_pos.y - 1);

            show_loop:=false; pass:=true;
            end;
    end;
  until pass = true;
  end;
end;

begin
repeat
  ctrl_c:=false;
  SetconsoleCtrlHandler(@handlerRoutine, TRUE);

  clear(0, 0, ScreenXY.x * ScreenXY.y, 0, 0);
  write('Enter decimal to convert: ');

  s:=Input(true,true);

  writeln(sLineBreak,slineBreak,'Convert to decimal: ');

  Integer_part;

  ctrl_c:=true;

  TextColor($E);
  write(slinebreak,slinebreak,'Tip: ');

  TextColor($7);
  write('You can copy the result by pressing Ctrl + C');

  write(sLineBreak,sLineBreak,'Press any key to ');

  TextColor($2);
  write('back');

  Textcolor($7);
  write(' | Esc to ');

  Textcolor($4);
  write('exit');

  repeat
    key:=readkey;
    if key = #3 then CopyToClip else break;
  until key = #27;

  Textcolor($7);

  result:='';
  decimal:=false; negative:=false;
until key = #27;
end.
