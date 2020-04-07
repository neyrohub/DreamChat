unit PtblCV;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CVScroll, ChatView, Printers, CommDlg, CVStyle;

{$I CV_Defs.inc}

type
  {------------------------------------------------------------}
  TCVPrintingStep = (cvpsStarting, cvpsProceeding, cvpsFinished);
  TCVPrintingEvent = procedure (Sender: TChatView; PageCompleted: Integer; Step:TCVPrintingStep) of object;
  {------------------------------------------------------------}
  TCVPageInfo = class (TCollectionItem)
    public
      StartY, StartLineNo : Integer;
      procedure Assign(Source: TPersistent); override;
  end;
  {------------------------------------------------------------}
  EInvalidPageNo = class(Exception);
  EStyleNotAssigned = class(Exception);
  {------------------------------------------------------------}
  TPrintableCV = class(TChatView)
  private
    { Private declarations }
    FOnFormatting, FOnPrinting: TCVPrintingEvent;
    pagescoll: TCollection;
    FLeftMarginMM, FRightMarginMM, FTopMarginMM, FBottomMarginMM: Integer;
    TmpLM, TmpTM, TmpRM, TmpBM: Integer;
    PrinterSad: TScreenAndDevice;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function FormatPages: Integer;
    procedure DrawPage(pgNo: Integer; Canvas: TCanvas);
    procedure PrintPages(firstPgNo, lastPgNo: Integer; Title: String;
                         Copies: Integer; Collate: Boolean);
    procedure Print(Title: String;
                    Copies: Integer; Collate: Boolean);
  published
    { Published declarations }
    property OnFormatting: TCVPrintingEvent read FOnFormatting write FOnFormatting;
    property OnSendingToPrinter: TCVPrintingEvent read FOnPrinting write FOnPrinting;
  end;
  {------------------------------------------------------------}
  TCVPrint = class(TComponent)
  private
    { Private declarations }
    FOnFormatting, FOnPrinting: TCVPrintingEvent;
    function GetLM: Integer;
    function GetRM: Integer;
    function GetTM: Integer;
    function GetBM: Integer;
    procedure SetLM(mm: Integer);
    procedure SetRM(mm: Integer);
    procedure SetTM(mm: Integer);
    procedure SetBM(mm: Integer);
    function GetPagesCount: Integer;
  protected
    { Protected declarations }
  public
    { Public declarations }
    cv: TPrintableCV;
    constructor Create(AOwner: TComponent); override;
    procedure AssignSource(PrintMe: TChatView);
    procedure Clear;
    function FormatPages(PrintOptions:TCVDisplayOptions): Integer;
    procedure PrintPages(firstPgNo, lastPgNo: Integer; Title: String;
                         Copies: Integer; Collate: Boolean);
    procedure Print(Title: String; Copies: Integer; Collate: Boolean);
    procedure MakePreview(pgNo: Integer; bmp: TBitmap);

  published
    { Published declarations }
    property PagesCount: Integer read GetPagesCount;
    property LeftMarginMM:  Integer read GetLM write SetLM;
    property RightMarginMM: Integer read GetRM write SetRM;
    property TopMarginMM:   Integer read GetTM write SetTM;
    property BottomMarginMM:Integer read GetBM write SetBM;
    property OnFormatting: TCVPrintingEvent read FOnFormatting write FOnFormatting;
    property OnSendingToPrinter: TCVPrintingEvent read FOnPrinting write FOnPrinting;
  end;
function GetPrinterDC: HDC;
implementation
{==================================================================}
procedure TCVPageInfo.Assign(Source: TPersistent);
begin
  if Source is TCVPageInfo then begin
    StartY := TCVPageInfo(Source).StartY;
    StartLineNo := TCVPageInfo(Source).StartLineNo;    
    end
  else
    inherited Assign(Source);
end;
{==================================================================}
type
  TPrinterDevice = class
    Driver, Device, Port: String;
  end;

function GetPrinterDC: HDC;
var ADevice, ADriver, APort: array[0..79] of Char;
    ADeviceMode: THandle;
    DevMode: PDeviceMode;
begin
  Printer.GetPrinter(ADevice,ADriver,APort,ADeviceMode);
  if ADeviceMode<>0 then
    DevMode := PDeviceMode(GlobalLock(ADeviceMode))
  else
    DevMode := nil;
  Result := CreateDC(ADriver, ADevice, APort, DevMode);
  if ADeviceMode<>0 then
    GlobalUnlock(ADeviceMode);
end;
{==================================================================}
constructor TCVPrint.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  cv := TPrintableCV.Create(Self);
  if not (csDesigning in ComponentState) then cv.Parent := TWinControl(Self.Owner);
  LeftMarginMM   := 20;
  RightMarginMM  := 20;
  TopMarginMM    := 20;
  BottomMarginMM := 20;
end;
{------------------------------------------------------------------}
function  TCVPrint.GetLM: Integer;
begin
   GetLM := cv.FLeftMarginMM;
end;
{------------------------------------------------------------------}
function  TCVPrint.GetRM: Integer;
begin
   GetRM := cv.FRightMarginMM;
end;
{------------------------------------------------------------------}
function  TCVPrint.GetTM: Integer;
begin
   GetTM := cv.FTopMarginMM;
end;
{------------------------------------------------------------------}
function  TCVPrint.GetBM: Integer;
begin
   GetBM := cv.FBottomMarginMM;
end;
{------------------------------------------------------------------}
procedure TCVPrint.SetLM(mm: Integer);
begin
   cv.FLeftMarginMM := mm;
end;
{------------------------------------------------------------------}
procedure TCVPrint.SetRM(mm: Integer);
begin
   cv.FRightMarginMM := mm;
end;
{------------------------------------------------------------------}
procedure TCVPrint.SetTM(mm: Integer);
begin
   cv.FTopMarginMM := mm;
end;
{------------------------------------------------------------------}
procedure TCVPrint.SetBM(mm: Integer);
begin
   cv.FBottomMarginMM := mm;
end;
{------------------------------------------------------------------}
function TCVPrint.FormatPages(PrintOptions:TCVDisplayOptions): Integer;
begin
  cv.DisplayOptions := PrintOptions;
  cv.FOnFormatting := FOnFormatting;
  FormatPages := cv.FormatPages;
end;
{------------------------------------------------------------------}
procedure TCVPrint.Print(Title: String; Copies: Integer; Collate: Boolean);
begin
  cv.FOnPrinting := FOnPrinting;
  cv.Print(Title, Copies, Collate);
end;
{------------------------------------------------------------------}
procedure TCVPrint.PrintPages(firstPgNo, lastPgNo: Integer; Title: String;
                              Copies: Integer; Collate: Boolean);
begin
  cv.FOnPrinting := FOnPrinting;
  cv.PrintPages(firstPgNo, lastPgNo, Title, Copies, Collate);
end;
{------------------------------------------------------------------}
procedure TCVPrint.AssignSource(PrintMe: TChatView);
begin
  cv.ShareLinesFrom(PrintMe);
  cv.Style := PrintMe.Style;
  cv.BackgroundBitmap := PrintMe.BackgroundBitmap;
  cv.BackgroundStyle := PrintMe.BackgroundStyle;
end;
{------------------------------------------------------------------}
procedure TCVPrint.Clear;
begin
  cv.Clear;
end;
{------------------------------------------------------------------}
procedure TCVPrint.MakePreview(pgNo: Integer; bmp: TBitmap);
var w,h: Integer;
begin
   w :=
     MulDiv(cv.Width+cv.TmpLM+cv.TmpRM, cv.Printersad.ppixScreen, cv.Printersad.ppixDevice);
   h :=
     MulDiv(cv.Height+cv.TmpTM+cv.TmpBM, cv.Printersad.ppiyScreen, cv.Printersad.ppiyDevice);
   if bmp.Width <> w then bmp.Width := w;
   if bmp.Height <> h then bmp.Height := h;
   bmp.Canvas.Brush.Color := clWhite;
   bmp.Canvas.Pen.Color := clWhite;
   bmp.Canvas.FillRect(Rect(0,0,bmp.Width, bmp.Height));
   cv.DrawPage(pgNo, bmp.Canvas);
end;
{------------------------------------------------------------------}
function TCVPrint.GetPagesCount: Integer;
begin
   GetPagesCount := cv.pagescoll.Count;
end;
{==================================================================}
constructor TPrintableCV.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  pagescoll := TCollection.Create(TCVPageInfo);
  Visible := False;
  ContStorage.Free;
  ContStorage := nil;
  ShareContents := True;
end;
{------------------------------------------------------------------}
destructor TPrintableCV.Destroy;
begin
  pagescoll.Free;
  inherited Destroy;
end;
{------------------------------------------------------------------}
function TPrintableCV.FormatPages: Integer;
var i,j       : Integer;
    dli, dli2, dli3 :TDrawContainerInfo;
    nextnewline  : Integer;
    cvpi       : TCVPageInfo;
    nPages    : Integer;
    PrinterCanvas : TCanvas;
    PHDC: HDC;
    lpy, lpx, StartY : Integer;

begin
   if Assigned(FOnFormatting) then FOnFormatting(Self,0, cvpsStarting);
   VScrollVisible := False;

   PrinterCanvas := TCanvas.Create;
   PHDC := GetPrinterDC;
   PrinterCanvas.Handle := PHDC;
   lpy := GetDeviceCaps(PHDC, LOGPIXELSY);
   lpx := GetDeviceCaps(PHDC, LOGPIXELSX);
   PrinterCanvas.Font.PixelsPerInch := lpy;
   Width := Printer.PageWidth -MulDiv(FLeftMarginMM+FRightMarginMM, 5, 127)*lpx;
   Height:= Printer.PageHeight - MulDiv(FTopMarginMM+FBottomMarginMM, 5, 127)*lpy;
   lpx := GetDeviceCaps(PHDC, HORZSIZE);
   lpy := GetDeviceCaps(PHDC, VERTSIZE);
   TmpLM := MulDiv(FLeftMarginMM, Printer.PageWidth, lpx);
   TmpTM := MulDiv(FTopMarginMM, Printer.PageHeight, lpy);
   TmpRM := MulDiv(FRightMarginMM, Printer.PageWidth, lpx);
   TmpBM := MulDiv(FBottomMarginMM, Printer.PageHeight, lpy);
   Format_(False, 0, PrinterCanvas, False);
   InfoAboutSaD(PrinterSaD, PrinterCanvas);
   PrinterCanvas.Handle := 0;
   PrinterCanvas.Free;
   DeleteDC(PHDC);

   PagesColl.Clear;
   FormatPages := 0;
   if DrawContainers.Count = 0 then exit;
   nPages := 1;
   cvpi     := TCVPageInfo(PagesColl.Add);
   cvpi.StartY := 0;
   cvpi.StartLineNo := 0;
   StartY := 0;
   i := 0;
   if Assigned(FOnFormatting) then FOnFormatting(Self,0, cvpsProceeding);
   while i<DrawContainers.Count do
   begin
      dli := TDrawContainerInfo(DrawContainers.Objects[i]);
      if dli.Bottom^{ + dli.Height}>StartY+Height then begin { i-th item does not fit in page }
//      if dli.Top^ + dli.Height>StartY+Height then begin { i-th item does not fit in page }
        nextnewline := i;
        { searching first item in first last in new page }
        for j:=i downto 0 do
        begin
          dli2 := TDrawContainerInfo(DrawContainers.Objects[j]);
//          if (j<>i) and (dli2.Top^ + dli2.Height <= dli.Top^) then break;
          if (j<>i) and (dli2.Bottom^{ + dli2.Height} <= {dli.Top^}dli.Bottom^) then break;
          nextnewline := j;
        end;
        { page must contain one item at least}
        if nextnewline = TCVPageInfo(PagesColl.Items[nPages-1]).StartLineNo then
           inc(nextnewline);
        if nextnewline<>DrawContainers.Count then begin
           { searching min y of first line in new page }
           dli2 := TDrawContainerInfo(DrawContainers.Objects[nextnewline]);
//           StartY := dli2.Top^;
           StartY := dli2.Bottom^ - dli2.Height;
           for j := nextnewline+1 to DrawContainers.Count-1 do begin
             dli3 := TDrawContainerInfo(DrawContainers.Objects[j]);
//             if (dli3.Top^ >= dli2.Top^ + dli2.Height) then break;
//             if dli3.Top^ < StartY then StartY := dli3.Top^;
             if (dli3.Bottom^ >= dli2.Bottom^) then break;
             if dli3.Bottom^ < StartY then StartY := dli3.Bottom^;
           end;
           cvpi             := TCVPageInfo(PagesColl.Add);
           cvpi.StartLineNo := nextnewline;
           cvpi.StartY      := StartY;
           if Assigned(FOnFormatting) then FOnFormatting(Self,nPages, cvpsProceeding);
           inc(nPages);           
        end;
        i := nextnewline;
        end
      else
        inc(i);
   end;
   if Assigned(FOnFormatting) then FOnFormatting(Self,nPages,cvpsProceeding);
   FormatPages := nPages;
   if Assigned(FOnFormatting) then FOnFormatting(Self,nPages, cvpsFinished);
end;
{------------------------------------------------------------------}

procedure DrawOnDevice(Canvas: TCanvas; x,y: Integer; sad:TScreenAndDevice; gr: TGraphic);
var
  Info: PBitmapInfo;
  InfoSize: DWORD;
  Image: Pointer;
  ImageSize: DWORD;
  Bits: HBITMAP;
  DIBWidth, DIBHeight: Longint;
  PrintWidth, PrintHeight: Longint;
begin
 if gr is TBitmap then begin
     Bits := TBitmap(gr).Handle;
     GetDIBSizes(Bits, InfoSize, ImageSize);
     Info := AllocMem(InfoSize);
     try
        Image := AllocMem(ImageSize);
        try
          GetDIB(Bits, 0, Info^, Image^);
          with Info^.bmiHeader do
            begin
              DIBWidth := biWidth;
              DIBHeight := biHeight;
            end;
            PrintWidth := MulDiv(DIBWidth, sad.ppixDevice, sad.ppixScreen);
            PrintHeight:= MulDiv(DIBHeight, sad.ppiyDevice, sad.ppiyScreen);
            StretchDIBits(Canvas.Handle, x, y, PrintWidth, PrintHeight, 0, 0,
              DIBWidth, DIBHeight, Image, Info^, DIB_RGB_COLORS, SRCCOPY);
        finally
          FreeMem(Image, ImageSize);
        end;
     finally
        FreeMem(Info, InfoSize);
     end;
 end;
end;
{------------------------------------------------------------------}
procedure TPrintableCV.DrawPage(pgNo: Integer; Canvas: TCanvas);
var i: Integer;
    TxtStyle: TFontInfo;
    dli:TDrawContainerInfo;
    li: TContainerInfo;
    zerocoord: Integer;
    first, last: Integer;
    sad:TScreenAndDevice;
    background, tmpbmp : TBitmap;
    BackWidth, BackHeight: Integer;
    wmf: TMetafile;
begin
 if not Assigned(FStyle) then begin
  raise EStyleNotAssigned.Create('Style of printable TChatView component is not assigned');
  exit;
 end;
 if (pgNo<1) or (pgNo>PagesColl.Count) then begin
  raise EInvalidPageNo.Create('Invalid page number is specified for printing');
  exit;
 end;
 first := TCVPageInfo(PagesColl.Items[pgNo-1]).StartLineNo;
 if pgNo=PagesColl.Count then
   last := DrawContainers.Count-1
 else
   last := TCVPageInfo(PagesColl.Items[pgNo]).StartLineNo-1;
 zerocoord := TCVPageInfo(PagesColl.Items[pgNo-1]).StartY-TmpTM;
 Canvas.Brush.Style := bsClear;
 InfoAboutSaD(sad, Canvas);
 BackWidth  := MulDiv(Width,  printersad.ppixScreen, printersad.ppixDevice);
 BackHeight := MulDiv(Height, printersad.ppiyScreen, printersad.ppiyDevice);
 if (BackGroundStyle <> bsNoBitmap) and (BackGroundBitmap<>nil) then begin
    if BackGroundStyle=bsTiledAndScrolled then BackGroundStyle:=bsTiled;
    background := TBitmap.Create;
    background.Width := BackWidth;
    background.Height := BackHeight;
    DrawBack(background.Canvas.Handle, Rect(0,0, BackWidth, BackHeight),
             BackWidth, BackHeight);
    DrawOnDevice(Canvas,
          MulDiv(TmpLM, sad.ppixDevice, Printersad.ppixDevice),
          MulDiv(TmpTM, sad.ppiyDevice, Printersad.ppiyDevice),
          sad, background);
    end
 else begin
    background := nil;
    Canvas.Pen.Color := Style.Color;
    Canvas.Brush.Color := Style.Color;
    Canvas.FillRect(
      Rect(
        MulDiv(TmpLM, sad.ppixDevice, Printersad.ppixDevice),
        MulDiv(TmpTM, sad.ppiyDevice, Printersad.ppiyDevice),
        MulDiv(TmpLM, sad.ppixDevice, Printersad.ppixDevice)+
        MulDiv(BackWidth,  sad.ppixDevice, sad.ppixScreen),
        MulDiv(TmpTM, sad.ppiyDevice, Printersad.ppiyDevice)+
        MulDiv(BackHeight, sad.ppiyScreen, sad.ppiyScreen)));
 end;
 tmpbmp := TBitmap.Create;
try
 for i:=first to last do begin
   dli := TDrawContainerInfo(DrawContainers.Objects[i]);
   li := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]);
   TxtStyle := li.TxtStyle;
   if TxtStyle <> nil then { text }
     with TxtStyle do begin
       Canvas.Font.Color := Color;
       Canvas.Font.Style := Style;
       Canvas.Font.Size  := Size;
       Canvas.Font.Name  := FontName;
       {$IFDEF ChatViewDEF3}
       Canvas.Font.CharSet  := CharSet;
       {$ENDIF}
       Canvas.TextOut(
          MulDiv(dli.Left+TmpLM, sad.ppixDevice, Printersad.ppixDevice),
//          MulDiv( dli.Top^ - zerocoord, sad.ppiyDevice, Printersad.ppiyDevice),
          MulDiv( dli.Bottom^ - zerocoord, sad.ppiyDevice, Printersad.ppiyDevice),
          DrawContainers.Strings[i]);
       continue;
     end;
   case li.ObjStyle of
     -3,-4,-6:{ graphics } { hotspots and bullets }
       begin
       if li.gr is TMetafile then
         begin
         wmf := TMetafile.Create;
           try
             wmf.Assign(li.gr);
             wmf.Width  := MulDiv(TMetafile(li.gr).Width, sad.ppixDevice, sad.ppixScreen);
             wmf.Height := MulDiv(TMetafile(li.gr).Height, sad.ppiyDevice, sad.ppiyScreen);
             Canvas.Draw(
                         MulDiv(dli.Left+TmpLM, sad.ppixDevice, Printersad.ppixDevice),
                         //MulDiv( dli.Top^ - zerocoord, sad.ppiyDevice, Printersad.ppiyDevice),
                         //wmf);
                         MulDiv( dli.Bottom^ - zerocoord, sad.ppiyDevice, Printersad.ppiyDevice),
                         wmf);
           finally
             wmf.free;
           end;
         end
       else
         begin
         if li.ObjStyle = cvsPicture then
           begin
           tmpbmp.Width  := TGraphic(li.gr).Width;
           tmpbmp.Height := TGraphic(li.gr).Height;
           end
         else
           begin
           tmpbmp.Width  := TImageList(li.gr).Width;
           tmpbmp.Height := TImageList(li.gr).Height;
           end;
         if background<>nil then
           tmpbmp.Canvas.CopyRect(Rect(0,0, tmpbmp.Width, tmpbmp.Height),
                                  background.Canvas,
                                  Rect(MulDiv(dli.Left,
                                       Printersad.ppixScreen,
                                       Printersad.ppixDevice),
                                  //MulDiv(dli.Top^ - (zerocoord+TmpTM), Printersad.ppiyScreen, Printersad.ppiyDevice),
                                  MulDiv(dli.Bottom^ - (zerocoord+TmpTM), Printersad.ppiyScreen, Printersad.ppiyDevice),
                                  MulDiv(dli.Left, Printersad.ppixScreen, Printersad.ppixDevice)+tmpbmp.Width,
                                  //MulDiv(dli.Top^ - (zerocoord+TmpTM), Printersad.ppiyScreen, Printersad.ppiyDevice)+tmpbmp.Height
                                  MulDiv(dli.Bottom^ - (zerocoord+TmpTM), Printersad.ppiyScreen, Printersad.ppiyDevice)+tmpbmp.Height)
                                  )
         else
           begin
           tmpbmp.Canvas.Pen.Color := Style.Color;
            tmpbmp.Canvas.Brush.Color := Style.Color;
           tmpbmp.Canvas.FillRect(Rect(0,0, tmpbmp.Width, tmpbmp.Height));
           end;
         if li.ObjStyle = cvsPicture then
           tmpbmp.Canvas.Draw(0,0, TGraphic(li.gr))
         else
           TImageList(li.gr).Draw(tmpbmp.Canvas,0,0,li.imgNo);
           DrawOnDevice(Canvas,
                        MulDiv(dli.Left+TmpLM, sad.ppixDevice, Printersad.ppixDevice),
                        //MulDiv( dli.Top^ - zerocoord, sad.ppiyDevice, Printersad.ppiyDevice),
                        MulDiv( dli.Bottom^ - zerocoord, sad.ppiyDevice, Printersad.ppiyDevice),
                        sad, tmpbmp);
         end;
       end;
     -1: {break line}
       begin
       Canvas.Pen.Color := FStyle.TextStyles[0].Color;
       Canvas.MoveTo(MulDiv(dli.Left+TmpLM+MulDiv(5, printersad.ppixDevice, printersad.ppixScreen),
                     sad.ppixDevice, Printersad.ppixDevice),
                     //MulDiv(dli.Top^ - zerocoord + MulDiv(5, printersad.ppiyDevice, printersad.ppiyScreen),
                     MulDiv(dli.Bottom^ - zerocoord + MulDiv(5, printersad.ppiyDevice, printersad.ppiyScreen),
                     sad.ppiyDevice, Printersad.ppiyDevice));
       Canvas.LineTo(MulDiv(Width + TmpLM - MulDiv(5 + RightMargin, printersad.ppixDevice, printersad.ppixScreen),
                     sad.ppixDevice, Printersad.ppixDevice),
                     //MulDiv(dli.Top^ - zerocoord + MulDiv(5, printersad.ppiyDevice, printersad.ppiyScreen),
                     MulDiv(dli.Bottom^ - zerocoord + MulDiv(5, printersad.ppiyDevice, printersad.ppiyScreen),
                     sad.ppiyDevice, Printersad.ppiyDevice));
       end;
     { controls is not supported yet }
   end;
 end;
finally
  background.Free;
  tmpbmp.Free;
end;
end;
{------------------------------------------------------------------}
procedure TPrintableCV.PrintPages(firstPgNo, lastPgNo: Integer; Title: String;
                                  Copies: Integer; Collate: Boolean);
var i,copyno: Integer;
    PrinterCopies: Integer;
begin
   if Assigned(FOnPrinting) then FOnPrinting(Self,0, cvpsStarting);
   Printer.Title := Title;
   PrinterCopies := Printer.Copies; { storing }
   if pcCopies in Printer.Capabilities then
     begin
       Printer.Copies := Copies;
                                 // Printer can make copies and collation if needed
       Copies := 1;              // TChatView need not support copies and collation itself
     end
   else
     Printer.Copies := 1;        // TChatView will provide copies and collation itself
   Printer.BeginDoc;
   if Collate then
     for copyno:= 1 to Copies do
       for i := firstPgNo to lastPgNo do
       begin
         DrawPage(i, Printer.Canvas);
         if Assigned(FOnPrinting) then FOnPrinting(Self,i, cvpsProceeding);
         if not ((i=lastPgNo) and (copyno=Copies)) then Printer.NewPage;
       end
   else
     for i := firstPgNo to lastPgNo do
       for copyno:= 1 to Copies do
       begin
         DrawPage(i, Printer.Canvas);
         if Assigned(FOnPrinting) then FOnPrinting(Self,i, cvpsProceeding);
         if not ((i=lastPgNo) and (copyno=Copies)) then Printer.NewPage;         
       end;
   Printer.EndDoc;
   Printer.Copies := PrinterCopies; { restoring }
   if Assigned(FOnPrinting) then FOnPrinting(Self,0, cvpsFinished);
end;
{------------------------------------------------------------------}
procedure TPrintableCV.Print(Title: String; Copies: Integer; Collate: Boolean);
begin
   PrintPages(1, PagesColl.Count, Title, Copies, Collate);
end;

end.
