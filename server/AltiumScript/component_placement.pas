// component_placement.pas
// Functions for placing, deleting, and manipulating components on PCB boards

unit component_placement;

interface

function FindFootprintInLibraries(const FootprintName: String): IPCB_LibComponent;
function CopyFootprintPrimitives(LibFootprint: IPCB_LibComponent; Component: IPCB_Component): Boolean;
function PlaceComponent(const Designator, Footprint: String; const X, Y: Double; const Layer, Rotation: Integer): String;
function DeleteComponent(const Designator: String): String;
function PlaceComponentArray(const Footprint, RefDes: String; const StartX, StartY, SpacingX, SpacingY: Double; const Rows, Cols: Integer): String;
function AlignComponents(const DesignatorsStr: String; const Alignment: String): String;

implementation

uses
    globals;

{..............................................................................}
{ Helper function to find a footprint in loaded libraries                     }
{..............................................................................}
function FindFootprintInLibraries(const FootprintName: String): IPCB_LibComponent;
var
    IntLibManager: IIntegratedLibraryManager;
    LibraryModel: IComponentLibraryModel;
    CompInfoIter: IIterator;
    CompInfo: IComponentInfo;
    ModelDatafile: IComponentModelDatafile;
    i: Integer;
begin
    Result := nil;
    try
        // Get the integrated library manager
        IntLibManager := IntegratedLibraryManager;
        if IntLibManager = nil then Exit;

        // Iterate through all loaded libraries
        for i := 0 to IntLibManager.InstalledLibraryCount - 1 do
        begin
            LibraryModel := IntLibManager.InstalledLibrary[i];
            if LibraryModel = nil then Continue;

            // Iterate through components in the library
            CompInfoIter := LibraryModel.ComponentIterator;
            if CompInfoIter = nil then Continue;

            CompInfo := CompInfoIter.FirstComponent;
            while CompInfo <> nil do
            begin
                // Check footprint models
                ModelDatafile := CompInfo.GetModelDatafile(cDocKind_PcbLib);
                if ModelDatafile <> nil then
                begin
                    if ModelDatafile.ModelName = FootprintName then
                    begin
                        // Found the footprint - load it
                        Result := PcbServer.LoadLibraryComponent(
                            LibraryModel.LibraryName,
                            CompInfo.LibReference,
                            cDocKind_PcbLib,
                            FootprintName
                        );
                        Exit;
                    end;
                end;

                CompInfo := CompInfoIter.NextComponent;
            end;
        end;
    except
        Result := nil;
    end;
end;

{..............................................................................}
{ Helper function to copy primitives from library footprint to component      }
{..............................................................................}
function CopyFootprintPrimitives(LibFootprint: IPCB_LibComponent; Component: IPCB_Component): Boolean;
var
    Iterator: IPCB_GroupIterator;
    Primitive: IPCB_Primitive;
    NewPrimitive: IPCB_Primitive;
begin
    Result := True;
    try
        Iterator := LibFootprint.GroupIterator_Create;
        Iterator.AddFilter_ObjectSet(MkSet(eTrackObject, eArcObject, ePadObject, eTextObject, eFillObject, eRegionObject));

        Primitive := Iterator.FirstPCBObject;
        while Primitive <> nil do
        begin
            // Clone primitive
            NewPrimitive := Primitive.Replicate;
            if NewPrimitive <> nil then
            begin
                Component.AddPCBObject(NewPrimitive);
            end;

            Primitive := Iterator.NextPCBObject;
        end;

        LibFootprint.GroupIterator_Destroy(Iterator);
    except
        Result := False;
    end;
end;

{..............................................................................}
{ Place a single component on the PCB                                         }
{..............................................................................}
function PlaceComponent(
    const Designator, Footprint: String;
    const X, Y: Double;
    const Layer, Rotation: Integer
): String;
var
    Board: IPCB_Board;
    Component: IPCB_Component;
    LibFootprint: IPCB_LibComponent;
    JsonResult: TStringList;
begin
    JsonResult := TStringList.Create;
    try
        Board := GetPCBServer.GetCurrentPCBBoard;
        if Board = nil then
        begin
            Result := '{"success": false, "error": "No board open"}';
            Exit;
        end;

        // Find footprint in libraries
        LibFootprint := FindFootprintInLibraries(Footprint);
        if LibFootprint = nil then
        begin
            Result := '{"success": false, "error": "Footprint not found: ' + Footprint + '"}';
            Exit;
        end;

        GetPCBServer.PreProcess;
        try
            // Create component
            Component := GetPCBServer.PCBObjectFactory(eComponentObject, eNoDimension, eCreate_Default);
            if Component = nil then
            begin
                Result := '{"success": false, "error": "Failed to create component"}';
                Exit;
            end;

            // Set basic properties
            Component.Name := TDynamicString(Designator);
            Component.Pattern := TDynamicString(Footprint);

            // Set position (convert from mm to internal units)
            Component.x := MMsToCoord(X);
            Component.y := MMsToCoord(Y);

            // Set layer
            if Layer = 0 then
                Component.Layer := eTopLayer
            else
                Component.Layer := eBottomLayer;

            // Set rotation
            Component.Rotation := Rotation;

            // Copy footprint primitives
            if not CopyFootprintPrimitives(LibFootprint, Component) then
            begin
                Result := '{"success": false, "error": "Failed to copy footprint primitives"}';
                Exit;
            end;

            // Add to board
            Board.AddPCBObject(Component);

            // Register component with board
            GetPCBServer.SendMessageToRobots(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Component.I_ObjectAddress);

            JsonResult.Add('{');
            JsonResult.Add('  "success": true,');
            JsonResult.Add('  "designator": "' + Designator + '",');
            JsonResult.Add('  "footprint": "' + Footprint + '",');
            JsonResult.Add('  "x": ' + FloatToStr(X) + ',');
            JsonResult.Add('  "y": ' + FloatToStr(Y) + ',');
            JsonResult.Add('  "layer": ' + IntToStr(Layer) + ',');
            JsonResult.Add('  "rotation": ' + IntToStr(Rotation));
            JsonResult.Add('}');
            Result := JsonResult.Text;
        finally
            GetPCBServer.PostProcess;
        end;

        // Refresh view
        GetClient.SendMessage('PCB:Zoom', 'Action=Redraw', 255, GetClient.CurrentView);

    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
    JsonResult.Free;
end;

{..............................................................................}
{ Delete a component by designator                                            }
{..............................................................................}
function DeleteComponent(const Designator: String): String;
var
    Board: IPCB_Board;
    Component: IPCB_Component;
begin
    Result := '';
    try
        Board := GetPCBServer.GetCurrentPCBBoard;
        if Board = nil then
        begin
            Result := '{"success": false, "error": "No board open"}';
            Exit;
        end;

        // Find component
        Component := Board.GetPcbComponentByRefDes(Designator);
        if Component = nil then
        begin
            Result := '{"success": false, "error": "Component not found: ' + Designator + '"}';
            Exit;
        end;

        GetPCBServer.PreProcess;
        try
            // Remove component
            Board.RemovePCBObject(Component);
            GetPCBServer.DestroyPCBObject(Component);

            Result := '{"success": true, "message": "Component deleted: ' + Designator + '"}';
        finally
            GetPCBServer.PostProcess;
        end;

        // Refresh
        GetClient.SendMessage('PCB:Zoom', 'Action=Redraw', 255, GetClient.CurrentView);

    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
end;

{..............................................................................}
{ Place an array of components in a grid pattern                              }
{..............................................................................}
function PlaceComponentArray(
    const Footprint, RefDes: String;
    const StartX, StartY, SpacingX, SpacingY: Double;
    const Rows, Cols: Integer
): String;
var
    Row, Col: Integer;
    X, Y: Double;
    Designator: String;
    JsonBuilder: TStringList;
    PlaceResult: String;
    ComponentCount: Integer;
begin
    JsonBuilder := TStringList.Create;
    try
        JsonBuilder.Add('{');
        JsonBuilder.Add('  "success": true,');
        JsonBuilder.Add('  "count": ' + IntToStr(Rows * Cols) + ',');
        JsonBuilder.Add('  "components": [');

        ComponentCount := 0;
        for Row := 0 to Rows - 1 do
        begin
            for Col := 0 to Cols - 1 do
            begin
                // Calculate position
                X := StartX + (Col * SpacingX);
                Y := StartY + (Row * SpacingY);

                // Generate designator (e.g., R1, R2, R3...)
                Designator := RefDes + IntToStr(Row * Cols + Col + 1);

                // Place component (default to top layer, 0 rotation)
                PlaceResult := PlaceComponent(Designator, Footprint, X, Y, 0, 0);

                // Add to result array
                if ComponentCount > 0 then
                    JsonBuilder.Add('    ,');
                JsonBuilder.Add('    "' + Designator + '"');

                ComponentCount := ComponentCount + 1;
            end;
        end;

        JsonBuilder.Add('  ]');
        JsonBuilder.Add('}');

        Result := JsonBuilder.Text;
    finally
        JsonBuilder.Free;
    end;
end;

{..............................................................................}
{ Align multiple components to a common edge                                  }
{..............................................................................}
function AlignComponents(
    const DesignatorsStr: String;
    const Alignment: String
): String;
var
    Board: IPCB_Board;
    Components: array[0..99] of IPCB_Component;
    ComponentCount: Integer;
    DesignatorsList: TStringList;
    i: Integer;
    AlignCoord: TCoord;
    Component: IPCB_Component;
    JsonResult: TStringList;
    Designator: String;
begin
    JsonResult := TStringList.Create;
    DesignatorsList := TStringList.Create;
    try
        Board := GetPCBServer.GetCurrentPCBBoard;
        if Board = nil then
        begin
            Result := '{"success": false, "error": "No board open"}';
            Exit;
        end;

        // Parse comma-separated designators
        DesignatorsList.Delimiter := ',';
        DesignatorsList.DelimitedText := DesignatorsStr;

        if DesignatorsList.Count = 0 then
        begin
            Result := '{"success": false, "error": "No designators provided"}';
            Exit;
        end;

        if DesignatorsList.Count > 100 then
        begin
            Result := '{"success": false, "error": "Too many components (max 100)"}';
            Exit;
        end;

        // Get all components
        ComponentCount := DesignatorsList.Count;
        for i := 0 to ComponentCount - 1 do
        begin
            Designator := Trim(DesignatorsList[i]);
            Components[i] := Board.GetPcbComponentByRefDes(Designator);
            if Components[i] = nil then
            begin
                Result := '{"success": false, "error": "Component not found: ' + Designator + '"}';
                Exit;
            end;
        end;

        // Calculate alignment coordinate based on alignment type
        if Alignment = 'left' then
        begin
            AlignCoord := Components[0].x;
            for i := 1 to ComponentCount - 1 do
                if Components[i].x < AlignCoord then
                    AlignCoord := Components[i].x;
        end
        else if Alignment = 'right' then
        begin
            AlignCoord := Components[0].x;
            for i := 1 to ComponentCount - 1 do
                if Components[i].x > AlignCoord then
                    AlignCoord := Components[i].x;
        end
        else if Alignment = 'top' then
        begin
            AlignCoord := Components[0].y;
            for i := 1 to ComponentCount - 1 do
                if Components[i].y > AlignCoord then
                    AlignCoord := Components[i].y;
        end
        else if Alignment = 'bottom' then
        begin
            AlignCoord := Components[0].y;
            for i := 1 to ComponentCount - 1 do
                if Components[i].y < AlignCoord then
                    AlignCoord := Components[i].y;
        end
        else
        begin
            Result := '{"success": false, "error": "Invalid alignment: ' + Alignment + '"}';
            Exit;
        end;

        // Apply alignment
        GetPCBServer.PreProcess;
        try
            for i := 0 to ComponentCount - 1 do
            begin
                Component := Components[i];
                if (Alignment = 'left') or (Alignment = 'right') then
                    Component.x := AlignCoord
                else
                    Component.y := AlignCoord;
            end;
        finally
            GetPCBServer.PostProcess;
        end;

        // Refresh
        GetClient.SendMessage('PCB:Zoom', 'Action=Redraw', 255, GetClient.CurrentView);

        JsonResult.Add('{');
        JsonResult.Add('  "success": true,');
        JsonResult.Add('  "message": "Components aligned",');
        JsonResult.Add('  "alignment": "' + Alignment + '",');
        JsonResult.Add('  "count": ' + IntToStr(ComponentCount));
        JsonResult.Add('}');
        Result := JsonResult.Text;

    except
        Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;

    JsonResult.Free;
    DesignatorsList.Free;
end;



end.
