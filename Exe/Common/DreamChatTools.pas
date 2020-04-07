unit DreamChatTools;

interface

uses
     Classes, Windows, Math;

FUNCTION RegisterHotKeyFromString(FormMainHandle: THandle; HotString: string):string;
function GetUserLoginName():string; forward;
FUNCTION GetParamX(SourceString: string; ParamNumber: Integer; Separator: string; HideSingleSeparaterError:boolean): string; forward;
FUNCTION GetParam(SourceString: string; ParamNumber: Integer; Separator: string): string; forward;
procedure StringToComponent(Component: TComponent; Value: string); forward;
FUNCTION ComponentToString(Component: TComponent): string; forward;
FUNCTION StrToIntE(value: string):integer; forward;
//"The forward directive has no effect in the interface section of a unit."
//Они там действительно нужны?
function CheckIP(sinp: string): string;
function WinToDos(St: string): string;
function DosToWin(St: string): string;

implementation

uses SysUtils;

{================= регистрируем комбинацию горячих клавиш  =====================}
FUNCTION RegisterHotKeyFromString(FormMainHandle: THandle; HotString: string):string;
var s: string;
    KeyChar: char;
    i: integer;
    TempSysKey, SysKey, VK: cardinal;
BEGIN
result := 'Error RegisterHotKey(' + HotString + '): ';
HotString := StringReplace(HotString, ' ', '', [rfReplaceAll, rfIgnoreCase]);
HotString := StringReplace(HotString, '''', '', [rfReplaceAll, rfIgnoreCase]);
HotString := StringReplace(HotString, '"', '', [rfReplaceAll, rfIgnoreCase]);
i := 0;
s := GetParam(HotString, i, '+');
while length(s) > 0 do
  begin
  if length(s) = 1 then
    begin
    //один символ - скорее всего это клавиша
    //вопрос какая символ или цифра
    KeyChar := UpCase(s[1])
    end
  else
    begin
    //в слагаемом нет знака '
    //это или CTRL ALT SHIFT WIN или цифра?
    if upperCase(s) = 'CTRL' then TempSysKey := MOD_CONTROL;
    if upperCase(s) = 'ALT' then TempSysKey := MOD_ALT;
    if upperCase(s) = 'SHIFT' then TempSysKey := MOD_SHIFT;
    if upperCase(s) = 'WIN' then TempSysKey := MOD_WIN;
    if TempSysKey <> 0 then
      begin
      SysKey := SysKey + TempSysKey;
      TempSysKey := 0;
      end
    else
      begin
      //в одном из слагаемых у нас неведомая фигня из нескольких символов
      //будем считать его кодом клавиши
        try
          VK := StrToInt(s);
        except
          on E : Exception do
            begin
            VK := 90;
            result := result + 'Cann''''t find VK code in string ' + s;
            end;
        end;
      end;
    end;
  i := i + 1;
  s := GetParam(HotString, i, '+');
  end;

  if byte(KeyChar) <> 0 then
    begin
    RegisterHotKey(FormMainHandle, 0, SysKey, byte(KeyChar));
    result := 'RegisterHotKey(' + HotString + ')';
    end
  else
    begin
    RegisterHotKey(FormMainHandle, 0, SysKey, VK);
    //                                        ^^^--- идентификатор может от $0000 до $BFFF
    result := 'RegisterHotKey(' + HotString + ')';
    end;
END;

FUNCTION StrToIntE(value: string):integer;
BEGIN
//Result := 0;
//try
  Result := StrToIntDef(value, 0);
{except
    //on E:EConvertError do
  on E:Exception do
    begin
     .ProcessException(Self, E);
    end;
end;}
END;

{================= GetLocalUserLoginName Получаем логин локального юзера  =====================}

function GetUserLoginName():string;
var TempBuffer:array[0..255] of Char;
    BufferSize:cardinal;
    lpUserName:PChar;
begin
  BufferSize := SizeOf(TempBuffer);
  lpUserName := @TempBuffer;

  if WNetGetUser(nil, lpUserName, BufferSize) = NO_ERROR then begin
    Result := lpUserName;
  end
  else
  begin
    Result := 'ErrorGetLocalUserLoginName'; //TODO: ВЕРНУТЬСЯ И ДОДЕЛАТЬ!!!
  end;
end;

{================= GetParamX Парсинг сообщения на поля данных =====================}

FUNCTION GetParamX(SourceString: String; ParamNumber: Integer; Separator: String; HideSingleSeparaterError:boolean): String;
VAR
I, Posit: integer;
S: string;
BEGIN
S := SourceString;
for I := 1 to ParamNumber do begin
  Posit := Pos(Separator, S) + Length(Separator) - 1;
  Delete(S, 1, Posit);
end;
Posit := Pos(Separator, S);
Delete(S, Posit , Length(S) - Posit + 1);
if HideSingleSeparaterError = true then
  begin
  i := Pos(Separator[1], s);
  while i > 0 do
    begin
    delete(s, i, 1);
    i := Pos(Separator[1], s);
    end;
  end;
Result := s;
END;

FUNCTION GetParam(SourceString: String; ParamNumber: Integer; Separator: String): String;
var s: string;
    i, Count: integer;
BEGIN
Count := 0;
s := SourceString;
i := pos(Separator, s);
while i > 0 do
  begin
  if Count = ParamNumber then
    begin
    result := copy(s, 1, i - 1);
    exit;
    end;
  delete(s, 1, i);
  inc(Count);
  i := pos(Separator, s);
  end;
if Count < ParamNumber then
  result := ''
else
  result := s;
END;

{============= StringToComponent General ф-ция загрузки пропертей компонента из файла =================}

procedure StringToComponent(Component: TComponent; Value: string);
var
  StrStream:TStringStream;
  ms: TMemoryStream;
begin
  StrStream := TStringStream.Create(Value);
  try
    ms := TMemoryStream.Create;
    try
      ObjectTextToBinary(StrStream, ms);
      ms.position := 0;
      ms.ReadComponent(Component);
    finally
      ms.Free;
    end;
  finally
    StrStream.Free;
  end;
end;

{============= ComponentToString General ф-ция сохранения пропертей компонента в файл =================}

FUNCTION ComponentToString(Component: TComponent): string;
var
  ms: TMemoryStream;
  ss: TStringStream;
  strlist: TStringList;
  posit: Longint;
begin
  strlist := TStringList.Create;
  ss := TStringStream.Create(' ');
  ms := TMemoryStream.Create;
  try
    ms.WriteComponent(Component);
    ms.position := 0;
    ObjectBinaryToText(ms, ss);
    ss.position := 0;
    //без этого в FForm.txt выгружаются все компоненты формы
    posit := pos('  object', ss.DataString);
    if posit > 0 then
      begin
      Result := ss.ReadString(posit - 2);
      Result := Result + 'end';//+ #13#10
      end
    else
      Result := ss.DataString;
    //а без этого все время прибавляется Form1_1_1_1_1
    //хз почему... потом разобраться!
    strlist.Text := Result;
    strlist.delete(0);
    strlist.Insert(0, 'object FormMain: TFormMain');
    Result := strlist.Text;
  finally
    strlist.Free;
    ms.Free;
    ss.free;
  end;
end;

function CheckIP(sinp: string): string;
var
  s: string;
begin
  if pos('.', sinp) = 0 then
    sinp := sinp + '.';
  s := copy(sinp, 1, pos('.', sinp) - 1);
  Delete(sinp, 1, pos('.', sinp));
  s      := IntToStr(EnsureRange(strtointdef(s, 127), 0, 255));
  Result := s + '.';

  if pos('.', sinp) = 0 then
    sinp := sinp + '.';
  s := copy(sinp, 1, pos('.', sinp) - 1);
  Delete(sinp, 1, pos('.', sinp));
  s      := IntToStr(EnsureRange(strtointdef(s, 0), 0, 255));
  Result := Result + s + '.';

  if pos('.', sinp) = 0 then
    sinp := sinp + '.';
  s := copy(sinp, 1, pos('.', sinp) - 1);
  Delete(sinp, 1, pos('.', sinp));
  s      := IntToStr(EnsureRange(strtointdef(s, 0), 0, 255));
  Result := Result + s + '.';

  s      := sinp;
  s      := IntToStr(EnsureRange(strtointdef(s, 1), 0, 255));
  Result := Result + s;
end;

function WinToDos(St: string): string;
var
  Ch: PChar;
begin
  Ch := StrAlloc(Length(St) + 1);
  AnsiToOem(PChar(St), Ch);
  Result := Ch;
  StrDispose(Ch);
end;

function DosToWin(St: string): string;
var
  Ch: PChar;
begin
  Ch := StrAlloc(Length(St) + 1);
  OemToAnsi(PChar(St), Ch);
  Result := Ch;
  StrDispose(Ch)
end;

end.
