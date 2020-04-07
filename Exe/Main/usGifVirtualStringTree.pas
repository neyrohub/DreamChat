unit usGifVirtualStringTree;

//*****************************************************************************
//*          Skin version TGifVirtualTree for AlphaControls 5.x               *
//*                   by Bajenov Andrey 2007(c)                               *
//*                   e-mail: neyro@mail.ru                                   *
//*****************************************************************************

interface

uses
   Windows, SysUtils, Classes, Graphics, controls, LiteGIFX2, Menus,
   VirtualTrees, uGifVirtualStringTree, VTHeaderPopup,
   Messages, sConst, sCommonData, sDefaults, acSBUtils,
   sScrollBar{ sDebugMsgs};

//ver  0.24

Const
    G_FIRSTLINE   = 0;
    G_FIRSTMINUS  = 1;
    G_FIRSTPLUS   = 2;
    G_LASTLINE    = 3;
    G_LASTMINUS   = 4;
    G_LASTPLUS    = 5;
    G_MIDDLELINE  = 6;
    G_MIDDLEMINUS = 7;
    G_MIDDLEPLUS  = 8;
    G_ONEMINUS    = 9;
    G_ONEPLUS     = 10;
    G_VERTICAL    = 11;
    G_CHECKBOX0   = 12;
    G_CHECKBOX1   = 13;
    G_CHECKBOX2   = 14;
    G_USER0       = 15;
    G_USER1       = 16;
    G_USER2       = 17;
    G_USER3       = 18;
    G_REFRESH     = 19;
    G_CHAT        = 20;
    G_LINE        = 21;
    G_IGNORED     = 22;
    G_POPUP_IGNORED         = 23;
    G_POPUP_PRIVATE_MESSAGE = 24;
    G_POPUP_MASSMESSAGE     = 25;
    G_POPUP_PRIVATE_CHAT    = 26;
    G_POPUP_CREATE_LINE     = 27;
    G_POPUP_EXIT            = 28;
    G_POPUP_SEE_SHARE       = 29;
    G_POPUP_NICKNAME        = 30;

type
  TsGifVirtualStringTree = class(TGifVirtualStringTree)
  private
    { Private declarations }
    FBoundLabel: TsBoundLabel;
    FCommonData: TsCommonData;
    FDisabledKind: TsDisabledKind;
    FOldDataChange : TNotifyEvent;
    procedure SetDisabledKind(const Value: TsDisabledKind);
    //procedure DataChange(Sender: TObject);
  protected
    procedure WndProc (var Message: TMessage); override;
  public
    { Public declarations }
    ListSW : TacScrollWnd;
    constructor CreateGVST(ParentChatLine:TObject; AComponent:TComponent; GifFilePath:String);override;
    destructor Destroy;override;
    procedure Paint; override;//перегружаем отрисовку, чтобы поправить размер V&HBar
    procedure Repaint; override;//перегружаем отрисовку, чтобы поправить размер V&HBar
    procedure AfterConstruction; override;
    procedure Loaded; override;
  published
    property BoundLabel : TsBoundLabel read FBoundLabel write FBoundLabel;//*
    property DisabledKind : TsDisabledKind read FDisabledKind write SetDisabledKind default DefDisabledKind;//*
    property SkinData : TsCommonData read FCommonData write FCommonData;//*
  end;

implementation
uses
  uChatLine,
  sMessages, sSKinProps, sVCLUtils, sGraphUtils, sAlphaGraph;

{------------------------------------------------------------------------------}
{                                    Skin                                      }
{------------------------------------------------------------------------------}
constructor TsGifVirtualStringTree.CreateGVST(ParentChatLine:TObject; AComponent:TComponent;GifFilePath:String);
var
    MS: TMemoryStream;
begin
inherited CreateGVST(ParentChatLine, AComponent, GifFilePath);
  FCommonData := TsCommonData.Create(Self, {$IFDEF DYNAMICCACHE} False {$ELSE} True {$ENDIF});
  FCommonData.COC := COC_TsEdit;
  if FCommonData.SkinSection = '' then FCommonData.SkinSection := s_Edit;
  FDisabledKind := DefDisabledKind;
  FBoundLabel := TsBoundLabel.Create(Self, FCommonData);
end;

destructor TsGifVirtualStringTree.Destroy;
var
  srtlist: TStringList;
begin
  if ListSW <> nil then FreeAndNil(ListSW);
  FreeAndNil(FBoundLabel);
  if Assigned(FCommonData) then FreeAndNil(FCommonData);

inherited Destroy();
end;

procedure TsGifVirtualStringTree.Loaded;
begin
  inherited Loaded;
  FCommonData.Loaded;
  RefreshEditScrolls(SkinData, ListSW);
end;

procedure TsGifVirtualStringTree.SetDisabledKind(const Value: TsDisabledKind);
begin
  if FDisabledKind <> Value then begin
    FDisabledKind := Value;
    FCommonData.Invalidate;
  end;
end;

procedure TsGifVirtualStringTree.AfterConstruction;
begin
  inherited AfterConstruction;
  FCommonData.Loaded;
end;

procedure TsGifVirtualStringTree.WndProc(var Message: TMessage);
var
  ScrollInfo: TScrollInfo;
  Code: Integer;
begin
if Message.Msg = SM_ALPHACMD then
  case Message.WParamHi of
    AC_CTRLHANDLED :
      begin
      Message.LParam := 1;
      Exit
      end; // AlphaSkins supported
    AC_REMOVESKIN :
      if Message.LParam = LongWord(SkinData.SkinManager) then
        begin
        if ListSW <> nil then FreeAndNil(ListSW);
        CommonWndProc(Message, FCommonData);
        if not FCommonData.CustomColor then Color := clWindow;
        if not FCommonData.CustomFont then Font.Color := clWindowText;
        RecreateWnd;
        exit
        end;
    AC_REFRESH :
      if (Message.LParam = LongWord(SkinData.SkinManager)) then
        begin
        CommonWndProc(Message, FCommonData);
        if FCommonData.Skinned then
          begin
          if not FCommonData.CustomColor then Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].Color;
          if not FCommonData.CustomFont then Font.Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].FontColor[1];
          end;
        Repaint;
        RefreshEditScrolls(SkinData, ListSW);
        exit
        end;
    AC_ENDPARENTUPDATE :
      if FCommonData.Updating then
        begin
        FCommonData.Updating := False;
        Repaint;
        Exit;
        end;
    AC_SETNEWSKIN :
      if (Message.LParam = LongWord(SkinData.SkinManager)) then
        begin
        CommonWndProc(Message, FCommonData);
        exit
        end
  end;
  if not ControlIsReady(Self) or not FCommonData.Skinned(True) then
    inherited
  else
    begin
      case Message.Msg of
      CN_DRAWITEM : Exit;
      WM_SIZE, WM_MOVE :
        begin
        end;
      WM_HSCROLL :
          case TWMHSCROLL(Message).ScrollCode of
            SB_THUMBPOSITION:
              begin
              SetScrollPos(Handle, SB_HORZ, TWMHSCROLL(Message).Pos, TRUE);
              acSBUtils.Ac_NCPaint(ListSW.sBarHorz.sw, Handle, 0, 0);
              end;
            SB_THUMBTRACK:
              begin
              SetScrollPos(Handle, SB_HORZ, TWMHSCROLL(Message).Pos, TRUE);
              end;
          end;
      WM_VSCROLL :
        begin
          case TWMVSCROLL(Message).ScrollCode of
            SB_THUMBPOSITION:
              begin
              SetScrollPos(Handle, SB_VERT, TWMVSCROLL(Message).Pos, TRUE);
              acSBUtils.Ac_NCPaint(ListSW.sBarVert.sw, Handle, 0, 0);
              end;
            SB_THUMBTRACK:
              begin
              SetScrollPos(Handle, SB_VERT, TWMVSCROLL(Message).Pos, TRUE);
              end;
          end;
{        if Assigned(FOnVScroll) then
          begin
          FOnVScroll(Self);
          end;}
        end;
      WM_SETFOCUS, CM_ENTER :
        if CanFocus then
          begin
          inherited;
          if Focused then
            begin
            FCommonData.FFocused := True;
            FCommonData.FMouseAbove := False;
            FCommonData.BGChanged := True;
            end;
          end;
      WM_KILLFOCUS, CM_EXIT:
        begin
        FCommonData.FFocused := False;
        FCommonData.FMouseAbove := False;
        FCommonData.BGChanged := True;
        end;
      end;
    CommonWndProc(Message, FCommonData);
    inherited;
      case Message.Msg of
      CM_SHOWINGCHANGED :
        RefreshEditScrolls(SkinData, ListSW);
      CM_VISIBLECHANGED, CM_ENABLEDCHANGED, WM_SETFONT :
        begin
        FCommonData.Invalidate;
        end;
      end;
  //end;
  // Aligning of the bound label
  if Assigned(BoundLabel) and Assigned(BoundLabel.FtheLabel) then
    case Message.Msg of
    CM_VISIBLECHANGED :
      begin
      BoundLabel.FtheLabel.Visible := Visible;
      BoundLabel.AlignLabel
      end;
    CM_ENABLEDCHANGED :
      begin
      BoundLabel.FtheLabel.Enabled := Enabled;
      BoundLabel.AlignLabel
      end;
    CM_BIDIMODECHANGED :
      begin
      BoundLabel.FtheLabel.BiDiMode := BiDiMode;
      BoundLabel.AlignLabel
      end;
    end;
  end;  
end;

procedure TsGifVirtualStringTree.Paint;
begin
inherited Paint;
if ListSW <> nil then
  begin
  acSBUtils.Ac_NCPaint(ListSW.sBarVert.sw, Handle, 0, 0);
  acSBUtils.Ac_NCPaint(ListSW.sBarHorz.sw, Handle, 0, 0);
  end;
end;

procedure TsGifVirtualStringTree.Repaint;
begin
inherited;
if ListSW <> nil then
  begin
  acSBUtils.Ac_NCPaint(ListSW.sBarVert.sw, Handle, 0, 0);
  acSBUtils.Ac_NCPaint(ListSW.sBarHorz.sw, Handle, 0, 0);
  end;
end;

end.

