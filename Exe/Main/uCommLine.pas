///msg "Andrey" Это сообщение из коммандной строки!
unit uCommLine;

{ TSharedMem }

{ This class simplifies the process of creating a region of shared memory.
  In Win32, this is accomplished by using the CreateFileMapping and
  MapViewOfFile functions. }
interface

uses
  SysUtils, Classes, Windows;

type

{ THandledObject }

{ This is a generic class for all encapsulated WinAPI's which need to call
  CloseHandle when no longer needed.  This code eliminates the need for
  3 identical destructors in the TEvent, TMutex, and TSharedMem classes
  which are descended from this class. }

  THandledObject = class(TObject)
  protected
    FHandle: THandle;
  public
    destructor Destroy; override;
    property Handle: THandle read FHandle;
  end;

  TSharedMem = class(THandledObject)
  private
    FName: string;
    FSize: Integer;
    FCreated: Boolean;
    FFileView: Pointer;
  public
    constructor Create(const Name: string; Size: Integer);
    destructor Destroy; override;
    property Name: string read FName;
    property Size: Integer read FSize;
    property Buffer: Pointer read FFileView;
    property Created: Boolean read FCreated;
  end;

const ShareMemSize = 100;

type
  TCommandLine = class(TObject)
  private
    //ВНИМАНИЕ! Этот процес взаимодействия ТОЛЬКО 2х процессов!
    //больше нельзя!!! Для этого нужно прикрутить сюда мьютекс!
    //Взаимодействие процессов происходит следующим образом:
    //в начале общей памяти, первые 2а байта это ProcessId, того
    //процесса, которые записал данные или $FF $FF, если 2й процесс
    //считал данные
    //если тригер = $ffff, то любой процесс может записать что хочет.
    //1. если процесс хочет что-то записать, он проверяет, что тригер = 0
    //2. устанавливает тригер = FProcessId и записывает.

    { Private declarations }
    FProcessId: DWORD;
    SharedMem: TSharedMem;
    Buffer: array [0..103] of byte;
    FMemFileName: string;
    FCommand : String;
    FTrigger: DWord;
    FIncommigCommand: boolean;
    FFirstCopyApplication: boolean;
    Function GetIncommigState():boolean;
    Function GetCommand():string;
    Procedure SendCommand(Cmd:string);
    Function GetTrigger():Dword;
    Procedure SetTrigger(TriggerState:Dword);
    property Trigger: Dword read GetTrigger write SetTrigger;
  public
    { Public declarations }
    LastError: DWORD;
    constructor Create(MemFileName:String);
    destructor Destroy; override;
    property IncommigCommand: boolean read GetIncommigState write FIncommigCommand;
    property FirstCopyApplication: boolean read FFirstCopyApplication write FFirstCopyApplication;
    property Command: string read GetCommand write SendCommand;
  end;

implementation

procedure Error(const Msg: string);
begin
//  MessageBox(0, PChar(Msg), PChar('Error') ,mb_ok);
  raise Exception.Create(Msg);
end;

destructor THandledObject.Destroy;
begin
  if FHandle <> 0 then
    CloseHandle(FHandle);
end;

{ TSharedMem }

constructor TSharedMem.Create(const Name: string; Size: Integer);
begin
  try
    FName := Name;
    FSize := Size;
    { CreateFileMapping, when called with $FFFFFFFF for the hanlde value,
      creates a region of shared memory }
    FHandle := OpenFileMapping(FILE_MAP_WRITE, true, PChar(Name));
//    if GetLastError = ERROR_FILE_NOT_FOUND then
//    if GetLastError <> ERROR_FILE_EXISTS then
//ERROR_ACCESS_DENIED
    if GetLastError = ERROR_ACCESS_DENIED then
      begin
      FName := FName + inttostr(Round(Random*100));
      Error(Format('TSharedMem: Error OpenFileMapping "%s", GetLastError = %d', [Name, GetLastError]));
//      abort;
      end;
    FHandle := CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0,
        Size, PChar(Name));
    if FHandle = 0 then abort;
    FCreated := GetLastError = 0;
    { We still need to map a pointer to the handle of the shared memory region }
    FFileView := MapViewOfFile(FHandle, FILE_MAP_WRITE, 0, 0, Size);
    if FFileView = nil then abort;
  except
    Error(Format('TSharedMem: Error creating shared memory %s (%d)', [Name, GetLastError]));
  end;
end;

destructor TSharedMem.Destroy;
begin
  if FFileView <> nil then
    UnmapViewOfFile(FFileView);
  inherited Destroy;
end;

{ TCommandLine }

constructor TCommandLine.Create(MemFileName:String);
//var
//   i: integer;
//   TempId: DWord;
//   MemHnd: hwnd;
begin
FProcessId := GetCurrentProcessId();
FMemFileName := MemFileName;
    try
      SharedMem := TSharedMem.Create(FMemFileName, ShareMemSize);
    except
      Error(Format('TCommandLine: Error creating shared memory %s (%d)', [FMemFileName, GetLastError]));
    end;
if Trigger = 0 then
  begin
  FirstCopyApplication := true;
  Trigger := $FFFF;
  end
else
  FirstCopyApplication := false;
end;

destructor TCommandLine.Destroy;
begin
SharedMem.Free;
end;


Function TCommandLine.GetTrigger():Dword;
begin
//проверяем состояние триггера!
FTrigger := $FFFF;
copymemory(@FTrigger, SharedMem.Buffer, 2);
result := FTrigger;
end;

Procedure TCommandLine.SetTrigger(TriggerState:Dword);
begin
//устанавливаем состояние триггера!
copymemory(SharedMem.Buffer, @TriggerState, 2);
//MessageBox(0, PChar('SetTrigger'), PChar(inttostr(TriggerState)) ,mb_ok);
end;

Function TCommandLine.GetIncommigState():boolean;
begin
//проверяем есть ли входящее сообщение?
if (Trigger <> $0000) and (Trigger <> $FFFF) and (Trigger <> FProcessId) then
  begin
  FIncommigCommand := true;
  result := true;
  end
else
  begin
  FIncommigCommand := false;
  result := false;
  end;
end;

Function TCommandLine.GetCommand():string;
var
  P:^byte;
begin
fcommand := '';
//читаем состояние тригера
if IncommigCommand = true then
  begin
  //считываем команду из другого приложения
  copymemory(@buffer, SharedMem.Buffer, ShareMemSize);
  //пропускаем первые 2 байта (там триггер)
  p := @buffer;
  inc(p);inc(p);
  fcommand := PChar(p);
  //очищаем общую память
  ZeroMemory(@buffer, SizeOf(buffer));
  copymemory(SharedMem.Buffer, @buffer, ShareMemSize);
  //сбрасываем триггер готовности для следующей команды
  Trigger := $FFFF;
  end;
result := fcommand;
end;

Procedure TCommandLine.SendCommand(Cmd:string);
var
  P:^byte;
begin
//проверяем состояние триггера!
//он должен быть равен 0, т.е. предыдущая команда должна быть выполнена.
if Trigger = $FFFF then
  begin
  //Записываем команду в общую память
  p := SharedMem.Buffer;
  inc(p);inc(p);
  copymemory(p, PChar(Cmd), length(Cmd) + 2);
  //устанавливаем тригер
  //команда может быть считана из SharedMem!
  Trigger := FProcessId;
  end;
end;
end.
