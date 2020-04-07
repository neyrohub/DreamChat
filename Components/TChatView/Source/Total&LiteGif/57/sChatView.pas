unit sChatView;

//*****************************************************************************
//*          Skin version TChatView for AlphaControls 5.x                     *
//*                   by Bajenov Andrey 2007(c)                               *
//*                   e-mail: neyro@mail.ru                                   *
//*****************************************************************************

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
    //Timer1: TTimer;
    ListSW : TacScrollWnd;//это и есть скин ScrollBars
    procedure Paint; override;//перегружаем свою отрисовку, чтобы поправить размер VBar
    procedure Repaint; override;//перегружаем свою отрисовку, чтобы поправить размер VBar
    //procedure Timer1Timer(Sender: TObject);
    procedure AfterConstruction; override;
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
  published
    property BoundLabel : TsBoundLabel read FBoundLabel write FBoundLabel;
    //property CharCase;//не знаю что это
    property DisabledKind : TsDisabledKind read FDisabledKind write SetDisabledKind default DefDisabledKind;
    property SkinData : TsCommonData read FCommonData write FCommonData;
  end;

implementation

uses sMaskData, sStyleSimply, acUtils, sMessages, sSKinProps, sVCLUtils, sGraphUtils, sAlphaGraph;


procedure TsChatView.AfterConstruction;
begin
  inherited AfterConstruction;
  FCommonData.Loaded;
end;

constructor TsChatView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FCommonData := TsCommonData.Create(Self, {$IFDEF DYNAMICCACHE} False {$ELSE} True {$ENDIF});
  FCommonData.COC := COC_TsEdit;
  if FCommonData.SkinSection = '' then FCommonData.SkinSection := s_Edit;
  FDisabledKind := DefDisabledKind;
  FBoundLabel := TsBoundLabel.Create(Self, FCommonData);
  //Timer1 := TTimer.Create(self);
  //Timer1.OnTimer := self.Timer1Timer;
//MessageBox(0, PChar('Create'), PChar(IntToStr(0)), MB_OK);
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
  inherited Loaded;
  FCommonData.Loaded;
  RefreshEditScrolls(SkinData, ListSW);
end;

procedure TsChatView.SetDisabledKind(const Value: TsDisabledKind);
begin
if FDisabledKind <> Value then
  begin
  FDisabledKind := Value;
  FCommonData.Invalidate;
  end;
end;

procedure TsChatView.Paint;
var imin, imax: integer;
begin
inherited Paint;
//GetScrollRange(Handle, SB_VERT, imin, imax);
//ListSW.sBarVert.ScrollInfo.nMax := imax;
//MessageBox(0, PChar(0), PChar(IntToStr(0)), MB_OK);

if ListSW <> nil then
  begin
  acSBUtils.Ac_NCPaint(ListSW.sBarVert.sw, Handle, 0, 0);
  acSBUtils.Ac_NCPaint(ListSW.sBarHorz.sw, Handle, 0, 0);
  end;
end;

procedure TsChatView.Repaint;
var imin, imax: integer;
begin
inherited;
//GetScrollRange(Handle, SB_VERT, imin, imax);
//ListSW.sBarVert.ScrollInfo.nMax := imax;
//MessageBox(0, PChar(0), PChar(IntToStr(0)), MB_OK);

if ListSW <> nil then
  begin
  acSBUtils.Ac_NCPaint(ListSW.sBarVert.sw, Handle, 0, 0);
  acSBUtils.Ac_NCPaint(ListSW.sBarHorz.sw, Handle, 0, 0);
  end;
end;


{procedure TsChatView.Timer1Timer(Sender: TObject);
var mes: TWMVSCROLL;
begin
RefreshEditScrolls(SkinData, ListSW);
end;}

procedure TsChatView.WndProc(var Message: TMessage);
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
        if ListSW <> nil then
          begin
//          self.UpdateScrollBars(0, ListSW.sBarVert.ScrollInfo.nMax);
//          SetScrollRange(Self.Handle, SB_VERT, 0, ListSW.sBarVert.ScrollInfo.nMax, true);
          FreeAndNil(ListSW);
          end;
        CommonWndProc(Message, FCommonData);
        if not FCommonData.CustomColor then Color := clWindow;
        if not FCommonData.CustomFont then Font.Color := clWindowText;
//        SetScrollPos(Handle, SB_VERT, TWMVSCROLL(Message).Pos, TRUE);
        RecreateWnd;
        self.Format;
        self.Repaint;
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
              //OnDebug('SB_THUMBPOSITION: ' + IntToStr(TWMVSCROLL(Message).Pos), '');

              //SetScrollPos(Handle, SB_VERT, TWMVSCROLL(Message).Pos, TRUE);
              self.VScrollPos := ListSW.sBarVert.ScrollInfo.nTrackPos;
              acSBUtils.Ac_NCPaint(ListSW.sBarVert.sw, Handle, 0, 0);
              end;
            SB_THUMBTRACK:
              begin
              //OnDebug('SB_THUMBTRACK: ' + IntToStr(TWMVSCROLL(Message).Pos), '');
              //self.VScrollPos := TWMVSCROLL(Message).Pos;
              self.VScrollPos := ListSW.sBarVert.ScrollInfo.nTrackPos;
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

end.

