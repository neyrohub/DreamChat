//PluginManager for DreamChat kernel 0.5
//site: http://sourceforge.net/projects/dreamchat
//forum: http://dreamchat.flybb.ru/

//Autor: Bajenov Andrey Bladimirovich (neyro@mail.ru)
//Saint-Petersburg, Russia.
//2007.02.03
//All right reserved.

//DreamChat PluginManager is published under a double license. You can choose
//which one fits better for you, either Mozilla Public License (MPL) or Lesser
//General Public License (LGPL). For more info about MPL read the MPL homepage.
//For more info about LGPL read the LGPL homepage.

//������ ����� ��������� ������� ��������� �������:
//+--------------------+   +----------------------+
//| Native Plugin Type | ->| Extended Plugin Type |
//+--------------------+   +----------------------+
//|                    |   | GetPluginType        |
//|  GetPluginInfo     |   | GetPluginInfo        |
//+--------------------+   | + some function      |
//                         +----------------------+

//��������� ��� ������� ������ ����� ����� �-���
//  TGetPluginType = function(var PluginTypeNote: PChar):byte;
//  TGetPluginInfo = function():PPluginInfo;
//�� ��� �-��� �������� � NATIVE (���������) ����� ������� TDChatPlugin, �������
//������ � ������ uDChatPlugin.
//� ������ TDChatPlugin ����� ���� ������������ ����� ������, �.�. �� ���������
//������ 2 �������� �������������� ������� GetPluginType � GetPluginInfo. ���
//������� ������ ����� ������ ������ DreamChat!
//����� � ����������� �� �����������, ������ ��� ������� ��������� ������
//�������������� ���������. ������� �����������, ������ ��� �������, � ��
//���������� ���������! ����� ���� ����������� ���������� ����������� DLL, ��
//��� ��� ������ ������ ��������������� ������ �� ����� ��������.
//��� ������� ������������ ������� ������� ������� �� ������������. ��������:

//TDChatPlugin - ����� ������ ��� (Native), ���������� � ������ TDChatPlugin
//(uChatPlugin.pas).
//�� �� ���������� � TPluginType, �.�. �������� ���������. ������������ 2�
//�������:
//  TGetPluginType = function(var PluginTypeNote: PChar):byte;
//    ���������� ����� ���� �������, �������������� � ���������
//    TPluginType = (Test, Visual, Communication, SoundEvents, Protocol);
//  TGetPluginInfo = function():PPluginInfo;
//    ���������� ��������� �� ���������, ���������� ���������� � �������

//TDChatTestPlugin - �������� ��� �������, ���������� � ������ TDChatTestPlugin
//(uDChatTestPlugin.pas)
//������ 2� ��������� �-���, �� ������������ ��� 2� �-���:
//  TTestFunction1 = function(i: integer):PChar;
//    ������ �������� �-���. ���������� � DLL ��������� ������������.
//  TTestFunction2 = function(i: integer):PChar;
//    ������ �������� �-���. ���������� � DLL ��������� ������������.

//TDChatCommPlugin - ��� COMM, ���������� � ������ TDChatCommPlugin
//(uDChatCommPlugin.pas)
//��������� ��� ������� �-���! �������������� DLL ����� ���� ������
//�������������� ��������� ����� �-���:
//  SendCommDisconnect, SendCommConnect, SendCommText � �.�.

//����� ��������� ���� ���� ��������! ��� ����� �����:
//1. ������� ���� ������, ���������� ����� ������ ������� (�������� �� ������
//   TDChatTestPlugin.
//2. �������� � ����� ��������� TPluginType ���� ��� �������.
//3. ������� ������ uPluginManager.pas � ����� TPluginManager.LoadPlugin()
//   �������� � Case, ��� ���� ��������� ������ ����� ��� ���, ��
//   �� ��������� �� ������ ������ ������. ��������:
//   DChatPlugin := TDChatCommPlugin.Create(NativePlugin);
//4. ������� ������ uPluginManager.pas � ����� TPluginManager.UnLoadPlugin()
//   �������� �������������� ���� ��������� ������� � ������ ���� �������.
//   ����� ����� ������ ���������� ��������� �������, � ��� ������ �� �����.

//��� ��� ��������?
//������� ������ PluginManager. ���������� � ��� ��-�� PluginManager.FileList
//��� ��������� � ��� ����������� ������ ������ DLL. ��� ����� ���� ��� �������,
//��� � ����� DLL. ����� ������� ��� ������ ������
//PluginManager.LoadNativePlugin ����������� ���������� � ������ DLL �� ������
//� �������������� �-��� GetPluginType � GetPluginInfo. ���� ��� ����������, ��
//������ ���� DLL ��������� ������ ��������� ������ ������ TDChatPlugin.
//��� ��������� ��������� ������� ��������� � ������ NativePluginList.
//����� �� ���������� � ���������� ������� � ��� ������ PluginManager.LoadPlugin
//������� ��� "�������������" �� ��� ����.
//�.�. ��� ������ LoadPlugin �� �������� �� ����� ��������� ��������� ������
//�� ������ (���� �� ���� ������) �������� ������ PluginManager.PluginList
//��������� ��������-��������. ������ LoadPlugin ������������ ��� �������
//��������� ������ ��������� ������, ��������������� ���� DLL � ���������
//������ ������������ ������ ��� ������ �� ����������� ����� TPluginType.
//�.�. ���������� ������� ���� �������������� �-���, ������������� � ���� ����
//�������.
//��� �������� ������������ �������, �� ��������� �� ������ PluginList ���
//������ ������������, DLL �����������. � ����� �� ��� �� DLL �����������
//��� �������� ������ � �������� � ������ �������� ��������.
//������� �������� ))).

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DChatPluginManager, DChatPlugin, DChatTestPlugin, DChatCommPlugin,
  DChatClientServerPlugin, CheckLst, IniFiles, VTHeaderPopup, Menus,
  uMenuItemId;

type
  TFormManage = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ButtonLoadPlugin: TButton;
    ButtonUnloadPlugin: TButton;
    ListBox2: TListBox;
    Memo1: TMemo;
    Memo2: TMemo;
    CheckListBox1: TCheckListBox;
    ListBox1: TListBox;
    VTHeaderPopupMenu1: TVTHeaderPopupMenu;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonLoadPluginClick(Sender: TObject);
    procedure ButtonUnloadPluginClick(Sender: TObject);
    procedure ListBox2Click(Sender: TObject);
    procedure CheckListBox1Click(Sender: TObject);
    procedure CheckListBox1DblClick(Sender: TObject);
    procedure CheckListBox1ClickCheck(Sender: TObject);
    procedure RefreshCheckersOfAutoLoadPluginList(DoLoadPlugin: boolean);
    procedure AddSendFileMenu(Component: TComponent; X, Y: Integer);
    procedure CheckListBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    PROCEDURE OnMenuClick(Sender: TObject);
    function LoadingPlugin():boolean;
  private
    { Private declarations }
  public
    { Public declarations }
  end;
var
  ExePath: string;
  FormManage: TFormManage;
  PluginManager: TPluginManager;
  PluginManagerConfig: TMemIniFile;

implementation

{$R *.DFM}

procedure TFormManage.FormCreate(Sender: TObject);
var i: integer;
    maxWidth: integer;
begin
ExePath := ExtractFilePath(Application.ExeName);
PluginManagerConfig := TMemIniFile.Create(ExePath + 'Config.ini');

PluginManager := TPluginManager.Create(ExePath + 'plugins\');
Memo1.Lines.Clear;
Memo2.Lines.Clear;
ListBox1.Items := PluginManager.FileList;

//������� �������������� ������ ��������� � ListBox1
    maxWidth := 0;
      for i := 0 to ListBox1.Items.Count - 1 do
        begin
        if maxWidth < ListBox1.Canvas.TextWidth(ListBox1.Items.Strings[i]) then
          maxWidth := ListBox1.Canvas.TextWidth(ListBox1.Items.Strings[i]);
        end;
      ListBox1.Perform(LB_SETHORIZONTALEXTENT, maxWidth + 10, 0);

for i := 0 to PluginManager.FileList.Count - 1 do
  begin
  if PluginManager.LoadNativePlugin(PluginManager.FileList.Strings[i]) = false then
    begin
    ChecklistBox1.Items.Add('Load Plugin error!');
    end;
  end;
ChecklistBox1.Items := PluginManager.NativePluginList;

RefreshCheckersOfAutoLoadPluginList(true);
end;

procedure TFormManage.FormDestroy(Sender: TObject);
var i: integer;
    NativePlugin: TDChatPlugin;
begin
if ChecklistBox1.Items.Count > 0 then
  begin
  for i := 0 to ChecklistBox1.Items.Count - 1 do
    begin
    //���������� ������ �������
    NativePlugin := TDChatPlugin(CheckListBox1.Items.Objects[i]);
    PluginManagerConfig.WriteBool('PluginAutoLoad', NativePlugin.Filename, CheckListBox1.Checked[i]);
    end;
  PluginManagerConfig.UpdateFile;
  end;
VTHeaderPopupMenu1.Items.Clear;
PluginManager.Free;
PluginManagerConfig.Free;
end;

procedure TFormManage.RefreshCheckersOfAutoLoadPluginList(DoLoadPlugin: boolean);
var i: integer;
    NativePlugin: TDChatPlugin;
    res: boolean;
begin
//������� ����� ������ ���� �������� �������� ��� ������������
i := 0;
while i <= ChecklistBox1.Items.Count - 1 do
  begin
  NativePlugin := TDChatPlugin(CheckListBox1.Items.Objects[i]);
  //�����, ��� � ������� ����������� SomeFile.dll = 1 ��� 0
  CheckListBox1.Checked[i] := PluginManagerConfig.ReadBool('PluginAutoLoad', NativePlugin.Filename, false);
  if CheckListBox1.Checked[i] = true then
    begin
    if DoLoadPlugin = true then
      begin
      CheckListBox1.ItemIndex := i;
      res := LoadingPlugin;
      if res = false then
        begin
        //����� �������� ������� ������ � ������!
        //��������� � ���������� ������� � ������ ���������
        inc(i);
        end;
      //������, ��� ��� ������� ������ �������� ������! �� ����������� i!
      end
    else
      begin
      //DoLoadPlugin = false
      //���������� ��� ���������� ������� � ������ ��������
      //��� �� ������������.
      inc(i);
      end;
    end
  else
    begin
    //������ ������ �� ������� �������� ��� ��������
    //��������� � ���������� � ������
    inc(i);
    end;
  end;
end;

procedure TFormManage.ButtonLoadPluginClick(Sender: TObject);
var TestPlugin: TDChatTestPlugin;
    Version: integer;
    e: EPluginError;
begin
LoadingPlugin;
end;

function TFormManage.LoadingPlugin():boolean;
var DChatPlugin: TDChatPlugin;
    Version: integer;
    e: EPluginLoadingError;
begin
result := true;
if ChecklistBox1.ItemIndex >= 0 then
  begin
    try
      Version := strtoint(TDChatPlugin(CheckListBox1.Items.Objects[CheckListBox1.ItemIndex]).PluginInfo.PluginManagerAPIVersion);
      DChatPlugin := TDChatPlugin(CheckListBox1.Items.Objects[CheckListBox1.ItemIndex]);
      if (DChatPlugin.PluginInfo.PluginAPIVersion <> '') or
        (Version = PlaginManagerVersion) then
        begin
          try
            //��������� ������
            if PluginManager.LoadPlugin(DChatPlugin) = false then
              begin
              //������ ��������
              e := EPluginLoadingError.Create('������ �������� ���������� (�������) ' +
                                       PChar(string(DChatPlugin.Filename))
                                       );
              result := false;
              raise e;
              end;
          except
            messagebox(0, PChar(string(TDChatPlugin(CheckListBox1.Items.Objects[CheckListBox1.ItemIndex]).Filename)),
                  PChar('������ �������� ���������� (�������)'), mb_ok);
            result := false;
            exit;
          end;
        CheckListBox1.Items := PluginManager.NativePluginList;
        listBox2.Items := PluginManager.PluginList;
        RefreshCheckersOfAutoLoadPluginList(false);
        end
      else
        begin
        messagebox(0,
               PChar('������ ����� �� ����������� ������ API ����������! PluginManagerAPIVersion = ' +
               TDChatPlugin(CheckListBox1.Items.Objects[CheckListBox1.ItemIndex]).PluginInfo.PluginManagerAPIVersion +
               ' . ������ ���� = ' + IntToStr(PlaginManagerVersion)),
               PChar(string(TDChatPlugin(CheckListBox1.Items.Objects[CheckListBox1.ItemIndex]).Filename)),
               mb_ok);
        result := false;
        end;
    except
      messagebox(0,
               PChar('������ ����� �� ����������� ������ API ����������! PluginManagerAPIVersion = ' +
               TDChatPlugin(CheckListBox1.Items.Objects[CheckListBox1.ItemIndex]).PluginInfo.PluginManagerAPIVersion +
               ' . ������ ���� = ' + IntToStr(PlaginManagerVersion)),
               PChar(string(TDChatPlugin(CheckListBox1.Items.Objects[CheckListBox1.ItemIndex]).Filename)),
               mb_ok);
    result := false;
    end;
  end;
memo2.Lines.Clear;
end;

procedure TFormManage.CheckListBox1DblClick(Sender: TObject);
begin
ButtonLoadPluginClick(Sender);
end;


procedure TFormManage.ButtonUnloadPluginClick(Sender: TObject);
var NativePlugin: TDChatPlugin;
begin
//��������� ����������� ������ � ��������� ��� � ������ Native
if listBox2.ItemIndex >= 0 then
  begin
  PluginManager.UnLoadPlugin(listBox2.Items.Objects[listBox2.ItemIndex]);
  CheckListBox1.Items.assign(PluginManager.NativePluginList);
  listBox2.Items := PluginManager.PluginList;
  RefreshCheckersOfAutoLoadPluginList(false);
  end;
end;

procedure TFormManage.CheckListBox1Click(Sender: TObject);
var NativePlugin: TDChatPlugin;
    s: string;
begin
if CheckListBox1.ItemIndex >= 0 then
  begin
  NativePlugin := TDChatPlugin(CheckListBox1.Items.Objects[CheckListBox1.ItemIndex]);
  memo1.Lines.Clear;
  memo1.Lines.Add('PluginName: ' + NativePlugin.PluginInfo.PluginName);
  memo1.Lines.Add('InternalPluginFileName: ' + NativePlugin.PluginInfo.InternalPluginFileName);
  case ord(NativePlugin.PluginInfo.PluginType) of
    0: s := 'Test';
    1: s := 'Visual';
    2: s := 'Communication';
    3: s := 'SoundEvents';
    4: s := 'Protocol';
    5: s := 'ClientServer';
  else
    begin
    s := 'Unknown';
    end;
  end;  
  memo1.Lines.Add('PluginType: ' + s);
  if Length(NativePlugin.PluginInfo.PluginManagerAPIVersion) > 0 then
    memo1.Lines.Add('PluginManager (Native API Version): ' + NativePlugin.PluginInfo.PluginManagerAPIVersion)
  else
    memo1.Lines.Add('PluginManager (Native API Version): Unknown');
  if Length(NativePlugin.PluginInfo.PluginAPIVersion) > 0 then
    memo1.Lines.Add('PluginAPIVersion: ' + NativePlugin.PluginInfo.PluginAPIVersion)
  else
    memo1.Lines.Add('PluginAPIVersion: Unknown');
  if Length(NativePlugin.PluginInfo.PluginVersion) > 0 then
    memo1.Lines.Add('PluginVersion: ' + NativePlugin.PluginInfo.PluginVersion)
  else
    memo1.Lines.Add('PluginVersion: Unknown');
  memo1.Lines.Add('PluginAutorName: ' + NativePlugin.PluginInfo.PluginAutorName);
  memo1.Lines.Add('PluginComment: ' + NativePlugin.PluginInfo.PluginComment);
  end;
end;

procedure TFormManage.ListBox2Click(Sender: TObject);
var TestPlugin: TDChatTestPlugin;
    CommPlugin: TDChatCommPlugin;
    NativePlugin: TDChatPlugin;
    ClientServerPlugin: TDChatClientServerPlugin;
    s: string;
begin
//�������� ������� ������� ����������� ��������!

if listBox2.ItemIndex >= 0 then
  begin
  if listBox2.Items.Objects[listBox2.ItemIndex] is TDChatClientServerPlugin then
    begin
    //���� ������� ������ ���� TDChatTestPlugin, �� � ���� ����
    //������� TestFunction1, TestFunction2
    ClientServerPlugin := TDChatClientServerPlugin(listBox2.Items.Objects[listBox2.ItemIndex]);
    if ClientServerPlugin <> nil then
      begin
      s := ClientServerPlugin.ExecuteCommand('showform', '', 0);
      memo2.Lines.Add(s);
      end;
    end;
  if listBox2.Items.Objects[listBox2.ItemIndex] is TDChatTestPlugin then
    begin
    //���� ������� ������ ���� TDChatTestPlugin, �� � ���� ����
    //������� TestFunction1, TestFunction2
{    TestPlugin := TDChatTestPlugin(listBox2.Items.Objects[listBox2.ItemIndex]);
    if TestPlugin <> nil then
      begin
      s := TestPlugin.TestFunction1(0);
      memo2.Lines.Add(s);
      end;}
    end;
  if listBox2.Items.Objects[listBox2.ItemIndex] is TDChatCommPlugin then
    begin
    //���� ������� ������ ���� TDChatCommPlugin, �� � ���� ���� ���
    //������� ������� ���������
    CommPlugin := TDChatCommPlugin(listBox2.Items.Objects[listBox2.ItemIndex]);
    s := CommPlugin.SendCommText('iChat', '192.168.1.4/ANDREY/Admins', 'Andrey',
                                 'Message from plugin', 'gsMTCI', 1);
    //���� ��� ���� ��������� ���������, �� � DChat � DebugLog ������������
    //'Message from plugin' ���������.
    //����� ��������� ������ � ��� ���, ����� ��������� PluginManager ��
    //����� ������� ������������ (Run As) ����� ��� ������� ��� ��� ��� ���������
    if s = '' then s := 'SendCommText() executed!';
    memo2.Lines.Add(s);
    end;

  NativePlugin := TDChatPlugin(listBox2.Items.Objects[listBox2.ItemIndex]);
  if NativePlugin <> nil then
    begin
    memo1.Lines.Clear;
    memo1.Lines.Add('PluginName: ' + NativePlugin.PluginInfo.PluginName);
    memo1.Lines.Add('InternalPluginFileName: ' + NativePlugin.PluginInfo.InternalPluginFileName);
    memo1.Lines.Add('PluginAutorName: ' + NativePlugin.PluginInfo.PluginAutorName);
    memo1.Lines.Add('PluginComment: ' + NativePlugin.PluginInfo.PluginComment);
    end;
  end;
end;

procedure TFormManage.CheckListBox1ClickCheck(Sender: TObject);
begin
  //���������� ������ �������
  PluginManagerConfig.WriteBool('PluginAutoLoad', TDChatPlugin(CheckListBox1.Items.Objects[CheckListBox1.ItemIndex]).Filename, CheckListBox1.Checked[CheckListBox1.itemindex]);
  PluginManagerConfig.UpdateFile;
end;

procedure TFormManage.AddSendFileMenu(Component: TComponent; X, Y: Integer);
var MenuItemId: TMenuItemId;
    ClientServerPlugin: TDChatClientServerPlugin;
    i, MenuNumb: integer;
    MenuCaption: string;
//    NativePlugin: TDChatPlugin;
begin
//������� ����, ������������� ��� ������� �� ����� � ������
//VTHeaderPopupMenu1.AddUserMenu(Component, X, Y, PDNode, VirtualNode);
VTHeaderPopupMenu1.Items.Clear;

{
for i := 0 to listBox1.Items.Count - 1 do
  begin
    NativePlugin := TDChatPlugin(CheckListBox1.Items.Objects[i]);
    memo2.Lines.Add('PluginName: ' + NativePlugin.PluginInfo.PluginName);
    if NativePlugin <> nil then
      begin
      if ord(NativePlugin.PluginInfo.PluginType) = 5 then ;//'ClientServer';
        begin
        MenuItem := TMenuItem.Create(VTHeaderPopupMenu1);
        MenuItem.Tag := i;
        MenuItem.OnClick := OnMenuClick;
        //MenuItem.Caption := '��� ���� ���';
        MenuItem.Caption := ClientServerPlugin.GetMenuItem;
        VTHeaderPopupMenu1.Items.Add(MenuItem);
        end;
      end;
  end;
}

//��� ������� ���� ������������ ���� ���������� �������� ����� ������-������
//� ���������� � ��� ������� ������� ��������� ������� ������ ����.
for i := 0 to listBox2.Items.Count - 1 do
  begin
  if listBox2.Items.Objects[i] <> nil then
    begin
    if listBox2.Items.Objects[i] is TDChatClientServerPlugin then
      begin
      //���� ������� ������ ���� TDChatTestPlugin, �� � ���� ����
      //������� TestFunction1, TestFunction2
      ClientServerPlugin := TDChatClientServerPlugin(listBox2.Items.Objects[i]);
      MenuNumb := 0;
      MenuCaption := ClientServerPlugin.ExecuteCommand('GetMenuItem', Pchar(inttostr(MenuNumb)), 0);
      while length(MenuCaption) > 0 do
        begin
        MenuItemId := TMenuItemId.Create(VTHeaderPopupMenu1);
        MenuItemId.Tag := i;
        MenuItemId.Id := MenuNumb;//0;
        MenuItemId.DChatClientServerPlugin := ClientServerPlugin;
        MenuItemId.OnClick := OnMenuClick;
        //MenuItem.Caption := '��� ���� ���';
        MenuItemId.Caption := MenuCaption;
        VTHeaderPopupMenu1.Items.Add(MenuItemId);
        inc(MenuNumb);
        MenuCaption := ClientServerPlugin.ExecuteCommand('GetMenuItem', Pchar(inttostr(MenuNumb)), 0);
        end;
      end;
    end;
  end;

end;

procedure TFormManage.CheckListBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
AddSendFileMenu(CheckListBox1, x, y);
end;

procedure TFormManage.ListBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
AddSendFileMenu(ListBox1, x, y);
end;

PROCEDURE TFormManage.OnMenuClick(Sender: TObject);
var i, n: integer;
    ClientServerPlugin: TDChatClientServerPlugin;
    InitString: string;
begin
i := TMenuItemId(Sender).Tag;
//����! ���� i ������� �� ���� � ����� ������ ������ ������� � ������ ��������!!!!
if TMenuItemId(Sender).DChatClientServerPlugin <> nil then
  begin
  if TMenuItemId(Sender).DChatClientServerPlugin is TDChatClientServerPlugin then
    begin
    ClientServerPlugin := TMenuItemId(Sender).DChatClientServerPlugin;
    if ClientServerPlugin.PluginInfo.PluginName = 'File client' then
      begin
      //���� ������� ������ ���� TDChatTestPlugin, �� � ���� ����
      //������� TestFunction1, TestFunction2
      n := TMenuItemId(Sender).Id;//{ - Trunc(TMenuItem(Sender).Tag/100)*100};
        case n of
        0:
          begin
          ClientServerPlugin := TDChatClientServerPlugin(listBox2.Items.Objects[i]);
          if ClientServerPlugin <> nil then
            begin
            ClientServerPlugin.ExecuteCommand('ShowForm', '', 0);
            Memo2.Lines.Add('ExecuteCommand ShowForm');
            end;
          end;
        1:
          begin
          ClientServerPlugin := TDChatClientServerPlugin(listBox2.Items.Objects[i]);
          if ClientServerPlugin <> nil then
            begin
            Randomize;
            InitString := '[Client]' + #13 +
                            'ServerIP=127.0.0.1'+ #13 +
//                          'ServerPort=5557'+ #13 +
                            'ServerPort=' + inttostr(random(10000)) + #13 +
                            'NickName=' + 'NickName' + #13 +
                            'RemoteNickName=' + 'RemoteNickName' + #13 +
                            'AutoConnect=true';
            Memo2.Lines.Add('Executing command: Connect');
            Memo2.Lines.Add('Result: ' + ClientServerPlugin.ExecuteCommand('Connect', PChar(InitString), 0));
            end;
          end;
        end;
      end;
    if ClientServerPlugin.PluginInfo.PluginName = 'File server' then
      begin
      //���� ������� ������ ���� TDChatTestPlugin, �� � ���� ����
      //������� TestFunction1, TestFunction2
      if ClientServerPlugin <> nil then
        begin
        ClientServerPlugin.ExecuteCommand('ShowForm', '', 0);
        Memo2.Lines.Add('ExecuteCommand ShowForm');
        end;
      Memo2.Lines.Add('MenuItem2');
      end;
    end;
  end;
end;

end.
