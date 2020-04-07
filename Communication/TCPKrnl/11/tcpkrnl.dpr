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
library TCPkrnl;

{/$/DEFINE USELOG4D}

uses
{$IFDEF USEFASTSHAREMEM}
  FastShareMem,
{$ENDIF}
  ExceptionLog,
  Windows,
  SysUtils,
  //SysInit,
  Classes,
  Messages,
  DCPcrypt2,
  DCPrc4,
  ScktComp,
  Inifiles,
  SyncObjs,
  WinSock,
  ExtCtrls,
  JwaWinType,
  JwaIpHlpApi,
  JwaIpRtrMib,
{$IFDEF USELOG4D}
  log4d,
{$ENDIF USELOG4D}
  ProtocolMessage in 'ProtocolMessage.pas';

type
  TMailSlotThread = class(TThread)
  private
  protected
    procedure Execute; override;
    procedure ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketConnected(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketConnecting(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketError(Sender: TObject; Socket: TCustomWinSocket;
                                ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ClientSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketLookup(Sender: TObject; Socket: TCustomWinSocket);
    PROCEDURE OnTryConnect(Sender: TObject);
  end;

type TCallBackFunction = function(Buffer:Pchar; Destination:cardinal):PChar;

//function Init(ModuleHandle: HMODULE;AdressCallBackFunction:Pointer; ExePath:Pchar):PChar;forward;
//function ShutDown():PChar;forward;
//function GetLocalUserLoginName(OverrideLN: PChar):PChar;forward;
//function GetLocalComputerName():string;forward;
//function SendCommBoardX(pProtoName, pNetbiosNameOfRemoteComputer:PChar;pMessageBoard:Pchar;PartMessNumber:cardinal):Pchar;forward;
//function SendCommConnect(pProtoName, pLocalNickName, pNetbiosNameOfRemoteComputer,
//                         pLineName,pNameOfRemoteComputer,
//                         pMessageStatusX:PChar; Status:Byte):Pchar;forward;
//function SendCommReceived(pProtoName, pNetbiosNameOfRemoteComputer:PChar;MessAboutReceived:PChar):Pchar;forward;

function SendNextOutgoingMessageFromBuffer:cardinal;forward;

const
  KernelVersion = 'T11';//T = TCP
  WaitForSomething = 250;//Если нечего делать отдаем проц другим задачам
                         //на 250мс (т.е. код отрабатывает не более 4 раз в сек)
  FullWorkSpeed = 10;//Полная рабочая скорость, в этот момент передаем сообщения
                     //из буфера, но все-таки отдаем проц другим на 10мс
  MESSAGEBUFSIZE = 1500;

{$IFDEF USELOG4D}
  // name of logger (configured in tcpkrnl.prop)
  TCPLOGGER_NAME = 'tcpkrnl';
{$ENDIF USELOG4D}

type
  TMessageBuf = array[0..MESSAGEBUFSIZE-1] of Char;

var
  key, InfoForExe, LocalComputerName, LocalLoginName, LocalIpAddres  :string;
  OverrideLoginName                                                  :String;
  ApplicationPath                                                    :String;
  {ChatVersion,} FullVersion                                           :string;
  //crypted_in, crypted_out, buffer_in, temp_in, buffer_out            :array[0..1499] of Char;
  //hClientSocket                                                      :handle;
  ClientSocket                                                       :TClientSocket;
  Show_SystemMessages_Connect                                        :boolean;
  Show_SystemMessages_Connected                                      :boolean;
{$IFDEF USELOG4D}
  DllName                                                            :array[0..MAX_PATH] of char;
{$ENDIF USELOG4D}
  SendMessCount, nMaxMessSize, UsersCount                            :cardinal;
  DCP_rc41                                                           :TDCP_rc4;
  RunCallBackFunction                                                :TCallBackFunction;
  OpenMailSlotList, QueueOfMessages, QueueOfRemoteComputersNames     :TStringList;
  IncommingQueueOfMessages                                           :TStringList;
  MSThread                                                           :TMailSlotThread;
  ConnectingTimer                                                    :TTimer;
  {ThreadBlocked,} DoConnect                                           :boolean;
  CriticalSection                                                    :TCriticalSection;


{============= впомогательная функция парсинга строки ======================}
FUNCTION GetParam(SourceString: String; ParamNumber: Integer; Separator: String): String;
var
  s: string;
  i, Count: integer;
{$IFDEF USELOG4D}
  logger: TlogLogger;
{$ENDIF USELOG4D}
BEGIN

try

  Count := 0;
  s := SourceString;
  i := pos(Separator, s);
  while i > 0 do begin
    if Count = ParamNumber then begin
      Result := copy(s, 1, i - 1);
      exit;
    end;
    delete(s, 1, i);
    inc(Count);
    i := pos(Separator, s);
  end;

  if Count < ParamNumber
    then Result := ''
    else Result := s;

except
 on E: Exception do begin
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
   raise;
 end;
end;

END;

FUNCTION  GetParamX(SourceString: String; ParamNumber: Integer; Separator: String; HideSingleSeparaterError:boolean): String;
VAR
  I, Posit: integer;
  S: string;
{$IFDEF USELOG4D}
  logger: TLogLogger;
{$ENDIF USELOG4D}
BEGIN
try

  //выковыривает то, что между разделителями (Separator)
  S := SourceString;
  for I := 1 to ParamNumber do begin
    Posit := Pos(Separator, S) + Length(Separator) - 1;
    Delete(S, 1, Posit);
  end;

  Posit := Pos(Separator, S);
  Delete(S, Posit , Length(S) - Posit + 1);
  if HideSingleSeparaterError = true then begin
    i := Pos(Separator[1], s);
    while i > 0 do begin
      delete(s, i, 1);
      i := Pos(Separator[1], s);
    end;
  end;
  Result := s;
except
 on E: Exception do begin
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
   raise;
 end;
end

END;

FUNCTION SetVersion(Version:PChar):PChar;
var
    ChatVersion: string;
BEGIN
  //собственно добавляет к строке версии ядра чата версию сетевой библиотеки
  FullVersion := '';
  ChatVersion := Version;
  FullVersion := ChatVersion + KernelVersion;
  Result := PChar(FullVersion);
END;

{FUNCTION GetOpenMailSlot(pNameOfRemoteComputer:PChar):THandle;
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
  end
else
  begin
  //открытый не нашли, открываем новый
  MailSlotWriteName := '\\' + sNameOfRemoteComputer + '\Mailslot\ICHAT047';
  hMailSlotWrite := CreateFile(PChar(MailSlotWriteName),GENERIC_WRITE, FILE_SHARE_READ,
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
END;}


{===================== Получаем имя локального компа  =========================}
function GetLocalComputerName():string;//TODO: здесь потом проверять win = 98/NT !!!!!!!!!
var
    TempBuffer:array[0..255] of Char;
    BufferSize:cardinal;
begin
  BufferSize := SizeOf(TempBuffer);
  GetComputerName(@TempBuffer, BufferSize);
  LocalComputerName := strpas(StrUpper(TempBuffer));

//LocalComputerName := '192.168.0.5' + '/' + LocalComputerName + '/' + 'Andrey';

  if Length(LocalComputerName) > 0
    then Result := LocalComputerName
    else Result := 'Error GetLocalComputerName';
end;

{===================== Получаем IP локального компа  =========================}
function GetLocalIP : string;
var
  err: integer;
  len, n: cardinal;
  MyAdrr: in_addr;
  res, IP, FirstOktetMyIP, Lan, Internet, ServerN, FirstOktetServerIP: string;
  ChatConf: TMemIniFile;
  MibIpAddrTable: PMIB_IPADDRTABLE;
  StrLst: TStringList;
begin
  Lan := '';
  Internet := '';
  ServerN := '';
  //RunCallBackFunction(PChar('Перечисляем сетевые интерфейсы:'), 0);
  //IP_For_Exe := '127.0.0.1';
  res := '127.0.0.1';

  MibIpAddrTable := AllocMem(SizeOF(MIB_IPADDRTABLE));
  len := SizeOF(MIB_IPADDRTABLE);
  //FillChar(MibIpAddrTable, len, 0);

  err := GetIpAddrTable(MibIpAddrTable, len, false);
  if err = ERROR_INSUFFICIENT_BUFFER then
  begin
    // allocate larger buffer
    FreeMem(MibIpAddrTable);
    MibIpAddrTable := AllocMem(len);
    err := GetIpAddrTable(MibIpAddrTable, len, false);
  end;

  if err <> 0 then
  begin
    //при вызове ф-ции произошла ошибка
    //  RunCallBackFunction(PChar('ошибка! берем 127.0.0.1'), 0);
    //TODO: add logging here
    FreeMem(MibIpAddrTable);
    Result := res; //PChar(res);
    exit;
  end;

  //кол-во интерфейсов = MibIpAddrTable.dwNumEntries;

  StrLst := TStringList.Create;//вспомогательный список для чтения config.ini
  ChatConf := TMemIniFile.Create(ApplicationPath + 'config.ini');
  ChatConf.ReadSection('ConnectionType', StrLst);
  IP := ChatConf.ReadString('ConnectionType', 'IP', '127.0.0.1');//читаем IP сервера из 'config.ini'
  FirstOktetServerIP := copy(IP, 1, pos('.', IP) - 1);

  for n := 0 to MibIpAddrTable.dwNumEntries - 1 do
  begin
// turn off range checking for table[n] entry
{$IFOPT R+}
{$DEFINE REVERSE_R}
{$R-}
{$ENDIF}
    MyAdrr.S_addr := MibIpAddrTable.table[n].dwAddr;
{$IFDEF REVERSE_R}
{$UNDEF REVERSE_R}
{$R+}
{$ENDIF}
    IP := StrPas(inet_ntoa(MyAdrr));
  //  RunCallBackFunction(PChar('[' + inttostr(n) + '] ' + ip), 0);
    FirstOktetMyIP := copy(IP, 1, pos('.', IP) - 1);
  //  if ip = '127' then нашли Loopback интерфейс;
//    if (FirstOktetMyIP <> '127') then
//    begin
      //в перечислении выпал реальный сетефой интерфейс (не LoopBack!)
      if FirstOktetMyIP = FirstOktetServerIP then
         begin
         //нашли лакальный сетевой интерфейс, из тойже сети, что и сервер чата.
         ServerN := IP;
         break;
         end;
      if (FirstOktetMyIP = '10') or (FirstOktetMyIP = '172') or (FirstOktetMyIP = '192') then
        Lan := IP //inet_ntoa(MyAdrr)
      else
        Internet := IP; //inet_ntoa(MyAdrr);
//    end;
  end;

  if Length(LAN) > 0
    then res := LAN;

  if Length(Internet) > 0
    then res := Internet;

  if Length(ServerN) > 0
    then res := ServerN;

  //если есть в Config.ini строка LocalIP, то принудительно заменяем им
  //реальный адрес сетевого интерфейса
  if strlst.IndexOf('LocalIP') >= 0 then
    res := ChatConf.ReadString('ConnectionType', 'LocalIP', '127.0.0.1');
  StrLst.free;

  Result := res; //PChar(res);

  FreeMem(MibIpAddrTable);

  ChatConf.Free;

//RunCallBackFunction(PChar('В чате будет отображен следующий IP: ' + res), 0);
end;



{=================== TMailSlotThread ==========================}

PROCEDURE TMailSlotThread.OnTryConnect(Sender: TObject);
begin
if (ConnectingTimer <> nil) and (ClientSocket <> nil) and
  (ClientSocket.Socket.Connected = false) then
  begin
  RunCallBackFunction(PChar('[' + TimeToStr(Now) + '] Trying connect to ' +
                      ClientSocket.Address + ':' + Inttostr(ClientSocket.port)), 0);
  //нужно ли писать системное сообщение в общий чат?
  if Show_SystemMessages_Connect = true then
    RunCallBackFunction(PChar('[' + TimeToStr(Now) + '] Trying connect to ' +
                        ClientSocket.Address + ':' + Inttostr(ClientSocket.port)), 1);
  ClientSocket.Open;
  ConnectingTimer.Interval := 3000;
  end;
end;

{=========================== ClientSocketError ===========================}
procedure TMailSlotThread.ClientSocketError(Sender: TObject; Socket: TCustomWinSocket;
                                ErrorEvent: TErrorEvent; var ErrorCode: Integer);
var
  s:string;
begin
//eeGeneral
  case ErrorEvent of
    eeGeneral:
      begin
      s := 'Communication: General error (' + inttostr(ErrorCode) + ') with host ' + (ClientSocket.Address) + ':' + IntToStr(ClientSocket.Port);
      end;
    eeSend:
      begin
      s := 'Communication: Send error (' + inttostr(ErrorCode) + ') to host ' + (ClientSocket.Address) + ':' + IntToStr(ClientSocket.Port);
      end;
    eeReceive:
      begin
      s := 'Communication: Receive error (' + inttostr(ErrorCode) + ') from host ' + (ClientSocket.Address) + ':' + IntToStr(ClientSocket.Port);
      end;
    eeConnect:
      begin
      s := 'Communication: Connect error (' + inttostr(ErrorCode) + ') to host ' + (ClientSocket.Address) + ':' + IntToStr(ClientSocket.Port);
      end;
    eeDisconnect:
      begin
      s := 'Communication: Disconnect error (' + inttostr(ErrorCode) + ') to host ' + (ClientSocket.Address) + ':' + IntToStr(ClientSocket.Port);
      end;
    eeAccept:
      begin
      s := 'Communication: Accept error (' + inttostr(ErrorCode) + ') to host ' + (ClientSocket.Address) + ':' + IntToStr(ClientSocket.Port);
      end;
  end;

  RunCallBackFunction(PChar(s), 0);
  RunCallBackFunction(PChar(s), 1);
  ErrorCode := 0;
end;

{=========================== ClientSocketConnecting ===========================}
procedure TMailSlotThread.ClientSocketConnecting(Sender: TObject; Socket: TCustomWinSocket);
begin
  RunCallBackFunction(PChar('Socket Connecting... '), 0);
end;

{============================ ClientSocketConnected =============================}
procedure TMailSlotThread.ClientSocketConnected(Sender: TObject; Socket: TCustomWinSocket);
begin
  if ClientSocket.Socket.Connected = true then begin
    RunCallBackFunction(PChar('[' + TimeToStr(Now) + '] Connected with ' + inet_ntoa(ClientSocket.Socket.RemoteAddr.sin_addr) +
                            ':' + Inttostr(ntohs(ClientSocket.Socket.RemoteAddr.sin_port))), 0);
    if Show_SystemMessages_Connected = true
      then RunCallBackFunction(PChar('[' + TimeToStr(Now) + '] Connected with ' + inet_ntoa(ClientSocket.Socket.RemoteAddr.sin_addr) +
                              ':' + Inttostr(ntohs(ClientSocket.Socket.RemoteAddr.sin_port))), 1);
  end;

  if ConnectingTimer <> nil
    then ConnectingTimer.Enabled := false;

  DoConnect := false;
end;

{============================ ClientSocketDisconnect =============================}
procedure TMailSlotThread.ClientSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  if ConnectingTimer <> nil then begin
    RunCallBackFunction(PChar('[' + TimeToStr(Now) + '] Disconnect'), 0);
    RunCallBackFunction(PChar('[' + TimeToStr(Now) + '] Disconnect.'), 1);
    DoConnect := true;
    ConnectingTimer.Interval := 1;
    ConnectingTimer.Enabled := true;
  end;
end;

{============================ ClientSocketLookup =============================}
procedure TMailSlotThread.ClientSocketLookup(Sender: TObject; Socket: TCustomWinSocket);
begin
  RunCallBackFunction(PChar('Socket access...'), 0);
end;

var
  MessageManager: TProtocolMessageManager;

{=============================== ClientSocketRead =============================}
//function GetNextIncomingMessageFromTCP():PChar;
procedure TMailSlotThread.ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
var SocketReadMessLen{, IChatMessLen, NextIchatPacketSize, MaxMessSize} :cardinal;
    {LenOfFieldMessLen, LenOfFieldCommand, HeaderLen, ProcessedData :cardinal;}
//    PTemp:PChar;
//    PMem{, PSource}: Pointer;
//    STemp, SHeader:String;
{$IFDEF USELOG4D}
    logger: TlogLogger;
{$ENDIF USELOG4D}
    buffer_in: array[0..1499] of Char;
begin
  //Socket DLL'ки вызывает эту ф-цию, когда в него что-то пришло из сети
  //пришедшие данные, декодируются, если пришло несколько "слипшихся" сообщений
  //IChat разделяем их и помещаем в промежуточный буфер IncommingQueueOfMessages
  //оттуда сообщения будет забирать exe, когда ему будет угодно.
  //выставляем флаг блокировки, чтобы EXE не смог обратиться к
  //IncommingQueueOfMessages
  //пока мы наполняем его данными.
  {ThreadBlocked := true;}
  ZeroMemory(@buffer_in, SizeOf(buffer_in));
  //ZeroMemory(@crypted_in, SizeOf(crypted_in));

  //в буфере buffer_in "сырые" данные, принятые из сети.
  SocketReadMessLen := Socket.ReceiveBuf(buffer_in, SizeOf(buffer_in));
  //количество уже декодированных байт (если были несколько склееных сообщений)
  //ProcessedData := 0;

  try
    MessageManager.Parse(buffer_in, SocketReadMessLen);
  except
    on E: Exception do begin
{$IFDEF USELOG4D}
      logger := TlogLogger.GetLogger(TCPLOGGER_NAME);
      logger.Error('Error parsing network message buffer.', E);
{$ENDIF USELOG4D}
    end;
  end;

  MessageManager.Export(IncommingQueueOfMessages);

  //RunCallBackFunction(PChar('<-- FullReceivedDataSize = [' + inttostr(SocketReadMessLen) + ']'), 0);
{
repeat
//[Длина сообщения][0x00] [CMD] [0x00] [Сообщение]
// ^^^^^^^^^^^^^^^--- это длина сообщения начиная с байта, следующего за первым нулем
//[106][0][192.168.0.5/ANDREY/Andrey][FORWARD][0][!iChat!!6!!IP/KName/Login!!STATUS!!0!!erew!][66][0][....]
// ^       ^                          ^        ^                                            ^
// |       |<--------------- NextIchatMessSize ------------------------------->|            |
// |                                  |                                                     |
// |<-  HeaderLen                   ->|                                                     |
// |                                                                                        |
// |<----------------------- SocketReadMessLen -------------------------------------------->|
//



  //декодируем TCPIchat заголовок
  //[Длина сообщения]
  PTemp := @buffer_in;
  STemp := String(PTemp);

  logger.Info(STemp);

  NextIchatPacketSize := 0;
  try
    NextIchatPacketSize := StrToInt(STemp);
  except
    on E:Exception do begin
      NextIchatPacketSize := 0;
      RunCallBackFunction(PChar('TCPKRNL Exception! ' + E.ClassName + ' : ' + E.Message), 0);
    end;
  end;

  SHeader := '[' + STemp + '][$00]';
  LenOfFieldMessLen := Length(STemp);
  HeaderLen := LenOfFieldMessLen + 1;
  //пока HeaderLen это только длина поля [Длина сообщения] + [0x00]
  //RunCallBackFunction(PChar('<-- LenOfFieldMessLen = [' + Inttostr(LenOfFieldMessLen) +
  //                          ']; NextIchatPacketSize = [' + Inttostr(NextIchatPacketSize) + ']'), 0);

  if ((NextIchatPacketSize + HeaderLen) <= SocketReadMessLen) and (NextIchatPacketSize > 0) then
  begin
    //это проверка на взлом, чтобы не присылали пакет с буквами вместо длины сообщения
    //или ложной длиной сообщения
    //[Команда]
    PTemp := @buffer_in[HeaderLen];
    STemp := String(PTemp);
    SHeader := SHeader + '[' + STemp + '][$00]';
    LenOfFieldCommand := Length(STemp);
    HeaderLen := HeaderLen + LenOfFieldCommand + 1;

    //[Сообщение]
    PTemp := @buffer_in[HeaderLen];

    //Быть внимательным! IChatMessLen может стать отрицательным!
    //а точнее т.к. IChatMessLen: cardinal, то просто переполниться!!!!!
    //и там будет сверхбольшое число! Возможно прийдется сделать проверку!
    if (NextIchatPacketSize > LenOfFieldCommand + 1) then
    begin
      IChatMessLen := NextIchatPacketSize - LenOfFieldCommand - 1;

      //перемещаем защифрованное сообщение IChat в буфер crypted_in
      Move(buffer_in[HeaderLen], crypted_in, IChatMessLen);

      //очищаем временный буфер, в него поместим расшифрованное сообщение IChat
      ZeroMemory(@temp_in, SizeOf(temp_in));

      DCP_rc41.Init(key[1], length(key) * 8, nil);
      DCP_rc41.Decrypt(crypted_in, temp_in, IChatMessLen);

      //StrCopy неравнодушен к $00, воспользуемся другой ф-цией
      PMem := AllocMem(IChatMessLen);//интересненько

//Мастера DELPHI (c):
// dRake (c) (29.11.05 21:06)
//   Есть указатель, на кусок памяти, выделенной через AllocMem(), можно ли
//   узнать потом по этому указателю размер данных на которые он ссылается?
// jack128 (c) (29.11.05 21:16) [2]
//   теоретически можно, но это не документировано, поэтому не стоит так делать..
// Суслик (c) (29.11.05 21:18) [3]
//   изучай getmem.inc и читай статью mystic'а на www.delphikingom.ru
// Palladin (c) (29.11.05 21:25) [4]
//   :) ну вообще-то автор программы должен знать сколько он выделил памяти...
//   правда в современной редакции Delphi это совсем не обязательно...
//   разве что для развлекухи...
// dRake © (29.11.05 22:11) [5]
//   предполагаю что там есть что-то типа пула указателей через который
//   можно узнать сколько на каждый выделенно памяти :)
// jack128 (c) (29.11.05 22:34) [7]
//   Сейчас дельфи под рукой нету, но вроде по отрицательному смещению размер
//   блока храниться..
// dRake (c) (30.11.05 12:22) [8]
//   Гм.. а если это смещение кто нибудь затрет?
// Плохиш (c) (30.11.05 12:30) [9]
//   Тогда виноват как всегда будет Билл Гейтс и его "кривая винда", которая
//   всегда падает, потому что программист затёрший память программирует только
//   идеальные безглючные программы, а винда ... ну ... криваяяяяя....

      //вывод:
      //Билли - мученник, принявший на себя все грехи программистов :-)))
      CopyMemory(PMem, @temp_in, IChatMessLen);

      //RunCallBackFunction(PChar('<-- LenOfFieldMessLen = [' + Inttostr(LenOfFieldMessLen) +
      //                          ']; NextIchatPacketSize = [' + Inttostr(NextIchatPacketSize) +
      //                          ']; IChatMessLen = [' + inttostr(IChatMessLen) + ']'), 0);
      //RunCallBackFunction(PChar('<-- IChatMessLen = [' + inttostr(IChatMessLen) + ']'), 0);

      //    RunCallBackFunction(PChar('<--' + SHeader + string(PMem)), 0);
      //^^^^^^^^^^^ эта строчка брала лишние символы в конце строки, видимо
      //выбирала из массива до тех пор пока не встречала 0, а нуля в массиве
      //как раз и не было, поэтому она выходила за конец массива
      SetString(STemp, PChar(PMem), IChatMessLen);//так норма
      //RunCallBackFunction(PChar('<--' + SHeader + STemp), 0);

      IncommingQueueOfMessages.AddObject(inttostr(IChatMessLen), pointer(PMem));
      ProcessedData := ProcessedData + LenOfFieldMessLen + NextIchatPacketSize + 1;
    end
    else
    begin
      //NextIchatMessSize было декодировано без ошибок, но значение оказалось
      //лажой! Например отрицательное или слишком большое.
      //Прекращаем обработку!
      ProcessedData := SocketReadMessLen;
      logger.Warn('NextIchatMessSize было декодировано без ошибок, но значение оказалось' +
                  'лажой! Например отрицательное или слишком большое.' +
                  'Прекращаем обработку!');
    end;
  end
  else
  begin
    //сюда попадаем при ошибках в декодировании размера пакета!
    //скорее всего пришла какая-то лажа! Прекращаем ее обработку!
    ProcessedData := SocketReadMessLen;
    logger.Warn('сюда попадаем при ошибках в декодировании размера пакета!' +
                'скорее всего пришла какая-то лажа! Прекращаем ее обработку!');
  end;
until ProcessedData >= SocketReadMessLen; // break the loop only after all messages are processed in buffer.

}

{ThreadBlocked := false;}
end;

PROCEDURE TMailSlotThread.Execute;
{$IFDEF USELOG4D}
var
  //count:cardinal;
  logger: TlogLogger;
{$ENDIF USELOG4D}
BEGIN
  //основной цикл этой DLL. Все сообщения для отправки передаются из EXE
  //в DLL. Она записывает их в буфер и немедленно возвращает управление в EXE
  //Потом в DLL крутится отдельный поток и если в буфере что-то есть, он передает
  //эти сообщения адресатам.
  while not Terminated do
  begin
    //собственно основной цикл потока DLL
    {  count := GetIncomingMessageCountFromMailSlot();
    }
    try
      if (SendNextOutgoingMessageFromBuffer = 0) {and (count = 0)} then
        sleep(WaitForSomething)
      else
        sleep(FullWorkSpeed);
  {  if count > 0 then GetNextIncomingMessageFromMailSlot();
  }
    except
      on E: Exception do begin
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME {'dreamchat'});
        logger.Error('[TMailSlotThread.Execute]', E);
{$ENDIF USELOG4D}
      end;
    end;

  end;
END;

function SendNextOutgoingMessageFromBuffer:cardinal;
var
    writeCount, MessageLen :cardinal;
    Command, SDebug, HeaderOfProtocol, NetBiosNameOfRemoteComputer, stemp{, scrypto} :string;
    crypted_out, buffer_out, Full_buffer :array[0..1499] of Char;
//    PFullPacket: PChar;
{$IFDEF USELOG4D}
    logger: TLogLogger;
{$ENDIF USELOG4D}
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

Result := 0;

try
  CriticalSection.Enter;

  try
    if (QueueOfMessages.Count > 0) and (ClientSocket <> nil) and
       (ClientSocket.Socket.Connected = true) then
      begin
      NetBiosNameOfRemoteComputer := QueueOfRemoteComputersNames.Strings[0];
      QueueOfRemoteComputersNames.Delete(0);

      stemp := QueueOfMessages.Strings[0];
      QueueOfMessages.Delete(0);

      //устанавливаем пароль
      DCP_rc41.Init(key[1], length(key) * 8, nil);
      //берет на один байт раньше (key[0] а это длина строки key)

      //шифруем строку, получаем строку HEX кодов
      //StrCopy(@buffer_out, PChar(stemp));
      CopyMemory(@buffer_out, @stemp[1], length(stemp));

      //RunCallBackFunction(PChar(@buffer_out), 0);

      writeCount := Length(stemp);
      DCP_rc41.Encrypt(buffer_out, crypted_out, writeCount);

      //RunCallBackFunction(PChar('длина crypto к зашифровке writeCount = ' + inttostr(writeCount)), 0);

      //  if (hClientSocket <> INVALID_HANDLE_VALUE) then
      //if  then begin
        //[Длина сообщения] [0x00] [Отправитель] [0x00] [CMD] [0x00] [Получатель | "*"] [0x00] [Сообщение]
        //[][0x00][192.168.0.5/ANDREY/Andrey][0x00][FORWARD][0x00][*][0x00][.......]

        HeaderOfProtocol := LocalComputerName + #00 + 'FORWARD' + #00 + NetBiosNameOfRemoteComputer + #00;
        SDebug := '[' + LocalComputerName + '][$00][' + 'FORWARD' + '][$00][' + NetBiosNameOfRemoteComputer + '][$00]';
        MessageLen := cardinal(Length(HeaderOfProtocol)) + writeCount;
        HeaderOfProtocol := InttoStr(MessageLen) + #00 + HeaderOfProtocol;
        //SDebug := GetParam(stemp, 4, #19#19) + ' ==> [' + InttoStr(MessageLen) + '][$00]' + SDebug;
        Command := GetParamX(stemp, 3, #19#19, true);
        if (Command = 'STATUS_REQ') or (Command = 'REFRESH_BOARD') then
          begin
          SDebug := 'iTCniaM' + ' ==> [' + InttoStr(MessageLen) + '][$00]' + SDebug
          end
        else
          begin
          SDebug := GetParamX(stemp, 4, #19#19, true) + ' ==> [' + InttoStr(MessageLen) + '][$00]' + SDebug;
          end;
   //    scrypto := string(PChar(@crypted_out));
        //проблема в том, что все ф-йии работающие с null-terminated строками
        //глючат из-за нулей попадающихся начале и в середине полностью сформированного
        //сообщения! приходиться юзать string. Или копировать участки памяти самому,
        //изпользуя под буфер buffer_out, который после шифрования простаивает.
        //использовать MOVE

//RunCallBackFunction(PChar('длина заголовка = [' + inttostr(length(HeaderOfProtocol)) +
//                          ']; длина crypto = [' + inttostr(writeCount) + ']'), 0);

        MessageLen := length(HeaderOfProtocol) + WriteCount;
        SDebug := SDebug + copy(buffer_out, 0, length(stemp));

        CopyMemory(@Full_buffer, @HeaderOfProtocol[1], length(HeaderOfProtocol));
        CopyMemory(@Full_buffer[length(HeaderOfProtocol)], @crypted_out, writeCount);

       // RunCallBackFunction(PChar(SDebug), 0);

        WriteCount := ClientSocket.Socket.SendBuf(Full_buffer, MessageLen);
        SendMessCount := SendMessCount + 1;
//RunCallBackFunction(Pchar('--> SendNextOutgoingMessageFromBuffer: В Socket было записано = [' + inttostr(WriteCount) + ']'), WriteCount);
      //end

      //нельзя иначе ошибка синхронизации потоков!!!!
      //при уничтожении этого потока возникает ошибка в CallBack
      Result := QueueOfMessages.Count;
      end
    else
      begin
       //если связь удалить не удалось, а буфер для отправки уже переполнен
      if (QueueOfMessages.Count > 32700) then QueueOfMessages.Delete(0);
      end;
  except
    on E: Exception do begin
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      raise;
    end;
  end;
finally
  CriticalSection.Leave;
end;
end;

///////////////////////////////////////////////////
///  Exported functions
///////////////////////////////////////////////////

{==================== GetLocalUserLoginName Получаем логин локального юзера  ========================}
function InternalGetLocalUserLoginName(OverrideLN: PChar):PChar;
var TempBuffer:array[0..255] of Char;
    BufferSize:cardinal;
    lpUserName:PChar;
begin
  //что тут? При запуске чата из DreamChat.dpr сюда можно передавать подложный логин
  if (Length(OverrideLN) > 0) and (Length(OverrideLoginName) = 0) then begin
    //запоминаем подложный логин и при следующем вызове этой ф-ции выдаем его.
    OverrideLoginName := OverrideLN;
    Result := PChar(OverrideLoginName);
    exit;
  end;

  if Length(OverrideLoginName) > 0 then begin
    //выдаем подложный логин и при вызове этой ф-ции.
    Result := PChar(OverrideLoginName);
    exit;
  end;

  //подложный логин не установлен, поэтому запрашиваем реальный
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

function GetLocalUserLoginName(OverrideLN: PChar):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalGetLocalUserLoginName(OverrideLN);
  except
    on E: Exception do begin
      Result := '';
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{======================== GetIP =============================}
function InternalGetIP : PChar;
var
  TempBuffer:array[0..255] of Char;
  s: string;
begin
  s := GetLocalIP();
  ZeroMemory(@TempBuffer, sizeof(TempBuffer));
  MoveMemory(@TempBuffer, PChar(s), Length(s));
  Result := @TempBuffer;
end;

function GetIP():PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalGetIP();
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{======================== GetIncomingMessageCount =============================}
function InternalGetIncomingMessageCount():cardinal;
begin
  //exe вызывает эту ф-цию, чтобы узнать сколько пришло сообщений.
  //Возвращает количество пришедших сообщений, ожидающих обработки.

  //ВНИМАНИЕ!!! В ПОСЛЕДУЮЩЕМ БЫТЬ ВНИМАТЕЛЬНЕЕ С Ф-ЦИЯМИ которые вызывает
  //ехешник!!! Ошибки просходят при разрушении объектов в этих ф-циях!
  //Т.е. IncommingQueueOfMessages уже разрушен а ехешник все равно
  //вызывает ф-цию, где происходит обращение к этому объекту.

  if {(ThreadBlocked = false) and} (IncommingQueueOfMessages <> nil)
    then Result := IncommingQueueOfMessages.Count
    else Result := 0;
end;

function GetIncomingMessageCount():cardinal;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalGetIncomingMessageCount();
    except
      on E: Exception do begin
        Result := 0;
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

{=========================== GetNextIncomingMessage ===========================}
function InternalGetNextIncomingMessage(PBufferForMessage:Pointer; BufferSize:cardinal):cardinal;
var MessSize:cardinal;
begin

//exe передпет в эту ф-цию указатель на буфер, в который она должна поместить
//очередное пришедшее сообщение
//Возвращает кол-во пришедших сообщений.

  if IncommingQueueOfMessages <> nil then begin
    if {(ThreadBlocked = false) and} (IncommingQueueOfMessages.Count > 0) then begin

      //RunCallBackFunction(PChar('IncommingQueueOfMessages: ' + inttostr(IncommingQueueOfMessages.Count)), 0);
      //RunCallBackFunction(PChar(IncommingQueueOfMessages.Objects[IncommingQueueOfMessages.Count - 1]), 0);

      MessSize := StrToInt(IncommingQueueOfMessages.Strings[0]);
      if BufferSize > MessSize then begin
        CopyMemory(PBufferForMessage,  Pointer(IncommingQueueOfMessages.Objects[0]), MessSize)
      end
      else
      begin
        RunCallBackFunction(PChar('Из-за не хватки размера буфера, ' +
                    'предоставляемого EXEшником, для приема сообщения из DLL ' +
                    'следующее входящее сообщение было удалено без обработки'), 0);
        RunCallBackFunction(PChar(IncommingQueueOfMessages.Objects[0]), 0);
      end;

      //RunCallBackFunction(PChar('PBufferForMessage: '), 0);
      //RunCallBackFunction(PChar(PBufferForMessage), 0);

      //StrDispose(PChar(IncommingQueueOfMessages.Objects[0]));
      FreeMem(Pointer(IncommingQueueOfMessages.Objects[0]));
      IncommingQueueOfMessages.Delete(0);
    end
    else
    begin
      RunCallBackFunction(PChar('Thread EXE was Blocked for 1 time!: '), 0);
      //PBufferForMessage := @buffer_in;
    end;
  end;

  Result := 0;//length(PChar(IncommingQueueOfMessages.Objects[IncommingQueueOfMessages.count - 1]));
end;

function GetNextIncomingMessage(PBufferForMessage:Pointer; BufferSize:cardinal):cardinal;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalGetNextIncomingMessage(PBufferForMessage, BufferSize);
    except
      on E: Exception do begin
        Result := 0;
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

{=============== Создаем, запускаем поток и открываем мэйлслот ================}
function InternalInit(ModuleHandle: HMODULE; AdressCallBackFunction:Pointer; ExePath:Pchar):PChar;
var
 //   L:integer;
    ChatConfig: TMemIniFile;
begin
  //когда EXE запустился, он прежде чем вызвать какую-нибудь ф-цию DLL,
  //обязательно вызывает ф-цию инициализации DLL

  ApplicationPath := ExePath;
  ChatConfig := TMemIniFile.Create(ExePath + 'config.ini');

  Show_SystemMessages_Connect := ChatConfig.ReadBool('SystemMessages', 'TryingMessage', true);
  Show_SystemMessages_Connected := ChatConfig.ReadBool('SystemMessages', 'ConnectedMessage', true);

  {ThreadBlocked := false;}
  // roma hClientSocket := INVALID_HANDLE_VALUE;
  InfoForExe := '';
  FullVersion := KernelVersion;
  SendMessCount := 1;
  //key := 'tahci';//внимание! не оставлять так!!!!
  key := ChatConfig.ReadString('Crypto', 'Key', 'tahci');

  UsersCount := 0;

  {<получаем имя компа>}
  LocalComputerName := GetLocalComputerName();

  {<получаем имя юзера>}

  LocalLoginName := GetLocalUserLoginName('');

  {<получаем IP компа>}
  LocalIpAddres := GetLocalIP();
  //LocalComputerName
  //MessageBox(0, PChar(LocalIpAddres), PChar(inttostr(0)) ,mb_ok);
  //RunCallBackFunction(PChar(LocalIpAddres), 0);

  LocalComputerName := LocalIpAddres + '/' + LocalComputerName + '/' + LocalLoginName;

  if DCP_rc41 = nil then begin
    DCP_rc41 := TDCP_rc4.Create(nil);
    DCP_rc41.Init(key[1], length(key) * 8, nil);
    OpenMailSlotList := TStringlist.Create;
    OpenMailSlotList.Sorted := true;
    nMaxMessSize := SizeOf(TMessageBuf);
    QueueOfMessages := TStringList.Create;
    IncommingQueueOfMessages := TStringList.Create;
    MessageManager := TProtocolMessageManager.Create(key);
    QueueOfRemoteComputersNames := TStringList.Create;
    CriticalSection := TCriticalSection.Create;

    if MSThread = nil then begin
      MSThread := TMailSlotThread.Create(false);
      MSThread.Priority := tpIdle;
    end;

    if ClientSocket = nil then begin
      ClientSocket := TClientSocket.Create(nil);
      ClientSocket.OnError := MSThread.ClientSocketError;
      ClientSocket.OnRead := MSThread.ClientSocketRead;
      ClientSocket.OnConnect := MSThread.ClientSocketConnected;
      ClientSocket.OnConnecting := MSThread.ClientSocketConnecting;
      ClientSocket.OnDisconnect := MSThread.ClientSocketDisconnect;
      ClientSocket.OnError := MSThread.ClientSocketError;
      ClientSocket.OnLookup := MSThread.ClientSocketLookup;

//    ClientSocket.OnWrite вместо потока

      //получаем путь и имя этой DLL

      //roma commented out next 3 lines
      //L := MAX_PATH + 1;
      //SetLength(Stemp, L);
      //GetModuleFileName(ModuleHandle, pointer(Stemp), L);


      //открываем config.ini и берем адрес сервака
//    ClientSocket.Port:=7777;
//    ClientSocket.Address:='62.149.2.14';

      ClientSocket.Address := ChatConfig.ReadString('ConnectionType', 'IP', '127.0.0.1');
      ClientSocket.Port := StrToInt(ChatConfig.ReadString('ConnectionType', 'Port', '6666'));
      ClientSocket.ClientType := ctNonBlocking;
//    ClientSocket.Active := true;
      //roma hClientSocket := ClientSocket.Socket.Handle;
      MSThread.Resume;

      DoConnect := true;
      ConnectingTimer := TTimer.Create(nil);
      ConnectingTimer.OnTimer := MSThread.OnTryConnect;
      ConnectingTimer.Interval := 1;
    end;

//roma    if hClientSocket = INVALID_HANDLE_VALUE
    if ClientSocket.Socket.Handle = INVALID_HANDLE_VALUE
      then InfoForExe := 'Ошибка открытия hClientSocket1: error ' + inttostr(GetLastError());
  end
  else
  begin
    InfoForExe := InfoForExe + 'Не могу создать DCP_rc41, т.к. он уже создан!';
  end;

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

  nMaxMessSize := SizeOf(TMessageBuf);
 //возвращаем пустую строку или сообщение об ошибке!

  ChatConfig.Free;
  Result := PChar(InfoForExe);
end;

function Init(ModuleHandle: HMODULE; AdressCallBackFunction:Pointer; ExePath:PChar):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalInit(ModuleHandle, AdressCallBackFunction, ExePath);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{========== Останавливаем, освобождаем поток и закрываем мэйлслоты ============}
function InternalShutDown():PChar;
var
  n:cardinal;

begin
  //прежде чем "умереть" EXE вызывает ф-цию "убийства" DLL
  //отправляем все что в очереди на отправку!!!!
  //иначе DISCONNECT не успеет уйти!!!
  // TODO: MSThread тоже в этот момент отправляет! нужно его остановить сначала.
  while SendNextOutgoingMessageFromBuffer <> 0 do begin
    sleep(1);
  end;

  Result := 'DCP_rc41 уже давно убит! А hMailSlotWrite закрыт!';
  if DCP_rc41 <> nil then begin

    if CriticalSection <> nil
      then CriticalSection.Free;

    if ClientSocket <> nil then begin
      ClientSocket.Active := false;
      ClientSocket.Close;
      ClientSocket.Free;
    end;

    if MSThread <> nil then begin
      MSThread.Terminate;
      sleep(100);
      MSThread.Free;
      MSThread := nil;
    end;

    if ConnectingTimer <> nil then begin
      ConnectingTimer.Free;
    end;

    DCP_rc41.Free;
    DCP_rc41 := nil;

    if OpenMailSlotList <> nil then begin
      if OpenMailSlotList.Count > 0 then begin
        for n := 0 to (OpenMailSlotList.Count - 1) do begin
          if THandle(OpenMailSlotList.Objects[n]) > 0
            then CloseHandle(THandle(OpenMailSlotList.Objects[n]));
        end;
      end;
      OpenMailSlotList.Free;
    end;

    if (IncommingQueueOfMessages.Count > 0) then begin
      for n := (IncommingQueueOfMessages.Count - 1) downto 0 do begin
        //удалять только используя декремент!!!!!
//      PTemp := PChar(IncommingQueueOfMessages.Objects[n]);
//      if PTemp <> nil then StrDispose(PTemp);
        if Pointer(IncommingQueueOfMessages.Objects[n]) <> nil
          then FreeMem(Pointer(IncommingQueueOfMessages.Objects[n]));
        IncommingQueueOfMessages.Delete(n);
      end;
    end;

//MessageBox(0, PChar('IncommingQueueOfMessages free'), PChar(inttostr(0)) ,mb_ok);
    IncommingQueueOfMessages.Free;

    if (QueueOfMessages.Count > 0) then begin
      for n := (QueueOfMessages.Count - 1) downto 0 do begin
        QueueOfMessages.Delete(n);
      end;
    end;

    QueueOfMessages.Free;
//MessageBox(0, PChar('QueueOfMessages free'), PChar(inttostr(0)) ,mb_ok);
    if (QueueOfRemoteComputersNames.Count > 0) then begin
      for n := (QueueOfRemoteComputersNames.Count - 1) downto 0 do begin
        QueueOfRemoteComputersNames.Delete(n);
      end;
    end;

    QueueOfRemoteComputersNames.Free;
//MessageBox(0, PChar('QueueOfRemoteComputersNames free'), PChar(inttostr(0)) ,mb_ok);
    Result := 'DCP_rc41.Free! All objects Free !';
  end;

  MessageManager.Free;

end;

function ShutDown():PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalShutDown();
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
//      logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
//      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{=================== Посылаем команду DISCONNECT ==============================}
function InternalSendCommDisconnect(pProtoName, pNameOfLocalComputer, pNetbiosNameOfRemoteComputer, pLineName:PChar):Pchar;
var {writeCount:cardinal;}
    stemp, sLineName, sNetbiosNameOfRemoteComputer, sNameOfLocalComputer,
    sProtoName:string;
    buffer_out, crypted_out: TMessageBuf;
begin
//exe вызывает эту ф-цию когда нужно послать сообщение DISCONNECT
if DCP_rc41 <> nil then begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
  sLineName := pLineName;
  sNameOfLocalComputer := pNameOfLocalComputer;
  sProtoName := pProtoName;

  //192.168.0.5/ANDREY/Andrey
  sNameOfLocalComputer := LocalComputerName;

  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;

  if Length(sNameOfLocalComputer) = 0
    then sNameOfLocalComputer := LocalComputerName;

  // iChat  1  ANDREY  DISCONNECT  iTCniaM 
  // iChat  [Счет ASCII]  [Отправитель]  DISCONNECT  iTCniaM 

  //                  iChat               [Счет ASCII]              
  stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 +
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
//  if sNetbiosNameOfRemoteComputer = sNameOfLocalComputer then sNetbiosNameOfRemoteComputer := '.';
  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);

//  RunCallBackFunction(PChar('==> QueueOfMessages: ' + stemp), 0);

  end;
result := '';
end;

function SendCommDisconnect(pProtoName, pNameOfLocalComputer, pNetbiosNameOfRemoteComputer, pLineName:PChar):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommDisconnect(pProtoName, pNameOfLocalComputer, pNetbiosNameOfRemoteComputer, pLineName);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

{====================== Посылаем команду CONNECT ==============================}
function InternalSendCommConnect(pProtoName, pLocalNickName, pNetbiosNameOfRemoteComputer,
                         pLineName,pNameOfRemoteComputer,
                         pMessageStatusX:PChar; Status:Byte):Pchar;
var stemp, sNameOfRemoteComputer, sProtoName:string;
    sNetbiosNameOfRemoteComputer, sMessageStatusX, sLineName, LocalNickName:string;
    buffer_out, crypted_out: TMessageBuf;
begin
//exe вызывает эту ф-цию когда нужно послать сообщение CONNECT
if DCP_rc41 <> nil then begin
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

//                     iChat               [Счет ASCII]                     [Отправитель]
  stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
//                  CONNECT           iTCniaM            [Логин]         
           #19#19 + 'CONNECT' + #19#19 + sLineName + #19#19 + LocalLoginName + #19#19 +
//          [Ник]                         [Away_сооб]                       *
           LocalNickName + #19#19 + #19#19 + sMessageStatusX + #19#19 + sNameOfRemoteComputer +
//                 [Версия]               [Статус]          
            #19#19 + FullVersion + #19#19 + inttostr(status) + #19;

  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
//  RunCallBackFunction(PChar('==> QueueOfMessages: ' + stemp), 0);
  end;
result := '';
end;

function SendCommConnect(pProtoName, pLocalNickName, pNetbiosNameOfRemoteComputer,
                         pLineName,pNameOfRemoteComputer,
                         pMessageStatusX:PChar; Status:Byte):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommConnect(pProtoName, pLocalNickName, pNetbiosNameOfRemoteComputer,
                           pLineName,pNameOfRemoteComputer,
                           pMessageStatusX, Status);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

{========================= Посылаем команду TEXT ==============================}
function InternalSendCommText(pProtoName, pNetbiosNameOfRemoteComputer, pNickNameOfRemoteComputer:PChar;pMessageText:PChar; ChatLine:Pchar;Increment:integer):Pchar;
var sMessageText, stemp, sNickNameOfRemoteComputer, sNetbiosNameOfRemoteComputer,
    sProtoName, sChatLine:string;
    buffer_out, crypted_out: TMessageBuf;
begin
//exe вызывает эту ф-цию когда нужно послать сообщение TEXT
//iChat983KITTYTEXTgsMTCI устранимая проблема?Andrey
//Личное соощщение
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
//  SendMessCount := SendMessCount + cardinal(Increment);
  //чтобы в TEdit не впихнули 99999999 букв и не выскочила ошибка
    sMessageText := pMessageText;
  if length(sMessageText) >= SizeOf(buffer_out) - 100 then
    sMessageText := copy(sMessageText, 0, SizeOf(buffer_out) - 100)
  else
    sMessageText := pMessageText;
  //для личных мессаг +1, чтобы всего номер сообщения был на 2 больше предыдущего

//  messagebox(0, PChar(MailSlotWriteName), 'SendCommText: MailSlotWriteName=' ,mb_ok);

  //                   iChat              [Счет ASCII]                     [Отправитель]
  stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
  //              TEXT            iTCniaM            [Текст]       
           #19#19 + 'TEXT' + #19#19 + sChatLine + #19#19 + sMessageText + #19#19 +
   //      [НИК Получатель]                   
           sNickNameOfRemoteComputer + #19 {+ #19};

//  SendMessCount := SendMessCount + 1;
  SendMessCount := SendMessCount + cardinal(Increment);
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
//  RunCallBackFunction(PChar('==> QueueOfMessages: ' + stemp), 0);
  end;
result := '';
end;

function SendCommText(pProtoName, pNetbiosNameOfRemoteComputer, pNickNameOfRemoteComputer:PChar;pMessageText:PChar; ChatLine:Pchar;Increment:integer):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommText(pProtoName, pNetbiosNameOfRemoteComputer, pNickNameOfRemoteComputer, pMessageText, ChatLine, Increment);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

{====================== Посылаем команду STATUS ==============================}
function InternalSendCommStatus(pProtoName, pNetbiosNameOfRemoteComputer:PChar;LocalUserStatus:cardinal;StatusMessage:Pchar):Pchar;
var
  sNetbiosNameOfRemoteComputer, sProtoName, stemp:string;
  buffer_out, crypted_out: TMessageBuf;
begin
//exe вызывает эту ф-цию когда нужно послать сообщение STATUS
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

  //                   iChat              [Счет ASCII]                     [Отправитель]
  stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
  //              STATUS            [Статус]                                  
           #19#19 + 'STATUS' + #19#19 + inttostr(LocalUserStatus) + #19#19 +
   //      [Away_сооб]     
           StatusMessage + #19;
//         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ это не верно!!!

  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
//  RunCallBackFunction(PChar('==> QueueOfMessages:  ' + stemp), 0);
  end;
result := '';
end;

function SendCommStatus(pProtoName, pNetbiosNameOfRemoteComputer:PChar;LocalUserStatus:cardinal;StatusMessage:Pchar):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommStatus(pProtoName, pNetbiosNameOfRemoteComputer, LocalUserStatus, StatusMessage);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

{=================== Посылаем команду RECEIVED ==============================}
function InternalSendCommReceived(pProtoName, pNetbiosNameOfRemoteComputer:PChar;MessAboutReceived:PChar):Pchar;
var
  sProtoName, sNetbiosNameOfRemoteComputer, stemp:string;
  buffer_out, crypted_out: TMessageBuf;
begin
//exe вызывает эту ф-цию когда нужно послать сообщение RECEIVED
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));

  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sProtoName := pProtoName;

  // iChat  305  KITTY  RECEIVED  gsMTCI . Нет меня.
  // iChat  [Счет ASCII]  [Отправитель]  RECEIVED  gsMTCI  [Away_сооб]

  //                  iChat               [Счет ASCII]              
  stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 +
      //   [Отправитель]                 RECEIVED     
           LocalComputerName  +  #19#19 + 'RECEIVED'  + #19#19 +
  //       gsMTCI            [Away_сооб]         
           'gsMTCI' + #19#19 + MessAboutReceived + #19;
//           'gsMTCI' + #19#19 + ChatUsers[UserId].HelloMessage + #19;

  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
//  RunCallBackFunction(PChar('==> QueueOfMessages:  ' + stemp), 0);
  end;
result := '';
end;

function SendCommReceived(pProtoName, pNetbiosNameOfRemoteComputer:PChar;MessAboutReceived:PChar):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommReceived(pProtoName, pNetbiosNameOfRemoteComputer, MessAboutReceived);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

{=================== Посылаем команду BOARD ==============================}

function InternalSendCommBoardX(pProtoName, pNetbiosNameOfRemoteComputer:PChar;pMessageBoard:Pchar;PartMessNumber:cardinal):Pchar;
var
  sProtoName, sNetbiosNameOfRemoteComputer, stemp:string;
  buffer_out, crypted_out: TMessageBuf;
begin
//собственно сама отправка кусочков
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));

  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sProtoName := pProtoName;
  // iChat  387  VADIMUS  BOARD  0  Люди, найдите фильм плизз.
  //# iChat ## 20  ## SAMAEL  ## BOARD ## 0 ##                           #

  //                  iChat               [Счет ASCII]              
  stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 +
      //   [Отправитель]                 BOARD     
           LocalComputerName  +  #19#19 + 'BOARD'  + #19#19 +
  //       [Номер части сообщения]           [MessageBoard]         
           inttostr(PartMessNumber) + #19#19 + pMessageBoard + #19;

  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
//  RunCallBackFunction(PChar('==> QueueOfMessages:  ' + stemp), 0);
  end;
result := '';
end;

function SendCommBoardX(pProtoName, pNetbiosNameOfRemoteComputer:PChar;pMessageBoard:Pchar;PartMessNumber:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommBoardX(pProtoName, pNetbiosNameOfRemoteComputer, pMessageBoard, PartMessNumber);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

function InternalSendCommBoard(pProtoName, pNameOfRemoteComputer:PChar;pMessageBoard:Pchar;MaxSizeOfPart:cardinal):Pchar;
var n, i, partcount, LenMess, StartPart{, EndPart}:cardinal;
    strbuffer: array of char;
begin
  //exe вызывает эту ф-цию когда нужно послать сообщение BOARD
  //служит для того, чтобы раздробить длинное сообщение доски объявлений
  //на несколько мелких кусков.
  //в каком же состоянии я это писал?! Ладно, потом переделаю...
  LenMess := strlen(pMessageBoard);
  //partcount := round(LenMess/MaxSizeOfPart) - 1;
  partcount := round(LenMess/MaxSizeOfPart) + 1; //AVR: -1 is removed
  setlength(strbuffer, MaxSizeOfPart + 1);

  if LenMess > MaxSizeOfPart then begin
    for n := 0 to partcount do begin
      StartPart := n * MaxSizeOfPart;
//    EndPart := n * MaxSizeOfPart + MaxSizeOfPart;
//    if EndPart > LenMess then EndPart := LenMess;
      for i := 0 to MaxSizeOfPart - 1 do begin
        strbuffer[i] := pMessageBoard[StartPart];
        inc(StartPart);
      end;
      InternalSendCommBoardX(pProtoName, pNameOfRemoteComputer, PChar(strbuffer), n);
    end;
  end
  else
  begin
    InternalSendCommBoardX(pProtoName, pNameOfRemoteComputer, pMessageBoard, 0);
  end;

  Result := '';
end;

function SendCommBoard(pProtoName, pNameOfRemoteComputer:PChar;pMessageBoard:Pchar;MaxSizeOfPart:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommBoard(pProtoName, pNameOfRemoteComputer, pMessageBoard, MaxSizeOfPart);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;



{=================== Посылаем команду REFRESH ==============================}
function InternalSendCommRefresh(pProtoName, pNetbiosNameOfRemoteComputer, pLineName, pLocalNickName:Pchar;
                         LocalUserStatus:cardinal;pAwayMess:Pchar;
                         pReceiver:Pchar;Increment:integer):Pchar;
var sReceiver, sNetbiosNameOfRemoteComputer, sTemp, sAwayMess,
    sProtoName, sLocalNickName, sLineName:string;
    buffer_out, crypted_out: TMessageBuf;
begin
//exe вызывает эту ф-цию когда нужно послать сообщение REFRESH
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

    //                   iChat              [Счет ASCII]                     [Отправитель]
    stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
    //              REFRESH            iTCniaM            [Логин]         
             #19#19 + 'REFRESH' + #19#19 + sLineName + #19#19 + LocalLoginName + #19#19 +
    //       [Ник]                         [Away_сооб]           *      
             sLocalNickName + #19#19 + #19#19 + sAwayMess   + #19#19 + sReceiver + #19#19 +
    //       [Версия]             [Статус]                     
             FullVersion + #19#19 + inttostr(LocalUserStatus) + #19;

  SendMessCount := SendMessCount + cardinal(Increment);
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
//  RunCallBackFunction(PChar('==> QueueOfMessages:  ' + stemp), 0);
  end;
result := '';
end;

function SendCommRefresh(pProtoName, pNetbiosNameOfRemoteComputer, pLineName, pLocalNickName:Pchar;
                         LocalUserStatus:cardinal;pAwayMess:Pchar;
                         pReceiver:Pchar;Increment:integer):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommRefresh(pProtoName, pNetbiosNameOfRemoteComputer, pLineName, pLocalNickName, LocalUserStatus, pAwayMess, pReceiver, Increment);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

{===================   Посылаем команду RENAME   ==============================}
function InternalSendCommRename(pProtoName, pNetbiosNameOfRemoteComputer:Pchar;pNewNickName:Pchar):Pchar;
var
  sProtoName, sNetbiosNameOfRemoteComputer, sTemp, sNewNickName:string;
  buffer_out, crypted_out: TMessageBuf;
begin
//exe вызывает эту ф-цию когда нужно послать сообщение RENAME
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
  sNewNickName := pNewNickName;
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sProtoName := pProtoName;

  //для смены имени посылается, отвечать на него не надо:
  //iChat287KITTYRENAMEKITTY

    //                   iChat              [Счет ASCII]                     [Отправитель]
    stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
    //              RENAME            NewNickName     
             #19#19 + 'RENAME' + #19#19 + sNewNickName + #19;

  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
//  RunCallBackFunction(PChar('==> QueueOfMessages:  ' + stemp), 0);
  end;
result := '';
end;

function SendCommRename(pProtoName, pNetbiosNameOfRemoteComputer:Pchar;pNewNickName:Pchar):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommRename(pProtoName, pNetbiosNameOfRemoteComputer, pNewNickName);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;

end;

{===================   Посылаем команду CREATE   ==============================}
function InternalSendCommCreate(pProtoName, pNetbiosNameOfRemoteComputer, pPrivateChatLineName:Pchar):Pchar;
var
  sProtoName, sTemp, sNetbiosNameOfRemoteComputer, sPrivateChatLineName:string;
  buffer_out, crypted_out: TMessageBuf;
begin
//exe вызывает эту ф-цию когда нужно послать сообщение CREATE
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

    //                   iChat              [Счет ASCII]                     [Отправитель]
    stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
    //               CREATE           [Имя приватного чата]                  [Получатель]                 
             #19#19 + 'CREATE' + #19#19 + sPrivateChatLineName + #19#19 + #19#19 + sNetbiosNameOfRemoteComputer + #19;

  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
//  RunCallBackFunction(PChar('==> QueueOfMessages:  ' + stemp), 0);
  end;
result := '';
end;

function SendCommCreate(pProtoName, pNetbiosNameOfRemoteComputer, pPrivateChatLineName:Pchar):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommCreate(pProtoName, pNetbiosNameOfRemoteComputer, pPrivateChatLineName);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

{=================   Посылаем команду CREATELINE   ============================}
function InternalSendCommCreateLine(pProtoName, pNetbiosNameOfRemoteComputer, pPrivateChatLineName, Password:Pchar):Pchar;
var
  sProtoName, sTemp, sNetbiosNameOfRemoteComputer, sPrivateChatLineName, sPassword:string;
  buffer_out, crypted_out: TMessageBuf;
begin
//iChat613192.168.1.4/ANDREY/UserCREATE_LINEНовая линия        192.168.1.4/ANDREY/User
//                                                   [Имя линии]  [Пароль]  [Отправитель]
//exe вызывает эту ф-цию когда нужно послать сообщение CREATE
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
  sPrivateChatLineName := pPrivateChatLineName;
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sPassword := Password;
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

    //                   iChat              [Счет ASCII]                     [Отправитель]
    stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
    //               CREATE           [Имя приватного чата]         [Пароль]            [Получатель]                   
             #19#19 + 'CREATE_LINE' + #19#19 + sPrivateChatLineName + #19#19 + sPassword + #19#19 + sNetbiosNameOfRemoteComputer + #19;

  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
//  RunCallBackFunction(PChar('==> QueueOfMessages:  ' + stemp), 0);
  end;
result := '';
end;

function SendCommCreateLine(pProtoName, pNetbiosNameOfRemoteComputer, pPrivateChatLineName, Password:Pchar):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommCreateLine(pProtoName, pNetbiosNameOfRemoteComputer, pPrivateChatLineName, Password);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;


{===============   Посылаем команду SendCommStatus_Req   ======================}
function InternalSendCommStatus_Req(pProtoName, pNetbiosNameOfRemoteComputer:PChar):Pchar;
var
  sNetbiosNameOfRemoteComputer, sProtoName, stemp:string;
  buffer_out, crypted_out: TMessageBuf;
begin
//exe вызывает эту ф-цию когда нужно послать сообщение STATUS
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));

//  MailSlotWriteName := '\\*\Mailslot\ICHAT047';
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sProtoName := pProtoName;

  //iChat418SATANASTATUS_REQ
  //                   iChat              [Счет ASCII]                     [Отправитель]
  stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
  //              STATUS_REQ      
           #19#19 + 'STATUS_REQ' + #19;

  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
//  RunCallBackFunction(PChar('==> QueueOfMessages:  ' + stemp), 0);
  end;
result := '';
end;

function SendCommStatus_Req(pProtoName, pNetbiosNameOfRemoteComputer:PChar):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommStatus_Req(pProtoName, pNetbiosNameOfRemoteComputer);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;


{===============   Посылаем команду SendCommMe   ======================}
function InternalSendCommMe(pProtoName, pNetbiosNameOfRemoteComputer, pNickNameOfRemoteComputer:PChar;pMessageText:PChar; ChatLine:Pchar;Increment:integer):Pchar;
var
  sMessageText, stemp, sNickNameOfRemoteComputer, sNetbiosNameOfRemoteComputer, sProtoName, sChatLine:string;
  buffer_out, crypted_out: TMessageBuf;
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
  end;
result := '';
end;

function SendCommMe(pProtoName, pNetbiosNameOfRemoteComputer, pNickNameOfRemoteComputer:PChar;pMessageText:PChar; ChatLine:Pchar;Increment:integer):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommMe(pProtoName, pNetbiosNameOfRemoteComputer, pNickNameOfRemoteComputer, pMessageText, ChatLine, Increment);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;


{==============   Посылаем команду SendCommBoard_Refresh   ====================}
function InternalSendCommRefresh_Board(pProtoName, pNetbiosNameOfRemoteComputer: PChar; Increment:integer):Pchar;
var {sMessageText,} stemp, sNetbiosNameOfRemoteComputer,
    sProtoName:string;
    buffer_out, crypted_out: TMessageBuf;
begin
//Запрос доски
//iChat[0x13][0x13]%d[0x13][0x13]192.168.1.4/ANDREY/User[0x13][0x13]REFRESH_BOARD
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
  sProtoName := pProtoName;
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  //для личных мессаг +1, чтобы всего номер сообщения был на 2 больше предыдущего

  //                   iChat              [Счет ASCII]                     [Отправитель]
  stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
  //              REFRESH_BOARD      
           #19#19 + 'REFRESH_BOARD' + #19;

  SendMessCount := SendMessCount + cardinal(Increment);
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
  //RunCallBackFunction(PChar('==> QueueOfMessages:  ' + stemp), 0);
  end;
result := '';
end;

function SendCommRefresh_Board(pProtoName, pNetbiosNameOfRemoteComputer: PChar; Increment:integer):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommRefresh_Board(pProtoName, pNetbiosNameOfRemoteComputer, Increment);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
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

var
{$IFDEF USELOG4D}
  logger: TlogLogger;
{$ENDIF USELOG4D}
  SavedDllProc: TDLLProc = nil;

procedure LibExit(Reason: Integer);
begin
{$IFDEF USELOG4D}
  if Reason = DLL_PROCESS_DETACH then begin
    logger.Info('--------------------------------------------------------');
    logger.Info('-----------------------   FINISH   ---------------------');
    logger.Info('--------------------------------------------------------');
  end;
{$ENDIF USELOG4D}

  if Assigned(SavedDllProc)
    then SavedDllProc(Reason);  // call saved entry point procedure
end;

begin
  IsMultiThread := True;

{$IFDEF USELOG4D}
  FillChar(DllName, sizeof(DllName), #0);
  GetModuleFileName(SysInit.hInstance, DllName, sizeof(DllName));
  //ApplicationPath:=DllName;
  ApplicationPath := ExtractFilePath(DllName);

  // initialize log4d
  TLogPropertyConfigurator.Configure(ApplicationPath + 'tcpkrnl.props');

  logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
  logger.Info('--------------------------------------------------------');
  logger.Info('------------------------   START   ---------------------');
  logger.Info('--------------------------------------------------------');

  SavedDllProc := DllProc;  // save exit procedure chain
  DllProc := @LibExit;  // install LibExit exit procedure
{$ENDIF USELOG4D}
end.


