unit uChatUser;

interface
uses classes, Windows, SysUtils, VirtualTrees, Inifiles, CVStyle, sChatView,
     ChatView, sDialogs, Graphics, ComCtrls,
     uLoadSaveStyleItems{, UDebugForm};

//TShowUserAction = (ShowUser_ADD, ShowUser_REDRAW, ShowUser_DELETE);

type

  TCheckNodeStates = (CNS_UnSelect, CNS_Private, CNS_Personal);

  // статусы дрима
  TDreamChatStatus = (dcsNormal = 0, dcsBusy = 1, dcsDND = 2, dcsAway = 3, dcsDisconnected = 4);

procedure FontInfoToFont(fi:TfontInfo; var f:TFont);

type
  TChatUser = class (TPersistent)
  private
    FComputerName             :String;
    FNickName		              :String;
    FDisplayNickName		      :String;
    FLogin                   	:String;
    FIP           		        :String;
    FProtoName			          :String;
    FVersion			            :String;
    FMessageBoard             :TStringList;
    FMessageStatus            :TStringList;
    FChatLinesList            :TStringList;//TLineNode у каждого юзера есть список линий в которых он состоит
    FLineName     		        :String;
    FLine                     :TObject;
//    FUserID	 		              :cardinal;
    FLastRefreshMessNumber    :cardinal;
    FTimeLastUpdate     	    :cardinal;
    FTimeInChat         	    :cardinal;
    FTimeOfLastMess     	    :cardinal;
    FReceivedMessCount      	:cardinal;
    FPrivateMessCount  	      :cardinal;
    FLastReceivedMessNumber 	:cardinal;//чтобы не приходили ложные сообщения! (как у автора)
    FStatus 			            :TDreamChatStatus;
    FCN_State                 :TCheckNodeStates;
    FIgnored                  :boolean;
    FPersonalIniConfigFile    :boolean;
    FVirtualNode              :PVirtualNode;
    FIsExpanded               :boolean;
    FUserConfigFileName       :string;//тут храним имя файла-конфига. Когда разрушаем юзера, записываем в уже созданный файл!
    FUserNickNames            :TStringList; //Все ники, которые когдалибо использовал даный юзер. Нужно для диалога настроек.
    procedure SetDisplayNickName(const Value: String);
  protected
    function GetUserId(): cardinal;
  public
    UserOnLineLI              :TLinkInfo;//указатель на ссылку, которая будет отображаться при наведении на ник
    UserOnLineFS              :TFontInfo;//указатель на конкретный стиль в общем списке стилей CVStyle1
    UserOnLineMouseOverFS     :TFontInfo;//указатель на конкретный стиль в общем списке стилей CVStyle1
    SoundDisconnect           :String;
    SoundConnect              :String;
    SoundText                 :String;
    SoundAlert                :String;
    SoundAlertToAll           :String;
    SoundReceived             :String;
    SoundStatus               :String;
    SoundBoard                :String;
    SoundRefresh              :String;
    SoundRename               :String;
    SoundCreate               :String;
    SoundFindLine             :String;
    property UserID	 	       	:cardinal read GetUserID {write FUserID};
    property ComputerName 		:String read FComputerName write FComputerName;
    property NickName			    :String read FNickName write FNickName;
    property DisplayNickName 	:String read FDisplayNickName write SetDisplayNickName;//отображаем в дереве не NickName, а DisplayNickName
                              //это на случай если у двух челов одинаковый ник, мы их отображаем в виде DisplayNickName = ComputerName_NickName
    property Login           	:String read FLogin write FLogin;
    property IP           		:String read FIP write FIP;
    property MessageStatus   	:TStringList read FMessageStatus write FMessageStatus;
    property MessageBoard    	:TStringList read FMessageBoard write FMessageBoard;
    property ChatLinesList    :TStringList read FChatLinesList write FChatLinesList;
    property LineName         :String read FLineName write FLineName;
    property Line             :TObject read FLine write FLine;
    property ProtoName			  :String read FProtoName write FProtoName;
    property Version			    :String read FVersion write FVersion;
    property TimeLastUpdate  	:cardinal read FTimeLastUpdate write FTimeLastUpdate;
    property TimeInChat      	:cardinal read FTimeInChat write FTimeInChat;
    property TimeOfLastMess  	:cardinal read FTimeOfLastMess write FTimeOfLastMess;
    property ReceivedMessCount:cardinal read FReceivedMessCount write FReceivedMessCount;
    property PrivateMessCount :cardinal read FPrivateMessCount write FPrivateMessCount;
    property LastReceivedMessNumber	:cardinal read FLastReceivedMessNumber write FLastReceivedMessNumber;//чтобы не приходили ложные сообщения! (как у автора)
    property LastRefreshMessNumber 	:cardinal read FLastRefreshMessNumber write FLastRefreshMessNumber;//т.к.
    property Status 		      :TDreamChatStatus read FStatus write FStatus;
    property CN_State 	      :TCheckNodeStates read FCN_State write FCN_State;
    property Ignored 	        :boolean read FIgnored write FIgnored;
    property VirtualNode 	    :PVirtualNode read FVirtualNode write FVirtualNode;
    property IsExpanded 	    :boolean read FIsExpanded write FIsExpanded;
    property UserNickNames    :TStringList read FUserNickNames write FUserNickNames;
//    MessHistory           :TStringList;
    function GetSoundFile(IniUserConfigFile: TMemIniFile; SoundName: string): string;
    procedure Assign(Source: TPersistent);override;{virtual;}
    procedure CreateIniUserFile(IniFileList: TMemIniFile);
    procedure LoadUserSettingsFromIni(IniUserConfigFile: TMemIniFile);
    procedure SaveUserSettingsToIni();
    //function StrToIntE(s: string):integer;
    constructor Create(CLine: TObject; ReceivedMessage: String); {override;}
    destructor Destroy; override;
  published
  end;

  PChatUser = ^TChatUser;

  PTreeNode = ^TTreeNode;

type
  TConfigChatUser = class (TPersistent)
  private
    FChanged                  :boolean;
    FUserOnLineFS             :TFont;
    FUserOnLineMouseOverFS    :TFont;
    FSoundDisconnect          :String;
    FSoundConnect             :String;
    FSoundText                :String;
    FSoundAlert               :String;
    FSoundAlertToAll          :String;
    FSoundReceived            :String;
    FSoundStatus              :String;
    FSoundBoard               :String;
    FSoundRefresh             :String;
    FSoundRename              :String;
    FSoundCreate              :String;
    FSoundFindLine            :String;
    procedure SetSoundAlert(const Value: String);
    procedure SetSoundAlertToAll(const Value: String);
    procedure SetSoundBoard(const Value: String);
    procedure SetSoundConnect(const Value: String);
    procedure SetSoundCreate(const Value: String);
    procedure SetSoundDisconnect(const Value: String);
    procedure SetSoundFindLine(const Value: String);
    procedure SetSoundReceived(const Value: String);
    procedure SetSoundRefresh(const Value: String);
    procedure SetSoundRename(const Value: String);
    procedure SetSoundStatus(const Value: String);
    procedure SetSoundText(const Value: String);
    procedure FontChanged(Sender: TObject);
  public
    UserTreeNode                       :TTreeNode;
    UserConfigFileName                 :string;
    ComputerName 		                   :String;
    UserNickNames                      :TStringList;
    property Changed                   :boolean read FChanged write FChanged;
    property UserOnLineFS              :TFont read FUserOnLineFS write FUserOnLineFS;
    property UserOnLineMouseOverFS     :TFont read FUserOnLineMouseOverFS write FUserOnLineMouseOverFS;
    property SoundDisconnect           :String read FSoundDisconnect write SetSoundDisconnect;
    property SoundConnect              :String read FSoundConnect write SetSoundConnect;
    property SoundText                 :String read FSoundText write SetSoundText;
    property SoundAlert                :String read FSoundAlert write SetSoundAlert;
    property SoundAlertToAll           :String read FSoundAlertToAll write SetSoundAlertToAll;
    property SoundReceived             :String read FSoundReceived write SetSoundReceived;
    property SoundStatus               :String read FSoundStatus write SetSoundStatus;
    property SoundBoard                :String read FSoundBoard write SetSoundBoard;
    property SoundRefresh              :String read FSoundRefresh write SetSoundRefresh;
    property SoundRename               :String read FSoundRename write SetSoundRename;
    property SoundCreate               :String read FSoundCreate write SetSoundCreate;
    property SoundFindLine             :String read FSoundFindLine write SetSoundFindLine;
    function GetSoundFileName(SoundName: string): string;
    function SetSoundFileName(SoundPath: string): string;
    function GetLastNick: string;
    function GetAllNicks: string;
    procedure LoadUserSettingsFromIni(IniUserConfigFile: TMemIniFile);
    procedure SaveUserSettingsToIni(var IniUserConfigFile: TMemIniFile);
    constructor Create; {override;}
    destructor Destroy; override;
  end;

implementation

uses uFormMain, uChatLine, DreamChatTools, uLineNode, uPathBuilder;

procedure FontInfoToFont(fi:TfontInfo; var f:TFont);
begin
f.Charset:=fi.CharSet;
f.Name:=fi.FontName;
f.Size:=fi.Size;
f.Color:=fi.Color;
f.Style:=fi.Style;
end;

{-------------------------------------}
constructor TChatUser.Create(CLine: TObject; ReceivedMessage: String);
label L1;
var Path: string;
    IniUserConfigFile, IniFileList: TMemIniFile;
//    StrList: TStringList;
//    ChatLine: TChatLine;
//    i: integer;
begin
//сделать передачу параметра! LOCALUSER|REMOTEUSER
//чтобы сразу при создании вкачивать в него инфу!
  inherited Create();
//  ChatLine := TChatLine(CLine);
  FLine := CLine;

  FMessageStatus := TStringList.Create;
  FMessageBoard := TStringList.Create;
  FChatLinesList := TStringList.Create;
  FUserNickNames := TStringList.Create;
  FComputerName           := GetParamX(ReceivedMessage, 2, #19#19, true);
  FCN_State               := CNS_UnSelect;
  FPrivateMessCount       := 0;
  FTimeLastUpdate         := 0;
  FTimeInChat             := 0;
  FTimeOfLastMess         := 0;
  FReceivedMessCount      := 0;
  FPrivateMessCount       := 0;
  FLastReceivedMessNumber := 0;
  FStatus 		            := dcsNormal;
  FCN_State               := CNS_UnSelect;
  FVirtualNode            := nil;
  FIsExpanded             := False;
  UserOnLineFS            := nil;
  UserOnLineMouseOverFS   := nil;
  UserOnLineLI            := nil;

{0.451 дальше тест прокачки юзера при создании!! (Возможно и локального!)}
  {if Length(ReceivedMessage) = 0 then
    begin
        Self.UserID := ChatLine.UsersCount - 1;
        Self.ComputerName := ChatLine.LocalComputerName;
        Self.IP := ChatLine.LocalIpAddres;

        Self.Login := ChatLine.LocalLoginName;
        Self.NickName := ChatLine.LocalNickName;
        Self.DisplayNickName := ChatLine.LocalNickName;
        Self.Status := 0;
        Self.MessageStatus.Clear;
        Self.LineName := ChatLine.ChatLineName;
        //Self.Version := VERSION;
        Self.Version := 'Not init';
        Self.ReceivedMessCount := 0;
        Self.LastReceivedMessNumber := 0;
        Self.TimeInChat := GetTickCount();
        Self.TimeOfLastMess := GetTickCount();
        StrList := TStringList.Create;
        for i := 0 to 3 do
          begin
          form1.ChatConfig.ReadSectionValues('MessagesState' + IntToStr(i), StrList);
          if StrList.Count > 0 then
            begin
            Self.MessageStatus.Add(StrList.Strings[0]);
            end
          else
            Self.MessageStatus.Add('Hi all!');
          end;
        Self.ProtoName := Form1.ChatConfig.ReadString('Protocols', 'ProtoName', 'iChat');
        StrList.Clear;
        StrList.LoadFromFile(Form1.ChatConfig.ReadString('Common', 'MessageBoard', 'MessageBoard.txt'));
        Self.MessageBoard.Text := StrList.Text;
        StrList.Free;
    end
  else
    begin
      Self.UserID := ChatLine.UsersCount - 1;
      Self.ComputerName := ChatLine.GetParamX(ReceivedMessage, 2, #19#19, true);
      Self.Login := ChatLine.GetParamX(ReceivedMessage, 5, #19#19, true);
      Self.NickName := ChatLine.GetParamX(ReceivedMessage, 6, #19#19, true);
      Self.Status := ChatLine.StrToIntE(ChatLine.GetParamX(ReceivedMessage, 11, #19#19, true));
      if Self.ComputerName <> ChatLine.LocalComputerName then
        begin
        while Self.Status >= Self.MessageStatus.Count do
          begin
          Self.MessageStatus.Add('');
          end;
        Self.MessageStatus.Strings[Self.Status] := ChatLine.GetParamX(ReceivedMessage, 8, #19#19, true);
        end;
      Self.LineName := (ChatLine.GetParamX(ReceivedMessage, 4, #19#19, true));
      Self.Version := ChatLine.GetParamX(ReceivedMessage, 10, #19#19, true);
      Self.ReceivedMessCount := Self.ReceivedMessCount + 1;
      Self.LastReceivedMessNumber := ChatLine.strtointE(ChatLine.GetParamX(ReceivedMessage, 1, #19#19, true));
      if ChatMode = cmodTCP then Self.Ip := ChatLine.GetParamX(Self.ComputerName, 0, '/', true);
      Self.TimeInChat := GetTickCount();
      Self.TimeOfLastMess := GetTickCount();
      //Self.DisplayNickName := ChatLine.GetUniqueNickName(Self.UserID);//тут ее нельзя вызывать!!
      //т.к. в GetUniqueNickName идет обращение к объекту, конструктор которого еще не отработал...
      Self.ProtoName := ChatLine.GetParamX(ReceivedMessage, 1, #19, true);
    end;}
//Прокачка закончена ))

//Далее считываем сохраненные параметры из файла-конфига этого юзера
  Path := TPathBuilder.GetUsersFolderName; //ExePath + 'Users\';
  if FileExists(Path + 'FileList.txt') = true then
    begin
    //FileList.txt со списком файлов-конфигов существует!
    IniFileList := TMemIniFile.Create(Path + 'FileList.txt');
    FUserConfigFileName := IniFileList.ReadString('UsersID', Self.ComputerName, '');
    if (length(FUserConfigFileName) >= 17) then
      begin
      //запись о файле есть, попробуем найти сам файл
      if FileExists(Path + FUserConfigFileName + '.txt') then
        begin
        //нашли файл с настройками юзера!
        FPersonalIniConfigFile := true;//признак того, что изменения должны быть сохранены при уходе юзера
        IniUserConfigFile := TMemIniFile.Create(Path + FUserConfigFileName + '.txt');
        Self.LoadUserSettingsFromIni(IniUserConfigFile);
        IniUserConfigFile.Free;
        end
      else
        begin
        //запись в FileList.txt есть, а файла нет!!! убираем запись
        //MessageBox(0, PChar('запись в FileList.txt есть, а файла нет!!!'), PChar(inttostr(1)) ,mb_ok);
        IniFileList.DeleteKey('UsersID', Self.ComputerName);
        Goto L1;
        end;
      end
    else
      begin
      L1:
      //ВНИМАНИЕ!!! Эта строчка говорит, что мы не будем сохранять конфиг
      //для этого юзера, однако создадим его и загрузим дефолтные настройки!
      FPersonalIniConfigFile := false;

      //FileList.txt со списком файлов-конфигов существует!
      //но в нем нет записи о файле-конфиге этого юзера
      //создаем файл-конфиг для этого юзера
      FUserConfigFileName := FormatDateTime( 'yy', Now) +
                             FormatDateTime( 'MM', Now) +
                             FormatDateTime( 'DD', Now) +
                             FormatDateTime('HH', Now)+
                             FormatDateTime('NN', Now) +
                             IntToStr(GetTickCount());
      self.CreateIniUserFile(IniFileList);
      IniFileList.WriteString('UsersID', Self.ComputerName, FUserConfigFileName);
      IniFileList.UpdateFile;
      end;
    end
  else
    begin
    //FileList.txt не существует!
    IniFileList := TMemIniFile.Create(Path + 'FileList.txt');
    FUserConfigFileName := FormatDateTime( 'yy', Now) +
                           FormatDateTime( 'MM', Now) +
                           FormatDateTime( 'DD', Now) +
                           FormatDateTime('HH', Now)+
                           FormatDateTime('NN', Now) +
                           IntToStr(GetTickCount());
    //создаем FileList.txt
    IniFileList.WriteString('UsersID', Self.ComputerName, FUserConfigFileName);
    IniFileList.UpdateFile;
    //создаем IniUserConfigFile.txt
    self.CreateIniUserFile(IniFileList);
    end;
  IniFileList.Free;
end;
{-------------------------------------}

destructor TChatUser.Destroy;
var
i: integer;
begin
//if FPersonalIniConfigFile = true then SaveUserSettingsToIni();
  SaveUserSettingsToIni();
  for I := 0 to FChatLinesList.Count - 1 do
    begin
    TLineNode(FChatLinesList.Objects[i]).free;
    end;
  FChatLinesList.Free;
  FMessageBoard.Free;
  FMessageStatus.Free;
  FUserNickNames.Free;
  inherited Destroy;
end;
{-------------------------------------}

procedure TChatUser.Assign(Source: TPersistent);
//var VirtualNd:TVirtualNode;
begin
  if Source is TChatUser then
    begin
      Self.ComputerName := TChatUser(Source).ComputerName;
      Self.NickName := TChatUser(Source).NickName;
      Self.DisplayNickName := TChatUser(Source).DisplayNickName;
      Self.Login := TChatUser(Source).Login;
      Self.IP := TChatUser(Source).IP;
      Self.ProtoName := TChatUser(Source).ProtoName;
      Self.FMessageStatus.Assign(TChatUser(Source).FMessageStatus);
      Self.FMessageBoard.Assign(TChatUser(Source).FMessageBoard);
      Self.FChatLinesList.Assign(TChatUser(Source).FChatLinesList);
      Self.FLineName := TChatUser(Source).FLineName;
      Self.FLine := TChatUser(Source).FLine;
      Self.Version := TChatUser(Source).Version;
      Self.TimeLastUpdate := TChatUser(Source).TimeLastUpdate;
      Self.TimeInChat := TChatUser(Source).TimeInChat;
      Self.TimeOfLastMess := TChatUser(Source).TimeOfLastMess;
      Self.ReceivedMessCount := TChatUser(Source).ReceivedMessCount;
      Self.LastReceivedMessNumber := TChatUser(Source).LastReceivedMessNumber;
      Self.LastRefreshMessNumber := TChatUser(Source).LastRefreshMessNumber;
      Self.PrivateMessCount := TChatUser(Source).PrivateMessCount;
      Self.Status := TChatUser(Source).Status;
      Self.CN_State := TChatUser(Source).CN_State;
      Self.FVirtualNode := TChatUser(Source).FVirtualNode;
      Self.IsExpanded := TChatUser(Source).IsExpanded;
      Self.FUserConfigFileName := TChatUser(Source).FUserConfigFileName;
      Self.FPersonalIniConfigFile := TChatUser(Source).FPersonalIniConfigFile;

      Self.SoundDisconnect := TChatUser(Source).SoundDisconnect;
      Self.SoundConnect := TChatUser(Source).SoundConnect;
      Self.SoundText := TChatUser(Source).SoundText;
      Self.SoundAlert := TChatUser(Source).SoundAlert;
      Self.SoundAlertToAll := TChatUser(Source).SoundAlertToAll;
      Self.SoundReceived := TChatUser(Source).SoundReceived;
      Self.SoundStatus := TChatUser(Source).SoundStatus;
      Self.SoundBoard := TChatUser(Source).SoundBoard;
      Self.SoundRefresh := TChatUser(Source).SoundRefresh;
      Self.SoundRename := TChatUser(Source).SoundRename;
      Self.SoundCreate := TChatUser(Source).SoundCreate;
      Self.SoundFindLine := TChatUser(Source).SoundFindLine;

      Self.UserOnLineLI := TChatUser(Source).UserOnLineLI;
      Self.UserOnLineFS := TChatUser(Source).UserOnLineFS;
      Self.UserOnLineMouseOverFS := TChatUser(Source).UserOnLineMouseOverFS;
    end
  else
    inherited Assign(Source);
end;

FUNCTION TChatUser.GetUserId(): cardinal;
var c: cardinal;
begin
result := INVALID_USER_ID;
for c := 0 to TChatLine(self.FLine).UsersCount - 1 do
  begin
  if TChatLine(self.FLine).ChatLineUsers[c] = self then
    begin
    result := c;
    break;
    end;
  end;
end;

{FUNCTION TChatUser.StrToIntE(s: string):integer;
BEGIN
result := 0;
try
  result := strtoint(s);
except
    //on E:EConvertError do
  on E:Exception do
    begin
    FormMain.ProcessException(Self, E);
    end;
end;
END;
}

function TChatUser.GetSoundFile(IniUserConfigFile: TMemIniFile; SoundName: string): string;
var s: string;
begin
s := IniUserConfigFile.ReadString('Sound', SoundName, '');
if (length(s) > 0) and (s[1] = '\') then s := ExcludeTrailingBackslash(TPathBuilder.GetExePath()) + s;
if not FileExists(s) then
  result := ''
else
  result := IniUserConfigFile.ReadString('Sound', SoundName, '');
//DebugForm.DebugMemo2.Lines.Add('SoundName: ' + SoundName + ' ' + result);
end;

procedure TChatUser.CreateIniUserFile(IniFileList: TMemIniFile);
var IniUserConfig: TMemIniFile;
    FontInfoSave :TTXTStyle;
    StringList: TStringList;
    i: integer;
begin
//IniFileList.WriteString('UsersID', Self.IP, FUserConfigFileName);
//IniFileList.UpdateFile;
IniUserConfig := TMemIniFile.Create(TPathBuilder.GetUsersFolderName {ExePath + 'Users\'} + FUserConfigFileName + '.txt');
//здесь надо грузануть дефолтный конфиг!!!
IniUserConfig.WriteString('TChatUser', 'ComputerName', Self.ComputerName);
IniUserConfig.WriteInteger('TChatUser', 'CheckNodeStates', FormMain.DefaultUser.ReadInteger('TChatUser', 'CheckNodeStates', 0));

Self.SoundDisconnect := FormMain.DefaultUser.ReadString('Sound', 'Disconnect', '');
Self.SoundText := FormMain.DefaultUser.ReadString('Sound', 'Text', '');
Self.SoundConnect := FormMain.DefaultUser.ReadString('Sound', 'Connect', '');
Self.SoundAlert := FormMain.DefaultUser.ReadString('Sound', 'Alert', '');
Self.SoundAlertToAll := FormMain.DefaultUser.ReadString('Sound', 'AlertToAll', '');
Self.SoundReceived := FormMain.DefaultUser.ReadString('Sound', 'Received', '');
Self.SoundStatus := FormMain.DefaultUser.ReadString('Sound', 'Status', '');
Self.SoundBoard := FormMain.DefaultUser.ReadString('Sound', 'Board', '');
Self.SoundRefresh := FormMain.DefaultUser.ReadString('Sound', 'Refresh', '');
Self.SoundRename := FormMain.DefaultUser.ReadString('Sound', 'Rename', '');
Self.SoundCreate := FormMain.DefaultUser.ReadString('Sound', 'Create', '');
Self.SoundFindLine := FormMain.DefaultUser.ReadString('Sound', 'FindLine', '');

IniUserConfig.WriteString('Sound', 'Disconnect', Self.SoundDisconnect);
IniUserConfig.WriteString('Sound', 'Text', Self.SoundText);
IniUserConfig.WriteString('Sound', 'Connect', Self.SoundConnect);
IniUserConfig.WriteString('Sound', 'Alert', Self.SoundAlert);
IniUserConfig.WriteString('Sound', 'AlertToAll', Self.SoundAlertToAll);
IniUserConfig.WriteString('Sound', 'Received', Self.SoundReceived);
IniUserConfig.WriteString('Sound', 'Status', Self.SoundStatus);
IniUserConfig.WriteString('Sound', 'Board', Self.SoundBoard);
IniUserConfig.WriteString('Sound', 'Refresh', Self.SoundRefresh);
IniUserConfig.WriteString('Sound', 'Rename', Self.SoundRename);
IniUserConfig.WriteString('Sound', 'Create', Self.SoundCreate);
IniUserConfig.WriteString('Sound', 'FindLine', Self.SoundFindLine);

//загружаем раздел [UserOnLineFS] из конфига юзера в компонент CVStyle
FontInfoSave := TTXTStyle.Create(nil);
StringList := TStringList.Create;
FormMain.DefaultUser.ReadSectionValues('UserOnLineFS', StringList);
FontInfoSave.SetStyleItems(0, StringList.Text);
i := FormMain.CVStyle1.AddTextStyle;
FormMain.CVStyle1.TextStyles.Items[i] := FontInfoSave.TextStyles.Items[0];
//тут сохраняем указатель на стиль конкретного юзера в общем списке стилей
UserOnLineFS := FormMain.CVStyle1.TextStyles.Items[i];

FormMain.DefaultUser.ReadSectionValues('UserOnLineMouseOverFS', StringList);
FontInfoSave.SetStyleItems(0, StringList.Text);
i := FormMain.CVStyle1.AddTextStyle;
FormMain.CVStyle1.TextStyles.Items[i] := FontInfoSave.TextStyles.Items[0];
//тут сохраняем указатель на стиль конкретного юзера в общем списке стилей
UserOnLineMouseOverFS := FormMain.CVStyle1.TextStyles.Items[i];

//проверяем заходил ли юзер в чат до этого?
i := TChatLine(self.FLine).UsersConnectHistory.IndexOf(self.FComputerName);
if i < 0 then
  begin
  //не заходил! добавляем его ссылку!
  UserOnLineLI := TChatLine(self.FLine).ChatLineView.AddLink(
                                        Ord(ltNICK),
                                        FormMain.OnLinkMouseMoveProcessing,
                                        FormMain.OnLinkMouseUpProcessing,
                                        UserOnLineFS,
                                        UserOnLineMouseOverFS,
                                        ComputerName);
  {i := }TChatLine(self.FLine).UsersConnectHistory.AddObject(self.FComputerName, UserOnLineLI);
  end
else
  begin
  //юзер уже один раз заходи в чат и его ссылка уже добавлена!
  UserOnLineLI := TLinkInfo(TChatLine(self.FLine).UsersConnectHistory.Objects[i]);
  //прокачиваем стили (были OffLine, стали снова индивидуальные)
  UserOnLineLI.LinkStyle := UserOnLineFS;
  UserOnLineLI.MouseOverLinkStyle := UserOnLineMouseOverFS;
  TChatLine(self.FLine).ChatLineView.UpDateLink(UserOnLineLI);
  end;

StringList.Clear;
IniUserConfig.GetStrings(StringList);
StringList.Add('');
StringList.Add('[UserNickNames]');
StringList.Add(FDisplayNickName);
IniUserConfig.SetStrings(StringList);

StringList.free;
FontInfoSave.Free;

IniUserConfig.WriteBool('TChatUser', 'Ignored', FormMain.DefaultUser.ReadBool('TChatUser', 'Ignored', false));
IniUserConfig.UpdateFile;
IniUserConfig.Free;
end;

procedure TChatUser.LoadUserSettingsFromIni(IniUserConfigFile: TMemIniFile);
var //s: string;
    FontInfoSave :TTXTStyle;
    StringList: TStringList;
    i: integer;
begin
Self.CN_State := TCheckNodeStates(StrToIntE(IniUserConfigFile.ReadString('TChatUser', 'CheckNodeStates', '0')));
Self.Ignored := IniUserConfigFile.ReadBool('TChatUser', 'Ignored', false);

Self.SoundDisconnect := GetSoundFile(IniUserConfigFile, 'Disconnect');
Self.SoundText := GetSoundFile(IniUserConfigFile, 'Text');
Self.SoundConnect := GetSoundFile(IniUserConfigFile, 'Connect');
Self.SoundAlert := GetSoundFile(IniUserConfigFile, 'Alert');
Self.SoundAlertToAll := GetSoundFile(IniUserConfigFile, 'AlertToAll');
Self.SoundReceived := GetSoundFile(IniUserConfigFile, 'Received');
Self.SoundStatus := GetSoundFile(IniUserConfigFile, 'Status');
Self.SoundBoard := GetSoundFile(IniUserConfigFile, 'Board');
Self.SoundRefresh := GetSoundFile(IniUserConfigFile, 'Refresh');
Self.SoundRename := GetSoundFile(IniUserConfigFile, 'Rename');
Self.SoundCreate := GetSoundFile(IniUserConfigFile, 'Create');
Self.SoundFindLine := GetSoundFile(IniUserConfigFile, 'FindLine');

//загружаем раздел [UserOnLineFS] из конфига юзера в компонент CVStyle
FontInfoSave := TTXTStyle.Create(nil);
StringList := TStringList.Create;
//если не находим стили в файле юзера, берем их из дефолтового конфига
if IniUserConfigFile.SectionExists('UserOnLineFS') then
  IniUserConfigFile.ReadSectionValues('UserOnLineFS', StringList)
else
  FormMain.DefaultUser.ReadSectionValues('UserOnLineFS', StringList);
FontInfoSave.SetStyleItems(0, StringList.Text);
i := FormMain.CVStyle1.AddTextStyle;
FormMain.CVStyle1.TextStyles.Items[i] := FontInfoSave.TextStyles.Items[0];
//тут сохраняем указатель на стиль конкретного юзера в общем списке стилей
UserOnLineFS := FormMain.CVStyle1.TextStyles.Items[i];
//--------------
if IniUserConfigFile.SectionExists('UserOnLineMouseOverFS') then
  IniUserConfigFile.ReadSectionValues('UserOnLineMouseOverFS', StringList)
else
  FormMain.DefaultUser.ReadSectionValues('UserOnLineMouseOverFS', StringList);
IniUserConfigFile.ReadSectionValues('UserOnLineMouseOverFS', StringList);
FontInfoSave.SetStyleItems(0, StringList.Text);
i := FormMain.CVStyle1.AddTextStyle;
FormMain.CVStyle1.TextStyles.Items[i] := FontInfoSave.TextStyles.Items[0];
//тут сохраняем указатель на стиль конкретного юзера в общем списке стилей
UserOnLineMouseOverFS := FormMain.CVStyle1.TextStyles.Items[i];
//--------------

//проверяем заходил ли юзер в чат до этого?
i := TChatLine(self.FLine).UsersConnectHistory.IndexOf(self.FComputerName);
if i < 0 then
  begin
  //не заходил! добавляем его ссылку!
  UserOnLineLI := TChatLine(self.FLine).ChatLineView.AddLink(
                                        Ord(ltNICK),
                                        FormMain.OnLinkMouseMoveProcessing,
                                        FormMain.OnLinkMouseUpProcessing,
                                        UserOnLineFS,
                                        UserOnLineMouseOverFS,
                                        ComputerName);
  {i := }TChatLine(self.FLine).UsersConnectHistory.AddObject(self.FComputerName, UserOnLineLI);
  end
else
  begin
  //юзер уже один раз заходи в чат и его ссылка уже добавлена!
  UserOnLineLI := TLinkInfo(TChatLine(self.FLine).UsersConnectHistory.Objects[i]);
  //прокачиваем стили (были OffLine, стали снова индивидуальные)
  UserOnLineLI.LinkStyle := UserOnLineFS;
  UserOnLineLI.MouseOverLinkStyle := UserOnLineMouseOverFS;
  TChatLine(self.FLine).ChatLineView.UpDateLink(UserOnLineLI);
  end;

if IniUserConfigFile.SectionExists('UserNickNames') then //Читаем список ников
  IniUserConfigFile.ReadSectionValues('UserNickNames', FUserNickNames);

//FormMain.Caption := UserOnLineLI.LinkText;
StringList.free;
FontInfoSave.Free;
end;

procedure TChatUser.SaveUserSettingsToIni();
var IniUserConfig: TMemIniFile;
    StringList, TempIniStringList: TStringList;
    FontInfoSave: TTXTStyle;
    n, i: integer;
    LinkInfo: TLinkInfo;
begin
IniUserConfig := TMemIniFile.Create(TPathBuilder.GetUsersFolderName {ExePath + 'Users\'} + FUserConfigFileName + '.txt');
IniUserConfig.WriteString('TChatUser', 'ComputerName', Self.ComputerName);
IniUserConfig.WriteInteger('TChatUser', 'CheckNodeStates', Word(Self.CN_State));
IniUserConfig.WriteBool('TChatUser', 'Ignored', Ignored);

//загружаем раздел [UserOnLineFS] из конфига юзера в компонент CVStyle
FontInfoSave := TTXTStyle.Create(nil);
StringList := TStringList.Create;
TempIniStringList := TStringList.Create;

//сохраняем каждый раз весь INI! а должны только одну секцию в конец дописывать!

FontInfoSave.TextStyles.Add;
//=========== [UserOnLineFS] =================
FontInfoSave.TextStyles.Items[0].Assign(UserOnLineFS);
//получаем "чистую секцию" без заголовков OBJECT и END
StringList.Text := FontInfoSave.GetTXTStyleItems(0);
StringList.Insert(0, '[UserOnLineFS]');
//сохраняем ее в секцию INI
IniUserConfig.EraseSection('UserOnLineFS');
IniUserConfig.GetStrings(TempIniStringList);
TempIniStringList.AddStrings(StringList);
//IniUserConfig.Clear;
IniUserConfig.SetStrings(TempIniStringList);
TempIniStringList.Clear;
//=========== [UserOnLineMouseOverFS] =================
//UserOnLineMouseOverFS.Size := 12;
FontInfoSave.TextStyles.Items[0] := UserOnLineMouseOverFS;
//получаем "чистую секцию" без заголовков OBJECT и END
StringList.Text := FontInfoSave.GetTXTStyleItems(0);
StringList.Insert(0, '[UserOnLineMouseOverFS]');
//сохраняем ее в секцию INI
IniUserConfig.EraseSection('UserOnLineMouseOverFS');
IniUserConfig.GetStrings(TempIniStringList);
TempIniStringList.AddStrings(StringList);
//IniUserConfig.Clear;
IniUserConfig.SetStrings(TempIniStringList);
TempIniStringList.Clear;

//=========== [UserOffLineFS] =================
{FontInfoSave.TextStyles.Items[0] := UserOffLineFS;
//получаем "чистую секцию" без заголовков OBJECT и END
StringList.Text := FontInfoSave.GetTXTStyleItems(0);
StringList.Insert(0, '[UserOffLineFS]');
//сохраняем ее в секцию INI
IniUserConfig.EraseSection('UserOffLineFS');
IniUserConfig.GetStrings(TempIniStringList);
TempIniStringList.AddStrings(StringList);
//IniUserConfig.Clear;
IniUserConfig.SetStrings(TempIniStringList);
TempIniStringList.Clear;}

// -----------------------------------

//когда юзер уходит, мы не удаляем его ссылку из массива ссылок, а меняем стиль
//ссылки на OffLine и сохраняем в писке UsersConnectHistory имя компьютера юзера,
//чью ссылку мы сохранили, чтобы при повторном заходе он не делал AddLink
//а взял созданную до этого свою ссылку и заново залил в нее свои личные стили.
i := TChatLine(self.FLine).UsersConnectHistory.IndexOf(self.FComputerName);
if i < 0 then
  {i := }TChatLine(self.FLine).UsersConnectHistory.AddObject(self.FComputerName, UserOnLineLI);

//не надо удалять ссылку! надо просто изменить ее стили на OffLine!
//TChatLine(FLine).ChatLineView.DeleteLink(UserOnLineLI, TFontInfo(TChatLine(self.FLine).UsersConnectHistory.Objects[i]));
if TChatLine(self.FLine).ChatLineView <> nil then
  begin
  if TChatLine(FLine).ChatLineView.LinksInfo <> nil then
    begin
    //self.UserOnLineFS := TFontInfo(TChatLine(self.FLine).UsersConnectHistory.Objects[i]);
    //self.UserOnLineMouseOverFS := TFontInfo(TChatLine(self.FLine).UsersConnectHistory.Objects[i]);
    for n := 0 to TChatLine(FLine).ChatLineView.LinksInfo.Count - 1 do
      begin
      if TLinkInfo(TChatLine(FLine).ChatLineView.LinksInfo.Objects[n]) = UserOnLineLI then
        begin
        //нашли ссылку юзера в общем массиве ссылок
        LinkInfo := TLinkInfo(TChatLine(FLine).ChatLineView.LinksInfo.Objects[n]);
        LinkInfo.LinkStyle := FormMain.CVStyle1.TextStyles.Items[USEROFFLINENICKSTYLE];
        LinkInfo.MouseOverLinkStyle := FormMain.CVStyle1.TextStyles.Items[USEROFFLINENICKSTYLE];
        //удаляем стили юзера из CVStyle1
        TChatLine(self.FLine).ChatLineView.UpDateLink(LinkInfo);
        //TChatLine(self.FLine).ChatLineView.Format;
        //TChatLine(self.FLine).ChatLineView.repaint;
        FormMain.CVStyle1.DeleteTextStyle(self.UserOnLineFS.Index);
        FormMain.CVStyle1.DeleteTextStyle(self.UserOnLineMouseOverFS.Index);
        break;
        end;
      end;
    end;
  end;

//Обновляем список использовавшихся ников
FUserNickNames.Insert(0, '[UserNickNames]');
IniUserConfig.EraseSection('UserNickNames');
IniUserConfig.GetStrings(TempIniStringList);
TempIniStringList.AddStrings(FUserNickNames);
IniUserConfig.SetStrings(TempIniStringList);

IniUserConfig.UpdateFile;
TempIniStringList.Free;
IniUserConfig.Free;
StringList.Free;
FontInfoSave.Free // roma: fix for memory leak
end;

procedure TChatUser.SetDisplayNickName(const Value: String);
begin
  FDisplayNickName := Value;
  //Если текущего ника нет в списоке использовавшихся ников, то добавляем его
  if FUserNickNames.IndexOf(Trim(FDisplayNickName))<0 then
    FUserNickNames.Insert(0, Trim(FDisplayNickName));
end;

{ TConfigChatUser }

constructor TConfigChatUser.Create;
begin
  FChanged := False;
  FUserOnLineFS := TFont.Create;
  FUserOnLineFS.OnChange := FontChanged;
  FUserOnLineMouseOverFS := TFont.Create;
  FUserOnLineMouseOverFS.OnChange := FontChanged;
  UserNickNames := TStringList.Create;
end;

destructor TConfigChatUser.Destroy;
begin
  FUserOnLineFS.Free;
  FUserOnLineMouseOverFS.Free;
  UserNickNames.Free;
  inherited;
end;

function TConfigChatUser.GetAllNicks: string;
begin
Result:=StringReplace(UserNickNames.Text, #13#10, ' ', [rfReplaceAll]);
end;

function TConfigChatUser.GetLastNick: string;
begin
if UserNickNames.Text<>'' then
  Result:=UserNickNames.Strings[0]
else
  Result:='';
end;

function TConfigChatUser.GetSoundFileName(SoundName: string): string;
begin
result := SoundName;
if (length(SoundName) > 0) and (ExtractFileDrive(SoundName) = '') then
    result := ExcludeTrailingBackslash(TPathBuilder.GetExePath()) + SoundName;
if not FileExists(result) then
  result := '';
end;

procedure TConfigChatUser.LoadUserSettingsFromIni(IniUserConfigFile: TMemIniFile);
var FontInfoSave :TTXTStyle;
    StringList: TStringList;
begin
  Self.FSoundDisconnect := GetSoundFileName(IniUserConfigFile.ReadString('Sound', 'Disconnect', ''));
  Self.FSoundText := GetSoundFileName(IniUserConfigFile.ReadString('Sound', 'Text', ''));
  Self.FSoundConnect := GetSoundFileName(IniUserConfigFile.ReadString('Sound', 'Connect', ''));
  Self.FSoundAlert := GetSoundFileName(IniUserConfigFile.ReadString('Sound', 'Alert', ''));
  Self.FSoundAlertToAll := GetSoundFileName(IniUserConfigFile.ReadString('Sound', 'AlertToAll', ''));
  Self.FSoundReceived := GetSoundFileName(IniUserConfigFile.ReadString('Sound', 'Received', ''));
  Self.FSoundStatus := GetSoundFileName(IniUserConfigFile.ReadString('Sound', 'Status', ''));
  Self.FSoundBoard := GetSoundFileName(IniUserConfigFile.ReadString('Sound', 'Board', ''));
  Self.FSoundRefresh := GetSoundFileName(IniUserConfigFile.ReadString('Sound', 'Refresh', ''));
  Self.FSoundRename := GetSoundFileName(IniUserConfigFile.ReadString('Sound', 'Rename', ''));
  Self.FSoundCreate := GetSoundFileName(IniUserConfigFile.ReadString('Sound', 'Create', ''));
  Self.FSoundFindLine := GetSoundFileName(IniUserConfigFile.ReadString('Sound', 'FindLine', ''));

  //загружаем раздел [UserOnLineFS] из конфига юзера в компонент CVStyle
  FontInfoSave := TTXTStyle.Create(nil);
  StringList := TStringList.Create;
  //если не находим стили в файле юзера, берем их из дефолтового конфига
  if IniUserConfigFile.SectionExists('UserOnLineFS') then
    IniUserConfigFile.ReadSectionValues('UserOnLineFS', StringList)
  else
    FormMain.DefaultUser.ReadSectionValues('UserOnLineFS', StringList);
  FontInfoSave.SetStyleItems(0, StringList.Text);
  FontInfoToFont( FontInfoSave.TextStyles.Items[0], FUserOnLineFS);
  //--------------
  if IniUserConfigFile.SectionExists('UserOnLineMouseOverFS') then
    IniUserConfigFile.ReadSectionValues('UserOnLineMouseOverFS', StringList)
  else
    FormMain.DefaultUser.ReadSectionValues('UserOnLineMouseOverFS', StringList);
  IniUserConfigFile.ReadSectionValues('UserOnLineMouseOverFS', StringList);
  FontInfoSave.SetStyleItems(0, StringList.Text);
  FontInfoToFont( FontInfoSave.TextStyles.Items[0], FUserOnLineMouseOverFS);
  //--------------

  if IniUserConfigFile.SectionExists('UserNickNames') then //Читаем список ников
    IniUserConfigFile.ReadSectionValues('UserNickNames', UserNickNames);

  StringList.free;
  FontInfoSave.Free;
end;

procedure TConfigChatUser.SaveUserSettingsToIni(var IniUserConfigFile: TMemIniFile);
var StringList, TempIniStringList: TStringList;
    FontInfoSave: TTXTStyle;
begin
  IniUserConfigFile.WriteString( 'Sound', 'Alert', SetSoundFileName(Self.FSoundAlert));
  IniUserConfigFile.WriteString( 'Sound', 'AlertToAll', SetSoundFileName(Self.FSoundAlertToAll));
  IniUserConfigFile.WriteString( 'Sound', 'Board', SetSoundFileName(Self.FSoundBoard));
  IniUserConfigFile.WriteString( 'Sound', 'Connect', SetSoundFileName(Self.FSoundConnect));
  IniUserConfigFile.WriteString( 'Sound', 'Disconnect', SetSoundFileName(Self.FSoundDisconnect));
  IniUserConfigFile.WriteString( 'Sound', 'Text', SetSoundFileName(Self.FSoundText));
  IniUserConfigFile.WriteString( 'Sound', 'Rename', SetSoundFileName(Self.FSoundRename));
  IniUserConfigFile.WriteString( 'Sound', 'Status', SetSoundFileName(Self.FSoundStatus));
  IniUserConfigFile.WriteString( 'Sound', 'FindLine', SetSoundFileName(Self.FSoundFindLine));
  IniUserConfigFile.WriteString( 'Sound', 'Create', SetSoundFileName(Self.FSoundCreate));
  IniUserConfigFile.WriteString( 'Sound', 'Received', SetSoundFileName(Self.FSoundReceived));
  IniUserConfigFile.WriteString( 'Sound', 'Refresh', SetSoundFileName(Self.FSoundRefresh));

  //загружаем раздел [UserOnLineFS] из конфига юзера в компонент CVStyle
  FontInfoSave := TTXTStyle.Create(nil);
  StringList := TStringList.Create;
  TempIniStringList := TStringList.Create;

  FontInfoSave.TextStyles.Add;
  //=========== [UserOnLineFS] =================
  FontInfoSave.TextStyles.Items[0].CharSet:=FUserOnLineFS.Charset;
  FontInfoSave.TextStyles.Items[0].FontName:=FUserOnLineFS.Name;
  FontInfoSave.TextStyles.Items[0].Size:=FUserOnLineFS.Size;
  FontInfoSave.TextStyles.Items[0].Color:=FUserOnLineFS.Color;
  FontInfoSave.TextStyles.Items[0].Style:=FUserOnLineFS.Style;
  //получаем "чистую секцию" без заголовков OBJECT и END
  StringList.Text := FontInfoSave.GetTXTStyleItems(0);
  StringList.Insert(0, '[UserOnLineFS]');
  //сохраняем ее в секцию INI
  IniUserConfigFile.EraseSection('UserOnLineFS');
  IniUserConfigFile.GetStrings(TempIniStringList);
  TempIniStringList.AddStrings(StringList);
  IniUserConfigFile.SetStrings(TempIniStringList);
  TempIniStringList.Clear;
  //=========== [UserOnLineMouseOverFS] =================
  FontInfoSave.TextStyles.Items[0].CharSet:=FUserOnLineMouseOverFS.Charset;
  FontInfoSave.TextStyles.Items[0].FontName:=FUserOnLineMouseOverFS.Name;
  FontInfoSave.TextStyles.Items[0].Size:=FUserOnLineMouseOverFS.Size;
  FontInfoSave.TextStyles.Items[0].Color:=FUserOnLineMouseOverFS.Color;
  FontInfoSave.TextStyles.Items[0].Style:=FUserOnLineMouseOverFS.Style;
  //получаем "чистую секцию" без заголовков OBJECT и END
  StringList.Text := FontInfoSave.GetTXTStyleItems(0);
  StringList.Insert(0, '[UserOnLineMouseOverFS]');
  //сохраняем ее в секцию INI
  IniUserConfigFile.EraseSection('UserOnLineMouseOverFS');
  IniUserConfigFile.GetStrings(TempIniStringList);
  TempIniStringList.AddStrings(StringList);
  IniUserConfigFile.SetStrings(TempIniStringList);
  TempIniStringList.Clear;

  IniUserConfigFile.UpdateFile;
  TempIniStringList.Free;
  StringList.Free;
  FontInfoSave.Free;
end;

procedure TConfigChatUser.SetSoundAlert(const Value: String);
begin
  if FSoundAlert<>Value then
  begin
    FSoundAlert := Value;
    FChanged:=True;
  end;
end;

procedure TConfigChatUser.SetSoundAlertToAll(const Value: String);
begin
  if FSoundAlertToAll<>Value then
  begin
    FSoundAlertToAll := Value;
    FChanged:=True;
  end;
end;

procedure TConfigChatUser.SetSoundBoard(const Value: String);
begin
  if FSoundBoard<>Value then
  begin
    FSoundBoard := Value;
    FChanged:=True;
  end;
end;

procedure TConfigChatUser.SetSoundConnect(const Value: String);
begin
  if FSoundConnect<>Value then
  begin
    FSoundConnect := Value;
    FChanged:=True;
  end;
end;

procedure TConfigChatUser.SetSoundCreate(const Value: String);
begin
  if FSoundCreate<>Value then
  begin
    FSoundCreate := Value;
    FChanged:=True;
  end;
end;

procedure TConfigChatUser.SetSoundDisconnect(const Value: String);
begin
  if FSoundDisconnect<>Value then
  begin
    FSoundDisconnect := Value;
    FChanged:=True;
  end;
end;

function TConfigChatUser.SetSoundFileName(SoundPath: string): string;
begin
  Result:='';
  if FileExists(SoundPath) then
  begin
    if pos(uppercase(TPathBuilder.GetExePath()), uppercase(SoundPath)) = 1 then
      //если начало пути совпадает с рабочей папкой чата
      //записываем короткий, относительный путь
      Result:=copy(SoundPath, length(TPathBuilder.GetExePath()), length(SoundPath))
    else
      Result:=SoundPath;
  end;
end;

procedure TConfigChatUser.SetSoundFindLine(const Value: String);
begin
  if FSoundFindLine<>Value then
  begin
    FSoundFindLine := Value;
    FChanged:=True;
  end;
end;

procedure TConfigChatUser.SetSoundReceived(const Value: String);
begin
  if FSoundReceived<>Value then
  begin
    FSoundReceived := Value;
    FChanged:=True;
  end;
end;

procedure TConfigChatUser.SetSoundRefresh(const Value: String);
begin
  if FSoundRefresh<>Value then
  begin
    FSoundRefresh := Value;
    FChanged:=True;
  end;
end;

procedure TConfigChatUser.SetSoundRename(const Value: String);
begin
  if FSoundRename<>Value then
  begin
    FSoundRename := Value;
    FChanged:=True;
  end;
end;

procedure TConfigChatUser.SetSoundStatus(const Value: String);
begin
  if FSoundStatus<>Value then
  begin
    FSoundStatus := Value;
    FChanged:=True;
  end;
end;

procedure TConfigChatUser.SetSoundText(const Value: String);
begin
  if FSoundText<>Value then
  begin
    FSoundText := Value;
    FChanged:=True;
  end;
end;

procedure TConfigChatUser.FontChanged(Sender: TObject);
begin
  FChanged:=True;
end;

end.
