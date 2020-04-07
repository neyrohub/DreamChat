unit PrintFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfrmPrint = class(TForm)
    ScrollBox1: TScrollBox;
    Panel1: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Panel2: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrint: TfrmPrint;

implementation

{$R *.DFM}

end.
