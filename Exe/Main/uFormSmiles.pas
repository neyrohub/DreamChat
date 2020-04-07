unit uFormSmiles;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CVScroll, sChatView, CVStyle, Inifiles,
  sSkinProvider, sDialogs, sSkinManager, ChatView;

type
  TFormSmiles = class(TForm)
    ChatView1: TsChatView;
    CVStyle1: TCVStyle;
    sSkinProvider1: TsSkinProvider;
    procedure ChatView1KeyDown(Sender: TObject; var Key: Word;
                               Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure ChatView1Click(Sender: TObject);
    procedure ChatView1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    Capt: string;
    procedure Debug(Mess, Mess2: String);
  public
    { Public declarations }
    PROCEDURE LoadComponents(Sender: TObject);
  end;

//var
//  FormSmiles: TFormSmiles;

implementation

uses DreamChatTools, uFormMain, uPathBuilder;

{$R *.DFM}

PROCEDURE TFormSmiles.LoadComponents(Sender: TObject);
var s, sc: string;
    strlist: TStringList;
BEGIN
//  s := ExtractFilePath(Application.ExeName);
//  sc := s + 'Components\';

  strlist := TStringList.Create;
  try
    sc := TPathBuilder.GetComponentsFolderName();
    strlist.LoadFromFile(sc + 'FStyle.txt');
    StringToComponent(CVStyle1, strlist.text);
    strlist.LoadFromFile(sc + 'FSmilesForm.txt');
    StringToComponent(self, strlist.text);
    Capt := Caption;
  except
    on E: Exception do sMessageDlg('GIF image loading  error!', E.Message, mtError, [mbOk], 0);
  end;

  strlist.Free;
END;

procedure TFormSmiles.FormCreate(Sender: TObject);
var Myinfo: TStartUpInfo;
    //TempChatConfig: TMemIniFile;
begin
{TempChatConfig := TMemIniFile.Create(ExtractFilePath(Application.ExeName) + 'config.ini');
//устанавливаем путь до скинов
//sSkinManager1.Active := false;
//sSkinManager1.SkinDirectory :=  'C:\Program Files\Borland\Delphi7\Tools\AlphaControls\Skins';
if TempChatConfig.ReadBool('Skin', 'Enable', False) = true then
  begin
  FormSmiles.sSkinManager1.SkinDirectory := ExtractFilePath(Application.ExeName) + 'Skins';
  FormSmiles.sSkinManager1.SkinName := TempChatConfig.ReadString('Skin', 'SkinName', 'NextAlpha');
  FormSmiles.sSkinManager1.Active := true;
  end
else
  FormSmiles.sSkinManager1.Active := false;
TempChatConfig.Free;}

//GetStartUpInfo(MyInfo);
//MyInfo.wShowWindow := SW_MINIMIZE;
//MyInfo.wShowWindow := SW_HIDE;
//ShowWindow(Handle, MyInfo.wShowWindow);

LoadComponents(Sender);

ChatView1.OnDebug := Debug;
ChatView1.CursorSelection := True;
end;

procedure TFormSmiles.FormDestroy(Sender: TObject);
begin
  //
end;

procedure TFormSmiles.Debug(Mess, Mess2: String);
//var n:word;
BEGIN
//Form2.Caption := Mess2;
//Label1.Caption := Mess;
END;

procedure TFormSmiles.ChatView1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_Escape) then begin
    ModalResult := mrOK;
  end;

  if (Key = VK_Return) then begin
    FormMain.Edit1.Text := FormMain.Edit1.Text + ChatView1.DrawContainers.Strings[ChatView1.CursorContainer];
    FormMain.Edit1.SelStart := length(FormMain.Edit1.Text);
    ModalResult := mrOK;
  end;
end;

procedure TFormSmiles.ChatView1Click(Sender: TObject);
begin
  FormMain.Edit1.Text := FormMain.Edit1.Text + ChatView1.DrawContainers.Strings[ChatView1.CursorContainer];
  FormMain.Edit1.SelStart := length(FormMain.Edit1.Text);
  ModalResult := mrOK;
end;

procedure TFormSmiles.ChatView1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Caption := Capt + ChatView1.DrawContainers.Strings[ChatView1.CursorContainer];
end;

end.
