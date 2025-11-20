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
function OpenDocumentByPath(const DocumentPath, DocumentType: String): String;

implementation

uses
    globals, json_utils;

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

        // Altium auto-saves projects, so we just return success
        JsonBuilder.Add('{');
        JsonBuilder.Add('  "success": true,');
        JsonBuilder.Add('  "message": "Project is auto-saved by Altium",');
        JsonBuilder.Add('  "project_file": "' + Project.DM_ProjectFileName + '"');
        JsonBuilder.Add('}');

        Result := JsonBuilder.Text;
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
    DocumentsArray: TStringList;
    DocProps: TStringList;
    i: Integer;
    Doc: IDocument;
    DocType, DocKind: String;
    PCBCount, SchCount, OtherCount: Integer;
begin
    JsonBuilder := TStringList.Create;
    DocumentsArray := TStringList.Create;
    DocProps := TStringList.Create;
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
            // Count document types and build documents array
            PCBCount := 0;
            SchCount := 0;
            OtherCount := 0;

            for i := 0 to Project.DM_LogicalDocumentCount - 1 do
            begin
                Doc := Project.DM_LogicalDocuments(i);
                if Doc <> nil then
                begin
                    // Get document kind (verified in InteractiveHTMLBOM4Altium2.pas:67)
                    DocKind := Doc.DM_DocumentKind;

                    // Count by extension for backwards compatibility
                    DocType := UpperCase(ExtractFileExt(Doc.DM_FileName));
                    if (DocType = '.PCBDOC') or (DocType = '.PCB') then
                        PCBCount := PCBCount + 1
                    else if (DocType = '.SCHDOC') or (DocType = '.SCH') then
                        SchCount := SchCount + 1
                    else
                        OtherCount := OtherCount + 1;

                    // Build document object
                    DocProps.Clear;
                    AddJSONProperty(DocProps, 'kind', DocKind);
                    AddJSONProperty(DocProps, 'file_name', ExtractFileName(Doc.DM_FileName));
                    AddJSONProperty(DocProps, 'full_path', Doc.DM_FullPath);

                    // Add document object to array
                    DocumentsArray.Add(BuildJSONObject(DocProps, 2));
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
            JsonBuilder.Add('  "other_count": ' + IntToStr(OtherCount) + ',');

            // Add documents array
            if DocumentsArray.Count > 0 then
                JsonBuilder.Add('  "documents": ' + BuildJSONArray(DocumentsArray, '', 1))
            else
                JsonBuilder.Add('  "documents": []');

            JsonBuilder.Add('}');

            Result := JsonBuilder.Text;
        except
            Result := '{"success": false, "error": "' + JSONEscapeString(ExceptionMessage) + '"}';
        end;
    finally
        DocProps.Free;
        DocumentsArray.Free;
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

{..............................................................................}
{ OpenDocumentByPath - Open and display a document by path                     }
{ Based on verified examples:                                                  }
{ - OpenSchDocs.pas:33 - Client.ShowDocument(Client.OpenDocument(...))        }
{ - DesignReuse.pas:179 - Client.OpenDocument('PCB', ...)                     }
{..............................................................................}
function OpenDocumentByPath(const DocumentPath, DocumentType: String): String;
var
    JsonBuilder: TStringList;
    OpenedDoc: IServerDocument;
    Client: IClient;
begin
    JsonBuilder := TStringList.Create;
    try
        // Get the client interface
        Client := GetClient;
        if Client = nil then
        begin
            Result := '{"success": false, "error": "Could not access Altium client"}';
            Exit;
        end;

        // Check if file exists
        if not FileExists(DocumentPath) then
        begin
            Result := '{"success": false, "error": "Document file not found: ' + JSONEscapeString(DocumentPath) + '"}';
            Exit;
        end;

        try
            // Check if document is already open (verified in OpenSchDocs.pas:32)
            if Client.IsDocumentOpen(DocumentPath) then
            begin
                // Document is already open, just show it
                OpenedDoc := Client.OpenDocument(DocumentType, DocumentPath);
                if OpenedDoc <> nil then
                    Client.ShowDocument(OpenedDoc);

                JsonBuilder.Add('{');
                JsonBuilder.Add('  "success": true,');
                JsonBuilder.Add('  "message": "Document was already open and has been brought to focus",');
                JsonBuilder.Add('  "document_path": "' + JSONEscapeString(DocumentPath) + '",');
                JsonBuilder.Add('  "document_type": "' + DocumentType + '"');
                JsonBuilder.Add('}');
            end
            else
            begin
                // Open and show the document (verified in OpenSchDocs.pas:33)
                OpenedDoc := Client.OpenDocument(DocumentType, DocumentPath);
                if OpenedDoc <> nil then
                begin
                    Client.ShowDocument(OpenedDoc);

                    JsonBuilder.Add('{');
                    JsonBuilder.Add('  "success": true,');
                    JsonBuilder.Add('  "message": "Document opened successfully",');
                    JsonBuilder.Add('  "document_path": "' + JSONEscapeString(DocumentPath) + '",');
                    JsonBuilder.Add('  "document_type": "' + DocumentType + '"');
                    JsonBuilder.Add('}');
                end
                else
                begin
                    JsonBuilder.Add('{');
                    JsonBuilder.Add('  "success": false,');
                    JsonBuilder.Add('  "error": "Failed to open document. Verify the document type is correct."');
                    JsonBuilder.Add('}');
                end;
            end;

            Result := JsonBuilder.Text;
        except
            Result := '{"success": false, "error": "' + JSONEscapeString(ExceptionMessage) + '"}';
        end;
    finally
        JsonBuilder.Free;
    end;
end;


end.
