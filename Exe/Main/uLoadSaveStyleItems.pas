unit uLoadSaveStyleItems;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CVStyle, StdCtrls;

type
  TFontInfoLoadSave = class(TComponent)
  //Используется только для загрузки/сохранения коллекции
  protected
    procedure DefineProperties(Filer: TFiler);override;
  private
    FFontInfos: TFontInfos;
    procedure ReadFontInfos(Reader: TReader);
    procedure WriteFontInfos(Writer: TWriter);
    //procedure DefineProperties(Filer: TFiler);override;
  public
    property TextStyles: TFontInfos read FFontInfos write FFontInfos;
    Constructor Create(Component: TComponent);override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent);override;{virtual;}
  end;

type
  TTXTStyle = class(TFontInfoLoadSave)
  //Используется преобразования коллекции из TXT в OBJECT и назад
  private
  public
    Function SetStyleItems(i: integer; TXTSection: String): boolean;
    //Function SetStyleSection0(Sections: String): boolean;
    Function GetTXTStyleItems(i: integer): String;
    //Function GetStyleSection0(): String;
  end;

implementation

{.$R *.dfm}

function ComponentToString(Component: TComponent): string;
var
  ms: TMemoryStream;
  ss: TStringStream;
begin
  ss := TStringStream.Create(' ');
  ms := TMemoryStream.Create;
  try
    ms.WriteComponent(Component);
    ms.position := 0;
    ObjectBinaryToText(ms, ss);
    ss.position := 0;
    Result := ss.DataString;
  finally
    ms.Free;
    ss.free;
  end;
end;

procedure StringToComponent(Component: TComponent; Value: string);
var
  StrStream:TStringStream;
  ms: TMemoryStream;
begin
  StrStream := TStringStream.Create(Value);
  try
    ms := TMemoryStream.Create;
    try
      ObjectTextToBinary(StrStream, ms);
      ms.position := 0;
      ms.ReadComponent(Component);
    finally
      ms.Free;
    end;
  finally
    StrStream.Free;
  end;
end;
{==============================================================================}
Constructor TFontInfoLoadSave.Create(Component: TComponent);
begin
inherited Create(Component);
FFontInfos := TFontInfos.Create;
Name := 'FontInfoSave';//А будет ли оно уникальным?!
end;

destructor TFontInfoLoadSave.Destroy;
begin
  FFontInfos.Free;
  inherited;
end;

procedure TFontInfoLoadSave.Assign(Source: TPersistent);
begin
  if Source is TFontInfoLoadSave then
    begin
    self.FFontInfos.Assign(TFontInfoLoadSave(Source).FFontInfos);
    end;
end;

procedure TFontInfoLoadSave.ReadFontInfos(Reader: TReader);
begin
Reader.ReadValue;
Reader.ReadCollection(FFontInfos);
end;

procedure TFontInfoLoadSave.WriteFontInfos(Writer: TWriter);
begin
Writer.WriteCollection(FFontInfos);
end;

procedure TFontInfoLoadSave.DefineProperties(Filer: TFiler);
begin
inherited;
Filer.DefineProperty('TextStyles', ReadFontInfos, WriteFontInfos, true);
end;
{==============================================================================}

Function TTXTStyle.SetStyleItems(i: integer; TXTSection: String): boolean;
var S: String;
    FontInfoSave: TFontInfoLoadSave;
    //n: integer;
    //StringList: TStringList;
Begin
//ВНИМАНИЕ! Передавать только по одной секции за раз!!!!!!!!!!!!!
//в функцию передается TXTSection:
//      CharSet = ANSI_CHARSET
//      FontName = 'Arial'
//      Size = 10
//      Color = clBlue
//      Style = [fsBold]
if i < 0 then i := 0;
if (self.TextStyles.Count = 0) then
  begin
  self.TextStyles.Add;//добавляем некий дефолтный стиль. У него будет индекс 0.
                      //ниже мы его благополучно перетрем!
  end;
if (i > self.TextStyles.Count - 1) then
  begin
  self.TextStyles.Add;//добавляем некий дефолтный стиль. У него будет индекс 0.
                      //ниже мы его благополучно перетрем!
  i := self.TextStyles.Count - 1
  end;
//преобразуем TXT в раздел стиля и перетираем им стиль с номером i
//но сначала восстановим форматирование по правилам DFM
S := 'object FontInfoSave: TFontInfoSave'#13#10 +
     '  TextStyles = <'#13#10 +
     '    item'#13#10 +
     TXTSection + #13#10 +
     '    end>'#13#10 +
     'end';
//Формат восстановлен!
//MessageBox(0, PChar(S), PChar(IntToStr(0)), MB_OK);
//создаем "переобразователь"
FontInfoSave := TFontInfoLoadSave.Create(nil);
try
  StringToComponent(FontInfoSave, S);
  result := true;
except
  result := false;
end;
//переписываем стиль в нужный стиль конечного объекта
self.TextStyles.Items[i].Assign(FontInfoSave.TextStyles.Items[0]);//<- этот "0" и
//есть ограничение одного раздела за раз!
FontInfoSave.Free;
End;

{Function TTXTStyle.SetStyleSection0(Sections: String): boolean;
var S: String;
Begin
S := 'object FontInfoSave: TFontInfoSave'#13#10 +
     '  TextStyles = <'#13#10 +
     '    item'#13#10 +
     Sections + #13#10 +
     '    end>'#13#10 +
     'end';
try
  StringToComponent(self, s);
  result := true;
except
  result := false;
end;
end;
}
Function TTXTStyle.GetTXTStyleItems(i: integer): String;
var //S: String;
    FontInfoSave: TFontInfoLoadSave;
    StringList: TStringList;
Begin
//сейчас Self содержит в себе свойство FFontInfos, в котором имеем дофига
//объектов-стилей. Наша задача получить текстовое представление раздела номер i
result := '';
if (i >= 0) and (i <= self.TextStyles.Count - 1) then
  begin
  StringList := TStringList.Create;//вспомогательная переменная))
  //из нескольких стилей находим нужный и преобразуем его в TXT
  //создаем "переобразователь"
  FontInfoSave := TFontInfoLoadSave.Create(nil);
  FontInfoSave.Name := 'TXTFontInfoSave';
  FontInfoSave.TextStyles.Add;
  FontInfoSave.TextStyles.Items[0].Assign(self.TextStyles.Items[i]);
  //и получаем TXT
  StringList.Text := ComponentToString(FontInfoSave);
  //очищаем секцию от заголовков OBJECT ITEMS < > END END
  if StringList.Count > 5 then
    begin
    StringList.Delete(0);
    StringList.Delete(0);
    StringList.Delete(0);

    StringList.Delete(StringList.Count - 1);
    StringList.Delete(StringList.Count - 1);

    for i := 0 to StringList.Count - 1 do
      begin
      StringList.Strings[i] := TrimLeft(StringList.Strings[i]);
      end;
    end;
  result := StringList.Text;
  FontInfoSave.Free;
  StringList.Free;
  end;
End;

{Function TTXTStyle.GetStyleSection0(): String;
var StringList: TStringList;
Begin
StringList := TStringList.Create;
StringList.Text := ComponentToString(Self);
if StringList.Count > 5 then
  begin
  StringList.Delete(0);
  StringList.Delete(0);
  StringList.Delete(0);

  StringList.Delete(StringList.Count - 1);
  StringList.Delete(StringList.Count - 1);
  end;
result := StringList.Text;
StringList.Free;
end;}
{==============================================================================}

end.

