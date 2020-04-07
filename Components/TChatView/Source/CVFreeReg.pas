unit CVFreeReg;
interface

  {$I CV_Defs.inc}

uses Classes,
    {$IFDEF ChatViewDEF6}
    DesignIntf, 
    {.$ELSE}
    DsgnIntf,
    {$ENDIF}
     ChatView, CVStyle, {CVSEdit,} PtblCV, sChatView;

procedure Register;

implementation

{--------------------------------------------------------------}
procedure Register;
begin
  RegisterComponents('ChatView', [TCVStyle, TChatView, TCVPrint, TsChatView]);
//  RegisterComponentEditor(TCVStyle, TCVSEditor);
//  RegisterPropertyEditor(TypeInfo(TFontInfos), TCVStyle, '', TCVSProperty);
end;

end.
