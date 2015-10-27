// Copyright (c) 2010-2016 Sergey Klochkov. Contacts: <hserg@sklabs.ru>
// License: http://opensource.org/licenses/GPL-3.0
// The project web site is located on http://hmm5.sklabs.ru

unit UModChecker;

interface

uses
  System.Classes;

type
  TLogAppendEvent = procedure(ALogLine: string) of object;

  TWoEChecker = class
  protected
    FInGamePath: TStringList;
    FDangerous: TStringList;
    FOnLogAppend: TLogAppendEvent;
  
  protected
    function IsGameFile(APath: string): boolean;
    function IsDangerousPack(AFileName: string): boolean;
    function IsInGamePathMod(APath: string): boolean;

    procedure ScanPak(const AFileName: string);
    procedure ScanFile(const AFSPath, APath, AFileName: string);
    procedure ScanDir(const ADir, CurrentHMM5Path: string);

    procedure DoLogAppend(ALogLine: string);

  public
    constructor Create;
    destructor Destroy; override;

    procedure ScanDataDir(ADir: string);
    procedure BuildInGamePath(ADataDir: string);

    property Dangerous: TStringList read FDangerous write FDangerous;
    property OnLogAppend: TLogAppendEvent read FOnLogAppend write FOnLogAppend;
  end;

implementation

uses
  System.SysUtils, System.StrUtils, System.Zip, UDirFileListBuilder,
  UConsts.Ru;

procedure TWoEChecker.BuildInGamePath(ADataDir: string);
const
  dataFiles: array [0..5] of string = (
    'a2p1-data.pak',
    'a2p1-texts.pak',
    'data.pak',
    'sound.pak',
    'soundsfx.pak',
    'texts.pak');
  ignoreList: array [0..2] of string = (
    'maps',
    'test',
    'campaigns');
var
  i, j, index: Integer;
  xFileName: string;
  xZipFile: TZipFile;
  xZIPFileName: string;
  lastValue: string;
  value: string;
begin
  ADataDir := IncludeTrailingPathDelimiter(ADataDir);
  FInGamePath.Clear;

  for j := 0 to Length(dataFiles) - 1 do
    begin
      xFileName := ADataDir + dataFiles[j];
      DoLogAppend(Format(' . %s %s', [TUIStrings.SCANNING, xFileName]));

      if not FileExists(xFileName) then
        continue;

      if not TZipFile.IsValid(xFileName) then
        continue;

      xZipFile := TZipFile.Create();
      try
        try
          xZipFile.Open(xFileName, zmRead);
          for i := 0 to xZipFile.FileCount - 1 do
            begin
              xZIPFileName := xZipFile.FileName[i];

              if (xZIPFileName[Length(xZIPFileName)] = '/') then
                continue;

              index := Pos('/', xZIPFileName);
              if index > 0 then
                Delete(xZIPFileName, index, Length(xZIPFileName));

              value := LowerCase(xZIPFileName);
              if value = lastValue then
                continue;

              FInGamePath.Add(value);
              lastValue := value;
            end;

          xZipFile.Close;
        except
          // nothing
        end;
      finally
        xZipFile.Free;
      end;
    end;

  for j := 0 to Length(ignoreList) - 1 do
    if FInGamePath.IndexOf(ignoreList[j]) <> -1 then
      FInGamePath.Delete(FInGamePath.IndexOf(ignoreList[j]));

  DoLogAppend('');
end;

constructor TWoEChecker.Create;
begin
  FInGamePath := TStringList.Create;
  FInGamePath.Sorted := true;
  FInGamePath.Duplicates := dupIgnore;

  FDangerous := TStringList.Create;
end;

destructor TWoEChecker.Destroy;
begin
  FDangerous.Free;
  FInGamePath.Free;
end;

procedure TWoEChecker.DoLogAppend(ALogLine: string);
begin
  if Assigned(FOnLogAppend) then
    FOnLogAppend(ALogLine);  
end;

function TWoEChecker.IsDangerousPack(AFileName: string): boolean;
var
  xZipFile: TZipFile;
  i: Integer;
  xZIPFileName: string;
begin
  Result := false;

  xZipFile := TZipFile.Create();
  try
    try
      xZipFile.Open(AFileName, zmRead);

      for i := 0 to xZipFile.FileCount - 1 do
        begin
          if AnsiEndsText('/', xZipFile.FileName[i]) then
            continue;

          xZIPFileName := StringReplace(xZipFile.FileName[i], '/', '\', [rfReplaceAll, rfIgnoreCase]);

          if IsInGamePathMod(xZIPFileName) then
            begin
              Result := true;
              exit;
            end;
        end;

      xZipFile.Close;
    except
      // nothing
    end;
  finally
    xZipFile.Free;
  end;
end;

function TWoEChecker.IsGameFile(APath: string): boolean;
const
  dataFiles: array [0..5] of string = (
    '\data\a2p1-data.pak',
    '\data\a2p1-texts.pak',
    '\data\data.pak',
    '\data\sound.pak',
    '\data\soundsfx.pak',
    '\data\texts.pak');
var
  i: Integer;
begin
  Result := false;
  for i := 0 to Length(dataFiles) - 1 do
    if AnsiEndsText(dataFiles[i], APath) then
      begin
        Result := true;
        break;
      end
end;

function TWoEChecker.IsInGamePathMod(APath: string): boolean;
begin
  if Pos('\', APath) > 0 then
    Delete(APath, Pos('\', APath), Length(APath));
  APath := LowerCase(APath);
  Result := (FInGamePath.IndexOf(APath) <> -1);
end;

procedure TWoEChecker.ScanDir(const ADir, CurrentHMM5Path: string);
begin
  if IsGameFile(ADir) then
    // FInfo.Add('[std]  ' + ADir)
  else
  if IsInGamePathMod(CurrentHMM5Path) then
    DoLogAppend('[!!!]  ' + ADir)
  else
    DoLogAppend('[???]  ' + ADir);
end;

procedure TWoEChecker.ScanDataDir(ADir: string);
var
  xDirList, xFileList: TStringList;
  i: integer;
  xDirPath: string;
begin
  ADir := IncludeTrailingPathDelimiter(ADir);

  xDirList := TStringList.Create;
  xFileList := TStringList.Create;
  try
    TDirFileListBuilder.Build(ADir, xDirList, xFileList);

    for i := 0 to xFileList.Count-1 do
      if AnsiEndsText('.pak', xFileList[i]) then
        ScanPak(ADir + xFileList[i])
      else
      if AnsiEndsText('.h5m', xFileList[i]) then
        ScanPak(ADir + xFileList[i])
      else
      if AnsiEndsText('.h5с', xFileList[i]) then
        ScanPak(ADir + xFileList[i])
      else
      if AnsiEndsText('.h5u', xFileList[i]) then
        ScanPak(ADir + xFileList[i])
      else
        ScanFile(ADir + xFileList[i], '', xFileList[i]);

    for i := 0 to xDirList.Count-1 do
      begin
        xDirPath := Trim(xDirList[i]);
        ScanDir(ADir+xDirPath+PathDelim, xDirPath);
      end;
  finally
    xDirList.Free;
    xFileList.Free;
  end;
end;

procedure TWoEChecker.ScanFile(const AFSPath, APath, AFileName: string);
begin
  if IsGameFile(AFSPath) then
    // DoLogAppend('[std]  ' + AFSPath)
  else
    DoLogAppend('[???]  ' + AFSPath);
end;

procedure TWoEChecker.ScanPak(const AFileName: string);
begin
  if IsGameFile(AFileName) then
    //  FInfo.Add('[std]  ' + AFileName)
  else
  if IsDangerousPack(AFileName) then
    begin
      DoLogAppend('[!!!]  ' + AFileName);
      FDangerous.Add(AFileName);
    end
  else
    DoLogAppend('[???]  ' + AFileName);
end;

end.
