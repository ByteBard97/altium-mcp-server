// board_init.pas
// Board initialization functions for Altium PCB

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
        Board := PCBServer.GetCurrentPCBBoard;
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

        PCBServer.PreProcess;
        try
            // Set board size (convert mm to internal units)
            Board.BoardOutline.SetState_XSize(MMsToCoord(Width));
            Board.BoardOutline.SetState_YSize(MMsToCoord(Height));

            AddJSONBoolean(ResultProps, 'success', True);
            AddJSONProperty(ResultProps, 'width', FloatToStr(Width) + 'mm');
            AddJSONProperty(ResultProps, 'height', FloatToStr(Height) + 'mm');
        finally
            PCBServer.PostProcess;
        // REMOVED EXTRA END: end;

        // Refresh view
        Client.SendMessage('PCB:Zoom', 'Action=Redraw', 255, Client.CurrentView);

        OutputLines := TStringList.Create;
        try
            OutputLines.Text := BuildJSONObject(ResultProps);
            Result := OutputLines.Text;
        finally
            OutputLines.Free;
        // REMOVED EXTRA END: end;
    finally
        ResultProps.Free;
    // REMOVED EXTRA END: end;
// REMOVED DUPLICATE END: end;

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
        Board := PCBServer.GetCurrentPCBBoard;
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

        PCBServer.PreProcess;
        try
            // Create four tracks to form the board outline
            for i := 0 to 3 do
            begin
                Track := PCBServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
                if Track <> nil then
                begin
                    Track.X1 := Points[i].X;
                    Track.Y1 := Points[i].Y;
                    Track.X2 := Points[i + 1].X;
                    Track.Y2 := Points[i + 1].Y;
                    Track.Layer := eKeepOutLayer; // Board outline is on KeepOut layer
                    Track.Width := MMsToCoord(0.2); // 0.2mm width for outline

                    Board.AddPCBObject(Track);
                    PCBServer.SendMessageToRobots(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Track.I_ObjectAddress);
                end;
            // REMOVED DUPLICATE END: end;

            AddJSONBoolean(ResultProps, 'success', True);
            AddJSONProperty(ResultProps, 'message', 'Board outline added');
            AddJSONProperty(ResultProps, 'x', FloatToStr(X) + 'mm');
            AddJSONProperty(ResultProps, 'y', FloatToStr(Y) + 'mm');
            AddJSONProperty(ResultProps, 'width', FloatToStr(Width) + 'mm');
            AddJSONProperty(ResultProps, 'height', FloatToStr(Height) + 'mm');
        finally
            PCBServer.PostProcess;
        end;

        // Refresh view
        Client.SendMessage('PCB:Zoom', 'Action=Redraw', 255, Client.CurrentView);

        OutputLines := TStringList.Create;
        try
            OutputLines.Text := BuildJSONObject(ResultProps);
            Result := OutputLines.Text;
        finally
            OutputLines.Free;
        // REMOVED EXTRA END: end;
    finally
        ResultProps.Free;
    // REMOVED EXTRA END: end;
// REMOVED DUPLICATE END: end;

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
        Board := PCBServer.GetCurrentPCBBoard;
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

        PCBServer.PreProcess;
        try
            // Create a pad object for the mounting hole
            Pad := PCBServer.PCBObjectFactory(ePadObject, eNoDimension, eCreate_Default);
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
                PCBServer.SendMessageToRobots(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Pad.I_ObjectAddress);

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
            PCBServer.PostProcess;
        // REMOVED EXTRA END: end;

        // Refresh view
        Client.SendMessage('PCB:Zoom', 'Action=Redraw', 255, Client.CurrentView);

        OutputLines := TStringList.Create;
        try
            OutputLines.Text := BuildJSONObject(ResultProps);
            Result := OutputLines.Text;
        finally
            OutputLines.Free;
        // REMOVED EXTRA END: end;
    finally
        ResultProps.Free;
    // REMOVED EXTRA END: end;
// REMOVED DUPLICATE END: end;

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
        Board := PCBServer.GetCurrentPCBBoard;
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

        PCBServer.PreProcess;
        try
            // Create text object
            TextObj := PCBServer.PCBObjectFactory(eTextObject, eNoDimension, eCreate_Default);
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
                PCBServer.SendMessageToRobots(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, TextObj.I_ObjectAddress);

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
            PCBServer.PostProcess;
        // REMOVED EXTRA END: end;

        // Refresh view
        Client.SendMessage('PCB:Zoom', 'Action=Redraw', 255, Client.CurrentView);

        OutputLines := TStringList.Create;
        try
            OutputLines.Text := BuildJSONObject(ResultProps);
            Result := OutputLines.Text;
        finally
            OutputLines.Free;
        // REMOVED EXTRA END: end;
    finally
        ResultProps.Free;
    // REMOVED EXTRA END: end;
// REMOVED DUPLICATE END: end;
