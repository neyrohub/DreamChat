unit uGifVirtualStringTree;

interface

uses
   Windows, SysUtils, Classes, Graphics, controls, LiteGIFX2, Menus,
   VirtualTrees, VTHeaderPopup, uFormUserInfo,
   uChatUser;

//ver  0.23

//помним, что в этом дереве данные связаны с узлом через указатель
//т.е. данные храняться отдельно от узла в структуре или объекте.
//Память под структуру данных дерево выделяет само (!) при передаче ей типа данных!
//в нашем случае тип данных TDataNode.

type
  TGifVirtualStringTree = class(TVirtualStringTree)
    procedure GifVirtualStringTreeGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure GifVirtualStringTreeAfterCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellRect: TRect);
    procedure GifVirtualStringTreeMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure GifVirtualStringTreeCompareNodes(Sender: TBaseVirtualTree;
      Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);

    procedure GifVirtualStringTreePaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure GifVirtualStringTreeScroll(Sender: TBaseVirtualTree; DeltaX,
      DeltaY: Integer);
    procedure GifVirtualStringTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GifVirtualStringTreeKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GifVirtualStringTreeKeyPress(Sender: TObject; var Key: Char);
{    procedure DefineProperties(Filer: TFiler);
    procedure LoadCompProperty(Reader: TReader);
    procedure StoreCompProperty(Writer: TWriter);}
  private
    { Private declarations }
    ApplicationPath: string;
    FTreeLinesWidth: word;
    FParentChatLine: TObject;
  public
    { Public declarations }
    ColumnWidth:word;
    FocusedNodeIndex: cardinal;
    HScrollPos: Integer;
    VScrollPos: Integer;
    property TreeLinesWidth : word read FTreeLinesWidth write FTreeLinesWidth;

    //procedure Clear;override;
    procedure ScrollToXY(x, y:integer);
    constructor CreateGVST(ParentChatLine:TObject;AComponent:TComponent; GifFilePath:String);virtual;{override;}
    destructor Destroy;{virtual;}override;
    FUNCTION ComponentToString(Component: TComponent): string;
  end;

  TDataType = (dtUser, dtCommon, dtPrivateChat, dtLine);

  TDataNode =  record
    User       : TChatUser;
//  DataUserId : cardinal;//ID  узера или другого объекта в зависимости от типа узла
    DataType   : TDataType;//тип узла в дереве
    LineNode   : TObject;//LineNode;
//  DataLineId : cardinal;//это сделано чтобы вывести название линии
                          //иначе не отличить названия 2х разных линий
  //AbsoluteNodeIndex: cardinal;//Используется для быстрого поиска узла
                              //Это индекс узла в дереве
  end;

  PDataNode = ^TDataNode;

implementation

uses
  uFormMain, uChatLine, ULineNode, DreamChatConfig, uImageLoader, uPathBuilder;

{procedure TGifVirtualStringTree.LoadCompProperty(Reader: TReader);
begin
    self.TreeLinesWidth := Reader.ReadInteger;
end;

procedure TGifVirtualStringTree.StoreCompProperty(Writer: TWriter);
begin
  Writer.WriteString(inttostr(self.TreeLinesWidth));
end;

procedure TGifVirtualStringTree.DefineProperties(Filer: TFiler);
  function DoWrite: Boolean;
  begin
    if Filer.Ancestor <> nil then
    begin
      if (TGifVirtualStringTree(Filer.Ancestor).TreeLinesWidth = nil) then
        Result := true
      else if TreeLinesWidth = nil or
         TGifVirtualStringTree(Filer.Ancestor).TreeLinesWidth.Name <> TreeLinesWidth.Name then
        Result := True

      else Result := False;
    end
    else
      Result := TreeLinesWidth <> nil;
  end;
begin
  inherited;
  Filer.DefineProperty('TreeLinesWidth', LoadCompProperty, StoreCompProperty, DoWrite);
end;}

constructor TGifVirtualStringTree.CreateGVST(ParentChatLine:TObject; AComponent:TComponent;GifFilePath:String);
var
    MS: TMemoryStream;
begin
  inherited Create(AComponent);
  ApplicationPath := GifFilePath;

  Self.FParentChatLine := ParentChatLine;
  Self.OnGetText := GifVirtualStringTreeGetText;
  Self.OnAfterCellPaint := GifVirtualStringTreeAfterCellPaint;
  //Self.OnMouseDown := GifVirtualStringTreeMouseDown;//берется из CLGifVTree.txt
  //Self.OnMouseUp := GifVirtualStringTreeMouseDown;//берется из CLGifVTree.txt
  Self.OnCompareNodes := GifVirtualStringTreeCompareNodes;
  Self.OnScroll := GifVirtualStringTreeScroll;
  Self.OnPaintText := GifVirtualStringTreePaintText;
  Self.OnKeyPress := GifVirtualStringTreeKeyPress;
  Self.OnKeyDown := GifVirtualStringTreeKeyDown;
  Self.OnKeyUp := GifVirtualStringTreeKeyUp;
  FTreeLinesWidth := 18;
  FocusedNodeIndex := 0;
end;

destructor TGifVirtualStringTree.Destroy;
var
  srtlist: TStringList;
  MainLine: TChatLine;
begin
MainLine := FormMain.GetMainLine();
if FParentChatLine = MainLine then
  begin
  //если это дерево главной формы, сохраняем настройки дерева в главной линии
  self.clear;
  self.NodeDataSize := 0;
  self.RootNodeCount := 0;
  self.Header.Columns.Delete(0);
  srtlist := TStringList.Create;
  srtlist.Text := self.ComponentToString(MainLine.ChatLineTree);
  srtlist.SaveToFile(TPathBuilder.GetComponentsFolderName() + {ApplicationPath + 'components\} 'CLGifVTree.txt');
  srtlist.Free;
  end;

inherited Destroy();
end;

FUNCTION TGifVirtualStringTree.ComponentToString(Component: TComponent): string;
var
  ms: TMemoryStream;
  ss: TStringStream;
  posit: Longint;
begin
  ss := TStringStream.Create(' ');
  ms := TMemoryStream.Create;
  try
    ms.WriteComponent(Component);
    ms.position := 0;
    ObjectBinaryToText(ms, ss);
    ss.position := 0;
    posit := pos('  object', ss.DataString);
    if posit > 0 then
      begin
      Result := ss.ReadString(posit - 2);
      Result := Result + 'end';//+ #13#10
      end
    else
      Result := ss.DataString;
  finally
    ms.Free;
    ss.free;
  end;
end;

procedure TGifVirtualStringTree.GifVirtualStringTreeKeyPress(Sender: TObject; var Key: Char);
begin
//Form1.Caption := Key;
end;

procedure TGifVirtualStringTree.GifVirtualStringTreeKeyDown(Sender: TObject; var Key: Word;
    Shift: TShiftState);
var
    //PDNode: PDataNode;
    //Node: PVirtualNode;
    ActiveChatLine:TChatLine;
begin
ActiveChatLine := FormMain.GetActiveChatLine();
if (ActiveChatLine <> nil) then
  begin
  if (ssCtrl in Shift) then
    begin
    //если нажата клавиша CTRL
    if (lo(Key) = VK_HOME) then
      begin
      //CTRL + HOME
      ActiveChatLine.ChatLineView.Perform($0100, VK_HOME, 0);//WM_KEYDOWN
      end;
    if (lo(Key) = VK_END) then
      begin
      //CTRL + END
      ActiveChatLine.ChatLineView.Perform($0100, VK_END, 0);//WM_KEYDOWN
      end;
    if (lo(Key) = VK_NEXT) then
      begin
      //CTRL + PGDOWN
      ActiveChatLine.ChatLineView.Perform($0100, VK_NEXT, 0);//WM_KEYDOWN
      end;
    if (lo(Key) = VK_PRIOR) then
      begin
      //CTRL + PGUP
      ActiveChatLine.ChatLineView.Perform($0100, VK_PRIOR, 0);//WM_KEYDOWN
      end;
    end;
  end;
end;

procedure TGifVirtualStringTree.GifVirtualStringTreeKeyUp(Sender: TObject; var Key: Word;
    Shift: TShiftState);
var  PDNode: PDataNode;
     Node: PVirtualNode;
begin
//Form1.Caption := inttostr(Key);
//Form1.Caption := inttostr(Key);
if (Key = VK_UP) or (Key = VK_DOWN) or (Key = VK_NEXT) or (Key = VK_PRIOR) then
  begin
  Node := self.FocusedNode;
  if Node <> nil then
    begin
    PDNode := Self.GetNodeData(Node);
    FocusedNodeIndex := Node.Index;
    //FormUI.GetUserInfo(TChatLine(FParentChatLine), PDNode.DataUserId);
    FormUI.GetUserInfo(TChatLine(FParentChatLine), PDNode.User);
    end;
  end;
end;

procedure TGifVirtualStringTree.GifVirtualStringTreeAfterCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  CellRect: TRect);
var
  rect1, rect2:TRect;
  n, NodeLevel1{, NodeTempLevel}:integer;
  NodeTemp:PVirtualNode;
  PDNode:PDataNode;
begin
//PDNode := VirtualStringTree1.GetNodeData(Node);
NodeLevel1 := Self.GetNodeLevel(Node);
  rect1.TopLeft.x := CellRect.TopLeft.x +
                    (Self.Indent {- 16}) * NodeLevel1 {+
                    Self.Margin div 2};
  rect1.TopLeft.y := CellRect.TopLeft.y{ -(VirtualStringTree1.OffsetY)};

  rect1.BottomRight.x := rect1.TopLeft.x + TDreamChatImageLoader.GetImage(G_USER1).Width;
  rect1.BottomRight.y := rect1.TopLeft.y + TDreamChatImageLoader.GetImage(G_USER1).Height;

if not (toShowButtons in Self.TreeOptions.PaintOptions) then
  begin
  if (Node.PrevSibling = nil) and (NodeLevel1 = 0) and
     (Node.ChildCount > 0) then
    begin
    if (Self.Expanded[Node] = false) then
      begin
      //
      //[+]
      // |
      TargetCanvas.Draw(Rect1.Left, Rect1.Top, TDreamChatImageLoader.GetImage(G_FIRSTPLUS).Bitmap[0]);
      end;
    if (Self.Expanded[Node] = true) then
      begin
      //
      //[-]
      // |
      TargetCanvas.Draw(Rect1.Left, Rect1.Top, TDreamChatImageLoader.GetImage(G_FIRSTMINUS).Bitmap[0]);
      end;
    if (Node.NextSibling = nil) then
      begin
      if (Self.Expanded[Node] = true) then
        begin
        //
        //[-]-
        //
        TargetCanvas.Draw(Rect1.Left, Rect1.Top, TDreamChatImageLoader.GetImage(G_ONEMINUS).Bitmap[0]);
        end
      else
        begin
        //
        //[+]-
        //
        TargetCanvas.Draw(Rect1.Left, Rect1.Top, TDreamChatImageLoader.GetImage(G_ONEPLUS).Bitmap[0]);
        end;
      end;
    end
  else
    begin
    if (Node.NextSibling <> nil) and
      (Node.ChildCount > 0) and
      (Self.Expanded[Node] = false) then
      begin
      // |
      //[+]-
      // |
      TargetCanvas.Draw(Rect1.Left, Rect1.Top, TDreamChatImageLoader.GetImage(G_MIDDLEPLUS).Bitmap[0]);
      end;
    if (Node.NextSibling <> nil) and
      (Node.ChildCount > 0) and
      (Self.Expanded[Node] = true) then
      begin
      // |
      //[-]-
      // |
      TargetCanvas.Draw(Rect1.Left, Rect1.Top, TDreamChatImageLoader.GetImage(G_MIDDLEMINUS).Bitmap[0]);
      end;

    if (Node.NextSibling = nil) and
      (Node.ChildCount > 0) and
      (Self.Expanded[Node] = false) then
      begin
      // |
      //[+]-
      //
      TargetCanvas.Draw(Rect1.Left, Rect1.Top, TDreamChatImageLoader.GetImage(G_LASTPLUS).Bitmap[0]);
      end;
    if (Node.NextSibling = nil) and
      (Node.ChildCount > 0) and
      (Self.Expanded[Node] = true) then
      begin
      // |
      //[-]-
      //
      TargetCanvas.Draw(Rect1.Left, Rect1.Top, TDreamChatImageLoader.GetImage(G_LASTMINUS).Bitmap[0]);
      end;
    end;
end;

if not (toShowTreeLines in Self.TreeOptions.PaintOptions) then
  begin
  if (Node.ChildCount = 0) then
    begin
    if (Node.PrevSibling = nil) and
      (NodeLevel1 = 0) and (Node.NextSibling <> nil) then
      begin
      //
      // +-
      // |
      //вообще прозрачность должна быть установлена в самом GIF,
      //но если ее там нет, то мы может принудительно назначить прозрачный цвет
      //перед выводом на канвас
      //TDreamChatImageLoader.GetImage(G_FIRSTLINE].Bitmap[0].Mask(RGB(255,255,255));
      TargetCanvas.Draw(Rect1.Left, Rect1.Top, TDreamChatImageLoader.GetImage(G_FIRSTLINE).Bitmap[0]);
      end;

    if (Node.NextSibling = nil) then
      begin
      // |
      // +-
      //
      TargetCanvas.Draw(Rect1.Left, Rect1.Top, TDreamChatImageLoader.GetImage(G_LASTLINE).Bitmap[0]);
      end;

    if (((NodeLevel1 = 0) and (Node.PrevSibling <> nil) and (Node.NextSibling <> nil)) or
      ((NodeLevel1 > 0) and (Node.NextSibling <> nil))) then
      begin
      // |
      // +-
      // |
      TargetCanvas.Draw(Rect1.Left, Rect1.Top, TDreamChatImageLoader.GetImage(G_MIDDLELINE).Bitmap[0]);
      end;
    end;
  //когда дерево раскрыто, нужно нарисовать вертикальную(ые) линию(ии) перед плюсом
  //|[-]-+--[node]
  //| | [+]-[node]
  //| |  +--[node]
  //| |
  //^-^---вот здесь
  NodeTemp := Node;
  for n := (NodeLevel1 - 1) downto 0 do
    begin
    NodeTemp := NodeTemp.Parent;
    if (NodeTemp <> nil) then
      begin
      if (NodeTemp.NextSibling <> nil) then
        begin
        rect2.TopLeft.y := CellRect.TopLeft.y;
        rect2.BottomRight.y := rect2.TopLeft.y + TDreamChatImageLoader.GetImage(G_FIRSTLINE).Height;
        rect2.TopLeft.x := CellRect.TopLeft.x +
                           (Self.Indent) * n {+
                           Self.Margin div 2};
        rect2.BottomRight.x := rect2.TopLeft.x + TDreamChatImageLoader.GetImage(G_FIRSTLINE).Width;
        TargetCanvas.Draw(Rect2.Left, Rect2.Top, TDreamChatImageLoader.GetImage(G_VERTICAL).Bitmap[0]);
        end
      end;
    end;
  end;

rect2.TopLeft.x := CellRect.TopLeft.x +
                   (Self.Indent {- 16}) * NodeLevel1 +
                   {Self.Margin div 2} +
                   TDreamChatImageLoader.GetImage(G_FIRSTLINE).Width;
rect2.TopLeft.y := CellRect.TopLeft.y;

PDNode := Self.GetNodeData(Node);
case PDNode.DataType of
 dtUser:
   begin
   //рисуем галочку перед юзером!!!
   if PDNode.User.CN_State = CNS_UnSelect then
     TargetCanvas.Draw(Rect2.Left, Rect2.Top, TDreamChatImageLoader.GetImage(G_CHECKBOX0).Bitmap[0]);
   if PDNode.User.CN_State = CNS_Private then
     TargetCanvas.Draw(Rect2.Left, Rect2.Top, TDreamChatImageLoader.GetImage(G_CHECKBOX1).Bitmap[0]);
   if PDNode.User.CN_State = CNS_Personal then
     TargetCanvas.Draw(Rect2.Left, Rect2.Top, TDreamChatImageLoader.GetImage(G_CHECKBOX2).Bitmap[0]);

   //рассчитываем координаты и рисуем юзверя
   rect2.TopLeft.x := rect2.Left + TDreamChatImageLoader.GetImage(G_CHECKBOX0).Width;
   TargetCanvas.Draw(Rect2.Left, Rect2.Top, TDreamChatImageLoader.GetImage(TImageIDs(integer(G_USER0) + Ord(PDNode.User.Status))).Bitmap[0]);
   //рисуем поверх юзера значек игнора
   if PDNode.User.Ignored = true then
     TargetCanvas.Draw(Rect2.Left, Rect2.Top, TDreamChatImageLoader.GetImage(G_IGNORED).Bitmap[0]);
   end;
 dtPrivateChat:
   begin
   TargetCanvas.Draw(Rect2.Left, Rect2.Top, TDreamChatImageLoader.GetImage(G_CHAT).Bitmap[0]);
   end;
 dtLine:
   begin
   TargetCanvas.Draw(Rect2.Left, Rect2.Top, TDreamChatImageLoader.GetImage(G_LINE).Bitmap[0]);
   end;
 end;
end;

procedure TGifVirtualStringTree.GifVirtualStringTreeMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  VirtualNode: PVirtualNode;
  indent1, NodeLevel1{, CWidth}: integer;
  c: cardinal;
  rect1: TRect;
  //s: string;
  //HitInfo: THitInfo;
  PDNode: PDataNode;
  LineNode: TLineNode;
  p: TPoint;
begin
VirtualNode := Self.GetNodeAt(X, Y);
if (VirtualNode <> nil) then
  begin
  FocusedNodeIndex := VirtualNode.Index;
  PDNode := self.GetNodeData(VirtualNode);
  FormUI.GetUserInfo(FParentChatLine, PDNode.User);
  rect1 := Self.GetDisplayRect(VirtualNode, -1, false);
  indent1 := Self.Indent * Self.GetNodeLevel(VirtualNode) {+ Self.Margin div 2};
  NodeLevel1 := Self.GetNodeLevel(VirtualNode);
  self.DoFocusNode(VirtualNode, true);
  self.SelectNodes(VirtualNode, VirtualNode, false);
  if (y >= rect1.TopLeft.y) and (y <= rect1.BottomRight.y) and
    (x >= rect1.TopLeft.x + indent1) and (x <= rect1.TopLeft.x + TDreamChatImageLoader.GetImage(G_FIRSTPLUS).Width + indent1) then
    begin
    //CLICK [+] Image Только левой мышью?! Почему? Проверки же нет! Странно...
    if Self.Expanded[VirtualNode] = true then
      begin
      if PDNode.DataType = dtUser then
        PDNode.User.IsExpanded := false
      else
        begin
        if self.GetNodeLevel(VirtualNode) = 0 then
          begin
          LineNode := TLineNode(PDNode.LineNode);
          LineNode.IsExpanded := false;
          end;
        end;
      //Self.Expanded[VirtualNode] := false
      //MessageBox(0, PChar('CLICK [+] IsExpanded = true'), PChar(inttostr(0)) ,mb_ok);
      end
    else
      begin
      if PDNode.DataType = dtUser then
        PDNode.User.IsExpanded := true
      else
        begin
        if self.GetNodeLevel(VirtualNode) = 0 then
          begin
          LineNode := TLineNode(PDNode.LineNode);
          LineNode.IsExpanded := true;
          end;
        end;
      //MessageBox(0, PChar('CLICK [+] IsExpanded = true'), PChar(inttostr(0)) ,mb_ok);
      end;
    end;
  if (y >= rect1.TopLeft.y) and (y <= rect1.BottomRight.y) and
    (x >= rect1.TopLeft.x + indent1 + TDreamChatImageLoader.GetImage(G_FIRSTLINE).Width) and
    (x <= rect1.TopLeft.x + indent1 + TDreamChatImageLoader.GetImage(G_FIRSTLINE).Width + TDreamChatImageLoader.GetImage(G_CHECKBOX0).Width) then
    begin
    //CHECKBOX Image Click! Любой мышью!
    if PDNode.DataType = dtUser then
      begin
      if PDNode.User.CN_State >= CNS_Personal then
        PDNode.User.CN_State := CNS_UnSelect
      else
        PDNode.User.CN_State :=
          Succ(PDNode.User.CN_State);
      UserListCNS_Private.Clear;
      UserListCNS_Personal.Clear;
      //заполняем список пользователей выделеных галочкой или стрелкой
      for c := 0 to TChatLine(self.FParentChatLine).UsersCount - 1 do
        begin
          case TChatLine(self.FParentChatLine).ChatLineUsers[c].CN_State of
            CNS_Personal: UserListCNS_Personal.Add(TChatLine(self.FParentChatLine).ChatLineUsers[c].ComputerName);
            CNS_Private: UserListCNS_Private.Add(TChatLine(self.FParentChatLine).ChatLineUsers[c].ComputerName);
          end;
        end;
      end;
    end;
  if (y >= rect1.TopLeft.y) and (y <= rect1.BottomRight.y) and
    (x >= rect1.TopLeft.x + indent1 + TDreamChatImageLoader.GetImage(G_FIRSTLINE).Width + TDreamChatImageLoader.GetImage(G_CHECKBOX0).Width) and
    (x <= rect1.TopLeft.x + indent1 + TDreamChatImageLoader.GetImage(G_FIRSTLINE).Width + TDreamChatImageLoader.GetImage(G_CHECKBOX0).Width + TDreamChatImageLoader.GetImage(G_USER0).Width) then
    begin
    //User Image Click! Любой мышью!
    end;
  //CWidth := self.Canvas.TextWidth(TChatLine(self.FParentChatLine).ChatLineUsers[PDNode.DataUserId].DisplayNickName);
  //какие-то проблемы с определением длины ника... получается на 5 пикселов меньше
  if (y >= rect1.TopLeft.y) and (y <= rect1.BottomRight.y) and
    (x >= rect1.TopLeft.x + indent1 + TDreamChatImageLoader.GetImage(G_FIRSTLINE).Width + TDreamChatImageLoader.GetImage(G_CHECKBOX0).Width + TDreamChatImageLoader.GetImage(G_USER0).Width) then
    //and (x <= rect1.TopLeft.x + indent1 + TDreamChatImageLoader.GetImage(G_FIRSTLINE].Width + TDreamChatImageLoader.GetImage(G_CHECKBOX0].Width + TDreamChatImageLoader.GetImage(G_USER0].Width + CWidth) then
    //какие-то проблемы с определением длины ника... получается на 5 пикселов меньше
    begin
    //Node Text Click! Кликнули по узлу дерева!!!';
    if PDNode.DataType = dtUser then
      begin
      //Node = User
      if Button = mbRight then
        begin
        //кликнули правой мышью по узлу dtUser
        DynamicPopupMenu.AddUserMenu(self, X, Y, PDNode, VirtualNode);
        end;
      end;
    if PDNode.DataType = dtPrivateChat then
      begin
      //Node = dtPrivateChat
      if Button = mbRight then
        begin
        //кликнули правой мышью по узлу dtPrivateChat
        DynamicPopupMenu.AddPrivateChatMenu(self, X, Y, PDNode, VirtualNode);
        end;
      end;
    if PDNode.DataType = dtLine then
      begin
      //Node = dtPrivateChat
      if Button = mbRight then
        begin
        //кликнули правой мышью по узлу dtLine
        DynamicPopupMenu.AddLineMenu(self, X, Y, PDNode, VirtualNode);
        end;
      end;
    end;
  end
else
  begin
  if Button = mbRight then
    begin
    //если кликнули правой мышью по пустому месту в дереве
    p.X := X;
    p.Y := Y;
    p := (Sender as TControl).ClientToScreen(p);
    DynamicPopupMenu.OnComponentClick(TComponent(Sender), p.X, p.Y {MouseX, MouseY});
    end;
  end;
end;

procedure TGifVirtualStringTree.GifVirtualStringTreeCompareNodes(Sender: TBaseVirtualTree;
  Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
PDNode1, PDNode2 : PDataNode;
begin
PDNode1 := self.GetNodeData(Node1);
PDNode2 := self.GetNodeData(Node2);
if (PDNode1.DataType = dtUser) and (PDNode2.DataType = dtUser) then
  result := CompareText(PDNode1.User.DisplayNickName,
                        PDNode2.User.DisplayNickName);
end;

procedure TGifVirtualStringTree.GifVirtualStringTreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
  PDNode: PDataNode;
  //c: cardinal;
  //User: TChatUser;
begin
PDNode := Self.GetNodeData(Node);
//CellText := PDNode.Text;
//TextType := ttStatic;
case PDNode.DataType of
  dtUser:
    begin
    //если узел дерева юзер - выводим его ник
    if PDNode.User <> nil then
      begin
      CellText := PDNode.User.DisplayNickName;
      end;
    end;
  dtPrivateChat:
    begin
    //если узел дерева - личный чат
    if PDNode.LineNode <> nil then
      begin
      //выводим его название
      //CellText := TChatLine(self.FParentChatLine).ChatLineUsers[PDNode.DataUserId].PrivateChatsList.Strings[PDNode.DataLineId];
      CellText := TLineNode(PDNode.LineNode).DisplayLineName;
      end;
    end;
  dtLine:
    begin
    //если узел дерева - линия
//    if self.FParentChatLine = Form1.GetMainLine then
    //if PDNode.DataUserId <= TChatLine(self.FParentChatLine).UsersCount - 1 then
    if PDNode.LineNode <> nil then
      begin
      //выводим его название
      //CellText := TChatLine(self.FParentChatLine).ChatLineUsers[PDNode.DataUserId].PrivateChatsList.Strings[PDNode.DataLineId];
      CellText := TLineNode(PDNode.LineNode).DisplayLineName;
      end;
    end;
  end;  
end;

procedure TGifVirtualStringTree.GifVirtualStringTreePaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
var
  PDNode: PDataNode;
  CWidth, indent1:integer;
begin
PDNode := Self.GetNodeData(Node);
indent1 := Self.Indent * Self.GetNodeLevel(Node);
if (PDNode.DataType = dtUser) and (PDNode.User <> nil) then
  CWidth := TargetCanvas.TextWidth(PDNode.User.DisplayNickName) + indent1 + 45 + 15;
if (PDNode.DataType = dtPrivateChat) and (PDNode.LineNode <> nil) then
  CWidth := TargetCanvas.TextWidth(TLineNode(PDNode.LineNode).DisplayLineName) + indent1 + 45 + 15;
if (PDNode.DataType = dtLine) and (PDNode.LineNode <> nil) then
  CWidth := TargetCanvas.TextWidth(TLineNode(PDNode.LineNode).DisplayLineName) + indent1 + 45 + 15;

if CWidth > ColumnWidth then
  begin
  ColumnWidth := CWidth;
  self.Header.Columns.Items[Column].Width := ColumnWidth;
  end;
//TargetCanvas.TextOut(0,0, 'ertertfghrthrthrthtrer');
//TargetCanvas.TextOut(10, 80, TChatLine(self.FParentChatLine).ChatLineUsers[PDNode.DataUserId].NickName);
end;

procedure TGifVirtualStringTree.GifVirtualStringTreeScroll(Sender: TBaseVirtualTree; DeltaX,
  DeltaY: Integer);
begin
//form1.Caption := 'OnScroll';
//потом можно будет отлавливать на сколько пикселей смещается канвас и
//перерисовывать только их...
//Self.Invalidate;
end;

procedure TGifVirtualStringTree.ScrollToXY(X, Y: Integer);
begin
self.DoSetOffsetXY(Point(x, y), [suoRepaintHeader, suoRepaintScrollbars, suoScrollClientArea, suoUpdateNCArea]);
end;

{procedure TGifVirtualStringTree.Clear;
begin
HScrollPos := self.OffsetX;
VScrollPos := self.OffsetY;
inherited;
end;}

end.
