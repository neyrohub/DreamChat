//Autor Bajenov Andrey
//All right reserved.
//Saint-Petersburg, Russia
//2007.02.03
//neyro@mail.ru

//DreamChat is published under a double license. You can choose which one fits
//better for you, either Mozilla Public License (MPL) or Lesser General Public
//License (LGPL). For more info about MPL read the MPL homepage. For more info
//about LGPL read the LGPL homepage.

unit DChatTestPlugin;

interface

uses
  Windows, Messages, SysUtils, Classes, DChatPlugin;

const
   DChatTestPluginVersion = 1;

type
  TInitFunction = function (ModuleHandle: HMODULE; pCallBackFunction:pointer; ExePath:PChar):PChar;
  TShutDownFunction = function ():PChar;
  TExecuteCommand = function (Command: PChar; Data: PChar; DataSize: cardinal):PChar;//Return errorcode or 0 if succef
  TLoadErrorEvent = procedure(Sender: TObject; ErrorMess: string) of object;

type
  TDChatTestPlugin = class(TDChatPlugin)
  private
    { Private declarations }
    FOnErrorLoading: TLoadErrorEvent;
    FOnErrorGetProc: TLoadErrorEvent;
  public
    { Public declarations }
    InitFunction: TInitFunction;
    ShutDownFunction: TShutDownFunction;
    ExecuteCommand: TExecuteCommand;
    property OnErrorLoading: TLoadErrorEvent read FOnErrorLoading write FOnErrorLoading;
    property OnErrorGetProc: TLoadErrorEvent read FOnErrorGetProc write FOnErrorGetProc;
    constructor Create(NativePlugin: TDChatPlugin);
    destructor Destroy; override;
  end;


implementation

Constructor TDChatTestPlugin.Create(NativePlugin: TDChatPlugin);
var ErrorMess: string;
Begin
//тут мы получаем плагин-предок этого типа.
//нам надо создать объект более высокого класса, но и заполнить свойства
//от уже существующего предка.

  //и так, если в конструкторе происходит исключение, то выполнение конструктора прерывается
  // и управление передается сразу на END конструктора.
  inherited Create(NativePlugin.Path + NativePlugin.Filename);
//  self.InitFunction := NativePlugin.InitFunction;
//  self.ShutDownFunction := NativePlugin.ShutDownFunction;
//  self.GetPluginType := NativePlugin.GetPluginType;
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
  if not Assigned(ExecuteCommand) then raise EExportFunctionError.Create('Error GetProcAddress of ExecuteCommand in Plug-in "' + FileName + '"');
//  TestFunction1 := GetProcAddress(DLLHandle, 'TestFunction1');
//  if not Assigned(TestFunction1) then raise EExportFunctionError.Create('Error GetProcAddress of TestFunction1 in Plug-in "' + FileName + '"');
End;

Destructor TDChatTestPlugin.Destroy; {override;}
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
