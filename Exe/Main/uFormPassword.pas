unit uFormPassword;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, sSkinProvider, sButton, sEdit, sLabel;

type
  TFormPassword = class(TForm)
    Edit1: TsEdit;
    Label1: TsLabel;
    Label2: TsLabel;
    Edit2: TsEdit;
    Button1: TsButton;
    Button2: TsButton;
    sSkinProvider1: TsSkinProvider;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
  { Public declarations }
    procedure StringToComponent(Component: TComponent; Value: string);
  end;

//короче делаем так:
//эта форма создаетс€ динамически(не фиг пам€ть занимать) ф-цией ShowPasswordForm()
//на вход ф-ции передаетс€ режим работы формы. ≈сли GetPassword = true
//значит форма работает в режиме получени€ парол€. Ќазвание линии
//должно быть передано в переменной pLineName и выведено пользователю
//без возможности редактировани€. “.е. это режим при входе в существующую линию.
//» 2й режим GetPassword = false. Ёто режим дл€ создани€ линии
//‘орма читает название линии введенное пользователем и пароль.
//ѕри закрытии возвращает строку вида:
//'"LineName" "Password"'

FUNCTION ShowPasswordForm(GetPassword:boolean;pLineName: PChar; var ResultString: PChar):TModalResult;

var
  FormPassword: TFormPassword;
  res: String;
  GetPasswordMode: boolean;

implementation

uses uFormMain, uPathBuilder;

{$R *.DFM}
procedure TFormPassword.StringToComponent(Component: TComponent; Value: string);
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

FUNCTION ShowPasswordForm(GetPassword:boolean;pLineName: PChar;var ResultString: PChar):TModalResult;
var //strlist:TStringList;
    si, sc:string;
BEGIN
GetPasswordMode := GetPassword;
si := TPathBuilder.GetImagesFolderName(); //ExtractFilePath(Application.ExeName) + 'images\';
sc := TPathBuilder.GetComponentsFolderName();// ExtractFilePath(Application.ExeName) + 'Components\';
//strlist := TStringList.Create;
//strlist.LoadFromFile(sc + 'FFormPassword.txt');
FormPassword := TFormPassword.Create(nil);
//FormPassword.StringToComponent(FormPassword, strlist.text);
FormPassword.Button2.Caption := fmInternational.Strings[I_CANCEL];
FormPassword.Label1.Caption := fmInternational.Strings[I_LINENAME];
FormPassword.Label2.Caption := fmInternational.Strings[I_PASSWORD];
if GetPasswordMode = true then
  begin
  FormPassword.Caption := fmInternational.Strings[I_INPUTPASSWORD];//'¬ведите пароль дл€ входа в линию:';
  FormPassword.Button1.Caption := fmInternational.Strings[I_COMING];//'¬ойти';
  FormPassword.Edit1.ReadOnly := true;
  FormPassword.Edit1.Enabled := false;
  FormPassword.Edit1.Text := pLineName;
  FormPassword.Edit2.Text := '';
  end
else
  begin
  FormPassword.Caption := fmInternational.Strings[I_INPUTPASSANDLINENAME];
  FormPassword.Button1.Caption := fmInternational.Strings[I_CREATE];
  FormPassword.Edit1.Text := fmInternational.Strings[I_NEWLINE];
  FormPassword.Edit2.Text := '';
  end;
FormPassword.ShowModal;
ResultString := PChar(res);
result := FormPassword.ModalResult;
FormPassword.Destroy;
END;

procedure TFormPassword.Button1Click(Sender: TObject);
begin
if GetPasswordMode = true then
  begin
  res := '"' + FormPassword.Edit1.Text + '" ' +
         '"' + FormPassword.Edit2.Text + '"';
  FormPassword.ModalResult := mrOk;
  end
else
  begin
  if length(FormPassword.Edit1.Text) > 0 then
    begin
    res := '"' + FormPassword.Edit1.Text + '" ' +
           '"' + FormPassword.Edit2.Text + '"';
    FormPassword.ModalResult := mrOk;
    end;
  end;
end;

procedure TFormPassword.Button2Click(Sender: TObject);
begin
FormPassword.Close;
end;

end.
