unit CVLiteGifAni;
//краткое описание:
//Этот модуль позваляет создать объект GifAni. Для того чтобы не создавать
//несколько объектов для одинаковых смайликов сделано следующее:
//Добавляемое изображение хранится в свойстве FGifImage
//а координаты куда его нужно выводить в массиве MirrorImagesX[n] и MirrorImagesY[n]
//т.е. если нужно отрисовать много одинаковых смайликов, создается 1н объект
//TGifAni и при помощи метода AddMirrorImages добавляются дубликаты.
//От дубликатов хранятся только координаты вывода. ВСЕ! при выводе мы берем
//1 объект TGifAni и сканируем массив с координатами дубликатов. Сколько там
//координат столько дубликатов по ним и рисуем.

//Теперь что касается TChatView. У него при добавлении каждый дубликат
//становится объектом отрисовки. Поэтому при выполнении FORMAT_ необходимо
//добраться до координат дубликата. Это можно сделать только зная порядковый номер
//дубликата в массиве (MirrorImagesX[n] тобишь n). Этот номер приходиться сохранять
//в info.imgNo := imgNo; в процедуре добавления. А в программе пользователя
//соответственно необходимо этот номер передавать. Если передать неправильно,
//то в лучшем случае перепишем один дубликат другим, в худшем расширим массив
//и все упадет.
interface
uses windows, classes, Graphics, VCLUtils, ExtCtrls, sysutils, litegif1;

const
 dmUndefined = 0;//Метод размещения не указан. Декодер не должен выполнять никаких специальных действий.
 dmDoNothing = 1;//Метод не указан. Изображение должно оставаться на месте.
 dmToBackground = 2;//Восстановить до фонового цвета - в область, занятую изображением, должен быть возвращен фоновый цвет.
 dmToPrevious = 3;//Восстановить предыдущее. Декодировщик должен восстановить картинку, которая была до вывода на экран данного изображения.
{dtUndefined,   {Take no action}
{dmDoNothing,   {Leave graphic, next frame goes on top of it}
{dtToBackground,{restore original background for next frame}
{dtToPrevious); {restore image as it existed before this frame}

type
  TDebugEvent = procedure (Mess: String) of object;
type
  TGifAni = class (TPersistent)
  private
    AnimateMayBeRuning          : boolean;
    FrameIndex                  : Integer;
    FBackGroundColor            : TColor;
    FDestCanvas                 : TCanvas;
    FGifCache                   : TBitmap;
    FVirtualCanvas              : TBitmap;
    FGifImage			: TGif;
    FTimer                      : TTimer;
    FOnDebug                    : TDebugEvent;
    FDebugText                  :string;

    FCacheIndex: Integer;
    FCache: TBitmap;
    FTransColor: TColor;
    procedure DoPaintImageOnVirtualCanvas(SourceGifImage:TGif;OutX,OutY:integer;
                                          BackGroundColor:TColor);
    procedure GetFrameBitmap(FImage:TGIF;DestCanvas:TCanvas;Index: Integer;
                             var TransColor: TColor);
  protected
  public
    MirrorImagesX                :array of integer;//max 32767
    MirrorImagesY                :array of integer;//max 32767
    ShowingAnimation             :array of boolean;//max 32767
    property    DestCanvas       :TCanvas read FDestCanvas write FDestCanvas;
    property    Timer	        	:TTimer read FTimer write FTimer;
    property    BackGroundColor		:TColor read FBackGroundColor write FBackGroundColor;
    property    GifImage	 		:TGIF read FGifImage write FGifImage;
//    property    GifX	 		        :Integer read FGifX write FGifX;
//    property    GifY	 		        :Integer read FGifY write FGifY;
    property    OnDebug: TDebugEvent read FOnDebug write FOnDebug;
    procedure   DrawFrame(MirrorNumber:Word; xshift, yshift:integer);
    procedure   Assign(Source: TPersistent);override;{virtual;}
    procedure   Animate(Sender: TObject);
    procedure   AddMirrorImages({x, y:Integer});
    PROCEDURE   DelAllMirrorImages({x, y:Integer});
    procedure   BeginAnimate(DestionationCanvas:TCanvas; BackGroundColor:TColor);
    constructor Create(FileName:String); {override;}
//    constructor CreateCopy(GifImage:TGIF);
    destructor  Destroy; override;
  published
  end;

  PGifAni = ^TGifAni;

implementation

{-------------------------------------}
constructor TGifAni.Create(FileName:String);
var MS: TMemoryStream;
begin
  inherited Create();
  FOnDebug := nil;
  AnimateMayBeRuning := false;
  FGifImage := TGif.Create;

  MS := TMemoryStream.Create;
  try
    MS.LoadFromFile(FileName);
    FGIFImage.LoadFromStream(ms);
  finally
    MS.Free;
  end;
  FTimer := TTimer.Create(nil);
  FrameIndex := 0;
  FVirtualCanvas := TBitMap.Create;
  FVirtualCanvas.Width := FGifImage.Width;
  FVirtualCanvas.Height := FGifImage.Height;
end;
{-------------------------------------}
{constructor TGifAni.CreateCopy(GifImage:TGIF);
begin
  inherited Create();
  FOnDebug := nil;
  AnimateMayBeRuning := false;
  FGifImage := TGIF.Create;
  FGifImage.Assign(GifImage);
  FTimer := TTimer.Create(nil);
  FrameIndex := 0;
  FVirtualCanvas := TBitMap.Create;
  FVirtualCanvas.Width := FGifImage.ScreenWidth;
  FVirtualCanvas.Height := FGifImage.ScreenHeight;
end;
{-------------------------------------}
destructor TGifAni.Destroy;
begin
  DelAllMirrorImages();
  FTimer.free;
  FGifImage.Free;
  FVirtualCanvas.Free;
  inherited Destroy;
end;
{-------------------------------------}
procedure TGifAni.Assign(Source: TPersistent);
begin
  if Source is TGifAni then
    begin
    end
  else
    inherited Assign(Source);
end;
{-------------------------------------}
procedure TGifAni.GetFrameBitmap(FImage:TGIF;DestCanvas:TCanvas;Index: Integer;
                                 var TransColor: TColor);
var
  I, Last, First: Integer;
  UseCache: Boolean;
begin
  if Index > FImage.ImageCount - 1 then index := FImage.ImageCount - 1;
  UseCache := (FCache <> nil) and (FCacheIndex = Index - 1) and (FCacheIndex >= 0) and
    (FImage.ImageDisposal[FCacheIndex] <> dmToPrevious);
  if UseCache then
    begin
    TransColor := FTransColor;
    end
  else
    begin
    FCache.Free;
    FCache := nil;
    end;
  Last := Index;
  first := Index;
//      if last < 0  then First := 0
//      else first := last;

  if not UseCache then
    begin
    DestCanvas.FillRect(Bounds(0, 0, FImage.Width, FImage.Height));
    while First > 0 do
      begin
      if (FImage.Width = FImage.ImageWidth[First]) and
        (FImage.Height = FImage.ImageHeight[First]) then
        begin
        if (FImage.TransparentIndex[First] = clNone) or
          ((FImage.ImageDisposal[First] = dmToBackground) and
          (First < Last)) then Break;
        end;
      Dec(First);
      end;
    for I := First to Last - 1 do
      begin
        case FImage.ImageDisposal[I] of
          dmUndefined, dmDoNothing:
            DestCanvas.Draw(FImage.ImageLeft[I], FImage.ImageTop[I], FImage.Bitmap[I]);
          dmToBackground:
            if I > First then
              DestCanvas.FillRect(Bounds(FImage.ImageLeft[I], FImage.ImageTop[I], FImage.ImageWidth[I], FImage.ImageHeight[I]));
          dmToPrevious:
            begin
            // do nothing
            end;
        end;
      end;
    end
  else
    begin
    if FImage.ImageDisposal[I] = dmToBackground then
      DestCanvas.FillRect(Bounds(FImage.ImageLeft[I], FImage.ImageTop[I], FImage.ImageWidth[I], FImage.ImageHeight[I]));
    end; // UseCache
DestCanvas.Draw(FImage.ImageLeft[I], FImage.ImageTop[I], FImage.Bitmap[Last]);
FCacheIndex := Index;
FTransColor := TransColor;
end;



procedure TGifAni.DoPaintImageOnVirtualCanvas(SourceGifImage:TGif;OutX,OutY:Integer;BackGroundColor:TColor);
begin
{ copy image from parent and back-level controls }
if (SourceGifImage.Width > 0) and
  (SourceGifImage.Height> 0) then
  begin
  GetFrameBitmap(SourceGifImage, FVirtualCanvas.Canvas, FrameIndex, BackGroundColor);
  end;
end;

procedure TGifAni.Animate(Sender: TObject);
var i:integer;
BEGIN
if FGifImage.ImageCount > 1 then
  begin
  inc(FrameIndex);
  if FrameIndex > FGifImage.ImageCount - 1 then
    FrameIndex := 0;
  end;
//в данном случае рисуем на виртуале подлинник      [0]               [0]
DoPaintImageOnVirtualCanvas(FGifImage, MirrorImagesX[0], MirrorImagesY[0], Self.BackGroundColor);
for i := 0 to length(MirrorImagesX) - 1 do
  begin
  if ShowingAnimation[i] = true then DrawFrame(i, 0, MirrorImagesY[i]);
  end;

if FGifImage.ImageCount > 1 then
  begin
  if FGifImage.ImageDelay[FrameIndex] = 0 then
    Animate(Self)
  else
    FTimer.Interval := FGifImage.ImageDelay[FrameIndex]*10;
  end;
END;

procedure TGifAni.DrawFrame(MirrorNumber:Word; xshift, yshift:integer);
BEGIN
//DoPaintImageOnVirtualCanvas(FGifImage, MirrorImagesX[0], MirrorImagesY[0], Self.BackGroundColor);
{for n := 0 to length(MirrorImagesX) - 1 do
  begin
  FDestCanvas.Draw(MirrorImagesX[n], MirrorImagesY[n], FVirtualCanvas);
  end;}
//FDebugText := inttostr(MirrorImagesY[MirrorNumber]);
//Self.OnDebug(FDebugText);
//FDestCanvas.Draw(MirrorImagesX[MirrorNumber] - xshift, MirrorImagesY[MirrorNumber], FVirtualCanvas);
FDestCanvas.Draw(MirrorImagesX[MirrorNumber] - xshift, yshift, FVirtualCanvas);
end;

procedure TGifAni.BeginAnimate(DestionationCanvas:TCanvas; BackGroundColor:TColor);
BEGIN
if AnimateMayBeRuning = true then
  begin
  FTimer.OnTimer := Animate;
  Self.DestCanvas := DestionationCanvas;
  Self.FBackGroundColor := BackGroundColor;
  self.Animate(self);
  end;
END;

PROCEDURE TGifAni.AddMirrorImages({x, y:Integer});
VAR i:integer;
BEGIN
AnimateMayBeRuning := true;
i := length(self.MirrorImagesX);//n = 1 , а элементов 1
SetLength(self.MirrorImagesX, i + 1);//n = 1, а элементов 2
SetLength(self.MirrorImagesY, i + 1);
SetLength(self.ShowingAnimation, i + 1);
self.MirrorImagesX[i] := -1000;//n т.к. 2 элемент имеет 1 индекс
self.MirrorImagesY[i] := 0;
self.ShowingAnimation[i] := false;
END;

PROCEDURE TGifAni.DelAllMirrorImages({x, y:Integer});
VAR i:integer;
BEGIN
AnimateMayBeRuning := false;
FTimer.Interval := 0;
{for i := 0 to length(self.ShowingAnimation) - 1 do
  begin
//  MessageBox(0, PChar(inttostr(i)), PChar('i =' + inttostr(length(self.ShowingAnimation) - 1)), mb_ok);
  self.ShowingAnimation[i] := false;
  end;}
SetLength(self.MirrorImagesX, 0);//n = 1, а элементов 2
SetLength(self.MirrorImagesY, 0);
SetLength(self.ShowingAnimation, 0);
END;
end.
