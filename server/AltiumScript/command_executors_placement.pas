// command_executors_placement.pas
// Component Placement Command Executors

unit command_executors_placement;

interface

uses
    PCB, Classes, SysUtils, globals, json_utils, component_placement;

function ExecutePlaceComponent(RequestData: TStringList): String;
function ExecuteDeleteComponent(RequestData: TStringList): String;
function ExecutePlaceComponentArray(RequestData: TStringList): String;
function ExecuteAlignComponents(RequestData: TStringList): String;

implementation

function ExecutePlaceComponent(RequestData: TStringList): String;


function ExecuteDeleteComponent(RequestData: TStringList): String;
var
    i, ValueStart: Integer;
    Designator: String;
begin
    Designator := '';

    try
        // Parse parameters from the request
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"designator"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                Designator := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                Designator := TrimJSON(Designator);
                break;
            end;
        end;

        if Designator <> '' then
        begin
            Result := DeleteComponent(Designator);
        end
        else
        begin
            Result := '{"success": false, "error": "No designator provided"}';
        end;
    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
end;


function ExecutePlaceComponentArray(RequestData: TStringList): String;


function ExecuteAlignComponents(RequestData: TStringList): String;
var
    ParamValue: String;
    i, ValueStart: Integer;
    Designators, Alignment: String;
begin
    Designators := '';
    Alignment := '';

    try
        // Parse parameters from the request
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"designators"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                Designators := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                Designators := TrimJSON(Designators);
            end
            else if (Pos('"alignment"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                Alignment := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                Alignment := TrimJSON(Alignment);
            end;
        end;

        if (Designators <> '') and (Alignment <> '') then
        begin
            Result := AlignComponents(Designators, Alignment);
        end
        else
        begin
            Result := '{"success": false, "error": "Missing required parameters"}';
        end;
    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
end;

{..............................................................................}
{ Phase 2: Project Management Command Executors                                }
{..............................................................................}

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
