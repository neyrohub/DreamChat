unit uFormPopUpMessage;
//Этот юнит создает окна всплывающих сообщений
//Окна могут быть двух видов:
//Если чат на экране, то создается обычное окно посередине экрана
//Если чат скрыт, то создается всплывающее из систрея окно.


//внимание!!! при вызове Create(FormPopUpMessageId:cardinal;...)
//FormPopUpMessageId <- должен быть уникальным, бесконечновозрастающим!!!!
//Т.к. FormPopUpMessageList.AddObject(inttostr(MessageId), self);
//Указатель на прокручивающееся окно храниться в обычном StringList списке
//и достается оттуда по уникальному имени.
//Следить за этим!!

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, sChatView, cvStyle, uChatUser, uChatLine, CVScroll,
  sButton, sPanel, sSkinProvider;

type //возможные состояния окна
  TPopUpState = (stGoingUp,   //Летим вверх
                 stGoingDown, //Летим вниз
                 stSysTray,   //Отлетали вверх-вниз, сидим в трее
                 stNormal);   //Торчим посередине экрана

type
  TFormPopUpMessage = class(TPersistent)
  protected
    FFormPopUp     :TForm;
    FChatView      :TsChatView;
    FPanel1        :TsPanel;
    FPanel2        :TsPanel;
    FButton1       :TsButton;
    FButton2       :TsButton;
    FTimer1		     :TTimer;
    FTimer2		     :TTimer;
    FTimer3		     :TTimer;
    FSkinProvider1 :TsSkinProvider;
  private
    { Private declarations }
    Procedure SetState(PopUpState: TPopUpState);
  public
    { Public declarations }
    MessageId                           :integer;//номер сообщения в списке unit1_FormPopUpMessageList
    OwnerChatLineId                     :cardinal;
    FromChatUserId                      :cardinal;
    MaxTop                              :integer;//Всплываем пока не достигнем этой координаты
    FromChatUserCompName                :string;
    FormScrollingStyle                  :boolean;//устанавливаем, если всплывает из трея
    FState                              :TPopUpState;//возможные состояния окна
    property Timer1		            :TTimer read FTimer1 write FTimer1;//таймер скролинга текста
    property Timer2		            :TTimer read FTimer2 write FTimer2;//таймер выплывания/уплывания окна
    property Timer3		            :TTimer read FTimer3 write FTimer3;//таймаут принудительного закрытия сообщения из systray
    property FormPopUp	        	:TForm read FFormPopUp write FFormPopUp;
    property ChatView	            :TsChatView read FChatView write FChatView;
    property Panel1		            :TsPanel read FPanel1 write FPanel1;
    property Panel2		            :TsPanel read FPanel2 write FPanel2;
    property Button1    		      :TsButton read FButton1 write FButton1;
    property Button2	            :TsButton read FButton2 write FButton2;
    property State                :TPopUpState read FState write SetState;
    property SkinProvider1	      :TsSkinProvider read FSkinProvider1 write FSkinProvider1;
    constructor Create(ownForm:TForm;
                       ownChatLineId:cardinal; SenderUserId:cardinal;
                       sMessage: String);
    destructor Destroy;override;
    procedure FormResize(Sender: TObject);
    procedure ChatViewMouseDown(Sender: TObject; Button: TMouseButton;
              Shift: TShiftState; X, Y: Integer);
    procedure ChatViewMouseUp(Sender: TObject; Button: TMouseButton;
              Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  end;

const br: String = ' ' + chr(13) + chr(10);

implementation

uses uFormMain, DreamChatTools, uPathBuilder;

{$R *.DFM}
constructor TFormPopUpMessage.Create(ownForm:TForm;
                                     ownChatLineId:cardinal;
                                     SenderUserId:cardinal;
                                     sMessage: String);
var
  strlist: TStringList;
  n: cardinal;
  i: integer;
  si, sc{, SmileFileName}:string;
  //MS: TMemoryStream;
  ChatLine: TChatLine;
  tLocalUser{, tUser}: TChatUser;
//  hMenuHandle: HMENU;
begin
inherited Create();
state := stGoingUp;
MaxTop := 0;

FormScrollingStyle := false;//обычный стиль выскакивающего окна

self.OwnerChatLineId := ownChatLineId;
self.FromChatUserId := SenderUserId;

si := TPathBuilder.GetImagesFolderName(); //ExtractFilePath(Application.ExeName) + 'images\';
sc := TPathBuilder.GetComponentsFolderName(); //ExtractFilePath(Application.ExeName) + 'Components\';

strlist := TStringList.Create;
if FormMain.Visible then
  begin
  //если форма чата видна на экране, то создаем обычное окно личного сообщения
  //если нет, то создаем сокращенное окно и прокручиваем в нем текст сообщения
  {создаем TFormPopUp}
  FFormPopUp := TForm.Create(nil);
  FFormPopUp.Name := 'FormPopUp_' + inttostr(ownChatLineID) + '_' +
                                    inttostr(FromChatUserID) + '_' +
                                    inttostr(GetTickCount());
  //  Self.parent := ownForm;
  strlist.LoadFromFile(sc + 'FormPopUpMessage.txt');
  StringToComponent(FormPopUp, strlist.text);
  ShowWindow(FormPopUp.Handle, SW_HIDE);
  FormPopUp.ParentWindow := 0;
  FormPopUp.parent := nil;//
  FormPopUp.OnClose := FormClose;
  MaxTop := FormPopUp.Top;
  {/создаем ChatLineView}

  {/создаем Panel1}
  Panel1 := TsPanel.Create(FormPopUp);
  Panel1.Name := 'FormPopUpPanel1_' + inttostr(ownChatLineID) + '_' +
                                    inttostr(FromChatUserID) + '_' +
                                    inttostr(GetTickCount());
  strlist.LoadFromFile(sc + 'FormPopUpPanel1.txt');
  StringToComponent(Panel1, strlist.text);
  Panel1.parent := FormPopUp;
  Panel1.ParentWindow := FormPopUp.Handle;
  Panel1.Caption := '';
  {/создаем Panel1}
  {создаем Panel2}
  Panel2 := TsPanel.Create(FormPopUp);
  Panel2.Name := 'FormPopUpPanel2_' + inttostr(ownChatLineID) + '_' +
                                      inttostr(FromChatUserID) + '_' +
                                      inttostr(GetTickCount());
  strlist.LoadFromFile(sc + 'FormPopUpPanel2.txt');
  StringToComponent(Panel2, strlist.text);
  Panel2.parent := FormPopUp;
  Panel2.ParentWindow := FormPopUp.Handle;
  Panel2.Caption := '';
  {/создаем Panel2}

  {создаем ChatLineView}
  FChatView := TsChatView.Create(Panel2);
  FChatView.Name := 'FormPopUpChatView_' + inttostr(ownChatLineID) + '_' +
                                     inttostr(FromChatUserID) + '_' +
                                     inttostr(GetTickCount());
  FChatView.parent := Panel2;
  //  ChatLineView.ParentWindow := 0;
  FChatView.ParentWindow := Panel2.Handle;
  FChatView.Style := FormMain.CVStyle1;//так надо!
  strlist.LoadFromFile(sc + 'CLChatLineView.txt');
  StringToComponent(FChatView, strlist.text);
  FChatView.Style := FormMain.CVStyle1;//так надо!
  FChatView.Align := alClient;
  FChatView.CursorSelection := false;
  //  ChatLineView.OnVScrolled := OnVScrolled;
  //  ChatLineView.OnMouseDown := ChatLineViewMouseDown;
  {/создаем ChatLineView}

  {/создаем Button1}
  Button1 := TsButton.Create(Panel1);
  Button1.Name := 'FormPopUpButton1_' + inttostr(ownChatLineID) + '_' +
                                     inttostr(FromChatUserID) + '_' +
                                     inttostr(GetTickCount());
  strlist.LoadFromFile(sc + 'FormPopUpButtonOk.txt');
  StringToComponent(Button1, strlist.text);
  Button1.parent := Panel1;
  Button1.ParentWindow := Panel1.Handle;
  Button1.OnClick := Button1Click;
  {/создаем Button1}

  {/создаем Button2}
  Button2 := TsButton.Create(Panel1);
  Button2.Name := 'FormPopUpButton2_' + inttostr(ownChatLineID) + '_' +
                                     inttostr(FromChatUserID) + '_' +
                                     inttostr(GetTickCount());
  strlist.LoadFromFile(sc + 'FormPopUpButtonAnswer.txt');
  StringToComponent(Button2, strlist.text);
  Button2.parent := Panel1;
  Button2.ParentWindow := Panel1.Handle;
  Button2.OnClick := Button2Click;
  {/создаем Button2}

  {создаем SkinProvider1}
  SkinProvider1 := TsSkinProvider.Create(FormPopUp);
  SkinProvider1.Name := 'FormPopUpSkinProvider1_' + inttostr(ownChatLineID) + '_' +
                                     inttostr(FromChatUserID) + '_' +
                                     inttostr(GetTickCount());
  {/создаем SkinProvider1}
  RxTrayMess.Interval := 500;
  RxTrayMess.Animated := true;
  RxTrayMess.Show;
  end
else
  begin
  //если нет, то создаем сокращенное окно и прокручиваем в нем текст сообщения
  {создаем TFormPopUp}
  FormScrollingStyle := true;
  FFormPopUp := TForm.Create(nil);

  FFormPopUp.Name := 'FormPopUp_' + inttostr(ownChatLineID) + '_' +
                                    inttostr(FromChatUserID) + '_' +
                                    inttostr(GetTickCount());
  //Self.parent := ownForm;
  strlist.LoadFromFile(sc + 'FormPopUpMessage.txt');
  StringToComponent(FormPopUp, strlist.text);
  //ShowWindow(FormPopUp.Handle, SW_HIDE);

  FormPopUp.ParentWindow := GetDesktopWindow();
  FormPopUp.parent := nil;//
  FormPopUp.FormStyle := fsStayOnTop;{fsNormal;}
  FormPopUp.Position := poDefault;
  FormPopUp.BorderStyle := bsSingle;// bsToolWindow;//bsNone;
  FormPopUp.OnClose := self.FormClose;
  {/создаем TFormPopUp}

  {создаем SkinProvider1}
  SkinProvider1 := TsSkinProvider.Create(FormPopUp);
  SkinProvider1.Name := 'FormPopUpSkinProvider1_' + inttostr(ownChatLineID) + '_' +
                                     inttostr(FromChatUserID) + '_' +
                                     inttostr(GetTickCount());
  FormPopUp.BorderIcons := [];
  {/создаем SkinProvider1}

  {создаем ChatLineView}
  FChatView := TsChatView.Create(FormPopUp);
  FChatView.Name := 'FormPopUpChatView_' + inttostr(ownChatLineID) + '_' +
                                     inttostr(FromChatUserID) + '_' +
                                     inttostr(GetTickCount());
  FChatView.Style := FormMain.CVStyle1;//так надо!
  FChatView.Parent := nil;
  FChatView.ParentWindow := FormPopUp.Handle;
  strlist.LoadFromFile(sc + 'CLChatLineView.txt');
  StringToComponent(FChatView, strlist.text);
  FChatView.CursorSelection := false;
  //FChatView.Align := alClient;
  FChatView.Width := FormPopUp.ClientWidth;
  FChatView.Height := FormPopUp.ClientHeight;
  FChatView.VScrollVisible := false;//гасим прокрутку
  FChatView.OnMouseUp := ChatViewMouseUp;
  FChatView.OnMouseDown := ChatViewMouseDown;
  {/создаем ChatLineView}
  FormPopUp.Left := Screen.DesktopWidth - FormPopUp.Width;
  FormPopUp.Top := Screen.WorkAreaHeight - 1;// - FormPopUp.Height;
  //добавляем пустые строки перед текстом, чтобы сообщение выплывало не сразу.
  for n := 0 to trunc(FChatView.Height/FChatView.GetCanvas.TextHeight(br) - 2) do
    begin
    FChatView.AddTextFromNewLine(br, 0, nil);
    end;

  end;
  strlist.Free;

  FormPopUp.OnResize := FormResize;

  ChatLine := FormMain.GetChatLineById(ownChatLineId);
if ChatLine <> nil then
  begin
  FromChatUserCompName := ChatLine.ChatLineUsers[FromChatUserId].ComputerName;
  tLocalUser := ChatLine.GetUserInfo(ChatLine.GetLocalUserId());
  MessageId := tLocalUser.PrivateMessCount;
  tLocalUser.PrivateMessCount := tLocalUser.PrivateMessCount + 1;
  FormPopUp.Caption := '[' + ChatLine.DisplayChatLineName +
                       '] ' + ChatLine.ChatLineUsers[FromChatUserId].ComputerName;
  sMessage := '<' + ChatLine.ChatLineUsers[FromChatUserId].DisplayNickName + '> ' + sMessage;
  end
else
  begin
  FromChatUserCompName := 'Unknown user';
  MessageId := GetTickCount();//с вероятностью в 99.99% это будет уникальный номер
  end;

//добавляем эту форму в список форм
FormPopUpMessageList.AddObject(inttostr(MessageId), self);
//пишем само сообщение
FormMain.ParseAllChatView(sMessage, nil, FormMain.CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE], nil, self.FChatView, false, true);

if FormScrollingStyle then
  begin
  //добавляем пустые строки после сообщения, чтобы оно полностью скролировалось вверх.
  for n := 0 to trunc(FChatView.Height/FChatView.GetCanvas.TextHeight(br)) - 1 do
    begin
    FChatView.AddTextFromNewLine(br, 0, nil);
    end;
  FChatView.VScrollPos := 0;

  MaxTop := Screen.WorkAreaHeight - FormPopUp.Height;
  for i := 0 to FormPopUpMessageList.Count - 1 do
    begin
    if TFormPopUpMessage(FormPopUpMessageList.Objects[i]).MessageId <> self.MessageId then
      begin
      //с самим собой сравнивать не надо
      if MaxTop > TFormPopUpMessage(FormPopUpMessageList.Objects[i]).FFormPopUp.Top then
        begin
        //на экране уже есть сообщения, пытаемся подняться выше
        MaxTop := TFormPopUpMessage(FormPopUpMessageList.Objects[i]).FFormPopUp.Top - self.FormPopUp.Height;
        if MaxTop < 0 then
          begin
          //выше уже верхняя граница экрана, и мы не помещаемся(( пробуем сместить влево
          MaxTop := Screen.WorkAreaHeight - FormPopUp.Height;
          end;
        end;
      end;
    end;

  Timer1 := TTimer.Create(FormPopUp);
  Timer1.OnTimer := Timer1Timer;
  Timer2 := TTimer.Create(FormPopUp);
  Timer2.OnTimer := Timer2Timer;
  Timer3 := TTimer.Create(FormPopUp);
  Timer3.OnTimer := Timer3Timer;
  Timer3.Enabled := false;

  Timer1.Interval := 70;//пускаем таймер скроллинга
  Timer2.Interval := 10;//пускаем таймер выползания окна
  end;
FChatView.FormatTail;
FChatView.Repaint;

if FormScrollingStyle = false then
  begin
  //если это скролируемое окно
  //переводит поток, который создал определяемое окно в приоритетный режим и активизирует окно.
  SetForegroundWindow(FormPopUp.Handle);
  SetWindowPos(FormPopUp.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE);
  FormPopUp.Visible := true;
  end
else
  begin
  //если это обычное выскакивающее окно
  //Style := GetWindowLong(FormPopUp.Handle, GWL_STYLE);
  //Style := Style And Not WS_SYSMENU;
  //SetWindowLong(FormPopUp.Handle, GWL_STYLE, Style);
  //создаем форму, которая не отбирает фокус у существующей
  //ShowWindow(FormPopUp.Handle, SW_SHOWNA);
  FormPopUp.Visible := true;
  ShowWindow(FormPopUp.Handle, SW_SHOWNOACTIVATE);
  end;
ShowWindow(Application.Handle, SW_HIDE);//убираем главную форму с панели задач
end;


destructor TFormPopUpMessage.Destroy;
var n:integer;
begin
self.FormPopUp.Visible := false;

FChatView.Clear;
{
FChatLineView.Free;//т.е. все они Parent от FFormPopUp, то их не надо уничтожать!
self.FButton1.free;//они сами уничтожатся при self.FFormPopUp.Release
self.FButton2.free;//а иначе AV!!!!
self.FPanel1.free;
self.FPanel2.free;
}
if self.FFormPopUp <> nil then
  begin
  if FChatView <> nil then FChatView.Free;
  n := FormPopUpMessageList.IndexOf(inttostr(Self.MessageId));
  if n >= 0 then
    begin
    //FormPopUpMessageList.Objects[n] := nil;
    FormPopUpMessageList.Delete(n);
    end;
  self.FFormPopUp.free;
  self.FFormPopUp := nil;
  end;

RxTrayMess.Animated := false;
RxTrayMess.Hide;
inherited Destroy;
end;

procedure TFormPopUpMessage.Button1Click(Sender: TObject);
begin
self.FFormPopUp.Close;
RxTrayMess.Animated := false;
RxTrayMess.Hide;
end;

procedure TFormPopUpMessage.Button2Click(Sender: TObject);
var
   ChatLine: TChatLine;
   tUser: TChatUser;
begin
//нужно написать имя юзера внизу, но он уже мог уйти...
ChatLine := FormMain.GetChatLineById(Self.OwnerChatLineId);
if ChatLine <> nil then
  begin
  if ChatLine.GetUserIdByCompName(FromChatUserCompName) = FromChatUserId then
    begin
    tUser := ChatLine.GetUserInfo(FromChatUserId);
    if tUser <> nil then
      begin
      FormMain.Edit1.Text := '/msg "' + tUser.DisplayNickName + '" ';
      FormMain.Edit1.SelStart := length(FormMain.Edit1.Text);
      end;
    end;
  end;
FormPopUp.Close;
if Application.MainForm.Visible = false then
  begin
  //Application.MainForm.Visible := True;
  Application.Restore;
  //посылаем сообщение окну, чтобы оно скрыло свой заголовок с панели задач
  //ShowWindow(Application.Handle, SW_HIDE);
  Application.BringToFront;
  end;
RxTrayMess.Animated := false;
RxTrayMess.Hide;
end;

procedure TFormPopUpMessage.Timer1Timer(Sender: TObject);
begin
if FChatView.VScrollPos < FChatView.VScrollMax then
  begin
  //листаем окно
  FChatView.VScrollPos := FChatView.VScrollPos + 1;
  FChatView.Paint; //с версии AC5.08 начались глюки в перерисовке
  end
else
  begin
  //пролистали окно до конца
  FChatView.VScrollPos := 0;
  Timer3.Interval := 1;//10*1000;//пускаем таймер автозакрытия окна
  Timer3.Enabled := true;
  end;
end;

procedure TFormPopUpMessage.Timer2Timer(Sender: TObject);
begin
//таймер всплытия/погружения окна из трея
if State = stGoingUp then
  begin
  //если окно всплывает вверх
  if FormPopUp.Top > MaxTop then
    FormPopUp.Top := FormPopUp.Top - 5
  else
    Timer2.Interval := 0;
  end;
if State = stGoingDown then
  begin
  //если окно упплывает вниз
  if FormPopUp.Top < Screen.WorkAreaHeight then
    begin
    FormPopUp.Top := FormPopUp.Top + 5;
    end
  else
    begin
    //полностью скрылись внизу экрана, закрываемся))

    //postmessage(FormPopUp.Handle, wm_close, 0, 0);
    //нельзя напрямую вызывать закрытие FormPopUp.Close т.к. это уничтожит ChatView
    //а в компоненте еще должна отработать внутренняя обработка MouseUp
    Timer2.Enabled := false;
    state := stSysTray;
    end;
  end;
end;

procedure TFormPopUpMessage.Timer3Timer(Sender: TObject);
begin
Timer3.Enabled := false;
//принудительно закрываем окно из systray
//showing := false;
state := stGoingDown;
end;

procedure TFormPopUpMessage.ChatViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
{if Button = mbLeft then
  begin
  FormMain.Visible := true;
  FormMain.BringToFront;
  end;}
//postmessage(FormPopUp.Handle, wm_close, 0, 0);
//нельзя напрямую вызывать закрытие FormPopUp.Close т.к. это уничтожит ChatView
//а в компоненте еще должна отработать внутренняя обработка MouseDown
end;

procedure TFormPopUpMessage.ChatViewMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   ChatLine: TChatLine;
   tUser: TChatUser;
begin
if Button = mbLeft then
  begin
  //FormMain.Visible := true;
  Application.MainForm.Visible := True;
  Application.Restore;
  Application.BringToFront;
  ShowWindow(Application.Handle, SW_HIDE);
//  Showing := false;
  state := stGoingDown;

//нужно написать имя юзера внизу, но он уже мог уйти...
ChatLine := FormMain.GetChatLineById(Self.OwnerChatLineId);
if ChatLine <> nil then
  begin
  if ChatLine.GetUserIdByCompName(FromChatUserCompName) = FromChatUserId then
    begin
    tUser := ChatLine.GetUserInfo(FromChatUserId);
    if tUser <> nil then
      begin
      FormMain.Edit1.Text := '/msg "' + tUser.DisplayNickName + '" ';
      FormMain.Edit1.SelStart := length(FormMain.Edit1.Text);
      end;
    end;
  end;

  end
else
  begin
  if FormScrollingStyle then postmessage(FormPopUp.Handle, wm_close, 0, 0);
  //нельзя напрямую вызывать закрытие FormPopUp.Close т.к. это уничтожит ChatView
  //а в компоненте еще должна отработать внутренняя обработка MouseUp
  end;
end;

procedure TFormPopUpMessage.FormResize(Sender: TObject);
begin
if not FormScrollingStyle then
  begin
  self.Button1.Left := Round((panel1.Width/2 - self.Button1.Width)/2);
  self.Button2.Left := Round(panel1.Width/2 + (panel1.Width/2 - self.Button1.Width)/2);
  end;
end;

procedure TFormPopUpMessage.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
self.Destroy;
end;

Procedure TFormPopUpMessage.SetState(PopUpState: TPopUpState);
begin
//(stGoingUp, stGoingDown, stSysTray, stNormal);
if PopUpState = stGoingUp then
  begin
  FState := stGoingUp;
  end;
if PopUpState = stGoingDown then
  begin
  FState := stGoingDown;
  FTimer2.Interval := 10;//пускаем таймер уползания окна
  end;
if PopUpState = stSysTray then
  begin
  //потом здесь не закрывать окно. Засветим в трее иконку и при нажатии на нее
  //вызовем откопаем окно в массиве и изменим его статус на Normal.
  //Это отобразит его на экране.
  FormPopUp.Close;
  RxTrayMess.Interval := 500;
  RxTrayMess.Animated := true;
  RxTrayMess.Show;
  end;
end;

end.
