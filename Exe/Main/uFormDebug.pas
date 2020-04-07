unit uFormDebug;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, sMemo, sSplitter, sSkinProvider;

type
  TDebugMan = class
  private
    class procedure Init();
    class procedure Show();
    class procedure Close();

  public
    class procedure AddLine1(str: string);
    class procedure AddLine2(str: string);
    class procedure Clear1();
    class procedure Toggle();
    class procedure SaveToFile1(fileName: string);
    class procedure SaveToFile2(fileName: string);
  end;


  TFormDebug = class(TForm)
    DebugMemo1: TsMemo;
    DebugMemo2: TsMemo;
    Splitter1: TsSplitter;
    sSkinProvider1: TsSkinProvider;
    procedure FormCreate(Sender: TObject);
    procedure DebugMemo2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DebugMemo1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AddLine1(str: string);
    procedure AddLine2(str: string);
  end;

implementation

uses uFormMain;

{$R *.DFM}

var
  FFormDebug: TFormDebug;
  //Myinfo: TStartUpInfo;

procedure TFormDebug.FormCreate(Sender: TObject);
begin
  //GetStartUpInfo(MyInfo);
  //MyInfo.wShowWindow := SW_MINIMIZE;
  //MyInfo.wShowWindow := SW_HIDE;
  //ShowWindow(Handle, MyInfo.wShowWindow);
end;

procedure TFormDebug.AddLine1(str: string);
begin
  DebugMemo1.Lines.Add(str);
end;

procedure TFormDebug.AddLine2(str: string);
begin
  DebugMemo2.Lines.Add(str);
end;

procedure TFormDebug.DebugMemo1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
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

procedure TFormDebug.DebugMemo2MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
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

{ TDebugMan }

class procedure TDebugMan.AddLine1(str: string);
begin
  Init();
  FFormDebug.AddLine1(str);
end;

class procedure TDebugMan.AddLine2(str: string);
begin
  Init();

  // не уверен что это нужно но было так в оригинальном коде
  if FFormDebug.DebugMemo2.Lines.Count > 1555
    then FFormDebug.DebugMemo2.Lines.Clear;

  FFormDebug.AddLine2(str);
end;

class procedure TDebugMan.Clear1;
begin
  Init();
  FFormDebug.DebugMemo1.Lines.Clear;
end;

class procedure TDebugMan.Close;
begin
  Init();
  FFormDebug.Close;
end;

class procedure TDebugMan.Init;
begin
  if FFormDebug = nil
    then FFormDebug := TFormDebug.Create(nil);
end;

class procedure TDebugMan.SaveToFile1(fileName: string);
begin
  Init();
  FFormDebug.DebugMemo1.Lines.SaveToFile(fileName);
end;

class procedure TDebugMan.SaveToFile2(fileName: string);
begin
  Init();
  FFormDebug.DebugMemo2.Lines.SaveToFile(fileName);
end;

class procedure TDebugMan.Show;
begin
  Init();
  FFormDebug.Show;
end;

class procedure TDebugMan.Toggle;
begin
  Init();
  FFormDebug.Visible := not FFormDebug.Visible;
end;

initialization
//GetStartUpInfo(MyInfo);
//MyInfo.wShowWindow := SW_MINIMIZE;

finalization
  if FFormDebug <> nil
    then FFormDebug.Free;

end.
