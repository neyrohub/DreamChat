unit uPathBuilder;

interface

type
  TPathBuilder = class
  public
    class function BuildSkinsPath(SkinsPath: string): string;
    class procedure Configure;
    class function GetExePath: string;
    class function GetConfigIniFileName: string;
    class function GetSmilesIniFileName: string;
    class function GetJobsIniFileName: string;
    class function GetComponentsFolderName: string;
    class function GetDefaultSkinsDirFull: string;
    class function GetImagesFolderName: string;
    class function GetSmilesFolderName: string;
    class function GetUsersFolderName: string;
  end;

implementation

uses Forms, SysUtils, DreamChatConfig;

{ TPathBuilder }

class function TPathBuilder.BuildSkinsPath(SkinsPath: string): string;
begin
  Result := SkinsPath;
  if (SkinsPath <> '') and (ExtractFileDrive(SkinsPath) = '')
    then Result := ExcludeTrailingPathDelimiter(TPathBuilder.GetExePath()) + SkinsPath;
end;

class procedure TPathBuilder.Configure;
begin

end;

class function TPathBuilder.GetComponentsFolderName: string;
begin
  Result := GetExePath + TDreamChatDefaults.ComponentsFolderName;
end;

class function TPathBuilder.GetConfigIniFileName: string;
begin
  Result :=  GetExePath() + TDreamChatDefaults.ConfigIniFileName;
end;

class function TPathBuilder.GetDefaultSkinsDirFull: string;
begin
  Result := GetExePath + TDreamChatDefaults.DefaultSkinsDir;
end;

var
  cachedExePath: string = '';

class function TPathBuilder.GetExePath: string;
begin
  if cachedExePath = ''
    then cachedExePath := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));

  Result := cachedExePath;
end;

class function TPathBuilder.GetImagesFolderName: string;
begin
  Result := GetExePath + TDreamChatDefaults.ImagesFolderName;
end;

class function TPathBuilder.GetJobsIniFileName: string;
begin
  Result := GetExePath + TDreamChatDefaults.JobsIniFileName;
end;

class function TPathBuilder.GetSmilesFolderName: string;
begin
  Result := GetExePath + TDreamChatDefaults.SmilesFolderName;
end;

class function TPathBuilder.GetSmilesIniFileName: string;
begin
  Result := GetExePath + TDreamChatDefaults.SmilesIniFileName;
end;

class function TPathBuilder.GetUsersFolderName: string;
begin
  Result := GetExePath + TDreamChatDefaults.UsersFolderName;
end;

end.
