//Autor Bajenov Andrey
//All right reserved.
//Saint-Petersburg, Russia
//2007.02.03
//neyro@mail.ru

//DreamChat is published under a double license. You can choose which one fits
//better for you, either Mozilla Public License (MPL) or Lesser General Public
//License (LGPL). For more info about MPL read the MPL homepage. For more info
//about LGPL read the LGPL homepage.

unit DChatClientServerPlugin;

interface

uses
  Windows, Messages, SysUtils, Classes, DChatPlugin;

const
   DChatClientServerPluginVersion = 4;


type
  TInitFunction = function (ModuleHandle: HMODULE; pCallBackFunction:pointer; ExePath:PChar; InitPamametrs: PChar):PChar;
  TShutDownFunction = function():PChar;
  TExecuteCommand = function (Command: PChar; Data: PChar; DataSize: cardinal):PChar;//Return errorcode or 0 if succef

  TLoadErrorEvent = procedure(Sender: TObject; ErrorMess: string) of object;

type
  TDChatClientServerPlugin = class(TDChatPlugin)
  private
    { Private declarations }
    FOnErrorLoading: TLoadErrorEvent;
    FOnErrorGetProc: TLoadErrorEvent;
  public
    { Public declarations }
    InitFunction: TInitFunction;
    ShutDownFunction: TShutDownFunction;
    ExecuteCommand: TExecuteCommand;
    {GetMenuItem: TGetMenuItem;}
    TExecuteCommand: TExecuteCommand;
    property OnErrorLoading: TLoadErrorEvent read FOnErrorLoading write FOnErrorLoading;
    property OnErrorGetProc: TLoadErrorEvent read FOnErrorGetProc write FOnErrorGetProc;
    constructor Create(NativePlugin: TDChatPlugin);
    destructor Destroy; override;
  end;


implementation

Constructor TDChatClientServerPlugin.Create(NativePlugin: TDChatPlugin);
var ErrorMess: string;
Begin
//тут мы получаем плагин-предок этого типа.
//нам надо создать объект более высокого класса, но и заполнить свойства
//от уже существующего предка.

  //и так, если в конструкторе происходит исключение, то выполнение конструктора прерывается
  // и управление передается сразу на END конструктора.
  inherited Create(NativePlugin.Path + NativePlugin.Filename);
  self.GetPluginInfo := NativePlugin.GetPluginInfo;
  self.PluginInfo := NativePlugin.PluginInfo;
  self.Filename := NativePlugin.Filename;
  self.Path := NativePlugin.Path;
  self.DLLHandle := NativePlugin.DLLHandle;

  InitFunction := GetProcAddress(DLLHandle, 'Init');
  if not Assigned(InitFunction) then raise EExportFunctionError.Create('Error GetProcAddress of InitFunction in Plug-in "' + FileName + '"');
  ShutDownFunction := GetProcAddress(DLLHandle, 'ShutDown');
  if not Assigned(ShutDownFunction) then raise EExportFunctionError.Create('Error GetProcAddress of ShutDownFunction in Plug-in "' + FileName + '"');
  ExecuteCommand := GetProcAddress(DLLHandle, 'ExecuteCommand');
  if not Assigned(ExecuteCommand) then raise EExportFunctionError.Create('Error GetProcAddress of ShowPluginForm in Plug-in "' + FileName + '"');
{  GetMenuItem := GetProcAddress(DLLHandle, 'GetMenuItem');
  if not Assigned(GetMenuItem) then raise EExportFunctionError.Create('Error GetProcAddress of GetMenuItem in Plug-in "' + FileName + '"');
}
  ExecuteCommand := GetProcAddress(DLLHandle, 'ExecuteCommand');
  if not Assigned(ExecuteCommand) then raise EExportFunctionError.Create('Error GetProcAddress of TExecuteCommand in Plug-in "' + FileName + '"');
End;

Destructor TDChatClientServerPlugin.Destroy; {override;}
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
