// routing.pas
// Routing functions for Altium PCB

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
        LayerObj := eTopLayer; // Default
        if Layer = 'TopLayer' then LayerObj := eTopLayer
        else if Layer = 'BottomLayer' then LayerObj := eBottomLayer
        else if Layer = 'MidLayer1' then LayerObj := eMidLayer1
        else if Layer = 'MidLayer2' then LayerObj := eMidLayer2
        else if Layer = 'MidLayer3' then LayerObj := eMidLayer3
        else if Layer = 'MidLayer4' then LayerObj := eMidLayer4;

        PCBServer.PreProcess;
        try
            // Create track object
            Track := PCBServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
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
                        Net := PCBServer.PCBObjectFactory(eNetObject, eNoDimension, eCreate_Default);
                        if Net <> nil then
                        begin
                            Net.Name := TDynamicString(NetName);
                            Board.AddPCBObject(Net);
                            Track.Net := Net;
                        end;
                    end;
                end;

                Board.AddPCBObject(Track);
                PCBServer.SendMessageToRobots(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Track.I_ObjectAddress);

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

        PCBServer.PreProcess;
        try
            // Create via object
            Via := PCBServer.PCBObjectFactory(eViaObject, eNoDimension, eCreate_Default);
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
                        Net := PCBServer.PCBObjectFactory(eNetObject, eNoDimension, eCreate_Default);
                        if Net <> nil then
                        begin
                            Net.Name := TDynamicString(NetName);
                            Board.AddPCBObject(Net);
                            Via.Net := Net;
                        end;
                    end;
                end;

                Board.AddPCBObject(Via);
                PCBServer.SendMessageToRobots(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Via.I_ObjectAddress);

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
        LayerObj := eTopLayer; // Default
        if Layer = 'TopLayer' then LayerObj := eTopLayer
        else if Layer = 'BottomLayer' then LayerObj := eBottomLayer
        else if Layer = 'MidLayer1' then LayerObj := eMidLayer1
        else if Layer = 'MidLayer2' then LayerObj := eMidLayer2
        else if Layer = 'MidLayer3' then LayerObj := eMidLayer3
        else if Layer = 'MidLayer4' then LayerObj := eMidLayer4;

        PCBServer.PreProcess;
        try
            // Create polygon object
            Polygon := PCBServer.PCBObjectFactory(ePolyObject, eNoDimension, eCreate_Default);
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
                        Net := PCBServer.PCBObjectFactory(eNetObject, eNoDimension, eCreate_Default);
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
                PCBServer.SendMessageToRobots(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Polygon.I_ObjectAddress);

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
        end;
    finally
        ResultProps.Free;
    end;
end;
