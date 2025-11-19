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


function ExecuteAddMountingHole(RequestData: TStringList): String;


function ExecuteAddBoardText(RequestData: TStringList): String;


function ExecuteRouteTrace(RequestData: TStringList): String;


function ExecuteAddVia(RequestData: TStringList): String;


function ExecuteAddCopperPour(RequestData: TStringList): String;


end.
