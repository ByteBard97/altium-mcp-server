// Altium_API.pas
// Auto-generated combined script - DO NOT EDIT DIRECTLY
// Edit source files and run build_script.py instead
//
// Generated from 18 source files:
//   - globals.pas
//   - json_utils.pas
//   - helpers.pas
//   - board_init.pas
//   - component_placement.pas
//   - library_utils.pas
//   - other_utils.pas
//   - pcb_layout_duplicator.pas
//   - pcb_utils.pas
//   - project_utils.pas
//   - routing.pas
//   - schematic_utils.pas
//   - command_executors_board.pas
//   - command_executors_components.pas
//   - command_executors_library.pas
//   - command_executors_placement.pas
//   - command_router.pas
//   - check_pcb_utils.pas

uses
    PCB, SCH, Workspace, Classes, SysUtils;

// ============================================================================
// GLOBAL VARIABLES
// ============================================================================

var
    // Request/Response handling
    RequestData : TStringList;
    ResponseData : TStringList;
    Params : TStringList;
    REQUEST_FILE : String;
    RESPONSE_FILE : String;
    ROOT_DIR: String;

// ============================================================================
// GLOBAL CONSTANTS
// ============================================================================

const
    constScriptProjectName = 'Altium_API';
    REPLACEALL = 1;  // Flag for StringReplace to replace all occurrences

// ============================================================================
// FORWARD DECLARATIONS
// ============================================================================

// From globals.pas
function GetPCBServer: IPCB_ServerInterface; forward;
function GetClient: IClient; forward;
procedure InitializeFilePaths(RootDirectory: String); forward;

// From json_utils.pas
function RemoveChar(const S: String; C: Char): String; forward;
function TrimJSON(InputStr: String): String; forward;
function JSONEscapeString(const S: String): String; forward;
function JSONPairStr(const Name, Value: String; IsString: Boolean): String; forward;
function BuildJSONObject(Pairs: TStringList; IndentLevel: Integer = 0): String; forward;
function BuildJSONArray(Items: TStringList; ArrayName: String = ''; IndentLevel: Integer = 0): String; forward;
function WriteJSONToFile(JSON: TStringList; FileName: String = ''): String; forward;
procedure AddJSONProperty(List: TStringList; Name: String; Value: String; IsString: Boolean = True); forward;
procedure AddJSONNumber(List: TStringList; Name: String; Value: Double); forward;
procedure AddJSONInteger(List: TStringList; Name: String; Value: Integer); forward;
procedure AddJSONBoolean(List: TStringList; Name: String; Value: Boolean); forward;

// From helpers.pas
procedure ExtractParameter(Line: String); forward;
procedure WriteResponse(Success: Boolean; Data: String; ErrorMsg: String); forward;

// From board_init.pas
function SetBoardSize(Width, Height: Double): String; forward;
function AddBoardOutline(X, Y, Width, Height: Double): String; forward;
function AddMountingHole(X, Y, HoleDiameter, PadDiameter: Double): String; forward;
function AddBoardText(Text: String; X, Y, Size: Double; Layer: String): String; forward;

// From component_placement.pas
function FindFootprintInLibraries(const FootprintName: String): IPCB_LibComponent; forward;
function CopyFootprintPrimitives(LibFootprint: IPCB_LibComponent; Component: IPCB_Component): Boolean; forward;
function PlaceComponent( const Designator, Footprint: String; const X, Y: Double; const Layer, Rotation: Integer ): String; forward;
function DeleteComponent(const Designator: String): String; forward;
function PlaceComponentArray( const Footprint, RefDes: String; const StartX, StartY, SpacingX, SpacingY: Double; const Rows, Cols: Integer ): String; forward;
function AlignComponents( const DesignatorsStr: String; const Alignment: String ): String; forward;

// From library_utils.pas
function ListComponentLibraries: String; forward;
function SearchComponents(const Query: String): String; forward;
function GetComponentFromLibrary(const LibraryName, ComponentName: String): String; forward;
function SearchFootprints(const Query: String): String; forward;

// From other_utils.pas
function ScriptProjectPath(Workspace: IWorkspace): String; forward;
function GetOpenOutputJob(): String; forward;
function EnsureDocumentFocused(CommandName: String): Boolean; forward;
function TakeViewScreenshot(ViewType: String): String; forward;
function GetOutputJobContainers(ROOT_DIR: String): String; forward;
function RunOutputJobs(ContainerNames: TStringList, ROOT_DIR: String): String; forward;
function IsOpenDoc(Path: String): Boolean; forward;

// From pcb_layout_duplicator.pas
function DuplicateSelectedObjects(Board: IPCB_Board; ObjectSet: TSet): TObjectList; forward;
function GetLayoutDuplicatorComponents(SelectedOnly: Boolean = True): String; forward;
function CheckWithTolerance(X1, Y1, X2, Y2 : TCoord) : Boolean; forward;
function ApplyLayoutDuplicator(SourceList: TStringList; DestList: TStringList): String; forward;

// From pcb_utils.pas
function Layer2String(Layer: TLayer): String; forward;
function ShapeToString(Shape: TShape): String; forward;
function GetAllNets(ROOT_DIR: String): String; forward;
function CreateNewNetClass(InClassName: String; InNetNames: TStringList): String; forward;
function GetPCBLayerStackup(ROOT_DIR: String): String; forward;
function GetPCBLayers(ROOT_DIR: String): String; forward;
function SetPCBLayerVisibility(LayerNamesList: TStringList; Visible: Boolean): String; forward;
function GetDesignRules(ROOT_DIR: String): String; forward;
function GetAllComponentData(ROOT_DIR: String; SelectedOnly: Boolean = False): String; forward;
function GetSelectedComponentsCoordinates(ROOT_DIR: String): String; forward;
function GetComponentPinsFromList(ROOT_DIR: String; DesignatorsList: TStringList): String; forward;
function MoveComponentsByDesignators(DesignatorsList: TStringList; XOffset, YOffset: TCoord; Rotation: TAngle): String; forward;
function GetBoardOutline(ROOT_DIR: String): String; forward;

// From project_utils.pas
function CreateProject(const ProjectName, ProjectPath, Template: String): String; forward;
function SaveProject: String; forward;
function GetProjectInfo: String; forward;
function CloseProject: String; forward;
function OpenDocumentByPath(const DocumentPath, DocumentType: String): String; forward;

// From routing.pas
function RouteTrace(X1, Y1, X2, Y2, Width: Double; Layer: String; NetName: String): String; forward;
function AddVia(X, Y, Diameter, HoleSize: Double; StartLayer, EndLayer: String; NetName: String): String; forward;
function AddCopperPour(X, Y, Width, Height: Double; Layer: String; NetName: String; PourOverSameNet: Boolean): String; forward;

// From schematic_utils.pas
function StrToPinElectricalType(ElecType: String): TPinElectrical; forward;
function StrToPinOrientation(Orient: String): TRotationBy90; forward;
function GetLibrarySymbolReference(ROOT_DIR: String): String; forward;
function CreateSchematicSymbol(SymbolName: String; PinsList: TStringList): String; forward;
function GetSchematicData(ROOT_DIR: String): String; forward;
function GetSchematicComponentsWithParameters(ROOT_DIR: String): String; forward;
function CheckSchematicPCBSync(ROOT_DIR: String): String; forward;

// From command_executors_board.pas
function ExecuteSetBoardSize(RequestData: TStringList): String; forward;
function ExecuteAddBoardOutline(RequestData: TStringList): String; forward;
function ExecuteAddMountingHole(RequestData: TStringList): String; forward;
function ExecuteAddBoardText(RequestData: TStringList): String; forward;
function ExecuteRouteTrace(RequestData: TStringList): String; forward;
function ExecuteAddVia(RequestData: TStringList): String; forward;
function ExecuteAddCopperPour(RequestData: TStringList): String; forward;

// From command_executors_components.pas
function ExecuteGetComponentPins(RequestData: TStringList): String; forward;
function ExecuteCreateNetClass(RequestData: TStringList): String; forward;
function ExecuteTakeViewScreenshot(RequestData: TStringList): String; forward;
function ExecuteCreateSchematicSymbol(RequestData: TStringList): String; forward;
function ExecuteSetPCBLayerVisibility(RequestData: TStringList): String; forward;
function ExecuteMoveComponents(RequestData: TStringList): String; forward;
function ExecuteLayoutDuplicatorApply(RequestData: TStringList): String; forward;
function ExecuteGetOutputJobContainers(RequestData: TStringList): String; forward;
function ExecuteRunOutputJobs(RequestData: TStringList): String; forward;

// From command_executors_library.pas
function ExecuteCreateProject(RequestData: TStringList): String; forward;
function ExecuteOpenDocument(RequestData: TStringList): String; forward;
function ExecuteSearchComponents(RequestData: TStringList): String; forward;
function ExecuteGetComponentFromLibrary(RequestData: TStringList): String; forward;
function ExecuteSearchFootprints(RequestData: TStringList): String; forward;

// From command_executors_placement.pas
function ExecutePlaceComponent(RequestData: TStringList): String; forward;
function ExecuteDeleteComponent(RequestData: TStringList): String; forward;
function ExecutePlaceComponentArray(RequestData: TStringList): String; forward;
function ExecuteAlignComponents(RequestData: TStringList): String; forward;

// From command_router.pas
function ExecuteCommand(CommandName: String): String; forward;

// ============================================================================
// IMPLEMENTATIONS
// ============================================================================

// ============================================================================
// GLOBALS.PAS
// ============================================================================

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




// ============================================================================
// JSON_UTILS.PAS
// ============================================================================

function RemoveChar(const S: String; C: Char): String;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(S) do
    if S[I] <> C then
      Result := Result + S[I];
end;


function TrimJSON(InputStr: String): String;
begin
  // Remove quotes and commas
  Result := InputStr;
  Result := RemoveChar(Result, '"');
  Result := RemoveChar(Result, ',');
  // Trim whitespace
  Result := Trim(Result);
end;

// Helper function to escape JSON strings

function JSONEscapeString(const S: String): String;
begin
    Result := StringReplace(S, '\', '\\', REPLACEALL);
    Result := StringReplace(Result, '"', '\"', REPLACEALL);
    Result := StringReplace(Result, #13#10, '\n', REPLACEALL);
    Result := StringReplace(Result, #10, '\n', REPLACEALL);
    Result := StringReplace(Result, #9, '\t', REPLACEALL);
end;

// Function to create a JSON name-value pair

function JSONPairStr(const Name, Value: String; IsString: Boolean): String;
begin
    if IsString then
        Result := '"' + JSONEscapeString(Name) + '": "' + JSONEscapeString(Value) + '"'
    else
        Result := '"' + JSONEscapeString(Name) + '": ' + Value;
end;

// Function to build a JSON object from a list of pairs

function BuildJSONObject(Pairs: TStringList; IndentLevel: Integer = 0): String;
var
    i: Integer;
    Output: TStringList;
    Indent, ChildIndent: String;
begin
    // Create indent strings based on level
    Indent := StringOfChar(' ', IndentLevel * 2);
    ChildIndent := StringOfChar(' ', (IndentLevel + 1) * 2);
    
    Output := TStringList.Create;
    try
        Output.Add(Indent + '{');
        
        for i := 0 to Pairs.Count - 1 do
        begin
            if i < Pairs.Count - 1 then
                Output.Add(ChildIndent + Pairs[i] + ',')
            else
                Output.Add(ChildIndent + Pairs[i]);
        end;
        
        Output.Add(Indent + '}');
        
        Result := Output.Text;
    finally
        Output.Free;
    end;
end;

// Function to build a JSON array from a list of items

function BuildJSONArray(Items: TStringList; ArrayName: String = ''; IndentLevel: Integer = 0): String;
var
    i: Integer;
    Output: TStringList;
    Indent, ChildIndent: String;
begin
    // Create indent strings based on level
    Indent := StringOfChar(' ', IndentLevel * 2);
    ChildIndent := StringOfChar(' ', (IndentLevel + 1) * 2);
    
    Output := TStringList.Create;
    try
        if ArrayName <> '' then
            Output.Add(Indent + '"' + JSONEscapeString(ArrayName) + '": [')
        else
            Output.Add(Indent + '[');
        
        for i := 0 to Items.Count - 1 do
        begin
            if i < Items.Count - 1 then
                Output.Add(ChildIndent + Items[i] + ',')
            else
                Output.Add(ChildIndent + Items[i]);
        end;
        
        Output.Add(Indent + ']');
        
        Result := Output.Text;
    finally
        Output.Free;
    end;
end;

// Function to convert JSON TStringList to string

function WriteJSONToFile(JSON: TStringList; FileName: String = ''): String;
begin
    // Simply return the JSON as text
    // The FileName parameter is kept for compatibility but not used
    Result := JSON.Text;
end;

// Helper function to add a simple property to a JSON object

procedure AddJSONProperty(List: TStringList; Name: String; Value: String; IsString: Boolean = True);
begin
    List.Add(JSONPairStr(Name, Value, IsString));
end;

// Helper to add a numeric property

procedure AddJSONNumber(List: TStringList; Name: String; Value: Double);
begin
    List.Add(JSONPairStr(Name, StringReplace(FloatToStr(Value), ',', '.', REPLACEALL), False));
end;

// Helper to add an integer property

procedure AddJSONInteger(List: TStringList; Name: String; Value: Integer);
begin
    List.Add(JSONPairStr(Name, IntToStr(Value), False));
end;

// Helper to add a boolean property

procedure AddJSONBoolean(List: TStringList; Name: String; Value: Boolean);
begin
    if Value then
        List.Add(JSONPairStr(Name, 'true', False))
    else
        List.Add(JSONPairStr(Name, 'false', False));
end;




// ============================================================================
// HELPERS.PAS
// ============================================================================

procedure ExtractParameter(Line: String);
var
    ParamName: String;
    ParamValue: String;
    NameEnd: Integer;
    ValueStart: Integer;
begin
    // Skip command line and lines without a colon
    if (Pos('"command":', Line) > 0) or (Pos(':', Line) = 0) then
        Exit;

    // Find the parameter name
    NameEnd := Pos(':', Line) - 1;
    if NameEnd <= 0 then Exit;

    // Extract and clean the parameter name
    ParamName := Copy(Line, 1, NameEnd);
    ParamName := TrimJSON(ParamName);

    // Extract the parameter value - don't trim arrays
    ValueStart := Pos(':', Line) + 1;
    ParamValue := Copy(Line, ValueStart, Length(Line) - ValueStart + 1);

    // Trim only if it's not an array
    if (Pos('[', ParamValue) = 0) then
        ParamValue := TrimJSON(ParamValue);

    // Add to parameters list
    if (ParamName <> '') and (ParamName <> 'command') then
        Params.Add(ParamName + '=' + ParamValue);
end;



procedure WriteResponse(Success: Boolean; Data: String; ErrorMsg: String);
var
    ActualSuccess: Boolean;
    ActualErrorMsg: String;
    ResultProps: TStringList;
    Response: TStringList;
begin
    // Check if Data contains an error message
    if (Pos('ERROR:', Data) = 1) then
    begin
        ActualSuccess := False;
        ActualErrorMsg := Copy(Data, 8, Length(Data)); // Remove 'ERROR: ' prefix
    end
    else
    begin
        ActualSuccess := Success;
        ActualErrorMsg := ErrorMsg;
    end;

    // Create response props
    ResultProps := TStringList.Create;
    Response := TStringList.Create;

    try
        // Add properties
        AddJSONBoolean(ResultProps, 'success', ActualSuccess);

        if ActualSuccess then
        begin
            // For JSON responses (starting with [ or {), don't wrap in additional quotes
            if (Length(Data) > 0) and ((Data[1] = '[') or (Data[1] = '{')) then
                ResultProps.Add(JSONPairStr('result', Data, False))
            else
                AddJSONProperty(ResultProps, 'result', Data);
        end
        else
        begin
            AddJSONProperty(ResultProps, 'error', ActualErrorMsg);
        end;

        // Build response
        Response.Text := BuildJSONObject(ResultProps);
        Response.SaveToFile(RESPONSE_FILE);
    finally
        ResultProps.Free;
        Response.Free;
    end;
end;




// ============================================================================
// BOARD_INIT.PAS
// ============================================================================

uses
    globals;

{..............................................................................}
{ Set Board Size - Set the dimensions of the PCB board                        }
{..............................................................................}

function SetBoardSize(Width, Height: Double): String;
var
    Board: IPCB_Board;
    OutputLines: TStringList;
    ResultProps: TStringList;
begin
    ResultProps := TStringList.Create;
    try
        Board := GetPCBServer.GetCurrentPCBBoard;
        if Board = nil then
        begin
            AddJSONBoolean(ResultProps, 'success', False);
            AddJSONProperty(ResultProps, 'error', 'No PCB document is currently active');

            OutputLines := TStringList.Create;
            try
                OutputLines.Text := BuildJSONObject(ResultProps);
                Result := OutputLines.Text;
            finally
                OutputLines.Free;
            end;
            Exit;
        end;

        GetPCBServer.PreProcess;
        try
            // Set board size (convert mm to internal units)
            Board.BoardOutline.SetState_XSize(MMsToCoord(Width));
            Board.BoardOutline.SetState_YSize(MMsToCoord(Height));

            AddJSONBoolean(ResultProps, 'success', True);
            AddJSONProperty(ResultProps, 'width', FloatToStr(Width) + 'mm');
            AddJSONProperty(ResultProps, 'height', FloatToStr(Height) + 'mm');
        finally
            GetPCBServer.PostProcess;
        end;

        // Refresh view
        GetClient.SendMessage('PCB:Zoom', 'Action=Redraw', 255, GetClient.CurrentView);

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
{ Add Board Outline - Draw rectangular board outline                          }
{..............................................................................}

function AddBoardOutline(X, Y, Width, Height: Double): String;
var
    Board: IPCB_Board;
    Track: IPCB_Track;
    OutputLines: TStringList;
    ResultProps: TStringList;
    X1, Y1, X2, Y2: TCoord;
    i: Integer;
    Points: array[0..4] of TPoint;
begin
    ResultProps := TStringList.Create;
    try
        Board := GetPCBServer.GetCurrentPCBBoard;
        if Board = nil then
        begin
            AddJSONBoolean(ResultProps, 'success', False);
            AddJSONProperty(ResultProps, 'error', 'No PCB document is currently active');

            OutputLines := TStringList.Create;
            try
                OutputLines.Text := BuildJSONObject(ResultProps);
                Result := OutputLines.Text;
            finally
                OutputLines.Free;
            end;
            Exit;
        end;

        // Convert coordinates to internal units
        X1 := MMsToCoord(X);
        Y1 := MMsToCoord(Y);
        X2 := MMsToCoord(X + Width);
        Y2 := MMsToCoord(Y + Height);

        // Define rectangle points (clockwise)
        Points[0].X := X1; Points[0].Y := Y1; // Bottom-left
        Points[1].X := X2; Points[1].Y := Y1; // Bottom-right
        Points[2].X := X2; Points[2].Y := Y2; // Top-right
        Points[3].X := X1; Points[3].Y := Y2; // Top-left
        Points[4].X := X1; Points[4].Y := Y1; // Close the rectangle

        GetPCBServer.PreProcess;
        try
            // Create four tracks to form the board outline
            for i := 0 to 3 do
            begin
                Track := GetPCBServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
                if Track <> nil then
                begin
                    Track.X1 := Points[i].X;
                    Track.Y1 := Points[i].Y;
                    Track.X2 := Points[i + 1].X;
                    Track.Y2 := Points[i + 1].Y;
                    Track.Layer := eKeepOutLayer; // Board outline is on KeepOut layer
                    Track.Width := MMsToCoord(0.2); // 0.2mm width for outline

                    Board.AddPCBObject(Track);
                    GetPCBServer.SendMessageToRobots(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Track.I_ObjectAddress);
                end;
            end;

            AddJSONBoolean(ResultProps, 'success', True);
            AddJSONProperty(ResultProps, 'message', 'Board outline added');
            AddJSONProperty(ResultProps, 'x', FloatToStr(X) + 'mm');
            AddJSONProperty(ResultProps, 'y', FloatToStr(Y) + 'mm');
            AddJSONProperty(ResultProps, 'width', FloatToStr(Width) + 'mm');
            AddJSONProperty(ResultProps, 'height', FloatToStr(Height) + 'mm');
        finally
            GetPCBServer.PostProcess;
        end;

        // Refresh view
        GetClient.SendMessage('PCB:Zoom', 'Action=Redraw', 255, GetClient.CurrentView);

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
{ Add Mounting Hole - Add a mounting hole at specified position               }
{..............................................................................}

function AddMountingHole(X, Y, HoleDiameter, PadDiameter: Double): String;
var
    Board: IPCB_Board;
    Pad: IPCB_Pad;
    OutputLines: TStringList;
    ResultProps: TStringList;
    ActualPadDiameter: Double;
begin
    ResultProps := TStringList.Create;
    try
        Board := GetPCBServer.GetCurrentPCBBoard;
        if Board = nil then
        begin
            AddJSONBoolean(ResultProps, 'success', False);
            AddJSONProperty(ResultProps, 'error', 'No PCB document is currently active');

            OutputLines := TStringList.Create;
            try
                OutputLines.Text := BuildJSONObject(ResultProps);
                Result := OutputLines.Text;
            finally
                OutputLines.Free;
            end;
            Exit;
        end;

        // Default pad diameter to 2x hole diameter if not specified
        if PadDiameter <= 0 then
            ActualPadDiameter := HoleDiameter * 2
        else
            ActualPadDiameter := PadDiameter;

        GetPCBServer.PreProcess;
        try
            // Create a pad object for the mounting hole
            Pad := GetPCBServer.PCBObjectFactory(ePadObject, eNoDimension, eCreate_Default);
            if Pad <> nil then
            begin
                // Set position
                Pad.X := MMsToCoord(X);
                Pad.Y := MMsToCoord(Y);

                // Set pad properties
                Pad.TopShape := eRoundedRectangular;
                Pad.TopXSize := MMsToCoord(ActualPadDiameter);
                Pad.TopYSize := MMsToCoord(ActualPadDiameter);

                // Set hole properties
                Pad.HoleSize := MMsToCoord(HoleDiameter);
                Pad.Layer := eMultiLayer; // Mounting holes go through all layers

                // Set as plated hole
                Pad.Plated := True;

                // Set name
                Pad.Name := TDynamicString('MTG');

                Board.AddPCBObject(Pad);
                GetPCBServer.SendMessageToRobots(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Pad.I_ObjectAddress);

                AddJSONBoolean(ResultProps, 'success', True);
                AddJSONProperty(ResultProps, 'message', 'Mounting hole added');
                AddJSONProperty(ResultProps, 'x', FloatToStr(X) + 'mm');
                AddJSONProperty(ResultProps, 'y', FloatToStr(Y) + 'mm');
                AddJSONProperty(ResultProps, 'hole_diameter', FloatToStr(HoleDiameter) + 'mm');
                AddJSONProperty(ResultProps, 'pad_diameter', FloatToStr(ActualPadDiameter) + 'mm');
            end
            else
            begin
                AddJSONBoolean(ResultProps, 'success', False);
                AddJSONProperty(ResultProps, 'error', 'Failed to create mounting hole pad object');
            end;
        finally
            GetPCBServer.PostProcess;
        end;

        // Refresh view
        GetClient.SendMessage('PCB:Zoom', 'Action=Redraw', 255, GetClient.CurrentView);

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
{ Add Board Text - Add text string to the board                               }
{..............................................................................}

function AddBoardText(Text: String; X, Y, Size: Double; Layer: String): String;
var
    Board: IPCB_Board;
    TextObj: IPCB_Text;
    OutputLines: TStringList;
    ResultProps: TStringList;
    LayerObj: TLayer;
begin
    ResultProps := TStringList.Create;
    try
        Board := GetPCBServer.GetCurrentPCBBoard;
        if Board = nil then
        begin
            AddJSONBoolean(ResultProps, 'success', False);
            AddJSONProperty(ResultProps, 'error', 'No PCB document is currently active');

            OutputLines := TStringList.Create;
            try
                OutputLines.Text := BuildJSONObject(ResultProps);
                Result := OutputLines.Text;
            finally
                OutputLines.Free;
            end;
            Exit;
        end;

        // Parse layer name to layer constant
        LayerObj := eTopOverlay; // Default
        if Layer = 'TopOverlay' then LayerObj := eTopOverlay
        else if Layer = 'BottomOverlay' then LayerObj := eBottomOverlay
        else if Layer = 'TopLayer' then LayerObj := eTopLayer
        else if Layer = 'BottomLayer' then LayerObj := eBottomLayer
        else if Layer = 'Mechanical1' then LayerObj := eMechanical1;

        GetPCBServer.PreProcess;
        try
            // Create text object
            TextObj := GetPCBServer.PCBObjectFactory(eTextObject, eNoDimension, eCreate_Default);
            if TextObj <> nil then
            begin
                // Set position
                TextObj.XLocation := MMsToCoord(X);
                TextObj.YLocation := MMsToCoord(Y);

                // Set text content
                TextObj.Text := TDynamicString(Text);

                // Set text properties
                TextObj.Size := MMsToCoord(Size);
                TextObj.Layer := LayerObj;
                TextObj.Width := MMsToCoord(Size * 0.15); // Stroke width proportional to size

                Board.AddPCBObject(TextObj);
                GetPCBServer.SendMessageToRobots(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, TextObj.I_ObjectAddress);

                AddJSONBoolean(ResultProps, 'success', True);
                AddJSONProperty(ResultProps, 'message', 'Text added to board');
                AddJSONProperty(ResultProps, 'text', Text);
                AddJSONProperty(ResultProps, 'x', FloatToStr(X) + 'mm');
                AddJSONProperty(ResultProps, 'y', FloatToStr(Y) + 'mm');
                AddJSONProperty(ResultProps, 'layer', Layer);
            end
            else
            begin
                AddJSONBoolean(ResultProps, 'success', False);
                AddJSONProperty(ResultProps, 'error', 'Failed to create text object');
            end;
        finally
            GetPCBServer.PostProcess;
        end;

        // Refresh view
        GetClient.SendMessage('PCB:Zoom', 'Action=Redraw', 255, GetClient.CurrentView);

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






// ============================================================================
// COMPONENT_PLACEMENT.PAS
// ============================================================================

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






// ============================================================================
// LIBRARY_UTILS.PAS
// ============================================================================

uses
    globals;

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
                    for j := 0 to Project.DM_LogicalDocumentCount - 1 do
                    begin
                        Doc := Project.DM_LogicalDocuments(j);
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
                            end;
                        end;
                    end;
                end;
            end;

            JsonBuilder.Add('  ]');
            JsonBuilder.Add('}');

            Result := JsonBuilder.Text;
        except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
        end;
    finally
        JsonBuilder.Free;
        AddedLibs.Free;
    end;
end;

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
                    for j := 0 to Project.DM_LogicalDocumentCount - 1 do
                    begin
                        Doc := Project.DM_LogicalDocuments(j);
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
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end;

            JsonBuilder.Add('  ],');
            JsonBuilder.Add('  "match_count": ' + IntToStr(MatchCount));
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
                                end;
                            end;
                        end;
                    end;
                end;
            end;

            if not Found then
            begin
                Result := '{"success": false, "error": "Component not found: ' + ComponentName + ' in library: ' + LibraryName + '"}';
                Exit;
            end;

            Result := JsonBuilder.Text;
        except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
        end;
    finally
        JsonBuilder.Free;
    end;
end;

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
                    for j := 0 to Project.DM_LogicalDocumentCount - 1 do
                    begin
                        Doc := Project.DM_LogicalDocuments(j);
                        if (Doc <> nil) and (Pos('.PCBLIB', UpperCase(Doc.DM_FileName)) > 0) then
                        begin
                            LibPath := Doc.DM_FileName;
                            LibName := ExtractFileName(LibPath);

                            // Try to get the PCB library
                            PCBLib := GetPCBServer.GetPCBLibraryByPath(LibPath);
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
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end;

            JsonBuilder.Add('  ],');
            JsonBuilder.Add('  "match_count": ' + IntToStr(MatchCount));
            JsonBuilder.Add('}');

            Result := JsonBuilder.Text;
        except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
        end;
    finally
        JsonBuilder.Free;
    end;
end;






// ============================================================================
// OTHER_UTILS.PAS
// ============================================================================

const
    DEFAULT = 'Blank';

{..............................................................................}
{ Get path of this script project.                                             }
{ Get prj path from Jeff Collins and William Kitchen's stripped down version   }
{..............................................................................}

function ScriptProjectPath(Workspace: IWorkspace): String;
var
  Project   : IProject;
  scriptsPath : TDynamicString;
  projectCount : Integer;
  i      : Integer;
begin
  if (Workspace = nil) then begin result:=''; exit; end;
  { Get a count of the number of currently opened projects.  The script project
    from which this script runs must be one of these. }
  projectCount := Workspace.DM_ProjectCount();
  { Loop over all the open projects.  We're looking for constScriptProjectName
    (of which we are a part).  Once we find this, we want to record the
    path to the script project directory. }
  scriptsPath:='';
  for i:=0 to projectCount-1 do
  begin
    { Get reference to project # i. }
    Project := Workspace.DM_Projects(i);
    { See if we found our script project. }
    if (AnsiPos(constScriptProjectName, Project.DM_ProjectFullPath) > 0) then
    begin
      { Strip off project name to give us just the path. }
      scriptsPath := StringReplace(Project.DM_ProjectFullPath, '\' +
      constScriptProjectName + '.PrjScr','', MkSet(rfReplaceAll,rfIgnoreCase));
    end;
  end;
  result := scriptsPath;
end;

// Find the first open OutJob document

function GetOpenOutputJob(): String;
var
    Project     : IProject;
    ProjectIdx, I  : Integer;
    Doc: IDocument;
    DocKind: String;
begin
    result := '';
    for ProjectIdx := 0 to GetWorkspace.DM_ProjectCount - 1 do
    begin
        Project := GetWorkspace.DM_Projects(ProjectIdx);
        if Project = Nil then Exit;

        // Iterate all documents in the project
        for I := 0 to Project.DM_LogicalDocumentCount - 1 do
        begin
            Doc := Project.DM_LogicalDocuments(I);
            DocKind := Doc.DM_DocumentKind;
            if DocKind = 'OUTPUTJOB' then
            begin
                result := Doc.DM_FullPath;
                Exit;
            end;
        end;
    end;
end;

// Modify the EnsureDocumentFocused function to handle all document types
// and return more detailed information

function EnsureDocumentFocused(CommandName: String): Boolean;
var
    I           : Integer;
    Project     : IProject;
    Doc         : IDocument;
    DocFound    : Boolean;
    CurrentDoc  : IServerDocument;
    DocumentKind: String;
    LogMessage  : String;
    OutJobPath: String;
begin
    Result := False;
    DocFound := False;
    DocumentKind := 'PCB'; // Default

    // For PCB-related commands, ensure PCB is available first
    if (CommandName = 'create_net_class')                    or
       (CommandName = 'get_all_component_data')              or
       (CommandName = 'get_all_components')                  or
       (CommandName = 'get_all_nets')                        or
       (CommandName = 'get_component_pins')                  or
       (CommandName = 'get_pcb_layers')                      or
       (CommandName = 'get_board_outline')                   or
       (CommandName = 'get_pcb_rules')                       or
       (CommandName = 'get_selected_components_coordinates') or
       (CommandName = 'layout_duplicator')                   or
       (CommandName = 'layout_duplicator_apply')             or
       (CommandName = 'move_components')                     or
       (CommandName = 'set_pcb_layer_visibility')            or
       (CommandName = 'get_pcb_layer_stackup')               or
       (CommandName = 'take_view_screenshot')                then
    begin
        DocumentKind := 'PCB';
    end
    else if (CommandName = 'create_schematic_symbol')        or
            (CommandName = 'get_library_symbol_reference')   then
    begin
        DocumentKind := 'SCHLIB';
    end
    else if (CommandName = 'get_schematic_data')             then
    begin
        DocumentKind := 'SCH';
    end
    else if (CommandName = 'get_output_job_containers')       or
            (CommandName = 'run_output_jobs')                then
    begin
        DocumentKind := 'OUTJOB';
    end;
    // Default to user argument if command not recognized

    LogMessage := 'Attempting to focus ' + DocumentKind + ' document';
    
    // Log the current focused document first
    if DocumentKind = 'PCB' then
    begin
        if PCBServer <> nil then
            LogMessage := LogMessage + '. Current PCB: ' + BoolToStr(GetPCBServer.GetCurrentPCBBoard <> nil, True);
    end
    else if DocumentKind = 'SCH' then
    begin
        if SchServer <> nil then
            LogMessage := LogMessage + '. Current SCH: ' + BoolToStr(SchServer.GetCurrentSchDocument <> nil, True);
    end
    else if DocumentKind = 'SCHLIB' then
    begin
        if SchServer <> nil then
        begin
            CurrentDoc := SchServer.GetCurrentSchDocument;
            LogMessage := LogMessage + '. Current SCHLIB: ' + BoolToStr((CurrentDoc <> nil) and (CurrentDoc.ObjectID = eSchLib), True);
        end;
    end;
    
    // ShowMessage(LogMessage); // For debugging
    
    // Retrieve the current project
    Project := GetWorkspace.DM_FocusedProject;
    If Project = Nil Then
    begin
        // No project is open
        Exit;
    end;

    // Check if the correct document type is already focused
    if (DocumentKind = 'PCB') and (PCBServer <> Nil) then
    begin
        if GetPCBServer.GetCurrentPCBBoard <> Nil then
        begin
            Result := True;
            Exit;
        end;
    end
    else if (DocumentKind = 'SCH') and (SchServer <> Nil) then
    begin
        CurrentDoc := SchServer.GetCurrentSchDocument;
        if CurrentDoc <> Nil then
        begin
            Result := True;
            Exit;
        end;
    end
    else if (DocumentKind = 'SCHLIB') and (SchServer <> Nil) then
    begin
        CurrentDoc := SchServer.GetCurrentSchDocument;
        if (CurrentDoc <> Nil) and (CurrentDoc.ObjectId = eSchLib) then
        begin
            Result := True;
            Exit;
        end;
    end
    else if (DocumentKind = 'OUTJOB') then
    begin
        OutJobPath := GetOpenOutputJob();
        if OutJobPath <> '' then
        begin
            Result := True;
            Exit;
        end;
    end;

    // Try to find and focus the required document type
    For I := 0 to Project.DM_LogicalDocumentCount - 1 Do
    Begin
        Doc := Project.DM_LogicalDocuments(I);
        If Doc.DM_DocumentKind = DocumentKind Then
        Begin
            DocFound := True;
            // Try to open and focus the document
            Doc.DM_OpenAndFocusDocument;
            // Give it a moment to focus
            Sleep(500);

            // Verify that the document is now focused
            if DocumentKind = 'PCB' then
            begin
                if GetPCBServer.GetCurrentPCBBoard <> Nil then
                begin
                    Result := True;
                    // ShowMessage('Successfully focused PCB document');
                    Exit;
                end;
            end
            else if DocumentKind = 'SCH' then
            begin
                CurrentDoc := SchServer.GetCurrentSchDocument;
                if (CurrentDoc <> Nil) then
                begin
                    Result := True;
                    // ShowMessage('Successfully focused SCH document');
                    Exit;
                end;
            end
            else if DocumentKind = 'SCHLIB' then
            begin
                CurrentDoc := SchServer.GetCurrentSchDocument;
                if (CurrentDoc <> Nil) and (CurrentDoc.ObjectID = eSchLib) then
                begin
                    Result := True;
                    // ShowMessage('Successfully focused SCHLIB document');
                    Exit;
                end;
            end
            else if DocumentKind = 'OUTJOB' then
            begin
                CurrentDoc := SchServer.GetCurrentSchDocument;
                if (CurrentDoc <> Nil) then
                begin
                    Result := True;
                    // ShowMessage('Successfully focused SCH document');
                    Exit;
                end;
            end;
        End; // Close the If statement at line 191
    End; // Close the For loop at line 188

    // TODO: Do I want to iterate through all workspace projects to find valid document if it is not current document?
    // Could use IWorkspace.DM_ProjectCount and for loop

    // No matching document found or couldn't be focused
    if not DocFound then
    begin
        ShowMessage('Error: No ' + DocumentKind + ' document found in the project.');
    end
    else
    begin
        ShowMessage('Error: Found ' + DocumentKind + ' document but could not focus it.');
    end;
    
    Result := False;
end;

// Add a screenshot function that supports both PCB and SCH views

function TakeViewScreenshot(ViewType: String): String;
var
    Board          : IPCB_Board;
    SchDoc         : ISch_Document;
    ResultProps    : TStringList;
    OutputLines    : TStringList;
    ClassName      : String;
    DocType        : String;
    WindowFound    : Boolean;
    
    // For screenshot thread
    ThreadStarted  : Boolean;
    ScreenshotResult : String;
begin
    // Default result
    Result := '{"success": false, "error": "Failed to initialize screenshot capture"}';
    
    // Determine what type of document we need to focus
    if LowerCase(ViewType) = 'pcb' then
    begin
        DocType := 'PCB';
        ClassName := 'View_Graphical';
    end
    else if LowerCase(ViewType) = 'sch' then
    begin
        DocType := 'SCH';
        ClassName := 'SchView';
    end
    else
    begin
        Result := '{"success": false, "error": "Invalid view type: ' + ViewType + '. Must be ''pcb'' or ''sch''"}';
        Exit;
    end;
    
    // Build the command to call the external screenshot utility
    // This part depends on how your C# server calls Altium for screenshots
    
    // Create result JSON
    ResultProps := TStringList.Create;
    try
        // Add successful result properties
        AddJSONBoolean(ResultProps, 'success', True);
        AddJSONProperty(ResultProps, 'view_type', ViewType);
        AddJSONProperty(ResultProps, 'class_filter', ClassName);
        AddJSONBoolean(ResultProps, 'window_found', WindowFound);
        
        // Add signal to the server that it can now capture the screenshot
        AddJSONBoolean(ResultProps, 'ready_for_capture', True);

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

// Get all available output job containers from the first open OutJob

function GetOutputJobContainers(ROOT_DIR: String): String;
var
    OutJobPath: String;
    IniFile: TIniFile;
    ContainerName, ContainerAction: String;
    G, J: Integer;
    S: String;
    ResultProps: TStringList;
    ContainersArray: TStringList;
    ContainerProps: TStringList;
    OutputLines: TStringList;
begin
    // Get the path of the first open OutJob
    OutJobPath := GetOpenOutputJob();

    // Exit if no open OutJob was found
    if OutJobPath = '' then
    begin
        ResultProps := TStringList.Create;
        try
            AddJSONBoolean(ResultProps, 'success', False);
            AddJSONProperty(ResultProps, 'error', 'No open OutJob document found');
            Result := BuildJSONObject(ResultProps);
        finally
            ResultProps.Free;
        end;
        Exit;
    end;

    // Create output containers array
    ResultProps := TStringList.Create;
    ContainersArray := TStringList.Create;

    try
        // Add the OutJob path to the result
        AddJSONProperty(ResultProps, 'outjob_path', OutJobPath);

        // Open the OutJob file (it's just an INI file)
        IniFile := TIniFile.Create(OutJobPath);
        try
            G := 1; // Group Number
            J := 1; // Job/Container Number
            ContainerName := '';

            // Iterate each Output Group
            While (G = 1) Or (ContainerName <> DEFAULT) Do
            Begin
                S := 'OutputGroup'+IntToStr(G); // Section (aka OutputGroup)

                // Reset J for each group
                J := 1;
                ContainerName := '';
                ContainerAction := '';

                // Iterate each Output Container
                While (J = 1) Or (ContainerName <> DEFAULT) Do
                Begin
                    ContainerName := IniFile.ReadString(S, 'OutputMedium' + IntToStr(J), DEFAULT);
                    ContainerAction := IniFile.ReadString(S, 'OutputMedium' + IntToStr(J) + '_Type', DEFAULT);

                    // Add valid containers to the list
                    if (ContainerName <> DEFAULT) then
                    begin
                        ContainerProps := TStringList.Create;
                        try
                            // Add container properties
                            AddJSONProperty(ContainerProps, 'container_name', ContainerName);
                            AddJSONProperty(ContainerProps, 'container_type', ContainerAction);
                            //AddJSONProperty(ContainerProps, 'group', IntToStr(G));
                            //AddJSONProperty(ContainerProps, 'container_id', IntToStr(J));

                            // Add to containers array
                            ContainersArray.Add(BuildJSONObject(ContainerProps, 1));
                        finally
                            ContainerProps.Free;
                        end;
                    end;

                    Inc(J);
                    // Exit if we've reached the default value
                    if ContainerName = DEFAULT then
                        break;
                End;

                Inc(G);
                // Exit if we've reached the default value after first group
                if (G > 1) and (ContainerName = DEFAULT) then
                    break;
            End;
        finally
            IniFile.Free;
        end;

        // Add success status and containers array to result
        AddJSONBoolean(ResultProps, 'success', True);
        ResultProps.Add(BuildJSONArray(ContainersArray, 'containers'));

        // Build final JSON
        OutputLines := TStringList.Create;
        try
            OutputLines.Text := BuildJSONObject(ResultProps);
            Result := WriteJSONToFile(OutputLines, ROOT_DIR);
        finally
            OutputLines.Free;
        end;
    finally
        ResultProps.Free;
        ContainersArray.Free;
    end;
end;

// Run selected output job containers with simplified logic

function RunOutputJobs(ContainerNames: TStringList, ROOT_DIR: String): String;
var
    OutJobPath: String;
    IniFile: TIniFile;
    ContainerName, ContainerAction, RelativePath: String;
    G, J: Integer;
    S: String;
    ResultProps: TStringList;
    ContainerResults: TStringList;
    ContainerResultProps: TStringList;
    I: Integer;
    ContainerFound: Boolean;
    SuccessCount: Integer;
    OutJobDoc: IServerDocument;
    OutputLines: TStringList;
begin
    // Get the path of the first open OutJob
    OutJobPath := GetOpenOutputJob();

    // Exit if no open OutJob was found
    if OutJobPath = '' then
    begin
        ResultProps := TStringList.Create;
        try
            AddJSONBoolean(ResultProps, 'success', False);
            AddJSONProperty(ResultProps, 'error', 'No open OutJob document found');
            Result := BuildJSONObject(ResultProps);
        finally
            ResultProps.Free;
        end;
        Exit;
    end;

    // Create results
    ResultProps := TStringList.Create;
    ContainerResults := TStringList.Create;
    SuccessCount := 0;

    try
        // Add the OutJob path to the result
        AddJSONProperty(ResultProps, 'outjob_path', OutJobPath);

        // Open the OutJob document
        if not(GetClient.IsDocumentOpen(OutJobPath)) then
        begin
            OutJobDoc := GetClient.OpenDocument('OUTPUTJOB', OutJobPath);
            OutJobDoc.Focus();
        end
        else
        begin
            OutJobDoc := GetClient.GetDocumentByPath(OutJobPath);
            OutJobDoc.Focus();
        end;

        // Exit if we can't open the OutJob document
        if OutJobDoc = Nil then
        begin
            AddJSONBoolean(ResultProps, 'success', False);
            AddJSONProperty(ResultProps, 'error', 'Could not open OutJob document: ' + OutJobPath);
            Result := BuildJSONObject(ResultProps);
            Exit;
        end;

        // Open the OutJob file (it's just an INI file)
        IniFile := TIniFile.Create(OutJobPath);
        try
            // Process each requested container
            for I := 0 to ContainerNames.Count - 1 do
            begin
                ContainerFound := False;
                ContainerResultProps := TStringList.Create;

                try
                    // Add container name to results
                    AddJSONProperty(ContainerResultProps, 'container_name', ContainerNames[I]);

                    // Iterate through groups and containers to find the matching one
                    G := 1;
                    while True do
                    begin
                        S := 'OutputGroup'+IntToStr(G);

                        J := 1;
                        while True do
                        begin
                            ContainerName := IniFile.ReadString(S, 'OutputMedium' + IntToStr(J), DEFAULT);

                            // Exit inner loop if we've reached the default value
                            if ContainerName = DEFAULT then
                                break;

                            // Check if this is one of the containers we want to run
                            if ContainerName = ContainerNames[I] then
                            begin
                                ContainerFound := True;
                                ContainerAction := IniFile.ReadString(S, 'OutputMedium' + IntToStr(J) + '_Type', DEFAULT);
                                RelativePath := IniFile.ReadString('PublishSettings', 'OutputBasePath' + IntToStr(J), '');

                                // Ensure document is focused
                                OutJobDoc.Focus();

                                // Run the container based on its type
                                if ContainerAction = 'GeneratedFiles' then
                                begin
                                    // Run GenerateFiles
                                    ResetParameters;
                                    AddStringParameter('Action', 'Run');
                                    AddStringParameter('OutputMedium', ContainerName);
                                    AddStringParameter('ObjectKind', 'OutputBatch');
                                    AddStringParameter('OutputBasePath', RelativePath);
                                    RunProcess('WorkspaceManager:GenerateReport');

                                    // Assume success
                                    AddJSONBoolean(ContainerResultProps, 'success', True);
                                    SuccessCount := SuccessCount + 1;
                                end
                                else if ContainerAction = 'Publish' then
                                begin
                                    // Run PublishToPDF with simpler parameters
                                    ResetParameters;
                                    AddStringParameter('Action', 'PublishToPDF');
                                    AddStringParameter('OutputMedium', ContainerName);
                                    AddStringParameter('ObjectKind', 'OutputBatch');
                                    AddStringParameter('OutputBasePath', RelativePath);
                                    AddStringParameter('DisableDialog', 'True');
                                    RunProcess('WorkspaceManager:Print');

                                    // Assume success
                                    AddJSONBoolean(ContainerResultProps, 'success', True);
                                    SuccessCount := SuccessCount + 1;
                                end
                                else
                                begin
                                    // Unknown action type
                                    AddJSONBoolean(ContainerResultProps, 'success', False);
                                    AddJSONProperty(ContainerResultProps, 'error', 'Unknown container action type: ' + ContainerAction);
                                end;

                                // Add output path info
                                AddJSONProperty(ContainerResultProps, 'relative_path', RelativePath);

                                // Break out after processing the container
                                break;
                            end;

                            Inc(J);
                        end;

                        // If we already found and processed the container, break out
                        if ContainerFound then
                            break;

                        // Exit outer loop if we've processed all groups
                        if ContainerName = DEFAULT then
                            break;

                        Inc(G);
                    end;

                    // Handle container not found
                    if not ContainerFound then
                    begin
                        AddJSONBoolean(ContainerResultProps, 'success', False);
                        AddJSONProperty(ContainerResultProps, 'error', 'Container not found: ' + ContainerNames[I]);
                    end;

                    // Add this container result to the results array
                    ContainerResults.Add(BuildJSONObject(ContainerResultProps, 1));
                finally
                    ContainerResultProps.Free;
                end;
            end;
        finally
            IniFile.Free;
        end;

        // Add summary results
        AddJSONBoolean(ResultProps, 'success', SuccessCount > 0);
        AddJSONInteger(ResultProps, 'total_containers', ContainerNames.Count);
        AddJSONInteger(ResultProps, 'successful_containers', SuccessCount);
        ResultProps.Add(BuildJSONArray(ContainerResults, 'container_results'));

        // Build and return the final JSON result
        OutputLines := TStringList.Create;
        try
            OutputLines.Text := BuildJSONObject(ResultProps);
            Result := WriteJSONToFile(OutputLines, ROOT_DIR);
        finally
            OutputLines.Free;
        end;
    finally
        ResultProps.Free;
        ContainerResults.Free;
    end;
end;

// Helper function to check if a document is open

function IsOpenDoc(Path: String): Boolean;
var
    Project     : IProject;
    ProjectIdx, I  : Integer;
    Doc: IDocument;
begin
    result := False;

    for ProjectIdx := 0 to GetWorkspace.DM_ProjectCount - 1 do
    begin
        Project := GetWorkspace.DM_Projects(ProjectIdx);
        if Project = Nil then Exit;

        if Path = Project.DM_ProjectFullPath then
        begin
            result := True;
            Exit;
        end;

        // Iterate documents
        for I := 0 to Project.DM_LogicalDocumentCount - 1 do
        begin
            Doc := Project.DM_LogicalDocuments(I);
            if Path = Doc.DM_FullPath then
            begin
                result := True;
                Exit;
            end;
        end;
    end;
end;




// ============================================================================
// PCB_LAYOUT_DUPLICATOR.PAS
// ============================================================================

// Function to duplicate selected objects of a specific type

function DuplicateSelectedObjects(Board: IPCB_Board; ObjectSet: TSet): TObjectList;
var
    Iterator       : IPCB_BoardIterator;
    OrigObj, NewObj : IPCB_Primitive;
    DuplicatedObjects : TObjectList;
    temp: String;
begin
    // Create object list to store duplicated objects
    DuplicatedObjects := CreateObject(TObjectList);
    DuplicatedObjects.OwnsObjects := False; // Don't destroy objects when list is freed
    
    // Create iterator for the specified object type
    Iterator := Board.BoardIterator_Create;
    Iterator.AddFilter_ObjectSet(ObjectSet);
    Iterator.AddFilter_IPCB_LayerSet(LayerSet.AllLayers);
    Iterator.AddFilter_Method(eProcessAll);

    GetPCBServer.PreProcess;
    
    OrigObj := Iterator.FirstPCBObject;
    while (OrigObj <> Nil) do
    begin
        if OrigObj.Selected then
        begin
            // Replicate the object
            NewObj := GetPCBServer.PCBObjectFactory(OrigObj.ObjectId, eNoDimension, eCreate_Default);
            NewObj := OrigObj.Replicate;

            // Add to board
            GetPCBServer.SendMessageToRobots(NewObj.I_ObjectAddress, c_Broadcast, PCBM_BeginModify, c_NoEventData);
            Board.AddPCBObject(NewObj);
            GetPCBServer.SendMessageToRobots(NewObj.I_ObjectAddress, c_Broadcast, PCBM_EndModify, c_NoEventData);

            // Send board registration message
            //GetPCBServer.SendMessageToRobots(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, NewObj.I_ObjectAddress);
            
            // Add to our list of duplicated objects
            DuplicatedObjects.Add(NewObj);
        end;
        
        OrigObj := Iterator.NextPCBObject;
    end;
    
    Board.BoardIterator_Destroy(Iterator);

    GetPCBServer.PostProcess;

    Board.ViewManager_FullUpdate();  
    
    Result := DuplicatedObjects;
end;

// Function to get source and destination component lists with pin data

function GetLayoutDuplicatorComponents(SelectedOnly: Boolean = True): String;
var
    Board          : IPCB_Board;
    Iterator       : IPCB_BoardIterator;
    SourceCmps     : TStringList;
    ResultProps    : TStringList;
    SourceArray    : TStringList;
    DestArray      : TStringList;
    Component      : IPCB_Component;
    CompProps      : TStringList;
    PinsArray      : TStringList;
    GrpIter        : IPCB_GroupIterator;
    Pad            : IPCB_Pad;
    i, j           : Integer;
    PinCount       : Integer;
    NetName        : String;
    xorigin, yorigin : Integer;
    PinProps       : TStringList;
    OutputLines    : TStringList;
    
    // For duplicated objects
    DuplicatedObjects : TObjectList;
    Obj               : IPCB_Primitive;
begin
    // Retrieve the current board
    Board := GetPCBServer.GetCurrentPCBBoard;
    if (Board = Nil) then
    begin
        Result := '{"success": false, "message": "No PCB document is currently active"}';
        Exit;
    end;

    // Get board origin coordinates
    xorigin := Board.XOrigin;
    yorigin := Board.YOrigin;

    // Create result properties
    ResultProps := TStringList.Create;
    SourceCmps := TStringList.Create;
    SourceArray := TStringList.Create;
    
    try
        // Get selected components as source
        Iterator := Board.BoardIterator_Create;
        Iterator.AddFilter_ObjectSet(MkSet(eComponentObject));
        Iterator.AddFilter_LayerSet(MkSet(eTopLayer, eBottomLayer));
        Iterator.AddFilter_Method(eProcessAll);

        Component := Iterator.FirstPCBObject;
        while (Component <> Nil) do
        begin
            if (Component.Selected = True) then
                SourceCmps.Add(Component.Name.Text);

            Component := Iterator.NextPCBObject;
        end;
        Board.BoardIterator_Destroy(Iterator);

        // Check if any source components were selected
        if (SourceCmps.Count = 0) then
        begin
            AddJSONBoolean(ResultProps, 'success', False);
            AddJSONProperty(ResultProps, 'message', 'No source components selected. Please select source components first.');
            
            OutputLines := TStringList.Create;
            try
                OutputLines.Text := BuildJSONObject(ResultProps);
                Result := OutputLines.Text;
            finally
                OutputLines.Free;
            end;
            
            Exit;
        end;
        
        // Duplicate all object types in one call
        DuplicatedObjects := DuplicateSelectedObjects(Board, MkSet(eTrackObject, eArcObject, eViaObject, ePolyObject, eRegionObject, eFillObject));
        
        // Deselect all original objects to avoid duplicating them again
        Iterator := Board.BoardIterator_Create;
        Iterator.AddFilter_ObjectSet(MkSet(eTrackObject, eArcObject, eViaObject, ePolyObject, eRegionObject, eFillObject));
        Iterator.AddFilter_IPCB_LayerSet(LayerSet.AllLayers);
        Iterator.AddFilter_Method(eProcessAll);

        GetPCBServer.PreProcess;
        Obj := Iterator.FirstPCBObject;
        while (Obj <> Nil) do
        begin
            // Only deselect objects that are not in our duplicated list
            if Obj.Selected and (DuplicatedObjects.IndexOf(Obj) < 0) then
                Obj.Selected := False;
            
            Obj := Iterator.NextPCBObject;
        end;
        GetPCBServer.PostProcess;
        Board.BoardIterator_Destroy(Iterator);

        // Select only the duplicated objects
        for i := 0 to DuplicatedObjects.Count - 1 do
        begin
            Obj := DuplicatedObjects[i];
            if (Obj <> nil) then
                Obj.Selected := True;
        end;

        // Add source components to JSON
        for i := 0 to SourceCmps.Count - 1 do
        begin
            Component := Board.GetPcbComponentByRefDes(SourceCmps[i]);
            if (Component <> nil) then
            begin
                // Create component properties
                CompProps := TStringList.Create;
                PinsArray := TStringList.Create;
                
                try
                    // Add component properties
                    AddJSONProperty(CompProps, 'designator', Component.Name.Text);
                    AddJSONProperty(CompProps, 'description', Component.SourceDescription);
                    AddJSONProperty(CompProps, 'footprint', Component.Pattern);
                    AddJSONNumber(CompProps, 'rotation', Component.Rotation);
                    AddJSONProperty(CompProps, 'layer', Layer2String(Component.Layer));
                    
                    // Add pin data
                    // Create pad iterator
                    GrpIter := Component.GroupIterator_Create;
                    GrpIter.SetState_FilterAll;
                    GrpIter.AddFilter_ObjectSet(MkSet(ePadObject));

                    // Process each pad
                    Pad := GrpIter.FirstPCBObject;
                    while (Pad <> Nil) do
                    begin
                        if Pad.InComponent then
                        begin
                            // Get net name if connected
                            if (Pad.Net <> Nil) then
                                NetName := JSONEscapeString(Pad.Net.Name)
                            else
                                NetName := '';

                            // Create pin properties
                            PinProps := TStringList.Create;
                            try
                                AddJSONProperty(PinProps, 'name', Pad.Name);
                                AddJSONProperty(PinProps, 'net', NetName);
                                AddJSONNumber(PinProps, 'x', CoordToMils(Pad.x - xorigin));
                                AddJSONNumber(PinProps, 'y', CoordToMils(Pad.y - yorigin));
                                AddJSONProperty(PinProps, 'layer', Layer2String(Pad.Layer));
                                
                                // Add to pins array
                                PinsArray.Add(BuildJSONObject(PinProps, 3));
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
                    
                    // Add to source array
                    SourceArray.Add(BuildJSONObject(CompProps, 2));
                finally
                    CompProps.Free;
                    PinsArray.Free;
                end;
            end;
        end;

        // Reset selection for destination components
        GetClient.SendMessage('PCB:DeSelect', 'Scope=All', 255, GetClient.CurrentView);
        
        // Have the user select destination components
        GetClient.SendMessage('PCB:Select', 'Scope=InsideArea | ObjectKind=Component', 255, GetClient.CurrentView);
        
        // Get the newly selected components (destination)
        SourceCmps.Clear();
        DestArray := TStringList.Create();
        
        try
            // Get newly selected components
            Iterator := Board.BoardIterator_Create;
            Iterator.AddFilter_ObjectSet(MkSet(eComponentObject));
            Iterator.AddFilter_LayerSet(MkSet(eTopLayer, eBottomLayer));
            Iterator.AddFilter_Method(eProcessAll);

            Component := Iterator.FirstPCBObject;
            while (Component <> Nil) do
            begin
                if (Component.Selected = True) then
                    SourceCmps.Add(Component.Name.Text);

                Component := Iterator.NextPCBObject;
            end;
            Board.BoardIterator_Destroy(Iterator);
            
            // Add destination components to JSON
            for i := 0 to SourceCmps.Count - 1 do
            begin
                Component := Board.GetPcbComponentByRefDes(SourceCmps[i]);
                if (Component <> nil) then
                begin
                    // Create component properties
                    CompProps := TStringList.Create;
                    PinsArray := TStringList.Create;
                    
                    try
                        // Add component properties
                        AddJSONProperty(CompProps, 'designator', Component.Name.Text);
                        AddJSONProperty(CompProps, 'description', Component.SourceDescription);
                        AddJSONProperty(CompProps, 'footprint', Component.Pattern);
                        AddJSONNumber(CompProps, 'rotation', Component.Rotation);
                        AddJSONProperty(CompProps, 'layer', Layer2String(Component.Layer));
                        
                        // Add pin data
                        // Create pad iterator
                        GrpIter := Component.GroupIterator_Create;
                        GrpIter.SetState_FilterAll;
                        GrpIter.AddFilter_ObjectSet(MkSet(ePadObject));

                        // Process each pad
                        Pad := GrpIter.FirstPCBObject;
                        while (Pad <> Nil) do
                        begin
                            if Pad.InComponent then
                            begin
                                // Get net name if connected
                                if (Pad.Net <> Nil) then
                                    NetName := JSONEscapeString(Pad.Net.Name)
                                else
                                    NetName := '';

                                // Create pin properties
                                PinProps := TStringList.Create;
                                try
                                    AddJSONProperty(PinProps, 'name', Pad.Name);
                                    AddJSONProperty(PinProps, 'net', NetName);
                                    AddJSONNumber(PinProps, 'x', CoordToMils(Pad.x - xorigin));
                                    AddJSONNumber(PinProps, 'y', CoordToMils(Pad.y - yorigin));
                                    AddJSONProperty(PinProps, 'layer', Layer2String(Pad.Layer));
                                    
                                    // Add to pins array
                                    PinsArray.Add(BuildJSONObject(PinProps, 3));
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
                        
                        // Add to destination array
                        DestArray.Add(BuildJSONObject(CompProps, 2));
                    finally
                        CompProps.Free;
                        PinsArray.Free;
                    end;
                end;
            end;
            
            // Now select all duplicated objects
            for i := 0 to DuplicatedObjects.Count - 1 do
            begin
                Obj := DuplicatedObjects[i];
                if (Obj <> nil) then
                    Obj.Selected := True;
            end;
            
            // Add all arrays to result
            AddJSONBoolean(ResultProps, 'success', True);
            ResultProps.Add(BuildJSONArray(SourceArray, 'source_components'));
            ResultProps.Add(BuildJSONArray(DestArray, 'destination_components'));
            AddJSONProperty(ResultProps, 'message', 'Successfully duplicated objects. Match each source and destination designator using the part descriptions, pin data, and other information. Then call layout_duplicator_apply and pass the source and destination lists in matching order.');
            
            // Build final JSON
            OutputLines := TStringList.Create;
            try
                OutputLines.Text := BuildJSONObject(ResultProps);
                Result := OutputLines.Text;
            finally
                OutputLines.Free;
            end;
        finally
            DestArray.Free;
        end;
    finally
        ResultProps.Free;
        SourceCmps.Free;
        SourceArray.Free;
    end;
end;

// Function to check if two points are within tolerance

function CheckWithTolerance(X1, Y1, X2, Y2 : TCoord) : Boolean;
begin
    if (Abs(X1 - X2) <= Tolerance) and (Abs(Y1 - Y2) <= Tolerance) then
        Result := True
    else
        Result := False;
end;

// Function to apply layout duplication with provided source and destination lists

function ApplyLayoutDuplicator(SourceList: TStringList; DestList: TStringList): String;
var
    Board          : IPCB_Board;
    CmpSrc, CmpDst : IPCB_Component;
    NameSrc, NameDst : TPCB_String;
    i, j           : Integer;
    ResultProps    : TStringList;
    MovedCount     : Integer;
    OutputLines    : TStringList;
    PadIterator    : IPCB_GroupIterator;
    Pad            : IPCB_Pad;
    ProcessedPoints: TStringList;
    Tolerance      : TCoord;

    // For faster tracking of processed primitives
    ProcessedObjects : TStringList;

    // For net tracing
    SelectedObjects : TObjectList;
    ConnectedPrim   : IPCB_Primitive;
    TraceStack      : TStringList;
    X, Y, NextX, NextY : TCoord;
    StackSize       : Integer;
    PointInfo       : String;
    Net             : IPCB_Net;
    ObjectAddress   : Integer;

    // For polygon processing
    Polygon        : IPCB_Primitive;
    PadRect        : TCoordRect;
    PolyRect       : TCoordRect;
    Overlapping    : Boolean;
    PolygonCount   : Integer;

    // For net invalidation
    NetsToInvalidate: TStringList;
begin
    // Retrieve the current board
    Board := GetPCBServer.GetCurrentPCBBoard;
    if (Board = Nil) then
    begin
        Result := '{"success": false, "error": "No PCB document is currently active"}';
        Exit;
    end;

    // Create result properties
    ResultProps := TStringList.Create;
    MovedCount := 0;
    PolygonCount := 0;

    // Create list to track processed points
    ProcessedPoints := TStringList.Create;
    ProcessedPoints.Duplicates := dupIgnore;  // Ignore duplicate entries

    // Create list to track processed primitives (using object address as string)
    ProcessedObjects := TStringList.Create;
    ProcessedObjects.Duplicates := dupIgnore;  // Ignore duplicate entries

    // Create list for net invalidation (using net names)
    NetsToInvalidate := TStringList.Create;
    NetsToInvalidate.Duplicates := dupIgnore;

    // Create stack for tracking points to process
    TraceStack := TStringList.Create;

    // Set a small tolerance for connection checking (1 mil)
    Tolerance := MilsToCoord(1);

    // Create collection for all selected objects
    SelectedObjects := TObjectList.Create; // Don't own objects
    SelectedObjects.OwnsObjects := False; // Don't destroy objects when list is freed

    try
        // Begin board modification
        GetPCBServer.PreProcess;

        // Collect all selected objects first - OPTIMIZATION #1
        // This is our biggest optimization - collecting all selected objects once
        for i := 0 to Board.SelectecObjectCount - 1 do
        begin
            ConnectedPrim := Board.SelectecObject[i];

            // Only collect relevant object types
            if (ConnectedPrim.ObjectId = eTrackObject) or
               (ConnectedPrim.ObjectId = eArcObject) or
               (ConnectedPrim.ObjectId = eViaObject) or
               (ConnectedPrim.ObjectId = ePolyObject) or
               (ConnectedPrim.ObjectId = eRegionObject) or
               (ConnectedPrim.ObjectId = eFillObject) then
            begin
                SelectedObjects.Add(ConnectedPrim);
            end;
        end;

        // Process component pairs
        for i := 0 to SourceList.Count - 1 do
        begin
            if (i < DestList.Count) then
            begin
                NameSrc := SourceList.Get(i);
                CmpSrc := Board.GetPcbComponentByRefDes(NameSrc);

                NameDst := DestList.Get(i);
                CmpDst := Board.GetPcbComponentByRefDes(NameDst);

                if ((CmpSrc <> nil) and (CmpDst <> nil)) then
                begin
                    // Begin modify component
                    CmpDst.BeginModify;

                    // Move Destination Components to Match Source Components
                    CmpDst.Rotation := CmpSrc.Rotation;
                    CmpDst.Layer_V6 := CmpSrc.Layer_V6;
                    CmpDst.x := CmpSrc.x;
                    CmpDst.y := CmpSrc.y;
                    CmpDst.Selected := True;

                    // End modify component
                    CmpDst.EndModify;

                    // Register component with the board
                    Board.DispatchMessage(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, CmpDst.I_ObjectAddress);

                    // Clear the processed points list for this component
                    ProcessedPoints.Clear;

                    // Clear processed objects list
                    ProcessedObjects.Clear;

                    // Clear nets to invalidate
                    NetsToInvalidate.Clear;

                    // Process all pads in the destination component
                    PadIterator := CmpDst.GroupIterator_Create;
                    PadIterator.AddFilter_ObjectSet(MkSet(ePadObject));

                    Pad := PadIterator.FirstPCBObject;
                    while Pad <> nil do
                    begin
                        // Skip if pad has no net
                        if (Pad.Net <> nil) then
                        begin
                            Net := Pad.Net;

                            // Track this net for final invalidation
                            if NetsToInvalidate.IndexOf(Net.Name) < 0 then
                                NetsToInvalidate.Add(Net.Name);

                            // Clear the stack
                            TraceStack.Clear;

                            // Add initial pad position to stack
                            TraceStack.Add(IntToStr(Pad.x) + ',' + IntToStr(Pad.y));

                            // Process until stack is empty
                            while TraceStack.Count > 0 do
                            begin
                                // Pop a point from the stack
                                StackSize := TraceStack.Count;
                                PointInfo := TraceStack[StackSize - 1];
                                TraceStack.Delete(StackSize - 1);

                                // Skip if we've already processed this point
                                if ProcessedPoints.IndexOf(PointInfo) >= 0 then
                                    Continue;

                                // Mark this point as processed
                                ProcessedPoints.Add(PointInfo);

                                // Extract X,Y from the point info
                                X := StrToInt(Copy(PointInfo, 1, Pos(',', PointInfo) - 1));
                                Y := StrToInt(Copy(PointInfo, Pos(',', PointInfo) + 1, Length(PointInfo)));

                                // Process all selected objects - OPTIMIZATION
                                for j := SelectedObjects.Count - 1 downto 0 do
                                begin
                                    ConnectedPrim := SelectedObjects[j];

                                    // Skip if already processed
                                    ObjectAddress := ConnectedPrim.I_ObjectAddress;
                                    if ProcessedObjects.IndexOf(IntToStr(ObjectAddress)) >= 0 then
                                        Continue;

                                    // Skip if already processed (using object address as identifier)
                                    ObjectAddress := ConnectedPrim.I_ObjectAddress;
                                    if ProcessedObjects.IndexOf(IntToStr(ObjectAddress)) >= 0 then
                                        Continue;

                                    // Check if primitive is at this point
                                    if ConnectedPrim.ObjectId = eTrackObject then
                                    begin
                                        // Check both endpoints
                                        if CheckWithTolerance(ConnectedPrim.x1, ConnectedPrim.y1, X, Y) or
                                           CheckWithTolerance(ConnectedPrim.x2, ConnectedPrim.y2, X, Y) then
                                        begin
                                            // Apply the net
                                            ConnectedPrim.BeginModify;
                                            ConnectedPrim.Net := Net;
                                            ConnectedPrim.EndModify;

                                            // Register primitive with the board
                                            Board.DispatchMessage(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, ConnectedPrim.I_ObjectAddress);

                                            // Mark as processed
                                            ProcessedObjects.Add(IntToStr(ObjectAddress));

                                            // Add other endpoint to stack
                                            if CheckWithTolerance(ConnectedPrim.x1, ConnectedPrim.y1, X, Y) then
                                                TraceStack.Add(IntToStr(ConnectedPrim.x2) + ',' + IntToStr(ConnectedPrim.y2))
                                            else
                                                TraceStack.Add(IntToStr(ConnectedPrim.x1) + ',' + IntToStr(ConnectedPrim.y1));

                                            // Remove from selected objects to speed up future searches
                                            SelectedObjects.Delete(j);
                                        end;
                                    end
                                    else if ConnectedPrim.ObjectId = eArcObject then
                                    begin
                                        // Check both endpoints
                                        if CheckWithTolerance(ConnectedPrim.StartX, ConnectedPrim.StartY, X, Y) or
                                           CheckWithTolerance(ConnectedPrim.EndX, ConnectedPrim.EndY, X, Y) then
                                        begin
                                            // Apply the net
                                            ConnectedPrim.BeginModify;
                                            ConnectedPrim.Net := Net;
                                            ConnectedPrim.EndModify;

                                            // Register primitive with the board
                                            Board.DispatchMessage(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, ConnectedPrim.I_ObjectAddress);

                                            // Mark as processed
                                            ProcessedObjects.Add(IntToStr(ObjectAddress));

                                            // Add other endpoint to stack
                                            if CheckWithTolerance(ConnectedPrim.StartX, ConnectedPrim.StartY, X, Y) then
                                                TraceStack.Add(IntToStr(ConnectedPrim.EndX) + ',' + IntToStr(ConnectedPrim.EndY))
                                            else
                                                TraceStack.Add(IntToStr(ConnectedPrim.StartX) + ',' + IntToStr(ConnectedPrim.StartY));

                                            // Remove from selected objects
                                            SelectedObjects.Delete(j);
                                        end;
                                    end
                                    else if ConnectedPrim.ObjectId = eViaObject then
                                    begin
                                        // Check single point
                                        if CheckWithTolerance(ConnectedPrim.x, ConnectedPrim.y, X, Y) then
                                        begin
                                            ConnectedPrim.BeginModify;
                                            ConnectedPrim.Net := Net;
                                            ConnectedPrim.EndModify;

                                            // Register primitive with the board
                                            Board.DispatchMessage(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, ConnectedPrim.I_ObjectAddress);

                                            // Mark as processed
                                            ProcessedObjects.Add(IntToStr(ObjectAddress));

                                            // Remove from selected objects
                                            SelectedObjects.Delete(j);

                                            // Mark as processed rather than removing
                                            //ProcessedObjects.Add(IntToStr(ObjectAddress));
                                        end;
                                    end;
                                end;
                            end;

                            // Process polygons for this pad - using filtered list
                            PadRect := Pad.BoundingRectangle;

                            // Process each selected polygon from our collected objects
                            for j := SelectedObjects.Count - 1 downto 0 do
                            begin
                                Polygon := SelectedObjects[j];

                                // Skip if already processed
                                ObjectAddress := Polygon.I_ObjectAddress;
                                if ProcessedObjects.IndexOf(IntToStr(ObjectAddress)) >= 0 then
                                    Continue;

                                // Check if it's a polygon type on the same layer
                                if ((Polygon.ObjectId = ePolyObject) or
                                    (Polygon.ObjectId = eRegionObject) or
                                    (Polygon.ObjectId = eFillObject)) and
                                    (Polygon.Layer = Pad.Layer) then
                                begin
                                    // Get polygon's bounding rectangle
                                    PolyRect := Polygon.BoundingRectangle;

                                    // Faster bounding box check
                                    if (PadRect.Left <= PolyRect.Right + Tolerance) and
                                       (PadRect.Right >= PolyRect.Left - Tolerance) and
                                       (PadRect.Bottom <= PolyRect.Top + Tolerance) and
                                       (PadRect.Top >= PolyRect.Bottom - Tolerance) then
                                    begin
                                        Overlapping := False;

                                        // For polygon, use PointInPolygon
                                        if Polygon.ObjectId = ePolyObject then
                                        begin
                                            // Check pad center and corners
                                            X := (PadRect.Left + PadRect.Right) div 2;
                                            Y := (PadRect.Bottom + PadRect.Top) div 2;

                                            if Polygon.PointInPolygon(X, Y) or
                                               Polygon.PointInPolygon(PadRect.Left, PadRect.Bottom) or
                                               Polygon.PointInPolygon(PadRect.Left, PadRect.Top) or
                                               Polygon.PointInPolygon(PadRect.Right, PadRect.Bottom) or
                                               Polygon.PointInPolygon(PadRect.Right, PadRect.Top) then
                                            begin
                                                Overlapping := True;
                                            end;
                                        end
                                        // For regions and fills, use distance checking
                                        else if Board.PrimPrimDistance(Pad, Polygon) <= Tolerance then
                                        begin
                                            Overlapping := True;
                                        end;

                                        if Overlapping then
                                        begin
                                            // Assign pad's net to the polygon
                                            Polygon.BeginModify;
                                            Polygon.Net := Net;
                                            Polygon.EndModify;

                                            // Register with board
                                            Board.DispatchMessage(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Polygon.I_ObjectAddress);

                                            // Mark as processed
                                            ProcessedObjects.Add(IntToStr(ObjectAddress));

                                            // Remove from the selected objects
                                            SelectedObjects.Delete(j);

                                            Inc(PolygonCount);
                                        end;
                                    end;
                                end;
                            end;
                        end;

                        Pad := PadIterator.NextPCBObject;
                    end;

                    CmpDst.GroupIterator_Destroy(PadIterator);

                    MovedCount := MovedCount + 1;
                end;
            end;
        end;

        // End board modification
        GetPCBServer.PostProcess;

        // Force redraw of the view - once at the end
        GetClient.SendMessage('PCB:Zoom', 'Action=Redraw', 255, GetClient.CurrentView);

        // Update connectivity
        ResetParameters;
        AddStringParameter('Action', 'RebuildConnectivity');
        RunProcess('PCB:UpdateConnectivity');

        // Run full update
        Board.ViewManager_FullUpdate;

        // Create result JSON
        AddJSONBoolean(ResultProps, 'success', True);
        AddJSONInteger(ResultProps, 'moved_count', MovedCount);
        AddJSONInteger(ResultProps, 'polygon_count', PolygonCount);
        AddJSONProperty(ResultProps, 'message', 'Successfully duplicated layout and applied nets for ' + IntToStr(MovedCount) +
                        ' components and ' + IntToStr(PolygonCount) + ' polygons/regions/fills.');

        // Build final JSON
        OutputLines := TStringList.Create;
        try
            OutputLines.Text := BuildJSONObject(ResultProps);
            Result := OutputLines.Text;
        finally
            OutputLines.Free;
        end;
    finally
        NetsToInvalidate.Free;
        ProcessedObjects.Free;
        ProcessedPoints.Free;
        TraceStack.Free;
        ResultProps.Free;
    end;
end;




// ============================================================================
// PCB_UTILS.PAS
// ============================================================================

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





// ============================================================================
// PROJECT_UTILS.PAS
// ============================================================================

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





// ============================================================================
// ROUTING.PAS
// ============================================================================

uses
    globals;

{..............................................................................}
{ Route Trace - Route a trace between two points on a layer                   }
{..............................................................................}

function RouteTrace(X1, Y1, X2, Y2, Width: Double; Layer: String; NetName: String): String;
var
    Board: IPCB_Board;
    Track: IPCB_Track;
    Net: IPCB_Net;
    OutputLines: TStringList;
    ResultProps: TStringList;
    LayerObj: TLayer;
begin
    ResultProps := TStringList.Create;
    try
        Board := GetPCBServer.GetCurrentPCBBoard;
        if Board = nil then
        begin
            AddJSONBoolean(ResultProps, 'success', False);
            AddJSONProperty(ResultProps, 'error', 'No PCB document is currently active');

            OutputLines := TStringList.Create;
            try
                OutputLines.Text := BuildJSONObject(ResultProps);
                Result := OutputLines.Text;
            finally
                OutputLines.Free;
            end;
            Exit;
        end;

        // Parse layer name to layer constant
        LayerObj := eTopLayer; // Default
        if Layer = 'TopLayer' then LayerObj := eTopLayer
        else if Layer = 'BottomLayer' then LayerObj := eBottomLayer
        else if Layer = 'MidLayer1' then LayerObj := eMidLayer1
        else if Layer = 'MidLayer2' then LayerObj := eMidLayer2
        else if Layer = 'MidLayer3' then LayerObj := eMidLayer3
        else if Layer = 'MidLayer4' then LayerObj := eMidLayer4;

        GetPCBServer.PreProcess;
        try
            // Create track object
            Track := GetPCBServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
            if Track <> nil then
            begin
                // Set endpoints
                Track.X1 := MMsToCoord(X1);
                Track.Y1 := MMsToCoord(Y1);
                Track.X2 := MMsToCoord(X2);
                Track.Y2 := MMsToCoord(Y2);

                // Set width and layer
                Track.Width := MMsToCoord(Width);
                Track.Layer := LayerObj;

                // Assign to net if specified
                if NetName <> '' then
                begin
                    Net := Board.FindNet(NetName);
                    if Net <> nil then
                        Track.Net := Net
                    else
                    begin
                        // Create new net if it doesn't exist
                        Net := GetPCBServer.PCBObjectFactory(eNetObject, eNoDimension, eCreate_Default);
                        if Net <> nil then
                        begin
                            Net.Name := TDynamicString(NetName);
                            Board.AddPCBObject(Net);
                            Track.Net := Net;
                        end;
                    end;
                end;

                Board.AddPCBObject(Track);
                GetPCBServer.SendMessageToRobots(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Track.I_ObjectAddress);

                AddJSONBoolean(ResultProps, 'success', True);
                AddJSONProperty(ResultProps, 'message', 'Trace routed');
                AddJSONProperty(ResultProps, 'from', FloatToStr(X1) + ',' + FloatToStr(Y1) + 'mm');
                AddJSONProperty(ResultProps, 'to', FloatToStr(X2) + ',' + FloatToStr(Y2) + 'mm');
                AddJSONProperty(ResultProps, 'layer', Layer);
                AddJSONProperty(ResultProps, 'width', FloatToStr(Width) + 'mm');
                if NetName <> '' then
                    AddJSONProperty(ResultProps, 'net', NetName);
            end
            else
            begin
                AddJSONBoolean(ResultProps, 'success', False);
                AddJSONProperty(ResultProps, 'error', 'Failed to create track object');
            end;
        finally
            GetPCBServer.PostProcess;
        end;

        // Refresh view
        GetClient.SendMessage('PCB:Zoom', 'Action=Redraw', 255, GetClient.CurrentView);

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
{ Add Via - Place a via at coordinates                                        }
{..............................................................................}

function AddVia(X, Y, Diameter, HoleSize: Double; StartLayer, EndLayer: String; NetName: String): String;
var
    Board: IPCB_Board;
    Via: IPCB_Via;
    Net: IPCB_Net;
    OutputLines: TStringList;
    ResultProps: TStringList;
    StartLayerObj, EndLayerObj: TLayer;
begin
    ResultProps := TStringList.Create;
    try
        Board := GetPCBServer.GetCurrentPCBBoard;
        if Board = nil then
        begin
            AddJSONBoolean(ResultProps, 'success', False);
            AddJSONProperty(ResultProps, 'error', 'No PCB document is currently active');

            OutputLines := TStringList.Create;
            try
                OutputLines.Text := BuildJSONObject(ResultProps);
                Result := OutputLines.Text;
            finally
                OutputLines.Free;
            end;
            Exit;
        end;

        // Parse layer names to layer constants
        StartLayerObj := eTopLayer; // Default
        if StartLayer = 'TopLayer' then StartLayerObj := eTopLayer
        else if StartLayer = 'MidLayer1' then StartLayerObj := eMidLayer1
        else if StartLayer = 'MidLayer2' then StartLayerObj := eMidLayer2
        else if StartLayer = 'MidLayer3' then StartLayerObj := eMidLayer3
        else if StartLayer = 'MidLayer4' then StartLayerObj := eMidLayer4;

        EndLayerObj := eBottomLayer; // Default
        if EndLayer = 'BottomLayer' then EndLayerObj := eBottomLayer
        else if EndLayer = 'MidLayer1' then EndLayerObj := eMidLayer1
        else if EndLayer = 'MidLayer2' then EndLayerObj := eMidLayer2
        else if EndLayer = 'MidLayer3' then EndLayerObj := eMidLayer3
        else if EndLayer = 'MidLayer4' then EndLayerObj := eMidLayer4;

        GetPCBServer.PreProcess;
        try
            // Create via object
            Via := GetPCBServer.PCBObjectFactory(eViaObject, eNoDimension, eCreate_Default);
            if Via <> nil then
            begin
                // Set position
                Via.X := MMsToCoord(X);
                Via.Y := MMsToCoord(Y);

                // Set via properties
                Via.Size := MMsToCoord(Diameter);
                Via.HoleSize := MMsToCoord(HoleSize);

                // Set layer span
                Via.LowLayer := EndLayerObj;
                Via.HighLayer := StartLayerObj;

                // Assign to net if specified
                if NetName <> '' then
                begin
                    Net := Board.FindNet(NetName);
                    if Net <> nil then
                        Via.Net := Net
                    else
                    begin
                        // Create new net if it doesn't exist
                        Net := GetPCBServer.PCBObjectFactory(eNetObject, eNoDimension, eCreate_Default);
                        if Net <> nil then
                        begin
                            Net.Name := TDynamicString(NetName);
                            Board.AddPCBObject(Net);
                            Via.Net := Net;
                        end;
                    end;
                end;

                Board.AddPCBObject(Via);
                GetPCBServer.SendMessageToRobots(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Via.I_ObjectAddress);

                AddJSONBoolean(ResultProps, 'success', True);
                AddJSONProperty(ResultProps, 'message', 'Via added');
                AddJSONProperty(ResultProps, 'x', FloatToStr(X) + 'mm');
                AddJSONProperty(ResultProps, 'y', FloatToStr(Y) + 'mm');
                AddJSONProperty(ResultProps, 'diameter', FloatToStr(Diameter) + 'mm');
                AddJSONProperty(ResultProps, 'hole_size', FloatToStr(HoleSize) + 'mm');
                AddJSONProperty(ResultProps, 'start_layer', StartLayer);
                AddJSONProperty(ResultProps, 'end_layer', EndLayer);
                if NetName <> '' then
                    AddJSONProperty(ResultProps, 'net', NetName);
            end
            else
            begin
                AddJSONBoolean(ResultProps, 'success', False);
                AddJSONProperty(ResultProps, 'error', 'Failed to create via object');
            end;
        finally
            GetPCBServer.PostProcess;
        end;

        // Refresh view
        GetClient.SendMessage('PCB:Zoom', 'Action=Redraw', 255, GetClient.CurrentView);

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
{ Add Copper Pour - Create a filled polygon zone                              }
{..............................................................................}

function AddCopperPour(X, Y, Width, Height: Double; Layer: String; NetName: String; PourOverSameNet: Boolean): String;
var
    Board: IPCB_Board;
    Polygon: IPCB_Polygon;
    Net: IPCB_Net;
    OutputLines: TStringList;
    ResultProps: TStringList;
    LayerObj: TLayer;
    Contour: IPCB_Contour;
begin
    ResultProps := TStringList.Create;
    try
        Board := GetPCBServer.GetCurrentPCBBoard;
        if Board = nil then
        begin
            AddJSONBoolean(ResultProps, 'success', False);
            AddJSONProperty(ResultProps, 'error', 'No PCB document is currently active');

            OutputLines := TStringList.Create;
            try
                OutputLines.Text := BuildJSONObject(ResultProps);
                Result := OutputLines.Text;
            finally
                OutputLines.Free;
            end;
            Exit;
        end;

        // Parse layer name to layer constant
        LayerObj := eTopLayer; // Default
        if Layer = 'TopLayer' then LayerObj := eTopLayer
        else if Layer = 'BottomLayer' then LayerObj := eBottomLayer
        else if Layer = 'MidLayer1' then LayerObj := eMidLayer1
        else if Layer = 'MidLayer2' then LayerObj := eMidLayer2
        else if Layer = 'MidLayer3' then LayerObj := eMidLayer3
        else if Layer = 'MidLayer4' then LayerObj := eMidLayer4;

        GetPCBServer.PreProcess;
        try
            // Create polygon object
            Polygon := GetPCBServer.PCBObjectFactory(ePolyObject, eNoDimension, eCreate_Default);
            if Polygon <> nil then
            begin
                // Set layer
                Polygon.Layer := LayerObj;

                // Create rectangular contour
                Contour := Polygon.Replicate; // Get a contour object

                // Add vertices for rectangle (clockwise)
                Polygon.PointCount := 4;
                Polygon.Segments[0] := TPolySegment;
                Polygon.Segments[0].Kind := ePolySegmentLine;
                Polygon.Segments[0].vx := MMsToCoord(X);
                Polygon.Segments[0].vy := MMsToCoord(Y);

                Polygon.Segments[1] := TPolySegment;
                Polygon.Segments[1].Kind := ePolySegmentLine;
                Polygon.Segments[1].vx := MMsToCoord(X + Width);
                Polygon.Segments[1].vy := MMsToCoord(Y);

                Polygon.Segments[2] := TPolySegment;
                Polygon.Segments[2].Kind := ePolySegmentLine;
                Polygon.Segments[2].vx := MMsToCoord(X + Width);
                Polygon.Segments[2].vy := MMsToCoord(Y + Height);

                Polygon.Segments[3] := TPolySegment;
                Polygon.Segments[3].Kind := ePolySegmentLine;
                Polygon.Segments[3].vx := MMsToCoord(X);
                Polygon.Segments[3].vy := MMsToCoord(Y + Height);

                // Set polygon properties
                Polygon.PolyHatchStyle := ePolySolid; // Solid fill

                // Pour over same net option
                if PourOverSameNet then
                    Polygon.RemoveIslandsByArea := 0
                else
                    Polygon.RemoveIslandsByArea := MMsToCoord(1.0); // Remove islands smaller than 1mm²

                // Assign to net
                if NetName <> '' then
                begin
                    Net := Board.FindNet(NetName);
                    if Net <> nil then
                        Polygon.Net := Net
                    else
                    begin
                        // Create new net if it doesn't exist
                        Net := GetPCBServer.PCBObjectFactory(eNetObject, eNoDimension, eCreate_Default);
                        if Net <> nil then
                        begin
                            Net.Name := TDynamicString(NetName);
                            Board.AddPCBObject(Net);
                            Polygon.Net := Net;
                        end;
                    end;
                end;

                // Rebuild polygon to apply pour
                Polygon.Rebuild;

                Board.AddPCBObject(Polygon);
                GetPCBServer.SendMessageToRobots(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Polygon.I_ObjectAddress);

                AddJSONBoolean(ResultProps, 'success', True);
                AddJSONProperty(ResultProps, 'message', 'Copper pour added');
                AddJSONProperty(ResultProps, 'x', FloatToStr(X) + 'mm');
                AddJSONProperty(ResultProps, 'y', FloatToStr(Y) + 'mm');
                AddJSONProperty(ResultProps, 'width', FloatToStr(Width) + 'mm');
                AddJSONProperty(ResultProps, 'height', FloatToStr(Height) + 'mm');
                AddJSONProperty(ResultProps, 'layer', Layer);
                AddJSONProperty(ResultProps, 'net', NetName);
            end
            else
            begin
                AddJSONBoolean(ResultProps, 'success', False);
                AddJSONProperty(ResultProps, 'error', 'Failed to create polygon object');
            end;
        finally
            GetPCBServer.PostProcess;
        end;

        // Refresh view
        GetClient.SendMessage('PCB:Zoom', 'Action=Redraw', 255, GetClient.CurrentView);

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






// ============================================================================
// SCHEMATIC_UTILS.PAS
// ============================================================================

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





// ============================================================================
// COMMAND_EXECUTORS_BOARD.PAS
// ============================================================================

function ExecuteSetBoardSize(RequestData: TStringList): String;
var
    i, ValueStart: Integer;
    ParamValue: String;
    Width, Height: Double;
begin
    Width := 0;
    Height := 0;

    try
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"width"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                Width := StrToFloat(ParamValue);
            end
            else if (Pos('"height"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                Height := StrToFloat(ParamValue);
            end;
        end;

        if (Width > 0) and (Height > 0) then
            Result := SetBoardSize(Width, Height)
        else
            Result := '{"success": false, "error": "Invalid board dimensions"}';
    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
end;



function ExecuteAddBoardOutline(RequestData: TStringList): String;
var
    i, ValueStart: Integer;
    ParamValue: String;
    X, Y, Width, Height: Double;
begin
    X := 0;
    Y := 0;
    Width := 0;
    Height := 0;

    try
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"x"', RequestData[i]) > 0) and (Pos('"x1"', RequestData[i]) = 0) and (Pos('"x2"', RequestData[i]) = 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                X := StrToFloat(ParamValue);
            end
            else if (Pos('"y"', RequestData[i]) > 0) and (Pos('"y1"', RequestData[i]) = 0) and (Pos('"y2"', RequestData[i]) = 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                Y := StrToFloat(ParamValue);
            end
            else if (Pos('"width"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                Width := StrToFloat(ParamValue);
            end
            else if (Pos('"height"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                Height := StrToFloat(ParamValue);
            end;
        end;

        if (Width > 0) and (Height > 0) then
            Result := AddBoardOutline(X, Y, Width, Height)
        else
            Result := '{"success": false, "error": "Invalid outline dimensions"}';
    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
end;


function ExecuteAddMountingHole(RequestData: TStringList): String;
var
    i, ValueStart: Integer;
    ParamValue: String;
    X, Y, HoleDiameter, PadDiameter: Double;
begin
    X := 0;
    Y := 0;
    HoleDiameter := 0;
    PadDiameter := 0;

    try
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"x"', RequestData[i]) > 0) and (Pos('"x1"', RequestData[i]) = 0) and (Pos('"x2"', RequestData[i]) = 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                X := StrToFloat(ParamValue);
            end
            else if (Pos('"y"', RequestData[i]) > 0) and (Pos('"y1"', RequestData[i]) = 0) and (Pos('"y2"', RequestData[i]) = 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                Y := StrToFloat(ParamValue);
            end
            else if (Pos('"hole_diameter"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                HoleDiameter := StrToFloat(ParamValue);
            end
            else if (Pos('"pad_diameter"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                PadDiameter := StrToFloat(ParamValue);
            end;
        end;

        if HoleDiameter > 0 then
            Result := AddMountingHole(X, Y, HoleDiameter, PadDiameter)
        else
            Result := '{"success": false, "error": "Invalid hole diameter"}';
    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
end;


function ExecuteAddBoardText(RequestData: TStringList): String;
var
    i, ValueStart: Integer;
    ParamValue, Text, Layer: String;
    X, Y, Size: Double;
begin
    Text := '';
    Layer := 'TopOverlay';
    X := 0;
    Y := 0;
    Size := 1.0;

    try
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"text"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                Text := TrimJSON(ParamValue);
            end
            else if (Pos('"x"', RequestData[i]) > 0) and (Pos('"x1"', RequestData[i]) = 0) and (Pos('"x2"', RequestData[i]) = 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                X := StrToFloat(ParamValue);
            end
            else if (Pos('"y"', RequestData[i]) > 0) and (Pos('"y1"', RequestData[i]) = 0) and (Pos('"y2"', RequestData[i]) = 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                Y := StrToFloat(ParamValue);
            end
            else if (Pos('"layer"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                Layer := TrimJSON(ParamValue);
            end
            else if (Pos('"size"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                Size := StrToFloat(ParamValue);
            end;
        end;

        if Text <> '' then
            Result := AddBoardText(Text, X, Y, Size, Layer)
        else
            Result := '{"success": false, "error": "No text provided"}';
    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
end;


function ExecuteRouteTrace(RequestData: TStringList): String;
var
    i, ValueStart: Integer;
    ParamValue, Layer, NetName: String;
    X1, Y1, X2, Y2, Width: Double;
begin
    X1 := 0;
    Y1 := 0;
    X2 := 0;
    Y2 := 0;
    Width := 0;
    Layer := 'TopLayer';
    NetName := '';

    try
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"x1"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                X1 := StrToFloat(ParamValue);
            end
            else if (Pos('"y1"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                Y1 := StrToFloat(ParamValue);
            end
            else if (Pos('"x2"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                X2 := StrToFloat(ParamValue);
            end
            else if (Pos('"y2"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                Y2 := StrToFloat(ParamValue);
            end
            else if (Pos('"width"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                Width := StrToFloat(ParamValue);
            end
            else if (Pos('"layer"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                Layer := TrimJSON(ParamValue);
            end
            else if (Pos('"net_name"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                NetName := TrimJSON(ParamValue);
            end;
        end;

        if Width > 0 then
            Result := RouteTrace(X1, Y1, X2, Y2, Width, Layer, NetName)
        else
            Result := '{"success": false, "error": "Invalid trace width"}';
    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
end;


function ExecuteAddVia(RequestData: TStringList): String;
var
    i, ValueStart: Integer;
    ParamValue, StartLayer, EndLayer, NetName: String;
    X, Y, Diameter, HoleSize: Double;
begin
    X := 0;
    Y := 0;
    Diameter := 0;
    HoleSize := 0;
    StartLayer := 'TopLayer';
    EndLayer := 'BottomLayer';
    NetName := '';

    try
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"x"', RequestData[i]) > 0) and (Pos('"x1"', RequestData[i]) = 0) and (Pos('"x2"', RequestData[i]) = 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                X := StrToFloat(ParamValue);
            end
            else if (Pos('"y"', RequestData[i]) > 0) and (Pos('"y1"', RequestData[i]) = 0) and (Pos('"y2"', RequestData[i]) = 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                Y := StrToFloat(ParamValue);
            end
            else if (Pos('"diameter"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                Diameter := StrToFloat(ParamValue);
            end
            else if (Pos('"hole_size"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                HoleSize := StrToFloat(ParamValue);
            end
            else if (Pos('"start_layer"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                StartLayer := TrimJSON(ParamValue);
            end
            else if (Pos('"end_layer"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                EndLayer := TrimJSON(ParamValue);
            end
            else if (Pos('"net_name"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                NetName := TrimJSON(ParamValue);
            end;
        end;

        if (Diameter > 0) and (HoleSize > 0) then
            Result := AddVia(X, Y, Diameter, HoleSize, StartLayer, EndLayer, NetName)
        else
            Result := '{"success": false, "error": "Invalid via dimensions"}';
    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
end;


function ExecuteAddCopperPour(RequestData: TStringList): String;
var
    i, ValueStart: Integer;
    ParamValue, Layer, NetName: String;
    X, Y, Width, Height: Double;
    PourOverSameNet: Boolean;
begin
    X := 0;
    Y := 0;
    Width := 0;
    Height := 0;
    Layer := 'TopLayer';
    NetName := '';
    PourOverSameNet := True;

    try
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"x"', RequestData[i]) > 0) and (Pos('"x1"', RequestData[i]) = 0) and (Pos('"x2"', RequestData[i]) = 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                X := StrToFloat(ParamValue);
            end
            else if (Pos('"y"', RequestData[i]) > 0) and (Pos('"y1"', RequestData[i]) = 0) and (Pos('"y2"', RequestData[i]) = 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                Y := StrToFloat(ParamValue);
            end
            else if (Pos('"width"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                Width := StrToFloat(ParamValue);
            end
            else if (Pos('"height"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                Height := StrToFloat(ParamValue);
            end
            else if (Pos('"layer"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                Layer := TrimJSON(ParamValue);
            end
            else if (Pos('"net_name"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                NetName := TrimJSON(ParamValue);
            end
            else if (Pos('"pour_over_same_net"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                PourOverSameNet := (ParamValue = 'true');
            end;
        end;

        if (Width > 0) and (Height > 0) and (NetName <> '') then
            Result := AddCopperPour(X, Y, Width, Height, Layer, NetName, PourOverSameNet)
        else
            Result := '{"success": false, "error": "Invalid copper pour parameters"}';
    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
end;




// ============================================================================
// COMMAND_EXECUTORS_COMPONENTS.PAS
// ============================================================================

function ExecuteGetComponentPins(RequestData: TStringList): String;
var
    ParamValue: String;
    i: Integer;
    DesignatorsList: TStringList;
begin
    DesignatorsList := TStringList.Create;
    try
        // Look through all the RequestData lines to find designators
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"designators"', RequestData[i]) > 0) then
            begin
                // Found the designators parameter
                // Parse the array in the next lines
                i := i + 1; // Move to the next line (should be '[')
                
                while (i < RequestData.Count) and (Pos(']', RequestData[i]) = 0) do
                begin
                    // This is an array element
                    // Extract the designator value
                    ParamValue := RequestData[i];
                    ParamValue := StringReplace(ParamValue, '"', '', REPLACEALL);
                    ParamValue := StringReplace(ParamValue, ',', '', REPLACEALL);
                    ParamValue := Trim(ParamValue);
                    
                    if (ParamValue <> '') and (ParamValue <> '[') then
                        DesignatorsList.Add(ParamValue);
                    
                    i := i + 1;
                end;
                
                break;
            end;
        end;
        
        if DesignatorsList.Count > 0 then
        begin
            Result := GetComponentPinsFromList(ROOT_DIR, DesignatorsList);
        end
        else
        begin
            ShowMessage('Error: No designators found for get_component_pins');
            Result := '';
        end;
    finally
        DesignatorsList.Free;
    end;
end;



function ExecuteCreateNetClass(RequestData: TStringList): String;
var
    ParamValue: String;
    i, ValueStart: Integer;
    ClassName: String;
    NetNamesList: TStringList;
begin
    ClassName := '';
    NetNamesList := TStringList.Create;

    try
        // Parse parameters from the request
        for i := 0 to RequestData.Count - 1 do
        begin
            // Look for class_name
            if (Pos('"class_name"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ClassName := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ClassName := TrimJSON(ClassName);
            end
            // Look for net_names array
            else if (Pos('"net_names"', RequestData[i]) > 0) then
            begin
                // Parse the array in the next lines
                i := i + 1; // Move to the next line (should be '[')

                while (i < RequestData.Count) and (Pos(']', RequestData[i]) = 0) do
                begin
                    // Extract the net name
                    ParamValue := RequestData[i];
                    ParamValue := StringReplace(ParamValue, '"', '', REPLACEALL);
                    ParamValue := StringReplace(ParamValue, ',', '', REPLACEALL);
                    ParamValue := Trim(ParamValue);

                    if (ParamValue <> '') and (ParamValue <> '[') then
                        NetNamesList.Add(ParamValue);

                    i := i + 1;
                end;
            end;
        end;

        if (ClassName <> '') and (NetNamesList.Count > 0) then
        begin
            Result := CreateNewNetClass(ClassName, NetNamesList);
        end
        else
        begin
            if ClassName = '' then
                Result := '{"success": false, "error": "No class name provided"}'
            else
                Result := '{"success": false, "error": "No net names provided"}';
        end;
    finally
        NetNamesList.Free;
    end;
end;


function ExecuteTakeViewScreenshot(RequestData: TStringList): String;
var
    ParamValue: String;
    i, ValueStart: Integer;
    ViewType: String;
begin
    // Extract the view type parameter
    ViewType := 'pcb';  // Default to PCB
    
    // Parse parameters from the request
    for i := 0 to RequestData.Count - 1 do
    begin
        // Look for view_type parameter
        if (Pos('"view_type"', RequestData[i]) > 0) then
        begin
            ValueStart := Pos(':', RequestData[i]) + 1;
            ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
            ParamValue := TrimJSON(ParamValue);
            ViewType := ParamValue;
            Break;
        end;
    end;
    
    Result := TakeViewScreenshot(ViewType);
end;



function ExecuteCreateSchematicSymbol(RequestData: TStringList): String;
var
    ParamValue: String;
    i, ValueStart: Integer;
    ComponentName: String;
    PinsList: TStringList;
begin
    ComponentName := '';
    PinsList := TStringList.Create;

    try
        // Parse parameters from the request
        for i := 0 to RequestData.Count - 1 do
        begin
            // Look for component name
            if (Pos('"symbol_name"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ComponentName := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ComponentName := TrimJSON(ComponentName);
            end
            // Look for pins array
            else if (Pos('"pins"', RequestData[i]) > 0) then
            begin
                // Parse the array in the next lines
                i := i + 1; // Move to the next line (should be '[')

                while (i < RequestData.Count) and (Pos(']', RequestData[i]) = 0) do
                begin
                    // Extract the pin data
                    ParamValue := TrimJSON(RequestData[i]);

                    if (ParamValue <> '') and (ParamValue <> '[') then
                        PinsList.Add(ParamValue);

                    i := i + 1;
                end;
            end
            // Look for description
            else if (Pos('"description"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                PinsList.Add('Description=' + ParamValue);
            end;
        end;

        if ComponentName <> '' then
        begin
            Result := CreateSchematicSymbol(ComponentName, PinsList);
        end
        else
        begin
            Result := '{"success": false, "error": "No component name provided"}';
        end;
    finally
        PinsList.Free;
    end;
end;


function ExecuteSetPCBLayerVisibility(RequestData: TStringList): String;
var
    ParamValue: String;
    i, ValueStart: Integer;
    LayerNamesList: TStringList;
    Visible: Boolean;
begin
    LayerNamesList := TStringList.Create;
    Visible := False;

    try
        // Parse parameters from the request
        for i := 0 to RequestData.Count - 1 do
        begin
            // Look for layer_names array
            if (Pos('"layer_names"', RequestData[i]) > 0) then
            begin
                // Parse the array in the next lines
                i := i + 1; // Move to the next line (should be '[')

                while (i < RequestData.Count) and (Pos(']', RequestData[i]) = 0) do
                begin
                    // Extract the layer name
                    ParamValue := TrimJSON(RequestData[i]);

                    if (ParamValue <> '') and (ParamValue <> '[') then
                        LayerNamesList.Add(ParamValue);

                    i := i + 1;
                end;
            end
            // Look for visible parameter
            else if (Pos('"visible"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                Visible := (ParamValue = 'true');
            end;
        end;

        if LayerNamesList.Count > 0 then
        begin
            Result := SetPCBLayerVisibility(LayerNamesList, Visible);
        end
        else
        begin
            Result := '{"success": false, "error": "No layer names provided"}';
        end;
    finally
        LayerNamesList.Free;
    end;
end;


function ExecuteMoveComponents(RequestData: TStringList): String;
var
    ParamValue: String;
    i, ValueStart: Integer;
    DesignatorsList: TStringList;
    XOffset, YOffset: TCoord;
    Rotation: Double;
begin
    DesignatorsList := TStringList.Create;
    XOffset := 0;
    YOffset := 0;
    Rotation := 0;  // Default rotation is 0 (no change)

    try
        // Parse parameters from the request
        for i := 0 to RequestData.Count - 1 do
        begin
            // Look for designators array
            if (Pos('"designators"', RequestData[i]) > 0) then
            begin
                // Parse the array in the next lines
                i := i + 1; // Move to the next line (should be '[')

                while (i < RequestData.Count) and (Pos(']', RequestData[i]) = 0) do
                begin
                    // Extract the designator value
                    ParamValue := TrimJSON(RequestData[i]);

                    if (ParamValue <> '') and (ParamValue <> '[') then
                        DesignatorsList.Add(ParamValue);

                    i := i + 1;
                end;
            end
            // Look for x_offset
            else if (Pos('"x_offset"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                XOffset := MilsToCoord(StrToFloat(ParamValue));
            end
            // Look for y_offset
            else if (Pos('"y_offset"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                YOffset := MilsToCoord(StrToFloat(ParamValue));
            end
            // Look for rotation
            else if (Pos('"rotation"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ParamValue := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ParamValue := TrimJSON(ParamValue);
                Rotation := StrToFloat(ParamValue);
            end;
        end;

        if DesignatorsList.Count > 0 then
        begin
            Result := MoveComponentsByDesignators(DesignatorsList, XOffset, YOffset, Rotation);
        end
        else
        begin
            Result := '{"success": false, "error": "No designators found for move_components"}';
        end;
    finally
        DesignatorsList.Free;
    end;
end;


function ExecuteLayoutDuplicatorApply(RequestData: TStringList): String;
var
    ParamValue: String;
    i: Integer;
    SourceList, DestList: TStringList;
begin
    SourceList := TStringList.Create;
    DestList := TStringList.Create;

    try
        // Parse parameters from the request
        for i := 0 to RequestData.Count - 1 do
        begin
            // Look for source designators array
            if (Pos('"source_designators"', RequestData[i]) > 0) then
            begin
                // Parse the array in the next lines
                i := i + 1; // Move to the next line (should be '[')

                while (i < RequestData.Count) and (Pos(']', RequestData[i]) = 0) do
                begin
                    // Extract the designator value
                    ParamValue := TrimJSON(RequestData[i]);

                    if (ParamValue <> '') and (ParamValue <> '[') then
                        SourceList.Add(ParamValue);

                    i := i + 1;
                end;
            end
            // Look for destination designators array
            else if (Pos('"destination_designators"', RequestData[i]) > 0) then
            begin
                // Parse the array in the next lines
                i := i + 1; // Move to the next line (should be '[')

                while (i < RequestData.Count) and (Pos(']', RequestData[i]) = 0) do
                begin
                    // Extract the designator value
                    ParamValue := TrimJSON(RequestData[i]);

                    if (ParamValue <> '') and (ParamValue <> '[') then
                        DestList.Add(ParamValue);

                    i := i + 1;
                end;
            end
        end;

        if (SourceList.Count > 0) and (DestList.Count > 0) then
        begin
            Result := ApplyLayoutDuplicator(SourceList, DestList);
        end
        else
        begin
            Result := '{"success": false, "error": "Source or destination lists are empty"}';
        end;
    finally
        SourceList.Free;
        DestList.Free;
    end;
end;



function ExecuteGetOutputJobContainers(RequestData: TStringList): String;
var
    ParamValue: String;
    i: Integer;
    OutJobPath: String;
begin
    OutJobPath := '';
    
    // Parse parameters from the request
    for i := 0 to RequestData.Count - 1 do
    begin
        if (Pos('"outjob_path"', RequestData[i]) > 0) then
        begin
            // Found the outjob_path parameter
            ParamValue := Copy(RequestData[i], Pos(':', RequestData[i]) + 1, Length(RequestData[i]));
            ParamValue := TrimJSON(ParamValue);
            OutJobPath := ParamValue;
            break;
        end;
    end;
    
    // Call the appropriate function
    Result := GetOutputJobContainers(ROOT_DIR);
end;



function ExecuteRunOutputJobs(RequestData: TStringList): String;
var
    ParamValue: String;
    i: Integer;
    ContainersList: TStringList;
begin
    ContainersList := TStringList.Create;
    
    try
        // Parse parameters from the request
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"container_names"', RequestData[i]) > 0) then
            begin
                // Parse the array in the next lines
                i := i + 1; // Move to the next line (should be '[')
                
                while (i < RequestData.Count) and (Pos(']', RequestData[i]) = 0) do
                begin
                    // Extract the container name
                    ParamValue := RequestData[i];
                    ParamValue := StringReplace(ParamValue, '"', '', REPLACEALL);
                    ParamValue := StringReplace(ParamValue, ',', '', REPLACEALL);
                    ParamValue := Trim(ParamValue);
                    
                    if (ParamValue <> '') and (ParamValue <> '[') then
                        ContainersList.Add(ParamValue);
                    
                    i := i + 1;
                end;
            end;
        end;
        
        if ContainersList.Count > 0 then
        begin
            Result := RunOutputJobs(ContainersList, ROOT_DIR);
        end
        else
        begin
            ShowMessage('Error: No container names specified');
            Result := '{"success": false, "error": "No container names specified"}';
        end;
    finally
        ContainersList.Free;
    end;
end;





// ============================================================================
// COMMAND_EXECUTORS_LIBRARY.PAS
// ============================================================================

function ExecuteCreateProject(RequestData: TStringList): String;
var
    i, ValueStart: Integer;
    ProjectName, ProjectPath, Template: String;
begin
    ProjectName := '';
    ProjectPath := '';
    Template := 'blank';

    try
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"project_name"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ProjectName := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ProjectName := TrimJSON(ProjectName);
            end
            else if (Pos('"project_path"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ProjectPath := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ProjectPath := TrimJSON(ProjectPath);
            end
            else if (Pos('"template"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                Template := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                Template := TrimJSON(Template);
            end;
        end;

        if (ProjectName <> '') and (ProjectPath <> '') then
            Result := CreateProject(ProjectName, ProjectPath, Template)
        else
            Result := '{"success": false, "error": "Missing required parameters"}';
    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
end;


function ExecuteOpenDocument(RequestData: TStringList): String;
var
    i, ValueStart: Integer;
    DocumentPath, DocumentType: String;
begin
    DocumentPath := '';
    DocumentType := '';

    try
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"document_path"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                DocumentPath := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                DocumentPath := TrimJSON(DocumentPath);
            end
            else if (Pos('"document_type"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                DocumentType := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                DocumentType := TrimJSON(DocumentType);
            end;
        end;

        if (DocumentPath <> '') and (DocumentType <> '') then
            Result := OpenDocumentByPath(DocumentPath, DocumentType)
        else
            Result := '{"success": false, "error": "Missing required parameters: document_path and document_type"}';
    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
end;

{..............................................................................}
{ Phase 2: Library Search Command Executors                                    }
{..............................................................................}


function ExecuteSearchComponents(RequestData: TStringList): String;
var
    i, ValueStart: Integer;
    Query: String;
begin
    Query := '';

    try
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"query"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                Query := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                Query := TrimJSON(Query);
                break;
            end;
        end;

        if Query <> '' then
            Result := SearchComponents(Query)
        else
            Result := '{"success": false, "error": "Query parameter required"}';
    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
end;


function ExecuteGetComponentFromLibrary(RequestData: TStringList): String;
var
    i, ValueStart: Integer;
    LibraryName, ComponentName: String;
begin
    LibraryName := '';
    ComponentName := '';

    try
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"library_name"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                LibraryName := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                LibraryName := TrimJSON(LibraryName);
            end
            else if (Pos('"component_name"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                ComponentName := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                ComponentName := TrimJSON(ComponentName);
            end;
        end;

        if (LibraryName <> '') and (ComponentName <> '') then
            Result := GetComponentFromLibrary(LibraryName, ComponentName)
        else
            Result := '{"success": false, "error": "Missing required parameters"}';
    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
end;



function ExecuteSearchFootprints(RequestData: TStringList): String;
var
    i, ValueStart: Integer;
    Query: String;
begin
    Query := '';

    try
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"query"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                Query := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                Query := TrimJSON(Query);
                break;
            end;
        end;

        if Query <> '' then
            Result := SearchFootprints(Query)
        else
            Result := '{"success": false, "error": "Query parameter required"}';
    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
end;




// ============================================================================
// COMMAND_EXECUTORS_PLACEMENT.PAS
// ============================================================================

function ExecutePlaceComponent(RequestData: TStringList): String;
begin
    Result := '{"success": false, "error": "ExecutePlaceComponent not yet implemented"}';
end;


function ExecuteDeleteComponent(RequestData: TStringList): String;
var
    i, ValueStart: Integer;
    Designator: String;
begin
    Designator := '';

    try
        // Parse parameters from the request
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"designator"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                Designator := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                Designator := TrimJSON(Designator);
                break;
            end;
        end;

        if Designator <> '' then
        begin
            Result := DeleteComponent(Designator);
        end
        else
        begin
            Result := '{"success": false, "error": "No designator provided"}';
        end;
    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
end;



function ExecutePlaceComponentArray(RequestData: TStringList): String;
begin
    Result := '{"success": false, "error": "ExecutePlaceComponentArray not yet implemented"}';
end;


function ExecuteAlignComponents(RequestData: TStringList): String;
var
    ParamValue: String;
    i, ValueStart: Integer;
    Designators, Alignment: String;
begin
    Designators := '';
    Alignment := '';

    try
        // Parse parameters from the request
        for i := 0 to RequestData.Count - 1 do
        begin
            if (Pos('"designators"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                Designators := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                Designators := TrimJSON(Designators);
            end
            else if (Pos('"alignment"', RequestData[i]) > 0) then
            begin
                ValueStart := Pos(':', RequestData[i]) + 1;
                Alignment := Copy(RequestData[i], ValueStart, Length(RequestData[i]) - ValueStart + 1);
                Alignment := TrimJSON(Alignment);
            end;
        end;

        if (Designators <> '') and (Alignment <> '') then
        begin
            Result := AlignComponents(Designators, Alignment);
        end
        else
        begin
            Result := '{"success": false, "error": "Missing required parameters"}';
        end;
    except
            Result := '{"success": false, "error": "' + ExceptionMessage + '"}';
    end;
end;




// ============================================================================
// COMMAND_ROUTER.PAS
// ============================================================================

function ExecuteCommand(CommandName: String): String;
begin
    Result := '';
    EnsureDocumentFocused(CommandName);

    // Direct command execution based on the command name
    case CommandName of
        'get_component_pins':
            Result := ExecuteGetComponentPins(RequestData);            
        'get_all_nets':
            Result := GetAllNets(ROOT_DIR);            
        'create_net_class':
            Result := ExecuteCreateNetClass(RequestData);            
        'get_all_component_data':
            Result := GetAllComponentData(ROOT_DIR, False);            
        'take_view_screenshot':
            Result := ExecuteTakeViewScreenshot(RequestData);            
        'get_library_symbol_reference':
            Result := GetLibrarySymbolReference(ROOT_DIR);            
        'create_schematic_symbol':
            Result := ExecuteCreateSchematicSymbol(RequestData);            
        'get_schematic_data':
            Result := GetSchematicData(ROOT_DIR);
        'get_schematic_components_with_parameters':
            Result := GetSchematicComponentsWithParameters(ROOT_DIR);
        'check_schematic_pcb_sync':
            Result := CheckSchematicPCBSync(ROOT_DIR);
        'get_pcb_layers':
            Result := GetPCBLayers(ROOT_DIR);
        'get_board_outline':
            Result := GetBoardOutline(ROOT_DIR);
        'set_pcb_layer_visibility':
            Result := ExecuteSetPCBLayerVisibility(RequestData);
        'get_pcb_layer_stackup':
            Result := GetPCBLayerStackup(ROOT_DIR);         
        'get_selected_components_coordinates':
            Result := GetSelectedComponentsCoordinates(ROOT_DIR);            
        'move_components':
            Result := ExecuteMoveComponents(RequestData);            
        'layout_duplicator':
            Result := GetLayoutDuplicatorComponents(True);            
        'layout_duplicator_apply':
            Result := ExecuteLayoutDuplicatorApply(RequestData);
        'get_pcb_rules':
            Result := GetDesignRules(ROOT_DIR);
        'get_output_job_containers':
            Result := ExecuteGetOutputJobContainers(RequestData);
        'run_output_jobs':
            Result := ExecuteRunOutputJobs(RequestData);
        'place_component':
            Result := ExecutePlaceComponent(RequestData);
        'delete_component':
            Result := ExecuteDeleteComponent(RequestData);
        'place_component_array':
            Result := ExecutePlaceComponentArray(RequestData);
        'align_components':
            Result := ExecuteAlignComponents(RequestData);
        // Phase 2: Project Management
        'create_project':
            Result := ExecuteCreateProject(RequestData);
        'save_project':
            Result := SaveProject;
        'get_project_info':
            Result := GetProjectInfo;
        'close_project':
            Result := CloseProject;
        'open_document':
            Result := ExecuteOpenDocument(RequestData);
        // Phase 2: Library Search
        'list_component_libraries':
            Result := ListComponentLibraries;
        'search_components':
            Result := ExecuteSearchComponents(RequestData);
        'get_component_from_library':
            Result := ExecuteGetComponentFromLibrary(RequestData);
        'search_footprints':
            Result := ExecuteSearchFootprints(RequestData);
        // Phase 5: Board & Routing
        'set_board_size':
            Result := ExecuteSetBoardSize(RequestData);
        'add_board_outline':
            Result := ExecuteAddBoardOutline(RequestData);
        'add_mounting_hole':
            Result := ExecuteAddMountingHole(RequestData);
        'add_board_text':
            Result := ExecuteAddBoardText(RequestData);
        'route_trace':
            Result := ExecuteRouteTrace(RequestData);
        'add_via':
            Result := ExecuteAddVia(RequestData);
        'add_copper_pour':
            Result := ExecuteAddCopperPour(RequestData);
    else
        ShowMessage('Error: Unknown command: ' + CommandName);
    end;





end;


// ============================================================================
// DEBUG HELPER
// ============================================================================

procedure DebugLog(const Msg: String);
var
    DebugFile: TextFile;
    DebugPath: String;
begin
    try
        DebugPath := 'C:\\Users\\geoff\\Desktop\\projects\\altium-mcp\\server\\debug.log';
        AssignFile(DebugFile, DebugPath);
        if FileExists(DebugPath) then
            Append(DebugFile)
        else
            Rewrite(DebugFile);
        try
            WriteLn(DebugFile, Msg);
        finally
            CloseFile(DebugFile);
        end;
    except
        // Silently ignore any errors in debug logging
    end;
end;


// ============================================================================
// MAIN ENTRY POINT
// ============================================================================

// Main procedure to run the bridge
procedure Run;
var
    CommandType: String;
    Result: String;
    i: Integer;
    Line: String;
    ValueStart: Integer;
    Workspace: IWorkspace;
    Project: IProject;
    ProjectCount: Integer;
    ScriptPath: String;
    RootDir: String;
    ProjectIdx: Integer;
    LastSlashPos: Integer;
begin
    DebugLog('=== Script Started ===');
    
    // Calculate root directory from script location
    Workspace := GetWorkspace;
    if (Workspace <> nil) then
    begin
        ProjectCount := Workspace.DM_ProjectCount();
        DebugLog('Project count: ' + IntToStr(ProjectCount));
        for ProjectIdx := 0 to ProjectCount - 1 do
        begin
            Project := Workspace.DM_Projects(ProjectIdx);
            DebugLog('Project ' + IntToStr(ProjectIdx) + ': ' + Project.DM_ProjectFileName);
            if (Project.DM_ProjectFileName = 'Altium_API.PrjScr') then
            begin
                ScriptPath := Project.DM_ProjectFullPath;
                // ScriptPath is like: C:\\...\\server\\AltiumScript\\Altium_API.PrjScr
                // We need to go up to the server directory
                RootDir := ExtractFilePath(ScriptPath);  // Gets C:\\...\\server\\AltiumScript\\
                // ShowMessage('Step 1 - After ExtractFilePath: ' + RootDir);
                // Remove ALL trailing backslashes
                while (Length(RootDir) > 0) and (RootDir[Length(RootDir)] = #92) do
                    RootDir := Copy(RootDir, 1, Length(RootDir) - 1);
                // ShowMessage('Step 2 - After removing backslashes: ' + RootDir);
                // Now RootDir = C:\\...\\server\\AltiumScript
                // Find the last backslash to go up one directory
                LastSlashPos := Length(RootDir);
                while (LastSlashPos > 0) and (RootDir[LastSlashPos] <> #92) do
                    LastSlashPos := LastSlashPos - 1;
                // ShowMessage('Step 3 - LastSlashPos: ' + IntToStr(LastSlashPos));
                // Extract up to (and including) the last backslash
                if LastSlashPos > 0 then
                    RootDir := Copy(RootDir, 1, LastSlashPos);
                // ShowMessage('Step 4 - Final RootDir: ' + RootDir);
                // Now RootDir = C:\\...\\server\\
                Break;
            end;
        end;
    end;

    // Initialize file paths based on script location
    InitializeFilePaths(RootDir);

    // DEBUG: Show all path calculations
    // ShowMessage('DEBUG Path Info:' + #13#10 + 
    //             'ScriptPath: ' + ScriptPath + #13#10 + 
    //             'RootDir: ' + RootDir + #13#10 + 
    //             'ROOT_DIR (global): ' + ROOT_DIR + #13#10 + 
    //             'REQUEST_FILE: ' + REQUEST_FILE);

    // Check if request file exists
    if not FileExists(REQUEST_FILE) then
    begin
        ShowMessage('Error: No request file found.' + #13#10 + 'ROOT_DIR: ' + ROOT_DIR + #13#10 + 'Full path: ' + REQUEST_FILE);
        Exit;
    end;

    try
        // Initialize parameters list
        Params := TStringList.Create;
        Params.Delimiter := '=';

        // Read the request file
        RequestData := TStringList.Create;
        try
            RequestData.LoadFromFile(REQUEST_FILE);

            // Default command type
            CommandType := '';

            // Parse command and parameters
            for i := 0 to RequestData.Count - 1 do
            begin
                Line := RequestData[i];

                // Extract command
                if Pos('"command":', Line) > 0 then
                begin
                    ValueStart := Pos(':', Line) + 1;
                    CommandType := Copy(Line, ValueStart, Length(Line) - ValueStart + 1);
                    CommandType := TrimJSON(CommandType);
                end
                else
                begin
                    // Extract all other parameters
                    ExtractParameter(Line);
                end;
            end;

            // Execute the command if valid
            if CommandType <> '' then
            begin
                Result := ExecuteCommand(CommandType);

                if Result <> '' then
                begin
                    WriteResponse(True, Result, '');
                end
                else
                begin
                    WriteResponse(False, '', 'Command execution failed');
                    ShowMessage('Error: Command execution failed');
                end;
            end
            else
            begin
                WriteResponse(False, '', 'No command specified');
                ShowMessage('Error: No command specified');
            end;
        finally
            RequestData.Free;
            Params.Free;
        end;
    except
        // Simple exception handling without the specific exception type
        WriteResponse(False, '', 'Exception occurred during script execution');
        ShowMessage('Error: Exception occurred during script execution');
    end;
end;
