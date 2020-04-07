unit uImageLoader;

interface

uses
  LiteGIFX2;

type

TImageIDs = (
    G_FIRST = 0,
    G_FIRSTLINE   = 0,
    G_FIRSTMINUS  = 1,
    G_FIRSTPLUS   = 2,
    G_LASTLINE    = 3,
    G_LASTMINUS   = 4,
    G_LASTPLUS    = 5,
    G_MIDDLELINE  = 6,
    G_MIDDLEMINUS = 7,
    G_MIDDLEPLUS  = 8,
    G_ONEMINUS    = 9,
    G_ONEPLUS     = 10,
    G_VERTICAL    = 11,
    G_CHECKBOX0   = 12,
    G_CHECKBOX1   = 13,
    G_CHECKBOX2   = 14,
    G_USER0       = 15,
    G_USER1       = 16,
    G_USER2       = 17,
    G_USER3       = 18,
    G_REFRESH     = 19,
    G_CHAT        = 20,
    G_LINE        = 21,
    G_IGNORED     = 22,
    G_POPUP_IGNORED         = 23,
    G_POPUP_PRIVATE_MESSAGE = 24,
    G_POPUP_MASSMESSAGE     = 25,
    G_POPUP_PRIVATE_CHAT    = 26,
    G_POPUP_CREATE_LINE     = 27,
    G_POPUP_EXIT            = 28,
    G_POPUP_SEE_SHARE       = 29,
    G_POPUP_NICKNAME        = 30,
    G_POPUP_CLOSE           = 31,
    G_POPUP_SAVE            = 32,
    G_CLEAR                 = 33,
    G_REFRESHB              = 34,
    G_STATUS0               = 35,
    G_STATUS1               = 36,
    G_STATUS2               = 37,
    G_STATUS3               = 38,
    G_SMILE                 = 39,
    G_DEBUG                 = 40,
    G_SETTINGS              = 41,
    G_ABOUT                 = 42,
    G_T_MAINICON            = 43,
    G_T_MAINICON_1          = 44,
    G_T_MAINICON_2          = 45,
    G_T_MAINICON_3          = 46,
    G_T_MESS_1              = 47,
    G_T_MESS_2              = 48,
    G_LAST = 48
    );

TDreamChatImageLoader = class
private
  class procedure Load();
  class procedure Unload();
public
  class function GetImage(id: TImageIDs): TGif;
end;

implementation

uses Classes, SysUtils, uPathBuilder,
  {$IFDEF USELOG4D}, log4d {$ENDIF USELOG4D}
DreamChatConsts;

const

ImageNames: array[TImageIDs] of string = (
    'firstline.gif',
    'firstminus.gif',
    'firstplus.gif',
    'lastline.gif',
    'lastminus.gif',
    'lastplus.gif',
    'middleline.gif',
    'middleminus.gif',
    'middleplus.gif',
    'oneminus.gif',
    'oneplus.gif',
    'vertical.gif',
    'checkbox0.gif',
    'checkbox1.gif',
    'checkbox2.gif',
    'user0.gif',
    'user1.gif',
    'user2.gif',
    'user3.gif',
    'refresh.gif',
    'chat.gif',
    'line.gif',
    'ignored.gif',
    'POP_Ignored.gif',
    'POP_privatemess.gif',
    'POP_massmessage.gif',
    'POP_privatechat.gif',
    'POP_createline.gif',
    'POP_exit.gif',
    'POP_SeeShare.gif',
    'POP_NickName.gif',
    'POP_Close.gif',
    'POP_Save.gif',
    'clear.gif',
    'refreshb.gif',
    'status0.gif',
    'status1.gif',
    'status2.gif',
    'status3.gif',
    'smile.gif',
    'debug.gif',
    'settings.gif',
    'about.gif',
    't_MAINICON.gif',
    't_MAINICON_1.gif',
    't_MAINICON_2.gif',
    't_MAINICON_3.gif',
    't_mess_1.gif',
    't_mess_2.gif'
    );

var
  FGifArray: array[TImageIDs] of TGif;
  Initialised: boolean = False;

{ TDreamChatImageLoader }

class function TDreamChatImageLoader.GetImage(id: TImageIDs): TGif;
begin
  Load();
  Result := FGifArray[id];
end;

class procedure TDreamChatImageLoader.Load;
var
  i: TImageIDs;
  MS: TMemoryStream;
{$IFDEF USELOG4D}
  logger: TLogLogger;
{$ENDIF USELOG4D}

begin
  if Initialised then exit;

  MS := TMemoryStream.Create;
  try
    for i:= G_FIRST to G_LAST do begin
      FGifArray[i] := TGif.Create;

      try
        MS.LoadFromFile(TPathBuilder.GetImagesFolderName() + ImageNames[i]);
      except
        on E:Exception do begin
         // nothing to do here, just log and ignore absence of the file
        {$IFDEF USELOG4D}
          logger := TLogLogger.GetLogger(DREAMCHATLOGGER_NAME);
          logger.Error('[TImageLoader.Load()]' + E.Message, E);
         {$ENDIF USELOG4D}
        end;
      end;

      FGifArray[i].LoadFromStream(MS);
    end;
  finally
    MS.Free;
  end;

  Initialised := True;
end;

class procedure TDreamChatImageLoader.Unload;
var
  i: TImageIDs;
begin
  if not Initialised then exit;

  for i:= G_FIRST to G_LAST do begin
    FGifArray[i].Free;
    FGifArray[i] := nil;
  end;

  Initialised := False;
end;

initialization
  TDreamChatImageLoader.load();

finalization
  if Initialised
    then TDreamChatImageLoader.Unload();

end.
