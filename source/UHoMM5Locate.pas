// Copyright (c) 2010-2016 Sergey Klochkov. Contacts: <hserg@sklabs.ru>
// License: http://opensource.org/licenses/GPL-3.0
// The project web site is located on http://hmm5.sklabs.ru

unit UHoMM5Locate;

interface

type
  THMM5Version = (hmmUnknown, hmmOriginal, hmmAddon1, hmmAddon2);

{ определение версии HoMM5 }
function DetectHMM5Version(ADir: string): THMM5Version;

{ поиск HoMM по ассоциациям с файлами }
function LocateHoMM5DirM1: string;

{ поиск HoMM по зарегестрированным путям }
function LocateHoMM5DirM2: string;

implementation

uses
  Winapi.Windows, System.SysUtils, System.StrUtils, System.Win.Registry;

function LocateHoMM5DirM1: string;
var
  reg: TRegistry;
  tmp: string;
begin
  Result := '';
  
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CLASSES_ROOT;
    if reg.OpenKeyReadOnly('\h5c_auto_file\shell\open\command') then
      if reg.ValueExists('') then
        if reg.GetDataType('') = rdString then
          begin
            tmp := reg.ReadString('');
            if Pos('"', tmp) > 0 then
              Delete(tmp, 1, 1);
            if Pos('\bin\', LowerCase(tmp)) > 0 then
              Delete(tmp, Pos('\bin\', LowerCase(tmp)), Length(tmp));
            if DirectoryExists(tmp) then
              Result := tmp;
          end;
  finally
    reg.Free;
  end;
end;

function LocateHoMM5DirM2: string;
var
  reg: TRegistry;
  tmp: string;
begin
  Result := '';

  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    if reg.OpenKeyReadOnly('\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\H5_Game.exe') then
      if reg.ValueExists('Path') then
        if reg.GetDataType('Path') = rdString then
          begin
            tmp := reg.ReadString('Path');
            if AnsiEndsText('\bin', tmp) then
              Delete(tmp, Length(tmp)-3, 4);
            if DirectoryExists(tmp) then
              Result := tmp;
          end;
  finally
    reg.Free;
  end;
end;

function DetectHMM5Version(ADir: string): THMM5Version;
begin
  Result := hmmUnknown;
  if not DirectoryExists(ADir) then
    exit;

  ADir := IncludeTrailingPathDelimiter(ADir);

  if FileExists(ADir + 'profiles\autoexec.cfg') then
    Result := hmmOriginal;
  if FileExists(ADir + 'profiles\autoexec_a1.cfg') then
    Result := hmmAddon1;
  if FileExists(ADir + 'profiles\autoexec_a2.cfg') then
    Result := hmmAddon2;
end;

end.
