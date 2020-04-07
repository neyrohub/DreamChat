unit ChatView;
//в этом юните переделана система отсчета! BaseLine это нижняя линия строки
//у объектов она прописана как BOTTOM и в методе Paint нужно переделать расчет
//координат верхнего левого угла объеков как .Bottom^ - .Heigth
//у Текста и BreakLine уже работает

interface
{$I CV_Defs.inc}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  CVStyle, CVScroll, ClipBrd, ImgList,
  litegif1, CVLiteGifAni, ExtCtrls;
  {------------------------------------------------------------------}



const
  cvVersion     = 'TChatView v0.39 by Bajenov Andrey';
  cvsBreak      = -1;
  cvsCheckPoint = -2;
  cvsPicture    = -3;
  cvsHotSpot    = -4;
  cvsComponent  = -5;
  cvsBullet     = -6;
  cvsGif        = -7;
  cvsGifAni     = -8;
  BeginSelection    = 0;
  ContinueSelection = 1;
  EndSelection      = 2;
type

  TChatView = class;
  TCVSaveFormat = (cvsfText,
                   cvsfHTML,
                   cvsfRTF, //<---not yet implemented
                   cvsfcvF  //<---not yet implemented
                   );
  TCVSaveOption = (cvsoOverrideImages);
  TCVSaveOptions = set of TCVSaveOption;
  {------------------------------------------------------------------}
  TDrawLineInfo = class
  {Объект, который содержит инфу о линии. Т.е. в одну линию у нас могут
   выводиться несколько контейнеров, чтобы у каждого контейнера не править
   BaseLine, сделаем чтобы все контейнеры одной линии ссылались на
   одну переменную BaseLine, тогда изменив одну переменную, мы подвинем сразу
   всю линию.
   Сюда также можно добавить и другие общие параметры объектов-контейнеров}
     BaseLine, MaxHeight: Integer;
     LineNumber: Integer;
  end;
  {------------------------------------------------------------------}
  TDrawContainerInfo = class
  {Объект-контейнер, который содержит инфу о том в какие координаты X,Y
   вывести свое содержимое. Содержимое, в зависимости от номера может
   быть текстом, GIF, Control и т.д.}
     Left, Width, Height: Integer;
     {Top делаем ссылкой на TDrawLineInfo}
     Bottom, LineNum: PInteger;
     ContainerNumber: Integer;
     FromNewLine: Boolean;
     pDrawLineInfo: TDrawLineInfo;
     {WordOffset:Integer;{только для текста! если больше 0 значит это
                         количество букв выделить с начала слова.
                         Если меньше нуля, то с конца}
     //ссылка на объект-линию, чтобы потом его можно было уничтожить
     //а то они будут терятся и будет происходить утечка памяти
  end;
  {------------------------------------------------------------------}
{поразмыслить над объединением их в один класс}
  TContainerInfo = class
  {Объект-контейнер, который содержит инфу о добавленных объектах, это
   может быть текстом, GIF, Control и т.д.}
     StyleNo: Integer;
     SameAsPrev: Boolean;
     Center: Boolean;
     imgNo: Integer; { for cvsJump# used as jump id }
     gr: TPersistent;
     fon: TBitMap;
  end;
  {------------------------------------------------------------------}
  TCPInfo = class
    public
     Y, LineNo: Integer;
  end;
  {------------------------------------------------------------------}
  TJumpInfo = class
    public
     l,t,w,h: Integer;
     id, idx: Integer;
  end;
  {------------------------------------------------------------------}
  TDebugEvent = procedure (Mess, Mess2: String) of object;
  TDrawGifAni = procedure (MirrorNumber:Word) of object;
  TBeginGifAni = procedure (DestCanvas:TCanvas; BackGroundColor:TColor) of object;
  TJumpEvent = procedure (Sender: TObject; id: Integer) of object;
  TCVMouseMoveEvent = procedure (Sender: TObject; id: Integer) of object;
  TCVSaveComponentToFileEvent = procedure (Sender: TChatView; Path: String; SaveMe: TPersistent; SaveFormat: TCVSaveFormat; var OutStr:String) of object;
  TCVURLNeededEvent = procedure (Sender: TChatView; id: Integer; var url:String) of object;
  TCVDblClickEvent = procedure  (Sender: TChatView; ClickedWord: String; Style: Integer) of object;
  TCVRightClickEvent = procedure  (Sender: TChatView; ClickedWord: String; Style, X, Y: Integer) of object;
  {------------------------------------------------------------------}
  TBackgroundStyle = (bsNoBitmap, bsStretched, bsTiled, bsTiledAndScrolled);
  {------------------------------------------------------------------}
  TCVDisplayOption = (cvdoImages, cvdoComponents, cvdoBullets);
  TCVDisplayOptions = set of TCVDisplayOption;
  {------------------------------------------------------------------}
  TScreenAndDevice = record
       ppixScreen, ppiyScreen, ppixDevice, ppiyDevice: Integer;
       LeftMargin: Integer;
   end;
  {------------------------------------------------------------------}
  TCVInteger2 = class
   public
    val: Integer;
  end;
  {------------------------------------------------------------------}
  TChatView = class(TCVScroller)
  private
    { Private declarations }
    FVersion: String;
    FDebugText:string;
    FDebugText2:string;
    BufferVirtCanv: TBitmap;//виртуальный КАНВАС! Сначала рисуем на нем потом копируем в реальный!
    TimerScrollStepY, ScrollDeltaY, ScrollToY: Integer;
    ScrollYSpeed: Word;
    ScrollTimer: TTimer;
    FAllowSelection, FSingleClick: Boolean;
    FDelimiters: String;
    FMergeDelimiters: String;
    DrawHover, Selection: Boolean;
    FOnJump: TJumpEvent;
    FOnDebug: TDebugEvent;//внимание! в программе ChatView1.OnDebug := Form1.Debug; иначе Access Violation !
    FOnCVMouseMove: TCVMouseMoveEvent;
    FOnSaveComponentToFile: TCVSaveComponentToFileEvent;
    FOnURLNeeded: TCVURLNeededEvent;
    FOnCVDblClick: TCVDblClickEvent;
    FOnCVRightClick: TCVRightClickEvent;
    FOnSelect, FOnResized: TNotifyEvent;
    FFirstJumpNo, FMaxTextWidth, FMinTextWidth, FLeftMargin, FRightMargin: Integer;
    FBackBitmap: TBitmap;
    FBackgroundStyle: TBackgroundStyle;
    OldWidth, OldHeight: Integer;
    FSelStartX, FSelStartY, FSelEndX, FSelEndY: Integer;
//    TmpStartX, TmpStartY, TmpEndX, TmpEndY: Integer;
    FSelStartContNo, FSelEndContNo, FSelStartOffsInCont, FSelEndOffsInCont: Integer;
    FSelStartPixOffsInCont, FSelEndPixOffsInCont: Integer;
    FGifAniObjNo : word;
    procedure InvalidateJumpRect(no: Integer);
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    procedure WMHScroll(var Message: TWMVScroll); message WM_HSCROLL;
//    procedure WMNCMOUSEMOVE(var Message: TMessage); message WM_NCMOUSEMOVE;
//    procedure CMInvalidate(var Message: TMessage); message CM_INVALIDATE;
    procedure DefaultDebug(Mess, Mess2: String);
    function GetLineCount: Integer;
    function GetPrevContainerInThisLine(DrawCont:TDrawContainerInfo): TContainerInfo;
    function GetMaxHeight(Line, FromObject:integer):Integer;
    function GetMinHeight(Line, FromObject:integer):Integer;
    function FindItemAtPos(X,Y: Integer): Integer;//ищет по всему отображаемому массиву (форматированных) объектов
    function FindItemAtScreenPos(ScrX, ScrY: Integer): Integer;//ищет по всему отображаемому массиву (форматированных) объектов
    function FindNearItemAtPos(X, Y: Integer): Integer;//ищет по всему отображаемому массиву (форматированных) объектов
    function FindNearItemAtScreenPos(ScrX, ScrY: Integer): Integer;//ищет по всему отображаемому массиву (форматированных) объектов
    procedure FindStartItemSelection();
    procedure FindEndItemSelection();
    function GetWordOffset(ContNumber:cardinal; XRange:integer;Str:PChar;StrLen:cardinal;
                           var SelContNo, SelPixOffsInCont:integer):integer;
    function FindSymbolAtScreenPos(ScrX, ScrY: Integer): String;
    procedure SetSelectionItems(X, Y: Integer);
    procedure SetGifAniCanvas(DestionationCanvas: TCanvas);
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CorrectSelectionBounds(x, y: integer);
    procedure RestoreSelBounds(StartNo, EndNo, StartOffs, EndOffs: Integer);
    procedure OnMouseUp(Sender: TObject; Button: TMouseButton;
              Shift: TShiftState; X, Y: Integer);
  protected
    { Protected declarations }
    DrawContainers:TStringList;
    checkpoints: TStringList;
    jumps: TStringList;
    FStyle: TCVStyle;
    nJmps: Integer;
    TextWidth, TextHeight: Integer;
    LastJumpMovedAbove: Integer;
    LastJumpDowned, XClicked, YClicked, XMouse, YMouse: Integer;
    imgSavePrefix: String;
    imgSaveNo: Integer;
    SaveOptions: TCVSaveOptions;
    skipformatting: Boolean;
    ShareContents: Boolean;

    procedure Notification(AComponent: TComponent; Operation: TOperation);override;
    procedure Click; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);override;
    procedure DblClick; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure FormatNextContainer(var DrawLineInfo:TDrawLineInfo;
                                  var LineNum, ContNum, x, baseline, Ascent:Integer;
                                  var sourceStrPtr:PChar;
                                  var newline{, CreateDrawLine}:boolean;
                                  Canvas: TCanvas; var sad: TScreenAndDevice);
{FormatNextContainer FormatNextContainer FormatNextContainer FormatNextContainer}




    procedure AdjustJumpsCoords;
//    procedure AdjustChildrenCoords;
    procedure ClearTemporal;
    function GetFirstVisibleContainer: cardinal;
    function GetLastVisibleContainer: cardinal;
    function GetLastContainerInLine(FromContainerNumber: cardinal): cardinal;
    function GetFirstContainerInLine(FromContainerNumber: cardinal): cardinal;
    procedure Format_(OnlyResized:Boolean; depth: Integer; Canvas: TCanvas; OnlyTail: Boolean);
    procedure SetBackBitmap(Value: TBitmap);
    procedure DrawBack(DC: HDC; Rect: TRect; Width,Height:Integer);
    procedure SetBackgroundStyle(Value: TBackgroundStyle);
    function GetNextFileName(Path: String): String; virtual;
    procedure ShareLinesFrom(Source: TChatView);
    procedure OnScrollTimer(Sender: TObject);
    procedure Loaded; override;
  public
    { Public declarations }
    DrawLinesInfo:TStringList;
    ContStorage:TStringList;
    {В этом списке построчно содержатся указатели на все контейнеры!!!!
    Контейнеры это отдельные объекты, которые сопоставлены со строками этого списка
    Если это текст, то строка заполнена текстом, а указатель указывает на
    контейнер со стилем. Если это картинта, то строка '', а указатель указывает
    на объект, содержащий атрибуты картинки}
    DisplayOptions: TCVDisplayOptions;
    FClientTextWidth: Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function FindClickedWord(var clickedword: String; var StyleNo: Integer): Boolean;
    procedure Paint; override;
    FUNCTION GetCanvas():TCanvas;
    procedure AddFromNewLine(s: String;StyleNo:Integer);
    procedure Add(s: String;StyleNo:Integer);
    procedure AddCenterLine(s: String;StyleNo:Integer);
    procedure AddText(s: String;StyleNo:Integer);
    procedure AddTextFromNewLine(s: String;StyleNo:Integer);
    procedure AddBreak;
    function AddCheckPoint: Integer; { returns cp # }
    function AddNamedCheckPoint(CpName: String): Integer; { returns cp # }
    function GetCheckPointY(no: Integer): Integer;
    function GetJumpPointY(no: Integer): Integer;
    procedure AddPicture(gr: TGraphic);
    procedure AddHotSpot(imgNo: Integer; lst: TImageList; fromnewline: Boolean);
    procedure AddBullet (imgNo: Integer; lst: TImageList; fromnewline: Boolean);
    procedure AddWinControl(ctrl: TWinControl; center: Boolean);
//    procedure AddControl(ctrl: TWinControl; center: Boolean);
    procedure AddGifAni(imgNo: Integer; GifAniObject: TGifAni; fromnewline: Boolean);

    function GetMaxPictureWidth: Integer;
    procedure Clear;
    procedure Format;
    procedure FormatTail;

    procedure AppendFrom(Source: TChatView);
    function GetLastCP: Integer;
    function SaveHTML(FileName, Title, ImagesPrefix: String; Options: TCVSaveOptions):Boolean;
    function SaveText(FileName: String; LineWidth: Integer):Boolean;

    procedure DeleteSection(CpName: String);
    procedure DeleteLines(FirstLine, Count: Integer);

    //use this only inside OnSaveComponentToFile event handler:
    function SavePicture(DocumentSaveFormat: TCVSaveFormat; Path: String; gr: TGraphic): String; virtual;

    procedure CopyText;
    function GetSelText: String;
    function SelectionExists: Boolean;
    procedure Deselect;
    procedure SelectAll;

    property LineCount: Integer read GetLineCount;
    property FirstVisibleContainer: cardinal read GetFirstVisibleContainer;
    property LastVisibleContainer: cardinal read GetLastVisibleContainer;
    procedure SmoothScrollYTo(ToY, orDeltaY:Integer);
  published
    { Published declarations }
    property PopupMenu;
    property OnClick;
    property OnKeyDown;
    property OnKeyUp;
    property OnKeyPress;
    property Version: String read FVersion;
    property FirstJumpNo: Integer read FFirstJumpNo write FFirstJumpNo;
    property OnJump: TJumpEvent read FOnJump write FOnJump;
    property OnCVMouseMove: TCVMouseMoveEvent read FOnCVMouseMove write FOnCVMouseMove;
    property OnSaveComponentToFile: TCVSaveComponentToFileEvent read FOnSaveComponentToFile write FOnSaveComponentToFile;
    property OnURLNeeded: TCVURLNeededEvent read FOnURLNeeded write FOnURLNeeded;
    property OnCVDblClick: TCVDblClickEvent read FOnCVDblClick write FOnCVDblClick;
    property OnCVRightClick: TCVRightClickEvent read FOnCVRightClick write FOnCVRightClick;
    property OnSelect: TNotifyEvent read FOnSelect write FOnSelect;
    property OnResized: TNotifyEvent read FOnResized write FOnResized;
    property OnDebug: TDebugEvent read FOnDebug write FOnDebug;
    property Style: TCVStyle read FStyle write FStyle;
    property MaxTextWidth:Integer read FMaxTextWidth write FMaxTextWidth;
    property MinTextWidth:Integer read FMinTextWidth write FMinTextWidth;
    property LeftMargin: Integer read FLeftMargin write FLeftMargin;
    property RightMargin: Integer read FRightMargin write FRightMargin;
    property BackgroundBitmap: TBitmap read FBackBitmap write SetBackBitmap;
    property BackgroundStyle: TBackgroundStyle read FBackgroundStyle write SetBackgroundStyle;
    property Delimiters: String read FDelimiters write FDelimiters;
    property MergeDelimiters: String read FMergeDelimiters write FMergeDelimiters;
    property AllowSelection: Boolean read FAllowSelection write FAllowSelection;
    property SingleClick: Boolean read FSingleClick write FSingleClick;
  end;

procedure InfoAboutSaD(var sad:TScreenAndDevice; Canvas: TCanvas);

implementation
{-------------------------------------}

{procedure TChatView.CMInvalidate(var Message: TMessage);
//var n:integer;
begin
//MessageBox(0, '', PChar(Inttostr(1)), mb_ok);
//DrawFrame;
inherited;
end;}

{-------------------------------------}
procedure InfoAboutSaD(var sad:TScreenAndDevice; Canvas: TCanvas);
var screenDC: HDC;
begin
     sad.ppixDevice := GetDeviceCaps(Canvas.Handle, LOGPIXELSX);
     //число пикселей на логический дюйм по ширине устройства (канваса)
     sad.ppiyDevice := GetDeviceCaps(Canvas.Handle, LOGPIXELSY);
     //число пикселей на логический дюйм по высоте устройства (канваса)
     screenDc := CreateCompatibleDC(0);
     //создаем Устройство Канвас
     sad.ppixScreen := GetDeviceCaps(screenDC, LOGPIXELSX);
     //число пикселей на логический дюйм по ширине устройства (канваса)
     sad.ppiyScreen := GetDeviceCaps(screenDC, LOGPIXELSY);
     //число пикселей на логический дюйм по высоте устройства (канваса)
     DeleteDC(screenDC);
     //уничтожаем Устройство Канвас
//в результате в sad записываются размеры уже созданного канваса и
//размеры канваса используемые в системе по умолчанию
//для чего это нужно? хз...
end;
{==================================================================}
constructor TChatView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FVersion              := cvVersion;
  FOnDebug              := DefaultDebug;
  BufferVirtCanv        := TBitmap.Create;

  FClientTextWidth      := False;
  FLeftMargin           := 5;
  FRightMargin          := 5;
  FMaxTextWidth         := 0;
  FMinTextWidth         := 0;
  TextWidth             := -1;
  TextHeight            := 0;
  LastJumpMovedAbove    := -1;
  FStyle                := nil;
  LastJumpDowned        := -1;
  DrawLinesInfo         := TStringList.Create;
  DrawContainers        := TStringList.Create;
  ContStorage           := TStringList.Create;
  checkpoints           := TStringList.Create;
  jumps                 := TStringList.Create;
  FBackBitmap           := TBitmap.Create;
  FBackGroundStyle      := bsNoBitmap;
  nJmps                 :=0;
  FirstJumpNo           :=0;
  skipformatting        := False;
  OldWidth              := 0;
  OldHeight             := 0;
  Width                 := 100;
  Height                := 40;
  DisplayOptions        := [cvdoImages, cvdoComponents, cvdoBullets];
//  MouseButtonState      := mbNone;
  ShareContents         := False;
  FDelimiters           := ' .;,:)}';
  FMergeDelimiters      := '({"|';
  DrawHover             := False;
  FSelStartContNo       := -1;
  FSelEndContNo         := -1;
  FSelStartOffsInCont   := 0;
  FSelEndOffsInCont     := 0;
  FSelStartPixOffsInCont:= 0;
  FSelEndPixOffsInCont  := 0;
  FSelStartX            := -1;
  FSelStartY            := -1;
  FSelEndX              := -1;
  FSelEndX              := -1;
{  TmpStartX := -1;
  TmpStartY := -1;
  TmpEndX := -1;
  TmpEndY := -1;}
  Selection             := False;
  FAllowSelection       := True;
  ScrollTimer           := nil;
  TimerScrollStepY      := 10;
  ScrollDeltaY          := 0;
  ScrollToY             := -1;
  ScrollYSpeed          := 100;
  FGifAniObjNo          := 0;
  AddFromNewLine('', 0);
  //Format_(False,0, Canvas, False);
end;
{-------------------------------------}
destructor TChatView.Destroy;
var n: cardinal;
begin
{  for n := 0 to DrawContainers.Count - 1 do
    begin
    if TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo <> DestroytedPointer then
      //уничтожаем все объекты линии, на которые ссылаются объекты-контейнеры.
      begin
      //т.к. указателя не пустые, но могут ссылаться на уже уничтоженый объект
      //запомним объект, кот. убили и больше такие указатели не убиваем
      DestroytedPointer := TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo;
      TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo.Free;
      end;
    end;}
  //уничтожаем содержимое контейнеров
  Clear;
//  GifFrame.Free;
  FBackBitmap.Free;
  BufferVirtCanv.Free;
  //уничтожаем сами объекты-контейнеры
  if DrawLinesInfo.Count > 0 then
    begin
    for n := 0 to DrawLinesInfo.Count - 1 do
      begin
      TDrawLineInfo(DrawLinesInfo.Objects[n]).Free;
      end;
    end;
  DrawLinesInfo.Free;
  DrawContainers.Free;
  checkpoints.Free;
  jumps.Free;
  if not ShareContents then ContStorage.Free;
  inherited Destroy;
end;
{-------------------------------------}
procedure TChatView.DefaultDebug(Mess, Mess2: String);
begin
//не удалять! Если не присвоен обработчик OnDebug, то вызывается эта процедура.
end;
{-------------------------------------}
procedure TChatView.WMSize(var Message: TWMSize);
begin
  Format_(True, 0, Canvas, False);
  if Assigned(FOnResized) then FOnResized(Self);
//  Paint;
end;
{-------------------------------------}
procedure TChatView.Format;
begin
  Format_(False, 0, Canvas, False);
end;
{-------------------------------------}
procedure TChatView.FormatTail;
begin
  Format_(False, 0, Canvas, True);
end;
{-------------------------------------}
procedure TChatView.ClearTemporal;
var i: Integer;
begin
  if ScrollTimer<>nil then begin
     ScrollTimer.Free;
     ScrollTimer := nil;
  end;
  DrawContainers.BeginUpdate;
  for i:=0 to DrawContainers.Count-1 do begin
    TDrawContainerInfo(DrawContainers.objects[i]).Free;
    DrawContainers.objects[i] := nil;
  end;
  DrawContainers.Clear;
  DrawContainers.EndUpdate;
  checkpoints.BeginUpdate;
  for i:=0 to checkpoints.Count-1 do begin
    TCPInfo(checkpoints.objects[i]).Free;
    checkpoints.objects[i] := nil;
  end;
  checkpoints.Clear;
  checkpoints.EndUpdate;
  jumps.BeginUpdate;
  for i:=0 to jumps.Count-1 do begin
    TJumpInfo(jumps.objects[i]).Free;
    jumps.objects[i] := nil;
  end;
  jumps.Clear;
  jumps.EndUpdate;
  nJmps :=0;
end;
{-------------------------------------}
procedure TChatView.Deselect;
begin
  Selection := False;
  FSelStartContNo := -1;
  FSelEndContNo := -1;
  FSelStartOffsInCont := 0;
  FSelEndOffsInCont := 0;
  if Assigned(FOnSelect) then OnSelect(Self);  
end;
{-------------------------------------}
procedure TChatView.SelectAll;
begin
  FSelStartContNo := 0;
  FSelEndContNo := DrawContainers.Count-1;
  FSelStartOffsInCont := 0;
  FSelEndOffsInCont := 0;
  if TContainerInfo(ContStorage.Objects[TDrawContainerInfo(DrawContainers.Objects[FSelEndContNo]).ContainerNumber]).StyleNo>=0 then
    FSelEndOffsInCont := Length(DrawContainers[FSelEndContNo])+1;
  if Assigned(FOnSelect) then OnSelect(Self);
end;
{-------------------------------------}
procedure TChatView.Clear;
var i: Integer;
begin
  Deselect;
  if not ShareContents then
    begin
    ContStorage.BeginUpdate;
    for i := 0 to ContStorage.Count - 1 do
      begin
      if TContainerInfo(ContStorage.objects[i]).StyleNo = -3 then { image}
        begin
        TContainerInfo(ContStorage.objects[i]).gr := nil;
        end;
      if TContainerInfo(ContStorage.objects[i]).StyleNo = -5 then {wincontrol}
        begin
//        RemoveControl(TControl(TContainerInfo(ContStorage.objects[i]).gr));
//        TContainerInfo(ContStorage.objects[i]).gr.Free;
//        TContainerInfo(ContStorage.objects[i]).gr := nil;
        end;
      if TContainerInfo(ContStorage.objects[i]).StyleNo = -8 then {GifAni}
        begin
        //Может возникнуть ошибка, если в UNIT1 GIFImage1.free; сделали
        //до ChatView1.clear;
        //Может конечно и можно как-то проверить безопасно ли вызывать метод
        //DelAllMirrorImages() или там уже битая ссылка объекта...
        //решение простое: в UNIT1 сначала ChatView1.clear; а потом уже GIFImage1.free;
        TGifAni(TContainerInfo(ContStorage.objects[i]).gr).DelAllMirrorImages();
        end;
      TContainerInfo(ContStorage.objects[i]).Free;
      ContStorage.objects[i] := nil;
      end;
    ContStorage.Clear;
    ContStorage.EndUpdate;
    end;
  ClearTemporal;
  AddFromNewLine('', 0);
end;
{-------------------------------------}
procedure TChatView.AddFromNewLine(s: String; StyleNo:Integer);
var info: TContainerInfo;
begin
  info := TContainerInfo.Create;
  info.StyleNo := StyleNo;
  info.SameAsPrev := False;
  info.Center := False;
  ContStorage.AddObject(s, info);
end;
{-------------------------------------}
procedure TChatView.Add(s: String; StyleNo:Integer);
var info: TContainerInfo;
begin
//Добавляет строку текста как есть, т.е. #10#13
//будет отображаться квадратиком
  info := TContainerInfo.Create;
  info.StyleNo := StyleNo;
  if ContStorage.Count = 0 then
    info.SameAsPrev := false
  else
    info.SameAsPrev := true;
  info.Center := False;
  ContStorage.AddObject(s, info);
end;
{-------------------------------------}
procedure TChatView.AddText(s: String;StyleNo:Integer);
var p: Integer;
begin
//Если в строке текста есть #10#13,
//то произойдет перенос текста на следующую строку
   s:=AdjustLineBreaks(s);
   p := Pos(chr(13)+chr(10),s);
   if p=0 then begin
     if s<>'' then Add(s,StyleNo);
     exit;
   end;
   Add(Copy(s,1,p-1), StyleNo);
   Delete(s,1, p+1);
   while s<>'' do begin
     p := Pos(chr(13)+chr(10),s);
     if p=0 then begin
        AddFromNewLine(s,StyleNo);
        break;
     end;
     AddFromNewLine(Copy(s,1,p-1), StyleNo);
     Delete(s,1, p+1);
   end;
end;
{-------------------------------------}
procedure TChatView.AddTextFromNewLine(s: String;StyleNo:Integer);
var p: Integer;
begin
   s:=AdjustLineBreaks(s);
   p := Pos(chr(13)+chr(10),s);
   if p=0 then begin
     AddFromNewLine(s,StyleNo);
     exit;
   end;
   while s<>'' do begin
     p := Pos(chr(13)+chr(10),s);
     if p=0 then begin
        AddFromNewLine(s,StyleNo);
        break;
     end;
     AddFromNewLine(Copy(s,1,p-1), StyleNo);
     Delete(s,1, p+1);
   end;
end;
{-------------------------------------}
procedure TChatView.AddCenterLine(s: String;StyleNo:Integer);
var info: TContainerInfo;
begin
  info := TContainerInfo.Create;
  info.StyleNo := StyleNo;
  info.SameAsPrev := False;
  info.Center := True;
  ContStorage.AddObject(s, info);
end;
{-------------------------------------}
procedure TChatView.AddBreak;
var info: TContainerInfo;
begin
  info := TContainerInfo.Create;
  info.StyleNo := -1;
  ContStorage.AddObject('', info);
end;
{-------------------------------------}
function TChatView.AddNamedCheckPoint(CpName: String): Integer;
var info: TContainerInfo;
    cpinfo: TCPInfo;
begin
  info := TContainerInfo.Create;
  info.StyleNo := -2;
  ContStorage.AddObject(CpName, info);
  cpInfo := TCPInfo.Create;
  cpInfo.Y := 0;
  checkpoints.AddObject(CpName,cpinfo);
  AddNamedCheckPoint := checkpoints.Count-1;
end;
{-------------------------------------}
function TChatView.AddCheckPoint: Integer;
begin
  AddCheckPoint := AddNamedCheckPoint('');
end;
{-------------------------------------}
function TChatView.GetCheckPointY(no: Integer): Integer;
begin
  GetCheckPointY := TCPInfo(checkpoints.Objects[no]).Y;
end;
{-------------------------------------}
function TChatView.GetJumpPointY(no: Integer): Integer;
var i: Integer;
begin
  GetJumpPointY := 0;
  for i:=0 to Jumps.Count-1 do
   if  TJumpInfo(jumps.objects[i]).id = no-FirstJumpNo then begin
     GetJumpPointY := TJumpInfo(jumps.objects[i]).t;
     exit;
   end;
end;
{-------------------------------------}
procedure TChatView.AddPicture(gr: TGraphic); { gr not copied, do not free it!}
var info: TContainerInfo;
begin
  info := TContainerInfo.Create;
  info.StyleNo := -3;
  info.gr := gr;
  info.SameAsPrev := False;
  info.Center := True;
  ContStorage.AddObject('', info);
end;
{-------------------------------------}
procedure TChatView.AddHotSpot(imgNo: Integer; lst: TImageList; fromnewline: Boolean);
var info: TContainerInfo;
begin
  info := TContainerInfo.Create;
  info.StyleNo := -4;
  info.gr := lst;
  info.imgNo := imgNo;
  info.SameAsPrev := not FromNewLine;
  ContStorage.AddObject('', info);
end;
{-------------------------------------}
procedure TChatView.AddBullet(imgNo: Integer; lst: TImageList; fromnewline: Boolean);
var info: TContainerInfo;
begin
  info := TContainerInfo.Create;
  info.StyleNo := -6;
  info.gr := lst;
  info.imgNo := imgNo;
  info.SameAsPrev := not FromNewLine;
  ContStorage.AddObject('', info);
end;
{-------------------------------------}
procedure TChatView.AddGifAni(imgNo: Integer; GifAniObject: TGifAni; fromnewline: Boolean);
var info: TContainerInfo;
//    r:TRect;
begin
//  if GifAniObject.GifImage.Count = 0 then AddGif(imgNo, GifAniObject.GifImage,fromnewline);
  GifAniObject.AddMirrorImages;
  info := TContainerInfo.Create;
  info.StyleNo := -8;
  info.gr := GifAniObject;
  if imgNo = 0 then
    begin
    info.imgNo := Length(GifAniObject.MirrorImagesX) - 1;
    end;
//  info.imgNo := imgNo;
  info.SameAsPrev := not FromNewLine;
  ContStorage.AddObject('', info);
  GifAniObject.BeginAnimate(Self.GetCanvas, Self.Style.Color);
end;
{-------------------------------------}
//procedure TChatView.AddControl(ctrl: TControl; center: Boolean); { do not free ctrl! }
procedure TChatView.AddWinControl(ctrl: TWinControl; center: Boolean); { do not free ctrl! }
var info: TContainerInfo;
begin
  ctrl.ParentWindow := Self.Handle;
  info := TContainerInfo.Create;
  info.StyleNo := -5;
  info.gr := ctrl;
//  info.SameAsPrev := false;//true;//
  info.SameAsPrev := true;
  info.Center := center;
  ContStorage.AddObject('', info);
//  InsertControl(ctrl);
end;
{-------------------------------------}
function TChatView.GetMaxPictureWidth: Integer;
var i,m: Integer;
begin
{
  cvsBreak      = -1;
  cvsCheckPoint = -2;
  cvsPicture    = -3;
  cvsHotSpot    = -4;
  cvsComponent  = -5;
  cvsBullet     = -6;
  cvsGif        = -7;
  cvsGifAni     = -8;
}
m := 0;
for i := 0 to ContStorage.Count-1 do
  begin
  if TContainerInfo(ContStorage.objects[i]).StyleNo = -3 then
    if m < TGraphic(TContainerInfo(ContStorage.objects[i]).gr).Width then
      m := TGraphic(TContainerInfo(ContStorage.objects[i]).gr).Width;
  if TContainerInfo(ContStorage.objects[i]).StyleNo = -5 then
    if m < TWinControl(TContainerInfo(ContStorage.objects[i]).gr).Width then
      m := TWinControl(TContainerInfo(ContStorage.objects[i]).gr).Width;
  if TContainerInfo(ContStorage.objects[i]).StyleNo = -7 then
    if m < TGIF(TContainerInfo(ContStorage.objects[i]).gr).Width then
      m := TGif(TContainerInfo(ContStorage.objects[i]).gr).Width;
  if TContainerInfo(ContStorage.objects[i]).StyleNo = -8 then
    if m < TGifAni(TContainerInfo(ContStorage.objects[i]).gr).GifImage.Width then
      m := TGifAni(TContainerInfo(ContStorage.objects[i]).gr).GifImage.Width;
  end;
//GetMaxPictureWidth := m;
result := m;
end;
{-------------------------------------}
function max(a,b: Integer): Integer;
begin
  if a>b then
    max := a
  else
    max := b;
end;
{-------------------------------------}
function TChatView.GetMaxHeight(Line, FromObject:integer):Integer;
var MaxHeight:integer;
begin
MaxHeight := 0;
  while (line = TDrawContainerInfo(DrawContainers.Objects[fromobject]).LineNum^) and
       (fromobject > 0) do
    begin
    if TDrawContainerInfo(DrawContainers.Objects[fromobject]).Height > MaxHeight then
      begin
      MaxHeight := TDrawContainerInfo(DrawContainers.Objects[fromobject]).Height;
      end;
    dec(fromobject);
    end;
result := MaxHeight;
end;
{-------------------------------------}
function TChatView.GetMinHeight(Line, FromObject:integer):Integer;
var MinHeight:integer;
begin
MinHeight := 0;
  while (line = TDrawContainerInfo(DrawContainers.Objects[FromObject]).LineNum^) and
        (fromobject > 0) do
    begin
    if TDrawContainerInfo(DrawContainers.Objects[FromObject]).Height < MinHeight then
      begin
      MinHeight := TDrawContainerInfo(DrawContainers.Objects[FromObject]).Height;
      end;
    dec(FromObject);
    end;
result := MinHeight;
end;

FUNCTION TChatView.GetCanvas():TCanvas;
BEGIN
Result := Canvas;
END;
{-------------------------------------}
{-------------------------------------}
{procedure TChatView.AdjustChildrenCoords;
var i: Integer;
    dli: TDrawContainerInfo;
    li : TContainerInfo;
begin
  for i:=0 to DrawContainers.Count-1 do
   begin
   dli := TDrawContainerInfo(DrawContainers.Objects[i]);
   li := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]);
   if li.StyleNo = -5 then //wincontrol
     begin
     TWinControl(li.gr).Left := dli.Left;
     TWinControl(li.gr).Tag := dli.Bottom^ - dli.Height;
     Tag2Y(TWinControl(li.gr));
     end;
   end;
end;}
{-------------------------------------}
procedure TChatView.AdjustJumpsCoords;
var i: Integer;
begin
  for i:=0 to jumps.Count-1 do begin
    TJumpInfo(jumps.Objects[i]).l :=
    TDrawContainerInfo(DrawContainers.Objects[TJumpInfo(jumps.Objects[i]).idx]).left;
    TJumpInfo(jumps.Objects[i]).t :=
//    TDrawContainerInfo(DrawContainers.Objects[TJumpInfo(jumps.Objects[i]).idx]).top^;
    TDrawContainerInfo(DrawContainers.Objects[TJumpInfo(jumps.Objects[i]).idx]).Bottom^ -
    TDrawContainerInfo(DrawContainers.Objects[TJumpInfo(jumps.Objects[i]).idx]).Height;
  end;
end;
{-------------------------------------}
procedure TChatView.SmoothScrollYTo(ToY, orDeltaY:Integer);
begin
if ScrollTimer = nil then
  begin
  ScrollTimer := TTimer.Create(nil);
  ScrollTimer.OnTimer := OnScrollTimer;
  ScrollTimer.Interval := ScrollYSpeed;
  end;
ScrollToY := ToY;
ScrollDeltaY := orDeltaY;
end;
{-------------------------------------}
const gdlnFirstVisible =1;
const gdlnLastCompleteVisible =2;
const gdlnLastVisible =3;
{-------------------------------------}
function TChatView.GetFirstVisibleContainer: cardinal;
var n: cardinal;
    dli : TDrawLineInfo;
begin
//У нас есть набор отформатированных объектов DrawContainers, нам нужно определить
//с какого объекта начать вывод на канвас. Для этого нам надо узнать какой объект
//находится ниже чем VPOS
result := 0;
n := 0;
while n <= DrawContainers.Count - 1 do
  begin
  dli := TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo;
  if dli.BaseLine > VPOS then
    begin
    result := n;
    break;
    end;
//  else
  n := n + 1;
  end;
//MessageBox(0, PChar(inttostr(DrawContainers.Count - 1)), 'DrawContainers.Count - 1', mb_ok);
//FDebugText :='VPOS=' + inttostr(VPOS) + ' GetFirstVisibleContainer = ' + inttostr(result);
//self.OnDebug(FDebugText);
end;
{-------------------------------------}
function TChatView.GetLastVisibleContainer: cardinal;
var n: cardinal;
dli : TDrawLineInfo;
begin
//если даже самый последний контейнер помещается в VPOS + Y размер канваса, то
result := DrawContainers.Count - 1;
n := 0;
while n <= DrawContainers.Count - 1 do
  begin
  dli := TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo;
  if (dli.BaseLine - TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo.MaxHeight) > (VPOS + self.Canvas.ClipRect.BottomRight.y {* 2}) then
    begin
    result := n - 1;
    break;
    end;
  n := n + 1;
  end;
end;
{------------------------------------------------------------------}
function TChatView.GetPrevContainerInThisLine(DrawCont:TDrawContainerInfo): TContainerInfo;
var ci : TContainerInfo;
begin
{result := nil;
if (DrawCont.ContainerNumber - 1 >= 0) then
  begin
  ci := TContainerInfo(ContStorage.Objects[DrawCont.ContainerNumber - 1]);
  if (ci. pDrawLineInfo.LineNumber = DrawCont.pDrawLineInfo.LineNumber) then result := dci;
  end;}
end;
{------------------------------------------------------------------}
function TChatView.GetLineCount: Integer;
begin
  GetLineCount := ContStorage.Count;
end;
{----------------------------------------------------}
procedure TChatView.InvalidateJumpRect(no: Integer);
var rec: TRect;
    i, id : Integer;
begin
   if Style.FullRedraw then
     Invalidate
   else begin
     id := no;
     for i:=0 to Jumps.Count -1 do
      if id = TJumpInfo(jumps.objects[i]).id then
       with TJumpInfo(jumps.objects[i]) do begin
         rec.Left := l - Hpos - 5;
         rec.Top  := t - VPos * VScrollStep - 5;
         rec.Right := l + w - Hpos + 5;
         rec.Bottom := t + h - VPos * VScrollStep + 5;
         InvalidateRect(Handle, @rec, False);
       end;
   end;
   Update;
end;
  {------------------------------------------------------------------}
procedure TChatView.CMMouseLeave(var Message: TMessage);
begin
   if DrawHover and (LastJumpMovedAbove<>-1) then begin
     DrawHover := False;
     InvalidateJumpRect(LastJumpMovedAbove);
   end;
   if Assigned(FOnCVMouseMove) and
      (LastJumpMovedAbove<>-1) then begin
      LastJumpMovedAbove := -1;
      OnCVMouseMove(Self,-1);
   end;
end;
{procedure TChatView.WMNCMOUSEMOVE(var Message: TMessage);
begin
MessageBox(0, PChar(inttostr(0)), 'WMLButtonUp', mb_ok);
//self.on
//inherited WMMouse(Message);
end;}
{-------------------------------------}
procedure TChatView.OnMouseUp(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
begin
FDebugText := 'OnMouseUp' + #10#13 +
              #10#13 + 'x = ' + inttostr(x) + '   y = ' + inttostr(y);
self.OnDebug(FDebugText, FDebugText2);
end;
{-------------------------------------}
procedure TChatView.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var i,no, StyleNo: Integer;
    clickedword: String;
   n, yshift, xshift: Integer;
   dli:TDrawContainerInfo;
    li: TContainerInfo;
    r :TRect;
    lastline: Boolean;
begin
if Button <> mbLeft then exit;
{  XClicked := X;
  YClicked := Y;
  //if Assigned(FOnJump) then begin
    LastJumpDowned := -1;
    for i:=0 to jumps.Count-1 do
     with jumps.objects[i] as TJumpInfo do
      if (X>=l-HPos) and
         (X<=l+w-HPos) and
         (Y >= t - VPos * VScrollStep) and
         (Y <= t + h - VPos * VScrollStep) then
           begin
             LastJumpDowned := id;
             break;
           end;
    if AllowSelection then
      begin
      FindItemForSel(XClicked + HPos, YClicked + VPos * VScrollStep, no, FSelStartOffs);
      FSelStartNo := no;
      FSelEndNo   := no;
      Selection   := (no<>-1);
      FSelEndOffs := FSelStartOffs;
      Invalidate;
      if ScrollTimer = nil then begin
        ScrollTimer := TTimer.Create(nil);
        ScrollTimer.OnTimer := OnScrollTimer;
        ScrollTimer.Interval := 100;
      end;

    end;
    if SingleClick and Assigned(FOnCVDblClick) and FindClickedWord(clickedword, StyleNo) then
       FOnCVDblClick(Self, clickedword, StyleNo);

}
if AllowSelection then
  begin
//  DoItemSel(X, Y, BeginSelection);
  if selection = false then
    begin
{    TmpStartX := x + HPos;
    TmpStartY := y + VPos;
    TmpEndX := x + HPos;
    TmpEndY := y + VPos;}
    FSelStartX := x + HPos;
    FSelStartY := y + VPos;
    FSelEndX := x + HPos;
    FSelEndY := y + VPos;

    SetSelectionItems(x, y);
    selection := true;
    invalidate;
    end;
  end;

inherited MouseDown(Button, Shift, X, Y);

//выводим инфу о позиции мыши
if FindItemAtScreenPos(x, y) > 0 then
  FDebugText := 'MouseDown' + #10#13 +
                'DrawContainer = ' + inttostr(FindItemAtScreenPos(x, y)) +
                #10#13 + 'BaseLine =' + inttostr(TDrawContainerInfo(DrawContainers.Objects[FindItemAtScreenPos(x, y)]).pDrawLineInfo.BaseLine) +
                #10#13 + 'Line =' + inttostr(TDrawContainerInfo(DrawContainers.Objects[FindItemAtScreenPos(x, y)]).pDrawLineInfo.LineNumber) +
                #10#13 + 'FSelStartContNo = ' + inttostr(FSelStartContNo) +
                #10#13 + 'FSelStartOffsInCont =' + inttostr(FSelStartOffsInCont) +
                #10#13 + 'FSelStartPixOffsInCont =' + inttostr(FSelStartPixOffsInCont) +
                #10#13 +
                #10#13 + 'FSelEndContNo = ' + inttostr(FSelEndContNo) +
                #10#13 + 'FSelEndOffsInCont =' + inttostr(FSelEndOffsInCont) +
                #10#13 + 'FSelEndPixOffsInCont =' + inttostr(FSelEndPixOffsInCont) +
                #10#13 + 'x = ' + inttostr(x) + '   y = ' + inttostr(y)
else
  FDebugText := 'MouseDown' + #10#13 + 'empty';
self.OnDebug(FDebugText, FDebugText2);
end;
{------------------------------------------------------------------}
procedure TChatView.MouseMove(Shift: TShiftState; X, Y: Integer);
var i, no, offs,ys, cont: Integer;
begin
ScrollDeltaY := 0;
if (Selection = true) then
  begin
  if Y < 0 then
    begin
    ScrollDeltaY := -2;
    ScrollYSpeed := 100;
    end;
  if Y < -30 then
    begin
    ScrollDeltaY := -VScrollStep;
    ScrollYSpeed := 50;
    end;
  if Y < -100 then
    begin
    ScrollDeltaY := -VPageScrollStep;
    ScrollYSpeed := 25;
    end;
  if Y > ClientHeight then
    begin
    ScrollDeltaY := 2;
    ScrollYSpeed := 100;
    end;
  if Y > ClientHeight + 30 then
    begin
    ScrollDeltaY := VScrollStep;
    ScrollYSpeed := 50;
    end;
  if Y > ClientHeight + 100 then
    begin
    ScrollDeltaY := VPageScrollStep;
    ScrollYSpeed := 25;
    end;
{   if Selection then
      begin
      XMouse := x;
      YMouse := y;
      ys := y;
      if ys<0 then y:=0;
      if ys>ClientHeight then ys:=ClientHeight;
      FindItemForSel(X + HPos, ys + VPos * VScrollStep, no, offs);
      FSelEndNo   := no;
      FselEndOffs    := offs;
      Invalidate;
      end;
    for i:=0 to jumps.Count-1 do
      begin
      if (X>=TJumpInfo(jumps.objects[i]).l-HPos) and
         (X<=TJumpInfo(jumps.objects[i]).l+TJumpInfo(jumps.objects[i]).w-HPos) and
         (Y>=TJumpInfo(jumps.objects[i]).t - VPos * VScrollStep) and
         (Y<=TJumpInfo(jumps.objects[i]).t + TJumpInfo(jumps.objects[i]).h - VPos * VScrollStep) then
        begin
        Cursor :=  FStyle.JumpCursor;
        if Assigned(FOnCVMouseMove) and
           (LastJumpMovedAbove<>TJumpInfo(jumps.objects[i]).id) then
          begin
          OnCVMouseMove(Self,TJumpInfo(jumps.objects[i]).id+FirstJumpNo);
          end;
        if DrawHover and (LastJumpMovedAbove<>-1) and
           (LastJumpMovedAbove<>TJumpInfo(jumps.objects[i]).id) then
          begin
          DrawHover := False;
          InvalidateJumpRect(LastJumpMovedAbove);
          end;
        LastJumpMovedAbove := TJumpInfo(jumps.objects[i]).id;
        if (Style<>nil) and (Style.HoverColor<>clNone) and not DrawHover then
          begin
          DrawHover := True;
          InvalidateJumpRect(LastJumpMovedAbove);
          end;
        exit;
        end;
      end;
    Cursor :=  crDefault;
    if DrawHover and (LastJumpMovedAbove<>-1) then
      begin
      DrawHover := False;
      InvalidateJumpRect(LastJumpMovedAbove);
      end;
    if Assigned(FOnCVMouseMove) and
       (LastJumpMovedAbove<>-1) then
      begin
      LastJumpMovedAbove := -1;
      OnCVMouseMove(Self,-1);
      end;
    if Selection then Invalidate;
}
  FSelEndX := x + HPos;
  FSelEndY := y + VPos;
  SetSelectionItems(x, y);
  invalidate;
  end;
if ScrollDeltaY <> 0 then SmoothScrollYTo(-1, ScrollDeltaY);
inherited MouseMove(Shift, X, Y);

FDebugText := '';
if FindItemAtScreenPos(x, y) > 0 then
  FDebugText := 'MouseMove' +
                #10#13 + 'BaseLine =' + inttostr(TDrawContainerInfo(DrawContainers.Objects[FindItemAtScreenPos(x, y)]).pDrawLineInfo.BaseLine) +
                #10#13 + 'Width =' + inttostr(TDrawContainerInfo(DrawContainers.Objects[FindItemAtScreenPos(x, y)]).width) +
                #10#13 + 'Line =' + inttostr(TDrawContainerInfo(DrawContainers.Objects[FindItemAtScreenPos(x, y)]).pDrawLineInfo.LineNumber) +
                #10#13 + 'DrawContainer = ' + inttostr(FindItemAtScreenPos(x, y))
else
  FDebugText := 'MouseMove' + #10#13 + 'Под курсором нет контейнера' +
                #10#13 + 'x = ' + inttostr(x) + '   y = ' + inttostr(y);
if FindNearItemAtScreenPos(x, y) > 0 then
  FDebugText := FDebugText +
                #10#13 + 'MaxHeight =' + inttostr(TDrawContainerInfo(DrawContainers.Objects[FindNearItemAtScreenPos(x, y)]).pDrawLineInfo.MaxHeight) +
                #10#13 + 'GetFirstContainerInLine = ' + inttostr(GetFirstContainerInLine(FindNearItemAtScreenPos(x, y))) +
                '   GetLastContainerInLine = ' + inttostr(GetLastContainerInLine(FindNearItemAtScreenPos(x, y))) +
//                #10#13 + 'TmpStartX =' + inttostr(TmpStartX) + '   TmpStartY =' + inttostr(TmpStartY) + '  TmpEndX =' + inttostr(TmpEndX) + '  TmpEndY =' + inttostr(TmpEndY) +
                #10#13 + 'FSelStartX =' + inttostr(FSelStartX) + '   FSelStartY =' + inttostr(FSelStartY) + '  FSelEndX =' + inttostr(FSelEndX) + '  FSelEndY =' + inttostr(FSelEndY) +
                #10#13 + 'FSelStartContNo = ' + inttostr(FSelStartContNo) +
                #10#13 + 'FSelStartOffsInCont =' + inttostr(FSelStartOffsInCont) +
                #10#13 + 'FSelStartPixOffsInCont =' + inttostr(FSelStartPixOffsInCont) +
                #10#13 + 'FSelEndContNo = ' + inttostr(FSelEndContNo) +
                #10#13 + 'FSelEndOffsInCont =' + inttostr(FSelEndOffsInCont) +
                #10#13 + 'FSelEndPixOffsInCont =' + inttostr(FSelEndPixOffsInCont) +
                #10#13 + 'x = ' + inttostr(x) + '   y = ' + inttostr(y)
else
  FDebugText := 'MouseMove' + #10#13 + 'Под курсором нет ДАЖЕ ЛИНИИ' +
                #10#13 + 'x = ' + inttostr(x) + '   y = ' + inttostr(y);
self.OnDebug(FDebugText, FDebugText2);
end;
{-------------------------------------}
procedure TChatView.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var i, StyleNo, no, offs, ys: Integer;
    clickedword: String;
    p: TPoint;
begin
{    if ScrollTimer<> nil then begin
      ScrollTimer.Free;
      ScrollTimer := nil;
    end;
    XClicked := X;
    YClicked := Y;
    if Selection and (Button = mbLeft) then begin
      ys := y;
      if ys<0 then y:=0;
      if ys>ClientHeight then ys:=ClientHeight;
      FindItemForSel(XClicked + HPos, ys + VPos * VScrollStep, no, offs);
      FSelEndNo   := no;
      FselEndOffs    := offs;
      Selection   := False;
      Invalidate;
      if Assigned(FOnSelect) then FOnSelect(Self);
    end;
    if Button = mbRight then begin
      inherited MouseUp(Button, Shift, X, Y);
      if not Assigned(FOnCVRightClick) then exit;
      p := ClientToScreen(Point(X,Y));
      if FindClickedWord(clickedword, StyleNo) then
        FOnCVRightClick(Self, clickedword, StyleNo,p.X,p.Y);
      exit;
    end;
    if Button <> mbLeft then exit;
    if (LastJumpDowned=-1) or not Assigned(FOnJump) then begin
      exit;
    end;
    for i:=0 to jumps.Count-1 do
    with jumps.objects[i] as TJumpInfo do
      if (LastJumpDowned=id) and
         (X>=l-HPos) and
         (X<=l+w-HPos) and
         (Y >= t - VPos * VScrollStep) and
         (Y <= t + h - VPos * VScrollStep) then
          begin
            OnJump(Self,id+FirstJumpNo);
            break;
          end;
    LastJumpDowned:=-1;
}
if (AllowSelection = true) and (selection = true) then
  begin
//  FSelEndX := x + HPos;
//  FSelEndY := y + VPos;
  SetSelectionItems(x, y);
  ScrollDeltaY := 0;
  selection := false;
  invalidate;
  end;

inherited MouseUp(Button, Shift, X, Y);

if FindItemAtScreenPos(x, y) > 0 then
  FDebugText := 'MouseUp' + #10#13 +
                'DrawContainer = ' + inttostr(FindItemAtScreenPos(x, y)) +
                #10#13 + 'BaseLine =' + inttostr(TDrawContainerInfo(DrawContainers.Objects[FindItemAtScreenPos(x, y)]).pDrawLineInfo.BaseLine) +
                #10#13 + 'Line =' + inttostr(TDrawContainerInfo(DrawContainers.Objects[FindItemAtScreenPos(x, y)]).pDrawLineInfo.LineNumber) +
                #10#13 + 'FSelStartContNo = ' + inttostr(FSelStartContNo) +
                #10#13 + 'FSelStartOffsInCont =' + inttostr(FSelStartOffsInCont) +
                #10#13 + 'FSelStartPixOffsInCont =' + inttostr(FSelStartPixOffsInCont) +
                #10#13 +
                #10#13 + 'FSelEndContNo = ' + inttostr(FSelEndContNo) +
                #10#13 + 'FSelEndOffsInCont =' + inttostr(FSelEndOffsInCont) +
                #10#13 + 'FSelEndPixOffsInCont =' + inttostr(FSelEndPixOffsInCont) +
                #10#13 + 'x = ' + inttostr(x) + '   y = ' + inttostr(y)
else
  FDebugText := 'MouseMove' + #10#13 + 'empty';
end;
{------------------------------------------------------------------}
{procedure TChatView.DoItemSel(ScreenX,ScreenY: Integer; const BegContEnd:word);
var
    styleno,i, a,b,mid, midtop, midbottom, midleft, midright, beginline, endline: Integer;
    dli: TDrawContainerInfo;
    //arr: array[0..1000] of integer;
    OffsWordNumber:integer;
    sz: TSIZE;
    cont, itemp:integer;
begin
  if DrawContainers.Count = 0 then exit;
{   dli := TDrawContainerInfo(DrawContainers.Objects[0]);
  if (dli.Bottom^ - dli.Height <=Y) and (dli.Bottom^ > Y) and
     (dli.Left <= X) and (dli.Left + dli.Width > X) then
     mid := 0
  else
    begin
    a := 1;
    b := DrawContainers.Count-1;
    while (b-a)>1 do begin
      mid := (a+b) div 2;
//      if (TDrawContainerInfo(DrawContainers.Objects[mid]).top^ <=Y) then
      if (TDrawContainerInfo(DrawContainers.Objects[mid]).Bottom^ -
          TDrawContainerInfo(DrawContainers.Objects[mid]).Height) <=Y then
        a := mid
      else
        b := mid;
    end;
    mid := a;
//    if TDrawContainerInfo(DrawContainers.Objects[b]).top^ <=Y then mid := b;
    if TDrawContainerInfo(DrawContainers.Objects[b]).Bottom^ -
       TDrawContainerInfo(DrawContainers.Objects[b]).Height <=Y then mid := b;
  end;
//  midtop := TDrawContainerInfo(DrawContainers.Objects[mid]).top^;
  midtop := TDrawContainerInfo(DrawContainers.Objects[mid]).Bottom^ -
            TDrawContainerInfo(DrawContainers.Objects[mid]).Height;
  midbottom := midtop + TDrawContainerInfo(DrawContainers.Objects[mid]).Height;
  // searching beginning of line "mid" belong to
  beginline := mid;
  while (beginline>=1) and
//         (TDrawContainerInfo(DrawContainers.Objects[beginline-1]).top^ +
//         TDrawContainerInfo(DrawContainers.Objects[beginline-1]).Height>midtop) do dec(beginline);
         (TDrawContainerInfo(DrawContainers.Objects[beginline-1]).Bottom^ > midtop) do dec(beginline);
  // searching end of line "mid" belong to
  endline := mid;
  while (endline < DrawContainers.Count-1) and
//         (TDrawContainerInfo(DrawContainers.Objects[endline+1]).top^ < midbottom) do inc(endline);
         (TDrawContainerInfo(DrawContainers.Objects[endline+1]).Bottom^ -
          TDrawContainerInfo(DrawContainers.Objects[endline+1]).Height < midbottom) do inc(endline);
  // calculating line bounds
  midleft := TDrawContainerInfo(DrawContainers.Objects[mid]).Left;
  midright := midleft+TDrawContainerInfo(DrawContainers.Objects[mid]).Width;
  for i:= beginline to endline do begin
    dli := TDrawContainerInfo(DrawContainers.Objects[i]);
//    if dli.top^  < midtop then midtop := dli.top^ ;
    if dli.Bottom^ - dli.Height < midtop then midtop := dli.Bottom^ - dli.Height ;
//    if dli.top^ + dli.Height > midbottom then midbottom := dli.top^ + dli.Height;
    if dli.Bottom^ > midbottom then midbottom := dli.Bottom^;
    if dli.Left < midleft then midleft := dli.Left;
    if dli.Left + dli.Width > midright then midright := dli.Left + dli.Width;
  end;
  if (Y<midtop) or (X<midleft) then begin
     {
     No := beginline-1;
     if No<0 then begin
       No := 0;
       Offs := 1;
       end
     else begin
       if TContainerInfo(ContStorage.Objects[TDrawContainerInfo(DrawContainers.Objects[No]).LineNo]).StyleNo<0 then
         Offs := 2
       else
         Offs := Length(DrawContainers[No])+1;
     end;
     exit;
     }
{     No := beginline;
     if TContainerInfo(ContStorage.Objects[TDrawContainerInfo(DrawContainers.Objects[No]).ContainerNumber]).StyleNo<0 then
         Offs := 0
       else
         Offs := 1;
     exit;
  end;
  if (Y>midbottom) or (X>midright) then begin
     No := endline+1;
     Offs := 1;
     if No>=DrawContainers.Count then begin
       No := DrawContainers.Count-1;
       Offs := Length(DrawContainers[No])+1;
       end
     else begin
       if TContainerInfo(ContStorage.Objects[TDrawContainerInfo(DrawContainers.Objects[No]).ContainerNumber]).StyleNo<0 then
         Offs := 0;
     end;
     exit;
  end;
  for i:= beginline to endline do begin
    dli := TDrawContainerInfo(DrawContainers.Objects[i]);
    if (dli.Left<=X) and (dli.Left+dli.Width>=X) then begin
      styleno := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo;
      No := i;
      Offs := 0;
      if styleno >= 0 then
        begin
        with FStyle.TextStyles[StyleNo] do
          begin
          Canvas.Font.Style := Style;
          Canvas.Font.Size  := Size;
          Canvas.Font.Name  := FontName;
          Canvas.Font.CharSet  := CharSet;
          end;
        GetTextExtentExPoint(Canvas.Handle,  PChar(DrawContainers[i]),  Length(DrawContainers[i]),
                             X-dli.Left,
                             @Offs, nil,
                             sz);
        inc(Offs);
        if Offs>Length(DrawContainers[i]) then Offs := Length(DrawContainers[i]);
        if (Offs < 1) and (Length(DrawContainers[i])>0) then Offs := 1;
        end
      else
        Offs := 1;
    end;
  end;
}
{cont := FindItemAtScreenPos(ScreenX,ScreenY);
if cont < 0 then exit;

dli := TDrawContainerInfo(DrawContainers.Objects[cont]);
styleno := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo;
if styleno >= 0 then
  begin
  with FStyle.TextStyles[StyleNo] do
    begin
    Canvas.Font.Style := Style;
    Canvas.Font.Size  := Size;
    Canvas.Font.Name  := FontName;
    Canvas.Font.CharSet := CharSet;
    end;
    //+------------------+  Допустим мышь указывает на букву А
    //| TChatView        |  нужно найти ее смещение от начала контейнера
    //|    ^             |
    //|     \            |
  GetTextExtentExPoint(Canvas.Handle,  PChar(DrawContainers.Strings[cont]),
                       Length(DrawContainers.Strings[cont]),
                       ScreenX - dli.Left,
                       @OffsWordNumber, nil,
                       sz);
  end;

case BegContEnd of
  BeginSelection:
     begin
     FSelStartContNo := cont;
     FSelEndContNo := cont;
     FSelStartOffsInCont := OffsWordNumber;
     FSelEndOffsInCont := OffsWordNumber;
     FSelStartPixOffsInCont := canvas.TextWidth(Copy(DrawContainers.Strings[cont], 0, OffsWordNumber));
     FSelEndPixOffsInCont := FSelStartPixOffsInCont;
//     MessageBox(0, PChar(Copy(DrawContainers.Strings[cont], 0, OffsWordNumber - 1)), PChar(inttostr(dx)),mb_ok);
     if OffsWordNumber = 0 then FSelStartPixOffsInCont := 0;

//     FSelStartPixOffsInCont := canvas.TextExtent(Copy(ContStorage.Strings[dli.ContainerNumber], 1, OffsWordNumber)).cx;

     //FSelEndOffsInCont := ;
     end;
  ContinueSelection:
     begin
     if FSelStartContNo > FSelEndContNo then
       begin
       itemp := FSelEndContNo;
       FSelEndContNo := FSelStartContNo;
       FSelStartContNo := itemp;
       if (FSelStartOffsInCont > FSelEndOffsInCont) then
         begin
         itemp := FSelEndOffsInCont;
         FSelEndOffsInCont := FSelStartOffsInCont;
         FSelStartOffsInCont := itemp;
         end;
       if (FSelStartContNo = FSelEndContNo) and
         (FSelStartPixOffsInCont > FSelEndPixOffsInCont) then
         begin
         itemp := FSelEndPixOffsInCont;
         FSelEndPixOffsInCont := FSelStartPixOffsInCont;
         FSelStartPixOffsInCont := itemp;
         end;
       end
     else
       begin
       if (FSelEndContNo >= FSelStartContNo)
//          and (FSelEndOffsInCont >= FSelStartOffsInCont)
         then
         begin
         FSelEndContNo := cont;
         FSelEndOffsInCont := OffsWordNumber;
         FSelEndPixOffsInCont := ScreenX;
         end;
       end;
     end;
  EndSelection:
     begin
{     FSelEndOffsInCont := OffsWordNumber;
     FSelEndContNo := cont;
//     FSelEndPixOffsInCont := ScreenX;
}
{     end;
  end;
end;
{-------------------------------------}
procedure TChatView.AppendFrom(Source: TChatView);
var i: Integer;
    gr: TGraphic;
    grclass: TGraphicClass;
    li: TContainerInfo;
begin
  ClearTemporal;
  for i:=0 to Source.ContStorage.Count-1 do begin
    li := TContainerInfo(Source.ContStorage.Objects[i]);
    case li.StyleNo of
      -1: AddBreak;
      -2: AddCheckPoint;
      -3: begin
           grclass := TGraphicClass(li.gr.ClassType);
           gr := grclass.Create;
           gr.Assign(li.gr);
           AddPicture(gr);
        end;
      -4: AddHotSpot(li.imgNo, TImageList(li.gr), not li.SameAsPrev);
      -5: ;
       {
       begin
           if li.gr is
           ctrlclass := TControlClass(li.gr.ClassType);
           ctrl := ctrlclass.Create(Self);
           ctrl.Assign(li.gr);
           AddControl(ctrl, li.Center);
        end;
        }
      -6: AddBullet(li.imgNo, TImageList(li.gr), not li.SameAsPrev);
      else
        begin
          if li.Center then
               AddCenterLine(Source.ContStorage[i], li.StyleNo)
          else
             if li.SameAsPrev then
                Add(Source.ContStorage[i], li.StyleNo)
             else
                AddFromNewLine(Source.ContStorage[i], li.StyleNo)
        end;
    end;
  end;
end;
{-------------------------------------}
function TChatView.GetLastCP: Integer;
begin
  GetLastCP := CheckPoints.Count-1;
end;
{-------------------------------------}
procedure TChatView.SetBackBitmap(Value: TBitmap);
begin
  FBackBitmap.Assign(Value);
  if (Value=nil) or (Value.Empty) then
     FullRedraw := False
  else
     case FBackgroundStyle of
       bsNoBitmap, bsTiledAndScrolled:
               FullRedraw := False;
       bsStretched, bsTiled:
               FullRedraw := True;
     end;
end;
{-------------------------------------}
procedure TChatView.SetBackgroundStyle(Value: TBackgroundStyle);
begin
  FBackgroundStyle := Value;
  if FBackBitmap.Empty then
     FullRedraw := False
  else
     case FBackgroundStyle of
       bsNoBitmap, bsTiledAndScrolled:
               FullRedraw := False;
       bsStretched, bsTiled:
               FullRedraw := True;
     end;
end;
{-------------------------------------}
procedure TChatView.DrawBack(DC: HDC; Rect: TRect; Width,Height:Integer);
var i, j: Integer;
    hbr: HBRUSH;
begin
 if FStyle = nil then exit; 
 if FBackBitmap.Empty or (FBackgroundStyle=bsNoBitmap) then
   begin
   hbr := CreateSolidBrush(ColorToRGB(FStyle.Color));
   dec(Rect.Bottom, Rect.Top);
   dec(Rect.Right, Rect.Left);
   Rect.Left := 0;
   Rect.Top := 0;
   FillRect(DC, Rect, hbr);
   DeleteObject(hbr);
   end
 else
   case FBackgroundStyle of
     bsTiled:
       for i := Rect.Top div FBackBitmap.Height to Rect.Bottom div FBackBitmap.Height do
         for j := Rect.Left div FBackBitmap.Width to Rect.Right div FBackBitmap.Width do
         BitBlt(DC, j*FBackBitmap.Width-Rect.Left,i*FBackBitmap.Height-Rect.Top, FBackBitmap.Width,
                FBackBitmap.Height, FBackBitmap.Canvas.Handle, 0, 0, SRCCOPY);
     bsStretched:
       StretchBlt(DC, -Rect.Left, -Rect.Top, Width, Height,
                  FBackBitmap.Canvas.Handle, 0, 0, FBackBitmap.Width, FBackBitmap.Height,
                  SRCCOPY);
     bsTiledAndScrolled:
       for i := (Rect.Top + VPos * VScrollStep) div FBackBitmap.Height to
               (Rect.Bottom + VPos * VScrollStep) div FBackBitmap.Height do
         for j := (Rect.Left+HPos) div FBackBitmap.Width to
                  (Rect.Right+HPos) div FBackBitmap.Width do
           BitBlt(DC, j*FBackBitmap.Width-HPos-Rect.Left,i*FBackBitmap.Height-VPos*VScrollStep-Rect.Top, FBackBitmap.Width,
                  FBackBitmap.Height, FBackBitmap.Canvas.Handle, 0, 0, SRCCOPY);
   end
end;
{-------------------------------------}
procedure TChatView.WMEraseBkgnd(var Message: TWMEraseBkgnd);
var r1: TRect;
begin
  if (csDesigning in ComponentState) then exit;
  Message.Result := 1;
  if (OldWidth<ClientWidth) or (OldHeight<ClientHeight) then begin
      GetClipBox(Message.DC, r1);
      DrawBack(Message.DC, r1, ClientWidth, ClientHeight);
  end;
  OldWidth := ClientWidth;
  OldHeight := ClientHeight;
end;
{-------------------------------------}
procedure TChatView.ShareLinesFrom(Source: TChatView);
begin
   if ShareContents then begin
     Clear;
     ContStorage := Source.ContStorage;
   end;
end;
{-------------------------------------}
function TChatView.GetFirstContainerInLine(FromContainerNumber: cardinal): cardinal;
var n, CurrentLine: cardinal;
//    dli : TDrawLineInfo;
begin
n := 0;
result := 1;
if FromContainerNumber >= 0 then
  begin
  n := FromContainerNumber;
  CurrentLine := TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo.LineNumber;
  for n := FromContainerNumber downto 0 do
    begin
    if (TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo.LineNumber < CurrentLine) then
      begin
      result := n + 1;
      break;
      end
    end;
  end;
end;
{-------------------------------------}
function TChatView.GetLastContainerInLine(FromContainerNumber: cardinal): cardinal;
var n, CurrentLine: cardinal;
//    dli : TDrawLineInfo;
begin
//эта процедура находит номер контейнера, стоящего в конце линии (строки)
//контейнеров. На входе НОМЕР контейнера, на выходе тоже НОМЕР контейнера в
//массиве отформатированных контейнеров DrawContainers.
n := 0;
result := FromContainerNumber;
if FromContainerNumber >= 0 then
  begin
  n := FromContainerNumber;
  CurrentLine := TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo.LineNumber;
  while n <= (DrawContainers.count - 1) do
    begin
    if TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo.LineNumber > CurrentLine then
      begin
      result := n - 1;
      break;
      end;
    inc(n);
    end;
  end;
end;
{-------------------------------------}
function TChatView.FindItemAtScreenPos(ScrX,ScrY: Integer): Integer;
begin
result := FindItemAtPos(ScrX + HPos,ScrY + VPos);
end;
{-------------------------------------}
function TChatView.FindItemAtPos(X,Y: Integer): Integer;
var
  n: Cardinal;
  dli: TDrawContainerInfo;
begin
result := -1;
for n := 0 to DrawContainers.Count - 1 do
  begin
  dli := TDrawContainerInfo(DrawContainers.Objects[n]);
  if (Y >= dli.pDrawLineInfo.BaseLine - dli.Height) and
     (Y <= dli.pDrawLineInfo.BaseLine) and
     (X > dli.Left) and (X < dli.Left + dli.Width) then
    begin
    result := n;
    break;
    end;
  end;
end;
{-------------------------------------}
function TChatView.FindNearItemAtScreenPos(ScrX, ScrY: Integer): Integer;
begin
ScrX := ScrX + HPos;
ScrY := ScrY + VPos;
result := FindNearItemAtPos(ScrX, ScrY);
end;
{-------------------------------------}
function TChatView.FindNearItemAtPos(X, Y: Integer): Integer;
//FindLineItemAtPos отличается от FindItemAtPos тем, что выдает номер контейнера
//не только когда на него неводят мышью, но и когда мышь находиться в пустотах
//между строк и на полях
var
  n, FirstInCurrLine, LastInCurrLine: Cardinal;
  dli: TDrawContainerInfo;
begin
result := -1;
{if Y >= TDrawContainerInfo(DrawContainers.Objects[DrawContainers.Count - 1]).pDrawLineInfo.BaseLine then
  begin
  //если курсор мыши ниже самой последней линии
//  FSelEndOffsInCont := Length(DrawContainers.Strings[DrawContainers.Count - 1]);
  result := DrawContainers.Count - 1
  end
else
  //иначе ищем где он}
for n := 1 to DrawContainers.Count - 1 do
  begin
  dli := TDrawContainerInfo(DrawContainers.Objects[n]);
  if (Y <= dli.pDrawLineInfo.BaseLine) and
     (Y >= dli.pDrawLineInfo.BaseLine - dli.pDrawLineInfo.MaxHeight) then
    begin
    //если курсор мыши находится между 2х строк
    if (X > dli.Left) and (X < dli.Left + dli.Width) then
      begin
      //мышь над контейнером
      result := n;
      break;
      end;
    end;
  end;  
{    else
      begin
      //мышь не над контейнером, возможно мышь на полях
      //или между правым краем и последним контейнером
      //проверям...
      first := GetFirstContainerInLine(n);
      dli := TDrawContainerInfo(DrawContainers.Objects[first]);
      if (X < dli.Left) then
        begin
        X := 0;
        result := first;
        break;
        end;
      last := GetLastContainerInLine(n);
      dli := TDrawContainerInfo(DrawContainers.Objects[last]);
      if (X > dli.Left + dli.Width) then
        begin
        X := 0;
        result := GetFirstContainerInLine(n);
        break;
        end;
      end;
    end;
  end;}
//кстати потом глянуть а какие размеры ставятся при добавлении '' (пустой) строки
{for n := 1 to DrawContainers.Count - 1 do
  begin
  //начинаем перебирать все контейнеры в поисках того, по короторому кликнули
  dli := TDrawContainerInfo(DrawContainers.Objects[n]);
  if (Y <= dli.pDrawLineInfo.BaseLine) and
     (Y >= dli.pDrawLineInfo.BaseLine - dli.pDrawLineInfo.MaxHeight) then
    begin
    //если курсор мыши попадает в высоту строки(находится между 2х строк)
    if (X > dli.Left) and (X < dli.Left + dli.Width) then
      begin
      //и в ширину контейнера, то мышь над контейнером
      result := n;
      break;
      end
    else
      begin
      //мышь между строк, но не над контролом (это может быть пустое
      //пространство между контролами или вообще где-нить на полях)
      LastInCurrLine := GetLastContainerInLine(n);
      dli := TDrawContainerInfo(DrawContainers.Objects[LastInCurrLine]);
      if (X > dli.Left + dli.Width) then
        begin
        //курсор мыши за последним контейнером этой линии (на правом поле)
        result := LastInCurrLine;
        end
      else
        begin
        //курсор мыши где-то между контейнеров этой линии
        end;
      FirstInCurrLine := GetFirstContainerInLine(n);
      dli := TDrawContainerInfo(DrawContainers.Objects[FirstInCurrLine]);
      if (X < dli.Left) then
        begin
        //курсор мыши перед первым контейнером этой линии (на правом поле)
        result := FirstInCurrLine;
        end
      else
        begin
        //курсор мыши где-то между контейнеров этой линии
        end;
      end;
    end;
  end;}
//FSelStartContNo, FSelEndContNo, FSelStartOffsInCont, FSelEndOffsInCont: Integer;
end;
{-------------------------------------}
procedure TChatView.FindStartItemSelection();
//FindLineItemAtPos отличается от FindItemAtPos тем, что выдает номер контейнера
//не только когда на него неводят мышью, но и когда мышь находиться в пустотах
//между строк и на полях
var
  n, FirstInCurrLine, LastInCurrLine: Cardinal;
  dli: TDrawContainerInfo;
begin
//кстати потом глянуть а какие размеры ставятся при добавлении '' (пустой) строки
for n := 1 to DrawContainers.Count - 1 do
  begin
  //начинаем перебирать все контейнеры в поисках того, на который указывает верхний
  //левый угол четырехугольника выделения
{  dli := TDrawContainerInfo(DrawContainers.Objects[n]);
  if (Y <= dli.pDrawLineInfo.BaseLine) and
     (Y >= dli.pDrawLineInfo.BaseLine - dli.pDrawLineInfo.MaxHeight) then
    begin
    //если курсор мыши попадает в высоту строки(находится между 2х строк)
    if (X > dli.Left) and (X < dli.Left + dli.Width) then
      begin
      //и в ширину контейнера, то мышь над контейнером
      result := n;
      break;
      end
    else
      begin
      //мышь между строк, но не над контролом (это может быть пустое
      //пространство между контролами или вообще где-нить на полях)
      LastInCurrLine := GetLastContainerInLine(n);
      dli := TDrawContainerInfo(DrawContainers.Objects[LastInCurrLine]);
      if (X > dli.Left + dli.Width) then
        begin
        //курсор мыши за последним контейнером этой линии (на правом поле)
        result := LastInCurrLine;
        end
      else
        begin
        //курсор мыши где-то между контейнеров этой линии
        end;
      FirstInCurrLine := GetFirstContainerInLine(n);
      dli := TDrawContainerInfo(DrawContainers.Objects[FirstInCurrLine]);
      if (X < dli.Left) then
        begin
        //курсор мыши перед первым контейнером этой линии (на правом поле)
        result := FirstInCurrLine;
        end
      else
        begin
        //курсор мыши где-то между контейнеров этой линии
        end;
      end;
    end;}
  end;     
//FSelStartContNo, FSelEndContNo, FSelStartOffsInCont, FSelEndOffsInCont: Integer;
end;
{-------------------------------------}
procedure TChatView.FindEndItemSelection();
var
  n, FirstInCurrLine, LastInCurrLine: Cardinal;
  dli: TDrawContainerInfo;
begin
end;
{-------------------------------------}
function TChatView.FindSymbolAtScreenPos(ScrX, ScrY: Integer): String;
var
  n: Cardinal;
  dli: TDrawContainerInfo;
  OffsWordNumber: integer;
  sz:TSize;
begin
result := '';
for n := 0 to DrawContainers.Count - 1 do
  begin
  dli := TDrawContainerInfo(DrawContainers.Objects[n]);
  if (ScrY >= dli.pDrawLineInfo.BaseLine - dli.Height) and
     (ScrY <= dli.pDrawLineInfo.BaseLine) and
     (ScrX > dli.Left) and (ScrX < dli.Left + dli.Width) then
    begin
    GetTextExtentExPoint(Canvas.Handle,  PChar(DrawContainers.Strings[n]),
                         Length(DrawContainers.Strings[n]),
                         ScrX - dli.Left,
                         @OffsWordNumber, nil,
                         sz);
    if OffsWordNumber <> 0 then
      result := Copy(DrawContainers.Strings[n], OffsWordNumber ,1);
    break;
    end;
  end;
end;
  {------------------------------------------------------------------}
function TChatView.FindClickedWord(var clickedword: String; var StyleNo: Integer): Boolean;
var no, lno: Integer;
    arr: array[0..1000] of integer;
    sz: TSIZE;
    max,first,len: Integer;
begin
  FindClickedWord := False;
  no := FindItemAtScreenPos(XClicked, YClicked);
  if no<>-1 then begin
     lno := TDrawContainerInfo(DrawContainers.Objects[no]).ContainerNumber;
     clickedword := DrawContainers[no];
     styleno := TContainerInfo(ContStorage.Objects[lno]).StyleNo;
     if styleno>=0 then begin
        with FStyle.TextStyles[StyleNo] do begin
         Canvas.Font.Style := Style;
         Canvas.Font.Size  := Size;
         Canvas.Font.Name  := FontName;
         Canvas.Font.CharSet  := CharSet;
       end;
       GetTextExtentExPoint(Canvas.Handle,  PChar(clickedword),  Length(clickedword),
                            XClicked+HPos-TDrawContainerInfo(DrawContainers.Objects[no]).Left,
                            @max, nil,
//                            max, arr[0],
                            sz);
       inc(max);
       if max>Length(clickedword) then max := Length(clickedword);
       first := max;
       if (Pos(clickedword[first], Delimiters)<>0) then begin
         ClickedWord := '';
         FindClickedWord := True;
         exit;
       end;
       while (first>1) and (Pos(clickedword[first-1], Delimiters)=0) do
         dec(first);
       len := max-first+1;
       while (first+len-1<Length(clickedword)) and (Pos(clickedword[first+len], Delimiters)=0) do
         inc(len);
       clickedword := copy(clickedword, first, len);
     end;
     FindClickedWord := True;
  end;

end;
  {------------------------------------------------------------------}
procedure TChatView.DblClick;
var
    StyleNo: Integer;
    clickedword: String;
begin
  inherited DblClick;
  if SingleClick or (not Assigned(FOnCVDblClick)) then exit;
  if FindClickedWord(clickedword, StyleNo) then
     FOnCVDblClick(Self, clickedword, StyleNo);
end;
  {------------------------------------------------------------------}
procedure TChatView.DeleteSection(CpName: String);
var i,j, startno, endno: Integer;
begin
   if ShareContents then exit;
   for i:=0 to checkpoints.Count-1 do
     if checkpoints[i]=CpName then begin
       startno := TCPInfo(checkpoints.Objects[i]).LineNo;
       endno := ContStorage.Count-1;
       for j := i+1 to checkpoints.Count-1 do
         if checkpoints[j]<>'' then
         begin
           endno := TCPInfo(checkpoints.Objects[j]).LineNo-1;
           break;
         end;
       DeleteLines(startno, endno-startno+1);
       exit;
     end;
end;
  {------------------------------------------------------------------}
procedure TChatView.DeleteLines(FirstLine, Count: Integer);
var i: Integer;
begin
  if ShareContents then exit;
  if FirstLine>=ContStorage.Count then exit;
  Deselect;
  if FirstLine+Count>ContStorage.Count then Count := ContStorage.Count-firstline;
  ContStorage.BeginUpdate;
  for i:=FirstLine to FirstLine+Count-1 do begin
    if TContainerInfo(ContStorage.objects[i]).StyleNo = -3 then { image}
      begin
//        TContainerInfo(ContStorage.objects[i]).gr.Free;//я закомментил
        TContainerInfo(ContStorage.objects[i]).gr := nil;
      end;
    if TContainerInfo(ContStorage.objects[i]).StyleNo = -5 then {wincontrol}
      begin
//        RemoveControl(TControl(TContainerInfo(ContStorage.objects[i]).gr));
        TContainerInfo(ContStorage.objects[i]).gr.Free;
        TContainerInfo(ContStorage.objects[i]).gr := nil;
      end;
    TContainerInfo(ContStorage.objects[i]).Free;
    ContStorage.objects[i] := nil;
  end;
  for i:=1 to Count do ContStorage.Delete(FirstLine);
  ContStorage.EndUpdate;
end;
{------------------------------------------------------------------}
procedure TChatView.CorrectSelectionBounds(x, y: integer);
var i: integer;
begin
//если выделение идет из правого нижнего в верхний левый или из левого нижнего
//в правый верхний, то меняем местами координаты углов рамки выделения
{    FSelStartX := x + HPos;
    FSelStartY := y + VPos;
    FSelEndX := x + HPos;
    FSelEndY := y + VPos;}
//    FSelEndX := x + HPos;
{TmpEndX := x + HPos;
TmpEndY := y + VPos;
if TmpStartY >= TmpEndY then
  begin
  FSelEndY := TmpStartY;
  FSelStartY := TmpEndY;
  end
else
  begin
  FSelEndY := TmpEndY;
  FSelStartY := TmpStartY;
  end;
if TmpStartX >= TmpEndX then
  begin
  FSelEndX := TmpStartX;
  FSelStartX := TmpEndX;
  end
else
  begin
  FSelEndX := TmpEndX;
  FSelStartX := TmpStartX;
  end;
}

{if (FSelStartY > FSelEndY) then
  begin
  i := FSelStartY;
  FSelStartY := FSelEndY;
  FSelEndY := i;
  end;}

//итак на этом этапе у нас исправлены координаты прямоугольника выделения
//т.е. конечные координаты больше начальных
//теперь нужно или установить выделение для контейнера (если мышь находиться над
//контейнером) или для всей строки (если мышь на полях)
end;
{------------------------------------------------------------------}
function TChatView.GetWordOffset(ContNumber:cardinal; XRange:integer;Str:PChar;StrLen:cardinal;
                                 var SelContNo, SelPixOffsInCont:integer):integer;
var OffsWordNumber, styleno:integer;
    dli:TDrawContainerInfo;
    sz:TSize;
begin
dli := TDrawContainerInfo(DrawContainers.Objects[ContNumber]);
styleno := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo;
if styleno >= 0 then
  begin
  with FStyle.TextStyles[StyleNo] do
    begin
    Canvas.Font.Style := Style;
    Canvas.Font.Size  := Size;
    Canvas.Font.Name  := FontName;
    Canvas.Font.CharSet := CharSet;
    end;
  //+------------------+  Допустим мышь указывает на букву А
  //| TChatView        |  нужно найти ее смещение от начала контейнера
  //|    ^             |
  //|     \            |
  OffsWordNumber := 0;
//  if SelStartX - dli.Left >= 0 then
  if XRange >= 0 then
  GetTextExtentExPoint(Canvas.Handle, PChar(Str),
                       StrLen,
                       XRange,//SelStartX - dli.Left,
                       @OffsWordNumber,//OffsWordNumber,
                       nil, sz);


//   FSelStartPixOffsInCont := canvas.TextWidth(Copy(DrawContainers.Strings[StartCont], 0, OffsWordNumber));
   SelContNo := ContNumber;
   SelPixOffsInCont := canvas.TextWidth(Copy(DrawContainers.Strings[ContNumber], 0, OffsWordNumber));
   if OffsWordNumber = 0 then SelPixOffsInCont := 0;
   result := OffsWordNumber;
  end;
{else
  begin
  //для контейнеров всех кроме текста
//  SelPixOffsInCont := XRange;//SelStartX - dli.Left;
  if (SelPixOffsInCont > dli.Width div 2) then
    SelContNo := ContNumber
  else
    SelContNo := ContNumber - 1;
  end;
{
dli := TDrawContainerInfo(DrawContainers.Objects[EndCont]);
styleno := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo;
if styleno >= 0 then
  begin
  with FStyle.TextStyles[StyleNo] do
    begin
    Canvas.Font.Style := Style;
    Canvas.Font.Size  := Size;
    Canvas.Font.Name  := FontName;
    Canvas.Font.CharSet := CharSet;
    end;
  //+------------------+  Допустим мышь указывает на букву А
  //| TChatView        |  нужно найти ее смещение от начала контейнера
  //|    ^             |
  //|     \            |
  OffsWordNumber := 0;
  if SelEndX - dli.Left >= 0 then
  GetTextExtentExPoint(Canvas.Handle, PChar(DrawContainers.Strings[EndCont]),
                       Length(DrawContainers.Strings[EndCont]),
                       SelEndX - dli.Left,
                       @OffsWordNumber, nil,
                       sz);

   FSelEndContNo := EndCont;
   FSelEndOffsInCont := OffsWordNumber;
   FSelEndPixOffsInCont := canvas.TextWidth(Copy(DrawContainers.Strings[EndCont], 0, OffsWordNumber));
   if OffsWordNumber = 0 then FSelEndPixOffsInCont := 0;
  end
else
  begin
  //для контейнеров всех кроме текста
  FSelEndPixOffsInCont := SelEndX - dli.Left;
  if (FSelEndPixOffsInCont > dli.Width div 2) then
    FSelEndContNo := EndCont
  else
    FSelEndContNo := EndCont - 1;
  end;}
end;

{------------------------------------------------------------------}
procedure TChatView.SetSelectionItems(x, y: integer);
//FindLineItemAtPos отличается от FindItemAtPos тем, что выдает номер контейнера
//не только когда на него неводят мышью, но и когда мышь находиться в пустотах
//между строк и на полях
var
  n, FirstInCurrLine, LastInCurrLine: Cardinal;
  dli, dli2: TDrawContainerInfo;
  OffsWordNumber, StyleNo, StartCont, EndCont, i, cont:integer;
  sz:TSize;
begin
//кстати потом глянуть а какие размеры ставятся при добавлении '' (пустой) строки
//FSelStartContNo, FSelEndContNo, FSelStartOffsInCont, FSelEndOffsInCont: Integer;
//SelStartX, SelStartY
//CorrectSelectionBounds(x, y);

    FDebugText2 := 'Start за последней строкой';
    self.OnDebug(FDebugText, FDebugText2);
    FSelStartContNo := DrawContainers.Count - 1;
    FSelStartOffsInCont := length(DrawContainers.Strings[DrawContainers.Count - 1]);
    FSelStartPixOffsInCont := 0;

for n := 1 to DrawContainers.Count - 1 do
  begin
  //начинаем перебирать все контейнеры в поисках того, по короторому кликнули
  dli := TDrawContainerInfo(DrawContainers.Objects[n]);
  if (FSelStartY <= dli.pDrawLineInfo.BaseLine) and
     (FSelStartY >= dli.pDrawLineInfo.BaseLine - dli.pDrawLineInfo.MaxHeight) then
    begin
    //если курсор мыши попадает в высоту строки(находится между 2х строк)
    if (FSelStartX > dli.Left) and (FSelStartX < dli.Left + dli.Width) then
      begin
      //и в ширину контейнера, то мышь над контейнером
      FSelStartContNo := n;
      FSelStartOffsInCont := 0;
      StyleNo := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo;
      if StyleNo >= 0 then
        begin
        //для текста
//        FDebugText2 := 'Start мышь над контейнером с текстом';
//        self.OnDebug(FDebugText, FDebugText2);
        FSelStartOffsInCont := GetWordOffset(n, FSelStartX - dli.Left,
                                             PChar(DrawContainers.Strings[n]),
                                             length(DrawContainers.Strings[n]),
                                             FSelStartContNo,
                                             FSelStartPixOffsInCont);
        end
      else
        begin
        //для контейнеров всех кроме текста
//        FDebugText2 := 'Start мышь над контейнером кроме текста';
//        self.OnDebug(FDebugText, FDebugText2);
        if (FSelStartX >= dli.Left + (dli.Width div 2)) then
          begin
          FSelStartPixOffsInCont := FSelStartX - dli.Left;
          FSelStartContNo := n
          end
        else
          begin
          FSelStartContNo := n + 1;
          end;
        end;
      break;
      end
    else
      begin
      //мышь между строк, но не над контролом (это может быть пустое
      //пространство между контролами или вообще где-нить на полях)
//      FDebugText2 := 'Start хз';
//      self.OnDebug(FDebugText, FDebugText2);
      FSelStartPixOffsInCont := 0;
      FirstInCurrLine := GetFirstContainerInLine(n);
      dli := TDrawContainerInfo(DrawContainers.Objects[FirstInCurrLine]);
      if (FSelStartX <= dli.Left) then
        begin
        //курсор мыши перед первым контейнером этой линии (на левом поле)
//        FDebugText2 := 'Start перед первым контейнером этой линии';
//        self.OnDebug(FDebugText, FDebugText2);
        FSelStartContNo := FirstInCurrLine;
        FSelStartOffsInCont := 0;
        break;
        end;
      LastInCurrLine := GetLastContainerInLine(n);
      dli := TDrawContainerInfo(DrawContainers.Objects[LastInCurrLine]);
      if (FSelStartX >= dli.Left + dli.Width) then
        begin
//        FDebugText2 := 'Start за последним контейнером этой линии';
//        self.OnDebug(FDebugText, FDebugText2);
        FSelStartContNo := FirstInCurrLine;
        FSelStartOffsInCont := 0;
        break;
        end;
      //курсор мыши где-то между контейнеров этой линии
      dli := TDrawContainerInfo(DrawContainers.Objects[n]);
//      FDebugText2 := 'Start между' +
//      '  n:=' + inttostr(n);
//      self.OnDebug(FDebugText, FDebugText2);
      FSelStartContNo := n;
      FSelStartOffsInCont := 0;
      end;
    end;
{  else
    begin
    //если за последней строкой (в самом низу контейнера)
    FDebugText2 := 'Start за последней строкой';
    self.OnDebug(FDebugText, FDebugText2);
    FSelStartContNo := DrawContainers.Count - 1;
    FSelStartOffsInCont := length(DrawContainers.Strings[DrawContainers.Count - 1]);
    FSelStartPixOffsInCont := 0;
    end;}
  end;

    FDebugText2 := 'End за последней строкой';
    self.OnDebug(FDebugText, FDebugText2);
    FSelEndContNo := DrawContainers.Count - 1;
    FSelEndOffsInCont := length(DrawContainers.Strings[DrawContainers.Count - 1]);
    FSelEndPixOffsInCont := 0;

for n := 1 to DrawContainers.Count - 1 do
  begin
  //начинаем перебирать все контейнеры в поисках того, по короторому кликнули
  dli := TDrawContainerInfo(DrawContainers.Objects[n]);
  if (FSelEndY <= dli.pDrawLineInfo.BaseLine) and
     (FSelEndY >= dli.pDrawLineInfo.BaseLine - dli.pDrawLineInfo.MaxHeight) then
    begin
    //если курсор мыши попадает в высоту строки(находится между 2х строк)
    if (FSelEndX > dli.Left) and (FSelEndX < dli.Left + dli.Width) then
      begin
      //и в ширину контейнера, то мышь над контейнером
      FSelEndContNo := n;
      FSelEndOffsInCont := 0;
      StyleNo := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo;
      if StyleNo >= 0 then
        begin
        //для текста
        FDebugText2 := 'End мышь над контейнером с текстом';
        self.OnDebug(FDebugText, FDebugText2);
        FSelEndOffsInCont := GetWordOffset(n, FSelEndX - dli.Left,
                                             PChar(DrawContainers.Strings[n]),
                                             length(DrawContainers.Strings[n]),
                                             FSelEndContNo,
                                             FSelEndPixOffsInCont);
        end
      else
        begin
        //для контейнеров всех кроме текста
        FDebugText2 := 'End мышь над контейнером кроме текста';
        self.OnDebug(FDebugText, FDebugText2);
        if (FSelEndX >= dli.Left + (dli.Width div 2)) then
          begin
          FSelEndPixOffsInCont := FSelEndX - dli.Left;
          FSelEndContNo := n;
          end
        else
          begin
          FSelEndContNo := n + 1;
          end;
        end;
      break;
      end
    else
      begin
      //мышь между строк, но не над контролом (это может быть пустое
      //пространство между контролами или вообще где-нить на полях)
      FDebugText2 := 'End хз';
      self.OnDebug(FDebugText, FDebugText2);
      FSelEndPixOffsInCont := 0;
      FirstInCurrLine := GetFirstContainerInLine(n);
      dli := TDrawContainerInfo(DrawContainers.Objects[FirstInCurrLine]);
      if (FSelEndX <= dli.Left) then
        begin
        //курсор мыши перед первым контейнером этой линии (на левом поле)
        FDebugText2 := 'End перед первым контейнером этой линии';
        self.OnDebug(FDebugText, FDebugText2);
        FSelEndContNo := FirstInCurrLine;
        FSelEndOffsInCont := 0;
        break;
        end;
      LastInCurrLine := GetLastContainerInLine(n);
      dli := TDrawContainerInfo(DrawContainers.Objects[LastInCurrLine]);
      if (FSelEndX >= dli.Left + dli.Width) then
        begin
        FDebugText2 := 'End за последним контейнером этой линии';
        self.OnDebug(FDebugText, FDebugText2);
        FSelEndContNo := LastInCurrLine;
        FSelEndOffsInCont := length(DrawContainers.Strings[LastInCurrLine]);
        break;
        end;
      //курсор мыши где-то между контейнеров этой линии
      //находим между каких
      if (n + 1 <= DrawContainers.Count - 1) then
        begin
        dli := TDrawContainerInfo(DrawContainers.Objects[n]);
        dli2 := TDrawContainerInfo(DrawContainers.Objects[n + 1]);
        if (FSelEndX >= dli.Left + dli.Width) and
           (FSelEndX <= dli2.Left) then
          begin
          FDebugText2 := 'End между' +
          '  n:=' + inttostr(n);
          self.OnDebug(FDebugText, FDebugText2);
          FSelEndContNo := n;
          FSelEndOffsInCont := length(DrawContainers.Strings[n]);
          FSelEndPixOffsInCont := x;
          break;
          end;
        end;
      end;
    end;
{  else
    begin
    //если за последней строкой (в самом низу контейнера)
    FDebugText2 := 'End за последней строкой';
    self.OnDebug(FDebugText, FDebugText2);
    FSelEndContNo := DrawContainers.Count - 1;
    FSelEndOffsInCont := length(DrawContainers.Strings[DrawContainers.Count - 1]);
    FSelEndPixOffsInCont := 0;
    end;}
  end;


if FSelStartContNo > FSelEndContNo then
  begin
  n := FSelEndContNo;
  FSelEndContNo := FSelStartContNo;
  FSelStartContNo := n;

  i := FSelEndOffsInCont;
  FSelEndOffsInCont := FSelStartOffsInCont;
  FSelStartOffsInCont := i;
  end
else
  begin
  if (FSelStartContNo = FSelEndContNo) then
    begin
    if (FSelStartOffsInCont > FSelEndOffsInCont) then
      begin
      n := FSelEndOffsInCont;
      FSelEndOffsInCont := FSelStartOffsInCont;
      FSelStartOffsInCont := n;
      end;
    if (FSelStartPixOffsInCont > FSelEndPixOffsInCont) then
      begin
      n := FSelEndPixOffsInCont;
      FSelEndPixOffsInCont := FSelStartPixOffsInCont;
      FSelStartPixOffsInCont := n;
      end;
    end;
  end;

{StartCont := FindNearItemAtPos(SelStartX, SelStartY);
//StartCont := GetFirstContainerInLine(StartCont);
if StartCont < 0 then exit;

EndCont := FindNearItemAtPos(SelEndX, SelEndY);
//EndCont := GetLastContainerInLine(EndCont);
if EndCont < 0 then exit;
}





end;
{------------------------------------------------------------------}
procedure TChatView.RestoreSelBounds(StartNo, EndNo, StartOffs, EndOffs: Integer);
var i: Integer;
    dli, dli2, dli3: TDrawContainerInfo;
begin
  if StartNo = -1 then exit;
{  for i :=0 to DrawContainers.Count-1 do begin
    dli := TDrawContainerInfo(DrawContainers.Objects[i]);
    if dli.ContainerNumber = StartNo then
      if TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo<0 then begin
        FSelStartContNo := i;
        FSelStartOffsInCont := StartOffs;
        end
      else begin
        if i<>DrawContainers.Count-1 then
          dli2 := TDrawContainerInfo(DrawContainers.Objects[i+1])
        else
          dli2 := nil;
        if i<>0 then
          dli3 := TDrawContainerInfo(DrawContainers.Objects[i-1])
        else
          dli3 := nil;
        if
          ((dli.Offs<=StartOffs) and (Length(DrawContainers[i])+dli.Offs>StartOffs)) or
          ((StartOffs>Length(ContStorage[dli.ContainerNumber])) and ((dli2=nil)or(dli2.ContainerNumber<>dli.ContainerNumber))) or
          ((dli.Offs>StartOffs) and ((dli3=nil)or(dli3.ContainerNumber<>dli.ContainerNumber)))
        then begin
          FSelStartContNo := i;
          FSelStartOffsInCont := StartOffs-dli.Offs+1;
          if FSelStartOffsInCont<0 then FSelStartOffsInCont := 0;
          if FSelStartOffsInCont>dli.Offs+Length(DrawContainers[i]) then FSelStartOffsInCont := dli.Offs+Length(DrawContainers[i]);
        end;
      end;
    if dli.ContainerNumber = EndNo then
      if TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo<0 then begin
        FSelEndContNo := i;
        FSelEndOffsInCont := EndOffs;
        end
      else begin
        if i<>DrawContainers.Count-1 then
          dli2 := TDrawContainerInfo(DrawContainers.Objects[i+1])
        else
          dli2 := nil;
        if i<>0 then
          dli3 := TDrawContainerInfo(DrawContainers.Objects[i-1])
        else
          dli3 := nil;
        if
          ((dli.Offs<=EndOffs) and (Length(DrawContainers[i])+dli.Offs>EndOffs)) or
          ((EndOffs>Length(ContStorage[dli.ContainerNumber])) and ((dli2=nil)or(dli2.ContainerNumber<>dli.ContainerNumber))) or
          ((dli.Offs>EndOffs) and ((dli3=nil)or(dli3.ContainerNumber<>dli.ContainerNumber)))
        then begin
          FSelEndContNo := i;
          FSelEndOffsInCont := EndOffs-dli.Offs+1;
          if FSelEndOffsInCont<0 then FSelEndOffsInCont := 0;
          if FSelEndOffsInCont>dli.Offs+Length(DrawContainers[i]) then FSelEndOffsInCont := dli.Offs+Length(DrawContainers[i]);
        end;
      end;
  end;}
end;
  {------------------------------------------------------------------}
function TChatView.SelectionExists: Boolean;
var StartNo, EndNo, StartOffs, EndOffs: Integer;
begin
if (FSelStartX >= 0) and (FSelStartY >= 0) and
  (FSelEndX >= 0) and (FSelEndY >= 0) then
    Result := True
  else
    Result := False
end;
  {------------------------------------------------------------------}
function TChatView.GetSelText: String;
var StartNo, EndNo, StartOffs, EndOffs, i: Integer;
    s : String;
    li : TContainerInfo;
begin
  Result := '';
  if not SelectionExists then exit;
  { getting selection as ContStorage indices }
//  StoreSelBounds(StartNo, EndNo, StartOffs, EndOffs);
  if StartNo = EndNo then begin
    li := TContainerInfo(ContStorage.Objects[StartNo]);
    if li.StyleNo < 0 then exit;
    Result := Copy(ContStorage[StartNo], StartOffs, EndOffs-StartOffs);
    exit;
    end
  else begin
    li := TContainerInfo(ContStorage.Objects[StartNo]);
    if li.StyleNo < 0 then
      s := ''
    else
      s := Copy(ContStorage[StartNo], StartOffs, Length(ContStorage[StartNo]));
    for i := StartNo+1 to EndNo do begin
      li := TContainerInfo(ContStorage.Objects[i]);
      if (li.StyleNo<>cvsCheckpoint) and not li.SameAsPrev then
          s := s+chr(13);
      if li.StyleNo >= 0 then
        if i<>EndNo then
          s := s + ContStorage[i]
        else
          s := s + Copy(ContStorage[i], 1, EndOffs-1);
    end;
    Result := AdjustLineBreaks(s);
    exit;
  end;
end;
  {------------------------------------------------------------------}
procedure TChatView.CopyText;
begin
  if SelectionExists then begin
    ClipBoard.Clear;
    Clipboard.SetTextBuf(PChar(GetSelText));
  end;
end;
  {------------------------------------------------------------------}
procedure TChatView.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if SelectionExists and (ssCtrl in Shift) then begin
    if (Key = ord('C')) or (Key = VK_INSERT) then CopyText;
    end
  else
    inherited KeyDown(Key,Shift)
end;
  {------------------------------------------------------------------}
procedure TChatView.OnScrollTimer(Sender: TObject);
begin
if ScrollToY > 0 then
  begin
  VScrollPos := VScrollPos + TimerScrollStepY;
  end;
if ScrollDeltaY <> 0 then
  begin
  VScrollPos := VScrollPos + ScrollDeltaY;
//  MouseMove([], XMouse, YMouse);
  end;
end;
  {------------------------------------------------------------------}
procedure TChatView.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation=opRemove) and (AComponent=FStyle) then begin
      Style := nil;
  end;
end;
  {------------------------------------------------------------------}
procedure TChatView.Click;
begin
  SetFocus;
  inherited;
end;
  {------------------------------------------------------------------}
procedure TChatView.Loaded;
begin
  inherited Loaded;
  Format;
end;
  {------------------------------------------------------------------}
procedure TChatView.SetGifAniCanvas(DestionationCanvas: TCanvas);
var n, FirstVisible, LastVisible : Cardinal;
    dli:TDrawContainerInfo;
    li: TContainerInfo;
    r :TRect;
begin
//Для чего все это:
FirstVisible := FirstVisibleContainer;
LastVisible := LastVisibleContainer;
for n := 0 to DrawContainers.Count - 1 do
  begin
  {в i в цикле прокручиваются номера строк, видимых на экране}
  {DrawContainers - это массив строк, которые ВИДНЫ на экране типа TStringList}
  dli := TDrawContainerInfo(DrawContainers.Objects[n]);
  li := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]);
  if li.StyleNo = -8 then
    begin
    if (n >= FirstVisible) and (n <= LastVisible) then
      begin
    //понял!!!!!! я всем призракам задаю координаты родителя!!!!!!
    //т.е. когда цикл дойдет до очередного призрака я должен:
    //найти его номер в MirrorImagesY[n] массве родителя
      TGifAni(li.gr).DestCanvas := DestionationCanvas;
      TGifAni(li.gr).ShowingAnimation[li.imgNo] := true;
      end
    else
      begin
      TGifAni(li.gr).ShowingAnimation[li.imgNo] := false;
      end;
    end;
  if li.StyleNo = -5 then
    begin
    if (n > LastVisible) or (n < FirstVisible) then
      begin
      TWinControl(li.gr).visible := false;
      end
    else
      begin
      TWinControl(li.gr).visible := true;
      TWinControl(li.gr).repaint;
      end;
    end;
  end;
end;
{-------------------------------------}
procedure TChatView.WMVScroll(var Message: TWMVScroll);
var i : Integer;
    dli:TDrawContainerInfo;
    li: TContainerInfo;
    r :TRect;
begin
//Для чего все это:
//При прокручивании не вызывается ф-ция Paint, сл-но не изменяются координаты
//объекта GifAni. Приходится отлавливать скроллинг и обновлять координаты.
inherited;
SetGifAniCanvas(self.Canvas);
end;
procedure TChatView.WMHScroll(var Message: TWMVScroll);
//ГОРИЗОНТАЛЬНЫЙ!!!!
//доделать! Учитывать HPos!!!
var i : Integer;
    dli:TDrawContainerInfo;
    li: TContainerInfo;
    r :TRect;
begin
//Для чего все это:
//При прокручивании не вызывается ф-ция Paint, сл-но не изменяются координаты
//объекта GifAni. Приходится отлавливать скроллинг и обновлять координаты.
inherited;
Invalidate;
//SetGifAniCanvas(self.Canvas);
end;

























{-------------------------------------}
procedure TChatView.Paint;
var i,no, yshift, xshift, n: Integer;
    cl, textcolor: TColor;
    dli:TDrawContainerInfo;
    li: TContainerInfo;
    lastline, hovernow: Boolean;
    r, rect1, GifRect :TRect;
    canv : TCanvas;
    s, s1 : String;
//    StartNo, EndNo, StartOffs, EndOffs: Integer;
//    GifFrame: TGifFrame;
    GIFImage:TGif;
    FirstVisible, LastVisible: cardinal;
begin
//xshift - т.к. при форматировании контейнеров координаты контейнеров задаются
//         от 0 до ширины канваса, то при выводе часть канваса может уходить за
//         начало экрана и имет -координаты. Чтобы правильно выводились контейнеры
//         нужно вычитать из них отрицательную часть канваса. Xshift она и есть.
//yshift - это высота в пикселах до того места, с которого необходимо перерисовать канвас

{определяем состояние TChatView компонента}
 if (csDesigning in ComponentState) or
    not Assigned(FStyle) then
   begin
    {если не присвоен компонент Style}
    cl := Canvas.Brush.Color;
    if Assigned(FStyle) then
        Canvas.Brush.Color := FStyle.Color
    else
        Canvas.Brush.Color := clWindow;
    Canvas.Brush.Style := bsSolid;
    Canvas.Pen.Color := clWindowText;
    Canvas.Font.Color := clWindowText;
    Canvas.Font.Name := 'MS Sans Serif';
    Canvas.Font.Size := 8;
    Canvas.Font.Style := [];
    Canvas.FillRect(Canvas.ClipRect);
    if (csDesigning in ComponentState) then
      Canvas.TextOut(ClientRect.Left+1, ClientRect.Top+1, FVersion)
    else
      Canvas.TextOut(ClientRect.Left+1, ClientRect.Top+1, 'Error: style is not assigned');
    Canvas.Brush.Color := clWindowText;
    Canvas.FrameRect(ClientRect);
    Canvas.Brush.Color := cl;
    exit;
 end;

// GetSelBounds(StartNo, EndNo, StartOffs, EndOffs);
 {
 StartNo - номер 1й выделенной строки
 EndNo - номер последней выделенной строки
 StartOffs - ???? номер символа с которого начинается выделение
 EndOffs - ???? номер символа на котором заканчивается выделение
 }
 lastline := False;
 r := Canvas.ClipRect;
//Use ClipRect to determine where the canvas needs painting.
//Если плавно сдвигать, то обычно это только 1 пиксел
//Внимание! Далее мы создает BufferVirtCanv высотой = окну TChatView!
 BufferVirtCanv.Width := r.Right - r.Left + 1;
 BufferVirtCanv.Height := r.Bottom - r.Top + 1;
//а потом в этот 1 пиксел должны вывести только то, что нужно!!!!!
//доделать оптимальную отрисовку!!!!!!!!
 canv := BufferVirtCanv.Canvas;
 DrawBack(canv.Handle, Canvas.ClipRect, ClientWidth, ClientHeight);
 yshift := VPos{ * VScrollStep};
 r.Top := r.Top + yshift;
 r.Bottom := r.Bottom + yshift;
 yshift := yshift + Canvas.ClipRect.Top;
 xshift := HPos + Canvas.ClipRect.Left;
 xshift := HPos + Canvas.ClipRect.Left;
 canv.Brush.Style := bsClear;

//FDebugText := 'r.Top  = ' + inttostr(r.TopLeft.y) +
//              'r.Bottom = ' + inttostr(r.BottomRight.y);
//self.OnDebug(FDebugText);

canv.Rectangle(FSelStartX - HPos, FSelStartY - VPos,
               FSelEndX - HPos, FSelEndY - VPos);

//доделать оптимальную отрисовку!!!!!!!!
//в качестве параметров передавать 1 пиксел из r. Читать выше!!!!
FirstVisible := GetFirstVisibleContainer();
LastVisible := GetLastVisibleContainer();
 for i := FirstVisible to LastVisible do
   begin
   //в i в цикле прокручиваются номера контейнеров, видимых на экране
   dli := TDrawContainerInfo(DrawContainers.Objects[i]);
//   if (lastline = True) and (dli.Left <= TDrawContainerInfo(DrawContainers.Objects[i-1]).left) then break;
//   if dli.top^ > r.Bottom then lastline := True;
   if dli.Bottom^ - dli.Height > r.Bottom then lastline := True;
   li := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]);
   no := li.StyleNo;
   if no >= 0 then
     begin // text
     canv.Font.Style := FStyle.TextStyles[no].Style;
     canv.Font.Size := FStyle.TextStyles[no].Size;
     canv.Font.Name := FStyle.TextStyles[no].FontName;
     canv.Font.CharSet := FStyle.TextStyles[no].CharSet;
     if not ((no in [cvsJump1, cvsJump2]) and DrawHover and
        (LastJumpMovedAbove<>-1) and
        (li.ImgNo = LastJumpMovedAbove)) then
       begin
       textcolor := FStyle.TextStyles[no].Color;
       hovernow := False;
       end
     else
       begin
       textcolor := FStyle.HoverColor;
       hovernow := True;
       canv.Font.Color := textcolor;
       end;
     if (i < FSelStartContNo) or (i > FSelEndContNo) or
        ((FSelStartContNo = FSelEndContNo) and (FSelStartOffsInCont = FSelEndOffsInCont))
       then
       begin
       //если очередной контейнер не попадает в выделенный участок или выделение пустое
       //выводим обычный текст
       canv.Font.Color := textcolor;
       canv.TextOut(dli.Left - xshift, dli.Bottom^ - dli.Height - yshift, DrawContainers.Strings[i]);
       end
     else
       begin
       //если очередной контейнер находиться в выделенном участоке
       //т.к. выделение текста может быть начато с середины контейнера и
       //закончено тоже в середине, нужно парвильно отобразить выделенный кусок
       //в начале и в конце
      if (i = FSelStartContNo) and (FSelStartOffsInCont > 0) then
          begin
          //выводим не выделенное начало (если выделение не с начала строки)
          s := Copy(DrawContainers.Strings[i], 0, FSelStartOffsInCont);
          canv.Font.Color := textcolor;
//        if not hovernow then canv.Font.Color := FStyle.SelTextColor;
          canv.TextOut(dli.Left - xshift, dli.Bottom^ - dli.Height - yshift, s);
          end;

       if (FSelStartContNo = FSelEndContNo) then
          begin
          //выводим ВЕСЬ выделенный текст в пределах одного контейнера
          s := Copy(DrawContainers.Strings[i], FSelStartOffsInCont + 1, FSelEndOffsInCont - FSelStartOffsInCont);
          canv.Brush.Style := bsSolid;
          canv.Brush.Color := FStyle.SelColor;
          canv.Font.Color := FStyle.SelTextColor;
          canv.TextOut(dli.Left - xshift + FSelStartPixOffsInCont, dli.Bottom^ - dli.Height - yshift, s);
          canv.Brush.Style := bsClear;
          if (FSelEndOffsInCont > 0) then
            begin
            //выводим не выделенный конец (если выделение не до конца строки)
            canv.Font.Color := textcolor;
            canv.TextOut(dli.Left - xshift + FSelStartPixOffsInCont + canv.TextWidth(s),
                         dli.Bottom^ - dli.Height - yshift,
                         Copy(DrawContainers.Strings[i], FSelEndOffsInCont + 1, Length(DrawContainers.Strings[i])));
            end;
          end
        else
          //если выделено более одного контейнера FSelStartContNo <> FSelEndContNo
          begin
          if (i = FSelStartContNo) then
            begin
            canv.Brush.Style := bsSolid;
            canv.Brush.Color := FStyle.SelColor;
            canv.Font.Color := FStyle.SelTextColor;
//       if not hovernow then canv.Font.Color := FStyle.SelTextColor;
            s := Copy(DrawContainers.Strings[i], 0, FSelStartOffsInCont);
            canv.TextOut(dli.Left + canv.TextWidth(s),
                         dli.Bottom^ - dli.Height - yshift,
                         Copy(DrawContainers.Strings[i], FSelStartOffsInCont + 1, Length(DrawContainers.Strings[i])));
            canv.Brush.Style := bsClear;
            end;
          if (i > FSelStartContNo) and (i < FSelEndContNo) then
            begin
            canv.Brush.Style := bsSolid;
            canv.Brush.Color := FStyle.SelColor;
            canv.Font.Color := FStyle.SelTextColor;
//       if not hovernow then canv.Font.Color := FStyle.SelTextColor;
            canv.TextOut(dli.Left - xshift, dli.Bottom^ - dli.Height - yshift, DrawContainers.Strings[i]);
            canv.Brush.Style := bsClear;
            end;
          if (i = FSelEndContNo) then
            begin
            if (FSelEndOffsInCont > 0) then
              begin
              //выводим выделенный конец
              s := Copy(DrawContainers.Strings[i], 0, FSelEndOffsInCont);
              canv.Font.Color := textcolor;
              canv.Brush.Style := bsSolid;
              canv.Brush.Color := FStyle.SelColor;
              canv.Font.Color := FStyle.SelTextColor;
              canv.TextOut(dli.Left - xshift, dli.Bottom^ - dli.Height - yshift, s);
              canv.Brush.Style := bsClear;
              end;
            if (FSelEndOffsInCont >= 0) then
              begin
              //выводим не выделенный конец
              s := Copy(DrawContainers.Strings[i], 0, FSelEndOffsInCont);
              canv.Font.Color := textcolor;
              canv.TextOut(dli.Left - xshift + canv.TextWidth(s),
                           dli.Bottom^ - dli.Height - yshift,
                           Copy(DrawContainers.Strings[i], FSelEndOffsInCont + 1, length(DrawContainers.Strings[i]) - FSelEndOffsInCont + 1));
              end;
            end;
          end;
       end;
     continue;
     end;
{===============================================================================}
   if (no = -8)  then // gifanimate
     begin
     //рисуем рамку при выделении
     if (i >= FSelStartContNo) and (i <= FSelEndContNo) then
       canv.Rectangle(dli.Left - HPos - 1, dli.Bottom^ - VPos,
                      dli.Left - HPos + dli.Width + 1,
                      dli.Bottom^ - VPos - dli.Height - 1);
     TGifAni(li.gr).MirrorImagesY[li.imgNo] := dli.Bottom^ - dli.Height - VPos {* VScrollStep};
     TGifAni(li.gr).MirrorImagesX[li.imgNo] := dli.Left - HPos;
     TGifAni(li.gr).DestCanvas := canv;
     TGifAni(li.gr).DrawFrame(li.imgNo, xshift - HPos, dli.Bottom^ - dli.Height - yshift);
     end;
{===============================================================================}
   if (no = -7)  then // gif }
     begin
     end;
{===============================================================================}
   if (no = -5)  then // WinControl
     begin
     //рисуем рамку при выделении
     if (i >= FSelStartContNo) and (i <= FSelEndContNo) then
       canv.Rectangle(dli.Left - HPos - 1, dli.Bottom^ - VPos,
                      dli.Left - HPos + dli.Width + 1,
                      dli.Bottom^ - VPos - dli.Height - 1);
     //рисуем, то мы начиная с левого ВЕРХНЕГО угла, а это выше базовой линии на
     //высоту контрола
     TWinControl(li.gr).Top := dli.Bottom^ - dli.Height - VPos {* VScrollStep};
     TWinControl(li.gr).Left := dli.Left - HPos;

{     FDebugText2 := FDebugText + #10#13 +
                   'paint: TWinControl(li.gr).Top =' + Inttostr(TWinControl(li.gr).Top) + #10#13 +
                   'paint: TWinControl(li.gr).Left =' + Inttostr(TWinControl(li.gr).Left);
     self.OnDebug(FDebugText2);}
     end;
{===============================================================================}
   if (no = -4) or (no = -6)  then
     begin // hotspots and bullets
     if (FSelStartContNo<=i) and (FSelEndContNo>=i) and
        not ((FSelEndContNo=i) and (FSelEndOffsInCont=0)) and
        not ((FSelStartContNo=i) and (FSelStartOffsInCont=2)) then
       begin
       TImageList(li.gr).BlendColor := FStyle.SelColor;
       TImageList(li.gr).DrawingStyle := dsSelected;
     end;
//     TImageList(li.gr).Draw(canv, dli.Left-xshift, dli.top^ -yshift, li.imgNo);
     TImageList(li.gr).Draw(canv, dli.Left - xshift - HPos, dli.Bottom^ - dli.Height - yshift, li.imgNo);
     TImageList(li.gr).DrawingStyle := dsNormal;
     continue;
   end;
{===============================================================================}
   if (no = -3)  then
     begin // graphics
     canv.Draw(dli.Left - xshift - HPos, dli.Bottom^  - yshift, TGraphic(li.gr));
     continue;
     end;
{===============================================================================}
//   if no = -2 then continue; // check point
   if no = -1 then
     begin //break line
     canv.Pen.Color := FStyle.TextStyles[0].Color;
     canv.MoveTo(dli.Left + 5 - xshift, dli.Bottom^ - dli.Height div 2 - yshift);
     canv.LineTo(XSize - 5 - xshift - FRightMargin, dli.Bottom^ - dli.Height div 2 - yshift);
     end;
   // controls ignored
   end;

Canvas.Draw(Canvas.ClipRect.Left, Canvas.ClipRect.Top, BufferVirtCanv);
SetGifAniCanvas(Canvas);
end;

{------------------------------------------------------------------}
procedure TChatView.Format_(OnlyResized:Boolean; depth: Integer; Canvas: TCanvas;
                            OnlyTail: Boolean);
var i, j: Integer;
    OldLine, line, x, b, d, a: Integer;
    pPartStr: Pchar;
    NewLine: Boolean;
    CrDrawLine: Boolean;
    xOld, bOld, dOld, aOld: Integer;
    mx: Integer;
    oldy, oldtextwidth, cw, ch: Integer;
    sad: TScreenAndDevice;
    StyleNo: Integer;
    StartContainer: Integer;
    StartNo, EndNo, StartOffs, EndOffs: Integer;
    LineInfo: TDrawLineInfo;
    LastDrawContainer:cardinal;
begin
   if VScrollStep = 0 then exit;
   if (csDesigning in ComponentState) or
      not Assigned(FStyle) or
      skipformatting or
      (depth>1)
      then exit;
   skipformatting := True;

//   if depth = 0 then StoreSelBounds(StartNo, EndNo, StartOffs, EndOffs);

   OldY := self.VPos;

   oldtextwidth := self.TextWidth;

   {self - это экземпляр компонента TChatView, созданный пользователем}
   //узнаем что больше: размер канваса или размер объектов-картинок
   mx := max(self.ClientWidth - (self.FLeftMargin + self.FRightMargin), GetMaxPictureWidth);
   if mx < self.FMinTextWidth then mx := self.FMinTextWidth;

   if self.FClientTextWidth = true then
     begin { widths of pictures and maxtextwidth are ignored }
     self.TextWidth := self.ClientWidth - (self.FLeftMargin + self.FRightMargin);
     if self.TextWidth < self.FMinTextWidth then self.TextWidth := self.FMinTextWidth;
     end
   else
     begin
     if (mx > self.FMaxTextWidth) and (self.FMaxTextWidth > 0) then
       self.TextWidth := self.FMaxTextWidth
     else
       self.TextWidth := mx;
     end;

   if not (OnlyResized and (self.TextWidth = OldTextWidth)) then
     begin
     if OnlyTail = true then
       begin
       //если нужно отформатировать только те контейнеры, которые были добавлены
       //в конец, зачит нужно восстановить ситуацию на момент окончания форматирования
       //в предыдущем проходе
       LastDrawContainer := DrawContainers.Count - 1;
       StartContainer := TDrawContainerInfo(DrawContainers.Objects[LastDrawContainer]).ContainerNumber + 1;
       b:= self.TextHeight;
       LineInfo := TDrawContainerInfo(DrawContainers.Objects[LastDrawContainer]).pDrawLineInfo;
       Line := TDrawLineInfo(DrawLinesInfo.Objects[DrawLinesInfo.count - 1]).LineNumber;
       x := TDrawContainerInfo(DrawContainers.Objects[LastDrawContainer]).Left +
            TDrawContainerInfo(DrawContainers.Objects[LastDrawContainer]).Width;
       b := TDrawContainerInfo(DrawContainers.Objects[LastDrawContainer]).pDrawLineInfo.BaseLine;
       inc(Line);
       end
     else
       begin
       StartContainer := 0;
       ClearTemporal;
       LineInfo := nil;
       line := 0;
       x := 0;
       b := 0;
       if DrawLinesInfo.Count > 0 then
         begin
         for i := 0 to DrawLinesInfo.Count - 1 do
           begin
           TDrawLineInfo(DrawLinesInfo.Objects[i]).Free;
           end;
         DrawLinesInfo.clear;
         end;
       end;

     pPartStr := nil;
     d := 0;
     a := 0;

     InfoAboutSaD(sad, Canvas);
     sad.LeftMargin := MulDiv(self.FLeftMargin,  sad.ppixDevice, sad.ppixScreen);

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
     for i := StartContainer to ContStorage.Count - 1 do
       begin
       StyleNo := TContainerInfo(ContStorage.Objects[i]).StyleNo;
       //проверка на ошибочное сочетание стиля и опций
       if not (((StyleNo = cvsPicture) and (not (cvdoImages in DisplayOptions))) or
          ((StyleNo = CvsComponent)and(not (cvdoComponents in DisplayOptions))) or
          (((StyleNo = cvsBullet) or
          (StyleNo = cvsHotspot))and(not (cvdoBullets in DisplayOptions)))) then
         begin
         if TContainerInfo(ContStorage.Objects[i]).SameAsPrev = false then
           {т.е. была каманда AddCenterLine или AddFromNewLine}
           begin
           NewLine := true;
           end;
         FormatNextContainer(LineInfo, line, i, x, b, a, pPartStr, NewLine, Canvas, sad);
         if Line > 1 then
           TDrawLineInfo(DrawLinesInfo.Objects[Line - 1]).BaseLine :=
           TDrawLineInfo(DrawLinesInfo.Objects[Line - 2]).BaseLine +
           TDrawLineInfo(DrawLinesInfo.Objects[Line - 1]).MaxHeight
         else
           TDrawLineInfo(DrawLinesInfo.Objects[Line - 1]).BaseLine :=
           TDrawLineInfo(DrawLinesInfo.Objects[Line - 1]).MaxHeight;
         end;
       end;
       {MessageBox(0, Pchar(inttostr(DrawContainers.count)),
                   'DrawContainers.count', mb_ok);}
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
     //высота всего содержимого TChatView
     self.TextHeight := TDrawLineInfo(DrawLinesInfo.Objects[Line - 1]).BaseLine + d + 1;
     if TextHeight div VScrollStep > 30000 then
       self.VScrollStep := self.TextHeight div 30000;
     AdjustJumpsCoords;
     end
   else
     begin
     //если произошло изменение размеров (WM_SIZE)
//     AdjustChildrenCoords;
     //при горизонтальном растяжении окна меняем позицию горизонтальной прокрутки
     SetHPos(0);
     end;
   cw := ClientWidth;
   ch := ClientHeight;
   UpdateScrollBars(mx + FLeftMargin + FRightMargin, TextHeight);
   if (cw<>ClientWidth) or (ch<>ClientHeight) then
     begin
     //хз что это....
     skipformatting := False;
     ScrollTo(OldY);
     Format_(OnlyResized, depth + 1, Canvas, False);
//     MessageBox(0, PChar(inttostr(0)), 'cw<>ClientWidth', mb_ok);
     end;
   if OnlyResized then ScrollTo(OldY);
//   if OnlyTail then ScrollTo(TextHeight);
   if depth = 0 then RestoreSelBounds(StartNo, EndNo, StartOffs, EndOffs);
   skipformatting := False;
SetGifAniCanvas(canvas);   
end;
{------------------------------------------------------------------}
procedure TChatView.FormatNextContainer(var DrawLineInfo:TDrawLineInfo;
                                  var LineNum, ContNum, x, baseline, Ascent:Integer;
                                  var sourceStrPtr:PChar;
                                  var newline:boolean;
                                  Canvas: TCanvas; var sad: TScreenAndDevice);
{
// (x, baseline) - это левый нижний угол прямоугольника для вывода текста
//baseline  - координата Y начала вывода объекта форматирования (т.е. он будет
//            выводится над этой координатой)
//
//x         - координата Х начала вывода объекта форматирования
//Ascent  - междустрочный интервал (между галокой Й и базовой линией верхней строки)              (или от конца высоты объекта???)

+----------------------------
|  Пример    пример пример_____
|                            ^
|                            | Ascent (между строк)
|  Пример    пример пример_____Y это подчеркивание соответствует Y координате (baseline)
^            ^
|<---------->|
      x
//т.е. (x, prevdesc) - это правый нижний угол предыдущей строки
//после вывода новой строки нужно передать координаты нового угла
}
var {sourceStrPtr,} strForAdd, strSpacePos: PChar;
    sourceStrPtrLen, PrevBaseLine: Integer;
    CreateDrawLine: Boolean;
    sz: TSIZE;
    maxInAllCanvasWidth, max,j, y, ctrlw, ctrlh : Integer;
{$IFNDEF ChatViewDEF4}
    arr: array[0..1000] of integer;
{$ENDIF}
    str: array[0..1000] of char;
    info: TDrawContainerInfo;
    metr: TTextMetric;
    StyleNo: Integer;
    center:Boolean;
    cpinfo: TCPInfo;
    jmpinfo: TJumpInfo;
    n, width, y5, Offs : Integer;
    CanvasRect:TRect;
    s:string;
begin
  width := TextWidth;
  PrevBaseLine := 0;

  if NewLine = true then
    begin
    if DrawLinesInfo.Count > 0 then
      begin
      //если цикл форматирования уже прошел один раз
      PrevBaseLine := TDrawLineInfo(DrawLinesInfo.Objects[DrawLinesInfo.Count - 1]).BaseLine;
      DrawLineInfo := TDrawLineInfo.Create;
      DrawLineInfo.LineNumber := LineNum;
      DrawLineInfo.BaseLine := baseline;
      DrawLinesInfo.AddObject(inttostr(LineNum), DrawLineInfo);
      inc(LineNum);
      NewLine := true;
      CreateDrawLine := False;
      end
    else
      begin
      //DrawLineInfo создается впервые
      DrawLineInfo := TDrawLineInfo.Create;
      DrawLineInfo.LineNumber := LineNum;
      DrawLinesInfo.AddObject(inttostr(LineNum), DrawLineInfo);
      DrawLineInfo.BaseLine := baseline;
      inc(LineNum);
      PrevBaseLine := 0;
      NewLine := true;
      CreateDrawLine := False;
      end;
    end
  else
    begin
    //если продолжаем вывод в туже строку, то PrevBaseLine получить тоже надо
    if DrawLinesInfo.Count > 1 then
      PrevBaseLine := TDrawLineInfo(DrawLinesInfo.Objects[DrawLinesInfo.Count - 2]).BaseLine;
//    MessageBox(0, Pchar(inttostr(PrevBaseLine)), 'PrevBaseLine', mb_ok);
    end;
{    if DrawLinesInfo.Count > 0 then
      PrevBaseLine := TDrawLineInfo(DrawLinesInfo.Objects[DrawLinesInfo.Count - 1]).BaseLine;
    end;}

  case TContainerInfo(ContStorage.Objects[ContNum]).StyleNo of
   -8:  { GifAni}
     begin
       ctrlw       := TGifAni(TContainerInfo(ContStorage.Objects[ContNum]).gr).GifImage.Width;
       ctrlh       := TGifAni(TContainerInfo(ContStorage.Objects[ContNum]).gr).GifImage.Height;
       ctrlw       := MulDiv(ctrlw, sad.ppixDevice, sad.ppixScreen);
       ctrlh       := MulDiv(ctrlh, sad.ppiyDevice, sad.ppiyScreen);
       info        := TDrawContainerInfo.Create;
       info.Width  := ctrlw;

       info.Height := ctrlh + 1;
       info.LineNum     := @DrawLineInfo.LineNumber;
       info.pDrawLineInfo := DrawLineInfo;
       //проверяем выход смайлика на границv компонента (исправить на канвас???)

       if TContainerInfo(ContStorage.Objects[ContNum]).SameAsPrev = false then
         begin
         //с новой строки по определению
         inc(LineNum);
         x := sad.LeftMargin;//отступ
         baseline := PrevBaseLine + Ascent + info.Height;
         DrawLineInfo.BaseLine := baseline;
         DrawLineInfo.MaxHeight := info.Height;
//         info.LineNum := @DrawLineInfo.LineNumber;
         newline := false;
         end
       else
         begin
         if (x + info.Width > width) then
           begin
           //с новой строки, т.к. не влазит на эту
           x := sad.LeftMargin;//отступ
           PrevBaseLine := TDrawLineInfo(DrawLinesInfo.Objects[DrawLinesInfo.Count - 1]).BaseLine;
           DrawLineInfo := TDrawLineInfo.Create;
           DrawLineInfo.LineNumber := LineNum;
           DrawLineInfo.MaxHeight := info.Height;
           DrawLinesInfo.AddObject(inttostr(LineNum), DrawLineInfo);
           baseline := PrevBaseLine + Ascent + info.Height;
           DrawLineInfo.BaseLine := baseline;
{s := 'ContNum = ' + inttostr(ContNum) +
     '   info.Height = ' + inttostr(info.Height) +
     '   baseline = ' + inttostr(baseline);
Ondebug(s);}
           inc(LineNum);
           end
         else
           begin
           //продолжаем старую строку
           x := x + 1 + sad.LeftMargin;
           if DrawLineInfo.MaxHeight < info.Height then
             DrawLineInfo.MaxHeight := info.Height;
           end;
         end;
       info.Left   := x;
       info.Bottom := @DrawLineInfo.BaseLine;
       info.ContainerNumber := ContNum;
       info.pDrawLineInfo := DrawLineInfo;
       DrawContainers.AddObject('', info);
       TGifAni(TContainerInfo(ContStorage.Objects[ContNum]).gr).MirrorImagesY[TContainerInfo(ContStorage.Objects[ContNum]).imgNo] := info.Bottom^;
       TGifAni(TContainerInfo(ContStorage.Objects[ContNum]).gr).MirrorImagesX[TContainerInfo(ContStorage.Objects[ContNum]).imgNo] := x;

//FDebugText := 'Format MirrorImagesY[' + inttostr(TContainerInfo(ContStorage.Objects[ContNum]).imgNo) + '] = ' + inttostr(info.Bottom^);
//self.OnDebug(FDebugText);

       x := x + ctrlw + 1 - sad.LeftMargin;
     end;
   -6: { Bullet }
     begin
       ctrlw       := TImageList(TContainerInfo(ContStorage.Objects[ContNum]).gr).Width;
       ctrlh       := TImageList(TContainerInfo(ContStorage.Objects[ContNum]).gr).Height;
       ctrlw       := MulDiv(ctrlw, sad.ppixDevice, sad.ppixScreen);
       ctrlh       := MulDiv(ctrlh, sad.ppiyDevice, sad.ppiyScreen);
       info := TDrawContainerInfo.Create;
       info.Width  := ctrlw+1;
       info.Height := ctrlh+1;
       if TContainerInfo(ContStorage.Objects[ContNum]).SameAsPrev = false then
         begin
         //с новой строки по определению
         x := sad.LeftMargin;//отступ
         baseline := PrevBaseLine + Ascent + info.Height;
         DrawLineInfo.BaseLine := baseline;
         DrawLineInfo.MaxHeight := info.Height;
         info.LineNum := @DrawLineInfo.LineNumber;
         inc(LineNum);
         newline := false;
         end
       else
         begin
         if (x + info.Width > width) then
           begin
           //с новой строки, т.к. не влазит на эту
           x := sad.LeftMargin;//отступ
           PrevBaseLine := TDrawLineInfo(DrawLinesInfo.Objects[DrawLinesInfo.Count - 1]).BaseLine;
           DrawLineInfo := TDrawLineInfo.Create;
           DrawLineInfo.LineNumber := LineNum;
           DrawLineInfo.MaxHeight := info.Height;
           baseline := PrevBaseLine + Ascent + info.Height;
           DrawLineInfo.BaseLine := baseline;
           DrawLinesInfo.AddObject(inttostr(LineNum), DrawLineInfo);
           info.LineNum := @DrawLineInfo.LineNumber;
           inc(LineNum);
           end
         else
           begin
           //продолжаем старую строку
           x := x + 1 + sad.LeftMargin;
           info.LineNum := @DrawLineInfo.LineNumber;
           if DrawLineInfo.MaxHeight < info.Height then
             DrawLineInfo.MaxHeight := info.Height;
           end;
         end;

       info.Left := x;
       info.Bottom := @DrawLineInfo.BaseLine;
       info.ContainerNumber := ContNum;
       info.pDrawLineInfo := DrawLineInfo;
       DrawContainers.AddObject('',info);

       DrawLineInfo.LineNumber := LineNum;
       x := x + ctrlw + 1 - sad.LeftMargin;
     end;
   -5: { WinControl }
     begin
       ctrlw       := TWinControl(TContainerInfo(ContStorage.Objects[ContNum]).gr).Width;
       ctrlh       := TWinControl(TContainerInfo(ContStorage.Objects[ContNum]).gr).Height;
       ctrlw       := MulDiv(ctrlw, sad.ppixDevice, sad.ppixScreen);
       ctrlh       := MulDiv(ctrlh, sad.ppiyDevice, sad.ppiyScreen);
       info        := TDrawContainerInfo.Create;
       info.Width  := ctrlw;

       info.Height := ctrlh + 1;
       info.LineNum     := @DrawLineInfo.LineNumber;
       info.pDrawLineInfo := DrawLineInfo;
       //проверяем выход смайлика на границv компонента (исправить на канвас???)

       if TContainerInfo(ContStorage.Objects[ContNum]).SameAsPrev = false then
         begin
         //с новой строки по определению
         inc(LineNum);
         x := sad.LeftMargin;//отступ
         baseline := PrevBaseLine + Ascent + info.Height;
         DrawLineInfo.BaseLine := baseline;
         DrawLineInfo.MaxHeight := info.Height;
//         info.LineNum := @DrawLineInfo.LineNumber;
         newline := false;
         end
       else
         begin
         if (x + info.Width > width) then
           begin
           //с новой строки, т.к. не влазит на эту
           x := sad.LeftMargin;//отступ
           PrevBaseLine := TDrawLineInfo(DrawLinesInfo.Objects[DrawLinesInfo.Count - 1]).BaseLine;
           DrawLineInfo := TDrawLineInfo.Create;
           DrawLineInfo.LineNumber := LineNum;
           DrawLineInfo.MaxHeight := info.Height;
           DrawLinesInfo.AddObject(inttostr(LineNum), DrawLineInfo);
           baseline := PrevBaseLine + Ascent + info.Height;
           DrawLineInfo.BaseLine := baseline;
{s := 'ContNum = ' + inttostr(ContNum) +
     '   info.Height = ' + inttostr(info.Height) +
     '   baseline = ' + inttostr(baseline);
Ondebug(s);}
           inc(LineNum);
           end
         else
           begin
           //продолжаем старую строку
           x := x + 1 + sad.LeftMargin;
           if DrawLineInfo.MaxHeight < info.Height then
             DrawLineInfo.MaxHeight := info.Height;
           end;
         end;
       info.Left   := x;
       info.Bottom := @DrawLineInfo.BaseLine;
       info.ContainerNumber := ContNum;
       info.pDrawLineInfo := DrawLineInfo;
       DrawContainers.AddObject('', info);
       //если убрать, то почему-то иногда при ресайзе выводит ниже чем надо
       //некое отражение
       //TWinControl(TContainerInfo(ContStorage.Objects[ContNum]).gr).Top := info.Bottom^ - TWinControl(TContainerInfo(ContStorage.Objects[ContNum]).gr).Height;
       TWinControl(TContainerInfo(ContStorage.Objects[ContNum]).gr).Left := x;

s := {'TControl(TContainerInfo(ContStorage}'.Objects[' +
     inttostr(ContNum) +
//     ']).gr).Top =' + inttostr(info.Bottom^);
     ']).gr).Top =' + inttostr(TWinControl(TContainerInfo(ContStorage.Objects[ContNum]).gr).Top);
Ondebug(s, FDebugText2);

//FDebugText := 'Format MirrorImagesY[' + inttostr(TContainerInfo(ContStorage.Objects[ContNum]).imgNo) + '] = ' + inttostr(info.Bottom^);
//self.OnDebug(FDebugText);

{MessageBox(0, 'format: info.Bottom^ =',
              PChar(Inttostr(info.Bottom^) + ' ' + inttostr(ContNum)),
              mb_ok);}

       x := x + ctrlw + 1 - sad.LeftMargin;
     end;
   -4: { hotSpot }
     begin
       ctrlw       := TImageList(TContainerInfo(ContStorage.Objects[ContNum]).gr).Width;
       ctrlh       := TImageList(TContainerInfo(ContStorage.Objects[ContNum]).gr).Height;
       ctrlw       := MulDiv(ctrlw, sad.ppixDevice, sad.ppixScreen);
       ctrlh       := MulDiv(ctrlh, sad.ppiyDevice, sad.ppiyScreen);
       info := TDrawContainerInfo.Create;
       info.Width  := ctrlw+1;
       info.Height := ctrlh+1;
       jmpinfo     := TJumpInfo.Create;
       jmpinfo.l   := x+1+sad.LeftMargin;;
       jmpinfo.t   := y+1;
       jmpinfo.w   := ctrlw;
       jmpinfo.h   := ctrlh;
       jmpinfo.id  := nJmps;
       jmpinfo.idx := DrawContainers.Count;
       jumps.AddObject('',jmpinfo);
       inc(nJmps);

       if TContainerInfo(ContStorage.Objects[ContNum]).SameAsPrev = false or
           (info.Left > width) then
         begin
         //с новой строки по определению
         x := sad.LeftMargin;
         baseline := PrevBaseLine + Ascent + info.Height;
         DrawLineInfo.BaseLine := baseline;
         DrawLineInfo.MaxHeight := info.Height;
         info.LineNum := @DrawLineInfo.LineNumber;
         inc(LineNum);
         newline := false;
         end
       else
         begin
         if (x + info.Width > width) then
           begin
           //с новой строки, т.е. не влазит на эту
           x := sad.LeftMargin;//отступ
           PrevBaseLine := TDrawLineInfo(DrawLinesInfo.Objects[DrawLinesInfo.Count - 1]).BaseLine;
           DrawLineInfo := TDrawLineInfo.Create;
           DrawLineInfo.LineNumber := LineNum;
           DrawLineInfo.MaxHeight := info.Height;
           baseline := PrevBaseLine + Ascent + info.Height;
           DrawLineInfo.BaseLine := baseline;
           DrawLinesInfo.AddObject(inttostr(LineNum), DrawLineInfo);
           info.LineNum := @DrawLineInfo.LineNumber;

           s := 'x := ' + inttostr(x) +
                '  BaseLine := ' + inttostr(BaseLine) +
                '  LineNum := ' + inttostr(LineNum);

           inc(LineNum);
           end
         else
           begin
           //продолжаем старую строку
           x := x + 1 + sad.LeftMargin;
           info.LineNum := @DrawLineInfo.LineNumber;
           if DrawLineInfo.MaxHeight < info.Height then
             DrawLineInfo.MaxHeight := info.Height;
           end;
         end;

//       MessageBox(0, Pchar(inttostr(nJmps)), 'nJmps', mb_ok);

       info.Left := x;
       info.Bottom := @DrawLineInfo.BaseLine;
       info.ContainerNumber := ContNum;
       info.FromNewLine := not TContainerInfo(ContStorage.Objects[ContNum]).SameAsPrev;
       DrawContainers.AddObject('',info);
       x := x + ctrlw + 1 - sad.LeftMargin;
     end;
   -3:  { graphics}
     begin
     end;
   -2: { check point}
    begin
       {cpinfo   := TCPInfo.Create;
       cpinfo.Y := baseline + Ascent;
       cpinfo.LineNo := ContNum;
       checkpoints.AddObject(ContStorage[ContNum], cpinfo);}
    end;
   -1: { break line}
    begin
      y5                 := MulDiv(5, sad.ppiyDevice, sad.ppiyScreen);
      info               := TDrawContainerInfo.Create;
      info.Left          := sad.LeftMargin;
      info.Bottom         := @DrawLineInfo.BaseLine;
      info.ContainerNumber := ContNum;
      info.LineNum        := @DrawLineInfo.LineNumber;
      info.Width         := Width;
      info.Height        := y5 + y5 + 1;
      info.pDrawLineInfo := DrawLineInfo;
      DrawLineInfo.MaxHeight := info.Height;
      DrawLineInfo.MaxHeight := info.Height;

      DrawContainers.AddObject(ContStorage[ContNum], info);

      baseline := PrevBaseLine + Ascent + info.Height;
//      MessageBox(0, Pchar(inttostr(PrevBaseLine)), 'PrevBaseLine', mb_ok);
      DrawLineInfo.BaseLine := baseline;
      x := 0;
    end;
  else
    begin { text }
      //копируем строку текста, содержащуюся в контейнере
      //Например:
      //  ChatView ChatView ChatView ChatView
      //  ^
      //  |
      //  +- sourceStrPtr
      if sourceStrPtr = nil then
        begin
        sourceStrPtr := PChar(ContStorage.Strings[ContNum]);
        //в strForAdd указатель на буфер [0..1000]
        strForAdd := str;
        //узнаем длину текста
        sourceStrPtrLen := StrLen(sourceStrPtr);
        //узнаем стиль вывода текста
        end;

      StyleNo := TContainerInfo(ContStorage.Objects[ContNum]).StyleNo;
      //настраиваем канвас на нужный стиль, чтобы правильно получить
      //метрику шрифта
      with FStyle.TextStyles[StyleNo] do
        begin
        Canvas.Font.Style := Style;
        Canvas.Font.Size  := Size;
        Canvas.Font.Name  := FontName;
        Canvas.Font.CharSet  := CharSet;
        end;
      //получаем в metr структуру с физическими параметрами шрифта
      GetTextMetrics(Canvas.Handle, metr);
      //metr.tmExternalLeading - междустрочное расстояние (отступ
      //выше галочки над Й)
      //metr.tmAscent - подъем (высота символа вместе с галочкой над Й,
      //но без подстрочного окончания вертикальной р)
      //флаг: этот контейнер выводить в туже строку что и предыдущий
      //флаг: по центру
      Center := TContainerInfo(ContStorage.Objects[ContNum]).Center;

      while sourceStrPtr <> nil do
        //В этом цикле прокручивается разбиение одной длинной строки, на строки,
        //которые поместятся в канвас. Для каждой разбитой строки, будет создан
        //контейнер отображения TDrawContainerInfo. Эти контейнеры содержат
        //инфу и форматировании вывода каждого объекта + у каждого объекта
        //не будет TOP координаты, а будет ссылка на объект DrawLineInfo
        //который и будет содержать TOP координату. Т.е. несколько TDrawContainerInfo
        //которые находятся на одной строке ссылаются на один TDrawLineInfo
        //врезультате достаточно поменять TOP только у одного TDrawLineInfo
        //и он изменится у всей строки.
        begin
        //если контейнер содержит текст
        //если установлен признак новой строки
        if newline = true then
          begin
          if CreateDrawLine = true then
            begin
            //вот в чем проблема: для объектов типа BreakLine и картинки
            //DrawLineInfo уже должен быть создан, а Text сам может и должен
            //создавать этот объект при переносе слов на другую строку
            //можно конечно сделать проверку в конструкторе...

            //устанавливаем базовую линию по максимально высокому объекту
            if LineNum > 1 then
              TDrawLineInfo(DrawLinesInfo.Objects[LineNum - 1]).BaseLine :=
              TDrawLineInfo(DrawLinesInfo.Objects[LineNum - 2]).BaseLine +
              TDrawLineInfo(DrawLinesInfo.Objects[LineNum - 1]).MaxHeight
            else
              TDrawLineInfo(DrawLinesInfo.Objects[LineNum - 1]).BaseLine :=
              TDrawLineInfo(DrawLinesInfo.Objects[LineNum - 1]).MaxHeight;

            if DrawLinesInfo.Count > 0 then
              PrevBaseLine := TDrawLineInfo(DrawLinesInfo.Objects[DrawLinesInfo.Count - 1]).BaseLine
            else
              PrevBaseLine := 0;
            DrawLineInfo := TDrawLineInfo.Create;
            DrawLineInfo.LineNumber := LineNum;
            DrawLinesInfo.AddObject(inttostr(LineNum), DrawLineInfo);
            inc(LineNum);
            end;
          //если начинаем вывод с новой строки, то сбрасываем Х координату в 0
          x := 0;
          //увеличиваем базовую линию
          //ВНИМАНИЕ !!! ЕЕ НУЖНО БРАТЬ ОТ TOP ПРЕДЫДУЩЕГО ОБЪЕКТА-ЛИНИИ!!!!
          //обнуляем флаг
          newline := false;
//          MessageBox(0, PChar(inttostr(DrawLineInfo.LineNumber) + '  ' + inttostr(baseline)),
//                    'DrawLineInfo.LineNumber   baseline', mb_ok);
          end;

        if x > Width then x := Width;
        GetTextExtentExPoint(Canvas.Handle,  sourceStrPtr,
                             sourceStrPtrLen, Width - x,
                             @max, nil,//в D5 срабатывает эта строка
                             sz);
        //ф-ция возвращает в max количество символов, помещающихся до конца канваса


        //копируем это количество символов в strForAdd
        StrLCopy(strForAdd, sourceStrPtr, max);

        if max < sourceStrPtrLen then
        //если max меньше, чем длина текста (т.е. текст НЕ ПОМЕЩАЕТСЯ до конца канваса)
          begin
          //пробуем получить в этом куске указатель на ПОСЛЕДНИЙ пробел
          //а точнее на любой из символов разделителей
          //сначала ищем с разделителях, которые остаются на верхней строке
          //например ':'
          for n := 1 to Length(FDelimiters) do
            begin
            strSpacePos := StrRScan(strForAdd, FDelimiters[n]);
            if strSpacePos <> nil then break;
            end;
          //если не нашли, то ищем среди слепленных разделителей
          //например '{' она должна переноситься в начале слова на др строку 
          if strSpacePos = nil then
          for n := 1 to Length(FMergeDelimiters) do
            begin
            strSpacePos := StrRScan(strForAdd, FMergeDelimiters[n]);
            if strSpacePos <> nil then
              begin
              if strSpacePos <> Pchar(strForAdd) then Dec(strSpacePos);
              break;
              end;
            end;
          if strSpacePos <> nil then
            begin
            //нашли, получаем хвостовик ЗА ПРОБЕЛОМ (это начало последнего слова
            //которое не влезло на эту строку, начиная с этого слова нужно выводить
            //уже строкой ниже) Например, имеем строку, на кот. указ. sourceStrPtr:
            //  ChatView ChatView ChatView ChatView
            //  ^
            //  |
            //  +- sourceStrPtr

            // +---------------------+  <--- область канваса
            // |                     |
            // |ChatView ChatView ChatView ChatView
            // |                     |
            // последнии слова не помещаются в канвас

            //  ChatView ChatView Cha
            //  ^                ^
            //  |                |
            //  +- strForAdd     +- strSpacePos

            //т.е. нам нужно вычесть кусочек ' Cha' это делается интересным образом
            //  strForAdd =  'ChatView ChatView Cha'
            //  strSpacePos =                 ' Cha'
            max := strSpacePos - strForAdd;
            //в strForAdd копируем только те слова, которые влезают целиком
            inc(max);
            StrLCopy(strForAdd, sourceStrPtr, max);
            sourceStrPtr := @(sourceStrPtr[max]);
            sourceStrPtrLen := StrLen(sourceStrPtr);

            newline := true;
            CreateDrawLine := true;
            end
          else
            begin
            //сюда попадаем, если в том куске, который помещается в канвас
            //(мы скопировали, его из изначальной строки)
            //НЕ НАЙДЕН НИ ОДИН ПРОБЕЛ!
            //т.е. у нас очень длинная строка без пробелов. Например:
            // ChatViewChatViewChatViewChatViewChatViewChatViewChatViewChatView
            // +---------------------+  <--- область канваса
            // |                     |
            // |ChatViewChatViewChatView  <-- переносим по буквам
            // |                     |
            // последнии слова не помещаются в канвас, но и пробела для переноса нет
            // ^^^^^^^^^^^^^^^^^ - это если нет объектов!!!

            //когда форматировали только текст, без объектов, был только один вариант
            //при котором слово не помещалос полностью в строку:
            //слово начинается от левого края канваса и без пробелов продолжается
            //до правого края канваса. Его было не разделить, т.к. в нем нет
            //символов разделителей. НО! После того как появились объекты
            //слово смогло начинаться сразу за объектом, например в центре канваса
            //и считать что это слово нельзя перенести целеком на нижнюю строку нельзя,
            //т.к. ее отодвинул на пол канваса от левого края объект
            // +----------------------+  <--- область канваса
            // |           __         |
            // | Chat LOL |__| ChatViewChat <-- ее вполне можно перести целеком
            // |                      |         а не по буквам.

            if x > 0 then max := 0;
            //эта строка очень важна! Если x = 0 то это
            //значит, что мы пытались поместить кусок строки не с середины канваса
            //а с самого начала, при этом в ней не нашлось пробела!
            //именно в этом случае строку нужно делить по буквам. Ну а если x > 0
            //то у нас еще был отступ от начала канваса и слово поместить в этом
            //отступе на новой строке!

            StrLCopy(strForAdd, sourceStrPtr, max);
            sourceStrPtr := @(sourceStrPtr[max]);
            sourceStrPtrLen := StrLen(sourceStrPtr);

            //тогда принудительно переводим строку
            newline := true;
            CreateDrawLine := true;
            end;
          end
        else
          begin
          //весь текст ПОМЕЩАЕТСЯ до конца канваса
          sourceStrPtr := nil;
          {s := '' + inttostr(0);
          Ondebug(s);}
          end;
        //тут мы выводим то, что поместилось на этой строчке
        //все что не поместилось, выводится при следующем вызове FormatNextContainer
        //и соответственно создается свой контейнер
        info := TDrawContainerInfo.Create;
        info.ContainerNumber := ContNum;
        info.LineNum := @DrawLineInfo.LineNumber;

        baseline := PrevBaseLine + Ascent + metr.tmHeight;
        //если была команда AddCenterLine('')
        if Center then
          begin
          x := (Width - sz.cx) div 2;
          if x < 0 then x := 0;
          end;

        if (StyleNo = cvsJump1) or (StyleNo = cvsJump2) then
          begin
          jmpinfo := TJumpInfo.Create;
          jmpinfo.l := x + sad.LeftMargin;
          jmpinfo.t := baseline;
          jmpinfo.w := sz.cx;
          jmpinfo.h := sz.cy;
          jmpinfo.id := nJmps;
          jmpinfo.idx := DrawContainers.Count - 1;
          TContainerInfo(ContStorage.Objects[ContNum]).imgNo := nJmps;
          jumps.AddObject('', jmpinfo);
          inc(nJmps);
          end;


{MessageBox(0, PChar(inttostr(Ascent) + '   ' +
           inttostr(metr.tmHeight)
           ), 'Ascent и metr.tmHeight', mb_ok);}
//MessageBox(0, PChar(inttostr(BaseLine)), 'BaseLine', mb_ok);
        DrawLineInfo.BaseLine := BaseLine;

{s := 'ContNum = ' + inttostr(ContNum) +
     '   info.Height = ' + inttostr(info.Height) +
     '   baseline = ' + inttostr(baseline);
Ondebug(s);}

        info.Left   := x + sad.LeftMargin;
        info.Bottom    := @DrawLineInfo.BaseLine;
        info.Width  := canvas.TextWidth(strForAdd);//было неправильно sz.cx;
        info.Height := sz.cy;
        info.pDrawLineInfo := DrawLineInfo;
        DrawContainers.AddObject(strForAdd, info);
        if DrawLineInfo.MaxHeight < info.Height then
          DrawLineInfo.MaxHeight := info.Height;

        x := x + sz.cx + 1;


{         if not newline then
           //продолжаем старую строку
           begin //continue line
           if prevabove < metr.tmExternalLeading + metr.tmAscent then
             begin
             j := DrawContainers.Count-1;
             if j>=0 then
               repeat
                 inc(TDrawContainerInfo(DrawContainers.Objects[j]).Top,
                     metr.tmExternalLeading+metr.tmAscent - prevabove);
                 dec(j);
               until  TDrawContainerInfo(DrawContainers.Objects[j+1]).FromNewLine;
             inc(baseline,metr.tmExternalLeading+metr.tmAscent-prevabove);
             prevabove := metr.tmExternalLeading+metr.tmAscent;

         MessageBox(0, PChar('if j>=0 then '),
                         PChar('  TDrawContainerInfo(DrawContainers.Objects[j+1]) = ' + inttostr(j+1)
                          ) , mb_ok);

             end;
           y := baseline - metr.tmAscent;
           info.FromNewLine := False;
           end
         else
           begin // new line
           info.FromNewLine := True;
           if Center then
             x := (Width - sz.cx) div 2
           else
             x :=0;
           y := baseline + prevDesc + metr.tmExternalLeading;
           inc(baseline, prevDesc + metr.tmExternalLeading + metr.tmAscent);
           prevabove := metr.tmExternalLeading+metr.tmAscent;
           end;
         info.Left   :=x+sad.LeftMargin;;
         info.Top    := y;
         info.Width  := sz.cx;
         info.Height := sz.cy;
         DrawContainers.AddObject(strForAdd, info);

{         MessageBox(0, PChar('создали Object =' + inttostr(DrawContainers.Count) +
                      '  string=' + strForAdd),
                         PChar(
                      '  LineNum = ' + inttostr(LineNum)
                          ) , mb_ok);
}
{         if (StyleNo=cvsJump1) or (StyleNo=cvsJump2) then
           begin
           jmpinfo := TJumpInfo.Create;
           jmpinfo.l := x+sad.LeftMargin;
           jmpinfo.t := y;
           jmpinfo.w := sz.cx;
           jmpinfo.h := sz.cy;
           jmpinfo.id := nJmps;
           jmpinfo.idx := DrawContainers.Count-1;
           TContainerInfo(ContStorage.Objects[ContNum]).imgNo := nJmps;
           jumps.AddObject('',jmpinfo);
           end;
         sourceStrPtrLen := StrLen(sourceStrPtr);
         if newline or (prevDesc < metr.tmDescent) then prevDesc := metr.tmDescent;
         inc(x,sz.cx);
         newline := True;}
        end;
{       if (StyleNo=cvsJump1) or (StyleNo=cvsJump2) then inc(nJmps);}
    end;
  end;//caseend
end;

  {------------------------------------------------------------------}
{$I CV_Save.inc}
  {------------------------------------------------------------------}

end.

