unit CVSEdit;

interface


uses
  {$I CV_Defs.inc}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CVStyle,
  {$IFDEF ChatViewDEF6}
  DesignIntf, DesignEditors,
  {$ENDIF}
  {$IFDEF ChatViewDEF7}
  {DesignEditors,}
  {$ENDIF}
  ComCtrls, ExtCtrls, StdCtrls;

const
  StandardStylesName:array[0..LAST_DEFAULT_STYLE_NO] of String =
         ( 'Normal Text', 'Heading', 'Subheading', 'Keywords',
           'Jump1', 'Jump2');
type
  {----------------------------------------------------------}
  TCVSProperty = class (TClassProperty)
   public
    //function GetValue:String; override;
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;
  {----------------------------------------------------------}
  TCVSEditor = class(TDefaultEditor)
  protected
    {$IFDEF ChatViewDEF6}
    procedure EditProperty(const PropertyEditor: IProperty;
      var Continue: Boolean); override;
    {$ELSE}
    procedure EditProperty(PropertyEditor: TPropertyEditor;
      var Continue, FreeEditor: Boolean); override;
    {$ENDIF}      
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;
  {----------------------------------------------------------}
  TfrmCVSEdit = class(TForm)
    btnOk: TButton;
    btnDel: TButton;
    btnEdit: TButton;
    btnAdd: TButton;
    Bevel1: TBevel;
    Label1: TLabel;
    tv: TTreeView;
    panPreview: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
    procedure tvChange(Sender: TObject; Node: TTreeNode);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    TextStyles: TFontInfos;
    procedure UpdateList;
  public
    { Public declarations }
    Modified: Boolean;
    procedure SetTextStyles(ATextStyles: TFontInfos);
  end;

implementation

{$R *.DFM}
{--------------------------------------------------------}
procedure TfrmCVSEdit.FormCreate(Sender: TObject);
begin
  TextStyles := nil;
  Modified := False;
end;
{--------------------------------------------------------}
procedure TfrmCVSEdit.UpdateList;
var i: Integer;
begin
  tv.Items.Clear;
  if TextStyles=nil then exit;
  for i:= 0 to TextStyles.Count-1 do
    if i<= LAST_DEFAULT_STYLE_NO then
       tv.Items.Add(nil,IntToStr(i)+'. '+StandardStylesName[i])
    else
       tv.Items.Add(nil,IntToStr(i)+'. '+'User Style');
  tv.Selected := tv.Items[0];  
end;
{--------------------------------------------------------}
procedure TfrmCVSEdit.SetTextStyles(ATextStyles: TFontInfos);
begin
  TextStyles := ATextStyles;
  UpdateList;
end;
{--------------------------------------------------------}
procedure TfrmCVSEdit.btnAddClick(Sender: TObject);
begin
   TextStyles.Add;
   UpdateList;
   Modified := True;
end;
{--------------------------------------------------------}
procedure TfrmCVSEdit.btnEditClick(Sender: TObject);
var dlg: TFontDialog;
    fnt: TFontInfo;
begin
      if tv.Selected = nil then begin
         Application.MessageBox('Style is not selected', 'Can not Edit',
                               MB_OK or MB_ICONSTOP);
         exit;
      end;
      dlg := TFontDialog.Create(Self);
      try
        fnt := TFontInfo(TextStyles[tv.Selected.AbsoluteIndex]);
        dlg.Font.Name  := fnt.FontName;
        dlg.Font.Size  := fnt.Size;
        dlg.Font.Style := fnt.Style;
        dlg.Font.Color := fnt.Color;
        {$IFDEF ChatViewDEF3}
        dlg.Font.CharSet := fnt.CharSet;
        {$ENDIF}
        if dlg.Execute then begin
          Modified := True;
          fnt.FontName  := dlg.Font.Name;
          fnt.Size  := dlg.Font.Size;
          fnt.Style := dlg.Font.Style;
          fnt.Color := dlg.Font.Color;
          {$IFDEF ChatViewDEF3}
          fnt.CharSet := dlg.Font.CharSet;
          {$ENDIF}
        end;
      finally
        dlg.Free;
        UpdateList;
      end;
end;
{--------------------------------------------------------}
procedure TfrmCVSEdit.btnDelClick(Sender: TObject);
begin
   if tv.Selected = nil then begin
         Application.MessageBox('Style is not selected', 'Can not Edit',
                               MB_OK or MB_ICONSTOP);
         exit;
   end;
   if tv.Selected.AbsoluteIndex<=LAST_DEFAULT_STYLE_NO then
     Application.MessageBox('Selected style is not user defined','Can not Delete',
                            MB_OK or MB_ICONSTOP)
   else begin
     Modified := True;
     TextStyles.Delete(tv.Selected.AbsoluteIndex);
   end;
   UpdateList;
end;
{--------------------------------------------------------}
procedure TfrmCVSEdit.tvChange(Sender: TObject; Node: TTreeNode);
begin
  if tv.Selected = nil then begin
    panPreview.Caption := '';
    panPreview.Color := clBtnFace;
    end
  else begin
    panPreview.Caption := 'Style Preview';
    panPreview.Font.Size := TextStyles[tv.Selected.AbsoluteIndex].Size;
    panPreview.Font.Style := TextStyles[tv.Selected.AbsoluteIndex].Style;
    panPreview.Font.Color := TextStyles[tv.Selected.AbsoluteIndex].Color;
    {$IFDEF ChatViewDEF3}
    panPreview.Font.CharSet := TextStyles[tv.Selected.AbsoluteIndex].CharSet;
    {$ENDIF}
    if ColorToRGB(panPreview.Font.Color) = ColorToRGB(clBtnFace) then
      panPreview.Color := clWindow
    else
      panPreview.Color := clBtnFace;

  end;
end;
{--------------------------------------------------------}
procedure TfrmCVSEdit.FormActivate(Sender: TObject);
begin
   tvChange(tv, nil);
end;
{==========================================================}
procedure TCVSProperty.Edit;
var frm:TfrmCVSEdit;
begin
   frm := TfrmCVSEdit.Create(Application);
   try
     frm.SetTextStyles(TFontInfos(GetOrdValue));
     frm.ShowModal;
     if frm.Modified then Modified;
   finally
     frm.Free;
   end;
end;
{--------------------------------------------------------}
function TCVSProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;
{==========================================================}
{$IFDEF ChatViewDEF6}
procedure TCVSEditor.EditProperty(const PropertyEditor: IProperty;
                                  var Continue: Boolean);
var
  PropName: string;
begin
  PropName := PropertyEditor.GetName;
  if (CompareText(PropName, 'TextStyles') = 0) then
  begin
    PropertyEditor.Edit;
    Continue := False;
  end;
end;
{$ELSE}
procedure TCVSEditor.EditProperty(PropertyEditor: TPropertyEditor;
  var Continue, FreeEditor: Boolean);
var
  PropName: string;
begin
  PropName := PropertyEditor.GetName;
  if (CompareText(PropName, 'TextStyles') = 0) then
  begin
    PropertyEditor.Edit;
    Continue := False;
  end;
end;
{$ENDIF}
{--------------------------------------------------------}
function TCVSEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;
{--------------------------------------------------------}
function TCVSEditor.GetVerb(Index: Integer): string;
begin
  if Index = 0 then
    Result := 'Edit Text Styles'
  else Result := '';
end;
{--------------------------------------------------------}
procedure TCVSEditor.ExecuteVerb(Index: Integer);
begin
  if Index = 0 then Edit;
end;

end.
