unit sChatView;

interface
{$I CV_Defs.inc}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ChatView, CVStyle, CVScroll, ClipBrd, ImgList,
  litegifx2, CVLiteGifAniX2, ExtCtrls, StdCtrls,
  sConst, sCommonData, sDefaults, acSBUtils,
  sScrollBar{ sDebugMsgs};

type
  TsChatView = class(TChatView)
  private
    FOnVScroll: TNotifyEvent;
    FOnScrollCaret: TNotifyEvent;
    FBoundLabel: TsBoundLabel;
    FCommonData: TsCommonData;
    FDisabledKind: TsDisabledKind;
    FOldDataChange : TNotifyEvent;
    procedure SetDisabledKind(const Value: TsDisabledKind);
    procedure DataChange(Sender: TObject);
  protected
    procedure WndProc (var Message: TMessage); override;
  public
    Timer1: TTimer;
    ListSW : TacScrollWnd;//это и есть скин ScrollBars
    procedure Paint;override;
    procedure Timer1Timer(Sender: TObject);
    procedure AfterConstruction; override;
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
  published
    property BoundLabel : TsBoundLabel read FBoundLabel write FBoundLabel;
//    property CharCase;
    property DisabledKind : TsDisabledKind read FDisabledKind write SetDisabledKind default DefDisabledKind;
    property SkinData : TsCommonData read FCommonData write FCommonData;
  end;

implementation

uses sMaskData, sStyleSimply, acUtils, sMessages, sSKinProps, sVCLUtils, sGraphUtils, sAlphaGraph;

{ TsChatView }
//var
//  ScrollsUpdating : boolean = False;

procedure TsChatView.AfterConstruction;
begin
  inherited AfterConstruction;
  FCommonData.Loaded;
end;

constructor TsChatView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{  ControlStyle := ControlStyle - [csOpaque];
  FCommonData := TsCommonData.Create(Self, {$IFDEF DYNAMICCACHE}
{   False {$ELSE}
{    True {$ENDIF}{);
{  FCommonData.COC := COC_TsMemo;
  if FCommonData.SkinSection = '' then FCommonData.SkinSection := s_Edit;
  FDisabledKind := DefDisabledKind;
  FBoundLabel := TsBoundLabel.Create(Self, FCommonData);
  ParentColor := False;}

  FCommonData := TsCommonData.Create(Self, {$IFDEF DYNAMICCACHE} False {$ELSE} True {$ENDIF});
  FCommonData.COC := COC_TsEdit;
  if FCommonData.SkinSection = '' then FCommonData.SkinSection := s_Edit;
  FDisabledKind := DefDisabledKind;
  FBoundLabel := TsBoundLabel.Create(Self, FCommonData);
  Timer1 := TTimer.Create(self);
  Timer1.OnTimer := self.Timer1Timer;
end;

procedure TsChatView.DataChange(Sender: TObject);
begin
  FOldDataChange(Sender);
end;

destructor TsChatView.Destroy;
begin
  if ListSW <> nil then FreeAndNil(ListSW);
  FreeAndNil(FBoundLabel);
  if Assigned(FCommonData) then FreeAndNil(FCommonData);
  inherited Destroy;
end;

procedure TsChatView.Loaded;
begin
{  inherited Loaded;
  FCommonData.Loaded;
  RefreshEditScrolls(SkinData, ListSW);}

  inherited Loaded;
  FCommonData.Loaded;
end;

procedure TsChatView.SetDisabledKind(const Value: TsDisabledKind);
begin
  if FDisabledKind <> Value then begin
    FDisabledKind := Value;
    FCommonData.Invalidate;
  end;
end;

{
procedure TsChatView.WndProc(var Message: TMessage);
begin
  if Message.Msg = SM_ALPHACMD then
    case Message.WParamHi of
    AC_CTRLHANDLED: begin
                    Message.LParam := 1; Exit
                    end; // AlphaSkins supported
    AC_SETNEWSKIN: begin
                   CommonWndProc(Message, FCommonData);
                   exit
                   end;
    AC_REMOVESKIN: begin
                   if ListSW <> nil then FreeAndNil(ListSW);
                   CommonWndProc(Message, FCommonData);
                   RecreateWnd;
                   exit;
                   end;
    AC_REFRESH: begin
                CommonWndProc(Message, FCommonData);
                Repaint;
                RefreshEditScrolls(SkinData, ListSW);
                exit;
                end;
    AC_ENDPARENTUPDATE: if FCommonData.Updating then
                          begin
                          FCommonData.Updating := False;
                          Perform(WM_NCPAINT, 0, 0);
                          Exit;
                          end;
    end;
  if not ControlIsReady(Self) or not FCommonData.Skinned then
    inherited
  else
    begin
    CommonWndProc(Message, FCommonData);
    inherited;
      case Message.Msg of
      CM_SHOWINGCHANGED: RefreshEditScrolls(SkinData, ListSW);
      EM_SETSEL: if Assigned(FOnScrollCaret) then FOnScrollCaret(Self);
      WM_HSCROLL, WM_VSCROLL : begin
                               //if TWMVScroll(Message).ScrollCode = SB_ENDSCROLL then
                                 RefreshEditScrolls(SkinData, ListSW);
                               if (Message.Msg = WM_VSCROLL) and Assigned(FOnVScroll) then
                                 begin
                                 FOnVScroll(Self);
                                 end;
                               end;
      end;
    end;
  // Aligning of the bound label
  if Assigned(BoundLabel) and Assigned(BoundLabel.FtheLabel) then
    case Message.Msg of
      WM_SIZE,
      WM_MOVE: BoundLabel.AlignLabel;
      CM_VISIBLECHANGED: begin
                         BoundLabel.FtheLabel.Visible := Visible; BoundLabel.AlignLabel
                         end;
      CM_ENABLEDCHANGED: begin
                         BoundLabel.FtheLabel.Enabled := Enabled; BoundLabel.AlignLabel
                         end;
      CM_BIDIMODECHANGED: begin
                          BoundLabel.FtheLabel.BiDiMode := BiDiMode; BoundLabel.AlignLabel
                          end;
    end;
end;
{--------------------------------------------------------}
{
procedure TsMemo.WndProc(var Message: TMessage);
begin
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_CTRLHANDLED : begin Message.LParam := 1; Exit end; // AlphaSkins supported
    AC_SETNEWSKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      BorderStyle := bsSingle;
      Ctl3D := True;
      CommonWndProc(Message, FCommonData);
      exit
    end;
    AC_REMOVESKIN : if LongWord(Message.LParam) = LongWord(SkinData.SkinManager) then begin
      CommonWndProc(Message, FCommonData);
      if Assigned(VSBar) then FreeAndNil(VSBar);
      if Assigned(HSBar) then FreeAndNil(HSBar);
      RecreateWnd;
      exit
    end;
    AC_REFRESH : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      CommonWndProc(Message, FCommonData);
      Perform(WM_ERASEBKGND, 0, 0);
      Repaint;
      exit
    end
  end;
  if not ControlIsReady(Self) or not FCommonData.Skinned then inherited else begin
    case Message.Msg of
//      WM_ERASEBKGND : if (csLoading in ComponentState) or FCommonData.Updating then Exit;
      WM_NCPAINT : begin
//        if not FCommonData.Updating then
        PaintBorder(TWMPaint(Message).DC);// else FCommonData.Updating := True;
        Exit;
      end;
      WM_PAINT : begin
        if ControlIsActive(FCommonData) then begin
          if not FCommonData.CustomColor and (Color <> FCommonData.SkinManager.gd[FCommonData.SkinIndex].HotColor) then Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].HotColor;
        end
        else if not FCommonData.CustomColor and (Color <> FCommonData.SkinManager.gd[FCommonData.SkinIndex].Color) then Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].Color;
        if not FCommonData.Updating then PaintBorder(0) else FCommonData.Updating := True;
        inherited;
        RefreshScrolls;
        exit;
      end;
      WM_PRINT : begin
        Perform(WM_PAINT, Message.WParam, Message.LParam);
        Perform(WM_NCPAINT, Message.WParam, Message.LParam);
        Exit;
      end;
    end;
    if not CommonWndProc(Message, FCommonData) then inherited;
    if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
      AC_URGENTPAINT : begin // v4.08
        if FCommonData.UrgentPainting then PrepareCache;
      end;
      AC_ENDPARENTUPDATE : if FCommonData.Updating then begin
        FCommonData.Updating := False;
        Perform(WM_NCPAINT, 0, 0);//Repaint;
        Exit
      end;
    end
    else case Message.Msg of
      CM_VISIBLECHANGED, CM_ENABLEDCHANGED, WM_SETFONT : begin
        FCommonData.Invalidate;
        if not (csFreeNotification in ComponentState) then RefreshScrolls;
      end;
      WM_LBUTTONDOWN : Down := True;
      WM_LBUTTONUP : Down := False;
      EM_SETSEL : if Assigned(FOnScrollCaret) then FOnScrollCaret(Self);
      WM_MOUSEWHEEL, WM_PASTE, WM_CUT, WM_CLEAR, WM_UNDO, WM_SETTEXT,
        CM_CHANGED, CM_INVALIDATE, CM_CONTROLLISTCHANGE :
          if not (csFreeNotification in ComponentState) then RefreshScrolls;
      WM_HSCROLL, WM_VSCROLL : begin
        RefreshScrolls;
        if (Message.Msg = WM_VSCROLL) and Assigned(FOnVScroll) then begin
          FOnVScroll(Self);
        end;
      end;
      CN_KEYDOWN, CN_KEYUP, WM_MOVE, CM_BIDIMODECHANGED, CM_PARENTBIDIMODECHANGED : if Visible and not (csLoading in ComponentState) and not (csFreeNotification in ComponentState) then RefreshScrolls;
      WM_MOUSEMOVE, WM_WINDOWPOSCHANGED : if Down and not (csDesigning in ComponentState) then RefreshScrolls;
      WM_SIZE : if Visible then begin
        Perform(WM_NCPAINT, Message.WParam, Message.LParam);
        RefreshScrolls;
      end;
    end;
  end;
  // Aligning of the bound label
  if Assigned(BoundLabel) and Assigned(BoundLabel.FtheLabel) then case Message.Msg of
    WM_SIZE, WM_WINDOWPOSCHANGED : begin BoundLabel.AlignLabel end;
    CM_VISIBLECHANGED : begin BoundLabel.FtheLabel.Visible := Visible; BoundLabel.AlignLabel end;
    CM_ENABLEDCHANGED : begin BoundLabel.FtheLabel.Enabled := Enabled; BoundLabel.AlignLabel end;
    CM_BIDIMODECHANGED : begin BoundLabel.FtheLabel.BiDiMode := BiDiMode; BoundLabel.AlignLabel end;
  end;
end;
}
procedure TsChatView.Paint;
begin
inherited;
acSBUtils.Ac_NCPaint(ListSW.sBarVert.sw, Handle, 0, 0, 0);
end;

procedure TsChatView.Timer1Timer(Sender: TObject);
var mes: TWMVSCROLL;
begin
//SetScrollPos(Handle, SB_VERT, 10, TRUE);
//acSBUtils.Ac_NCPaint(ListSW.sBarVert.sw, Handle, 0, 0);
//acSBUtils.SendScrollMessage(Handle, 0, 0, 10);
//ListSW.sBarVert.ScrollInfo.nTrackPos := 10;

//ListSW.sBarVert.fScrollVisible := false;

//ListSW.fThumbTracking := true;
//ListSW.DontRepaint := false;

//mes.Pos := 10;
//ListSW.acWndProc(TMessage(mes));
RefreshEditScrolls(SkinData, ListSW);
end;

procedure TsChatView.WndProc(var Message: TMessage);
begin
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
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
        begin
        end;
      WM_VSCROLL :
        begin
          case TWMVSCROLL(Message).ScrollCode of
            SB_THUMBPOSITION:
              begin
              //sConst, sCommonData, sDefaults, sMessages, acSBUtils
              OnDebug('SB_THUMBPOSITION: ' + IntToStr(TWMVSCROLL(Message).Pos), '');

              SetScrollPos(Handle, SB_VERT, TWMVSCROLL(Message).Pos, TRUE);
              acSBUtils.Ac_NCPaint(ListSW.sBarVert.sw, Handle, 0, 0);

//              acSBUtils.Ac_ThumbTrackVert(ListSW.sBarVert, Handle, 10, 10);
              //ListSW.sBarVert.ScrollInfo.nPos := TWMVSCROLL(Message).Pos;
//              acSBUtils.SendScrollMessage(Handle, 0, integer(ListSW.sBarVert.sw), TWMVSCROLL(Message).Pos);
//              ListSW.sBarVert.sw
//              acSBUtils.RefreshScrolls(SkinData, ListSW);
//              acSBUtils.UpdateScrolls(ListSW, true);
//               RefreshScrolls(SkinData, ListSW);
//              Ac_SetScrollInfo(ListSW.sBarVert.sw )
//              ListSW.sBarVert.  := false;
//              UpdateScrolls(ListSW, true);
//              RefreshEditScrolls(SkinData, ListSW);
              end;
            SB_THUMBTRACK:
              begin
              OnDebug('SB_THUMBTRACK: ' + IntToStr(TWMVSCROLL(Message).Pos), '');
              //inherited WndProc(Message);
              self.VScrollPos := TWMVSCROLL(Message).Pos;
              //Perform(Message.Msg, Message.WParam, Message.LParam);
              end;
            SB_ENDSCROLL:
              begin
              //acSBUtils.Ac_NCPaint(ListSW.sBarVert.sw, Handle, 0, 0);
              //OnDebug('SB_ENDSCROLL: ' + IntToStr(TWMVSCROLL(Message).Pos), '');
              //MessageBox(0, PChar('SB_THUMBTRACK'), PChar(IntToStr(0)), MB_OK);
              end;
          end;
        if Assigned(FOnVScroll) then
          begin
          FOnVScroll(Self);
          end;
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
    end;
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

end.

