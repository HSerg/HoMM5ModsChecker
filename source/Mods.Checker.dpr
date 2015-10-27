// Copyright (c) 2010-2016 Sergey Klochkov. Contacts: <hserg@sklabs.ru>
// License: http://opensource.org/licenses/GPL-3.0
// The project web site is located on http://hmm5.sklabs.ru

program Mods.Checker;

uses
  Forms,
  UMainForm in 'UMainForm.pas' {MainForm},
  UModChecker in 'UModChecker.pas',
  UHoMM5Locate in 'UHoMM5Locate.pas',
  UDirFileListBuilder in 'UDirFileListBuilder.pas',
  UConsts.Ru in 'UConsts.Ru.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'HoMM5 Mods Checker';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
