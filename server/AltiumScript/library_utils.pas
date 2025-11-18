{..............................................................................}
{ Library Search and Component Discovery Utilities                             }
{ Functions for searching components and footprints in loaded libraries        }
{..............................................................................}

{..............................................................................}
{ ListComponentLibraries - List all available component libraries              }
{..............................................................................}
function ListComponentLibraries: String;
var
    Workspace: IWorkspace;
    Project: IProject;
    JsonBuilder: TStringList;
    i, j: Integer;
    Doc: IDocument;
    LibPath: String;
    LibName: String;
    LibCount: Integer;
    AddedLibs: TStringList;
begin
    JsonBuilder := TStringList.Create;
    AddedLibs := TStringList.Create;
    try
        Workspace := GetWorkspace;
        if Workspace = nil then
        begin
            Result := '{"success": false, "error": "No workspace available"}';
            Exit;
        end;

        try
            JsonBuilder.Add('{');
            JsonBuilder.Add('  "success": true,');
            JsonBuilder.Add('  "libraries": [');

            LibCount := 0;

            // Iterate through all open projects
            for i := 0 to Workspace.DM_ProjectCount - 1 do
            begin
                Project := Workspace.DM_Projects(i);
                if Project <> nil then
                begin
                    // Iterate through all documents in the project
                    for j := 0 to Project.DM_DocumentCount - 1 do
                    begin
                        Doc := Project.DM_Documents(j);
                        if Doc <> nil then
                        begin
                            LibPath := Doc.DM_FileName;
                            LibName := ExtractFileName(LibPath);

                            // Check if this is a library file
                            if (Pos('.SCHLIB', UpperCase(LibName)) > 0) or
                               (Pos('.PCBLIB', UpperCase(LibName)) > 0) or
                               (Pos('.INTLIB', UpperCase(LibName)) > 0) then
                            begin
                                // Avoid duplicates
                                if AddedLibs.IndexOf(LibPath) = -1 then
                                begin
                                    AddedLibs.Add(LibPath);

                                    if LibCount > 0 then
                                        JsonBuilder.Add('    ,');

                                    JsonBuilder.Add('    {');
                                    JsonBuilder.Add('      "name": "' + LibName + '",');
                                    JsonBuilder.Add('      "path": "' + LibPath + '",');

                                    if Pos('.SCHLIB', UpperCase(LibName)) > 0 then
                                        JsonBuilder.Add('      "type": "Schematic Library"')
                                    else if Pos('.PCBLIB', UpperCase(LibName)) > 0 then
                                        JsonBuilder.Add('      "type": "PCB Library"')
                                    else
                                        JsonBuilder.Add('      "type": "Integrated Library"');

                                    JsonBuilder.Add('    }');

                                    LibCount := LibCount + 1;
                                end;
                            // REMOVED DUPLICATE END: end;
                        // REMOVED DUPLICATE END: end;
                    // REMOVED DUPLICATE END: end;
                // REMOVED DUPLICATE END: end;
            // REMOVED DUPLICATE END: end;

            JsonBuilder.Add('  ]');
            JsonBuilder.Add('}');

            Result := JsonBuilder.Text;
        except
            on E: Exception do
            begin
                Result := '{"success": false, "error": "' + E.Message + '"}';
            end;
        // REMOVED DUPLICATE END: end;
    finally
        JsonBuilder.Free;
        AddedLibs.Free;
    end;
end;
// REMOVED DUPLICATE END: end;

{..............................................................................}
{ SearchComponents - Search for components across all loaded libraries         }
{..............................................................................}
function SearchComponents(const Query: String): String;
var
    Workspace: IWorkspace;
    Project: IProject;
    JsonBuilder: TStringList;
    i, j, k: Integer;
    Doc: IDocument;
    SchLib: ISch_Lib;
    SchComponent: ISch_Component;
    LibPath: String;
    LibName: String;
    CompName: String;
    CompDesc: String;
    SearchQuery: String;
    MatchCount: Integer;
begin
    JsonBuilder := TStringList.Create;
    try
        Workspace := GetWorkspace;
        if Workspace = nil then
        begin
            Result := '{"success": false, "error": "No workspace available"}';
            Exit;
        end;

        try
            SearchQuery := LowerCase(Query);
            MatchCount := 0;

            JsonBuilder.Add('{');
            JsonBuilder.Add('  "success": true,');
            JsonBuilder.Add('  "query": "' + Query + '",');
            JsonBuilder.Add('  "results": [');

            // Iterate through all open projects
            for i := 0 to Workspace.DM_ProjectCount - 1 do
            begin
                Project := Workspace.DM_Projects(i);
                if Project <> nil then
                begin
                    // Iterate through all documents in the project
                    for j := 0 to Project.DM_DocumentCount - 1 do
                    begin
                        Doc := Project.DM_Documents(j);
                        if (Doc <> nil) and (Pos('.SCHLIB', UpperCase(Doc.DM_FileName)) > 0) then
                        begin
                            LibPath := Doc.DM_FileName;
                            LibName := ExtractFileName(LibPath);

                            // Try to get the schematic library
                            SchLib := SCHServer.GetSchDocumentByPath(LibPath);
                            if SchLib <> nil then
                            begin
                                // Iterate through components in the library
                                for k := 0 to SchLib.ComponentCount - 1 do
                                begin
                                    SchComponent := SchLib.GetComponent(k);
                                    if SchComponent <> nil then
                                    begin
                                        CompName := SchComponent.LibReference;
                                        CompDesc := SchComponent.ComponentDescription;

                                        // Check if component matches search query
                                        if (Pos(SearchQuery, LowerCase(CompName)) > 0) or
                                           (Pos(SearchQuery, LowerCase(CompDesc)) > 0) then
                                        begin
                                            if MatchCount > 0 then
                                                JsonBuilder.Add('    ,');

                                            JsonBuilder.Add('    {');
                                            JsonBuilder.Add('      "name": "' + CompName + '",');
                                            JsonBuilder.Add('      "description": "' + CompDesc + '",');
                                            JsonBuilder.Add('      "library": "' + LibName + '",');
                                            JsonBuilder.Add('      "library_path": "' + LibPath + '"');
                                            JsonBuilder.Add('    }');

                                            MatchCount := MatchCount + 1;
                                        end;
                                    // REMOVED DUPLICATE END: end;
                                // REMOVED DUPLICATE END: end;
                            // REMOVED DUPLICATE END: end;
                        // REMOVED DUPLICATE END: end;
                    // REMOVED DUPLICATE END: end;
                // REMOVED DUPLICATE END: end;
            // REMOVED DUPLICATE END: end;

            JsonBuilder.Add('  ],');
            JsonBuilder.Add('  "match_count": ' + IntToStr(MatchCount));
            JsonBuilder.Add('}');

            Result := JsonBuilder.Text;
        except
            on E: Exception do
            begin
                Result := '{"success": false, "error": "' + E.Message + '"}';
            end;
        // REMOVED DUPLICATE END: end;
    finally
        JsonBuilder.Free;
    end;
end;
// REMOVED DUPLICATE END: end;

{..............................................................................}
{ GetComponentFromLibrary - Get detailed information about a component         }
{..............................................................................}
function GetComponentFromLibrary(const LibraryName, ComponentName: String): String;
var
    Workspace: IWorkspace;
    Project: IProject;
    JsonBuilder: TStringList;
    i, j, k: Integer;
    Doc: IDocument;
    SchLib: ISch_Lib;
    SchComponent: ISch_Component;
    Pin: ISch_Pin;
    LibPath: String;
    CompName: String;
    Found: Boolean;
begin
    JsonBuilder := TStringList.Create;
    try
        Workspace := GetWorkspace;
        if Workspace = nil then
        begin
            Result := '{"success": false, "error": "No workspace available"}';
            Exit;
        end;

        try
            Found := False;

            // Iterate through all open projects
            for i := 0 to Workspace.DM_ProjectCount - 1 do
            begin
                if Found then Break;

                Project := Workspace.DM_Projects(i);
                if Project <> nil then
                begin
                    // Iterate through all documents in the project
                    for j := 0 to Project.DM_DocumentCount - 1 do
                    begin
                        if Found then Break;

                        Doc := Project.DM_Documents(j);
                        if (Doc <> nil) and (Pos(LibraryName, Doc.DM_FileName) > 0) then
                        begin
                            LibPath := Doc.DM_FileName;

                            // Try to get the schematic library
                            SchLib := SCHServer.GetSchDocumentByPath(LibPath);
                            if SchLib <> nil then
                            begin
                                // Search for the component
                                for k := 0 to SchLib.ComponentCount - 1 do
                                begin
                                    SchComponent := SchLib.GetComponent(k);
                                    if (SchComponent <> nil) and
                                       (SchComponent.LibReference = ComponentName) then
                                    begin
                                        Found := True;

                                        JsonBuilder.Add('{');
                                        JsonBuilder.Add('  "success": true,');
                                        JsonBuilder.Add('  "name": "' + SchComponent.LibReference + '",');
                                        JsonBuilder.Add('  "description": "' + SchComponent.ComponentDescription + '",');
                                        JsonBuilder.Add('  "library": "' + ExtractFileName(LibPath) + '",');
                                        JsonBuilder.Add('  "pin_count": ' + IntToStr(SchComponent.PinCount) + ',');
                                        JsonBuilder.Add('  "pins": [');

                                        // Add pin information
                                        // Note: Pin iteration would require additional implementation
                                        // This is a simplified version

                                        JsonBuilder.Add('  ]');
                                        JsonBuilder.Add('}');

                                        Break;
                                    end;
                                // REMOVED DUPLICATE END: end;
                            // REMOVED DUPLICATE END: end;
                        // REMOVED DUPLICATE END: end;
                    // REMOVED DUPLICATE END: end;
                // REMOVED DUPLICATE END: end;
            // REMOVED DUPLICATE END: end;

            if not Found then
            begin
                Result := '{"success": false, "error": "Component not found: ' + ComponentName + ' in library: ' + LibraryName + '"}';
                Exit;
            end;

            Result := JsonBuilder.Text;
        except
            on E: Exception do
            begin
                Result := '{"success": false, "error": "' + E.Message + '"}';
            end;
        // REMOVED DUPLICATE END: end;
    finally
        JsonBuilder.Free;
    end;
end;
// REMOVED DUPLICATE END: end;

{..............................................................................}
{ SearchFootprints - Search for footprints across all loaded PCB libraries     }
{..............................................................................}
function SearchFootprints(const Query: String): String;
var
    Workspace: IWorkspace;
    Project: IProject;
    JsonBuilder: TStringList;
    i, j, k: Integer;
    Doc: IDocument;
    PCBLib: IPCB_Library;
    LibComponent: IPCB_LibComponent;
    LibPath: String;
    LibName: String;
    FootprintName: String;
    SearchQuery: String;
    MatchCount: Integer;
begin
    JsonBuilder := TStringList.Create;
    try
        Workspace := GetWorkspace;
        if Workspace = nil then
        begin
            Result := '{"success": false, "error": "No workspace available"}';
            Exit;
        end;

        try
            SearchQuery := LowerCase(Query);
            MatchCount := 0;

            JsonBuilder.Add('{');
            JsonBuilder.Add('  "success": true,');
            JsonBuilder.Add('  "query": "' + Query + '",');
            JsonBuilder.Add('  "results": [');

            // Iterate through all open projects
            for i := 0 to Workspace.DM_ProjectCount - 1 do
            begin
                Project := Workspace.DM_Projects(i);
                if Project <> nil then
                begin
                    // Iterate through all documents in the project
                    for j := 0 to Project.DM_DocumentCount - 1 do
                    begin
                        Doc := Project.DM_Documents(j);
                        if (Doc <> nil) and (Pos('.PCBLIB', UpperCase(Doc.DM_FileName)) > 0) then
                        begin
                            LibPath := Doc.DM_FileName;
                            LibName := ExtractFileName(LibPath);

                            // Try to get the PCB library
                            PCBLib := PCBServer.GetPCBLibraryByPath(LibPath);
                            if PCBLib <> nil then
                            begin
                                // Iterate through footprints in the library
                                for k := 0 to PCBLib.ComponentCount - 1 do
                                begin
                                    LibComponent := PCBLib.GetComponent(k);
                                    if LibComponent <> nil then
                                    begin
                                        FootprintName := LibComponent.Name;

                                        // Check if footprint matches search query
                                        if Pos(SearchQuery, LowerCase(FootprintName)) > 0 then
                                        begin
                                            if MatchCount > 0 then
                                                JsonBuilder.Add('    ,');

                                            JsonBuilder.Add('    {');
                                            JsonBuilder.Add('      "name": "' + FootprintName + '",');
                                            JsonBuilder.Add('      "library": "' + LibName + '",');
                                            JsonBuilder.Add('      "library_path": "' + LibPath + '",');
                                            JsonBuilder.Add('      "pad_count": ' + IntToStr(LibComponent.GetPrimitiveCount(ePadObject)));
                                            JsonBuilder.Add('    }');

                                            MatchCount := MatchCount + 1;
                                        end;
                                    // REMOVED DUPLICATE END: end;
                                // REMOVED DUPLICATE END: end;
                            // REMOVED DUPLICATE END: end;
                        // REMOVED DUPLICATE END: end;
                    // REMOVED DUPLICATE END: end;
                // REMOVED DUPLICATE END: end;
            // REMOVED DUPLICATE END: end;

            JsonBuilder.Add('  ],');
            JsonBuilder.Add('  "match_count": ' + IntToStr(MatchCount));
            JsonBuilder.Add('}');

            Result := JsonBuilder.Text;
        except
            on E: Exception do
            begin
                Result := '{"success": false, "error": "' + E.Message + '"}';
            end;
        // REMOVED DUPLICATE END: end;
    finally
        JsonBuilder.Free;
    end;
end;
// REMOVED DUPLICATE END: end;

end;
// REMOVED DUPLICATE END: end;
// REMOVED DUPLICATE END: end;
