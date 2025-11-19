// command_executors_library.pas
// Project Management and Library Search Command Executors

unit command_executors_library;

interface

uses
    PCB, Classes, SysUtils, globals, json_utils, project_utils, library_utils;

function ExecuteCreateProject(RequestData: TStringList): String;
function ExecuteSearchComponents(RequestData: TStringList): String;
function ExecuteGetComponentFromLibrary(RequestData: TStringList): String;
function ExecuteSearchFootprints(RequestData: TStringList): String;

implementation

function ExecuteCreateProject(RequestData: TStringList): String;
var
    i, ValueStart: Integer;
    ProjectName, ProjectPath, Template: String;
begin
    ProjectName := '';
    ProjectPath := '';
    Template := 'blank';

    try
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"project_name"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ProjectName := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ProjectName := TrimJSON(ProjectName);
            end
            else if (Pos('"project_path"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ProjectPath := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ProjectPath := TrimJSON(ProjectPath);
            end
            else if (Pos('"template"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                Template := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                Template := TrimJSON(Template);
            end;
        end;

        if (ProjectName <> '') and (ProjectPath <> '') then
            Result := CreateProject(ProjectName, ProjectPath, Template)
        else
            Result := '{"success": false, "error": "Missing required parameters"}';
    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
end;

{..............................................................................}
{ Phase 2: Library Search Command Executors                                    }
{..............................................................................}

function ExecuteSearchComponents(RequestData: TStringList): String;
var
    i, ValueStart: Integer;
    Query: String;
begin
    Query := '';

    try
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"query"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                Query := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                Query := TrimJSON(Query);
                break;
            end;
        end;

        if Query <> '' then
            Result := SearchComponents(Query)
        else
            Result := '{"success": false, "error": "Query parameter required"}';
    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
end;

function ExecuteGetComponentFromLibrary(RequestData: TStringList): String;
var
    i, ValueStart: Integer;
    LibraryName, ComponentName: String;
begin
    LibraryName := '';
    ComponentName := '';

    try
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"library_name"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                LibraryName := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                LibraryName := TrimJSON(LibraryName);
            end
            else if (Pos('"component_name"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ComponentName := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ComponentName := TrimJSON(ComponentName);
            end;
        end;

        if (LibraryName <> '') and (ComponentName <> '') then
            Result := GetComponentFromLibrary(LibraryName, ComponentName)
        else
            Result := '{"success": false, "error": "Missing required parameters"}';
    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
end;


function ExecuteSearchFootprints(RequestData: TStringList): String;
var
    i, ValueStart: Integer;
    Query: String;
begin
    Query := '';

    try
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"query"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                Query := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                Query := TrimJSON(Query);
                break;
            end;
        end;

        if Query <> '' then
            Result := SearchFootprints(Query)
        else
            Result := '{"success": false, "error": "Query parameter required"}';
    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
end;

end.
