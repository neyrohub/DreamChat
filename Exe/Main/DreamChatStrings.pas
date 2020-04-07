unit DreamChatStrings;

interface

uses Classes;

type

TDreamChatStringIDs =
(
//[Form]
  I_COMMONCHAT,          //'Общий'
  I_PRIVATE,             //'Приват'
  I_LINE,                //'Линия'
  I_MESSAGESBOARD,       //Доска объявлений
  I_MESSAGESBOARDUPDATE, //Обновлена доска объявлений
  I_USERCONNECTED,       //К нам приходит:
  I_USERDISCONNECTED,    //Нас покинул :
  I_NOTANSWERING,
  I_PRIVATEWITH,         //Личный чат с
  I_USERRENAME,          //изменяет имя на
//[PopUpMenu]
  I_CLOSE,               //Закрыть
  I_REFRESH,             //Обновить
  I_SAVELOG,             //Сохранить лог
  I_PRIVATEMESSAGE,      //Личное сообщение
  I_PRIVATEMESSAGETOALL, //Личное сообщение всем
  I_CREATELINE,          //Создать линию
  I_TOTALIGNOR,          //Игнорировать все сообщения
  I_USERINFO,            //О пользователе
  I_COMETOPRIVATE,       //Войти в приват
  I_COMETOLINE,          //Войти в линию
//[UserInfo]
  I_DISPLAYNICKNAME,
  I_NICKNAME,
  I_IP,
  I_COMPUTERNAME,
  I_LOGIN,
  I_CHATVER,
  I_COMMDLLVER,
  I_STATE,
//[NewLine]
  I_INPUTPASSWORD,
  I_COMING,               //Войти
  I_INPUTPASSANDLINENAME, //Введите название и пароль для новой линии:
  I_CREATE,
  I_NEWLINE,
  I_CANCEL,
  I_LINENAME,
  I_PASSWORD,
//[MainPopUpMenu]
  I_EXIT,

  I_SEESHARE,             //перейти к ресурсам компьютера
  I_WRITENICKNAME         //Написать имя внизу
  );

  TDreamChatStrings = class
  private
    FStrings: TStrings;
    function GetData(index: integer): string;
    procedure SetData(index: integer; value: string);
    constructor Create;
    destructor Destroy; override;
  public

    procedure Load(IniFileName: string);
    property Data[index: integer]: string read GetData write SetData; default;
  end;

implementation

uses IniFiles, SysUtils;

{ TDreamChatStrings }

constructor TDreamChatStrings.Create;
begin
  inherited Create;
  FStrings := TStringList.Create;
end;

destructor TDreamChatStrings.Destroy;
begin
  FreeAndNil(FStrings);
  inherited Destroy;
end;

function TDreamChatStrings.GetData(index: integer): string;
begin
  Result := FStrings.Values[IntToStr(index)];
end;

procedure TDreamChatStrings.Load(IniFileName: string);
var
  MemIniStrings: TMemIniFile;
  //i, i_end: integer;
begin
  MemIniStrings := TMemIniFile.Create(IniFileName);

  //CurrLang := ExePath + ChatConfig.ReadString(TDreamChatConfig.Common {'Common'}, TDreamChatConfig.Language {'Language'}, 'Languages\English.lng');

  MemIniStrings.ReadSection('Strings', FStrings);

{  i_end := Section.Count - 1;
  for i := 0 to i_end do
    begin
    FStrings.Add(MemIniStrings.ReadString('Strings', InttoStr(i + 10), ''));//Strings
    //EInternational.Add(MemIniStrings.ReadString('ErrorStrings', InttoStr(i + 10), ''));
    end;}
end;

procedure TDreamChatStrings.SetData(index: integer; value: string);
begin

end;

end.

