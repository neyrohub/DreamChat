unit uMouseHook;

interface

uses
  Windows, Messages, SysUtils;

function MouseProc(code: integer; wParam: word; lParam: longword): longword; stdcall;
function SetupLocalHook: boolean;
function RemoveLocalHook: boolean;

var
  CurrentHook: HHook; //contains the handle of the currently installed hook
  HookInstalled: boolean; //true if a hook is installed
  pMessStruct :PMOUSEHOOKSTRUCT;

implementation

uses uFormMain;

function SetupLocalHook: boolean;
begin
  CurrentHook := SetWindowsHookEx(WH_MOUSE, @MouseProc, 0, GetCurrentThreadID()); //install hook
  if CurrentHook <> 0
    then SetupLocalHook := True
    else SetupLocalHook := False; //return true if it worked
end;

function RemoveLocalHook: boolean;
begin
  RemoveLocalHook := UnhookWindowsHookEx(CurrentHook);
end;

function MouseProc(code: integer; wParam: word; lParam: longword): longword; stdcall;
begin

pMessStruct := pointer(lParam);

MouseX := PMouseHookStruct(lParam)^.pt.x;
MouseY := PMouseHookStruct(lParam)^.pt.y;

if code < 0 then
  begin  //if code is <0 your keyboard hook should always run CallNextHookEx instantly and
  MouseProc := CallNextHookEx(CurrentHook, code, wParam, lparam); //then return the value from it.
  Exit;
  end;

CallNextHookEx(CurrentHook, code, wParam, lparam);  //call the next hook proc if there is one
MouseProc := 0; //if KeyBoardHook returns a non-zero value, the window that should get
                     //the keyboard message doesnt get it.
//Exit;
end;

end.
