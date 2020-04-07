//Author Bajenov Andrey
//All right reserved.
//Saint-Petersburg, Russia
//2007.02.03
//neyro@mail.ru

//DreamChat is published under a double license. You can choose which one fits
//better for you, either Mozilla Public License (MPL) or Lesser General Public
//License (LGPL). For more info about MPL read the MPL homepage. For more info
//about LGPL read the LGPL homepage.

//это NATIVE плагин с минимумом функций. Фактически это оболочка для более
//продвинутого плагина


unit DChatPlugin;

interface

uses
  Windows, Messages, SysUtils, Classes{, IdStack, IdThread};

Type
  TPluginType = (Test, Visual, Communication, SoundEvents, Protocol, ClientServer);

  EPluginError = class(Exception);
  EPluginLoadingError = class(Exception);
  EExportFunctionError = class(Exception);

Type
  TPluginInfo = packed record
  PluginComment: shortstring;           // Описание плагина
  PluginAutorName: shortstring;         // Имя автора
  PluginName: shortstring;              // Название плагина
  InternalPluginFileName: shortstring;  // Авторское файла
  PluginType: TPluginType;              // Тип плагина
  PluginAPIVersion: shortstring;        // Версия набора интерфейсных функций плагина
  PluginManagerAPIVersion: shortstring; // Версия первичного набора интерфейсных функций (версия плагин менеджера)
  PluginVersion: shortstring;           // Версия Build
end;
PPluginInfo = ^TPluginInfo;

type
  //TInitFunction = function (ModuleHandle: HMODULE; pCallBackFunction:pointer; ExePath:PChar):PChar;
  //TShutDownFunction = function ():PChar;
  TGetPluginType = function(var PluginTypeNote: PChar):byte;
  TGetPluginInfo = function():PPluginInfo;

type
  TDChatPlugin = class(TPersistent)
  private
    { Private declarations }
    FFilename: shortstring;          // Имя файла
    FPath: string;                   // Путь к каталогу
    FDLLHandle: HINST;               // Хэндл загруженной DLL
    FPluginInfo: PPluginInfo;        // Инфа о плагине
  public
    { Public declarations }
    GetPluginInfo: TGetPluginInfo;
    property PluginInfo: PPluginInfo read FPluginInfo write FPluginInfo;
    property Filename: shortstring read FFilename write FFilename;
    property Path: string read FPath write FPath;
    property DLLHandle: HINST read FDLLHandle write FDLLHandle;

    constructor Create(FullDLLName: String);
    destructor Destroy; override;
  end;


implementation

Constructor TDChatPlugin.Create(FullDLLName: String);
var ErrorMessage: string;
    E: Exception;
Begin
inherited Create();
FDLLHandle := LoadLibrary(PChar(FullDLLName));

if FDLLHandle <= 0 then
  begin
  ErrorMessage := 'Error: Can''t load library ' + FullDLLName;
//  sMessageDlg('Critical error!', ErrorMessage, mtError, [mbOk], 0);
  E := Exception.Create(ErrorMessage);
  raise E.create(ErrorMessage);
  inherited Destroy();
  self := nil;
  end
else
  begin
  //и так, если в конструкторе происходит исключение, то выполнение конструктора
  //прерывается и управление передается сразу на END конструктора.
//  GetPluginType := GetProcAddress(FDLLHandle, 'GetPluginType'); убрано в 4й версии API
//  if not Assigned(GetPluginType) then raise EExportFunctionError.Create('Error GetProcAddress of GetPluginType in Plug-in "' + FullDLLName + '"');
  GetPluginInfo := GetProcAddress(FDLLHandle, 'GetPluginInfo');
  if not Assigned(GetPluginInfo) then raise EExportFunctionError.Create('Error GetProcAddress of GetPluginInfo in Plug-in "' + FullDLLName + '"');
  self.PluginInfo := GetPluginInfo();
  Filename := ExtractFileName(FullDLLName);
  Path := ExtractFileDir(FullDLLName) + '\';
  end;
End;

Destructor TDChatPlugin.Destroy; {override;}
Begin
  inherited Destroy;
  FreeLibrary(self.FDLLHandle);
End;

end.
