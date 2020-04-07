unit ULineNode;

interface
uses classes, UChatLine, VirtualTrees;

type
TLineState = (LS_LineAtRemoteUser, LS_LineObjectCreated);

//этот класс описывает линии-узлы дерева, которые выводятся в дереве пользователей
//при раскрытии [+] у юзера. Т.е. это те линии в которых учавствует или
//учавствовал юзер. Серьезно к этому списку относиться нельзя, поэтому
//он отделен от списка Form1.ChatLines и никакого отношения к нему не имеет.
//Зачем это сделано? Допустим мы получаем из сети сообщение REFRESH с именем
//линии которая до сих пор была не известна. Мы знаем кто это сообщение прислал
//и сразу заносим ее в список линий этого пользователя.

type
  TLineNode = class (TPersistent)
  private
    FLineName     		     :String;
    FLineId                :cardinal;//ID линии в списке линий юзера владельца
    FDisplayLineName     	 :String;
    FCreatedByCommand    	 :String;
    FLineOwner   		       :String;//имя юзера, которому принадлежит линия
    FLineOwnerID   	       :cardinal;//ID юзера, которому принадлежит линия
{    FNickName			       :String;
    FDisplayNickName		   :String;
    FLogin                 :String;
    FIP           		     :String;}
    FVersion		        	 :String;
    FLineUsers             :TStringList;
    FLastRefreshMessNumber :cardinal;
    FTimeCreate            :TDateTime;
    FTimeOfLastMess     	 :cardinal;
    FReceivedMessCount  	 :cardinal;
    FLastReceivedMessNumber:cardinal;//чтобы не приходили ложные сообщения! (как у автора)
    FLineType              :TLineType;
    FLineState             :TLineState;
    FIsExpanded            :boolean;
    FVirtualNode           :PVirtualNode;
  protected
  public
    property LineName        :String read FLineName write FLineName;
    property LineID          :cardinal read FLineID write FLineID;
    property DisplayLineName :String read FDisplayLineName write FDisplayLineName;
    property CreatedByCommand:String read FCreatedByCommand write FCreatedByCommand;
    property LineOwner 		   :String read FLineOwner write FLineOwner;
    property LineOwnerID 	   :cardinal read FLineOwnerID write FLineOwnerID;
{    property NickName			 :String read FNickName write FNickName;
    property DisplayNickName :String read FDisplayNickName write FDisplayNickName;//отображаем в дереве не NickName, а DisplayNickName
                                        //это на случай если у двух челов одинаковый ник, мы их отображаем в виде DisplayNickName = ComputerName_NickName
    property Login           :String read FLogin write FLogin;
    property IP           	 :String read FIP write FIP;
}
    property Version			   :String read FVersion write FVersion;
    property LineUsers       :TStringList read FLineUsers write FLineUsers;
    property TimeCreate      :TDateTime read FTimeCreate write FTimeCreate;
    property TimeOfLastMess  :cardinal read FTimeOfLastMess write FTimeOfLastMess;
    property ReceivedMessCount     :cardinal read FReceivedMessCount write FReceivedMessCount;
    property LastReceivedMessNumber:cardinal read FLastReceivedMessNumber write FLastReceivedMessNumber;//чтобы не приходили ложные сообщения! (как у автора)
    property LastRefreshMessNumber :cardinal read FLastRefreshMessNumber write FLastRefreshMessNumber;//т.к.
    property LineType 			       :TLineType read FLineType write FLineType;
    property LineState 			       :TLineState read FLineState write FLineState;
    property IsExpanded 	         :boolean read FIsExpanded write FIsExpanded;
    property VirtualNode 	         :PVirtualNode read FVirtualNode write FVirtualNode;

    procedure Assign(Source: TPersistent);override;{virtual;}
    constructor Create(Line_Name:String; Line_State:TLineState); {override;}
    destructor Destroy; override;
  published
  end;

  PLineNode = ^TLineNode;

implementation

uses SysUtils;

{-------------------------------------}
constructor TLineNode.Create(Line_Name:String; Line_State:TLineState);
begin
//TLineType = (LT_COMMON, LT_PRIVATE_CHAT, LT_COMMON_LINE);
//сделать передачу параметра! LOCALUSER|REMOTEUSER
//чтобы сразу при создании вкачивать в него инфу!
  inherited Create();
  FLineUsers   := TStringList.Create;
  FLineName    := Line_Name;
{  if (LineName = 'iTCniaM') or (LineName = '*') then
    FLineType := LT_COMMON
  else
    FLineType := Line_Type;}
  FLineState         := Line_State;
  FIsExpanded        := false;
  FVirtualNode       := nil;
end;
{-------------------------------------}
destructor TLineNode.Destroy;
begin
  FreeAndNil(FLineUsers);
  inherited Destroy;
end;
{-------------------------------------}

procedure TLineNode.Assign(Source: TPersistent);
begin
  if Source is TLineNode then
    begin
    Self.FLineName := TLineNode(Source).FLineName;
    Self.FDisplayLineName := TLineNode(Source).FDisplayLineName;
    Self.FCreatedByCommand := TLineNode(Source).FCreatedByCommand;
    Self.FLineOwner := TLineNode(Source).FLineOwner;
    //Self.FNickName := TLineNode(Source).FNickName;
    //Self.FDisplayNickName := TLineNode(Source).FDisplayNickName;
    //Self.FLogin := TLineNode(Source).FLogin;
    //Self.FIP := TLineNode(Source).FIP;
    Self.FVersion := TLineNode(Source).FVersion;
    Self.FLastRefreshMessNumber := TLineNode(Source).FLastRefreshMessNumber;
    Self.FTimeCreate := TLineNode(Source).FTimeCreate;
    Self.FTimeOfLastMess := TLineNode(Source).FTimeOfLastMess;
    Self.FReceivedMessCount := TLineNode(Source).FReceivedMessCount;
    Self.FLastReceivedMessNumber := TLineNode(Source).FLastReceivedMessNumber;
    Self.FLineUsers.Assign(TLineNode(Source).FLineUsers);
    Self.FLineType := TLineNode(Source).FLineType;
    Self.FLineState := TLineNode(Source).FLineState;
    Self.FIsExpanded := TLineNode(Source).FIsExpanded;
    Self.FVirtualNode := TLineNode(Source).FVirtualNode;
    end
  else
    inherited Assign(Source);
end;

end.
