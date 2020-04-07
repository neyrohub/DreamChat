//Текст этой DLL распространяется в том виде КАК ЕСТЬ (AS IS)
//Никакой ответственности за последствия его работы автор не несет.
//У меня он компилиться в среде DELPHI 5 + FREE WARE component DCP +
//модуль заголовков функций JwaWinType с http://www.delphi-jedi.org/
//Хм... project jedi вообще полезный ресурс для делфятников :-)
//т.к. содержик заголовки для всех API функций WINDOWS.
//За это им большое спасибо!

//Небольшой комментарий:
//1.Многое из того что написано здесь может показаться бредом,
//  не оптимальным решением и т.д. Если так, то сделайте лучше, потому что
//  на многие вещи у меня не хватает времени. Кроме того, здесь могут 
//  встретиться куски уже не используемого кода (из прошлых версий) или что-то
//  оставлено как напоминание на будущее...
//2.При написании своей DLL НЕ МЕНЯТЬ названия ЭКСПОРТИРУЕМЫХ ФУНКЦИЙ,
//  количество, тип и очередность передаваемых в них параметров, а также тип
//  результата!
//3.С внутренностями можно поступать по своему усмотрению.


//дописать функции создания выделенной линии
library mskrnl;

{/$DEFINE USEFASTSHAREMEM}

uses
{$IFDEF USEFASTSHAREMEM}
  FastShareMem,
{$ENDIF USEFASTSHAREMEM}
  Windows,
  JwaWinType,
  DCPcrypt2,
  DCPrc4,
  sysutils,
  Classes,
  Inifiles,
  messages,
  WinSock, JwaIpHlpApi, JwaIpRtrMib, syncobjs;

type
  TMailSlotThread = class(TThread)
  private
  protected
    procedure Execute; override;
  end;

type TCallBackFunction = function(Buffer:Pchar; MessCountInBuffer:cardinal):PChar;

function Init(ModuleHandle: HMODULE; AdressCallBackFunction:pointer; ExePath:PChar):PChar;forward;
function ShutDown():PChar;forward;
function GetLocalUserLoginName(OverrideLN: PChar):PChar;forward;
function GetLocalComputerName():string;forward;
function SendCommBoardX(pProtoName, pNetbiosNameOfRemoteComputer:PChar;pMessageBoard:Pchar;PartMessNumber:cardinal):Pchar;forward;
function SendCommConnect(pProtoName, pLocalNickName, pNetbiosNameOfRemoteComputer,
                         pLineName,pNameOfRemoteComputer,
                         pMessageStatusX:PChar; Status:Byte):Pchar;forward;
function SendCommReceived(pProtoName, pNetbiosNameOfRemoteComputer:PChar;MessAboutReceived:PChar):Pchar;forward;

const
  KernelVersion = 'M36';//M = MailSlot
  WaitForSomething = 250;//Если нечего делать отдаем проц другим задачам
                         //на 250мс (т.е. код отрабатывает не более 4 раз в сек)
  FullWorkSpeed = 10;//Полная рабочая скорость, в этот момент передаем сообщения
                     //из буфера, но все-таки отдаем проц другим на 10мс

var
  key, InfoForExe, LocalComputerName, LocalLoginName                 :string;
  OverrideLoginName                                                  :String;
  MailSlotReadName                                                   :string;
  ApplicationPath                                                    :String;
//  Show_SystemMessages_Connect                                        :boolean;
//  Show_SystemMessages_Connected                                      :boolean;
  ChatVersion, FullVersion                                           :string;
  crypted_in, crypted_out, buffer_in, buffer_out                     :array[0..1499] of Char;
  hMailSlotWrite, hMailSlotRead                                      :handle;
  SendMessCount, readCount, nMaxMessSize, UsersCount                 :cardinal;
  DCP_rc41                                                           :TDCP_rc4;
  RunCallBackFunction                                                :TCallBackFunction;
  OpenMailSlotList, QueueOfMessages, QueueOfRemoteComputersNames     :TStringList;
  IncommingQueueOfMessages                                           :TStringList;
  MSThread                                                           :TMailSlotThread;
  ThreadBlocked                                                      :boolean;
  CriticalSection                                                    :TCriticalSection;

{============= впомогательная функция парсинга строки ======================}
FUNCTION  GetParamX(SourceString: String; ParamNumber: Integer; Separator: String; HideSingleSeparaterError:boolean): String;
VAR
I, Posit: integer;
S: string;
BEGIN
//выковыривает то, что между разделителями (Separator)
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

function GetIP : PChar;
var
err, n: integer;
len{, NumberOfInterfaces}: cardinal;
MibIpAddrTable: MIB_IPADDRTABLE;
MyAdrr: in_addr;
res, IP, Lan, Internet: string;
ChatConf: TMemIniFile;
begin
//для совместимости с серверной версией
Lan := '';
Internet := '';

//RunCallBackFunction(PChar('Перечисляем сетевые интерфейсы:'), 0);
//IP_For_Exe := '127.0.0.1';
res := '127.0.0.1';
result := PChar(res);
len := SizeOF(MibIpAddrTable);
FillChar(MibIpAddrTable, len, 0);
err := GetIpAddrTable(@MibIpAddrTable, len, false);
if err <> 0 then
  begin
  //при вызове ф-ции произошла ошибка
//  RunCallBackFunction(PChar('ошибка! берем 127.0.0.1'), 0);
  exit;
  end;
//кол-во интерфейсов = MibIpAddrTable.dwNumEntries;

for n := 0 to MibIpAddrTable.dwNumEntries - 1 do
  begin
  MyAdrr.S_addr := MibIpAddrTable.table[n].dwAddr;
  Ip := inet_ntoa(MyAdrr);
//  RunCallBackFunction(PChar('[' + inttostr(n) + '] ' + ip), 0);
  ip := copy(ip, 1, pos('.', Ip) - 1);
//  if ip = '127' then нашли Loopback интерфейс;
  if (ip <> '127') then
    begin
    if (ip = '10') or (ip = '172') or (ip = '192') then
      Lan := inet_ntoa(MyAdrr)
    else
      Internet := inet_ntoa(MyAdrr);
    end;
  end;
if LAN <> '' then res := PChar(LAN);
if Internet <> '' then res := PChar(Internet);
ChatConf := TMemIniFile.Create(ApplicationPath + 'config.ini');
if ChatConf.ReadString('ConnectionType', 'LocalIP', '127.0.0.1') <> '127.0.0.1' then
  res := ChatConf.ReadString('ConnectionType', 'LocalIP', '127.0.0.1');
ChatConf.Free;
result := PChar(res);
//RunCallBackFunction(PChar('В чате будет отображен следующий IP: ' + res), 0);
end;

FUNCTION SetVersion(Version:PChar):PChar;
BEGIN
//собственно добавляет к строке версии ядра чата версию сетевой библиотеки
FullVersion := '';
ChatVersion := Version;
FullVersion := ChatVersion + KernelVersion;
result := PChar(FullVersion);
END;

FUNCTION GetOpenMailSlot(pNameOfRemoteComputer:PChar):THandle;
VAR i:integer;
    MailSlotWriteName, sNameOfRemoteComputer:string;
BEGIN
//раньше при каждой передачи сообщения удаленному компу на время передачи
//открывался маилслот после передачи он закрывался. Из-за этого возникали
//тормоза. Решение: Откроем все маилслоты и будем держать их открытыми.
//В этой функции ищется открытый маилслот.

//доделать закрытие маилслота, когда от юзера приходит DISCONNECT в общую линию
//а то сейчас список открытых маилслотов только увеличивается!!!!
result := INVALID_HANDLE_VALUE;
sNameOfRemoteComputer := pNameOfRemoteComputer;
if OpenMailSlotList.Find(sNameOfRemoteComputer, i) = true then
  begin
  //с этим компом маилслот уже открыт
  result := THandle(OpenMailSlotList.Objects[i]);
  //RunCallBackFunction(PChar('Уже открыт:' + OpenMailSlotList.Strings[i] + '  ' +
  //                    inttostr(THandle(OpenMailSlotList.Objects[i]))), 0);
  end
else
  begin
  //открытый не нашли, открываем новый
//  MessageBox(0, PChar(sNameOfRemoteComputer), PChar('открытый не нашли, открываем новый') ,mb_ok);
  MailSlotWriteName := '\\' + sNameOfRemoteComputer + '\Mailslot\ICHAT047';
  hMailSlotWrite := CreateFile(PChar(MailSlotWriteName), GENERIC_WRITE, FILE_SHARE_READ,
                                nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  OpenMailSlotList.AddObject(sNameOfRemoteComputer, pointer(hMailSlotWrite));
  //Резонно задать вопрос: А причем здесь pointer(hMailSlotWrite)?
  //ну мне просто нужно хранить пары
  //[строка(имя компа) + 32разрядное число(Handle открытого маилслота с этим компом)]
  //число храниться там, где должен быть указатель (разрядность же совпадает)
  //просто я его интерпретирую потом не как указатель а как хэндел (такой ход конем)
  result := hMailSlotWrite;
  //RunCallBackFunction(PChar('Открываем новый:' + sNameOfRemoteComputer + '  ' +
  //                    inttostr(hMailSlotWrite)), 0);
  end;
//RunCallBackFunction(PChar('OpenMailSlotList:' + OpenMailSlotList.Text), 0);
END;

{==================== Получаем логин локального юзера  ========================}
FUNCTION GetLocalUserLoginName(OverrideLN: PChar):PChar;
var TempBuffer:array[0..255] of Char;
    BufferSize:cardinal;
    lpUserName:PChar;
begin
//что тут? При запуске чата из DreamChat.dpr сюда можно передавать подложный логин
if (Length(OverrideLN) > 0) and (Length(OverrideLoginName) = 0) then
  begin
  //запоминаем подложный логин и при следующем вызове этой ф-ции выдаем его.
  OverrideLoginName := OverrideLN;
  result := PChar(OverrideLoginName);
  exit;
  end;
if Length(OverrideLoginName) > 0 then
  begin
  //выдаем подложный логин и при вызове этой ф-ции.
  result := PChar(OverrideLoginName);
  exit;
  end;
//подложный логин не установлен, поэтому запрашиваем реальный
BufferSize := SizeOf(TempBuffer);
lpUserName := @TempBuffer;
if WNetGetUser(nil, lpUserName, BufferSize) = NO_ERROR then
  begin
  result := lpUserName;
  end
else
  result := 'ErrorGetLocalUserLoginName'; //ВЕРНУТЬСЯ И ДОДЕЛАТЬ!!!
end;
{===================== Получаем имя локального компа  =========================}
function GetLocalComputerName():string;//здесь потом проверять win = 98/NT !!!!!!!!!
var TempBuffer:array[0..255] of Char;
    BufferSize:cardinal;
begin
BufferSize := SizeOf(TempBuffer);
GetComputerName(@TempBuffer, BufferSize);
LocalComputerName := strpas(StrUpper(TempBuffer));
if Length(LocalComputerName) > 0 then
  begin
  result := LocalComputerName;
  end
else
  result := 'Error GetLocalComputerName';
end;

{======================== GetIncomingMessageCount =============================}
function GetIncomingMessageCount():cardinal;
{var NextMessSize, MaxMessSize:cardinal;
    MessCount, TimeOut:cardinal;}
begin
//exe вызывает эту ф-цию, чтобы узнать сколько пришло сообщений.
//Возвращает количество пришедших сообщений, ожидающих обработки.

//ВНИМАНИЕ!!! В ПОСЛЕДУЮЩЕМ БЫТЬ ВНИМАТЕЛЬНЕЕ С Ф-ЦИЯМИ которые вызывает
//ехешник!!! Ошибки просходят при разрушении объектов в этих ф-циях!
//Т.е. IncommingQueueOfMessages уже разрушен а ехешник все равно
//вызывает ф-цию, где происходит обращение к этому объекту.
result := 0;
CriticalSection.Acquire; // блокирование других потоков
try
  if (ThreadBlocked = false) and (IncommingQueueOfMessages <> nil) then
    result := IncommingQueueOfMessages.Count;
  finally
    CriticalSection.Release;
  end;
end;
{================== GetIncomingMessageCountFromMailSlot =======================}
function GetIncomingMessageCountFromMailSlot():cardinal;
var NextMessSize, MaxMessSize:cardinal;
    MessCount, TimeOut:cardinal;
begin
//exe вызывает эту ф-цию, чтобы узнать сколько пришло сообщений.
//Возвращает количество пришедших сообщений, ожидающих обработки.
GetMailslotInfo(hMailSlotRead, @MaxMessSize, NextMessSize, @MessCount, @TimeOut);
result := MessCount;
end;
{=========================== GetNextIncomingMessage ===========================}
//function GetNextIncomingMessage(PBufferForMessage:Pointer;):cardinal;
function GetNextIncomingMessage(PBufferForMessage:Pointer; BufferSize:cardinal):cardinal;
var {NextMessSize, MaxMessSize,} MessSize:cardinal;
begin
//exe вызывает эту ф-цию, чтобы получить указатель на следующее пришедшее
//сообщение, ожидающее обработки.
//Возвращает следующее сообщение, ожидающее обработки.
CriticalSection.Acquire; // блокирование других потоков
try
  if IncommingQueueOfMessages <> nil then
    begin
    if (ThreadBlocked = false) and (IncommingQueueOfMessages.Count > 0) then
      begin

      //  RunCallBackFunction(PChar('IncommingQueueOfMessages: ' + inttostr(IncommingQueueOfMessages.Count)), 0);
      //  RunCallBackFunction(PChar(IncommingQueueOfMessages.Objects[IncommingQueueOfMessages.Count - 1]), 0);

      //  StrCopy(PBufferForMessage, PChar(IncommingQueueOfMessages.Objects[0]));
      MessSize := StrToInt(IncommingQueueOfMessages.Strings[0]);
      if BufferSize > MessSize then
        CopyMemory(PBufferForMessage,  Pointer(IncommingQueueOfMessages.Objects[0]), MessSize)
      else
        begin
        RunCallBackFunction(PChar('Из-за не хватки размера буфера, ' +
                    'предоставляемого EXEшником, для приема сообщения из DLL ' +
                    'следующее входящее сообщение было удалено без обработки'), 0);
        RunCallBackFunction(PChar(IncommingQueueOfMessages.Objects[0]), 0);
        end;

     //  RunCallBackFunction(PChar('PBufferForMessage: '), 0);
     //  RunCallBackFunction(PChar(PBufferForMessage), 0);

      StrDispose(PChar(IncommingQueueOfMessages.Objects[0]));
      IncommingQueueOfMessages.Delete(0);
     end
   else
     begin
     RunCallBackFunction(PChar('Thread EXE was Blocked for 1 time!: '), 0);
     //PBufferForMessage := @buffer_in;
     end;
   end;
finally
  CriticalSection.Release;
end;
result := 0;//length(PChar(IncommingQueueOfMessages.Objects[IncommingQueueOfMessages.count - 1]));
end;
{==================== GetNextIncomingMessageFromMailSlot ======================}
function GetNextIncomingMessageFromMailSlot():PChar;
var {NextMessSize, MaxMessSize:cardinal;}
    PTemp:PChar;
begin
//exe вызывает эту ф-цию, чтобы получить указатель на следующее пришедшее
//сообщение, ожидающее обработки.
//Возвращает следующее сообщение, ожидающее обработки.
ThreadBlocked := true;
ZeroMemory(@buffer_in, SizeOf(buffer_in));
ZeroMemory(@crypted_in, SizeOf(crypted_in));
ReadFile(hMailSlotRead, crypted_in, SizeOf(crypted_in), readCount, nil);
DCP_rc41.Init(key[1], length(key) * 8, nil);
DCP_rc41.Decrypt(crypted_in, buffer_in, readCount);

PTemp := StrAlloc(readCount + 2);
StrCopy(PTemp, @buffer_in);
//RunCallBackFunction(PChar('@buffer_in readCount = ' + inttostr(readCount) + ' :' ), readCount);
//RunCallBackFunction(PChar(@buffer_in), readCount);

//RunCallBackFunction(PChar('PTemp ziseof = ' + inttostr(length(PTemp)) + ' :'), readCount);
//RunCallBackFunction(PTemp, readCount);

IncommingQueueOfMessages.AddObject(inttostr(readCount), pointer(PTemp));

result := @buffer_in;
ThreadBlocked := false;
end;

function ReadNextOutgoingMessageFromBuffer:cardinal;
var writeCount:cardinal;
    MailSlotWriteName, NetBiosNameOfRemoteComputer, stemp:string;
begin
//раньше при каждой передачи сообщения удаленному компу на время передачи
//открывался маилслот после передачи он закрывался. Из-за этого возникали
//тормоза. Решение: Откроем все маилслоты и будем держать их открытыми.
//Но это еще не все! Т.к. запись сообщения в маилслот удаленного компа
//занимает некоторое время (например он занят), а ф-ция записи блокирующая, т.е.
//WriteFile(hMailSlotWrite....) блокирует поток, до тех пор пока не получит
//результат об успехе или неудаче записи, пришлось выделить для нее отдельный
//поток. Собственно этот поток крутиться внутри DLL и связан с EXE через
//буфер, дабы избежать каких-либо блокировок основного потока EXE.
//Надеюсь смысл объяснил...
//
//и так поток DLL постоянно вызывает эту ф-цию, чтобы узнать, есть ли в буфере
//сообщения, которые необходимо отправить.
//(хм... ну вообще-то не постоянно, а ~4 раза в сек на "холостом" ходу, когда
//буфер пуст и до 100 раз в сек при не пустом буфере)
//настраивается при помощи времени, от которого поток добровольно отказывается.
//sleep(250) <---- ядро windows даст отработать этому потоку только через 250мс
//так сказать это все на пальцах, но если интересно, то RTFM по WINDOWS :-)

result := 0;
if QueueOfMessages.Count > 0 then
  begin
  NetBiosNameOfRemoteComputer := QueueOfRemoteComputersNames.Strings[0];
  MailSlotWriteName := '\\' + NetBiosNameOfRemoteComputer + '\Mailslot\ICHAT047';
  hMailSlotWrite := GetOpenMailSlot(PChar(NetBiosNameOfRemoteComputer));
  QueueOfRemoteComputersNames.Delete(0);
  stemp := QueueOfMessages.Strings[0];
  QueueOfMessages.Delete(0);

  //устанавливаем пароль
  DCP_rc41.Init(key[1], length(key) * 8, nil);
  //берет на один байт раньше (key[0] а это длина строки key)

  //шифруем строку, получаем строку HEX кодов
  StrCopy(@buffer_out, PChar(stemp));
  DCP_rc41.Encrypt(buffer_out, crypted_out, Length(stemp));

  if (hMailSlotWrite <> INVALID_HANDLE_VALUE) then
    begin
    if (WriteFile(hMailSlotWrite, crypted_out, Length(stemp), WriteCount, nil) = false) then
      begin
      RunCallBackFunction(Pchar('SendCommDisconnect: ошибка записи в MailSlot = ' +
                          MailSlotWriteName + '    GetLastError = ' +
                          inttostr(GetLastError())), 0);
      end
    else
      begin
//      SendMessCount := SendMessCount + 1;
//      RunCallBackFunction(Pchar('SendCommDisconnect: В MailSlot было записано = ' + inttostr(WriteCount)), WriteCount);
      end;
    end;
  //нельзя иначе ошибка синхронизации потоков!!!!
  //при уничтожении этого потока возникает ошибка в CallBack
  //RunCallBackFunction(PChar('==>' + '[' + MailSlotWriteName + '] ' + stemp), WriteCount);
  result := QueueOfMessages.Count;
  end;
end;

PROCEDURE TMailSlotThread.Execute;
var count:cardinal;
BEGIN
//основной цикл этой DLL. Все сообщения для отправки передаются из EXE
//в DLL. Она записывает их в буфер и немедленно возвращает управление в EXE
//Потом в DLL крутится отдельный поток и если в буфере что-то есть, он передает
//эти сообщения адресатам.
While not Terminated do
  begin
  //собственно основной цикл потока DLL
  count := GetIncomingMessageCountFromMailSlot();
  if (ReadNextOutgoingMessageFromBuffer = 0) and (count = 0) then
    sleep(WaitForSomething)
  else
    sleep(FullWorkSpeed);
  if count > 0 then GetNextIncomingMessageFromMailSlot();
  end;
END;

{=============== Создаем, запускаем поток и открываем мэйлслот ================}
function Init(ModuleHandle: HMODULE; AdressCallBackFunction:pointer; ExePath:PChar):PChar;
var ChatConfig : TMemIniFile;
    Stemp:String;
    L:integer;
begin
//когда EXE запустился, он прежде чем вызвать какую-нибудь ф-цию DLL,
//обязательно вызывает ф-цию инициализации DLL
//получаем путь и имя этой DLL
ApplicationPath := ExePath;
L := MAX_PATH + 1;
SetLength(Stemp, L);
GetModuleFileName(ModuleHandle, pointer(Stemp), L);

ThreadBlocked := false;
InfoForExe := '';
FullVersion := KernelVersion;
SendMessCount := 1;
MailSlotReadName := '\\.\Mailslot\ICHAT047';
//MailSlotWriteName := '\\*\Mailslot\ICHAT047';
//key := 'tahci';//внимание! не оставлять так!!!!

ChatConfig := TMemIniFile.Create(ExePath + 'config.ini');
key := ChatConfig.ReadString('Crypto', 'Key', 'tahci');
UsersCount := 0;

{<получаем имя компа>}
LocalComputerName := GetLocalComputerName();

{<получаем имя юзера>}
LocalLoginName := GetLocalUserLoginName('');

if DCP_rc41 = nil then
  begin
  DCP_rc41 := TDCP_rc4.Create(nil);
  DCP_rc41.Init(key[1], length(key) * 8, nil);
  OpenMailSlotList := TStringlist.Create;
  OpenMailSlotList.Sorted := true;
  nMaxMessSize := SizeOf(buffer_in);
  QueueOfMessages := TStringList.Create;
  IncommingQueueOfMessages := TStringList.Create;
  QueueOfRemoteComputersNames := TStringList.Create;
  CriticalSection := TCriticalSection.Create;
  if MSThread = nil then
    begin
    MSThread := TMailSlotThread.Create(false);
    MSThread.Priority := tpIdle;
    MSThread.Resume;
    end;
  if hMailSlotRead = 0 then
    begin
    hMailSlotRead := CreateMailSlot(PChar(MailSlotReadName),
                                    nMaxMessSize, 1, nil);
    end;
  if hMailSlotRead = INVALID_HANDLE_VALUE then
     InfoForExe := 'Ошибка открытия MailSlotReadName: ' + MailSlotReadName;
  end
else
  InfoForExe := InfoForExe + 'Не могу создать DCP_rc41, т.к. он уже создан!';

RunCallBackFunction := AdressCallBackFunction;

//******************************************************************************
//* Запоминаем адрес функции обратного вызова, что потом ее вызывать.          *
//* Раньше она нужна была для других целей, а теперь служит для вывода лога в  *
//* окно отладки. Ее реализация в EXE выглядит следующим образом:              *
//
//* FUNCTION CallBackFunction(Buffer:Pchar; MessCountInBuffer:cardinal):PChar; *
//* BEGIN                                                                      *
//*   //DLL может вызвать эту функцию когда ей захочется                       *
//* Form2.Memo2.Lines.Add(Buffer);                                             *
//* sglob := 'CallBackFunction: Меня только что вызвала DLL!';                 *
//* result := @sglob[1];                                                       *
//* END;                                                                       *
//******************************************************************************
//Если не понятно, то подробнее:
//в DLL в основном храняться функции, которые вызывает ЕХЕ, когда это нужно EXE.
//Однако если в DLL есть свои потоки, то им тоже нужно обмениваться инфой с EXE
//и передавать ее в произвольный момент времени, не дожидаясь когда EXE вызовет
//одну из ее функций. Для этого и придуман механизм обратного вызова.
//Соответственно EXE сообщает DLL адрес своей функции/метода, который можно
//вызвать в произвольный момент времени, DLL его запоминает и спокойно вызывает.
//Правда в данной реализации, если будет добавлен поток, нужно будет
//делать безопасный вызов! Т.к. в CallBackFunction происходит работа с
//компонентом.

nMaxMessSize := SizeOf(buffer_in);
//возвращаем пустую строку или сообщение об ошибке!

ChatConfig.Free;
result := PChar(InfoForExe);
end;

{========== Останавливаем, освобождаем поток и закрываем мэйлслоты ============}
function ShutDown():PChar;
var n:cardinal;
    PTemp: PChar;
begin
//прежде чем "умереть" EXE вызывает ф-цию "убийства" DLL
//отправляем все что в очереди на отправку!!!!
//иначе DISCONNECT не успеет уйти!!!

{While ReadNextOutgoingMessageFromBuffer <> 0 do
  begin
  sleep(1);
  end;}

result := 'DCP_rc41 уже давно убит! А hMailSlotWrite закрыт!';
if DCP_rc41 <> nil then
  begin
  if MSThread <> nil then
    begin
    MSThread.Terminate;
//    sleep(100);
    MSThread.Free;
    MSThread := nil;
    end;
  if CriticalSection <> nil then CriticalSection.Free;
  DCP_rc41.Free;
  DCP_rc41 := nil;;
  if OpenMailSlotList <> nil then
    begin
    if OpenMailSlotList.Count > 0 then
      begin
      for n := 0 to (OpenMailSlotList.Count - 1) do
        begin
        if THandle(OpenMailSlotList.Objects[n]) > 0 then CloseHandle(THandle(OpenMailSlotList.Objects[n]));
        end;
      end;
    OpenMailSlotList.Free;
    OpenMailSlotList := nil;
    end;
  if hMailSlotRead > 0 then CloseHandle(hMailSlotRead);
//MessageBox(0, PChar('IncommingQueueOfMessages prepare to free'), PChar(inttostr(IncommingQueueOfMessages.Count)) ,mb_ok);
  if (IncommingQueueOfMessages.Count > 0) then
    begin
    for n := (IncommingQueueOfMessages.Count - 1) downto 0 do
      begin
      //удалять только используя декремент!!!!!
      PTemp := PChar(IncommingQueueOfMessages.Objects[n]);
      if PTemp <> nil then StrDispose(PTemp);
      IncommingQueueOfMessages.Delete(n);
      end;
    end;
//MessageBox(0, PChar('IncommingQueueOfMessages free'), PChar(inttostr(0)) ,mb_ok);
  IncommingQueueOfMessages.Free;
  IncommingQueueOfMessages := nil;
  if (QueueOfMessages.Count > 0) then
    begin
    for n := (QueueOfMessages.Count - 1) downto 0 do
      begin
      QueueOfMessages.Delete(n);
      end;
    end;
  QueueOfMessages.Free;
  QueueOfMessages := nil;
//MessageBox(0, PChar('QueueOfMessages free'), PChar(inttostr(0)) ,mb_ok);
  if (QueueOfRemoteComputersNames.Count > 0) then
    begin
    for n := (QueueOfRemoteComputersNames.Count - 1) downto 0 do
      begin
      QueueOfRemoteComputersNames.Delete(n);
      end;
    end;
  QueueOfRemoteComputersNames.Free;
  QueueOfRemoteComputersNames := nil;
//MessageBox(0, PChar('QueueOfRemoteComputersNames free'), PChar(inttostr(0)) ,mb_ok);
  result := 'DCP_rc41.Free! All objects Free !';
  end;
end;

{=================== Посылаем команду DISCONNECT ==============================}
function SendCommDisconnect(pProtoName, pNameOfLocalComputer, pNetbiosNameOfRemoteComputer, pLineName:PChar):Pchar;
var writeCount:cardinal;
    stemp, sLineName, sNetbiosNameOfRemoteComputer, sNameOfLocalComputer,
    sProtoName, MailSlotWriteName:string;
begin
//exe вызывает эту ф-цию когда нужно послать сообщение DISCONNECT
WriteCount := 0;
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
  sLineName := pLineName;
  sNameOfLocalComputer := pNameOfLocalComputer;
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sProtoName := pProtoName;
  if Length(sNameOfLocalComputer) = 0 then sNameOfLocalComputer := LocalComputerName;

  // iChat  1  ANDREY  DISCONNECT  iTCniaM 
  // iChat  [Счет ASCII]  [Отправитель]  DISCONNECT  iTCniaM 

  //                  iChat            [Счет ASCII]              
  stemp := Char($13) + 'iChat' + #19#19 + inttostr(SendMessCount) + #19#19 +
      //   [Отправитель]            DISCONNECT     
           sNameOfLocalComputer  +  #19#19 + 'DISCONNECT'  + #19#19 +
  //       iTCniaM    
           sLineName + #19;

  //устанавливаем пароль
  //DCP_rc41.Init('tahci', length(key) * 8, nil);
  DCP_rc41.Init(key[1], length(key) * 8, nil);
  //да вот так key[1] по идиотски приходится передавать иначе
  //берет на один байт раньше (key[0] а это длина строки key)

  //шифруем строку, получаем строку HEX кодов
  StrCopy(@buffer_out, PChar(stemp));
  DCP_rc41.Encrypt(buffer_out, crypted_out, Length(stemp));

  //определяем в чей мэйлслот послать
  if sNetbiosNameOfRemoteComputer = sNameOfLocalComputer then sNetbiosNameOfRemoteComputer := '.';
  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);

  MailSlotWriteName := '\\' + sNetbiosNameOfRemoteComputer + '\Mailslot\ICHAT047';
{
  hMailSlotWrite := GetOpenMailSlot(pNameOfRemoteComputer);

  if (hMailSlotWrite <> INVALID_HANDLE_VALUE) then
    begin
    if (WriteFile(hMailSlotWrite, crypted_out, Length(stemp), WriteCount, nil) = false) then
      result := Pchar('SendCommDisconnect: ошибка записи в MailSlot = ' + inttostr(GetLastError()))
    else
      begin
      SendMessCount := SendMessCount + 1;
      result := Pchar('SendCommDisconnect: В MailSlot было записано = ' + inttostr(WriteCount));
      end;
    end;
  end
else
  result := 'SendCommDisconnect: DCP_rc41 не создан!';
}
RunCallBackFunction(PChar('==>' + '[' + MailSlotWriteName + '] ' + stemp), WriteCount);

  end;
result := '';
end;

{====================== Посылаем команду CONNECT ==============================}
function SendCommConnect(pProtoName, pLocalNickName, pNetbiosNameOfRemoteComputer,
                         pLineName,pNameOfRemoteComputer,
                         pMessageStatusX:PChar; Status:Byte):Pchar;
var writeCount:cardinal;
    sProtoName, stemp, sNameOfRemoteComputer, MailSlotWriteName:string;
    sNetbiosNameOfRemoteComputer, sMessageStatusX, sLineName, LocalNickName:string;
begin
//exe вызывает эту ф-цию когда нужно послать сообщение CONNECT
WriteCount := 0;
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
  LocalNickName := pLocalNickName;
  sNameOfRemoteComputer := pNameOfRemoteComputer;
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sLineName := pLineName;
  sProtoName := pProtoName;

  //если имя компа в сообщениии = '', то значит это сообщение всем
  if Length(sNameOfRemoteComputer) = 0 then sNameOfRemoteComputer := '*';

  sMessageStatusX := pMessageStatusX;
  if Length(sMessageStatusX) = 0 then sMessageStatusX := 'Hi all!';

  //iChat2ANDREYCONNECTiTCniaMAdminsAndreyПриветствую!*1.21b60
  //iChat [Счет ASCII]  [Отправитель] CONNECTiTCniaM [Логин] 
  //[Ник]  [Away_сооб] * [Версия]  [Статус] 

//                     iChat            [Счет ASCII]                     [Отправитель]
  stemp := Char($13) + 'iChat' + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
//                  CONNECT           iTCniaM            [Логин]         
           #19#19 + 'CONNECT' + #19#19 + sLineName + #19#19 + LocalLoginName + #19#19 +
//          [Ник]                         [Away_сооб]                       *
           LocalNickName + #19#19 + #19#19 + sMessageStatusX + #19#19 + sNameOfRemoteComputer +
//                 [Версия]               [Статус]          
            #19#19 + FullVersion + #19#19 + inttostr(status) + #19;

  //определяем в чей мэйлслот послать
  if LocalComputerName = sNetbiosNameOfRemoteComputer then
     sNetbiosNameOfRemoteComputer := '.';
  MailSlotWriteName := '\\' + sNetbiosNameOfRemoteComputer + '\Mailslot\ICHAT047';

  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
  RunCallBackFunction(PChar('==>' + '[' + MailSlotWriteName + '] ' + stemp), WriteCount);
  end;
result := '';
end;

{========================= Посылаем команду TEXT ==============================}
//function SendCommText(MessageText:PChar; RecepientNickName:Pchar; ChatLine:Pchar):Pchar;
function SendCommText(pProtoName, pNetbiosNameOfRemoteComputer, pNickNameOfRemoteComputer:PChar;pMessageText:PChar; ChatLine:Pchar;Increment:integer):Pchar;
var writeCount:cardinal;
    sProtoName, MailSlotWriteName, sMessageText, stemp,
    sNickNameOfRemoteComputer, sNetbiosNameOfRemoteComputer, sChatLine:string;
begin
//exe вызывает эту ф-цию когда нужно послать сообщение TEXT
//iChat983KITTYTEXTgsMTCI устранимая проблема?Andrey
//Личное соощщение
WriteCount := 0;
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
{[~] [ichat] [~~] [Счетчик ASCII] [~~] [Отправитель] [~~] [TEXT] [~~]
 [Линия] [~~] [Текст] [~~] [НИК Получатель | "*" | ""] [~]
}
  sChatLine := ChatLine;
  sProtoName := pProtoName;
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sNickNameOfRemoteComputer := pNickNameOfRemoteComputer;
  SendMessCount := SendMessCount + Increment;
  //чтобы в TEdit не впихнули 99999999 букв и не выскочила ошибка
    sMessageText := pMessageText;
  if length(sMessageText) >= SizeOf(buffer_out) - 100 then
    sMessageText := copy(sMessageText, 0, SizeOf(buffer_out) - 100)
  else
    sMessageText := pMessageText;
  //для личных мессаг +1, чтобы всего номер сообщения был на 2 больше предыдущего

//  messagebox(0, PChar(MailSlotWriteName), 'SendCommText: MailSlotWriteName=' ,mb_ok);

  //                   iChat           [Счет ASCII]                     [Отправитель]
  stemp := Char($13) + 'iChat' + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
  //              TEXT            iTCniaM            [Текст]       
           #19#19 + 'TEXT' + #19#19 + sChatLine + #19#19 + sMessageText + #19#19 +
   //      [НИК Получатель]                   
           sNickNameOfRemoteComputer + #19 {+ #19};

{  //устанавливаем пароль
  DCP_rc41.Init(key[1], length(key) * 8, nil);
  //берет на один байт раньше (key[0] а это длина строки key)

  //шифруем строку, получаем строку HEX кодов
  StrCopy(@buffer_out, PChar(stemp));
  DCP_rc41.Encrypt(buffer_out, crypted_out, Length(stemp));

  //определяем в чей мэйлслот послать
//  MailSlotWriteName := '\\' + sNameOfRemoteComputer + '\Mailslot\ICHAT047';

  hMailSlotWrite := GetOpenMailSlot(pNameOfRemoteComputer);

  if (hMailSlotWrite <> INVALID_HANDLE_VALUE) then
    begin
    if (WriteFile(hMailSlotWrite, crypted_out, Length(stemp), WriteCount, nil) = false) then
      result := Pchar('SendCommDisconnect: ошибка записи в MailSlot = ' + inttostr(GetLastError()))
    else
      begin
      SendMessCount := SendMessCount + 1;
      result := Pchar('SendCommDisconnect: В MailSlot было записано = ' + inttostr(WriteCount));
      end;
    end;
  end
else
  result := 'SendCommConnect: DCP_rc41 не создан!';

}
  //определяем в чей мэйлслот послать
  MailSlotWriteName := '\\' + sNetbiosNameOfRemoteComputer + '\Mailslot\ICHAT047';
  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
  RunCallBackFunction(PChar('==>' + '[' + MailSlotWriteName + '] ' + stemp), WriteCount);
  end;
result := '';
end;

{====================== Посылаем команду STATUS ==============================}
function SendCommStatus(pProtoName, pNetbiosNameOfRemoteComputer:PChar;LocalUserStatus:cardinal;StatusMessage:Pchar):Pchar;
var writeCount:cardinal;
    sProtoName, MailSlotWriteName, sNetbiosNameOfRemoteComputer, stemp:string;
begin
//exe вызывает эту ф-цию когда нужно послать сообщение STATUS
WriteCount := 0;
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));

//  MailSlotWriteName := '\\*\Mailslot\ICHAT047';
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sProtoName := pProtoName;

  //iChat  24           KITTY          STATUS  3         Katushka получает... сообщение :gigi:
  //iChat  642          ALF            STATUS  3         Меня нет.   
  //iChat [Счет ASCII]  [Отправитель]  STATUS  [Статус]  [Away_сооб] 

  //                   iChat           [Счет ASCII]                     [Отправитель]
  stemp := Char($13) + 'iChat' + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
  //              STATUS            [Статус]                                  
           #19#19 + 'STATUS' + #19#19 + inttostr(LocalUserStatus) + #19#19 +
   //      [Away_сооб]     
           StatusMessage + #19;
//         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ это не верно!!!

{  //устанавливаем пароль
  DCP_rc41.Init(key[1], length(key) * 8, nil);
  //берет на один байт раньше (key[0] а это длина строки key)

  //шифруем строку, получаем строку HEX кодов
  StrCopy(@buffer_out, PChar(stemp));
  DCP_rc41.Encrypt(buffer_out, crypted_out, Length(stemp));

  //определяем в чей мэйлслот послать
  MailSlotWriteName := '\\' + sNameOfRemoteComputer + '\Mailslot\ICHAT047';

  hMailSlotWrite := GetOpenMailSlot(pNameOfRemoteComputer);

  if (hMailSlotWrite <> INVALID_HANDLE_VALUE) then
    begin
    if (WriteFile(hMailSlotWrite, crypted_out, Length(stemp), WriteCount, nil) = false) then
      result := Pchar('SendCommDisconnect: ошибка записи в MailSlot = ' + inttostr(GetLastError()))
    else
      begin
      SendMessCount := SendMessCount + 1;
      result := Pchar('SendCommDisconnect: В MailSlot было записано = ' + inttostr(WriteCount));
      end;
    end;
  end
else
  result := 'SendCommStatus: DCP_rc41 не создан!';

RunCallBackFunction(PChar('==>' + '[' + MailSlotWriteName + '] ' + stemp), WriteCount);
}
  //определяем в чей мэйлслот послать
  MailSlotWriteName := '\\' + sNetbiosNameOfRemoteComputer + '\Mailslot\ICHAT047';
  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
  RunCallBackFunction(PChar('==>' + '[' + MailSlotWriteName + '] ' + stemp), WriteCount);
  end;
result := '';
end;

{=================== Посылаем команду RECEIVED ==============================}
function SendCommReceived(pProtoName, pNetbiosNameOfRemoteComputer:PChar;MessAboutReceived:PChar):Pchar;
var writeCount:cardinal;
    sProtoName, MailSlotWriteName, sNetbiosNameOfRemoteComputer, stemp:string;
begin
//exe вызывает эту ф-цию когда нужно послать сообщение RECEIVED
WriteCount := 0;
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));

  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sProtoName := pProtoName;

  // iChat  305  KITTY  RECEIVED  gsMTCI . Нет меня.
  // iChat  [Счет ASCII]  [Отправитель]  RECEIVED  gsMTCI  [Away_сооб]

  //                  iChat            [Счет ASCII]              
  stemp := Char($13) + 'iChat' + #19#19 + inttostr(SendMessCount) + #19#19 +
      //   [Отправитель]                 RECEIVED     
           LocalComputerName  +  #19#19 + 'RECEIVED'  + #19#19 +
  //       gsMTCI            [Away_сооб]         
           'gsMTCI' + #19#19 + MessAboutReceived + #19;
//           'gsMTCI' + #19#19 + ChatUsers[UserId].HelloMessage + #19;

{  //устанавливаем пароль
  DCP_rc41.Init(key[1], length(key) * 8, nil);

  StrCopy(@buffer_out, PChar(stemp));
  DCP_rc41.Encrypt(buffer_out, crypted_out, Length(stemp));

  //определяем в чей мэйлслот послать
  MailSlotWriteName := '\\' + sNameOfRemoteComputer + '\Mailslot\ICHAT047';
//  messagebox(0, PChar(MailSlotWriteName), 'SendCommReceived: MailSlotWriteName =' ,mb_ok);

  hMailSlotWrite := GetOpenMailSlot(pNameOfRemoteComputer);

  if (hMailSlotWrite <> INVALID_HANDLE_VALUE) then
    begin
    if (WriteFile(hMailSlotWrite, crypted_out, Length(stemp), WriteCount, nil) = false) then
      result := Pchar('SendCommDisconnect: ошибка записи в MailSlot = ' + inttostr(GetLastError()))
    else
      begin
      SendMessCount := SendMessCount + 1;
      result := Pchar('SendCommDisconnect: В MailSlot было записано = ' + inttostr(WriteCount));
      end;
    end;
  end
else
  result := 'SendCommReceived: DCP_rc41 не создан!';

RunCallBackFunction(PChar('==>' + '[' + MailSlotWriteName + '] ' + stemp), WriteCount);
}
  //определяем в чей мэйлслот послать
  MailSlotWriteName := '\\' + sNetbiosNameOfRemoteComputer + '\Mailslot\ICHAT047';
  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
  RunCallBackFunction(PChar('==>' + '[' + MailSlotWriteName + '] ' + stemp), WriteCount);
  end;
result := '';
end;

{=================== Посылаем команду BOARD ==============================}
function SendCommBoard(pProtoName, pNameOfRemoteComputer:PChar;pMessageBoard:Pchar;MaxSizeOfPart:cardinal):Pchar;
var n, i, partcount, LenMess, StartPart, EndPart:cardinal;
    strbuffer: array of char;
begin
//exe вызывает эту ф-цию когда нужно послать сообщение BOARD
//служит для того, чтобы раздробить длинное сообщение доски объявлений
//на несколько мелких кусков.
//в каком же состоянии я это писал?! Ладно, потом переделаю...
LenMess := strlen(pMessageBoard);
if (LenMess = 0) then
  partcount := 1
else
  partcount := round(LenMess/MaxSizeOfPart) - 1;

if LenMess = 0 then LenMess := 1;
partcount := abs(i);

setlength(strbuffer, MaxSizeOfPart + 1);
if LenMess > MaxSizeOfPart then
  begin
  for n := 0 to partcount do
    begin
    StartPart := n * MaxSizeOfPart;
    EndPart := n * MaxSizeOfPart + MaxSizeOfPart;
    if EndPart > LenMess then EndPart := LenMess;
    for i := 0 to MaxSizeOfPart - 1 do
      begin
      strbuffer[i] := pMessageBoard[StartPart];
      inc(StartPart);
      end;
    SendCommBoardX(pProtoName, pNameOfRemoteComputer, PChar(strbuffer), n);
    end;
  end
else
  begin
  SendCommBoardX(pProtoName, pNameOfRemoteComputer, pMessageBoard, 0);
  end;
result := '';
end;

function SendCommBoardX(pProtoName, pNetbiosNameOfRemoteComputer:PChar;pMessageBoard:Pchar;PartMessNumber:cardinal):Pchar;
var writeCount:cardinal;
    sProtoName, MailSlotWriteName, sNetbiosNameOfRemoteComputer, stemp:string;
begin
//собственно сама отправка кусочков
WriteCount := 0;
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));

  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sProtoName := pProtoName;
  // iChat  387  VADIMUS  BOARD  0  Люди, найдите фильм плизз.
  //# iChat ## 20  ## SAMAEL  ## BOARD ## 0 ##                           #

  //                  iChat            [Счет ASCII]              
  stemp := Char($13) + 'iChat' + #19#19 + inttostr(SendMessCount) + #19#19 +
      //   [Отправитель]                 BOARD     
           LocalComputerName  +  #19#19 + 'BOARD'  + #19#19 +
  //       [Номер части сообщения]           [MessageBoard]         
           inttostr(PartMessNumber) + #19#19 + pMessageBoard + #19;

{  //устанавливаем пароль
  DCP_rc41.Init(key[1], length(key) * 8, nil);

  StrCopy(@buffer_out, PChar(stemp));
  DCP_rc41.Encrypt(buffer_out, crypted_out, Length(stemp));

  //определяем в чей мэйлслот послать
  MailSlotWriteName := '\\' + sNameOfRemoteComputer + '\Mailslot\ICHAT047';

  hMailSlotWrite := GetOpenMailSlot(pNameOfRemoteComputer);

  if (hMailSlotWrite <> INVALID_HANDLE_VALUE) then
    begin
    if (WriteFile(hMailSlotWrite, crypted_out, Length(stemp), WriteCount, nil) = false) then
      result := Pchar('SendCommDisconnect: ошибка записи в MailSlot = ' + inttostr(GetLastError()))
    else
      begin
      SendMessCount := SendMessCount + 1;
      result := Pchar('SendCommDisconnect: В MailSlot было записано = ' + inttostr(WriteCount));
      end;
    end;
  end
else
  result := 'SendCommBoard: DCP_rc41 не создан!';

RunCallBackFunction(PChar('==>' + '[' + MailSlotWriteName + '] ' + stemp), WriteCount);
}
  //определяем в чей мэйлслот послать
  MailSlotWriteName := '\\' + sNetbiosNameOfRemoteComputer + '\Mailslot\ICHAT047';
  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
  RunCallBackFunction(PChar('==>' + '[' + MailSlotWriteName + '] ' + stemp), WriteCount);
  end;
result := '';
end;

{=================== Посылаем команду REFRESH ==============================}
function SendCommRefresh(pProtoName, pNetbiosNameOfRemoteComputer, pLineName, pLocalNickName:Pchar;
                         LocalUserStatus:cardinal;pAwayMess:Pchar;
                         pReceiver:Pchar;Increment:integer):Pchar;
var writeCount:cardinal;
    sProtoName, MailSlotWriteName, sReceiver, sNetbiosNameOfRemoteComputer,
    sTemp, sAwayMess, sLocalNickName, sLineName:string;
begin
//exe вызывает эту ф-цию когда нужно послать сообщение REFRESH
WriteCount := 0;
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
  //я послал запрос:
  //iChat137ANDREYREFRESHiTCniaMAdminsAndreyПриветствую!*1.21b63
  //iChat137ANDREYREFRESHiTCniaMAdminsAndreyПриветствую!*1.21b63

    sAwayMess := pAwayMess;
    sLocalNickName := pLocalNickName;
    sLineName := pLineName;
    sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
    sReceiver := pReceiver;
    sProtoName := pProtoName;

    //                   iChat           [Счет ASCII]                     [Отправитель]
    stemp := Char($13) + 'iChat' + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
    //              REFRESH            iTCniaM            [Логин]         
             #19#19 + 'REFRESH' + #19#19 + sLineName + #19#19 + LocalLoginName + #19#19 +
    //       [Ник]                         [Away_сооб]           *      
             sLocalNickName + #19#19 + #19#19 + sAwayMess   + #19#19 + sReceiver + #19#19 +
    //       [Версия]             [Статус]                     
             FullVersion + #19#19 + inttostr(LocalUserStatus) + #19;

{    //устанавливаем пароль
    DCP_rc41.Init(key[1], length(key) * 8, nil);

    StrCopy(@buffer_out, PChar(stemp));
    DCP_rc41.Encrypt(buffer_out, crypted_out, Length(stemp));

    //определяем в чей мэйлслот послать
    MailSlotWriteName := '\\' + sNameOfRemoteComputer + '\Mailslot\ICHAT047';

  hMailSlotWrite := GetOpenMailSlot(pNameOfRemoteComputer);

  if (hMailSlotWrite <> INVALID_HANDLE_VALUE) then
    begin
    if (WriteFile(hMailSlotWrite, crypted_out, Length(stemp), WriteCount, nil) = false) then
      result := Pchar('SendCommDisconnect: ошибка записи в MailSlot = ' + inttostr(GetLastError()))
    else
      begin
      SendMessCount := SendMessCount + Increment;
      result := Pchar('SendCommDisconnect: В MailSlot было записано = ' + inttostr(WriteCount));
      end;
    end;
  end
else
  result := 'SendCommRefresh: DCP_rc41 не создан!';

RunCallBackFunction(PChar('==>' + '[' + MailSlotWriteName + '] ' + stemp), WriteCount);
}
  //определяем в чей мэйлслот послать
  MailSlotWriteName := '\\' + sNetbiosNameOfRemoteComputer + '\Mailslot\ICHAT047';
  SendMessCount := SendMessCount + Increment;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
  RunCallBackFunction(PChar('==>' + '[' + MailSlotWriteName + '] ' + stemp), WriteCount);
  end;
result := '';
end;

{===================   Посылаем команду RENAME   ==============================}
function SendCommRename(pProtoName, pNetbiosNameOfRemoteComputer:Pchar;pNewNickName:Pchar):Pchar;
var writeCount:cardinal;
    sProtoName, MailSlotWriteName, sNetbiosNameOfRemoteComputer, sTemp, sNewNickName:string;
begin
//exe вызывает эту ф-цию когда нужно послать сообщение RENAME
WriteCount := 0;
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
  sNewNickName := pNewNickName;
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sProtoName := pProtoName;

  //для смены имени посылается, отвечать на него не надо:
  //iChat287KITTYRENAMEKITTY

    //                   iChat           [Счет ASCII]                     [Отправитель]
    stemp := Char($13) + 'iChat' + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
    //              RENAME            NewNickName     
             #19#19 + 'RENAME' + #19#19 + sNewNickName + #19;

{    //устанавливаем пароль
    DCP_rc41.Init(key[1], length(key) * 8, nil);

    StrCopy(@buffer_out, PChar(stemp));
    DCP_rc41.Encrypt(buffer_out, crypted_out, Length(stemp));

    //определяем в чей мэйлслот послать
    MailSlotWriteName := '\\' + sNameOfRemoteComputer + '\Mailslot\ICHAT047';

  hMailSlotWrite := GetOpenMailSlot(pNameOfRemoteComputer);

  if (hMailSlotWrite <> INVALID_HANDLE_VALUE) then
    begin
    if (WriteFile(hMailSlotWrite, crypted_out, Length(stemp), WriteCount, nil) = false) then
      result := Pchar('SendCommDisconnect: ошибка записи в MailSlot = ' + inttostr(GetLastError()))
    else
      begin
      SendMessCount := SendMessCount + 1;
      result := Pchar('SendCommDisconnect: В MailSlot было записано = ' + inttostr(WriteCount));
      end;
    end;
  end
else
  result := 'SendCommRename: DCP_rc41 не создан!';

RunCallBackFunction(PChar('==>' + '[' + MailSlotWriteName + '] ' + stemp), WriteCount);
}
  //определяем в чей мэйлслот послать
  MailSlotWriteName := '\\' + sNetbiosNameOfRemoteComputer + '\Mailslot\ICHAT047';
  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
  RunCallBackFunction(PChar('==>' + '[' + MailSlotWriteName + '] ' + stemp), WriteCount);
  end;
result := '';
end;

{===================   Посылаем команду CREATE   ==============================}
function SendCommCreate(pProtoName, pNetbiosNameOfRemoteComputer, pPrivateChatLineName:Pchar):Pchar;
var writeCount:cardinal;
    sProtoName, MailSlotWriteName, sTemp, sNetbiosNameOfRemoteComputer, sPrivateChatLineName:string;
begin
//exe вызывает эту ф-цию когда нужно послать сообщение CREATE
WriteCount := 0;
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
  sPrivateChatLineName := pPrivateChatLineName;
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sProtoName := pProtoName;
  //со мной создают личный чат:
  //мне приходит: создан ПУСТОЙ личный чат
  //iChat527KITTYCREATE856000ANDREY

  //я посылаю: я захожу в него
  //iChat28ANDREYCONNECT856000AdminsAndreyПриветствую!*1.3b30

  //мне приходит: ANDREY ваш вход подтверждаю
  //iChat531KITTYCONNECT856000Katushkakatчshka:hello:ANDREY1.3b30

  //я посылаю: KITTY ваш вход подтверждаю
  //iChat30ANDREYCONNECT856000AdminsAndreyПриветствую!KITTY1.3b30

    //                   iChat           [Счет ASCII]                     [Отправитель]
    stemp := Char($13) + 'iChat' + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
    //               CREATE           [Имя приватного чата]                  [Получатель]                 
             #19#19 + 'CREATE' + #19#19 + sPrivateChatLineName + #19#19 + #19#19 + sNetbiosNameOfRemoteComputer + #19;

  //определяем в чей мэйлслот послать
  MailSlotWriteName := '\\' + sNetbiosNameOfRemoteComputer + '\Mailslot\ICHAT047';
  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
  RunCallBackFunction(PChar('==>' + '[' + MailSlotWriteName + '] ' + stemp), WriteCount);
  end;
result := '';
end;

{===================   Посылаем команду CREATELINE   ==============================}
function SendCommCreateLine(pProtoName, pNetbiosNameOfRemoteComputer, pPrivateChatLineName, pPassword:Pchar):Pchar;
var writeCount:cardinal;
    MailSlotWriteName, sTemp, sNetbiosNameOfRemoteComputer,
    sProtoName, sPrivateChatLineName, sPassword:string;
begin
//exe вызывает эту ф-цию когда нужно послать сообщение CREATE
WriteCount := 0;
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
  sPrivateChatLineName := pPrivateChatLineName;
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sPassword := pPassword;
  sProtoName := pProtoName;
  //со мной создают личный чат:
  //мне приходит: создан ПУСТОЙ личный чат
  //iChat527KITTYCREATE856000ANDREY

  //я посылаю: я захожу в него
  //iChat28ANDREYCONNECT856000AdminsAndreyПриветствую!*1.3b30

  //мне приходит: ANDREY ваш вход подтверждаю
  //iChat531KITTYCONNECT856000Katushkakatчshka:hello:ANDREY1.3b30

  //я посылаю: KITTY ваш вход подтверждаю
  //iChat30ANDREYCONNECT856000AdminsAndreyПриветствую!KITTY1.3b30

    //                   iChat           [Счет ASCII]                     [Отправитель]
    stemp := Char($13) + 'iChat' + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
    //               CREATE           [Имя приватного чата]         пароль             [Получатель]                 
             #19#19 + 'CREATE_LINE' + #19#19 + sPrivateChatLineName + #19#19 + sPassword + #19#19 + sNetbiosNameOfRemoteComputer + #19;

  //определяем в чей мэйлслот послать
  MailSlotWriteName := '\\' + sNetbiosNameOfRemoteComputer + '\Mailslot\ICHAT047';
  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
  RunCallBackFunction(PChar('==>' + '[' + MailSlotWriteName + '] ' + stemp), WriteCount);
  end;
result := '';
end;

{===============   Посылаем команду SendCommStatus_Req   ======================}
function SendCommStatus_Req(pProtoName, pNetbiosNameOfRemoteComputer:PChar):Pchar;
var MailSlotWriteName, sNetbiosNameOfRemoteComputer, sProtoName, stemp:string;
begin
//exe вызывает эту ф-цию когда нужно послать сообщение STATUS
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));

//  MailSlotWriteName := '\\*\Mailslot\ICHAT047';
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sProtoName := pProtoName;
  MailSlotWriteName := '\\' + sNetbiosNameOfRemoteComputer + '\Mailslot\ICHAT047';

  //iChat418SATANASTATUS_REQ
  //                   iChat              [Счет ASCII]                     [Отправитель]
  stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
  //              STATUS_REQ      
           #19#19 + 'STATUS_REQ' + #19;

  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
  RunCallBackFunction(PChar('==>' + '[' + MailSlotWriteName + '] ' + stemp), 0);
//  RunCallBackFunction(PChar('==> QueueOfMessages:  ' + stemp), 0);
  end;
result := '';
end;

{===============   Посылаем команду SendCommMe   ======================}
function SendCommMe(pProtoName, pNetbiosNameOfRemoteComputer, pNickNameOfRemoteComputer:PChar;pMessageText:PChar; ChatLine:Pchar;Increment:integer):Pchar;
var sMessageText, stemp, sNickNameOfRemoteComputer, sNetbiosNameOfRemoteComputer,
    MailSlotWriteName, sProtoName, sChatLine:string;
begin
//ME [0x13][0x13] [сообщение] [0x13][0x13] [имя линии] [0x13][0x13] [получатель] - аналог ACTION в IRC (команда /me сообщение). Класс IChatMeMessage.
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
  sChatLine := ChatLine;
  sProtoName := pProtoName;
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sNickNameOfRemoteComputer := pNickNameOfRemoteComputer;
  MailSlotWriteName := '\\' + sNetbiosNameOfRemoteComputer + '\Mailslot\ICHAT047';
//  SendMessCount := SendMessCount + cardinal(Increment);
  //чтобы в TEdit не впихнули 99999999 букв и не выскочила ошибка
    sMessageText := pMessageText;
  if length(sMessageText) >= SizeOf(buffer_out) - 100 then
    sMessageText := copy(sMessageText, 0, SizeOf(buffer_out) - 100)
  else
    sMessageText := pMessageText;
  //для личных мессаг +1, чтобы всего номер сообщения был на 2 больше предыдущего

  //                   iChat              [Счет ASCII]                     [Отправитель]
  stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
  //              ME              iTCniaM            gfrjeioj      
           #19#19 + 'ME' + #19#19 + sChatLine + #19#19 + sMessageText + #19#19 +
   //      [НИК Получатель]            
           sNickNameOfRemoteComputer + #19;

  SendMessCount := SendMessCount + cardinal(Increment);
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
  RunCallBackFunction(PChar('==>' + '[' + MailSlotWriteName + '] ' + stemp), 0);
  end;
result := '';
end;

{==============   Посылаем команду SendCommBoard_Refresh   ====================}
function SendCommRefresh_Board(pProtoName, pNetbiosNameOfRemoteComputer: PChar; Increment:integer):Pchar;
var sMessageText, stemp, sNetbiosNameOfRemoteComputer,
    MailSlotWriteName, sProtoName:string;
begin
//Запрос доски
//iChat[0x13][0x13]%d[0x13][0x13]192.168.1.4/ANDREY/User[0x13][0x13]REFRESH_BOARD
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
  sProtoName := pProtoName;
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  MailSlotWriteName := '\\' + sNetbiosNameOfRemoteComputer + '\Mailslot\ICHAT047';
  //для личных мессаг +1, чтобы всего номер сообщения был на 2 больше предыдущего

  //                   iChat              [Счет ASCII]                     [Отправитель]
  stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
  //              REFRESH_BOARD      
           #19#19 + 'REFRESH_BOARD' + #19;

  SendMessCount := SendMessCount + cardinal(Increment);
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
  RunCallBackFunction(PChar('==>' + '[' + MailSlotWriteName + '] ' + stemp), 0);
  end;
result := '';
end;

exports
Init index 1 name 'Init',
ShutDown index 2 name 'ShutDown',
SendCommDisconnect index 3 name 'SendCommDisconnect',
SendCommConnect index 4 name 'SendCommConnect',
SendCommText index 5 name 'SendCommText',
SendCommReceived index 6 name 'SendCommReceived',
SendCommStatus index 7 name 'SendCommStatus',
SendCommBoard index 8 name 'SendCommBoard',
SendCommRefresh index 9 name 'SendCommRefresh',
SetVersion index 10 name 'SetVersion',
SendCommBoardX index 11 name 'SendCommBoardX',
SendCommRename index 12 name 'SendCommRename',
GetIncomingMessageCount index 13 name 'GetIncomingMessageCount',
GetNextIncomingMessage index 14 name 'GetNextIncomingMessage',
SendCommCreate index 15 name 'SendCommCreate',
GetIP index 16 name 'GetIP',
SendCommCreateLine index 17 name 'SendCommCreateLine',
SendCommStatus_Req index 18 name 'SendCommStatus_Req',
SendCommMe index 19 name 'SendCommMe',
SendCommRefresh_Board index 20 name 'SendCommRefresh_Board',
GetLocalUserLoginName index 21 name 'GetLocalUserLoginName';

begin
  IsMultiThread := True;
end.


