unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  RVStyle, RichView, ExtCtrls, StdCtrls, RVScroll;

type
  TForm1 = class(TForm)
    RVStyle1: TRVStyle;
    Timer1: TTimer;
    Button1: TButton;
    Panel1: TPanel;
    RichView1: TRichView;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
const crlf:String = chr(13)+chr(10);
begin
  with RichView1 do begin
     AddTextFromNewLine(
        ' '+crlf+' '+crlf+' '+crlf+' '+crlf+' '+crlf+' '+crlf+
        ' '+crlf+' '+crlf+' ', rvsNormal);
     AddCenterLine ('Credits Demo', rvsHeading);
     AddTextFromNewLine(
        'Roberto Nelson'+crlf+
        'Bruce Young'+crlf+
        'Kim Lambert'+crlf+
        'Leslie Johnson'+crlf+
        'Phil Forest'+crlf+
        'K.J. Weston'+crlf+
        'Lee Terry'+crlf+
        'Stewart Hall'+crlf+
        'Katherine Young'+crlf+
        'Chris Papadopulos'+crlf+
        'Pete Fisher'+crlf+
        'Ann Bennet'+crlf+
        'Roger De Sousa'+crlf+
        'Janet Boldwin'+crlf+
        'Roger Reeves'+crlf+
        'Willie Stansbury'+crlf+
        'Leslie  Phong'+crlf+
        'Ashok Ramanathan'+ crlf+
        'and other people from Employee.db'+
        ' '+crlf+' '+crlf+' '+crlf+' '+crlf+' '+crlf+' '+crlf+
        ' '+crlf+' '+crlf+' '+crlf+' '+crlf+' '+crlf+' '
        , rvsNormal);
     VSmallStep := 1;        
     Format;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
   if RichView1.VScrollPos<>RichView1.VScrollMax then
    RichView1.VScrollPos := RichView1.VScrollPos+1
   else
    RichView1.VScrollPos := 0;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
    Close;
end;

end.
