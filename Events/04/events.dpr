//Текст этой DLL распространяется в том виде КАК ЕСТЬ (AS IS)
//Никакой ответственности за последствия его работы автор не несет.
//У меня он компилиться в среде DELPHI 5

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

library events;

uses
{$IFDEF USEFASTSHAREMEM}
  FastShareMem,
{$ENDIF}
  Windows,
  mmsystem,
  SysUtils,
  //SysInit,
  Classes,
  Inifiles,
{$IFDEF USELOG4D}
  log4d,
{$ENDIF USELOG4D}
  Messages;

const
  LINE_TYPE_COMMON = 0;
  LINE_TYPE_PRIVATE_CHAT = 1;
  LINE_TYPE_COMMON_LINE = 2;
  DllVersion = 'E03';//E = Events

{$IFDEF USELOG4D}
    // name of logger (configured in tcpkrnl.prop)
  EVLOGGER_NAME = 'events';
{$ENDIF USELOG4D}

type TCallBackFunction = function(Buffer:Pchar; MessCountInBuffer:cardinal):PChar;

var
  sExePath                      :string;
  RunCallBackFunction           :TCallBackFunction;
  debug                         :boolean;

{=============== Создаем, запускаем поток и открываем мэйлслот ================}

// returns error message string in case of error.
// if no error then empty string should be returned.
function InternalEvInit(AdressCallBackFunction:Pointer; pExePath:PChar):PChar;
var
    ChatConfig: TMemIniFile;
begin
  // ensure that path ends on path delimiter
  sExePath := ExcludeTrailingPathDelimiter(pExePath);

  debug := true;//false;

  ChatConfig := TMemIniFile.Create(sExePath + 'sound.ini');

  if ChatConfig.ReadBool('SystemMessages', 'SoundDebug', false) = true
    then debug := true;

  ChatConfig.Free;

  RunCallBackFunction := AdressCallBackFunction;

//******************************************************************************
//* Запоминаем адрес функции обратного вызова, что потом ее вызывать.          *
//* Раньше она нужна была для других целей, а теперь служит для вывода лога в  *
//* окно отладки. Ее реализация в EXE выглядит следующим образом:              *
//
//* FUNCTION CallBackFunction(Buffer:Pchar; MessCountInBuffer:cardinal):PChar; *
//* BEGIN                                                                      *
//*   {DLL может вызвать эту функцию когда ей захочется}                       *
//* Form2.Memo2.Lines.Add(Buffer);                                             *
//* sglob := 'CallBackFunction: Меня только что вызвала DLL!';                 *
//* result := @sglob[1];                                                       *
//* END;                                                                       *
//******************************************************************************
//Если не понятно, то подробнее:
//в DLL в основном храняться функции, которые вызывает ЕХЕ, когда это нужно EXE.
//Однако DLL тоже нужно обмениваться инфой с EXE и передавать ее в
//произвольный момент времени, не дожидаясь когда EXE вызовет одну из ее
//функций. Для этого и придуман механизм обратного вызова. Соответственно
//EXE сообщает DLL адрес своей функции/метода, который можно вызвать в
//произвольный момент времени, DLL его запоминает и спокойно вызывает.
//Правда в данной реализации, если будет добавлен поток, нужно будет
//делать безопасный вызов! Т.к. в CallBackFunction происходит работа с
//компонентом.

  //возвращаем пустую строку если нету ошибки, иначе сообщение об ошибке!
  Result := ''; //roma PChar(InfoForExe);
end;

function EvInit(AdressCallBackFunction:Pointer; pExePath:PChar):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvInit(AdressCallBackFunction, pExePath);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{========== Останавливаем, освобождаем поток и закрываем мэйлслоты ============}
function EvShutDown():PChar;
//{$IFDEF USELOG4D}
//var
//  logger: TlogLogger;
//{$ENDIF USELOG4D}
begin
//{$IFDEF USELOG4D}
//  logger := TLogLogger.GetLogger(EVLOGGER_NAME);
//  logger.Info('------------------------   FINISH   ---------------------');
//{$ENDIF USELOG4D}

  Result := 'ShutDown of ' + DllVersion + ' OK!';
end;

{=================== Посылаем команду DISCONNECT ==============================}
function InternalEvOnCommDisconnect(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var
  s:string;
begin
// iChat  1  ANDREY  DISCONNECT  iTCniaM 
// iChat  [Счет ASCII]  [Отправитель]  DISCONNECT  iTCniaM 
//s := ChatConfig.ReadString('sound', 'Disconnect', '');
//if (length(s) > 0) and (s[1] = '\') then s := sExePath + s;

  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommDisconnect: ' + s), 0);
end;

function EvOnCommDisconnect(LineType: integer; pReceivedMessage, PlayFile:PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommDisconnect(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{====================== Посылаем команду CONNECT ==============================}
function InternalEvOnCommConnect(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var
  s:string;
begin
//iChat2ANDREYCONNECTiTCniaMAdminsAndreyПриветствую!*1.21b60
//s := ChatConfig.ReadString('sound', 'Connect', '');
  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommConnect: ' + s), 0);
end;

function EvOnCommConnect(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommConnect(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{========================= Посылаем команду TEXT ==============================}
function InternalEvOnCommText(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var s:string;
begin
//iChat983KITTYTEXTgsMTCI устранимая проблема?Andrey
//Личное соощщение
  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommText: ' + s), 0);
end;

function EvOnCommText(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommText(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{====================== Посылаем команду STATUS ==============================}
function InternalEvOnCommStatus(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var s:string;
begin
  //iChat  24           KITTY          STATUS  3         Katushka получает... сообщение :gigi:
  //iChat  642          ALF            STATUS  3         Меня нет.   
  //iChat [Счет ASCII]  [Отправитель]  STATUS  [Статус]  [Away_сооб] 
  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommStatus: ' + s), 0);
end;

function EvOnCommStatus(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommStatus(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;


{=================== Посылаем команду RECEIVED ==============================}
function InternalEvOnCommReceived(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var s:string;
begin
  // iChat  305  KITTY  RECEIVED  gsMTCI . Нет меня.
  // iChat  [Счет ASCII]  [Отправитель]  RECEIVED  gsMTCI  [Away_сооб]
  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommReceived: ' + s), 0);
end;

function EvOnCommReceived(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommReceived(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{=================== Посылаем команду BOARD ==============================}
function InternalEvOnCommBoard(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var s:string;
begin
  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommBoard: ' + s), 0);
end;

function EvOnCommBoard(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommBoard(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{=================== Посылаем команду REFRESH ==============================}
function InternalEvOnCommRefresh(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var s:string;
begin
  //iChat137ANDREYREFRESHiTCniaMAdminsAndreyПриветствую!*1.21b63
  //iChat137ANDREYREFRESHiTCniaMAdminsAndreyПриветствую!*1.21b63
  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommRefresh: ' + s), 0);
end;

function EvOnCommRefresh(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommRefresh(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{===================   Посылаем команду RENAME   ==============================}
function InternalEvOnCommRename(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var
  s:string;
begin
  //iChat287KITTYRENAMEKITTY
  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommRename: ' + s), 0);
end;

function EvOnCommRename(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommRename(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{===================   Посылаем команду CREATE   ==============================}
function InternalEvOnCommCreate(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var
  s:string;
begin
  //со мной создают личный чат:
  //мне приходит: создан ПУСТОЙ личный чат
  //iChat527KITTYCREATE856000ANDREY

  //я посылаю: я захожу в него
  //iChat28ANDREYCONNECT856000AdminsAndreyПриветствую!*1.3b30

  //мне приходит: ANDREY ваш вход подтверждаю
  //iChat531KITTYCONNECT856000Katushkakatчshka:hello:ANDREY1.3b30

  //я посылаю: KITTY ваш вход подтверждаю
  //iChat30ANDREYCONNECT856000AdminsAndreyПриветствую!KITTY1.3b30

  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommCreate: ' + s), 0);
end;

function EvOnCommCreate(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommCreate(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{==========================   Личное сообщение   ==============================}
function InternalEvOnCommAlert(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var
  s:string;
begin
  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommAlert: ' + s), 0);
end;

function EvOnCommAlert(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommAlert(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{===================   Массовое личное сообщение   ============================}
function InternalEvOnCommAlertToAll(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var
  s:string;
begin
  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommAlertToAll: ' + s), 0);
end;

function EvOnCommAlertToAll(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommAlertToAll(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{===================   Найдена новая линия   ============================}
function InternalEvOnCommFindLine(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var
  s:string;
begin
  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommFindLine: ' + s), 0);
end;

function EvOnCommFindLine(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommFindLine(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

exports
  EvInit index 1 name 'EvInit',
  EvShutDown index 2 name 'EvShutDown',
  EvOnCommDisconnect index 3 name 'EvOnCommDisconnect',
  EvOnCommConnect index 4 name 'EvOnCommConnect',
  EvOnCommText index 5 name 'EvOnCommText',
  EvOnCommReceived index 6 name 'EvOnCommReceived',
  EvOnCommStatus index 7 name 'EvOnCommStatus',
  EvOnCommBoard index 8 name 'EvOnCommBoard',
  EvOnCommRefresh index 9 name 'EvOnCommRefresh',
  EvOnCommRename index 10 name 'EvOnCommRename',
  EvOnCommCreate index 11 name 'EvOnCommCreate',
  EvOnCommAlert index 12 name 'EvOnCommAlert',
  EvOnCommAlertToAll index 13 name 'EvOnCommAlertToAll',
  EvOnCommFindLine index 14 name 'EvOnCommFindLine';

var
{$IFDEF USELOG4D}
  logger: TlogLogger;
  DllName                       :array[0..MAX_PATH] of char;
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
{$IFDEF USELOG4D}
  FillChar(DllName, sizeof(DllName), #0);
  GetModuleFileName(SysInit.hInstance, DllName, sizeof(DllName));
  //sExePath:=DllName;
  sExePath := ExtractFilePath(DllName);

  // initialize log4d
  TLogPropertyConfigurator.Configure(sExePath+'events.props');

  logger := TLogLogger.GetLogger(EVLOGGER_NAME);
  logger.Info('--------------------------------------------------------');
  logger.Info('------------------------   START   ---------------------');
  logger.Info('--------------------------------------------------------');

  SavedDllProc := DllProc;  // save exit procedure chain
  DllProc := @LibExit;  // install LibExit exit procedure
{$ENDIF USELOG4D}
end.


