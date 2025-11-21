// schematic_utils.pas
// Schematic utility functions for Altium

unit schematic_utils;

interface

function StrToPinElectricalType(ElecType: String): TPinElectrical;
function StrToPinOrientation(Orient: String): TRotationBy90;
function GetLibrarySymbolReference(ROOT_DIR: String): String;
function CreateSchematicSymbol(SymbolName: String; PinsList: TStringList): String;
function GetSchematicData(ROOT_DIR: String): String;
function GetSchematicComponentsWithParameters(ROOT_DIR: String): String;
function CheckSchematicPCBSync(ROOT_DIR: String): String;
function GetWholeDesignJSON(ROOT_DIR: String): String;

implementation

uses
    globals;

// Helper function to convert string to pin electrical type
function StrToPinElectricalType(ElecType: String): TPinElectrical;
begin
    if ElecType = 'eElectricHiZ' then
        Result := eElectricHiZ
    else if ElecType = 'eElectricInput' then
        Result := eElectricInput
    else if ElecType = 'eElectricIO' then
        Result := eElectricIO
    else if ElecType = 'eElectricOpenCollector' then
        Result := eElectricOpenCollector
    else if ElecType = 'eElectricOpenEmitter' then
        Result := eElectricOpenEmitter
    else if ElecType = 'eElectricOutput' then
        Result := eElectricOutput
    else if ElecType = 'eElectricPassive' then
        Result := eElectricPassive
    else if ElecType = 'eElectricPower' then
        Result := eElectricPower
    else
        Result := eElectricPassive; // Default
end;

// Helper function to convert string to pin orientation
function StrToPinOrientation(Orient: String): TRotationBy90;
begin
    if Orient = 'eRotate0' then
        Result := eRotate0
    else if Orient = 'eRotate90' then
        Result := eRotate90
    else if Orient = 'eRotate180' then
        Result := eRotate180
    else if Orient = 'eRotate270' then
        Result := eRotate270
    else
        Result := eRotate0; // Default
end;

// Function to get current schematic library component data
function GetLibrarySymbolReference(ROOT_DIR: String): String;
var
    CurrentLib       : ISch_Lib;
    SchComponent     : ISch_Component;
    PinIterator      : ISch_Iterator;
    Pin              : ISch_Pin;
    ComponentProps   : TStringList;
    PinsArray        : TStringList;
    PinProps         : TStringList;
    OutputLines      : TStringList;
    PinName, PinNum  : String;
    PinType          : String;
    PinOrient        : String;
    PinX, PinY       : Integer;
begin
    Result := '';
    
    // Check if we have a schematic library document
    CurrentLib := SchServer.GetCurrentSchDocument;
    if (CurrentLib.ObjectID <> eSchLib) Then
    begin
        Result := 'ERROR: Please open a schematic library document';
        Exit;
    end;
    
    // Get the currently focused component from the library
    SchComponent := CurrentLib.CurrentSchComponent;
    if SchComponent = Nil Then
    begin
        Result := 'ERROR: No component is currently selected in the library';
        Exit;
    end;
    
    // Create component properties
    ComponentProps := TStringList.Create;
    
    try
        // Add basic component properties
        AddJSONProperty(ComponentProps, 'library_name', ExtractFileName(CurrentLib.DocumentName));
        AddJSONProperty(ComponentProps, 'component_name', SchComponent.LibReference);
        AddJSONProperty(ComponentProps, 'description', SchComponent.ComponentDescription);
        AddJSONProperty(ComponentProps, 'designator', SchComponent.Designator.Text);
        
        // Create an array for pins
        PinsArray := TStringList.Create;
        
        try
            // Create pin iterator
            PinIterator := SchComponent.SchIterator_Create;
            PinIterator.AddFilter_ObjectSet(MkSet(ePin));
            
            Pin := PinIterator.FirstSchObject;
            
            // Process all pins
            while (Pin <> nil) do
            begin
                // Create pin properties
                PinProps := TStringList.Create;
                
                try
                    // Get pin properties
                    PinNum := Pin.Designator;
                    PinName := Pin.Name;
                    
                    // Convert electrical type to string
                    case Pin.Electrical of
                        eElectricHiZ: PinType := 'eElectricHiZ';
                        eElectricInput: PinType := 'eElectricInput';
                        eElectricIO: PinType := 'eElectricIO';
                        eElectricOpenCollector: PinType := 'eElectricOpenCollector';
                        eElectricOpenEmitter: PinType := 'eElectricOpenEmitter';
                        eElectricOutput: PinType := 'eElectricOutput';
                        eElectricPassive: PinType := 'eElectricPassive';
                        eElectricPower: PinType := 'eElectricPower';
                        else PinType := 'eElectricPassive';
                    end;
                    
                    // Convert orientation to string
                    case Pin.Orientation of
                        eRotate0: PinOrient := 'eRotate0';
                        eRotate90: PinOrient := 'eRotate90';
                        eRotate180: PinOrient := 'eRotate180';
                        eRotate270: PinOrient := 'eRotate270';
                        else PinOrient := 'eRotate0';
                    end;
                    
                    // Get coordinates
                    PinX := CoordToMils(Pin.Location.X);
                    PinY := CoordToMils(Pin.Location.Y);
                    
                    // Add pin properties
                    AddJSONProperty(PinProps, 'pin_number', PinNum);
                    AddJSONProperty(PinProps, 'pin_name', PinName);
                    AddJSONProperty(PinProps, 'pin_type', PinType);
                    AddJSONProperty(PinProps, 'pin_orientation', PinOrient);
                    AddJSONNumber(PinProps, 'x', PinX);
                    AddJSONNumber(PinProps, 'y', PinY);
                    
                    // Add this pin to the pins array
                    PinsArray.Add(BuildJSONObject(PinProps, 1));
                    
                    // Move to next pin
                    Pin := PinIterator.NextSchObject;
                finally
                    PinProps.Free;
                end;
            end;
            
            SchComponent.SchIterator_Destroy(PinIterator);
            
            // Add pins array to component - pass empty string as the array name
            // because we're adding it directly to the ComponentProps
            ComponentProps.Add('"pins": ' + BuildJSONArray(PinsArray));
            
            // Build final JSON
            OutputLines := TStringList.Create;
            
            try
                OutputLines.Text := BuildJSONObject(ComponentProps);
                Result := WriteJSONToFile(OutputLines, ROOT_DIR+'temp_symbol_reference.json');
            finally
                OutputLines.Free;
            end;
        finally
            PinsArray.Free;
        end;
    finally
        ComponentProps.Free;
    end;
end;

function CreateSchematicSymbol(SymbolName: String; PinsList: TStringList): String;
var
    CurrentLib       : ISch_Lib;
    SchComponent     : ISch_Component;
    SchPin           : ISch_Pin;
    R                : ISch_Rectangle;
    I, PinCount      : Integer;
    PinData          : TStringList;
    PinName, PinNum  : String;
    PinType          : String;
    PinOrient        : String;
    PinX, PinY       : Integer;
    PinElec          : TPinElectrical;
    PinOrientation   : TRotationBy90;
    MinX, MaxX, MinY, MaxY : Integer;
    CenterX, CenterY : Integer;
    Padding          : Integer;
    ResultProps      : TStringList;
    Description      : String;
    OutputLines      : TStringList;
begin
    // Check if we have a schematic library document
    CurrentLib := SchServer.GetCurrentSchDocument;
    if (CurrentLib.ObjectID <> eSchLib) Then
    begin
        Result := 'ERROR: Please open a schematic library document';
        Exit;
    end;

    Description := 'New Component';  // Default description

    // Parse the pins list for description
    for I := 0 to PinsList.Count - 1 do
    begin
        if (Pos('Description=', PinsList[I]) = 1) then
        begin
            Description := Copy(PinsList[I], 13, Length(PinsList[I]) - 12);
            Break;
        end;
    end;

    // Create a library component (a page of the library is created)
    SchComponent := SchServer.SchObjectFactory(eSchComponent, eCreate_Default);
    if (SchComponent = Nil) Then
    begin
        Result := 'ERROR: Failed to create component';
        Exit;
    end;

    // Set up parameters for the library component
    SchComponent.CurrentPartID := 1; // Is this automatically generated if not manually assigned? What if two IDs overlap?
    SchComponent.DisplayMode := 0;

    // Define the LibReference and component description
    SchComponent.LibReference := SymbolName;
    SchComponent.ComponentDescription := Description;
    SchComponent.Designator.Text := 'U';

    // First pass - collect pin data for sizing the rectangle
    MinX := 9999; MaxX := -9999; MinY := 9999; MaxY := -9999;
    PinCount := 0;

    for I := 0 to PinsList.Count - 1 do
    begin
        // Skip if this is the description line
        if (Pos('Description=', PinsList[I]) = 1) then Continue;

        // Parse the pin data
        PinData := TStringList.Create;
        try
            PinData.Delimiter := '|';
            PinData.DelimitedText := PinsList[I];

            if (PinData.Count >= 6) then
            begin
                // Get pin coordinates and orientation
                PinX := StrToInt(PinData[4]);
                PinY := StrToInt(PinData[5]);
                PinOrient := PinData[3];

                // Track overall min/max for all pins
                MinX := Min(MinX, PinX);
                MaxX := Max(MaxX, PinX);
                MinY := Min(MinY, PinY);
                MaxY := Max(MaxY, PinY);

                PinCount := PinCount + 1;
            end;
        finally
            PinData.Free;
        end;
    end;

    // Set rectangle to cover all pins with padding
    if (PinCount = 0) then
    begin
        // Default rectangle if no pins
        MinX := 300;
        MinY := 0;
        MaxX := 1000;
        MaxY := 1000;
    end;

    // Create a rectangle for the component body
    R := SchServer.SchObjectFactory(eRectangle, eCreate_Default);
    if (R = Nil) Then
    begin
        Result := 'ERROR: Failed to create rectangle';
        Exit;
    end;

    // Define the rectangle parameters using determined boundaries
    R.LineWidth := eSmall;
    R.Location := Point(MilsToCoord(MinX), MilsToCoord(MinY - 100));
    R.Corner := Point(MilsToCoord(MaxX), MilsToCoord(MaxY + 100));
    R.AreaColor := $00B0FFFF; // Yellow (BGR format)
    R.Color := $00FF0000;     // Blue (BGR format)
    R.IsSolid := True;
    R.OwnerPartId := SchComponent.CurrentPartID;
    R.OwnerPartDisplayMode := SchComponent.DisplayMode;

    // Add the rectangle to the component
    SchComponent.AddSchObject(R);

    // TODO: Define Designator Name as U?, J?, etc
    SchComponent.Designator.Name := 'U?';

    // Move designator to top left
    SchComponent.Designator.Location := Point(MilsToCoord(MinX), MilsToCoord(MaxY + 100)); // Autoposition is another option: ISch_Component.Designator.Autoposition

    // Second pass - add pins to the component
    for I := 0 to PinsList.Count - 1 do
    begin
        // Skip if this is the description line
        if (Pos('Description=', PinsList[I]) = 1) then Continue;

        // Parse the pin data
        PinData := TStringList.Create;
        try
            PinData.Delimiter := '|';
            PinData.DelimitedText := PinsList[I];

            if (PinData.Count >= 6) then
            begin
                PinNum := PinData[0];
                PinName := PinData[1];
                PinType := PinData[2];
                PinOrient := PinData[3];
                PinX := StrToInt(PinData[4]);
                PinY := StrToInt(PinData[5]);

                // Create a pin
                SchPin := SchServer.SchObjectFactory(ePin, eCreate_Default);
                if (SchPin = Nil) Then
                    Continue;

                // Set pin properties
                PinElec := StrToPinElectricalType(PinType);
                PinOrientation := StrToPinOrientation(PinOrient);

                SchPin.Designator := PinNum;
                SchPin.Name := PinName;
                SchPin.Electrical := PinElec;
                SchPin.Orientation := PinOrientation;
                SchPin.Location := Point(MilsToCoord(PinX), MilsToCoord(PinY));

                // Set ownership
                SchPin.OwnerPartId := SchComponent.CurrentPartID;
                SchPin.OwnerPartDisplayMode := SchComponent.DisplayMode;

                // Add the pin to the component
                SchComponent.AddSchObject(SchPin);
            end;
        finally
            PinData.Free;
        end;
    end;

    // Add the component to the library
    CurrentLib.AddSchComponent(SchComponent);

    // Send a system notification that a new component has been added to the library
    SchServer.RobotManager.SendMessage(nil, c_BroadCast, SCHM_PrimitiveRegistration, SchComponent.I_ObjectAddress);
    CurrentLib.CurrentSchComponent := SchComponent;

    // Refresh library
    CurrentLib.GraphicallyInvalidate;

    // Create result JSON
    ResultProps := TStringList.Create;
    try
        AddJSONBoolean(ResultProps, 'success', True);
        AddJSONProperty(ResultProps, 'component_name', SymbolName);
        AddJSONInteger(ResultProps, 'pins_count', PinCount);
        
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

// Function to get all schematic component data
function GetSchematicData(ROOT_DIR: String): String;
var
    Project     : IProject;
    Doc         : IDocument;
    CurrentSch  : ISch_Document;
    Iterator    : ISch_Iterator;
    PIterator   : ISch_Iterator;
    Component   : ISch_Component;
    Parameter, NextParameter : ISch_Parameter;
    Rect        : TCoordRect;
    ComponentsArray : TStringList;
    CompProps   : TStringList;
    ParamsProps : TStringList;
    OutputLines : TStringList;
    Designator, Sheet, ParameterName, ParameterValue : String;
    x, y, width, height, rotation : String;
    left, right, top, bottom : String;
    i : Integer;
    SchematicCount, ComponentCount : Integer;
begin
    Result := '';

    // Retrieve the current project
    Project := GetWorkspace.DM_FocusedProject;
    If (Project = Nil) Then
    begin
        ShowMessage('Error: No project is currently open');
        Exit;
    end;

    // Create array for components
    ComponentsArray := TStringList.Create;
    
    try
        // Count the number of schematic documents
        SchematicCount := 0;
        For i := 0 to Project.DM_LogicalDocumentCount - 1 Do
        Begin
            Doc := Project.DM_LogicalDocuments(i);
            If Doc.DM_DocumentKind = 'SCH' Then
                SchematicCount := SchematicCount + 1;
        End;

        // Process each schematic document
        ComponentCount := 0;
        For i := 0 to Project.DM_LogicalDocumentCount - 1 Do
        Begin
            Doc := Project.DM_LogicalDocuments(i);
            If Doc.DM_DocumentKind = 'SCH' Then
            Begin
                // Open the schematic document
                GetClient.OpenDocument('SCH', Doc.DM_FullPath);
                CurrentSch := SchServer.GetSchDocumentByPath(Doc.DM_FullPath);

                If (CurrentSch <> Nil) Then
                Begin
                    // Get schematic components
                    Iterator := CurrentSch.SchIterator_Create;
                    Iterator.AddFilter_ObjectSet(MkSet(eSchComponent));

                    Component := Iterator.FirstSchObject;
                    While (Component <> Nil) Do
                    Begin
                        // Create component properties
                        CompProps := TStringList.Create;
                        
                        try
                            // Get basic component properties
                            Designator := Component.Designator.Text;
                            Sheet := Doc.DM_FullPath;

                            // Get position, dimensions and rotation
                            x := FloatToStr(CoordToMils(Component.Location.X));
                            y := FloatToStr(CoordToMils(Component.Location.Y));

                            Rect := Component.BoundingRectangle;
                            left := FloatToStr(CoordToMils(Rect.Left));
                            right := FloatToStr(CoordToMils(Rect.Right));
                            top := FloatToStr(CoordToMils(Rect.Top));
                            bottom := FloatToStr(CoordToMils(Rect.Bottom));

                            width := FloatToStr(CoordToMils(Rect.Right - Rect.Left));
                            height := FloatToStr(CoordToMils(Rect.Bottom - Rect.Top));

                            If Component.Orientation = eRotate0 Then
                                rotation := '0'
                            Else If Component.Orientation = eRotate90 Then
                                rotation := '90'
                            Else If Component.Orientation = eRotate180 Then
                                rotation := '180'
                            Else If Component.Orientation = eRotate270 Then
                                rotation := '270'
                            Else
                                rotation := '0';

                            // Add component properties
                            AddJSONProperty(CompProps, 'designator', Designator);
                            AddJSONProperty(CompProps, 'sheet', Sheet);
                            AddJSONNumber(CompProps, 'schematic_x', StrToFloat(x));
                            AddJSONNumber(CompProps, 'schematic_y', StrToFloat(y));
                            AddJSONNumber(CompProps, 'schematic_width', StrToFloat(width));
                            AddJSONNumber(CompProps, 'schematic_height', StrToFloat(height));
                            AddJSONNumber(CompProps, 'schematic_rotation', StrToFloat(rotation));
                            
                            // Get parameters
                            ParamsProps := TStringList.Create;
                            try
                                // Create parameter iterator
                                PIterator := Component.SchIterator_Create;
                                PIterator.AddFilter_ObjectSet(MkSet(eParameter));

                                Parameter := PIterator.FirstSchObject;
                                
                                // Process all parameters
                                while (Parameter <> nil) do
                                begin
                                    // Get this parameter's info
                                    ParameterName := Parameter.Name;
                                    ParameterValue := Parameter.Text;

                                    // Add parameter to the list
                                    AddJSONProperty(ParamsProps, ParameterName, ParameterValue);
                                    
                                    // Move to next parameter
                                    Parameter := PIterator.NextSchObject;
                                end;

                                Component.SchIterator_Destroy(PIterator);
                                
                                // Add parameters to component
                                CompProps.Add('"parameters": ' + BuildJSONObject(ParamsProps, 2));
                                
                                // Add to components array
                                ComponentsArray.Add(BuildJSONObject(CompProps, 1));
                                ComponentCount := ComponentCount + 1;
                            finally
                                ParamsProps.Free;
                            end;
                        finally
                            CompProps.Free;
                        end;

                        // Move to next component
                        Component := Iterator.NextSchObject;
                    End;

                    CurrentSch.SchIterator_Destroy(Iterator);
                End;
            End;
        End;
        
        // Build the final JSON array
        OutputLines := TStringList.Create;
        try
            OutputLines.Text := BuildJSONArray(ComponentsArray);
            Result := WriteJSONToFile(OutputLines, ROOT_DIR+'temp_schematic_data.json');
        finally
            OutputLines.Free;
        end;
    finally
        ComponentsArray.Free;
    end;
end;

// Function to get all schematic component parameters for BOM analysis
function GetSchematicComponentsWithParameters(ROOT_DIR: String): String;
var
    Workspace       : IWorkspace;
    Project         : IProject;
    FlatHierarchy   : IDocument;
    ComponentNum    : Integer;
    Component       : IComponent;
    Part            : IPart;
    ParameterNum    : Integer;
    Parameter       : IParameter;
    ComponentsArray : TStringList;
    CompProps       : TStringList;
    ParamsProps     : TStringList;
    OutputLines     : TStringList;
    Designator      : String;
    LibReference    : String;
    Description     : String;
    Footprint       : String;
    ParameterName   : String;
    ParameterValue  : String;
begin
    Result := '';

    // Get workspace and project
    Workspace := GetWorkspace;
    Project := Workspace.DM_FocusedProject;

    If (Project = Nil) Then
    begin
        Result := '{"error": "No project is currently open"}';
        Exit;
    end;

    // Compile project
    Project.DM_Compile;

    // Get flattened hierarchy
    FlatHierarchy := Project.DM_DocumentFlattened;

    If (FlatHierarchy = Nil) Then
    begin
        Result := '{"error": "Failed to get flattened project. Please compile the project first."}';
        Exit;
    end;

    // Create array for components
    ComponentsArray := TStringList.Create;

    try
        // Iterate through all components
        For ComponentNum := 0 to FlatHierarchy.DM_ComponentCount - 1 do
        begin
            Component := FlatHierarchy.DM_Components(ComponentNum);

            // Create component properties
            CompProps := TStringList.Create;

            try
                // Get the first subpart to access component properties
                // (Much information can only be retrieved from subparts)
                If Component.DM_SubPartCount > 0 Then
                begin
                    Part := Component.DM_SubParts(0);

                    // Get basic component properties
                    Designator := Part.DM_PhysicalDesignator;
                    LibReference := Part.DM_LibraryReference;
                    Description := Part.DM_Description;
                    Footprint := Part.DM_Footprint;

                    // Add basic properties
                    AddJSONProperty(CompProps, 'designator', Designator);
                    AddJSONProperty(CompProps, 'lib_reference', LibReference);
                    AddJSONProperty(CompProps, 'description', Description);
                    AddJSONProperty(CompProps, 'footprint', Footprint);

                    // Get all parameters
                    ParamsProps := TStringList.Create;
                    try
                        For ParameterNum := 0 to Component.DM_ParameterCount - 1 do
                        begin
                            Parameter := Component.DM_Parameters(ParameterNum);
                            ParameterName := Parameter.DM_Name;
                            ParameterValue := Parameter.DM_Value;

                            // Add parameter to the list
                            AddJSONProperty(ParamsProps, ParameterName, ParameterValue);
                        end;

                        // Add parameters object to component
                        CompProps.Add('"parameters": ' + BuildJSONObject(ParamsProps, 2));

                        // Add to components array
                        ComponentsArray.Add(BuildJSONObject(CompProps, 1));
                    finally
                        ParamsProps.Free;
                    end;
                end;
            finally
                CompProps.Free;
            end;
        end;

        // Build the final JSON array
        OutputLines := TStringList.Create;
        try
            OutputLines.Text := BuildJSONArray(ComponentsArray);
            Result := WriteJSONToFile(OutputLines, ROOT_DIR+'temp_bom_components.json');
        finally
            OutputLines.Free;
        end;
    finally
        ComponentsArray.Free;
    end;
end;

// Function to check synchronization between schematic and PCB components
function CheckSchematicPCBSync(ROOT_DIR: String): String;
var
    Workspace           : IWorkspace;
    Project             : IProject;
    FlatHierarchy       : IDocument;
    Board               : IPCB_Board;
    Iterator            : IPCB_BoardIterator;
    ComponentNum        : Integer;
    SchComponent        : IComponent;
    PCBComponent        : IPCB_Component;
    Part                : IPart;

    // Hash tables for tracking components (using TStringList as hash map)
    SchUniqueIdMap      : TStringList;  // Maps UniqueId -> Designator
    PCBSourceIdMap      : TStringList;  // Maps SourceUniqueId -> Designator

    // Result arrays
    SchOnlyArray        : TStringList;
    PCBOnlyArray        : TStringList;
    MismatchArray       : TStringList;

    // Individual component properties
    SchItemProps        : TStringList;
    PCBItemProps        : TStringList;
    MismatchProps       : TStringList;

    // Result properties
    ResultProps         : TStringList;
    OutputLines         : TStringList;

    SchDesignator       : String;
    PCBDesignator       : String;
    UniqueId            : String;
    SourceUniqueId      : String;

    MatchedCount        : Integer;
    TotalSchCount       : Integer;
    TotalPCBCount       : Integer;
    InSync              : Boolean;
    i                   : Integer;
begin
    Result := '';

    // Get workspace and project
    Workspace := GetWorkspace;
    Project := Workspace.DM_FocusedProject;

    If (Project = Nil) Then
    begin
        Result := '{"error": "No project is currently open"}';
        Exit;
    end;

    // Compile project to get latest schematic data
    Project.DM_Compile;

    // Get flattened hierarchy for schematic components
    FlatHierarchy := Project.DM_DocumentFlattened;

    If (FlatHierarchy = Nil) Then
    begin
        Result := '{"error": "Failed to get flattened project. Please compile the project first."}';
        Exit;
    end;

    // Get current PCB board
    Board := GetPCBServer.GetCurrentPCBBoard;
    if (Board = nil) then
    begin
        Result := '{"error": "No PCB document is currently open"}';
        Exit;
    end;

    // Initialize hash maps and result arrays
    SchUniqueIdMap := TStringList.Create;
    PCBSourceIdMap := TStringList.Create;
    SchOnlyArray := TStringList.Create;
    PCBOnlyArray := TStringList.Create;
    MismatchArray := TStringList.Create;

    try
        // Build schematic components map
        TotalSchCount := FlatHierarchy.DM_ComponentCount;

        For ComponentNum := 0 to TotalSchCount - 1 do
        begin
            SchComponent := FlatHierarchy.DM_Components(ComponentNum);

            // Get the first subpart to access component properties
            If SchComponent.DM_SubPartCount > 0 Then
            begin
                Part := SchComponent.DM_SubParts(0);
                SchDesignator := Part.DM_PhysicalDesignator;
                UniqueId := SchComponent.DM_UniqueId;

                // Store in map: UniqueId -> Designator
                SchUniqueIdMap.Add(UniqueId + '=' + SchDesignator);
            end;
        end;

        // Build PCB components map
        Iterator := Board.BoardIterator_Create;
        Iterator.AddFilter_ObjectSet(MkSet(eComponentObject));
        Iterator.AddFilter_IPCB_LayerSet(LayerSet.AllLayers);
        Iterator.AddFilter_Method(eProcessAll);

        TotalPCBCount := 0;
        PCBComponent := Iterator.FirstPCBObject;
        while (PCBComponent <> Nil) do
        begin
            PCBDesignator := PCBComponent.Name.Text;
            SourceUniqueId := PCBComponent.SourceUniqueId;

            // Store in map: SourceUniqueId -> Designator
            PCBSourceIdMap.Add(SourceUniqueId + '=' + PCBDesignator);
            TotalPCBCount := TotalPCBCount + 1;

            // Move to next component
            PCBComponent := Iterator.NextPCBObject;
        end;

        Board.BoardIterator_Destroy(Iterator);

        // Compare schematic components against PCB
        MatchedCount := 0;

        For i := 0 to SchUniqueIdMap.Count - 1 do
        begin
            UniqueId := SchUniqueIdMap.Names[i];
            SchDesignator := SchUniqueIdMap.ValueFromIndex[i];

            // Check if this UniqueId exists in PCB
            if PCBSourceIdMap.IndexOfName(UniqueId) >= 0 then
            begin
                // Found match - check if designators match
                PCBDesignator := PCBSourceIdMap.Values[UniqueId];

                if SchDesignator = PCBDesignator then
                begin
                    // Perfect match
                    MatchedCount := MatchedCount + 1;
                end
                else
                begin
                    // UniqueId matches but designators differ
                    MismatchProps := TStringList.Create;
                    try
                        AddJSONProperty(MismatchProps, 'schematic_designator', SchDesignator);
                        AddJSONProperty(MismatchProps, 'pcb_designator', PCBDesignator);
                        AddJSONProperty(MismatchProps, 'unique_id', UniqueId);
                        MismatchArray.Add(BuildJSONObject(MismatchProps, 2));
                    finally
                        MismatchProps.Free;
                    end;
                end;
            end
            else
            begin
                // Component exists in schematic but not in PCB
                SchItemProps := TStringList.Create;
                try
                    AddJSONProperty(SchItemProps, 'designator', SchDesignator);
                    AddJSONProperty(SchItemProps, 'unique_id', UniqueId);
                    SchOnlyArray.Add(BuildJSONObject(SchItemProps, 2));
                finally
                    SchItemProps.Free;
                end;
            end;
        end;

        // Find PCB components that don't exist in schematic
        For i := 0 to PCBSourceIdMap.Count - 1 do
        begin
            SourceUniqueId := PCBSourceIdMap.Names[i];
            PCBDesignator := PCBSourceIdMap.ValueFromIndex[i];

            // Check if this SourceUniqueId exists in schematic
            if SchUniqueIdMap.IndexOfName(SourceUniqueId) < 0 then
            begin
                // Component exists in PCB but not in schematic
                PCBItemProps := TStringList.Create;
                try
                    AddJSONProperty(PCBItemProps, 'designator', PCBDesignator);
                    AddJSONProperty(PCBItemProps, 'source_unique_id', SourceUniqueId);
                    PCBOnlyArray.Add(BuildJSONObject(PCBItemProps, 2));
                finally
                    PCBItemProps.Free;
                end;
            end;
        end;

        // Determine if in sync
        InSync := (SchOnlyArray.Count = 0) and (PCBOnlyArray.Count = 0) and (MismatchArray.Count = 0);

        // Build final result JSON
        ResultProps := TStringList.Create;
        try
            AddJSONBoolean(ResultProps, 'success', True);
            AddJSONBoolean(ResultProps, 'in_sync', InSync);
            ResultProps.Add('"schematic_only": ' + BuildJSONArray(SchOnlyArray, '', 1));
            ResultProps.Add('"pcb_only": ' + BuildJSONArray(PCBOnlyArray, '', 1));
            ResultProps.Add('"designator_mismatches": ' + BuildJSONArray(MismatchArray, '', 1));
            AddJSONInteger(ResultProps, 'matched_count', MatchedCount);
            AddJSONInteger(ResultProps, 'total_schematic', TotalSchCount);
            AddJSONInteger(ResultProps, 'total_pcb', TotalPCBCount);

            OutputLines := TStringList.Create;
            try
                OutputLines.Text := BuildJSONObject(ResultProps);
                Result := WriteJSONToFile(OutputLines, ROOT_DIR+'temp_sync_check.json');
            finally
                OutputLines.Free;
            end;
        finally
            ResultProps.Free;
        end;

    finally
        SchUniqueIdMap.Free;
        PCBSourceIdMap.Free;
        SchOnlyArray.Free;
        PCBOnlyArray.Free;
        MismatchArray.Free;
    end;
end;

// Function to get the entire schematic design in one JSON call
// This combines component data, parameters, pins, and nets
// Uses ONLY verified DM (Design Manager) interface methods from working examples
function GetWholeDesignJSON(ROOT_DIR: String): String;
var
    Workspace       : IWorkspace;
    Project         : IProject;
    Doc             : IDocument;
    FlatHierarchy   : IDocument;
    Net             : INet;
    DMComp          : IComponent;
    DMPart          : IPart;
    DMPin           : IPin;
    NetPin          : INetItem;

    ComponentsArray : TStringList;
    CompProps       : TStringList;
    PinsArray       : TStringList;
    PinProps        : TStringList;
    NetsArray       : TStringList;
    NetProps        : TStringList;
    OutputLines     : TStringList;
    ResultProps     : TStringList;
    PinNetMap       : TStringList;

    Designator      : String;
    Description     : String;
    Footprint       : String;
    SheetName       : String;
    PinNumber       : String;
    PinName         : String;
    NetName         : String;

    i, j, k         : Integer;
    PartIdx         : Integer;
    PinIdx          : Integer;
begin
    Result := '';

    // VERIFIED: GetWorkspace and DM_FocusedProject (from GetPinData.pas line 89)
    Workspace := GetWorkspace;
    Project := Workspace.DM_FocusedProject;

    If (Project = Nil) Then
    begin
        Result := '{"error": "No project is currently open"}';
        Exit;
    end;

    // ALWAYS trigger full IDE compilation to ensure net connectivity data is populated
    ResetParameters;
    AddStringParameter('Action', 'Compile');
    AddStringParameter('ObjectKind', 'Project');
    RunProcess('WorkspaceManager:Compile');

    // Wait for compilation to complete
    Sleep(8000);  // Wait 8 seconds for compilation to finish

    // VERIFIED: DM_Compile (from GetPinData.pas line 90)
    // Call DM_Compile AFTER RunProcess to refresh the Design Manager data
    Project.DM_Compile;

    // Verify compilation succeeded
    FlatHierarchy := Project.DM_DocumentFlattened;
    If (FlatHierarchy = Nil) Then
    Begin
        Result := '{"error": "Project compilation failed - DM_DocumentFlattened is still nil after compilation"}';
        Exit;
    End;

    // Create main data structures
    ComponentsArray := TStringList.Create;

    // First pass: Build pin-to-net mapping using VERIFIED method from GetPinData.pas
    // This uses INetItem.DM_NetName instead of IPin.DM_FlattenedNetName
    PinNetMap := TStringList.Create;
    // Don't sort - we need to use .Values assignment
    PinNetMap.Duplicates := dupIgnore;

    try
        // Build pin-to-net map by iterating through nets (GetPinData.pas approach)
        For i := 0 to Project.DM_LogicalDocumentCount - 1 Do
        Begin
            Doc := Project.DM_LogicalDocuments(i);

            If Doc.DM_DocumentKind = 'SCH' Then
            Begin
                // VERIFIED: DM_NetCount and DM_Nets (from GetPinData.pas line 114, 116)
                For j := 0 to Doc.DM_NetCount - 1 Do
                Begin
                    Net := Doc.DM_Nets(j);

                    // Get net name from first pin (GetPinData.pas line 121, 65)
                    NetName := '';
                    if Net.DM_PinCount > 0 then
                    begin
                        NetPin := Net.DM_Pins(0);
                        // VERIFIED: DM_NetName on INetItem (GetPinData.pas line 65)
                        NetName := NetPin.DM_NetName;
                    end;

                    // Map all pins in this net to the net name
                    // VERIFIED: DM_PinCount and DM_Pins (from GetPinData.pas line 121, 122)
                    For k := 0 to Net.DM_PinCount - 1 Do
                    Begin
                        NetPin := Net.DM_Pins(k);
                        // Create unique key: ComponentDesignator|PinNumber
                        // VERIFIED: DM_LogicalPartDesignator (GetPinData.pas line 124) and DM_PinNumber (line 66)
                        PinNetMap.Values[NetPin.DM_LogicalPartDesignator + '|' + NetPin.DM_PinNumber] := NetName;
                    End;
                End;
            End;
        End;

        // Second pass: Get component data
        // VERIFIED: DM_LogicalDocumentCount and DM_LogicalDocuments (from GetPinData.pas line 109, 111)
        For i := 0 to Project.DM_LogicalDocumentCount - 1 Do
        Begin
            Doc := Project.DM_LogicalDocuments(i);

            // VERIFIED: DM_DocumentKind (from examples)
            If Doc.DM_DocumentKind = 'SCH' Then
            Begin
                SheetName := ExtractFileName(Doc.DM_FullPath);

                // VERIFIED: DM_ComponentCount and DM_Components (from FindUnmatchedPorts.pas line 222, 224)
                For j := 0 to Doc.DM_ComponentCount - 1 Do
                Begin
                    DMComp := Doc.DM_Components(j);

                    // Create component properties
                    CompProps := TStringList.Create;
                    try
                        // VERIFIED: DM_LogicalDesignator (from FindUnmatchedPorts.pas line 253)
                        Designator := DMComp.DM_LogicalDesignator;

                        // Basic properties
                        AddJSONProperty(CompProps, 'designator', Designator);
                        AddJSONProperty(CompProps, 'sheet', SheetName);

                        // Get pins with nets - VERIFIED approach from GetCompNets function
                        PinsArray := TStringList.Create;
                        try
                            // VERIFIED: DM_SubPartCount (from FindUnmatchedPorts.pas line 602)
                            if (DMComp.DM_SubPartCount = 1) then
                            begin
                                // VERIFIED: DM_PinCount and DM_Pins (from FindUnmatchedPorts.pas line 595, 597)
                                for PinIdx := 0 to DMComp.DM_PinCount - 1 do
                                begin
                                    DMPin := DMComp.DM_Pins(PinIdx);

                                    PinProps := TStringList.Create;
                                    try
                                        // Look up net name from PinNetMap using component designator and actual pin number
                                        // VERIFIED: DMPin.DM_PinNumber exists on IPin (same as INetItem.DM_PinNumber)
                                        PinNumber := DMPin.DM_PinNumber;
                                        NetName := PinNetMap.Values[Designator + '|' + PinNumber];
                                        if NetName = '' then
                                            NetName := '?';

                                        // Add pin properties
                                        // Use 'name' to match adapter expectations (altium_json.py line 292)
                                        AddJSONProperty(PinProps, 'name', PinNumber);
                                        AddJSONProperty(PinProps, 'net', NetName);

                                        PinsArray.Add(BuildJSONObject(PinProps, 3));
                                    finally
                                        PinProps.Free;
                                    end;
                                end;
                            end
                            // VERIFIED: DM_SubParts for multipart (from FindUnmatchedPorts.pas line 606, 607)
                            else if (DMComp.DM_SubPartCount > 1) then
                            begin
                                for PartIdx := 0 to DMComp.DM_SubPartCount - 1 do
                                begin
                                    DMPart := DMComp.DM_SubParts(PartIdx);
                                    // VERIFIED: DMPart.DM_PinCount (from FindUnmatchedPorts.pas line 607)
                                    for PinIdx := 0 to DMPart.DM_PinCount - 1 do
                                    begin
                                        DMPin := DMPart.DM_Pins(PinIdx);

                                        PinProps := TStringList.Create;
                                        try
                                            // Look up net name from PinNetMap using component designator and actual pin number
                                            // VERIFIED: DMPin.DM_PinNumber exists on IPin
                                            PinNumber := DMPin.DM_PinNumber;
                                            NetName := PinNetMap.Values[Designator + '|' + PinNumber];
                                            if NetName = '' then
                                                NetName := '?';

                                            if (NetName <> '?') then
                                            begin
                                                // Use 'name' to match adapter expectations (altium_json.py line 292)
                                                AddJSONProperty(PinProps, 'name', PinNumber);
                                                AddJSONProperty(PinProps, 'net', NetName);

                                                PinsArray.Add(BuildJSONObject(PinProps, 3));
                                            end;
                                        finally
                                            PinProps.Free;
                                        end;
                                    end;
                                end;
                            end;

                            CompProps.Add(BuildJSONArray(PinsArray, 'pins', 1));
                        finally
                            PinsArray.Free;
                        end;

                        // Add component to components array
                        ComponentsArray.Add(BuildJSONObject(CompProps, 1));
                    finally
                        CompProps.Free;
                    end;
                End;
            End;
        End;

        // Build nets array - VERIFIED approach from GetPinData.pas
        NetsArray := TStringList.Create;
        try
            // VERIFIED: DM_LogicalDocumentCount, DM_LogicalDocuments (GetPinData.pas line 109, 111)
            For i := 0 to Project.DM_LogicalDocumentCount - 1 Do
            Begin
                Doc := Project.DM_LogicalDocuments(i);

                // VERIFIED: DM_NetCount and DM_Nets (GetPinData.pas line 114, 116)
                for j := 0 to Doc.DM_NetCount - 1 do
                begin
                    Net := Doc.DM_Nets(j);

                    NetProps := TStringList.Create;
                    try
                        // Get net name from first pin in net (GetPinData.pas line 121, 65)
                        NetName := '';
                        if Net.DM_PinCount > 0 then
                        begin
                            NetPin := Net.DM_Pins(0);
                            // VERIFIED: DM_NetName on INetItem (GetPinData.pas line 65)
                            NetName := NetPin.DM_NetName;
                        end;

                        AddJSONProperty(NetProps, 'name', NetName);
                        // VERIFIED: DM_PinCount (GetPinData.pas line 119)
                        AddJSONInteger(NetProps, 'pin_count', Net.DM_PinCount);

                        NetsArray.Add(BuildJSONObject(NetProps, 1));
                    finally
                        NetProps.Free;
                    end;
                end;
            End;

            // Build final JSON structure
            ResultProps := TStringList.Create;
            try
                ResultProps.Add(BuildJSONArray(ComponentsArray, 'components', 0));
                ResultProps.Add(',');
                ResultProps.Add(BuildJSONArray(NetsArray, 'nets', 0));

                OutputLines := TStringList.Create;
                try
                    OutputLines.Add('{');
                    for i := 0 to ResultProps.Count - 1 do
                        OutputLines.Add(ResultProps[i]);
                    OutputLines.Add('}');

                    Result := WriteJSONToFile(OutputLines, ROOT_DIR+'temp_whole_design.json');
                finally
                    OutputLines.Free;
                end;
            finally
                ResultProps.Free;
            end;
        finally
            NetsArray.Free;
        end;

    finally
        ComponentsArray.Free;
        PinNetMap.Free;
    end;
end;


end.
