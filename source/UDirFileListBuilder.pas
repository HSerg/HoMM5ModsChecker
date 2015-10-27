// Copyright (c) 2010-2016 Sergey Klochkov. Contacts: <hserg@sklabs.ru>
// License: http://opensource.org/licenses/GPL-3.0
// The project web site is located on http://hmm5.sklabs.ru

unit UDirFileListBuilder;

interface

uses
  System.Classes;

type
  TDirFileListBuilder = class
    class function Build(const APath: string;
      const DirList, FileList: TStrings): Boolean;
  end;

implementation

uses
  Winapi.Windows, System.SysUtils;

{ TDirFileListBuilder }

class function TDirFileListBuilder.Build(const APath: string;
  const DirList, FileList: TStrings): Boolean;
var
  SearchRec: TSearchRec;
begin
  Assert(DirList <> nil);
  Assert(FileList <> nil);

  Result := FindFirst(IncludeTrailingPathDelimiter(APath) + '*', faAnyFile, SearchRec) = 0;

  DirList.BeginUpdate;
  FileList.BeginUpdate;
  try
    while Result do
      begin
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
          begin
            if (SearchRec.Attr and faDirectory) <> 0 then
              DirList.Add(SearchRec.Name)
            else
              FileList.Add(SearchRec.Name);
          end;

        case FindNext(SearchRec) of
          0 : ;
          ERROR_NO_MORE_FILES :
            Break;
          else
            Result := False;
        end;
      end;
  finally
    FindClose(SearchRec);
    DirList.EndUpdate;
    FileList.EndUpdate
  end;
end;

end.
