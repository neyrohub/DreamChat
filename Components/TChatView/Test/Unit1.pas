unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, PtblCV,
  CVStyle, CVScroll,
  LiteGifx2, CVLiteGifAniX2, ChatView;
type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    ChatView1: TChatView;
    Button1: TButton;
    Label1: TLabel;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Edit1: TEdit;
    CVStyle1: TCVStyle;
    Button7: TButton;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Debug(Mess, Mess2: String);
    procedure OnLinkMouseMoveProcessing(SenderCV: TComponent; DrawCont: TDrawContainerInfo; LinkInfo:TLinkInfo);//��訸��ⰷ �v��� �� ��vv��
    procedure OnLinkMouseUpProcessing(Button: TMouseButton; X, Y: Integer; SenderCV: TComponent; DrawCont: TDrawContainerInfo; LinkInfo:TLinkInfo);//��訸��ⰷ �v��� �� ��vv��
    procedure ChatView1MouseMove(Sender: TObject; Shift: TShiftState; X,
              Y: Integer);

    procedure Button1Click(Sender: TObject);
    procedure TestButtonClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  GIFImage1:TGIF;
  frame:word;
  NickLink: TLinkInfo;
  TextStyle:integer;
  SmilesGIFImages:array [0..500] of TGif;
  TestButton:TButton;
  ProgressBar1: TProgressBar;


implementation

uses Unit2;

{$R *.DFM}
{------------------------------------------------------------------}
procedure TForm1.OnLinkMouseMoveProcessing(SenderCV: TComponent; DrawCont: TDrawContainerInfo; LinkInfo:TLinkInfo);
BEGIN
Button2.Caption := 'Processing : ' + inttostr(DrawCont.ContainerNumber);
//MessageBox(0, PChar('LinkProcessing'), PChar(inttostr(1)) ,mb_ok);
END;

procedure TForm1.OnLinkMouseUpProcessing(Button: TMouseButton; X, Y: Integer; SenderCV: TComponent; DrawCont: TDrawContainerInfo; LinkInfo:TLinkInfo);//��訸��ⰷ �v��� �� ��vv��
BEGIN
Button1.Caption := 'Down : ' + inttostr(DrawCont.ContainerNumber);
//MessageBox(0, PChar('LinkProcessing'), PChar(inttostr(1)) ,mb_ok);
END;

procedure TForm1.TestButtonClick(Sender: TObject);
BEGIN
Form1.Caption := inttostr(TestButton.Top);
END;

procedure TForm1.ChatView1MouseMove(Sender: TObject; Shift: TShiftState; X,
          Y: Integer);
var ItemAtPos: integer;
begin
ItemAtPos := ChatView1.FindItemAtScreenPos(x, y);
if ItemAtPos > 0 then
  begin
  form1.Caption := ChatView1.DrawContainers.Strings[ItemAtPos];
  end;
end;

procedure TForm1.Debug(Mess, Mess2: String);
var n:word;
BEGIN
//if Form2 <> nil then Form2.memo1.lines.Add(Mess2);
if Form2 <> nil then Form2.Caption := Mess2;
Label1.Caption := Mess;
//Form2.Caption := Mess2;
END;
{------------------------------------------------------------------}
procedure TForm1.FormCreate(Sender: TObject);
const crlf:String = chr(13)+chr(10);
      cvsProgram = LAST_DEFAULT_STYLE_NO+1;
      cvsLetter = LAST_DEFAULT_STYLE_NO+2;
var CVDisplayOption: TCVDisplayOption;
    FontInfos:TFontInfos;
    FontInfo:TFontInfo;
    MS:TMemoryStream;
    Link: TLinkInfo;
begin
  {~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
//  TestButton := TButton.Create(nil{ChatView1});
//Form1.Constraints
  MS := TMemoryStream.Create;
  TestButton := TButton.Create(ChatView1);
  TestButton.OnClick := TestButtonClick;
  TestButton.Height := 24;
  ProgressBar1 := TProgressBar.Create(ChatView1);
  ProgressBar1.Position := 50;
  ProgressBar1.Width := 200;
  ChatView1.OnDebug := Form1.Debug;
  ChatView1.OnMouseMove := ChatView1MouseMove;
  ChatView1.CursorSelection := false;
  TextStyle := 0;

//  GIFImage1 := TGIF.Create;
//  GIFImage1.LoadFromFile('bath.gif');
  SmilesGIFImages[0] := TGif.Create;
//  MS.LoadFromFile('r_cs.gif');
  MS.LoadFromFile('hmm.gif');
//  MS.LoadFromFile('bath.gif');
//  MS.LoadFromFile('getaway.gif');
  SmilesGIFImages[0].LoadFromStream(ms);
  MS.Clear;
  SmilesGIFImages[1] := TGif.Create;
  MS.LoadFromFile('lol.gif');
  SmilesGIFImages[1].LoadFromStream(ms);

//  SmilesGIFImages[0] := TGifAni.Create('75.gif');//TGIFImage.Create;
//  SmilesGIFImages[0] := TGifAni.Create('113.gif');//TGIFImage.Create;
//  SmilesGIFImages[1] := TGifAni.Create('hmm.gif');//TGIFImage.Create;
//  SmilesGIFImages[0] := TGifAni.Create('punk.gif');//TGIFImage.Create;
//  SmilesGIFImages[0].OnDebug := Debug;
//  SmilesGIFImages[1].OnDebug := Debug;
  {~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
  Link := ChatView1.AddLink(0, OnLinkMouseMoveProcessing,
                            OnLinkMouseUpProcessing,
                            CVStyle1.TextStyles.Items[4],
                            CVStyle1.TextStyles.Items[3],
                            'http:\\rambler.ru');
//  Button1.Caption := inttostr(ChatView1.LinksInfo.IndexOfObject(Link));
//Link := nil;

  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, Link);
  ChatView1.Add('TChatViewTChatViewTChatViewTChatViewTChatViewTChatViewTChatViewTChatViewTChatViewTChatViewTChatViewTChatViewTChatView', TextStyle, nil);
  ChatView1.Add('|TChatView|', TextStyle, Link);
  ChatView1.Add('|Demo1|', TextStyle, Link);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program2', TextStyle, nil);
//  ChatView1.Add('', cvsNormal);
//  ChatView1.AddGif(0, GIFImage1, false);
// ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, Link);
//  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
//  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
//  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
//  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
//  ChatView1.AddGifAni(':bath:', SmilesGIFImages[1], false);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
//  ChatView1.AddWinControl(TestButton, false);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
//  ChatView1.AddBreak;
//  ChatView1.AddBreak;
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
{  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
//   ChatView1.AddGifAni(':bath:', SmilesGIFImages[1], false);}
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[1], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
{  ChatView1.AddGifAni(':bath:', SmilesGIFImages[1], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[1], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[1], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[1], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);

  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, link);
//  ChatView1.AddFromNewLine('Contents', cvsSubHeading);
//  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false);
//  ChatView1.AddWinControl(TestButton, false);
//  ChatView1.Add('TChatView Demo and Help Program TChatView Demo and Help Program', TextStyle, nil);
{  ChatView1.AddWinControl(ProgressBar1, false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, link);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  {}
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', cvsNormal, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.Add('|TChatView Demo and Help Program TChatView Demo and Help Program|', TextStyle, nil);
  ChatView1.AddCenterLine('(Copyright(c) 2004-2007 by Bajenov A.V.)', cvsNormal, nil);
  ChatView1.AddCenterLine('Contents', cvsSubHeading, link);
  {~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
  ChatView1.Format;
  {~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
//  SmilesGIFImages[0].BeginAnimate(ChatView1.GetCanvas(), ChatView1.Style.Color);
//  SmilesGIFImages[1].BeginAnimate(ChatView1.GetCanvas(), ChatView1.Style.Color);
MS.free;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
//RxGIFAnimator1.Free;
//GIFImage1.free;
ChatView1.Clear;
TestButton.Free;
SmilesGIFImages[0].free;
SmilesGIFImages[1].free;
end;

procedure TForm1.Button1Click(Sender: TObject);
var i: integer;
begin
i := 0;
  ChatView1.Add('TsChatView Demo', TextStyle, nil);
//  ChatView1.Add('TsChatView Demo and Help Program TsChatView Demo and Help Program', TextStyle, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
  ChatView1.Format;
//  ChatView1.FormatTail;
  ChatView1.Repaint;

{for i := 0 to 8000 do
  begin
  ChatView1.Add('TChatView Demo ' + inttostr(i) + ' ', TextStyle, nil);
//  ChatView1.Add('TChatView Demo and Help Program TChatView Demo and Help Program', TextStyle, nil);
  ChatView1.AddGifAni(':bath:', SmilesGIFImages[0], false, nil);
//  ChatView1.Format;
  end;}
  ChatView1.FormatTail;
  ChatView1.Repaint;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  ChatView1.AddWinControl(TestButton, false, nil);
//  ChatView1.Format;
  ChatView1.FormatTail;
  ChatView1.Repaint;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  s: string;
  Link: TLinkInfo;
//bmp: TBitmap;
//DC: HDC;
begin 
{bmp := TBitmap.Create;
bmp.Height := Button3.Height;
bmp.Width := Button3.Width;
DC := GetDC(Button3.Handle);
bitblt(bmp.Canvas.Handle, 0, 0, Button3.Width, Button3.Height,
       DC, 0, 0, SRCCOPY);
Form1.Canvas.Draw(0, 250, bmp);
//bmp.SaveToFile('Screen.bmp');
ReleaseDC(0, DC);
//ChatView1.cava}
s := 'I_DisplayNickName ';
//ChatView1.AddTextFromNewLine(s + ' ', 1, nil);
//ChatView1.AddText('tUser.DisplayNickName', 2, nil);
//ChatView1.AddTextFromNewLine('I_NickName' + ' ', 1, nil);
//ChatView1.AddText('tUser.NickName', 2, nil);
//ChatView1.AddTextFromNewLine('<NickName>' + ' ', 1, nil);
Link := ChatView1.AddLink(0, OnLinkMouseMoveProcessing,
                             OnLinkMouseUpProcessing,
                             CVStyle1.TextStyles.Items[4],
                             CVStyle1.TextStyles.Items[3],
                             'http:\\rambler.ru');
ChatView1.AddText( '<RemoteNickName>', 2,
                           ChatView1.AddLink(0,
                           OnLinkMouseMoveProcessing,
                           OnLinkMouseUpProcessing,
                           CVStyle1.TextStyles.Items[4],
                           CVStyle1.TextStyles.Items[3],
                           'http:\\rambler.ru'));
ChatView1.AddText('Message', 3, nil);
ChatView1.FormatTail;
ChatView1.Repaint;
end;

procedure TForm1.Button4Click(Sender: TObject);
var i, link: integer;
begin
//�������� � ��� ��� ���� �� ��� ������� ���� ����� ��������� ���� �����
//�� ��� ����� ���� �� ���� �� ������ ������� ���� �����!
//� ��� ������ ������ ������ � ����� ��������� �� ��������� ����������!
i := CVStyle1.AddTextStyle;
Button4.Caption := 'Last style: ' + IntToStr(i);
CVStyle1.TextStyles.Items[i].Color := clWhite;

NickLink := ChatView1.AddLink(0, OnLinkMouseMoveProcessing,
                              OnLinkMouseUpProcessing,
                              CVStyle1.TextStyles.Items[i],
                              CVStyle1.TextStyles.Items[3], 'Andrey');
Edit1.Text := IntToStr(ChatView1.LinksInfo.IndexOfObject(NickLink));
ChatView1.Add('Andrey', 0, NickLink);
ChatView1.FormatTail;
ChatView1.Repaint;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
CVStyle1.TextStyles.Delete(6);
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
ChatView1.DeleteLink(TLinkInfo(ChatView1.LinksInfo.Objects[StrToInt(Edit1.Text)]), CVStyle1.TextStyles.Items[0]);
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
ChatView1.Clear;
ChatView1.FormatTail;
ChatView1.Repaint;
end;

end.
