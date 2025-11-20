// command_executors_placement.pas
// Component Placement Command Executors

unit command_executors_placement;

interface

uses
    PCB, Classes, SysUtils, globals, json_utils, component_placement;

function ExecutePlaceComponent(RequestData: TStringList): String;
function ExecuteDeleteComponent(RequestData: TStringList): String;
function ExecutePlaceComponentArray(RequestData: TStringList): String;
function ExecuteAlignComponents(RequestData: TStringList): String;

implementation

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

end.
