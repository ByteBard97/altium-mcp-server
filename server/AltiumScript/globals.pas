// globals.pas
// Global constants and variables shared across command executor units

unit globals;

interface

uses
    Classes, SysUtils;

const
    constScriptProjectName = 'Altium_API';
    REPLACEALL = 1;

var
    RequestData : TStringList;
    ResponseData : TStringList;
    Params : TStringList;
    REQUEST_FILE : String;
    RESPONSE_FILE : String;
    ROOT_DIR: String;

procedure InitializeFilePaths();

implementation

uses
    PCB;

procedure InitializeFilePaths();
var
    ScriptPath: String;
    Workspace: IWorkspace;
begin
    // Get the current workspace
    Workspace := GetWorkspace;
    
    // Get the script project path
    ScriptPath := ScriptProjectPath(Workspace);
    
    // Go back one directory from the script path
    ROOT_DIR := ExtractFilePath(ExtractFilePath(ScriptPath));
    
    // Set the file paths
    REQUEST_FILE := ROOT_DIR + 'request.json';
    RESPONSE_FILE := ROOT_DIR + 'response.json';
end;

end.
