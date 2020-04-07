unit CVFreeReg;
interface

  {$I CV_Defs.inc}

uses Classes,
    {$IFDEF ChatViewDEF6}
    DesignIntf, 
    {$ELSE}
    DsgnIntf,
    {$ENDIF}
     ChatView, CVStyle, CVSEdit, PtblCV;

procedure Register;

implementation

{--------------------------------------------------------------}
procedure Register;
begin
  RegisterComponents('ChatView', [TCVStyle, TChatView, TCVPrint]);
  RegisterComponentEditor(TCVStyle, TCVSEditor);
  RegisterPropertyEditor(TypeInfo(TFontInfos), TCVStyle, '', TCVSProperty);
end;

end.
