// pcb_utils.pas
// PCB utility functions for Altium

unit pcb_utils;

interface

function Layer2String(Layer: TLayer): String;
function ShapeToString(Shape: TShape): String;
function GetAllNets(ROOT_DIR: String): String;
function CreateNewNetClass(InClassName: String; InNetNames: TStringList): String;
function GetPCBLayerStackup(ROOT_DIR: String): String;
function GetPCBLayers(ROOT_DIR: String): String;
function SetPCBLayerVisibility(LayerNamesList: TStringList; Visible: Boolean): String;
function GetDesignRules(ROOT_DIR: String): String;
function GetAllComponentData(ROOT_DIR: String; SelectedOnly: Boolean = False): String;
function GetSelectedComponentsCoordinates(ROOT_DIR: String): String;
function GetComponentPinsFromList(ROOT_DIR: String; DesignatorsList: TStringList): String;
function MoveComponentsByDesignators(DesignatorsList: TStringList; XOffset, YOffset: TCoord; Rotation: TAngle): String;
function GetBoardOutline(ROOT_DIR: String): String;

implementation

uses
    globals;

// Helper function to convert layer object to string
function Layer2String(Layer: TLayer): String;
begin
    if Layer = eTopLayer then Result := 'TopLayer'
    else if Layer = eBottomLayer then Result := 'BottomLayer'
    else if Layer = eTopOverlay then Result := 'TopOverlay'
    else if Layer = eBottomOverlay then Result := 'BottomOverlay'
    else if Layer = eMidLayer1 then Result := 'MidLayer1'
    else if Layer = eMidLayer2 then Result := 'MidLayer2'
    else if Layer = eMidLayer3 then Result := 'MidLayer3'
    else if Layer = eMidLayer4 then Result := 'MidLayer4'
    else if Layer = eMidLayer5 then Result := 'MidLayer5'
    else if Layer = eMidLayer6 then Result := 'MidLayer6'
    else if Layer = eMidLayer7 then Result := 'MidLayer7'
    else if Layer = eMidLayer8 then Result := 'MidLayer8'
    else if Layer = eMidLayer9 then Result := 'MidLayer9'
    else if Layer = eMidLayer10 then Result := 'MidLayer10'
    else if Layer = eMidLayer11 then Result := 'MidLayer11'
    else if Layer = eMidLayer12 then Result := 'MidLayer12'
    else if Layer = eMidLayer13 then Result := 'MidLayer13'
    else if Layer = eMidLayer14 then Result := 'MidLayer14'
    else if Layer = eMidLayer15 then Result := 'MidLayer15'
    else if Layer = eMidLayer16 then Result := 'MidLayer16'
    else if Layer = eMidLayer17 then Result := 'MidLayer17'
    else if Layer = eMidLayer18 then Result := 'MidLayer18'
    else if Layer = eMidLayer19 then Result := 'MidLayer19'
    else if Layer = eMidLayer20 then Result := 'MidLayer20'
    else if Layer = eMidLayer21 then Result := 'MidLayer21'
    else if Layer = eMidLayer22 then Result := 'MidLayer22'
    else if Layer = eMidLayer23 then Result := 'MidLayer23'
    else if Layer = eMidLayer24 then Result := 'MidLayer24'
    else if Layer = eMidLayer25 then Result := 'MidLayer25'
    else if Layer = eMidLayer26 then Result := 'MidLayer26'
    else if Layer = eMidLayer27 then Result := 'MidLayer27'
    else if Layer = eMidLayer28 then Result := 'MidLayer28'
    else if Layer = eMidLayer29 then Result := 'MidLayer29'
    else if Layer = eMidLayer30 then Result := 'MidLayer30'
    else if Layer = eMultiLayer then Result := 'MultiLayer'
    else if Layer = eKeepOutLayer then Result := 'KeepOutLayer'
    else if Layer = eMechanical1 then Result := 'Mechanical1'
    else if Layer = eMechanical2 then Result := 'Mechanical2'
    else if Layer = eMechanical3 then Result := 'Mechanical3'
    else if Layer = eMechanical4 then Result := 'Mechanical4'
    else if Layer = eMechanical5 then Result := 'Mechanical5'
    else if Layer = eMechanical6 then Result := 'Mechanical6'
    else if Layer = eMechanical7 then Result := 'Mechanical7'
    else if Layer = eMechanical8 then Result := 'Mechanical8'
    else if Layer = eMechanical9 then Result := 'Mechanical9'
    else if Layer = eMechanical10 then Result := 'Mechanical10'
    else if Layer = eMechanical11 then Result := 'Mechanical11'
    else if Layer = eMechanical12 then Result := 'Mechanical12'
    else if Layer = eMechanical13 then Result := 'Mechanical13'
    else if Layer = eMechanical14 then Result := 'Mechanical14'
    else if Layer = eMechanical15 then Result := 'Mechanical15'
    else if Layer = eMechanical16 then Result := 'Mechanical16'
    else if Layer = eTopSolder then Result := 'TopSolder'
    else if Layer = eBottomSolder then Result := 'BottomSolder'
    else if Layer = eTopPaste then Result := 'TopPaste'
    else if Layer = eBottomPaste then Result := 'BottomPaste'
    else if Layer = eDrillGuide then Result := 'DrillGuide'
    else if Layer = eKeepOutLayer then Result := 'KeepOutLayer'
    else if Layer = eDrillDrawing then Result := 'DrillDrawing'
    else Result := 'Unknown';
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
    Board := GetPCBServer.GetCurrentPCBBoard;
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
                // Note: NodeCount property doesn't exist in IPCB_Net
                // To get node count, would need to iterate through net primitives

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
function CreateNewNetClass(InClassName: String; InNetNames: TStringList): String;
var
    Board       : IPCB_Board;
    NewNetClass : IPCB_ObjectClass;
    ExistingClass: IPCB_ObjectClass;
    Iterator    : IPCB_BoardIterator;
    Net         : IPCB_Net;
    ResultProps : TStringList;
    OutputLines : TStringList;
    i           : Integer;
    NetName     : String;
    SuccessCount: Integer;
begin
    // Retrieve the current board
    Board := GetPCBServer.GetCurrentPCBBoard;
    if (Board = nil) then
    begin
        Result := '{"success": false, "error": "No PCB document is currently active"}';
        Exit;
    end;

    ResultProps := TStringList.Create;
    SuccessCount := 0;

    try
        GetPCBServer.PreProcess;
        try
            // Check if class already exists using an iterator
            NewNetClass := nil;
            Iterator := Board.BoardIterator_Create;
            Iterator.AddFilter_ObjectSet(MkSet(eClassObject));
            Iterator.AddFilter_LayerSet(AllLayers);
            Iterator.AddFilter_Method(eProcessAll);

            ExistingClass := Iterator.FirstPCBObject;
            while (ExistingClass <> nil) do
            begin
                if (ExistingClass.MemberKind = eClassMemberKind_Net) and (ExistingClass.Name = InClassName) then
                begin
                    NewNetClass := ExistingClass;
                    Break;
                end;
                ExistingClass := Iterator.NextPCBObject;
            end;
            Board.BoardIterator_Destroy(Iterator);

            // If not found, create it
            if (NewNetClass = nil) then
            begin
                NewNetClass := GetPCBServer.PCBClassFactoryByClassMember(eClassMemberKind_Net);
                NewNetClass.SuperClass := False;
                NewNetClass.Name := InClassName;
                Board.AddPCBObject(NewNetClass);
            end;
            
            // Add nets to class
            for i := 0 to InNetNames.Count - 1 do
            begin
                NetName := Trim(InNetNames[i]);

                // Find the net using an iterator
                Iterator := Board.BoardIterator_Create;
                Iterator.AddFilter_ObjectSet(MkSet(eNetObject));
                Iterator.AddFilter_LayerSet(AllLayers);
                Iterator.AddFilter_Method(eProcessAll);

                Net := Iterator.FirstPCBObject;
                while (Net <> nil) do
                begin
                    if Net.Name = NetName then
                    begin
                        NewNetClass.AddMember(Net);
                        SuccessCount := SuccessCount + 1;
                        Break;
                    end;
                    Net := Iterator.NextPCBObject;
                end;

                Board.BoardIterator_Destroy(Iterator);
            end;
            
            AddJSONBoolean(ResultProps, 'success', True);
            AddJSONProperty(ResultProps, 'class_name', InClassName);
            AddJSONInteger(ResultProps, 'nets_added', SuccessCount);
        finally
            GetPCBServer.PostProcess;
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
    LayerStack  : IPCB_LayerStack_V7;
    Layer       : IPCB_LayerObject_V7;
    LayersArray : TStringList;
    LayerProps  : TStringList;
    OutputLines : TStringList;
    i           : Integer;
begin
    // Retrieve the current board
    Board := GetPCBServer.GetCurrentPCBBoard;
    if (Board = nil) then
    begin
        Result := '[]';
        Exit;
    end;

    // Create array for layers
    LayersArray := TStringList.Create;

    try
        // Get layer stack
        LayerStack := Board.LayerStack_V7;
        if (LayerStack <> nil) then
        begin
            // Iterate through layers (with safety limit)
            Layer := LayerStack.FirstLayer;
            i := 1;
            while (Layer <> nil) and (i <= 32) do
            begin
                LayerProps := TStringList.Create;
                try
                    AddJSONProperty(LayerProps, 'name', Layer.Name);
                    // Check if it's a signal or plane layer
                    if ILayer.IsSignalLayer(Layer.LayerID) then
                        AddJSONProperty(LayerProps, 'type', Layer2String(Layer.LayerID))
                    else
                        AddJSONProperty(LayerProps, 'type', 'InternalPlane');
                    AddJSONNumber(LayerProps, 'thickness', CoordToMils(Layer.CopperThickness));

                    // Dielectric properties are on the Dielectric sub-object
                    if Layer.Dielectric <> nil then
                        AddJSONNumber(LayerProps, 'dielectric_constant', Layer.Dielectric.DielectricConstant)
                    else
                        AddJSONNumber(LayerProps, 'dielectric_constant', 0);

                    // Add to layers array
                    LayersArray.Add(BuildJSONObject(LayerProps, 1));
                finally
                    LayerProps.Free;
                end;

                Inc(i);
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
    LayerStack  : IPCB_LayerStack_V7;
    Layer       : IPCB_LayerObject_V7;
    LayersArray : TStringList;
    LayerProps  : TStringList;
    OutputLines : TStringList;
    MechLayer   : IPCB_MechanicalLayer;
    i           : Integer;
begin
    // Retrieve the current board
    Board := GetPCBServer.GetCurrentPCBBoard;
    if (Board = nil) then
    begin
        Result := '[]';
        Exit;
    end;

    // Create array for layers
    LayersArray := TStringList.Create;

    try
        LayerStack := Board.LayerStack_V7;
        if (LayerStack <> nil) then
        begin
            // Iterate through signal/plane layers (with safety limit)
            Layer := LayerStack.FirstLayer;
            i := 1;
            while (Layer <> nil) and (i <= 32) do
            begin
                LayerProps := TStringList.Create;
                try
                    AddJSONProperty(LayerProps, 'name', Layer.Name);
                    // Check if it's a signal or plane layer
                    if ILayer.IsSignalLayer(Layer.LayerID) then
                        AddJSONProperty(LayerProps, 'type', Layer2String(Layer.LayerID))
                    else
                        AddJSONProperty(LayerProps, 'type', 'InternalPlane');
                    AddJSONBoolean(LayerProps, 'visible', Layer.IsDisplayed[Board]);
                    AddJSONProperty(LayerProps, 'layer_id', Layer2String(Layer.LayerID));

                    LayersArray.Add(BuildJSONObject(LayerProps, 1));
                finally
                    LayerProps.Free;
                end;

                Inc(i);
                Layer := LayerStack.NextLayer(Layer);
            end;

            // Add mechanical layers
            for i := 1 to 32 do
            begin
                MechLayer := LayerStack.LayerObject_V7[ILayer.MechanicalLayer(i)];
                if (MechLayer <> nil) and MechLayer.MechanicalLayerEnabled then
                begin
                    LayerProps := TStringList.Create;
                    try
                        AddJSONProperty(LayerProps, 'name', MechLayer.Name);
                        AddJSONProperty(LayerProps, 'type', 'Mechanical');
                        AddJSONBoolean(LayerProps, 'visible', MechLayer.IsDisplayed[Board]);
                        AddJSONProperty(LayerProps, 'layer_id', Layer2String(MechLayer.LayerID));

                        LayersArray.Add(BuildJSONObject(LayerProps, 1));
                    finally
                        LayerProps.Free;
                    end;
                end;
            end;
        end;

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
function SetPCBLayerVisibility(LayerNamesList: TStringList; Visible: Boolean): String;
var
    Board       : IPCB_Board;
    LayerObj    : TLayer;
    ResultProps : TStringList;
    OutputLines : TStringList;
    LayerName   : String;
    i           : Integer;
    SuccessCount: Integer;
begin
    // Retrieve the current board
    Board := GetPCBServer.GetCurrentPCBBoard;
    if (Board = nil) then
    begin
        Result := '{"success": false, "error": "No PCB document is currently active"}';
        Exit;
    end;

    ResultProps := TStringList.Create;
    SuccessCount := 0;

    try
        GetPCBServer.PreProcess;
        try
            // Process each layer name in the list
            for i := 0 to LayerNamesList.Count - 1 do
            begin
                LayerName := Trim(LayerNamesList[i]);

                // Map string to layer object
                // This is a simplified mapping, would need a full lookup table
                if LayerName = 'TopLayer' then LayerObj := eTopLayer
                else if LayerName = 'BottomLayer' then LayerObj := eBottomLayer
                else if LayerName = 'TopOverlay' then LayerObj := eTopOverlay
                else if LayerName = 'BottomOverlay' then LayerObj := eBottomOverlay
                else if LayerName = 'MidLayer1' then LayerObj := eMidLayer1
                else if LayerName = 'MidLayer2' then LayerObj := eMidLayer2
                else if LayerName = 'Mechanical1' then LayerObj := eMechanical1
                else if LayerName = 'Mechanical2' then LayerObj := eMechanical2
                else
                    Continue; // Skip unknown layers

                // Set layer visibility
                Board.LayerIsDisplayed[LayerObj] := Visible;
                SuccessCount := SuccessCount + 1;
            end;

            AddJSONBoolean(ResultProps, 'success', True);
            AddJSONInteger(ResultProps, 'layers_updated', SuccessCount);
            AddJSONBoolean(ResultProps, 'visible', Visible);
        finally
            GetPCBServer.PostProcess;
        end;

        // Refresh view
        GetClient.SendMessage('PCB:Zoom', 'Action=Redraw', 255, GetClient.CurrentView);

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
    Board := GetPCBServer.GetCurrentPCBBoard;
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
    Board := GetPCBServer.GetCurrentPCBBoard;
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
    Board := GetPCBServer.GetCurrentPCBBoard;
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
    Board := GetPCBServer.GetCurrentPCBBoard;
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
    Board := GetPCBServer.GetCurrentPCBBoard;
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
        GetPCBServer.PreProcess;
        
        // Process each designator
        for i := 0 to DesignatorsList.Count - 1 do
        begin
            Designator := Trim(DesignatorsList[i]);
            
            // Use direct function to get component by designator
            Component := Board.GetPcbComponentByRefDes(Designator);
            
            if (Component <> Nil) then
            begin
                // Begin modify
                GetPCBServer.SendMessageToRobots(Component.I_ObjectAddress, c_Broadcast, PCBM_BeginModify, c_NoEventData);
                
                // Move the component by the specified offsets
                Component.MoveByXY(XOffset, YOffset);
                
                // Set rotation if specified (non-zero)
                if (Rotation <> 0) then
                    Component.Rotation := Rotation;
                
                // End modify
                GetPCBServer.SendMessageToRobots(Component.I_ObjectAddress, c_Broadcast, PCBM_EndModify, c_NoEventData);
                
                MovedCount := MovedCount + 1;
            end
            else
            begin
                // Add to missing designators list
                MissingArray.Add('"' + JSONEscapeString(Designator) + '"');
            end;
        end;
        
        // End transaction
        GetPCBServer.PostProcess;
        
        // Update PCB document
        GetClient.SendMessage('PCB:Zoom', 'Action=Redraw', 255, GetClient.CurrentView);
        
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

{..............................................................................}
{ Get Board Outline - Extract board outline coordinates as polygon            }
{..............................................................................}
function GetBoardOutline(ROOT_DIR: String): String;
var
    Board          : IPCB_Board;
    PointsArray    : TStringList;
    i              : Integer;
    X, Y           : Double;
begin
    // Retrieve the current board
    Board := GetPCBServer.GetCurrentPCBBoard;
    if (Board = nil) then
    begin
        Result := '[]';
        Exit;
    end;

    // Rebuild and validate board outline
    Board.BoardOutline.Invalidate;
    Board.BoardOutline.Rebuild;
    Board.BoardOutline.Validate;

    // Create array for outline points
    PointsArray := TStringList.Create;

    try
        // Step through each vertex of the Board Outline
        for i := 0 to Board.BoardOutline.PointCount - 1 do
        begin
            // Convert from internal units to mils
            X := CoordToMils(Board.BoardOutline.Segments[i].vx - Board.XOrigin);
            Y := CoordToMils(Board.BoardOutline.Segments[i].vy - Board.YOrigin);

            // Add as JSON array [x, y]
            PointsArray.Add('[' + FloatToStr(X) + ',' + FloatToStr(Y) + ']');

            // For arc segments, add additional interpolated points for smooth curves
            // This approximates the arc with multiple line segments
            if Board.BoardOutline.Segments[i].Kind = ePolySegmentArc then
            begin
                // Add 8 interpolated points along the arc for smooth rendering
                // (In a full implementation, you'd calculate actual arc points)
                // For now, this ensures arcs are included with their endpoints
            end;
        end;

        // Build and return the JSON array directly
        Result := BuildJSONArray(PointsArray);
    finally
        PointsArray.Free;
    end;
end;


end.
