// pcb_utils.pas
// PCB utility functions for Altium

unit pcb_utils;

interface

uses
    Classes, SysUtils, PCB, json_utils;

function GetAllNets(ROOT_DIR: String): String;
function CreateNetClass(ClassName: String; NetNamesList: TStringList): String;
function GetPCBLayerStackup(ROOT_DIR: String): String;
function GetPCBLayers(ROOT_DIR: String): String;
function SetPCBLayerVisibility(LayerName: String; IsVisible: Boolean): String;
function GetDesignRules(ROOT_DIR: String): String;
function GetAllComponentData(ROOT_DIR: String; SelectedOnly: Boolean = False): String;
function GetSelectedComponentsCoordinates(ROOT_DIR: String): String;
function GetComponentPinsFromList(ROOT_DIR: String; DesignatorsList: TStringList): String;
function MoveComponentsByDesignators(DesignatorsList: TStringList; XOffset, YOffset: TCoord; Rotation: TAngle): String;

implementation

// Helper function to convert layer object to string
function Layer2String(Layer: TLayer): String;
begin
    Result := Layer2String(Layer); // Use built-in function if available, otherwise we might need to implement mapping
    // Note: In Altium DelphiScript, Layer2String is a built-in function.
    // If it's not available in the context, we might need to map it manually.
    // For now assuming it's available as it was used in the original script.
end;

// Helper function to convert shape to string
function ShapeToString(Shape: TShape): String;
begin
    case Shape of
        eRoundedRectangular: Result := 'RoundedRectangular';
        eRectangular: Result := 'Rectangular';
        eOctagonal: Result := 'Octagonal';
        eCircleShape: Result := 'Circle';
        eArcShape: Result := 'Arc';
        else Result := 'Unknown';
    end;
end;

{..............................................................................}
{ Get All Nets - Retrieve all nets from the PCB                               }
{..............................................................................}
function GetAllNets(ROOT_DIR: String): String;
var
    Board       : IPCB_Board;
    Iterator    : IPCB_BoardIterator;
    Net         : IPCB_Net;
    NetsArray   : TStringList;
    NetProps    : TStringList;
    OutputLines : TStringList;
begin
    // Retrieve the current board
    Board := PCBServer.GetCurrentPCBBoard;
    if (Board = nil) then
    begin
        Result := '[]';
        Exit;
    end;

    // Create array for nets
    NetsArray := TStringList.Create;
    
    try
        // Create an iterator to find all nets
        Iterator := Board.BoardIterator_Create;
        Iterator.AddFilter_ObjectSet(MkSet(eNetObject));
        Iterator.AddFilter_LayerSet(AllLayers);
        Iterator.AddFilter_Method(eProcessAll);

        // Process each net
        Net := Iterator.FirstPCBObject;
        while (Net <> Nil) do
        begin
            // Create net properties
            NetProps := TStringList.Create;
            try
                AddJSONProperty(NetProps, 'name', Net.Name);
                AddJSONInteger(NetProps, 'node_count', Net.NodeCount);
                
                // Add to nets array
                NetsArray.Add(BuildJSONObject(NetProps, 1));
            finally
                NetProps.Free;
            end;
            
            // Move to next net
            Net := Iterator.NextPCBObject;
        end;

        // Clean up the iterator
        Board.BoardIterator_Destroy(Iterator);
        
        // Build the final JSON array
        OutputLines := TStringList.Create;
        try
            OutputLines.Text := BuildJSONArray(NetsArray);
            Result := WriteJSONToFile(OutputLines, ROOT_DIR+'\temp_nets_data.json');
        finally
            OutputLines.Free;
        end;
    finally
        NetsArray.Free;
    end;
end;

{..............................................................................}
{ Create Net Class - Create a class of nets                                   }
{..............................................................................}
function CreateNetClass(ClassName: String; NetNamesList: TStringList): String;
var
    Board       : IPCB_Board;
    NetClass    : IPCB_ObjectClass;
    Net         : IPCB_Net;
    ResultProps : TStringList;
    OutputLines : TStringList;
    i           : Integer;
    NetName     : String;
    SuccessCount: Integer;
begin
    // Retrieve the current board
    Board := PCBServer.GetCurrentPCBBoard;
    if (Board = nil) then
    begin
        Result := '{"success": false, "error": "No PCB document is currently active"}';
        Exit;
    end;

    ResultProps := TStringList.Create;
    SuccessCount := 0;
    
    try
        PCBServer.PreProcess;
        try
            // Check if class already exists
            NetClass := Board.GetObjectClassByName(ClassName);
            
            // If not, create it
            if (NetClass = nil) then
            begin
                NetClass := PCBServer.PCBObjectFactory(eClassObject, eNoDimension, eCreate_Default);
                NetClass.Name := ClassName;
                NetClass.Kind := eNetClass;
                Board.AddPCBObject(NetClass);
            end;
            
            // Add nets to class
            for i := 0 to NetNamesList.Count - 1 do
            begin
                NetName := Trim(NetNamesList[i]);
                Net := Board.GetNetByName(NetName);
                
                if (Net <> nil) then
                begin
                    NetClass.AddMember(Net);
                    SuccessCount := SuccessCount + 1;
                end;
            end;
            
            AddJSONBoolean(ResultProps, 'success', True);
            AddJSONProperty(ResultProps, 'class_name', ClassName);
            AddJSONInteger(ResultProps, 'nets_added', SuccessCount);
        finally
            PCBServer.PostProcess;
        end;
        
        // Build final JSON
        OutputLines := TStringList.Create;
        try
            OutputLines.Text := BuildJSONObject(ResultProps);
            Result := OutputLines.Text;
        finally
            OutputLines.Free;
        end;
    finally
        ResultProps.Free;
    end;
end;

{..............................................................................}
{ Get PCB Layer Stackup - Retrieve layer stackup information                  }
{..............................................................................}
function GetPCBLayerStackup(ROOT_DIR: String): String;
var
    Board       : IPCB_Board;
    LayerStack  : IPCB_MasterLayerStack;
    Layer       : IPCB_LayerStack_LayerObject;
    LayersArray : TStringList;
    LayerProps  : TStringList;
    OutputLines : TStringList;
begin
    // Retrieve the current board
    Board := PCBServer.GetCurrentPCBBoard;
    if (Board = nil) then
    begin
        Result := '[]';
        Exit;
    end;

    // Create array for layers
    LayersArray := TStringList.Create;
    
    try
        // Get layer stack
        LayerStack := Board.MasterLayerStack;
        if (LayerStack <> nil) then
        begin
            // Iterate through layers
            Layer := LayerStack.FirstLayer;
            while (Layer <> nil) do
            begin
                LayerProps := TStringList.Create;
                try
                    AddJSONProperty(LayerProps, 'name', Layer.Name);
                    AddJSONProperty(LayerProps, 'type', Layer2String(Layer.LayerID));
                    AddJSONNumber(LayerProps, 'thickness', CoordToMils(Layer.Thickness));
                    AddJSONNumber(LayerProps, 'dielectric_constant', Layer.DielectricConstant);
                    
                    // Add to layers array
                    LayersArray.Add(BuildJSONObject(LayerProps, 1));
                finally
                    LayerProps.Free;
                end;
                
                Layer := LayerStack.NextLayer(Layer);
            end;
        end;
        
        // Build the final JSON array
        OutputLines := TStringList.Create;
        try
            OutputLines.Text := BuildJSONArray(LayersArray);
            Result := WriteJSONToFile(OutputLines, ROOT_DIR+'\temp_stackup_data.json');
        finally
            OutputLines.Free;
        end;
    finally
        LayersArray.Free;
    end;
end;

{..............................................................................}
{ Get PCB Layers - Retrieve all available PCB layers                          }
{..............................................................................}
function GetPCBLayers(ROOT_DIR: String): String;
var
    Board       : IPCB_Board;
    Iterator    : IPCB_LayerIterator;
    Layer       : IPCB_LayerObject;
    LayersArray : TStringList;
    LayerProps  : TStringList;
    OutputLines : TStringList;
begin
    // Retrieve the current board
    Board := PCBServer.GetCurrentPCBBoard;
    if (Board = nil) then
    begin
        Result := '[]';
        Exit;
    end;

    // Create array for layers
    LayersArray := TStringList.Create;
    
    try
        // Iterate through all layers
        // Note: IPCB_LayerIterator might not be the correct way to get all layers in all versions
        // Alternative is to iterate through enum values
        
        // For this implementation, we'll use a simplified approach checking standard layers
        // This is a placeholder for a more comprehensive iteration if needed
        
        // TODO: Implement full layer iteration
        // For now, return empty array as this requires more complex API usage
        
        // Build the final JSON array
        OutputLines := TStringList.Create;
        try
            OutputLines.Text := BuildJSONArray(LayersArray);
            Result := WriteJSONToFile(OutputLines, ROOT_DIR+'\temp_layers_data.json');
        finally
            OutputLines.Free;
        end;
    finally
        LayersArray.Free;
    end;
end;

{..............................................................................}
{ Set PCB Layer Visibility - Show or hide a specific layer                    }
{..............................................................................}
function SetPCBLayerVisibility(LayerName: String; IsVisible: Boolean): String;
var
    Board       : IPCB_Board;
    LayerObj    : TLayer;
    ResultProps : TStringList;
    OutputLines : TStringList;
begin
    // Retrieve the current board
    Board := PCBServer.GetCurrentPCBBoard;
    if (Board = nil) then
    begin
        Result := '{"success": false, "error": "No PCB document is currently active"}';
        Exit;
    end;

    ResultProps := TStringList.Create;
    
    try
        // Map string to layer object
        // This is a simplified mapping, would need a full lookup table
        if LayerName = 'TopLayer' then LayerObj := eTopLayer
        else if LayerName = 'BottomLayer' then LayerObj := eBottomLayer
        else if LayerName = 'TopOverlay' then LayerObj := eTopOverlay
        else if LayerName = 'BottomOverlay' then LayerObj := eBottomOverlay
        else
        begin
            // Try to find by name
            // LayerObj := Board.LayerFromName(LayerName); // Hypothetical API
            // If not found:
            AddJSONBoolean(ResultProps, 'success', False);
            AddJSONProperty(ResultProps, 'error', 'Unknown layer: ' + LayerName);
            
            OutputLines := TStringList.Create;
            try
                OutputLines.Text := BuildJSONObject(ResultProps);
                Result := OutputLines.Text;
            finally
                OutputLines.Free;
            end;
            Exit;
        end;
        
        PCBServer.PreProcess;
        try
            Board.LayerIsDisplayed[LayerObj] := IsVisible;
            
            AddJSONBoolean(ResultProps, 'success', True);
            AddJSONProperty(ResultProps, 'layer', LayerName);
            AddJSONBoolean(ResultProps, 'visible', IsVisible);
        finally
            PCBServer.PostProcess;
        end;
        
        // Refresh view
        Client.SendMessage('PCB:Zoom', 'Action=Redraw', 255, Client.CurrentView);
        
        // Build final JSON
        OutputLines := TStringList.Create;
        try
            OutputLines.Text := BuildJSONObject(ResultProps);
            Result := OutputLines.Text;
        finally
            OutputLines.Free;
        end;
    finally
        ResultProps.Free;
    end;
end;

{..............................................................................}
{ Get Design Rules - Retrieve all design rules                                }
{..............................................................................}
function GetDesignRules(ROOT_DIR: String): String;
var
    Board         : IPCB_Board;
    BoardIterator : IPCB_BoardIterator;
    Rule          : IPCB_Rule;
    RulesArray    : TStringList;
    RuleProps     : TStringList;
    OutputLines   : TStringList;
begin
    // Retrieve the current board
    Board := PCBServer.GetCurrentPCBBoard;
    if (Board = Nil) then
    begin
        Result := '[]';
        Exit;
    end;

    // Create array for rules
    RulesArray := TStringList.Create;
    
    try
        // Retrieve the iterator
        BoardIterator := Board.BoardIterator_Create;
        BoardIterator.AddFilter_ObjectSet(MkSet(eRuleObject));
        BoardIterator.AddFilter_LayerSet(AllLayers);
        BoardIterator.AddFilter_Method(eProcessAll);

        // Process each rule
        Rule := BoardIterator.FirstPCBObject;
        while (Rule <> Nil) do
        begin
            // Create rule properties
            RuleProps := TStringList.Create;
            try
                // Add rule descriptor
                AddJSONProperty(RuleProps, 'descriptor', Rule.Descriptor);
                AddJSONProperty(RuleProps, 'rule_kind', Rule.GetState_ShortDescriptorString);
                AddJSONProperty(RuleProps, 'filter1', Rule.Scope1Expression);
                AddJSONProperty(RuleProps, 'filter2', Rule.Scope2Expression);

                // Add to rules array
                RulesArray.Add(BuildJSONObject(RuleProps, 1));
            finally
                RuleProps.Free;
            end;
            
            // Move to next rule
            Rule := BoardIterator.NextPCBObject;
        end;

        // Clean up the iterator
        Board.BoardIterator_Destroy(BoardIterator);
        
        // Build the final JSON array
        OutputLines := TStringList.Create;
        try
            OutputLines.Text := BuildJSONArray(RulesArray);
            Result := WriteJSONToFile(OutputLines, ROOT_DIR+'\temp_rules_data.json');
        finally
            OutputLines.Free;
        end;
    finally
        RulesArray.Free;
    end;
end;

// Function to get all component data from the PCB
function GetAllComponentData(ROOT_DIR: String; SelectedOnly: Boolean = False): String;
var
    Board       : IPCB_Board;
    Iterator    : IPCB_BoardIterator;
    Component   : IPCB_Component;
    ComponentsArray : TStringList;
    ComponentProps : TStringList;
    Rect        : TCoordRect;
    xorigin, yorigin : Integer;
    i           : Integer;
    ComponentCount : Integer;
    OutputLines : TStringList;
begin
    // Retrieve the current board
    Board := PCBServer.GetCurrentPCBBoard;
    if (Board = nil) then
    begin
        Result := '[]';
        Exit;
    end;
    
    // Get board origin coordinates
    xorigin := Board.XOrigin;
    yorigin := Board.YOrigin;

    // Create array for components
    ComponentsArray := TStringList.Create;
    
    try
        // Create an iterator to find all components
        Iterator := Board.BoardIterator_Create;
        Iterator.AddFilter_ObjectSet(MkSet(eComponentObject));
        Iterator.AddFilter_IPCB_LayerSet(LayerSet.AllLayers);
        Iterator.AddFilter_Method(eProcessAll);

        // Process each component
        Component := Iterator.FirstPCBObject;
        while (Component <> Nil) do
        begin
            // Process either all components or only selected ones
            if ((not SelectedOnly) or (SelectedOnly and Component.Selected)) then
            begin
                // Create component properties
                ComponentProps := TStringList.Create;
                try
                    // Get bounds
                    Rect := Component.BoundingRectangleNoNameComment;
                    
                    // Add properties
                    AddJSONProperty(ComponentProps, 'designator', Component.Name.Text);
                    AddJSONProperty(ComponentProps, 'name', Component.Identifier);
                    AddJSONProperty(ComponentProps, 'description', Component.SourceDescription);
                    AddJSONProperty(ComponentProps, 'footprint', Component.Pattern);
                    AddJSONProperty(ComponentProps, 'layer', Layer2String(Component.Layer));
                    AddJSONNumber(ComponentProps, 'x', CoordToMils(Component.x - xorigin));
                    AddJSONNumber(ComponentProps, 'y', CoordToMils(Component.y - yorigin));
                    AddJSONNumber(ComponentProps, 'width', CoordToMils(Rect.Right - Rect.Left));
                    AddJSONNumber(ComponentProps, 'height', CoordToMils(Rect.Bottom - Rect.Top));
                    AddJSONNumber(ComponentProps, 'rotation', Component.Rotation);
                    
                    // Add to components array
                    ComponentsArray.Add(BuildJSONObject(ComponentProps, 1));
                finally
                    ComponentProps.Free;
                end;
            end;
            
            // Move to next component
            Component := Iterator.NextPCBObject;
        end;

        // Clean up the iterator
        Board.BoardIterator_Destroy(Iterator);
        
        // Build the final JSON array
        OutputLines := TStringList.Create;
        try
            OutputLines.Text := BuildJSONArray(ComponentsArray);
            Result := WriteJSONToFile(OutputLines, ROOT_DIR+'\temp_component_data.json');
        finally
            OutputLines.Free;
        end;
    finally
        ComponentsArray.Free;
    end;
end;

// Example refactored function using the new JSON utilities
function GetSelectedComponentsCoordinates(ROOT_DIR: String): String;
var
    Board       : IPCB_Board;
    Component   : IPCB_Component;
    Rect        : TCoordRect;
    xorigin, yorigin : Integer;
    ComponentsArray : TStringList;
    ComponentProps : TStringList;
    OutputLines : TStringList;
    i : Integer;
begin
    Result := '';

    // Retrieve the current board
    Board := PCBServer.GetCurrentPCBBoard;
    if Board = nil then Exit;

    // Get board origin coordinates
    xorigin := Board.XOrigin;
    yorigin := Board.YOrigin;

    // Create output and components array
    OutputLines := TStringList.Create;
    ComponentsArray := TStringList.Create;
    
    try
        // Process each selected component
        for i := 0 to Board.SelectecObjectCount - 1 do
        begin
            // Only process selected components
            if Board.SelectecObject[i].ObjectId = eComponentObject then
            begin
                // Cast to component type
                Component := Board.SelectecObject[i];
                
                // Get component bounds
                Rect := Component.BoundingRectangleNoNameComment;
                
                // Create component properties
                ComponentProps := TStringList.Create;
                try
                    // Add component properties
                    AddJSONProperty(ComponentProps, 'designator', Component.Name.Text);
                    AddJSONNumber(ComponentProps, 'x', CoordToMils(Component.x - xorigin));
                    AddJSONNumber(ComponentProps, 'y', CoordToMils(Component.y - yorigin));
                    AddJSONNumber(ComponentProps, 'width', CoordToMils(Rect.Right - Rect.Left));
                    AddJSONNumber(ComponentProps, 'height', CoordToMils(Rect.Bottom - Rect.Top));
                    AddJSONNumber(ComponentProps, 'rotation', Component.Rotation);
                    
                    // Add component JSON to array
                    ComponentsArray.Add(BuildJSONObject(ComponentProps, 1));
                finally
                    ComponentProps.Free;
                end;
            end;
        end;
        
        // If components found, build array
        if ComponentsArray.Count > 0 then
            Result := BuildJSONArray(ComponentsArray)
        else
            Result := '[]';
            
        // For consistency with existing code, write to file and read back
        OutputLines.Text := Result;
        Result := WriteJSONToFile(OutputLines, ROOT_DIR+'\temp_selected_components.json');
    finally
        ComponentsArray.Free;
        OutputLines.Free;
    end;
end;

// Function to get pin data for specified components
function GetComponentPinsFromList(ROOT_DIR: String; DesignatorsList: TStringList): String;
var
    Board           : IPCB_Board;
    Component       : IPCB_Component;
    ComponentsArray : TStringList;
    CompProps       : TStringList;
    PinsArray       : TStringList;
    GrpIter         : IPCB_GroupIterator;
    Pad             : IPCB_Pad;
    NetName         : String;
    xorigin, yorigin : Integer;
    PinProps        : TStringList;
    PinCount, PinsProcessed : Integer;
    Designator      : String;
    i               : Integer;
    OutputLines     : TStringList;
begin
    // Retrieve the current board
    Board := PCBServer.GetCurrentPCBBoard;
    if (Board = nil) then
    begin
        Result := '[]';
        Exit;
    end;
    
    // Get board origin coordinates
    xorigin := Board.XOrigin;
    yorigin := Board.YOrigin;

    // Create array for components
    ComponentsArray := TStringList.Create;
    
    try
        // Process each designator
        for i := 0 to DesignatorsList.Count - 1 do
        begin
            Designator := Trim(DesignatorsList[i]);
            
            // Use direct function to get component by designator
            Component := Board.GetPcbComponentByRefDes(Designator);
            
            if (Component <> Nil) then
            begin
                // Create component properties
                CompProps := TStringList.Create;
                PinsArray := TStringList.Create;
                
                try
                    // Add designator to component
                    AddJSONProperty(CompProps, 'designator', Component.Name.Text);
                    
                    // Create pad iterator
                    GrpIter := Component.GroupIterator_Create;
                    GrpIter.SetState_FilterAll;
                    GrpIter.AddFilter_ObjectSet(MkSet(ePadObject));
                    
                    // Count pins
                    PinCount := 0;
                    Pad := GrpIter.FirstPCBObject;
                    while (Pad <> Nil) do
                    begin
                        if Pad.InComponent then
                            PinCount := PinCount + 1;
                        Pad := GrpIter.NextPCBObject;
                    end;
                    
                    // Reset iterator
                    Component.GroupIterator_Destroy(GrpIter);
                    GrpIter := Component.GroupIterator_Create;
                    GrpIter.SetState_FilterAll;
                    GrpIter.AddFilter_ObjectSet(MkSet(ePadObject));
                    
                    // Process each pad
                    PinsProcessed := 0;
                    Pad := GrpIter.FirstPCBObject;
                    while (Pad <> Nil) do
                    begin
                        if Pad.InComponent then
                        begin
                            // Get net name if connected
                            if (Pad.Net <> Nil) then
                                NetName := Pad.Net.Name
                            else
                                NetName := '';
                                
                            // Create pin properties
                            PinProps := TStringList.Create;
                            try
                                AddJSONProperty(PinProps, 'name', Pad.Name);
                                AddJSONProperty(PinProps, 'net', NetName);
                                AddJSONNumber(PinProps, 'x', CoordToMils(Pad.x - xorigin));
                                AddJSONNumber(PinProps, 'y', CoordToMils(Pad.y - yorigin));
                                AddJSONNumber(PinProps, 'rotation', Pad.Rotation);
                                AddJSONProperty(PinProps, 'layer', Layer2String(Pad.Layer));
                                AddJSONNumber(PinProps, 'width', CoordToMils(Pad.XSizeOnLayer[Pad.Layer]));
                                AddJSONNumber(PinProps, 'height', CoordToMils(Pad.YSizeOnLayer[Pad.Layer]));
                                AddJSONProperty(PinProps, 'shape', ShapeToString(Pad.ShapeOnLayer[Pad.Layer]));
                                
                                // Add to pins array
                                PinsArray.Add(BuildJSONObject(PinProps, 3));
                                
                                // Increment counter
                                PinsProcessed := PinsProcessed + 1;
                            finally
                                PinProps.Free;
                            end;
                        end;
                        
                        Pad := GrpIter.NextPCBObject;
                    end;
                    
                    // Clean up iterator
                    Component.GroupIterator_Destroy(GrpIter);
                    
                    // Add pins array to component
                    CompProps.Add(BuildJSONArray(PinsArray, 'pins', 1));
                    
                    // Add to components array
                    ComponentsArray.Add(BuildJSONObject(CompProps, 1));
                finally
                    CompProps.Free;
                    PinsArray.Free;
                end;
            end
            else
            begin
                // Component not found, add empty component
                CompProps := TStringList.Create;
                try
                    AddJSONProperty(CompProps, 'designator', Designator);
                    CompProps.Add('"pins": []');
                    
                    // Add to components array
                    ComponentsArray.Add(BuildJSONObject(CompProps, 1));
                finally
                    CompProps.Free;
                end;
            end;
        end;
        
        // Build the final JSON array
        OutputLines := TStringList.Create;
        try
            OutputLines.Text := BuildJSONArray(ComponentsArray);
            Result := WriteJSONToFile(OutputLines, ROOT_DIR+'\temp_pins_data.json');
        finally
            OutputLines.Free;
        end;
    finally
        ComponentsArray.Free;
    end;
end;

// Function to move components by X and Y offsets and set rotation
function MoveComponentsByDesignators(DesignatorsList: TStringList; XOffset, YOffset: TCoord; Rotation: TAngle): String;
var
    Board          : IPCB_Board;
    Component      : IPCB_Component;
    ResultProps    : TStringList;
    MissingArray   : TStringList;
    Designator     : String;
    i              : Integer;
    MovedCount     : Integer;
    OutputLines    : TStringList;
begin
    // Retrieve the current board
    Board := PCBServer.GetCurrentPCBBoard;
    if (Board = nil) then
    begin
        Result := 'ERROR: No PCB document is currently active';
        Exit;
    end;
    
    // Create output properties
    ResultProps := TStringList.Create;
    MissingArray := TStringList.Create;
    MovedCount := 0;
    
    try
        // Start transaction
        PCBServer.PreProcess;
        
        // Process each designator
        for i := 0 to DesignatorsList.Count - 1 do
        begin
            Designator := Trim(DesignatorsList[i]);
            
            // Use direct function to get component by designator
            Component := Board.GetPcbComponentByRefDes(Designator);
            
            if (Component <> Nil) then
            begin
                // Begin modify
                PCBServer.SendMessageToRobots(Component.I_ObjectAddress, c_Broadcast, PCBM_BeginModify, c_NoEventData);
                
                // Move the component by the specified offsets
                Component.MoveByXY(XOffset, YOffset);
                
                // Set rotation if specified (non-zero)
                if (Rotation <> 0) then
                    Component.Rotation := Rotation;
                
                // End modify
                PCBServer.SendMessageToRobots(Component.I_ObjectAddress, c_Broadcast, PCBM_EndModify, c_NoEventData);
                
                MovedCount := MovedCount + 1;
            end
            else
            begin
                // Add to missing designators list
                MissingArray.Add('"' + JSONEscapeString(Designator) + '"');
            end;
        end;
        
        // End transaction
        PCBServer.PostProcess;
        
        // Update PCB document
        Client.SendMessage('PCB:Zoom', 'Action=Redraw', 255, Client.CurrentView);
        
        // Create result JSON
        AddJSONInteger(ResultProps, 'moved_count', MovedCount);
        
        // Add missing designators array
        if (MissingArray.Count > 0) then
            ResultProps.Add(BuildJSONArray(MissingArray, 'missing_designators'))
        else
            ResultProps.Add('"missing_designators": []');
        
        // Build final JSON
        OutputLines := TStringList.Create;
        try
            OutputLines.Text := BuildJSONObject(ResultProps);
            Result := OutputLines.Text;
        finally
            OutputLines.Free;
        end;
    finally
        ResultProps.Free;
        MissingArray.Free;
    end;
end;

end.
