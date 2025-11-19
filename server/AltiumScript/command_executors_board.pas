// command_executors_board.pas
// Board and Routing Command Executors

unit command_executors_board;

interface

uses
    PCB, Classes, SysUtils, globals, json_utils, board_init, routing;

function ExecuteSetBoardSize(RequestData: TStringList): String;
function ExecuteAddBoardOutline(RequestData: TStringList): String;
function ExecuteAddMountingHole(RequestData: TStringList): String;
function ExecuteAddBoardText(RequestData: TStringList): String;
function ExecuteRouteTrace(RequestData: TStringList): String;
function ExecuteAddVia(RequestData: TStringList): String;
function ExecuteAddCopperPour(RequestData: TStringList): String;

implementation

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

end.
