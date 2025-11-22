// ReloadAndCompile.pas
// Helper script to reload and compile Altium_API.pas
//
// Usage:
//   1. Add this to your Altium project
//   2. Assign a hotkey (e.g. Ctrl+Shift+R)
//   3. After running rebuild.bat, press your hotkey

procedure ReloadAndCompile;
var
    ScriptManager : IScriptsManager;
    ProjectPath   : String;
begin
    ProjectPath := GetCurrentDir + '\Altium_API.PrjScr';

    ShowMessage('Reloading and compiling Altium_API.pas...');

    // Get script manager
    ScriptManager := Client.ScriptsManager;

    if ScriptManager <> nil then
    begin
        // Close the project if it's open
        ScriptManager.CloseScriptProject(ProjectPath);

        // Reopen the project (this reloads the .pas file)
        ScriptManager.OpenScriptProject(ProjectPath);

        // Compile the project
        ScriptManager.CompileScriptProject(ProjectPath);

        ShowMessage('Script reloaded and compiled!');
    end
    else
    begin
        ShowMessage('Error: Could not access Script Manager');
    end;
end;
