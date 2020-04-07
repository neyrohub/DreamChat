unit CVScroll;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Graphics;

const
  cvVersion = 'TCVScroller v0.32 by Bajenov Andrey';

type
  TCVScroller = class(TCustomControl)
  private
    FTracking: Boolean;
    FFullRedraw: Boolean;
    FVScrollVisible: Boolean;
    FOnVScrolled: TNotifyEvent;
    FMouseWheelXStep: Integer;
    FMouseWheelYStep: Integer;
    FVSmallStep, FHSmallStep, FVPageStep, FHPageStep: integer;
    function  GetVScrollPos: Integer;
    function  GetVScrollMax: Integer;
    procedure SetVScrollPos(Pos: Integer);
    procedure SetVScrollVisible(vis: Boolean);
  protected
    HPos, VPos, XSize, YSize: Integer;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure UpdateScrollBars(XS, YS: Integer);
    procedure WMHScroll(var Message: TWMHScroll); message WM_HSCROLL;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMMouseWheel(var Message: TWMMouseWheel); message WM_MOUSEWHEEL;

    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure SetVPos(p: Integer);
    procedure SetHPos(p: Integer);
    procedure Paint; override;
    procedure ScrollChildren(dx, dy: Integer);
    procedure UpdateChildren;
    property FullRedraw: Boolean read FFullRedraw write FFullRedraw;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);override;
    procedure ScrollTo(y: Integer);
    property VScrollPos: Integer read GetVScrollPos write SetVScrollPos;
    property VScrollMax: Integer read GetVScrollMax;
    property VScrollStep: Integer read FVSmallStep write FVSmallStep;
    property HScrollStep: Integer read FHSmallStep write FHSmallStep;
    property VPageScrollStep: Integer read FVPageStep write FVPageStep;
    property HPageScrollStep: Integer read FHPageStep write FHPageStep;
  published
    { Published declarations }
    property MouseWheelXStep: Integer read FMouseWheelXStep;
    property MouseWheelYStep: Integer read FMouseWheelYStep;
    property Visible;
    property TabStop;
    property TabOrder;
    property Align;
    property HelpContext;
    property Tracking: Boolean read FTracking write FTracking;
    property VScrollVisible: Boolean read FVScrollVisible write SetVScrollVisible;
    property OnVScrolled: TNotifyEvent read FOnVScrolled write FOnVScrolled;
  end;

//procedure Tag2Y(AControl: TControl);

implementation
{------------------------------------------------------}
{procedure Tag2Y(AControl: TControl);
begin
if AControl.Tag>10000 then
  AControl.Top := 10000
else
  if AControl.Tag<-10000 then
    AControl.Top := -10000
  else
    AControl.Top := AControl.Tag;
end;}
{------------------------------------------------------}
constructor TCVScroller.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
 TabStop := True;
 FTracking := True;
 FFullRedraw := False;
 FVScrollVisible := True;
 FMouseWheelXStep := 20;
 FMouseWheelYStep := 20;
 FVSmallStep := 10;
 FHSmallStep := 10;
 FVPageStep := 50;
 FHPageStep := 50;
 VPos := 0;
 HPos := 0;
end;
{------------------------------------------------------}
procedure TCVScroller.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);   //CreateWindow
  Params.Style := Params.Style or WS_CLIPCHILDREN or WS_HSCROLL or WS_VSCROLL;
end;
{------------------------------------------------------}
procedure  TCVScroller.CreateWnd;
begin
  inherited CreateWnd;
  UpdateScrollBars(ClientWidth, ClientHeight);
end;
{------------------------------------------------------}
procedure TCVScroller.UpdateScrollBars(XS, YS: Integer);
var
  ScrollInfo: TScrollInfo;
begin
  XSize := XS;
  YSize := YS;
  ScrollInfo.cbSize := SizeOf(ScrollInfo);
  ScrollInfo.fMask := SIF_ALL;
  ScrollInfo.nMin := 0;
  ScrollInfo.nPage := ClientHeight;
  ScrollInfo.nMax := YSize;
  ScrollInfo.nPos := VPos;
  ScrollInfo.nTrackPos := 0;
  SetScrollInfo(Handle, SB_VERT, ScrollInfo, True);
  if not FVScrollVisible then
    ShowScrollBar(Handle, SB_VERT, FVScrollVisible);

  ScrollInfo.fMask := SIF_ALL;
  ScrollInfo.nMin := 0;
  ScrollInfo.nMax := XSize-1;
  ScrollInfo.nPage := ClientWidth;
  ScrollInfo.nPos := HPos;
  ScrollInfo.nTrackPos := 0;
  SetScrollInfo(Handle, SB_HORZ, ScrollInfo, True);
  //UpdateChildren;
end;
{------------------------------------------------------}
procedure TCVScroller.UpdateChildren;
var i: Integer;
begin
//    for i:=0 to ControlCount-1 do
//      Tag2Y(Controls[i]);
end;
{------------------------------------------------------}
procedure TCVScroller.ScrollChildren(dx, dy: Integer);
var i: Integer;
begin
  if (dx=0) and (dy=0) then exit;
  for i:=0 to ControlCount-1 do begin
   if dy<>0 then begin
    Controls[i].Tag := Controls[i].Tag+dy;
//    Tag2Y(Controls[i]);
   end;
   if dx<>0 then Controls[i].Left := Controls[i].Left + dx;
  end
end;
{------------------------------------------------------}
procedure TCVScroller.WMHScroll(var Message: TWMHScroll);
begin
  with Message do
    case ScrollCode of
      SB_LINEUP: SetHPos(HPos - FHSmallStep);
      SB_LINEDOWN: SetHPos(HPos + FHSmallStep);
      SB_PAGEUP: SetHPos(HPos - FHPageStep);
      SB_PAGEDOWN: SetHPos(HPos + FHPageStep);
      SB_THUMBPOSITION: SetHPos(Pos);
      SB_THUMBTRACK: if FTracking then SetHPos(Pos);
      SB_TOP: SetHPos(0);
      SB_BOTTOM: SetHPos(XSize);
    end;

end;
{------------------------------------------------------}
procedure TCVScroller.WMVScroll(var Message: TWMVScroll);
begin
  with Message do
    case ScrollCode of
      SB_LINEUP: SetVPos(VPos - FVSmallStep);
      SB_LINEDOWN: SetVPos(VPos + FVSmallStep);
      SB_PAGEUP: SetVPos(VPos - FVPageStep);
      SB_PAGEDOWN: SetVPos(VPos + FVPageStep);
      SB_THUMBPOSITION: SetVPos(Pos);
      SB_THUMBTRACK: if FTracking then SetVPos(Pos);
      SB_TOP: SetVPos(0);
      SB_BOTTOM: SetVPos(YSize);
    end;

end;
{------------------------------------------------------}
procedure TCVScroller.WMMouseWheel(var Message: TWMMouseWheel);
begin
if Message.WheelDelta < 0 then
  SetVPos(VPos + FMouseWheelYStep)
else
  SetVPos(VPos - FMouseWheelYStep);
end;
{------------------------------------------------------}
procedure TCVScroller.WMKeyDown(var Message: TWMKeyDown);
var vScrollNotify, hScrollNotify: Integer;
begin
  vScrollNotify := -1;
  hScrollNotify := -1;
  with Message do
    case CharCode of
        VK_UP:
            vScrollNotify := SB_LINEUP;
        VK_PRIOR:
            vScrollNotify := SB_PAGEUP;
        VK_NEXT:
            vScrollNotify := SB_PAGEDOWN;
        VK_DOWN:
            vScrollNotify := SB_LINEDOWN;
        VK_HOME:
            vScrollNotify := SB_TOP;
        VK_END:
            vScrollNotify := SB_BOTTOM;
        VK_LEFT:
            hScrollNotify := SB_LINELEFT;
        VK_RIGHT:
            hScrollNotify := SB_LINERIGHT;
    end;
  if (vScrollNotify <> -1) then
        Perform(WM_VSCROLL, vScrollNotify, 0);
  if (hScrollNotify <> -1) then
        Perform(WM_HSCROLL, hScrollNotify, 0);
  inherited;
end;
{------------------------------------------------------}
procedure TCVScroller.SetVPos(p: Integer);
var   ScrollInfo: TScrollInfo;
      oldPos: Integer;
      r: TRect;
begin
  OldPos := VPos;
  VPos := p;
  ScrollInfo.cbSize := SizeOf(ScrollInfo);
  ScrollInfo.nPos := VPos;
  ScrollInfo.fMask := SIF_POS;
  SetScrollInfo(Handle, SB_VERT, ScrollInfo, True);
  GetScrollInfo(Handle, SB_VERT, ScrollInfo);
  VPos := ScrollInfo.nPos;
  r := ClientRect;
  r := self.GetClientRect;
  if OldPos - VPos <> 0 then
    begin
    if FFullRedraw then
      begin
      ScrollChildren(0, (OldPos - VPos));
      Refresh;
      end
    else
      begin
      ScrollWindowEx(Handle, 0, (OldPos - VPos), nil, @r, 0, nil, SW_ERASE
                    {SW_INVALIDATE}  {or SW_SCROLLCHILDREN}  {SW_ERASE}
                     );
//если ставить SW_INVALIDATE то прокрутка осуществляется без дополнительной перерисовки
//однако координаты уходят в минус и смайлики бесятся!
      INVALIDATE;
      ScrollChildren(0, (OldPos - VPos));
      end;
    if Assigned(FOnVScrolled) then  FOnVScrolled(Self);
    end;
end;
{------------------------------------------------------}
procedure TCVScroller.SetHPos(p: Integer);
var   ScrollInfo: TScrollInfo;
      oldPos: Integer;
      r: TRect;
begin
  OldPos := HPos;
  HPos := p;
  ScrollInfo.cbSize := SizeOf(ScrollInfo);
  ScrollInfo.nPos := HPos;
  ScrollInfo.fMask := SIF_POS;
  SetScrollInfo(Handle, SB_HORZ, ScrollInfo, True);
  GetScrollInfo(Handle, SB_HORZ, ScrollInfo);
  HPos := ScrollInfo.nPos;
  r := ClientRect;
  if OldPos-HPos <> 0 then begin
   if FFullRedraw then begin
         ScrollChildren((OldPos - HPos), 0);
         Refresh;
       end
   else begin
         ScrollWindowEx(Handle, (OldPos - HPos), 0,  nil, @r, 0, nil, SW_INVALIDATE{or
                   SW_SCROLLCHILDREN});
         ScrollChildren((OldPos - HPos), 0);
       end;
  end;
end;
{------------------------------------------------------}
procedure TCVScroller.Paint;
var i: Integer;
begin
 Canvas.Font.Color := clRed;
 Canvas.Font.Size := 2;
 Canvas.FillRect(Canvas.ClipRect);
 for i := Canvas.ClipRect.Top  to Canvas.ClipRect.Bottom do
   Canvas.TextOut(-HPos, i, IntToStr(i + VPos));
end;
{------------------------------------------------------}
procedure TCVScroller.ScrollTo(y: Integer);
begin
//сделать ScrollToItem() но в другом модуле.
SetVPos(y);
end;
{-------------------------------------------------------}
function TCVScroller.GetVScrollPos: Integer;
begin
  GetVScrollPos := VPos;
end;
{-------------------------------------------------------}
procedure TCVScroller.SetVScrollPos(Pos: Integer);
begin
   SetVPos(Pos);
end;
{-------------------------------------------------------}
function TCVScroller.GetVScrollMax: Integer;
var ScrollInfo: TScrollInfo;
begin
  ScrollInfo.cbSize := SizeOf(ScrollInfo);
  ScrollInfo.nPos := HPos;
  ScrollInfo.fMask := SIF_RANGE or SIF_PAGE;
  GetScrollInfo(Handle, SB_VERT, ScrollInfo);
  GetVScrollMax := ScrollInfo.nMax - Integer(ScrollInfo.nPage-1);
end;
{-------------------------------------------------------}
procedure TCVScroller.SetVScrollVisible(vis: Boolean);
begin
    FVScrollVisible := vis;
    ShowScrollBar(Handle, SB_VERT, vis);
end;
{-------------------------------------------------------}
procedure TCVScroller.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS;
end;
end.
