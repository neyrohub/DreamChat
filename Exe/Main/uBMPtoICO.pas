unit uBMPtoICO;

interface

uses
  Windows, Graphics, litegifX2;

function BMPToICO(SourceBMP: TBitMap): TIcon;forward;
function GIFToICO(SourceGIF: TGif; FrameNumber: integer): TIcon;forward;

implementation

//Нужно создать два bitmap'а: bitmap-маску ("AND" bitmap) и
//bitmap-картинку (XOR bitmap). Потом передать дескрипторы "AND" и "XOR"
//bitmap-ов API функции CreateIconIndirect():

function BMPToICO(SourceBMP: TBitMap): TIcon;
var
  IconSizeX: integer;
  IconSizeY: integer;
  AndMask: TBitmap;
  XOrMask: TBitmap;
  IconInfo: TIconInfo;
  //Icon: TIcon;
begin
  {Get the icon size}
  IconSizeX := GetSystemMetrics(SM_CXICON);
  IconSizeY := GetSystemMetrics(SM_CYICON);
  {Create the "And" mask}
  AndMask := TBitmap.Create;
  AndMask.Monochrome := true;
  AndMask.Width := IconSizeX;
  AndMask.Height := IconSizeY;
  {Draw on the "And" mask}
//  AndMask.Canvas.Brush.Color := clWhite;
//  AndMask.Canvas.Brush.Color := SourceBMP.TransparentColor;
//  AndMask.TransparentColor := SourceBMP.TransparentColor;

//  AndMask.Canvas.FillRect(Rect(0, 0, IconSizeX, IconSizeY));
//  AndMask.Canvas.Brush.Color := clBlack;
//  AndMask.Canvas.Ellipse(4, 4, IconSizeX - 4, IconSizeY - 4);
  AndMask.Assign(SourceBMP);
  {Draw as a test}
//  Form1.Canvas.Draw(IconSizeX * 2, IconSizeY, AndMask);
  {Create the "XOr" mask}
  XOrMask := TBitmap.Create;
  XOrMask.Width := IconSizeX;
  XOrMask.Height := IconSizeY;
  {Draw on the "XOr" mask}
  XOrMask.Canvas.Brush.Color := ClBlack;
//  XOrMask.Canvas.Brush.Color := SourceBMP.TransparentColor;
//  XOrMask.TransparentColor := SourceBMP.TransparentColor;

//  XOrMask.Canvas.FillRect(Rect(0, 0, IconSizeX, IconSizeY));
//  XOrMask.Canvas.Pen.Color := clRed;
//  XOrMask.Canvas.Brush.Color := clRed;
//  XOrMask.Canvas.Ellipse(4, 4, IconSizeX - 4, IconSizeY - 4);
  XOrMask.Assign(SourceBMP);
  {Draw as a test}
//  Form1.Canvas.Draw(IconSizeX * 4, IconSizeY, XOrMask);
  {Create a icon}
  Result := TIcon.Create;
  IconInfo.fIcon := true;
  IconInfo.xHotspot := 0;
  IconInfo.yHotspot := 0;
  IconInfo.hbmMask := AndMask.Handle;
  IconInfo.hbmColor := XOrMask.Handle;
  Result.Handle := CreateIconIndirect(IconInfo);
  {Destroy the temporary bitmaps}
  AndMask.Free;
  XOrMask.Free;
  {Draw as a test}
  //Form1.Canvas.Draw(IconSizeX * 6, IconSizeY, Icon);
  {Assign the application icon}
  //Application.Icon := Icon;
  {Force a repaint}
  //InvalidateRect(Application.Handle, nil, true);
  {Free the icon}
//  Result := Icon;
end;

function GIFToICO(SourceGIF: TGif; FrameNumber: integer): TIcon;
var
  IconSizeX: integer;
  IconSizeY: integer;
  AndMask: TBitmap;
  XOrMask: TBitmap;
  IconInfo: TIconInfo;
  Mask: TBitmap;
  TempB: TBitmap;
begin
  {Get the icon size}
  IconSizeX := GetSystemMetrics(SM_CXICON);
  IconSizeY := GetSystemMetrics(SM_CYICON);
  {Create the "And" mask}
  AndMask := TBitmap.Create;
  //Mask := TBitmap.Create; - утечка
  AndMask.Monochrome := true;
  AndMask.Width := IconSizeX;
  AndMask.Height := IconSizeY;
  {Draw on the "And" mask}
//  AndMask.Canvas.Brush.Color := clWhite;
  //Mask.Assign(SourceGIF.Bitmap[FrameNumber]); - лишнее
  TempB := SourceGIF.GetStripBitmap(Mask);
  TempB.Free; //функция создает картинку, которая нам не нужна
  AndMask.Assign(Mask);
  {Draw as a test}
//  Form1.Canvas.Draw(IconSizeX * 2, IconSizeY, AndMask);
  {Create the "XOr" mask}
  XOrMask := TBitmap.Create;
  XOrMask.Width := IconSizeX;
  XOrMask.Height := IconSizeY;
  {Draw on the "XOr" mask}
  XOrMask.Canvas.Brush.Color := ClBlack;

  XOrMask.Assign(SourceGIF.Bitmap[FrameNumber]);
  {Draw as a test}
//  Form1.Canvas.Draw(IconSizeX * 4, IconSizeY, XOrMask);
  {Create a icon}
  Result := TIcon.Create;
  IconInfo.fIcon := true;
  IconInfo.xHotspot := 0;
  IconInfo.yHotspot := 0;
  IconInfo.hbmMask := AndMask.Handle;
  IconInfo.hbmColor := XOrMask.Handle;
  Result.Handle := CreateIconIndirect(IconInfo);
  {Destroy the temporary bitmaps}
  AndMask.Free;
  XOrMask.Free;
  Mask.Free;
  {Draw as a test}
  //Form1.Canvas.Draw(IconSizeX * 6, IconSizeY, Icon);
  {Assign the application icon}
  //Application.Icon := Icon;
  {Force a repaint}
  //InvalidateRect(Application.Handle, nil, true);
  {Free the icon}
  //Result := Icon;
end;

end.
