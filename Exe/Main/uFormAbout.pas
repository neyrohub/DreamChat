unit uFormAbout;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, sSkinProvider, ShellApi,
  ChatView, sChatView, cvStyle, CVScroll, litegifX2;

type
  TFormAbout = class(TPersistent)
  protected
    FFormAbout     :TForm;
    FChatView      :TsChatView;
    FCVStyle       :TCVStyle;
    FTimer         :TTimer;
    FSkinProvider  :TsSkinProvider;
  private
    { Private declarations }
  public
    { Public declarations }
    SmilesGIFImages                     :array of TGif;
    property FormAbout	        	      :TForm read FFormAbout write FFormAbout;
    property ChatLineView		            :TsChatView read FChatView write FChatView;
    property CVStyle		                :TCVStyle read FCVStyle write FCVStyle;
    property Timer		                  :TTimer read FTimer write FTimer;
    property SkinProvider               :TsSkinProvider read FSkinProvider write FSkinProvider;
    constructor Create(ownForm:TForm; DfmPath, GifPath: string);
    destructor Destroy;override;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure StringToComponent(Component: TComponent; Value: string);
    procedure Timer1Timer(Sender: TObject);
    procedure OnLinkMouseMoveProcessing(SenderCV: TComponent; DrawCont: TDrawContainerInfo; LinkInfo:TLinkInfo);//юсЁрсюЄўшъ ъышър эр ёёvыъх
    procedure OnLinkMouseDownProcessing(Button: TMouseButton; X, Y: Integer; SenderCV: TComponent; DrawCont: TDrawContainerInfo; LinkInfo:TLinkInfo);//юсЁрсюЄўшъ ъышър эр ёёvыъх
  end;

const br: String = ' ' + chr(13) + chr(10);
      NORMALTEXTSTYLE = 0;
      REDTEXTSTYLE = 1;
      BLACKTEXTSTYLE = 2;
      LINKTEXTSTYLE = 3;
      ONLINKTEXTSTYLE = 4;

implementation

uses uFormMain;

constructor TFormAbout.Create(ownForm:TForm; DfmPath, GifPath: string);
var Canvas: TCanvas;
    n: integer;
    strlist: TStringList;
//    Link: String;
    MS: TMemoryStream;
    LinkText, OverLinkText: TFontInfo;
begin
//inherited Create(ownForm);
inherited Create();

strlist := TStringList.Create;
{создаем TFormPopUp}

FFormAbout := TForm.Create(nil);
  FFormAbout.Name := 'FormAbout';
  //  Self.parent := ownForm;
  strlist.LoadFromFile(DfmPath + 'FormAbout.txt');
  self.StringToComponent(FFormAbout, strlist.text);
  FFormAbout.ParentWindow := 0;
  FFormAbout.parent := nil;//
  FFormAbout.OnClose := FormClose;
{/создаем ChatLineView}

{создаем CVStyle}
FCVStyle := TCVStyle.Create(FFormAbout);
  FCVStyle.Name := 'CVStyle';
//  FCVStyle.parent := FFormAbout;
//  FCVStyle.ParentWindow := FFormAbout.Handle;
  strlist.LoadFromFile(DfmPath + 'FormAboutStyle.txt');
  self.StringToComponent(FCVStyle, strlist.text);
{/создаем CVStyle}

{создаем SkinProvider}
FSkinProvider := TsSkinProvider.Create(FFormAbout);
  FSkinProvider.Form := FFormAbout;
  FSkinProvider.PrepareForm;
{/создаем SkinProvider}

{создаем ChatLineView}
FChatView := TsChatView.Create(FFormAbout);
  FChatView.Name := 'ChatView';
  FChatView.parent := FFormAbout;
  FChatView.ParentWindow := FFormAbout.Handle;
  FChatView.Style := self.FCVStyle;//так надо!
  strlist.LoadFromFile(DfmPath + 'FormAboutCV.txt');
  self.StringToComponent(FChatView, strlist.text);
  FChatView.Style := self.FCVStyle;//так надо!
  FChatView.CursorSelection := false;
//  ChatLineView.OnVScrolled := OnVScrolled;
//  ChatLineView.OnMouseDown := ChatLineViewMouseDown;
{/создаем ChatLineView}

strlist.Free;

//нужно добавить столько переносов строки, чтобы текст оказался ровно ниже канваса
FChatView.Style := self.FCVStyle;
FChatView.VScrollVisible := false;

setLength(SmilesGIFImages, 5);
SmilesGIFImages[0] := TGif.Create;
SmilesGIFImages[1] := TGif.Create;
SmilesGIFImages[2] := TGif.Create;
SmilesGIFImages[3] := TGif.Create;
SmilesGIFImages[4] := TGif.Create;

MS := TMemoryStream.Create;
try
  MS.LoadFromFile(GifPath + 'notworthy.gif');
  SmilesGIFImages[0].LoadFromStream(ms);
  MS.Clear;
  MS.LoadFromFile(GifPath + 'russian_ru.gif');
  SmilesGIFImages[1].LoadFromStream(ms);
  MS.Clear;
  MS.LoadFromFile(GifPath + 'girl_witch.gif');
  SmilesGIFImages[2].LoadFromStream(ms);
  MS.Clear;
  MS.LoadFromFile(GifPath + 'friends.gif');
  SmilesGIFImages[3].LoadFromStream(ms);
  MS.Clear;
  MS.LoadFromFile(GifPath + 'snoozer_19.gif');
  SmilesGIFImages[4].LoadFromStream(ms);
  MS.Clear;
except
  on E: Exception do
    begin
    MessageBox(0, PChar(E.Message), PChar('GIF image loading  error!'), mb_ok);
    end;
end;
MS.Free;

Canvas := FChatView.GetCanvas;
with FChatView.Style.TextStyles[0] do
  begin
  Canvas.Font.Style   := Style;
  Canvas.Font.Size    := Size;
  Canvas.Font.Name    := FontName;
  Canvas.Font.CharSet := CharSet;
  end;

//FFormAbout.Caption := inttostr(FFormAbout.Height) + ' / ' + inttostr(Canvas.TextHeight(crlf)) + ' = ' +
//                      inttostr(round(FFormAbout.Height/Canvas.TextHeight(crlf)));
for n := 0 to trunc(FFormAbout.Height/Canvas.TextHeight(br)) - 2 do
  begin
  FChatView.AddTextFromNewLine(br, 0, nil);
  end;
//      NORMALTEXTSTYLE = 0;
//      REDTEXTSTYLE = 1;
//      BLACKTEXTSTYLE = 2;
//      LINKTEXTSTYLE = 4;
//      ONLINKTEXTSTYLE = 5;

LinkText := FCVStyle.TextStyles.Items[LINKTEXTSTYLE];
OverLinkText := FCVStyle.TextStyles.Items[ONLINKTEXTSTYLE];

with FChatView do
  begin
  AddCenterLine('Вас приветствует команда', BLACKTEXTSTYLE, nil);
  AddCenterLine('разработчиков DreamChat!', BLACKTEXTSTYLE, nil);
  AddTextFromNewLine(br, 0, nil);
  AddTextFromNewLine('Хочется сказать несколько слов о проекте. Начиная писать этот чат в 2004 году для себя я и не мог' +
  ' предположить, что он пополнит ряды Open Source Software.' +
  ' Но я рад, что это произошло! Мне приятно, что в этом мире есть еще люди,' +
  ' которые пишут программы не только ради денег, но и для' +
  ' души!', NORMALTEXTSTYLE, nil);
  AddTextFromNewLine('Поэтому хотелось бы их всех поблагодарить' +
  ' и начать конечно надо с автора оригинального Intranet Chat. ' +
                     'Александр Ворожун, спасибо Вам за уникальный чат! Он помогает тысячам пользователям ' +
                     'ощутить радость от общения в сети!', NORMALTEXTSTYLE, nil);
  AddTextFromNewLine('Страница в интернете: ', NORMALTEXTSTYLE, nil);
  AddText('http://vnalex.tripod.com/', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://vnalex.tripod.com/'));
  AddTextFromNewLine('Страница в Wikipedia: ', NORMALTEXTSTYLE, nil);
  AddText('http://ru.wikipedia.org/wiki/IChat', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://ru.wikipedia.org/wiki/IChat'));
  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);

  AddTextFromNewLine('Передаю приветы всем участникам проекта DreamChat:', BLACKTEXTSTYLE, nil);
  AddTextFromNewLine('Автор DreamChat.exe: ', REDTEXTSTYLE, nil);
  AddText(           'Баженов Андрей (aka Neyro[RUS])', NORMALTEXTSTYLE, nil);
  AddTextFromNewLine('Моя страница в сети Internet: ', NORMALTEXTSTYLE, nil);
  AddText('http://neyro.h15.ru', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://neyro.h15.ru'));
  AddTextFromNewLine('Моя почта: ', NORMALTEXTSTYLE, nil);
  AddText('neyro@mail.ru', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'mailto:neyro@mail.ru'));
  AddTextFromNewLine('Я в контакте: ', NORMALTEXTSTYLE, nil);
  AddText('http://vk.com/bajenov', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://vk.com/bajenov'));
  AddTextFromNewLine('Автор модуля настроек: ', REDTEXTSTYLE, nil);
  AddText(           'Петривский Николай (aka Torbins)', NORMALTEXTSTYLE, nil);
  AddTextFromNewLine('Николай в контакте: ', NORMALTEXTSTYLE, nil);
  AddText('http://vk.com/id9399979', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://vk.com/id9399979'));
  AddTextFromNewLine('Автор DreamChat Server: ', REDTEXTSTYLE, nil);
  AddText(           'Андрей Романченко (aka LaserSquard)', NORMALTEXTSTYLE, nil);
  AddTextFromNewLine('Андрей в Одноклассниках: ', NORMALTEXTSTYLE, nil);
  AddText('hhttp://www.odnoklassniki.ru/profile/156729022749', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://www.odnoklassniki.ru/profile/156729022749'));
  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddTextFromNewLine('Дело по клонированию движется, надеюсь к нашей интернациональной команде будут присоединяться все кому не без различна судьба IChat.', NORMALTEXTSTYLE, nil);
  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);

//  AddTextFromNewLine('Ссылки:', BLACKTEXTSTYLE, -1);
  AddTextFromNewLine('Страница нашего проекта в сети Internet: ', NORMALTEXTSTYLE, nil);
  AddText('http://sourceforge.net/projects/dreamchat', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://sourceforge.net/projects/dreamchat'));
  AddTextFromNewLine('Все замеченые баги, вопросы и пожелания пишите на наш форум: ', NORMALTEXTSTYLE, nil);
  AddText('http://dreamchat.flybb.ru', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://dreamchat.flybb.ru/'));

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);


  AddTextFromNewLine('Хочу сказать большое спасибо:' , BLACKTEXTSTYLE, nil);
  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[3], false, nil);
  AddText( 'Петривский Николай (aka Torbins) за внедрение в проект скинов' +
  ' (AlphaControls), создание модуля настроек и за' +
  ' неоценимые заслуги в выявлении багов и ошибок в DreamChat. А особенно за' +
  ' подключение к проекту эксперта EurekaLog.' +
  ' C этой системой дело по выявлению багов наконец сдвинулось с мертвой точки.', NORMALTEXTSTYLE, nil);

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[3], false, nil);
  AddText( 'Андрей Романченко (aka LaserSquard) за написание DreamChat Server,' +
  ' исправление tcpkrnl.dll, за профессиональную реструктуризацию проекта,' +
  ' за организацию и поддержку проекта на SourceForge.net,' +
  ' за терпение, когда приходилось объяснять двум новичкам правила работы в' +
  ' SourceForge.net, а также за помощь в вылавливании багов в DreamChat.', NORMALTEXTSTYLE, nil);

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[1], false, nil);
  AddText( 'Автору колобков Aiwan (не нашел Вашего имени)! Без ваших смайлов ' +
  ' в чате не чего делать! ', NORMALTEXTSTYLE, nil);
  AddText('http://www.kolobok.us', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://www.kolobok.us'));

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[0], false, nil);
  AddText( 'Sergey Tkachenko (', NORMALTEXTSTYLE, nil);
  AddText('http://www.trichview.com', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://www.trichview.com'));
  AddText( ') за исходники TRichView, TRVStyle and TRVPrint ' +
           'Components ver 0.5.2 FREEWARE, т.к. именно Ваши идеи помогли мне написать TsChatView.', NORMALTEXTSTYLE, nil);

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[0], false, nil);
  AddText( 'Mike Lischke and Delphi Gems software solutions (', NORMALTEXTSTYLE, nil);
  AddText('http://www.delphi-gems.com', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://www.delphi-gems.com'));
  AddText( ') за замечательный компонент Virtual ' +
           'Treeview 3.5.0 (Mozilla Public License (MPL) or Lesser General Public License (LGPL))', NORMALTEXTSTYLE, nil);

             AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[0], false, nil);
  AddText( 'Российской команде разработчиков компонентов Alpha Controls (', NORMALTEXTSTYLE, nil);
  AddText('http://alphaskins.com/', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://alphaskins.com/'));
  AddText( ') за модную одежду для чата!', NORMALTEXTSTYLE, nil);

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[0], false, nil);
  AddText( 'Программистам Мастер-Банка за замечательную библиотеку и исходники компонентов RXLIB (', NORMALTEXTSTYLE, nil);
  AddText('http://www.rxlib.ru', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://www.rxlib.ru'));
  AddText( ')', NORMALTEXTSTYLE, nil);

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[0], false, nil);
  AddText( 'Лучшему форуму Delphi программистов (Особенно разделу "Потрепаться") ', NORMALTEXTSTYLE, nil);
  AddText('http://delphimaster.ru/cgi-bin/forum.pl?n=3', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://delphimaster.ru'));

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[0], false, nil);
  AddText( 'Сообществу Delphi программистов ', NORMALTEXTSTYLE, nil);
  AddText('http://www.delphi-jedi.org/', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://www.delphi-jedi.org/'));

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[0], false, nil);
  AddText( 'Eurekalog за великолепный Bugs Tracer ', NORMALTEXTSTYLE, nil);
  AddText('http://www.eurekalog.com/', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://www.eurekalog.com/'));

//  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
//  AddGifAni('', SmilesGIFImages[2], false, nil);
//  AddText( 'Очаровательной, голубоглазой блондиночке Лене, за тотальный игнор. Если бы не он этот чат не появился бы вообще.', NORMALTEXTSTYLE, nil);

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[0], false, nil);
  AddText( 'А так же всем пользователям, кто принимал, принимает и будет принимать участие в этом проекте.', NORMALTEXTSTYLE, nil);
  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddTextFromNewLine('[update 2012] Надо сделать что-то хорошее перед концом света, ' +
  'поэтому я наконец-то нашел время для DChat! (шутка)' +
  ' А если серьезно, то в офлайн режиме работа не прекращалась. Я по мере возможности ' +
  'дописывал систему управления плагинами и сами плагины. ' +
  'Из-за нехватки свободного времени работа завершилась только сейчас. ' +
  'Надеюсь заработают плагин по передачи файлов, а потом и плагин для ' +
  'видеосвязи. Пока не знаю как сделать передачу звука с компрессией...(', NORMALTEXTSTYLE, nil);

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddCenterLine('', NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[4], false, nil);
  AddCenterLine('Автор DreamChat - Баженов Андрей', NORMALTEXTSTYLE, nil);
  AddCenterLine('Санкт-Петербург 2004-2012(с)', NORMALTEXTSTYLE, nil);
  end;
for n := 0 to round(FFormAbout.Height/Canvas.TextHeight(br)) - 1 do
  begin
  //добавляем в конец пустых строк
  FChatView.AddTextFromNewLine(br, 0, nil);
  end;
FChatView.Format;
FChatView.Repaint;
FTimer := TTimer.Create(FFormAbout);
FTimer.OnTimer := Timer1Timer;
FTimer.Interval := 50;
//FChatView.ScrollTo(430);

FFormAbout.Visible := true;

SetForegroundWindow(FFormAbout.Handle);
SetWindowPos(FFormAbout.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE);
end;


destructor TFormAbout.Destroy;
var n: integer;
begin
FTimer.Free;
FTimer := nil;

self.FFormAbout.Visible := false;
FChatView.Clear;
if self.FFormAbout <> nil then
  begin
  self.FFormAbout.Release;
  //FFormPopUp.free;
  self.FFormAbout := nil;
  end;

if self.FCVStyle <> nil then FCVStyle.Free;
if self.FChatView <> nil then FChatView.free;
if self.FSkinProvider <> nil then FSkinProvider.free;

//SmilesGIFImages[0].Free;
for n := 0 to Length(SmilesGIFImages) - 1 do
  begin
  SmilesGIFImages[n].Free;
  end;
Setlength(SmilesGIFImages, 0);
inherited Destroy;
end;

procedure TFormAbout.StringToComponent(Component: TComponent; Value: string);
var
  StrStream:TStringStream;
  ms: TMemoryStream;
begin
  StrStream := TStringStream.Create(Value);
  try
    ms := TMemoryStream.Create;
    try
      ObjectTextToBinary(StrStream, ms);
      ms.position := 0;
      ms.ReadComponent(Component);
    finally
      ms.Free;
    end;
  finally
    StrStream.Free;
  end;
end;

procedure TFormAbout.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
//self.Destroy;
//FormAbout := nil;
FreeAndNil(uFormMain.FormAbout);
end;

procedure TFormAbout.Timer1Timer(Sender: TObject);
begin
if FChatView.VScrollPos <> FChatView.VScrollMax then
  FChatView.VScrollPos := FChatView.VScrollPos + 1
else
  FChatView.VScrollPos := 0;
end;

procedure TFormAbout.OnLinkMouseMoveProcessing(SenderCV: TComponent;
                              DrawCont: TDrawContainerInfo; LinkInfo:TLinkInfo);
BEGIN
//Form1.Caption := LinkInfo.LinkText;
//Memo1.Lines.Add('Processing : ' + inttostr(DrawCont.ContainerNumber));
//MessageBox(0, PChar('LinkProcessing'), PChar(inttostr(1)) ,mb_ok);
END;

procedure TFormAbout.OnLinkMouseDownProcessing(Button: TMouseButton; X, Y: Integer;
              SenderCV: TComponent; DrawCont: TDrawContainerInfo; LinkInfo:TLinkInfo);//юсЁрсюЄўшъ ъышър эр ёёvыъх
var
StartupInfo: TStartupInfo;
ProcessInfo: TProcessInformation;
CommandLine: string;
BEGIN
FillChar(StartupInfo, SizeOf(StartupInfo), #0);
StartupInfo.cb := SizeOf(StartupInfo);
StartupInfo.dwFlags := STARTF_USESTDHANDLES;
StartupInfo.wShowWindow := SW_SHOWNORMAL;//SW_HIDE;
StartupInfo.hStdOutput := 0;
StartupInfo.hStdInput := 0;

//CommandLine := 'explorer.exe ' + LinkInfo.LinkText;
//CreateProcess(nil, PChar(CommandLine), nil, nil, True,
//              CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS,
//              nil, nil, StartupInfo, ProcessInfo);
ShellExecute(0,'Open', PChar(LinkInfo.LinkText), nil, nil, SW_SHOWNORMAL);


//DebugForm.DebugMemo1.Lines.Add('ContainerNumber = ' + inttostr(DrawCont.ContainerNumber) + '  LinkInfo.LinkText = ' +
//              LinkInfo.LinkText);
//MessageBox(0, PChar('LinkProcessing'), PChar(inttostr(1)) ,mb_ok);
END;

end.
