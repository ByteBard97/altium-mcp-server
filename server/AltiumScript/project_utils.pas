{..............................................................................}
{ Project Management Utilities                                                  }
{ Functions for creating, saving, and managing Altium projects                 }
{..............................................................................}

unit project_utils;

interface

function CreateProject(const ProjectName, ProjectPath, Template: String): String;
function SaveProject: String;
function GetProjectInfo: String;
function CloseProject: String;

implementation

uses
    globals;

{..............................................................................}
{ CreateProject - Create a new Altium project with a blank PCB document        }
{..............................................................................}
function CreateProject(const ProjectName, ProjectPath, Template: String): String;
var
    Workspace: IWorkspace;
    Project: IProject;
    ProjectFile: String;
    PCBDoc: IDocument;
    SchDoc: IDocument;
    JsonBuilder: TStringList;
begin
    JsonBuilder := TStringList.Create;
    try
        Workspace := GetWorkspace;
        if Workspace = nil then
        begin
            Result := '{"success": false, "error": "No workspace available"}';
            Exit;
        end;

        // Build project file path
        ProjectFile := ProjectPath + '\' + ProjectName + '.PrjPCB';

        try
            // Create new project
            Project := Workspace.DM_CreateNewProject(ProjectFile);
            if Project = nil then
            begin
                Result := '{"success": false, "error": "Failed to create project"}';
                Exit;
            end;

            // Create a blank PCB document
            PCBDoc := Workspace.DM_CreateNewDocument('PCB');
            if PCBDoc <> nil then
            begin
                PCBDoc.DM_DocumentSave;
                Project.DM_AddSourceDocument(PCBDoc.DM_FileName);
            end;

            // Create a blank schematic document
            SchDoc := Workspace.DM_CreateNewDocument('SCH');
            if SchDoc <> nil then
            begin
                SchDoc.DM_DocumentSave;
                Project.DM_AddSourceDocument(SchDoc.DM_FileName);
            end;

            // Save the project
            Project.DM_ProjectSave;

            // Build success response
            JsonBuilder.Add('{');
            JsonBuilder.Add('  "success": true,');
            JsonBuilder.Add('  "project_file": "' + ProjectFile + '",');
            JsonBuilder.Add('  "project_name": "' + ProjectName + '",');
            JsonBuilder.Add('  "template": "' + Template + '"');
            JsonBuilder.Add('}');

            Result := JsonBuilder.Text;
        except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
        end;
    finally
        JsonBuilder.Free;
    end;
end;

{..............................................................................}
{ SaveProject - Save the currently open project                                }
{..............................................................................}
function SaveProject: String;
var
    Workspace: IWorkspace;
    Project: IProject;
    JsonBuilder: TStringList;
    i: Integer;
    Doc: IDocument;
begin
    JsonBuilder := TStringList.Create;
    try
        Workspace := GetWorkspace;
        if Workspace = nil then
        begin
            Result := '{"success": false, "error": "No workspace available"}';
            Exit;
        end;

        Project := Workspace.DM_FocusedProject;
        if Project = nil then
        begin
            Result := '{"success": false, "error": "No project open"}';
            Exit;
        end;

        try
            // Save all documents in the project
            for i := 0 to Project.DM_DocumentCount - 1 do
            begin
                Doc := Project.DM_Documents(i);
                if Doc <> nil then
                    Doc.DM_DocumentSave;
            end;

            // Save the project itself
            Project.DM_ProjectSave;

            // Build success response
            JsonBuilder.Add('{');
            JsonBuilder.Add('  "success": true,');
            JsonBuilder.Add('  "message": "Project saved successfully",');
            JsonBuilder.Add('  "project_file": "' + Project.DM_ProjectFileName + '"');
            JsonBuilder.Add('}');

            Result := JsonBuilder.Text;
        except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
        end;
    finally
        JsonBuilder.Free;
    end;
end;

{..............................................................................}
{ GetProjectInfo - Get detailed information about the currently open project   }
{..............................................................................}
function GetProjectInfo: String;
var
    Workspace: IWorkspace;
    Project: IProject;
    JsonBuilder: TStringList;
    i: Integer;
    Doc: IDocument;
    DocType: String;
    PCBCount, SchCount, OtherCount: Integer;
begin
    JsonBuilder := TStringList.Create;
    try
        Workspace := GetWorkspace;
        if Workspace = nil then
        begin
            Result := '{"success": false, "error": "No workspace available"}';
            Exit;
        end;

        Project := Workspace.DM_FocusedProject;
        if Project = nil then
        begin
            Result := '{"success": false, "error": "No project open"}';
            Exit;
        end;

        try
            // Count document types
            PCBCount := 0;
            SchCount := 0;
            OtherCount := 0;

            for i := 0 to Project.DM_LogicalDocumentCount - 1 do
            begin
                Doc := Project.DM_LogicalDocuments(i);
                if Doc <> nil then
                begin
                    DocType := UpperCase(ExtractFileExt(Doc.DM_FileName));
                    if (DocType = '.PCBDOC') or (DocType = '.PCB') then
                        PCBCount := PCBCount + 1
                    else if (DocType = '.SCHDOC') or (DocType = '.SCH') then
                        SchCount := SchCount + 1
                    else
                        OtherCount := OtherCount + 1;
                end;
            end;

            // Build response
            JsonBuilder.Add('{');
            JsonBuilder.Add('  "success": true,');
            JsonBuilder.Add('  "name": "' + JSONEscapeString(ExtractFileName(Project.DM_ProjectFileName)) + '",');
            JsonBuilder.Add('  "path": "' + JSONEscapeString(Project.DM_ProjectFullPath) + '",');
            JsonBuilder.Add('  "file_count": ' + IntToStr(Project.DM_LogicalDocumentCount) + ',');
            JsonBuilder.Add('  "pcb_count": ' + IntToStr(PCBCount) + ',');
            JsonBuilder.Add('  "schematic_count": ' + IntToStr(SchCount) + ',');
            JsonBuilder.Add('  "other_count": ' + IntToStr(OtherCount));
            JsonBuilder.Add('}');

            Result := JsonBuilder.Text;
        except
            Result := '{"success": false, "error": "' + JSONEscapeString(ExceptionMessage) + '"}';
        end;
    finally
        JsonBuilder.Free;
    end;
end;

{..............................................................................}
{ CloseProject - Close the currently open project                              }
{..............................................................................}
function CloseProject: String;
var
    Workspace: IWorkspace;
    Project: IProject;
    JsonBuilder: TStringList;
    ProjectName: String;
begin
    JsonBuilder := TStringList.Create;
    try
        Workspace := GetWorkspace;
        if Workspace = nil then
        begin
            Result := '{"success": false, "error": "No workspace available"}';
            Exit;
        end;

        Project := Workspace.DM_FocusedProject;
        if Project = nil then
        begin
            Result := '{"success": false, "error": "No project open"}';
            Exit;
        end;

        try
            ProjectName := ExtractFileName(Project.DM_ProjectFileName);

            // Close the project
            Workspace.DM_CloseProject(Project);

            // Build success response
            JsonBuilder.Add('{');
            JsonBuilder.Add('  "success": true,');
            JsonBuilder.Add('  "message": "Project closed successfully",');
            JsonBuilder.Add('  "project_name": "' + ProjectName + '"');
            JsonBuilder.Add('}');

            Result := JsonBuilder.Text;
        except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
        end;
    finally
        JsonBuilder.Free;
    end;
end;



end.
