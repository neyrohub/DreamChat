//Autor Bajenov Andrey
//All right reserved.
//Saint-Petersburg, Russia
//2007.02.03
//neyro@mail.ru

//DreamChat is published under a double license. You can choose which one fits
//better for you, either Mozilla Public License (MPL) or Lesser General Public
//License (LGPL). For more info about MPL read the MPL homepage. For more info
//about LGPL read the LGPL homepage.

unit DChatCommPlugin;

interface

uses
  Windows, Messages, SysUtils, Classes, DChatPlugin;

type
  TLoadErrorEvent = procedure(Sender: TObject; ErrorMess: string) of object;

type
  TInitFunction = function (ModuleHandle: HMODULE; pCallBackFunction:pointer; ExePath:PChar):PChar;
  TShutDownFunction = function ():PChar;
  TSendCommDisconnect = function (pProtoName, pNameOfLocalComputer, pNameOfRemoteComputer, pLineName:PChar):Pchar;
  TSendCommConnect = function (pProtoName, pLocalNickName, pNetbiosNameOfRemoteComputer,
                         pLineName,pNameOfRemoteComputer,
                         pMessageStatusX:PChar; Status:Byte):Pchar;
  TSendCommText = function (pProtoName, pNameOfRemoteComputer:PChar;pNickNameOfRemoteComputer:PChar;MessageText:PChar; ChatLine:Pchar;Increment:integer):Pchar;
  TSendCommReceived = function (pProtoName, pNameOfRemoteComputer:PChar;MessAboutReceived:PChar):Pchar;
  TSendCommStatus = function (pProtoName, pNameOfRemoteComputer:PChar;LocalUserStatus:cardinal;StatusMessage:Pchar):Pchar;
  TSendCommBoard = function (pProtoName, pNameOfRemoteComputer:PChar;pMessageBoard:Pchar;MaxSizeOfPart:cardinal):Pchar;
  TSendCommRefresh = function (pProtoName, pNameOfRemoteComputer, pLineName, pLocalNickName:Pchar;LocalUserStatus:cardinal;pAwayMess:Pchar;pReceiver:Pchar;Increment:integer):Pchar;
  TSendCommRename = function (pProtoName, pNameOfRemoteComputer:Pchar;pNewNickNameMess:Pchar):Pchar;
  TSetVersion = function (Version:PChar):PChar;
  TGetIncomingMessageCount = function ():cardinal;
  TGetNextIncomingMessage = function (BufferForMessage:Pointer; BufferSize:cardinal):cardinal;
  TSendCommCreate = function (pProtoName, pNameOfRemoteComputer, pPrivateChatLineName:Pchar):Pchar;
  TGetIP = function ():PChar;
  TSendCommCreateLine = function (pProtoName, pNameOfRemoteComputer, pPrivateChatLineName, pPassword:Pchar):Pchar;
  TSendCommStatus_Req = function (pProtoName, pNetbiosNameOfRemoteComputer:PChar):Pchar;
  TSendCommMe = function (pProtoName, pNameOfRemoteComputer:PChar;pNickNameOfRemoteComputer:PChar;MessageText:PChar; ChatLine:Pchar;Increment:integer):Pchar;

type
  TDChatCommPlugin = class(TDChatPlugin)
  private
    { Private declarations }
    FOnErrorLoading: TLoadErrorEvent;
    FOnErrorGetProc: TLoadErrorEvent;
  public
    { Public declarations }
    CommunicationInit       : TInitFunction;
    CommunicationShutDown   : TShutDownFunction;
    SendCommDisconnect      : TSendCommDisconnect;
    SendCommConnect         : TSendCommConnect;
    SendCommText            : TSendCommText;
    SendCommReceived        : TSendCommReceived;
    SendCommStatus          : TSendCommStatus;
    SendCommBoard           : TSendCommBoard;
    SendCommRefresh         : TSendCommRefresh;
    SendCommRename          : TSendCommRename;
    SetVersion              : TSetVersion;
    GetIncomingMessageCount : TGetIncomingMessageCount;
    GetNextIncomingMessage  : TGetNextIncomingMessage;
    SendCommCreate          : TSendCommCreate;
    GetLocalIP              : TGetIP;
    SendCommCreateLine      : TSendCommCreateLine;
    SendCommStatus_Req      : TSendCommStatus_Req;
    SendCommMe              : TSendCommMe;

    //FUNCTION CallBackFunction(Buffer:Pchar; Destination:cardinal):PChar;
    property OnErrorLoading: TLoadErrorEvent read FOnErrorLoading write FOnErrorLoading;
    property OnErrorGetProc: TLoadErrorEvent read FOnErrorGetProc write FOnErrorGetProc;
    constructor Create(NativePlugin: TDChatPlugin);
    destructor Destroy; override;
  end;

implementation

FUNCTION {TDChatCommPlugin.}CallBackFunction(Buffer:Pchar; Destination:cardinal):PChar;
BEGIN
//DLL может вызвать эту функцию когда ей захочется
result := Buffer;
END;

Constructor TDChatCommPlugin.Create(NativePlugin: TDChatPlugin);
var ErrorMess: string;
Begin
//тут мы получаем плагин-предок этого типа.
//нам надо создать объект более высокого класса, но и заполнить свойства
//от уже существующего предка.

  //и так, если в конструкторе происходит исключение, то выполнение конструктора прерывается
  // и управление передается сразу на END конструктора.
  inherited Create(NativePlugin.Path + NativePlugin.Filename);
//  self.GetPluginType := NativePlugin.GetPluginType;
  self.GetPluginInfo := NativePlugin.GetPluginInfo;
  self.PluginInfo := NativePlugin.PluginInfo;
  self.Filename := NativePlugin.Filename;
  self.Path := NativePlugin.Path;
  self.DLLHandle := NativePlugin.DLLHandle;

  CommunicationInit := GetProcAddress(DLLHandle, 'Init');
  if not Assigned(CommunicationInit) then raise EExportFunctionError.Create('Error GetProcAddress of CommunicationInit in Plug-in "' + FileName + '"');

  CommunicationShutDown := GetProcAddress(DLLHandle, 'ShutDown');
  if not Assigned(CommunicationShutDown) then raise EExportFunctionError.Create('Error GetProcAddress of CommunicationShutDown in Plug-in "' + FileName + '"');

  SendCommDisconnect := GetProcAddress(DLLHandle, 'SendCommDisconnect');
  if not Assigned(SendCommDisconnect) then raise EExportFunctionError.Create('Error GetProcAddress of SendCommDisconnect in Plug-in "' + FileName + '"');

  SendCommConnect := GetProcAddress(DLLHandle, 'SendCommConnect');
  if not Assigned(SendCommConnect) then raise EExportFunctionError.Create('Error GetProcAddress of SendCommConnect in Plug-in "' + FileName + '"');

  SendCommText := GetProcAddress(DLLHandle, 'SendCommText');
  if not Assigned(SendCommText) then raise EExportFunctionError.Create('Error GetProcAddress of SendCommText in Plug-in "' + FileName + '"');

  SendCommReceived := GetProcAddress(DLLHandle, 'SendCommReceived');
  if not Assigned(SendCommReceived) then raise EExportFunctionError.Create('Error GetProcAddress of SendCommReceived in Plug-in "' + FileName + '"');

  SendCommStatus := GetProcAddress(DLLHandle, 'SendCommStatus');
  if not Assigned(SendCommStatus) then raise EExportFunctionError.Create('Error GetProcAddress of SendCommStatus in Plug-in "' + FileName + '"');

  SendCommBoard := GetProcAddress(DLLHandle, 'SendCommBoard');
  if not Assigned(SendCommBoard) then raise EExportFunctionError.Create('Error GetProcAddress of SendCommBoard in Plug-in "' + FileName + '"');

  SendCommRefresh := GetProcAddress(DLLHandle, 'SendCommRefresh');
  if not Assigned(SendCommRefresh) then raise EExportFunctionError.Create('Error GetProcAddress of SendCommRefresh in Plug-in "' + FileName + '"');

  SendCommRename := GetProcAddress(DLLHandle, 'SendCommRename');
  if not Assigned(SendCommRename) then raise EExportFunctionError.Create('Error GetProcAddress of SendCommRename in Plug-in "' + FileName + '"');

  SetVersion := GetProcAddress(DLLHandle, 'SetVersion');
  if not Assigned(SetVersion) then raise EExportFunctionError.Create('Error GetProcAddress of SetVersion in Plug-in "' + FileName + '"');

  GetIncomingMessageCount := GetProcAddress(DLLHandle, 'GetIncomingMessageCount');
  if not Assigned(GetIncomingMessageCount) then raise EExportFunctionError.Create('Error GetProcAddress of GetIncomingMessageCount in Plug-in "' + FileName + '"');

  GetNextIncomingMessage := GetProcAddress(DLLHandle, 'GetNextIncomingMessage');
  if not Assigned(GetNextIncomingMessage) then raise EExportFunctionError.Create('Error GetProcAddress of GetNextIncomingMessage in Plug-in "' + FileName + '"');

  SendCommCreate := GetProcAddress(DLLHandle, 'SendCommCreate');
  if not Assigned(SendCommCreate) then raise EExportFunctionError.Create('Error GetProcAddress of SendCommCreate in Plug-in "' + FileName + '"');

  GetLocalIP := GetProcAddress(DLLHandle, 'GetIP');
  if not Assigned(GetLocalIP) then raise EExportFunctionError.Create('Error GetProcAddress of GetIP in Plug-in "' + FileName + '"');

  SendCommCreateLine := GetProcAddress(DLLHandle, 'SendCommCreateLine');
  if not Assigned(SendCommCreateLine) then raise EExportFunctionError.Create('Error GetProcAddress of SendCommCreateLine in Plug-in "' + FileName + '"');

  SendCommStatus_Req := GetProcAddress(DLLHandle, 'SendCommStatus_Req');
  if not Assigned(SendCommStatus_Req) then raise EExportFunctionError.Create('Error GetProcAddress of SendCommStatus_Req in Plug-in "' + FileName + '"');

  SendCommMe := GetProcAddress(DLLHandle, 'SendCommMe');
  if not Assigned(SendCommMe) then raise EExportFunctionError.Create('Error GetProcAddress of SendCommMe in Plug-in "' + FileName + '"');

//ErrorMessage := CommunicationInit(CommunicationLibHandle, @CallBackFunction, PChar(ExePath));
CommunicationInit(self.DLLHandle, @CallBackFunction, PChar(self.Path));
End;

Destructor TDChatCommPlugin.Destroy; {override;}
Begin
  inherited Destroy;
  //MessageBox(0, PChar('TDChatTestPlugin.Destroy'), PChar(IntToStr(0)), MB_OK);
End;

{как из DLL получить полный путь до нее 
procedure ShowDllPath stdcall;
var
TheFileName: array[0..MAX_PATH] of char;
begin
FillChar(TheFileName, sizeof(TheFileName), #0);
GetModuleFileName(hInstance, TheFileName, sizeof(TheFileName));
MessageBox(0, TheFileName, ?The DLL file name is:?, mb_ok);
end;}
end.
