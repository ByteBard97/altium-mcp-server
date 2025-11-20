// globals.pas
// Global constants and variables shared across command executor units

unit globals;

interface

uses
    Classes, SysUtils, PCB;

const
    constScriptProjectName = 'Altium_API';
    eClassMemberKind_Net = 1;

var
    RequestData : TStringList;
    ResponseData : TStringList;
    Params : TStringList;
    REQUEST_FILE : String;
    RESPONSE_FILE : String;
    ROOT_DIR: String;

// Wrapper functions to access Altium's global objects from units
function GetPCBServer: IPCB_ServerInterface;
function GetClient: IClient;

procedure InitializeFilePaths(RootDirectory: String);

implementation

// These functions provide access to Altium's global objects
// PCBServer and Client are automatically available in the main script context
function GetPCBServer: IPCB_ServerInterface;
begin
    Result := PCBServer;
end;

function GetClient: IClient;
begin
    Result := Client;
end;

procedure InitializeFilePaths(RootDirectory: String);
begin
    // Use the provided root directory
    ROOT_DIR := RootDirectory;

    // Ensure ROOT_DIR ends with a backslash
    if (Length(ROOT_DIR) > 0) and (ROOT_DIR[Length(ROOT_DIR)] <> '\') then
        ROOT_DIR := ROOT_DIR + '\';

    // Set the file paths
    REQUEST_FILE := ROOT_DIR + 'request.json';
    RESPONSE_FILE := ROOT_DIR + 'response.json';
end;

end.
