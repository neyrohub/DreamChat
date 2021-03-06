{this file is included in ChatView.pas}
{------------------------------------}
procedure ReplaceStr(var str: String; old, new: String);
var p: Integer;
begin
   while true do begin
     p := pos(old, str);
     if p=0 then break;
     Delete(str,p, Length(old));
     Insert(new, str, p);
   end;
end;
{------------------------------------------------------------}
procedure ReplaceStr2(var str: String; old, new: String);
var p,ptr: Integer;
    s: String;
begin
   s := str;
   ptr := 1;
   while true do begin
     p := pos(old, s);
     if p=0 then break;
     inc(p, ptr-1);
     Delete(str,p, Length(old));
     Insert(new, str, p);
     ptr := p+Length(new);
     s := Copy(str, ptr, Length(str)+1-ptr);
   end;
end;
{------------------------------------------------------------}
function MakeHTMLStr(str:String): String;
begin
  ReplaceStr2(str, '&', '&amp');
  ReplaceStr(str, '>', '&gt');
  ReplaceStr(str, '<', '&lt');
  ReplaceStr(str, '  ', '&nbsp ');
  MakeHTMLStr := str;
end;

{------------------------------------------------------------}
function ColorCode(C: TColor): String;
var s: String;
begin
 s := IntToHex(ColorToRGB(c),6);
 s := Copy(s,5,2)+Copy(s,3,2)+Copy(s,1,2);
 ColorCode := '"#'+s+'"';
end;
{------------------------------------------------------------}
function GetFontSize(pts: Integer): Integer;
begin
  if pts<=8 then
    GetFontSize := 1
  else
    case pts of
      9..10:  GetFontSize := 2;
      11..12: GetFontSize := 3;
      13..14: GetFontSize := 4;
      15..18: GetFontSize := 5;
      19..24: GetFontSize := 6;
      else    GetFontSize := 7;
    end;
end;
{------------------------------------------------------------}
function OpenFontTag(ts: TFontInfo; normalfs: TFontStyles; Relative: Boolean): String;
var s: String;
begin
  s := '<FONT size='+IntToStr(GetFontSize(ts.Size))+ ' color='+ColorCode(ts.Color)+
       ' face="'+ts.FontName+'">';
  if Relative then begin
    if not (fsBold      in ts.Style) and (fsBold      in normalfs) then s := s+'</B>';
    if not (fsItalic    in ts.Style) and (fsItalic    in normalfs) then s := s+'</I>';
    if not (fsUnderline in ts.Style) and (fsUnderline in normalfs) then s := s+'</U>';
    if not (fsStrikeOut in ts.Style) and (fsStrikeOut in normalfs) then s := s+'</S>';
    if (fsBold      in ts.Style) and not (fsBold      in normalfs) then s := s+'<B>';
    if (fsItalic    in ts.Style) and not (fsItalic    in normalfs) then s := s+'<I>';
    if (fsUnderline in ts.Style) and not (fsUnderline in normalfs) then s := s+'<U>';
    if (fsStrikeOut in ts.Style) and not (fsStrikeOut in normalfs) then s := s+'<S>';
    end
  else begin
    if (fsBold in ts.Style)      then s := s+'<B>';
    if (fsItalic in ts.Style)    then s := s+'<I>';
    if (fsUnderline in ts.Style) then s := s+'<U>';
    if (fsStrikeOut in ts.Style) then s := s+'<S>';
  end;
  OpenFontTag := s;
end;
{------------------------------------------------------------}
function CloseFontTag(ts: TFontInfo; normalfs: TFontStyles; Relative: Boolean):String;
var s: String;
begin
  if Relative then begin
    if (fsBold      in ts.Style) and not (fsBold      in normalfs) then s := s+'</B>';
    if (fsItalic    in ts.Style) and not (fsItalic    in normalfs) then s := s+'</I>';
    if (fsUnderline in ts.Style) and not (fsUnderline in normalfs) then s := s+'</U>';
    if (fsStrikeOut in ts.Style) and not (fsStrikeOut in normalfs) then s := s+'</S>';
    if not (fsBold      in ts.Style) and (fsBold      in normalfs) then s := s+'<B>';
    if not (fsItalic    in ts.Style) and (fsItalic    in normalfs) then s := s+'<I>';
    if not (fsUnderline in ts.Style) and (fsUnderline in normalfs) then s := s+'<U>';
    if not (fsStrikeOut in ts.Style) and (fsStrikeOut in normalfs) then s := s+'<S>';
    end
  else begin
    if (fsBold in ts.Style)      then s := s+'</B>';
    if (fsItalic in ts.Style)    then s := s+'</I>';
    if (fsUnderline in ts.Style) then s := s+'</U>';
    if (fsStrikeOut in ts.Style) then s := s+'</S>';
  end;
  s:= s+'</FONT>';
  CloseFontTag := s;
end;
{------------------------------------------------------------}
function TChatView.GetNextFileName(Path: String): String;
var fn: String;
begin
  while True do begin
     inc(imgSaveNo);
     fn := Path+imgSavePrefix+IntToStr(imgSaveNo)+'.bmp';
     GetNextFileName := fn;
     if not FileExists(fn) then exit;
     if (cvsoOverrideImages in SaveOptions) and
        ((FileGetAttr(fn) and faReadOnly)=0) then exit;
  end;
end;
{------------------------------------------------------------}
function TChatView.SavePicture(DocumentSaveFormat: TCVSaveFormat; Path: String; gr: TGraphic): String;
var fn: String;
    bmp: TBitmap;
begin
  { DocumentSaveFormat in this version is ignored }
   fn := GetNextFileName(Path);
   SavePicture := ExtractFileName(fn);
   if gr is TBitmap then begin
     gr.SaveToFile(fn);
     exit;
   end;
   bmp := TBitmap.Create;
   try
     bmp.Height := gr.Height;
     bmp.Width := gr.Width;
     bmp.Canvas.Brush.Color := Style.Color;
     bmp.Canvas.Pen.Color := Style.Color;
     bmp.Canvas.FillRect(Rect(0,0,Width,Height));
     bmp.Canvas.Draw(0,0,gr);
     bmp.SaveToFile(fn);
   finally
     bmp.Free;
   end;

end;
{------------------------------------------------------------}
function TChatView.SaveHTML(FileName,Title,ImagesPrefix: String; Options: TCVSaveOptions):Boolean;
var f: TextFile;
    i,j: Integer;
    li: TContainerInfo;
    needbr: Boolean;
    s: String;
    cpno, jumpno: Integer;
    Bullets: TStringList;
    fn: String;
    bmp: TBitmap;
    cvi: TCVInteger2;
begin
  {$I+}
  SaveHTML := False;
  if Style = nil then exit;
  SaveHTML := True;
  imgSavePrefix := ImagesPrefix;
  imgSaveNo := 0;
  SaveOptions := Options;
  cpno := 0;
  jumpno := FirstJumpNo;
  Bullets := TStringList.Create;
  try
    AssignFile(f, FileName);
    Rewrite(f);
    try
     WriteLn(f,'<HTML><HEAD><TITLE>'+Title+'</TITLE></HEAD>');
     Writeln(f,'<BODY bgcolor='+ColorCode(Style.Color));
     if (BackgroundStyle<>bsNoBitmap) and
        (BackgroundBitmap<>nil) then begin
        Writeln(f,'      background='+ SavePicture(cvsfHTML, ExtractFilePath(FileName), BackgroundBitmap));
        if (BackgroundStyle<>bsTiledAndScrolled) then
        Writeln(f,'      bgproperties=fixed');
     end;
     Writeln(f,'      leftmargin='+IntToStr(LeftMargin)+'>');
     WriteLn(f,OpenFontTag(Style.TextStyles[cvsNormal], Style.TextStyles[cvsNormal].Style, False));
     needbr := False;
     for i:=0 to ContStorage.Count-1 do begin
         li := TContainerInfo(ContStorage.Objects[i]);
         case li.StyleNo of
         {*} cvsBreak:
                begin
                   Writeln(f,'<HR noshade size=1>');
                   needbr := False;
                end;
          {*} cvsComponent:
                if Assigned(FOnSaveComponentToFile) then begin
                   s := '';
                   FOnSaveComponentToFile(Self, ExtractFilePath(FileName), li.gr, cvsfHTML, s);
                   if s<>'' then begin
                      Writeln(f,s);
                      needbr := True;
                   end;
                end;
           {*} cvsCheckPoint:
                begin
                   WriteLn(f);
                   WriteLn(f,'<A name=ChatViewCheckPoint'+IntToStr(cpno)+'></A>');
                   inc(cpno);
                end;
           {*} cvsPicture:
                begin
                   if (not li.Center) and (not li.SameAsPrev) then WriteLn(f,'<BR>');
                   if li.Center then Write(f,'<CENTER>');
                   Write(f,'<IMG src="'+
                            SavePicture(cvsfHTML, ExtractFilePath(FileName), TGraphic(li.gr))+
                            '">');
                   if li.Center then Write(f,'</CENTER>');
                   needbr := True;
                end;
           {*} cvsBullet, cvsHotSpot:
                begin
                   if (not li.SameAsPrev) and needbr then WriteLn(f,'<BR>');
                   fn := '';
                   for j:=0 to Bullets.Count-1 do
                     if (TContainerInfo(ContStorage.Objects[i]).gr =
                         TContainerInfo(ContStorage.Objects[TCVInteger2(Bullets.Objects[j]).val]).gr) and
                        (TContainerInfo(ContStorage.Objects[i]).imgNo =
                         TContainerInfo(ContStorage.Objects[TCVInteger2(Bullets.Objects[j]).val]).imgNo) then begin
                        fn := Bullets[j];
                     end;
                   if fn='' then begin
                      bmp := TBitmap.Create;
                      bmp.Width := TImageList(li.gr).Width;
                      bmp.Height := TImageList(li.gr).Height;
                      bmp.Canvas.Brush.Color := Style.Color;
                      bmp.Canvas.Pen.Color := Style.Color;
                      bmp.Canvas.FillRect(Rect(0,0,Width,Height));
                      TImageList(li.gr).Draw(bmp.Canvas, 0, 0, li.imgNo);
                      fn := SavePicture(cvsfHTML, ExtractFilePath(FileName), bmp);
                      cvi     := TCVInteger2.Create;
                      cvi.Val := i;
                      Bullets.AddObject(fn, cvi);
                      bmp.Free;
                   end;
                   s := '';
                   if li.StyleNo=cvsHotSpot then begin
                     if Assigned(FOnURLNeeded) then
                         FOnURLNeeded(Self,jumpno,s);
                     inc(jumpno);
                     if s<>'' then Write(f,'<A href='+s+'>');
                   end;
                   Write(f,'<IMG src="'+fn+'">');
                   if s<>'' then Write(f,'</A>');
                   needbr := True;
                end;
           {*} cvsJump1, cvsJump2:
                begin
                   if (not li.Center) and (not li.SameAsPrev) and needbr then WriteLn(f,'<BR>');
                   if li.Center then Write(f,'<CENTER>');
                   s := '';
                   if Assigned(FOnURLNeeded) then
                       FOnURLNeeded(Self,jumpno,s);
                   inc(jumpno);
                   if s<>'' then Write(f,'<A href='+s+'>');
                   Write(f,OpenFontTag(Style.TextStyles[li.StyleNo], Style.TextStyles[cvsNormal].Style, True)+
                         MakeHTMLStr(ContStorage[i])+CloseFontTag(Style.TextStyles[li.StyleNo], Style.TextStyles[cvsNormal].Style, True));
                   if s<>'' then Write(f,'</A>');
                   needbr := not li.Center;
                end;
           {*} cvsNormal:
                begin
                   if (not li.Center) and (not li.SameAsPrev) and needbr then WriteLn(f,'<BR>');
                   if li.Center then
                     Write(f,'<CENTER>'+MakeHTMLStr(ContStorage[i])+'</CENTER>')
                   else
                     Write(f,MakeHTMLStr(ContStorage[i]));
                   needbr := not li.Center;
                end;
           {*} else
                begin
                   if (not li.Center) and (not li.SameAsPrev) and needbr then WriteLn(f,'<BR>');
                   if li.Center then Write(f,'<CENTER>');
                   Write(f,OpenFontTag(Style.TextStyles[li.StyleNo], Style.TextStyles[cvsNormal].Style, True)+
                         MakeHTMLStr(ContStorage[i])+CloseFontTag(Style.TextStyles[li.StyleNo], Style.TextStyles[cvsNormal].Style, True));
                   if li.Center then Write(f,'</CENTER>');
                   needbr := not li.Center;
                end;
          end;
     end;
     Writeln(f);
     WriteLn(f,CloseFontTag(Style.TextStyles[cvsNormal], Style.TextStyles[cvsNormal].Style, False));
     WriteLn(f,'</BODY></HTML>');
    finally
     for j:=0 to Bullets.Count-1 do begin
       TCVInteger2(Bullets.Objects[j]).Free;
       Bullets.Objects[j] := nil;
     end;
     Bullets.Free;
     CloseFile(f)
    end;
  except
    SaveHTML := False;
  end;
end;
{------------------------------------------------------------------}
function TChatView.SaveText(FileName: String; LineWidth: Integer):Boolean;
var f: TextFile;
    i,j: Integer;
    li: TContainerInfo;
    s, s2: String;
begin
  {$I+}
  SaveText := True;
  s := '';
  for j:=1 to LineWidth do s := s + '-';
  try
    AssignFile(f, FileName);
    Rewrite(f);
    try
     for i:=0 to ContStorage.Count-1 do begin
         li := TContainerInfo(ContStorage.Objects[i]);
         case li.StyleNo of
         {*} cvsBreak:
                begin Writeln(f); Write(f,s); end;
         {*} cvsCheckPoint: ;
         {*} cvsComponent:
                begin
                  if (not li.SameAsPrev) then WriteLn(f);
                  if Assigned(FOnSaveComponentToFile) then begin
                     s2 := '';
                     FOnSaveComponentToFile(Self,ExtractFilePath(FileName), li.gr, cvsfText, s2);
                     if s2<>'' then Write(f,s2);
                  end;
                end;
         {*} cvsPicture,cvsHotSpot,cvsBullet: {case}
              if (not li.SameAsPrev) then WriteLn(f);
         {*} else                             {case}
              begin
                if (not li.SameAsPrev) then WriteLn(f);
                if li.Center then begin
                  s2 := '';
                  for j:=1 to (LineWidth-Length(ContStorage[i])) div 2 do
                    s2 := s2 + ' ';
                  Write(f,s2+ContStorage[i])
                  end
                else
                  Write(f,ContStorage[i]);
              end;
         end;
     end;
    finally
     CloseFile(f)
    end;
  except
    SaveText := False;
  end;
end;