unit CVLiteGifAniX2;//версии 2 !!!!!!!!
//краткое описание:
//Этот модуль позволяет создать объект GifAni. Для того чтобы не создавать
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
uses windows, classes, Graphics, VCLUtils, ExtCtrls, sysutils,
     litegifx2{, UStartForm};

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
  TDebugEvent = procedure (Mess, Mess2: String) of object;
type
  TGifAni = class (TPersistent)
  private
    AnimateMayBeRuning          : boolean;
    FBackGroundColor            : TColor;
    FDestCanvas                 : TCanvas;
    FGifCache                   : TBitmap;
//    FVirtualCanvas              : TBitmap;
    FGifImage			: TGif;
    FTimer                      : TTimer;
    FOnDebug                    : TDebugEvent;
    FDebugText                  :string;

    FCacheIndex: Integer;
    FCache: TBitmap;
    FTransColor: TColor;
  protected
  public
    FrameIndex                  : Integer;
    MirrorImagesX                :array of integer;//max 32767
    MirrorImagesY                :array of integer;//max 32767
    ShowingAnimation             :array of boolean;//max 32767
    property    DestCanvas       :TCanvas read FDestCanvas write FDestCanvas;
    property    Timer	        	:TTimer read FTimer write FTimer;
    property    BackGroundColor		:TColor read FBackGroundColor write FBackGroundColor;
    property    GifImage	 		:TGIF read FGifImage write FGifImage;
//    property    OnDebug: TDebugEvent read FOnDebug write FOnDebug;
    procedure   GetFrameBitmap(DestCanvas:TCanvas;Index: Integer;
                               TransColor: TColor);
//    procedure   DrawFrame(MirrorNumber:Word; xshift, yshift:integer);
    procedure   DrawFrame(MirrorNumber:Word);
    procedure   Assign(Source: TPersistent);override;{virtual;}
    procedure   Animate(Sender: TObject);
    procedure   AddMirrorImages({x, y:Integer});
    PROCEDURE   DelAllMirrorImages({x, y:Integer});
    procedure   BeginAnimate(DestionationCanvas:TCanvas; BackGroundColor:TColor);
//    constructor Create(MS: TMemoryStream; FileName:String);
    constructor Create(GifImage:TGif);
    destructor  Destroy; override;
  published
  end;

  PGifAni = ^TGifAni;

implementation

{-------------------------------------}
//constructor Create(MS: TMemoryStream; FileName:String);
constructor TGifAni.Create(GifImage:TGif);
var n: integer;
    TempBitmap: TBitmap;
    TempBitmaps: array of TBitmap;
begin
inherited Create();
FOnDebug := nil;
AnimateMayBeRuning := false;
FGifImage := GifImage;

FTimer := TTimer.Create(nil);
FrameIndex := 0;

if FGifImage.FramesOverBitmaps = false then
  begin
  //а делаем следующее:
  //зачем декодировать фреймы в RunTime? Мы их декодируем прямо сейчас и заменим
  //ими те BitMap что были!
  TempBitmap := TBitmap.Create;
  TempBitmap.Width := FGifImage.Width;
  TempBitmap.Height := FGifImage.Height;
  setlength(TempBitmaps, FGifImage.ImageCount);
//  StartForm.SetMax(FGifImage.ImageCount);

  for n := 0 to length(TempBitmaps) - 1 do
    begin
    TempBitmaps[n] := TBitmap.Create;
    GetFrameBitmap(TempBitmap.Canvas, n, clWhite);
    TempBitmaps[n].Assign(TempBitmap);
//    StartForm.LoadingProgress(n);
    end;
  TempBitmap.free;

  for n := 0 to length(TempBitmaps) - 1 do
    begin
    FGifImage.SetBitmap(n, TempBitmaps[n]);
    TempBitmaps[n].free;
    end;
  //очень важно!!!! без этой строчки будут глюки!!!
  //т.к. у нас из разных ChatView при добавлении идут ссылки на один и тот же Gif
  //то нельзя 2й раз вызывать замену FGifImage.BitMap[] на декодированные фреймы!!!
  //т.к. второй раз мы уже попытаемся декодировать декодированное... и получим глюк
  FGifImage.FramesOverBitmaps := true;
  setlength(TempBitmaps, 0);
  end;
end;
{-------------------------------------}
destructor TGifAni.Destroy;
begin
  DelAllMirrorImages();
  FTimer.free;
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
procedure TGifAni.GetFrameBitmap(DestCanvas:TCanvas;Index: Integer;
                                 TransColor: TColor);
var
  I, Last, First: Integer;
  UseCache: Boolean;
begin
  if Index > FGifImage.ImageCount - 1 then index := FGifImage.ImageCount - 1;
  UseCache := (FCache <> nil) and (FCacheIndex = Index - 1) and (FCacheIndex >= 0) and
    (FGifImage.ImageDisposal[FCacheIndex] <> dmToPrevious);
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
    DestCanvas.FillRect(Bounds(0, 0, FGifImage.Width, FGifImage.Height));
    while First > 0 do
      begin
      if (FGifImage.Width = FGifImage.ImageWidth[First]) and
        (FGifImage.Height = FGifImage.ImageHeight[First]) then
        begin
        if (FGifImage.TransparentIndex[First] = clNone) or
          ((FGifImage.ImageDisposal[First] = dmToBackground) and
          (First < Last)) then Break;
        end;
      Dec(First);
      end;
    for I := First to Last - 1 do
      begin
        case FGifImage.ImageDisposal[I] of
          dmUndefined, dmDoNothing:
            DestCanvas.Draw(FGifImage.ImageLeft[I], FGifImage.ImageTop[I], FGifImage.Bitmap[I]);
//            DestCanvas.Draw(0, 0, FGifImage.Bitmap[I]);
          dmToBackground:
            if I > First then
              DestCanvas.FillRect(Bounds(FGifImage.ImageLeft[I], FGifImage.ImageTop[I], FGifImage.ImageWidth[I], FGifImage.ImageHeight[I]));
          dmToPrevious:
            begin
            // do nothing
            end;
        end;
      end;
    end
  else
    begin
    if FGifImage.ImageDisposal[I] = dmToBackground then
      DestCanvas.FillRect(Bounds(FGifImage.ImageLeft[I], FGifImage.ImageTop[I], FGifImage.ImageWidth[I], FGifImage.ImageHeight[I]));
    end; // UseCache
DestCanvas.Draw(FGifImage.ImageLeft[I], FGifImage.ImageTop[I], FGifImage.Bitmap[Last]);
//DestCanvas.Draw(0, 0, FGifImage.Bitmap[Last]);
FCacheIndex := Index;
FTransColor := TransColor;
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
for i := 0 to length(MirrorImagesX) - 1 do
  begin
//  if ShowingAnimation[i] = true then DrawFrame(i, 0, MirrorImagesY[i]);
  if ShowingAnimation[i] = true then DrawFrame(i);
  end;

if FGifImage.ImageCount > 1 then
  begin
  if FGifImage.ImageDelay[FrameIndex] < 10 then
//    Animate(Self)
    FTimer.Interval := 50
  else
    FTimer.Interval := FGifImage.ImageDelay[FrameIndex]*10;
  end;
END;

{
для версии ChatView 0.44
procedure TGifAni.DrawFrame(MirrorNumber:Word; xshift, yshift:integer);
BEGIN
FDestCanvas.Draw(MirrorImagesX[MirrorNumber], yshift, FGifImage.Bitmap[FrameIndex]);
end;}

procedure TGifAni.DrawFrame(MirrorNumber:Word);
BEGIN
FDestCanvas.Draw(MirrorImagesX[MirrorNumber], MirrorImagesY[MirrorNumber], FGifImage.Bitmap[FrameIndex]);
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
