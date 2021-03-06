unit uProtocolMessage;

interface

uses
  Classes, Windows, SysUtils, DynamicArrays, uCommonUnitObj;

type

 TProtocolMessage = class
 private
//   FOwner: TObject;
   FPacketSize: cardinal;
   FCommand: string;
   FCryptedText: string;
   FPlainText: string;
   FDefaultKey: string;

   function CheckBufAvail(buffer: PChar; bufferSize: cardinal): boolean;
 public
//   constructor Create(Owner: TObject; DefaultKey: string);
   constructor Create(DefaultKey: string);
   function ParseBuffer(buffer:PChar; bufferSize:cardinal): cardinal; // size is used for buffer overflow checking
   function GetFormattedMessage(): string; overload;
   function GetAsBuffer(): PChar;
   class function GetFormattedMessage(buffer:PChar; bufferSize:cardinal):string; overload;
   class function GetMessage(Key: string; buffer:PChar; bufferSize:cardinal): TProtocolMessage;

   // properties
   property PacketSize: cardinal read FPacketSize;
   property Command: string read FCommand;
   property CryptedText: string read FCryptedText;
   property PlainText: string read FPlainText;
   property DefaultKey: string read FDefaultKey write FDefaultKey;
 end;

  TProtocolMessageManager = class
  private
    FMessages: TList;
    FDefaultKey: string;
    FLeftBuffer: THArrayByte;
    procedure InternalParse(buffer:PChar; bufferSize:cardinal);
    procedure ClearMessages();
  public
    constructor Create(Key: string);
    destructor Destroy(); override;
    procedure Parse(buffer:PChar; bufferSize:cardinal);
    procedure Export(MessageQueue: TStringList);
    property DefaultKey: string read FDefaultKey write FDefaultKey;
  end;

  EIncorrectData = class(EConvertError);

implementation

uses
  DCPcrypt2, DCPrc4,
  {$IFDEF USELOG4D}
  log4d,
  {$ENDIF USELOG4D}
  DreamChatExceptions;


{ TProtocolMessage }

// check if buffer is large enough for holding string representation of size of message
function TProtocolMessage.CheckBufAvail(buffer: PChar; bufferSize: cardinal): boolean;
var
  index: cardinal;
begin
  Result := False;
  if (buffer = nil) or (bufferSize = 0)
    then exit;

  // empty buffers are also not allowed
  if buffer[0] = #0
    then exit;

  index := 0;

  repeat

    if(buffer[index] = #0) then
    begin
      // buffer is enough, return true
      Result := True;
      exit;
    end;

    inc(index);
  until index >= bufferSize;

  // by default it is considered that buffer is not enough and False will be returned
end;

constructor TProtocolMessage.Create({Owner: TObject;} DefaultKey: string);
begin
  FPacketSize := 0;

  if Length(DefaultKey) = 0
    then raise DreamChatTechnicalException.Create('Key is empty.');
  FDefaultKey := DefaultKey;
end;

function TProtocolMessage.GetFormattedMessage: string;
begin
  Result := Format('[%d][$00][%s][$00][%s]', [FPacketSize, FCommand, FCryptedText]);
end;

function TProtocolMessage.GetAsBuffer: PChar;
begin
  Result := AllocMem(Length(FPlainText));
  CopyMemory(Result, PChar(FPlainText), Length(FPlainText));
end;

class function TProtocolMessage.GetFormattedMessage(buffer: PChar; bufferSize: cardinal): string;
var
  mess: TProtocolMessage;
begin
//  mess := TProtocolMessage.Create(nil, '0'); // TODO: KEY absent!
  mess := TProtocolMessage.Create('0'); // TODO: KEY absent!
  try
    mess.ParseBuffer(buffer, bufferSize);
    Result := mess.GetFormattedMessage();
  finally
    mess.Free;
  end;
end;

class function TProtocolMessage.GetMessage(Key: string; buffer: PChar; bufferSize: cardinal): TProtocolMessage;
begin
//  Result := TProtocolMessage.Create(nil, Key);
  Result := TProtocolMessage.Create(Key);
  Result.ParseBuffer(buffer, bufferSize);
end;

// parses one message from a buffer
// buffer may contain more than one message, second, etc messages are not parsed
// returns index of first character of next message in buffer
function TProtocolMessage.ParseBuffer(buffer: PChar; bufferSize: cardinal): cardinal;
var
  IChatPacketSize: cardinal;
  CommandOffset: cardinal;
  DataOffset: cardinal;
  LenOfFieldMessLen: cardinal;
  LenOfFieldCommand: cardinal;
  IChatDataLen: cardinal;
  PacketSizeStr: string;
  Command: string;
  PPlainText, PCryptedText: PChar;
  DCP_rc41 :TDCP_rc4;
  UncryptoKey: string;
  i: integer;
begin
  if (buffer = nil) or (bufferSize = 0)
    then raise EConvertError.Create('Message buffer is NULL.');

  // check if buffer is large enough to hold size of received message and trailing zero
  if not CheckBufAvail(buffer, bufferSize)
    then raise EConvertError.Create('Incorrect data in message buffer received. Packet size is incorrect.');

  // size of entire message as int
  PacketSizeStr := StrPas(buffer);
  IChatPacketSize := StrToInt(PacketSizeStr);

  if IChatPacketSize = 0
    then raise EIncorrectData.Create('Incorrect data in message buffer received. Packet size is zero.');

  LenOfFieldMessLen := Length(PacketSizeStr);
  CommandOffset := LenOfFieldMessLen + 1; // offset in buffer for command

  // ��� �������� �� �����, ����� �� ��������� ����� ��� ������ ������ ���������
  // TODO: ��� �� �������� ������ ��������� ������� � �� ������ � �����.
  if ((IChatPacketSize + CommandOffset) > bufferSize)
    then raise EConvertError.Create('Incorrect data in message buffer received. Packet size is incorrect.');

  // check if buffer is large enough to hold command and trailing zero
  // command cannot be empty and must contain at least one symbol
  if not CheckBufAvail(@buffer[CommandOffset], bufferSize - CommandOffset)
    then raise EConvertError.Create('Incorrect data in message buffer received. ' +
      'Empty command detected.');

  Command := StrPas(@buffer[CommandOffset]);
  LenOfFieldCommand := Length(Command);
  DataOffset := CommandOffset + LenOfFieldCommand + 1;

  // IChatPacketSize ��������� � ������� ������� ������� � �� ������� ������� ������.
  // ������� ��������� ��� �������� ������ ������ �� ������ ����� ������� + 1
  if (IChatPacketSize < LenOfFieldCommand + 1)
    then raise EIncorrectData.Create('Incorrect data in message buffer received. Packet size is too small.');

  // check if buffer is large enough to hold message data and trailing zero
  // message data cannot be empty and must contain at least one symbol
  //if not CheckBufAvail(@buffer[DataOffset], bufferSize - DataOffset)
//    then raise EConvertError.Create('Incorrect data in message buffer received. Empty message data detected.');

  // ��������� ������ ������ (������ ���������)
  IChatDataLen := IChatPacketSize - LenOfFieldCommand - 1;

  if IChatDataLen = 0
    then raise EIncorrectData.Create('Incorrect data in message buffer received. Message size is zero.');

  if(DataOffset + IChatDataLen > bufferSize)
    then raise EConvertError.Create('Incorrect data in message buffer received. Packet size exceeds buffer size.');

  // all sems ok, assign actual values to fields
  FPacketSize := IChatPacketSize;
  FCommand := Command;
  //���������� ������������� ��������� IChat � ������ FCryptedText
  SetString(FCryptedText, PChar(@(buffer[DataOffset])), Integer(IChatDataLen));

  // create string filled by zeros
  FPlainText := StringOfChar(#0, Length(FCryptedText)); // TODO: ������ ��������� �������� ��� ����������� ��� ���?

  PPlainText := PChar(FPlainText);
  PCryptedText := PChar(FCryptedText);
  DCP_rc41 := TDCP_rc4.Create(nil);
  try
    UncryptoKey := FDefaultKey;
{
�������� � ���������: ���� �� ����� ������������ ������������ ����� ���� ����� �� ���� ������ ���������
      if (CryptoKeyForRemoteComputers.Count > 0) then
        begin
        i := CryptoKeyForRemoteComputers.IndexOf(sNetBiosNameOfRemoteComputer);
        end;
      if i >= 0 then
        begin
        //������������� ������������ ��������� ���� ����������
        pPersonalCrypto := pPersonalCrypto(CryptoKeyForRemoteComputers.Objects[i]);
        UncryptoKey := pPersonalCrypto.
        end;
}
    DCP_rc41.Init(UncryptoKey[1], Length(UncryptoKey) * 8, nil);
    DCP_rc41.Decrypt(PCryptedText^, PPlainText^, IChatDataLen);
  finally
    DCP_rc41.Free;
  end;

  Result := DataOffset + IChatDataLen;
end;

{ TProtocolMessageManager }

constructor TProtocolMessageManager.Create(Key: string);
begin
  FMessages := TList.Create;
  FDefaultKey := Key;
  FLeftBuffer := THArrayByte.Create();
end;

destructor TProtocolMessageManager.Destroy;
begin
  FMessages.Free;
  FLeftBuffer.Free;
  inherited Destroy;
end;

procedure TProtocolMessageManager.Parse(buffer: PChar; bufferSize: cardinal);
var
  mergedBuffer: THArrayByte;
begin
  if FLeftBuffer.Count > 0 then
  begin
    mergedBuffer := THArrayByte.Create;
    try
      mergedBuffer.AddMany(FLeftBuffer.Memory, FLeftBuffer.Count);
      mergedBuffer.AddMany(buffer, bufferSize);
      FLeftBuffer.Clear;
      InternalParse(mergedBuffer.Memory, mergedBuffer.Count);
    finally
      mergedBuffer.Free;
    end;
  end
  else
  begin
    InternalParse(buffer, bufferSize);
  end;
end;

// buffer: PChar is merged buffer with remained from last Parse() call
procedure TProtocolMessageManager.InternalParse(buffer: PChar; bufferSize: cardinal);
var
  currMessageIndex: cardinal;
  mess: TProtocolMessage;
  {$IFDEF USELOG4D}
  logger: TlogLogger;
  {$ENDIF USELOG4D}
begin
  currMessageIndex := 0;

  try
    ClearMessages;

    while currMessageIndex < bufferSize do begin
      mess := TProtocolMessage.Create(FDefaultKey);
      //ParseBuffer return index related to buffer buffer[currMessageIndex].
      // Therefore we add this index to previous one to get correct index regarding to initial buffer
      currMessageIndex := currMessageIndex + mess.ParseBuffer(@buffer[currMessageIndex], bufferSize - currMessageIndex);
      FMessages.Add(mess);
    end;

  except
    on E: EIncorrectData do begin
     // exception means that last message is partially included in buffer or we have
      // at least one incorrect message in buffer
      {$IFDEF USELOG4D}
      logger := TlogLogger.GetLogger('tcpkrnl');
      logger.Info('Error parsing message.', E);
      {$ENDIF USELOG4D}
    end;

    on E: EConvertError do begin
      // it seems that partail message left in buffer, remember this buffer and appent to next piece of data received from network.
      FLeftBuffer.Clear;
      // move rest of symbols to buffer for future parsing
      FLeftBuffer.AddMany(@buffer[currMessageIndex], bufferSize - currMessageIndex);
    end;
  end;

end;

procedure TProtocolMessageManager.Export(MessageQueue: TStringList);
var
  i: integer;
begin
  for i := 0 to FMessages.Count - 1 do
  begin
    MessageQueue.AddObject(IntToStr(Length(TProtocolMessage(FMessages[i]).FPlainText)), Pointer(TProtocolMessage(FMessages[i]).GetAsBuffer()));
  end;

  ClearMessages;
end;

procedure TProtocolMessageManager.ClearMessages;
var
  i: integer;
begin
  for i := 0 to FMessages.Count - 1 do
    TProtocolMessage(FMessages[i]).Free;

  FMessages.Clear;
end;

end.
