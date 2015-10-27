// Copyright (c) 2010-2016 Sergey Klochkov. Contacts: <hserg@sklabs.ru>
// License: http://opensource.org/licenses/GPL-3.0
// The project web site is located on http://hmm5.sklabs.ru

unit UMainForm;

interface

uses
  Windows, Vcl.Forms, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Controls, Vcl.Mask,
  JvExMask, JvToolEdit, System.Classes;

type
  TMainForm = class(TForm)
    jvdedtHMM5Path: TJvDirectoryEdit;
    lblHMM5Path: TLabel;
    mmLog: TMemo;
    btnCheck: TButton;
    statusBar: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure btnCheckClick(Sender: TObject);
    
  private
    const HMM5PATHDELIM = '\';

  private
    FStdMessage: string;

  private
    FInfo: TStrings;
    procedure LogAppend(ALogLine: string);

  public
    procedure Scan(ADir: string);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.SysUtils, System.StrUtils, JclFileUtils, UModChecker, UHoMM5Locate,
  UConsts.Ru;

procedure TMainForm.btnCheckClick(Sender: TObject);
const
  paths: array [0..4] of string = (
    '\bin',
    '\Maps',
    '\data',
    '\UserMODs',
    '\UserCampaigns');
var
  dir: string;
  i: Integer;
begin
  jvdedtHMM5Path.Enabled := false;
  btnCheck.Enabled := false;
  try
    dir := jvdedtHMM5Path.Text;

    if AnsiEndsText('\', dir) then
      Delete(dir, Length(dir), 1);

    for i := 0 to Length(paths) - 1 do
      if AnsiEndsText(paths[i], dir) then
        begin
          Delete(dir, Length(dir)-(Length(paths[i])-1), Length(paths[i]));
          break;
        end;

    Scan(dir);
  finally
    jvdedtHMM5Path.Enabled := true;
    btnCheck.Enabled := true;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  tmp: string;
begin
  FInfo := mmLog.Lines;

  btnCheck.Caption := TUIStrings.BTN_CHECK;
  lblHMM5Path.Caption := TUIStrings.LBL_HMM_FOLDER;

  FInfo.Add('HoMM5 Mods Checker');
  FInfo.Add('Version :  1.0');
  FInfo.Add('');
  FInfo.Add('Copyright © 2010-2016 Sergey A. Klochkov');
  FInfo.Add('HSerg@sklabs.ru, http://hmm5.sklabs.ru');
  FInfo.Add('');
  FInfo.Add('');

  FStdMessage := mmLog.Lines.Text;

  tmp := LocateHoMM5DirM1();
  if tmp = '' then
    tmp := LocateHoMM5DirM2();
  if tmp <> '' then
    jvdedtHMM5Path.Text := tmp;
end;

procedure TMainForm.LogAppend(ALogLine: string);
begin
  FInfo.Add(ALogLine);
  Application.ProcessMessages();
end;

procedure TMainForm.Scan(ADir: string);
var
  hmm5Version: THMM5Version;
  xVersionTitle: string;
  Major, Minor, Build, Revision: Word;
  FixedInfo: TVSFixedFileInfo;
  tmp: string;
  i: integer;
  xWoEChecker: TWoEChecker;
  exitWithErrors: boolean;
begin
  hmm5Version := DetectHMM5Version(ADir);
  case hmm5Version of
    hmmOriginal :
      xVersionTitle := TUIStrings.HMM5_ORIGINAL_VERSION_TITLE;
    hmmAddon1   :
      xVersionTitle := TUIStrings.HMM5_ADDON1_VERSION_TITLE;
    hmmAddon2   :
      xVersionTitle := TUIStrings.HMM5_ADDON2_VERSION_TITLE;
    hmmUnknown  :
      xVersionTitle := TUIStrings.HMM5_UNKNOWN_VERSION_TITLE;
  end;

  exitWithErrors := true;

  mmLog.Lines.Text := FStdMessage;
  xWoEChecker := TWoEChecker.Create;
  try
    xWoEChecker.OnLogAppend := LogAppend;
    try
      FInfo.Add(Format(' * %s: %s', [TUIStrings.VERSION_HMM5, xVersionTitle]));

      if VersionFixedFileInfo(ADir+'\bin\H5_Game.exe', FixedInfo) then
        begin
          VersionExtractFileInfo(FixedInfo, Major, Minor, Build, Revision);
          tmp := Format('%u.%u.%u.%u', [ Major, Minor, Build, Revision]);
        end
      else
        begin
          tmp := TUIStrings.FILE_VERSION_UNKNOWN;
        end;
      FInfo.Add(Format(' * %s: %s', [TUIStrings.FILE_VERSION, tmp]));

      FInfo.Add('');

      xWoEChecker.BuildInGamePath(ADir+'\data');

      xWoEChecker.ScanDataDir(ADir+'\data');
      xWoEChecker.ScanDataDir(ADir+'\UserMODs');
      xWoEChecker.ScanDataDir(ADir+'\Maps');
      xWoEChecker.ScanDataDir(ADir+'\UserCampaigns');

      FInfo.Add('');
      FInfo.Add('');

      if xWoEChecker.Dangerous.Count > 0 then
        begin
          FInfo.Add(Format(' %s:', [TUIStrings.FILES_AND_FOLDERS_WITH_MOD]));
          for i := 0 to xWoEChecker.Dangerous.Count - 1 do
            FInfo.Add('   ' + xWoEChecker.Dangerous[i]);
          exitWithErrors := true;
        end
      else
        begin
          FInfo.Add(Format(' %s', [TUIStrings.NO_MODS_FOUND]));
          exitWithErrors := false;
        end;

    except
      FInfo.Add('');
      FInfo.Add('');
      FInfo.Add(Format(' %s', [TUIStrings.FINISHED_WITH_ERRORS]));
    end;
  finally
    xWoEChecker.Free;
  end;

  if exitWithErrors then
    MessageBox(Handle, TUIStrings.DLG_TEXT_FIN_WITH_MODS,
      TUIStrings.COMPLETED, MB_OK or MB_ICONERROR)
  else
    MessageBox(Handle, TUIStrings.DLG_TEXT_FIN_WO_MODS,
      TUIStrings.COMPLETED, MB_OK or MB_ICONINFORMATION);
end;

end.
