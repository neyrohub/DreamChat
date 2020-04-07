unit DreamChatMessageBox;
{
  Object oriented wrappers over Delphi standard MessageDlg functions.
  Useful when we need to change behavior of all MessageDlg calls in application or
  add more actions before or after showing the message.

  Feel free to extend TDreamChatMessageBox class with new overloaded MessageBox functions.
}

interface

uses
{$IFDEF USEFASTSHAREMEM}
  FastShareMem,
{$ENDIF}

   Dialogs, sDialogs;

type

  TDreamChatMessageBox = class
    class function Show(const Msg: string): Word; overload;
    class function Show(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: Longint): Word; overload;
  end;

implementation

class function TDreamChatMessageBox.Show(const Msg: string): Word;
begin
  Result := Show(Msg, mtInformation, [], 0);
end;

class function TDreamChatMessageBox.Show(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: Longint): Word;
begin
  Result := sMessageDlg(Msg, DlgType, Buttons, HelpCtx);
end;


end.
