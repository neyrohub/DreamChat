unit BackStyl;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfrmBackStyle = class(TForm)
    RadioGroup1: TRadioGroup;
    btnOk: TButton;
    btnCancel: TButton;
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBackStyle: TfrmBackStyle;

implementation
uses Unit1, RichView;
{$R *.DFM}

procedure TfrmBackStyle.btnOkClick(Sender: TObject);
begin
 Form1.RichView1.BackgroundStyle := TBackgroundStyle(RadioGroup1.ItemIndex);
end;

end.
