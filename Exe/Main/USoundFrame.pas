unit USoundFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, sFrameAdapter, StdCtrls, Mask, sMaskEdit, sCustomComboEdit,
  sTooledit, sLabel, Buttons, sSpeedButton, MMSystem;
              
type
  TSoundFrame = class(TFrame)
    sFrameAdapter1: TsFrameAdapter;
    fePath: TsFilenameEdit;
    sbPlay: TsSpeedButton;
    sbStop: TsSpeedButton;
    {procedure fePathMouseActivate(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y, HitTest: Integer;
      var MouseActivate: TMouseActivate); }
    procedure fePathKeyPress(Sender: TObject; var Key: Char);
    procedure FrameResize(Sender: TObject);
    procedure sbPlayClick(Sender: TObject);
    procedure sbStopClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TSoundFrame.FrameResize(Sender: TObject);
begin
//fePath.Width:=Width-fePath.Left*2;
end;

procedure TSoundFrame.fePathKeyPress(Sender: TObject; var Key: Char);
begin
  if key=#13 then
    if not FileExists(fePath.Text) then
      fePath.Text:='';
end;

{procedure TSoundFrame.fePathMouseActivate(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y, HitTest: Integer;
  var MouseActivate: TMouseActivate);
begin
  if not FileExists(fePath.Text) then
    fePath.Text:=''
  else
    fePath.InitialDir:=fePath.Text;
end;}

procedure TSoundFrame.sbPlayClick(Sender: TObject);
begin
  if FileExists(fePath.Text) then
    PlaySound(PChar(fePath.Text), 0, SND_FILENAME+SND_ASYNC);
end;

procedure TSoundFrame.sbStopClick(Sender: TObject);
begin
  if FileExists(fePath.Text) then
    PlaySound(nil, 0, SND_PURGE);
end;

end.
