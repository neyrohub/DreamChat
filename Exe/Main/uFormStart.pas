unit uFormStart;

interface

uses
  Windows, Messages, Controls, StdCtrls, Forms, Dialogs,
  SysUtils, Classes, Graphics, ComCtrls, Gauges,
  sSkinProvider, sEdit, sGauge, sLabel,
  sSkinManager;

type
  TFormStart = class(TForm)
    sLabel1: TsLabel;
    sLabel2: TsLabel;
    Gauge1: TsGauge;
    sSkinProvider1: TsSkinProvider;
  private
    { Private declarations }
    procedure InitializeText();
  public
    { Public declarations }
    procedure Init(progressMax: integer);
    procedure MoveProgress(smileyName: string; count: integer);
  end;

var
  FormStart: TFormStart;

implementation

uses Math;

resourcestring
  StrLoadingSmileys = 'Загружаем смайлы (%d):'; //TODO: localization!

{$R *.DFM}

procedure TFormStart.Init(progressMax: integer);
const
  MIN_WIDTH = 300; // min form width
begin
  InitializeText();

  Width := max(MIN_WIDTH, sLabel1.Canvas.TextWidth(sLabel1.Caption)*2 + sLabel1.Left*4);
  sLabel2.Width := sLabel1.Canvas.TextWidth(sLabel1.Caption);
  sLabel2.Left := sLabel1.Left + sLabel1.Width + sLabel1.Left + sLabel1.Left;
  Gauge1.Width  := Width - Gauge1.Left*2;
  Gauge1.MaxValue := progressMax;
  Position := poScreenCenter;
end;

procedure TFormStart.MoveProgress(smileyName: string; count: integer);
begin
  sLabel2.Caption := smileyName;
  sLabel1.Caption := Format(StrLoadingSmileys, [count]);
  Gauge1.Progress := Gauge1.Progress + 1;
end;

procedure TFormStart.InitializeText;
begin
  sLabel1.Caption := Format(StrLoadingSmileys, [0]);
end;

end.
