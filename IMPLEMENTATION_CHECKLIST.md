# Implementation Checklist for Tier 1 Features
## Step-by-Step Build Guide Using VERIFIED APIs Only

---

## Architecture Overview

For each new tool, we need to build **3 layers**:

```
┌─────────────────────────────────────────────┐
│  Python MCP Tool (server/tools/*.py)       │  ← User-facing API
│  - @mcp.tool() decorator                   │
│  - Parameter validation                    │
│  - Calls altium_bridge                     │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│  Command Router (command_router.pas)        │  ← Dispatch layer
│  - Routes command name to executor          │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│  Executor Function (command_executors_*.pas)│  ← Altium API calls
│  - Uses VERIFIED Altium APIs                │
│  - Returns JSON string                      │
└─────────────────────────────────────────────┘
```

---

## Example: `get_board_extents()` (Complete Implementation)

### STEP 1: Create DelphiScript Executor Function

**File**: `server/AltiumScript/pcb_utils.pas`

**Location**: Add after existing functions

```pascal
{..............................................................................}
{ ExecuteGetBoardExtents - Calculate board bounding box from all components  }
{..............................................................................}
function ExecuteGetBoardExtents(const Params: String): String;
var
    Board: IPCB_Board;
    Iterator: IPCB_BoardIterator;
    Component: IPCB_Component;
    Rect: TCoordRect;
    MinX, MinY, MaxX, MaxY: TCoord;
    xorigin, yorigin: TCoord;
    FirstComponent: Boolean;
    JsonBuilder: TStringList;
begin
    JsonBuilder := TStringList.Create;
    try
        // Get current board
        Board := GetPCBServer.GetCurrentPCBBoard;
        if Board = nil then
        begin
            Result := '{"success": false, "error": "No PCB document open"}';
            Exit;
        end;

        xorigin := Board.XOrigin;
        yorigin := Board.YOrigin;

        // Initialize bounds
        FirstComponent := True;

        // Create iterator for all components
        Iterator := Board.BoardIterator_Create;
        Iterator.AddFilter_ObjectSet(MkSet(eComponentObject));
        Iterator.AddFilter_LayerSet(AllLayers);
        Iterator.AddFilter_Method(eProcessAll);

        try
            Component := Iterator.FirstPCBObject;
            while (Component <> Nil) do
            begin
                Rect := Component.BoundingRectangleNoNameComment;

                if FirstComponent then
                begin
                    MinX := Rect.Left;
                    MinY := Rect.Bottom;
                    MaxX := Rect.Right;
                    MaxY := Rect.Top;
                    FirstComponent := False;
                end
                else
                begin
                    if Rect.Left < MinX then MinX := Rect.Left;
                    if Rect.Bottom < MinY then MinY := Rect.Bottom;
                    if Rect.Right > MaxX then MaxX := Rect.Right;
                    if Rect.Top > MaxY then MaxY := Rect.Top;
                end;

                Component := Iterator.NextPCBObject;
            end;
        finally
            Board.BoardIterator_Destroy(Iterator);
        end;

        // Build JSON response
        JsonBuilder.Add('{');
        JsonBuilder.Add('  "success": true,');
        JsonBuilder.Add('  "data": {');
        AddJSONNumber(JsonBuilder, 'min_x_mm', CoordToMMs(MinX - xorigin));
        AddJSONNumber(JsonBuilder, 'min_y_mm', CoordToMMs(MinY - yorigin));
        AddJSONNumber(JsonBuilder, 'max_x_mm', CoordToMMs(MaxX - xorigin));
        AddJSONNumber(JsonBuilder, 'max_y_mm', CoordToMMs(MaxY - yorigin));
        AddJSONNumber(JsonBuilder, 'width_mm', CoordToMMs(MaxX - MinX));
        AddJSONNumber(JsonBuilder, 'height_mm', CoordToMMs(MaxY - MinY));
        JsonBuilder.Add('  }');
        JsonBuilder.Add('}');

        Result := JsonBuilder.Text;
    finally
        JsonBuilder.Free;
    end;
end;
```

**Verified APIs Used**:
- ✅ `GetPCBServer.GetCurrentPCBBoard` - Get board
- ✅ `Board.BoardIterator_Create` - Create iterator
- ✅ `Iterator.AddFilter_ObjectSet(MkSet(eComponentObject))` - Filter components
- ✅ `Component.BoundingRectangleNoNameComment` - Get component bounds
- ✅ `Board.XOrigin`, `Board.YOrigin` - Coordinate system
- ✅ `CoordToMMs()` - Unit conversion

---

### STEP 2: Add Command Routing

**File**: `server/AltiumScript/command_router.pas`

**Location**: In the `RouteCommand` function, add new case:

```pascal
function RouteCommand(const CommandName, Params: String): String;
begin
    if CommandName = 'get_all_component_property_names' then
        Result := ExecuteGetAllComponentPropertyNames(Params)

    else if CommandName = 'get_component_property_values' then
        Result := ExecuteGetComponentPropertyValues(Params)

    // ... existing commands ...

    else if CommandName = 'get_board_extents' then          // ← ADD THIS
        Result := ExecuteGetBoardExtents(Params)

    else
        Result := '{"success": false, "error": "Unknown command: ' + CommandName + '"}';
end;
```

---

### STEP 3: Create Python MCP Tool

**File**: `server/tools/board_tools.py`

**Location**: Add new tool function:

```python
@mcp.tool()
async def get_board_extents() -> str:
    """
    Get the bounding box dimensions of the PCB board based on component placement.

    Calculates the minimum rectangular area that contains all components
    on the board. Useful for:
    - Understanding actual board size requirements
    - Verifying board fits within mechanical constraints
    - Calculating panelization requirements
    - Design space analysis

    Returns:
        JSON object with board extents:
        {
            "success": true,
            "data": {
                "min_x_mm": float,      // Minimum X coordinate
                "min_y_mm": float,      // Minimum Y coordinate
                "max_x_mm": float,      // Maximum X coordinate
                "max_y_mm": float,      // Maximum Y coordinate
                "width_mm": float,      // Total width
                "height_mm": float      // Total height
            }
        }

    Example:
        >>> extents = await get_board_extents()
        >>> print(f"Board is {extents['data']['width_mm']}mm x {extents['data']['height_mm']}mm")
    """
    response = await altium_bridge.call_script("get_board_extents", {})

    if not response.success:
        return json.dumps({
            "success": False,
            "error": f"Failed to get board extents: {response.error}"
        })

    return json.dumps(response.data, indent=2)
```

---

### STEP 4: Register Tool (if new file)

**File**: `server/main.py`

**Only needed if creating a NEW tools file. For existing files like `board_tools.py`, the registration already exists.**

```python
# In main.py, board_tools is already registered:
register_board_tools(mcp, altium_bridge)  # Already exists
```

---

### STEP 5: Test

```bash
# In Altium, open a PCB project
# In Claude Desktop, test the tool:

"What are my board dimensions?"

# Expected response:
# Based on component placement, your board extents are:
# - Width: 85.2mm
# - Height: 54.6mm
# - Bounding box: (10.0, 15.0) to (95.2, 69.6)
```

---

## Full Implementation List

### Feature 1: `get_board_extents()` ✅ (Example Above)
- **Pascal**: `ExecuteGetBoardExtents` in `pcb_utils.pas`
- **Router**: Add case in `command_router.pas`
- **Python**: Add tool in `board_tools.py`
- **Effort**: 0.5 days

---

### Feature 2: `get_net_details(net_name: str)`

#### Pascal Executor (`pcb_utils.pas`):
```pascal
function ExecuteGetNetDetails(const Params: String): String;
var
    Board: IPCB_Board;
    Net: IPCB_Net;
    NetName: String;
    Iterator: IPCB_BoardIterator;
    Track: IPCB_Track;
    Via: IPCB_Via;
    Pad: IPCB_Pad;
    TrackList, ViaList, PadList: TStringList;
    xorigin, yorigin: TCoord;
begin
    // Parse NetName from Params JSON
    NetName := GetParamValue(Params, 'net_name');

    Board := GetPCBServer.GetCurrentPCBBoard;
    Net := Board.FindNet(NetName);

    if Net = nil then
    begin
        Result := '{"success": false, "error": "Net not found: ' + NetName + '"}';
        Exit;
    end;

    xorigin := Board.XOrigin;
    yorigin := Board.YOrigin;

    TrackList := TStringList.Create;
    ViaList := TStringList.Create;
    PadList := TStringList.Create;

    try
        // Iterate tracks
        Iterator := Board.BoardIterator_Create;
        Iterator.AddFilter_ObjectSet(MkSet(eTrackObject));

        Track := Iterator.FirstPCBObject;
        while (Track <> Nil) do
        begin
            if (Track.Net = Net) then
            begin
                // Build track JSON: coordinates, width, layer
                TrackJSON := '{';
                TrackJSON := TrackJSON + '"x1_mm": ' + FloatToStr(CoordToMMs(Track.X1 - xorigin)) + ', ';
                TrackJSON := TrackJSON + '"y1_mm": ' + FloatToStr(CoordToMMs(Track.Y1 - yorigin)) + ', ';
                TrackJSON := TrackJSON + '"x2_mm": ' + FloatToStr(CoordToMMs(Track.X2 - xorigin)) + ', ';
                TrackJSON := TrackJSON + '"y2_mm": ' + FloatToStr(CoordToMMs(Track.Y2 - yorigin)) + ', ';
                TrackJSON := TrackJSON + '"width_mm": ' + FloatToStr(CoordToMMs(Track.Width)) + ', ';
                TrackJSON := TrackJSON + '"layer": "' + Layer2String(Track.Layer) + '"';
                TrackJSON := TrackJSON + '}';

                TrackList.Add(TrackJSON);
            end;
            Track := Iterator.NextPCBObject;
        end;

        Board.BoardIterator_Destroy(Iterator);

        // Same for vias and pads...

        // Build final JSON with tracks, vias, pads arrays

    finally
        TrackList.Free;
        ViaList.Free;
        PadList.Free;
    end;
end;
```

#### Python Tool (`board_tools.py`):
```python
@mcp.tool()
async def get_net_details(net_name: str) -> str:
    """
    Get detailed routing information for a specific net.

    Returns all tracks, vias, and pads connected to the specified net,
    including their coordinates, dimensions, and layers. Useful for:
    - Understanding net routing topology
    - Analyzing trace widths and layer usage
    - Debugging connectivity issues
    - Signal integrity analysis

    Args:
        net_name: Name of the net to analyze (e.g., "GND", "USB_DP", "VCC")

    Returns:
        JSON with net routing details including tracks, vias, and pads
    """
    response = await altium_bridge.call_script("get_net_details", {"net_name": net_name})

    if not response.success:
        return json.dumps({
            "success": False,
            "error": f"Failed to get net details: {response.error}"
        })

    return json.dumps(response.data, indent=2)
```

**Verified APIs**:
- ✅ `Board.FindNet(NetName)` - Get net
- ✅ `Track.X1`, `Track.Y1`, `Track.X2`, `Track.Y2` - Track coordinates
- ✅ `Track.Width` - Track width
- ✅ `Track.Layer` - Track layer
- ✅ `Track.Net` - Net comparison
- ✅ `Via.X`, `Via.Y`, `Via.Size`, `Via.HoleSize` - Via properties
- ✅ `Pad.Net` - Pad net connection

**Effort**: 2 days

---

### Feature 3: `get_component_neighbors(designator: str, radius_mm: float)`

#### Pascal Executor (`pcb_utils.pas`):
```pascal
function ExecuteGetComponentNeighbors(const Params: String): String;
var
    Board: IPCB_Board;
    TargetComp, Component: IPCB_Component;
    Iterator: IPCB_BoardIterator;
    Designator: String;
    RadiusMM: Float;
    RadiusCoord: TCoord;
    Distance: Float;
    NeighborList: TStringList;
    xorigin, yorigin: TCoord;
begin
    // Parse parameters
    Designator := GetParamValue(Params, 'designator');
    RadiusMM := StrToFloat(GetParamValue(Params, 'radius_mm'));

    Board := GetPCBServer.GetCurrentPCBBoard;
    TargetComp := Board.GetPcbComponentByRefDes(Designator);

    if TargetComp = nil then
    begin
        Result := '{"success": false, "error": "Component not found: ' + Designator + '"}';
        Exit;
    end;

    RadiusCoord := MMsToCoord(RadiusMM);
    xorigin := Board.XOrigin;
    yorigin := Board.YOrigin;

    NeighborList := TStringList.Create;

    try
        Iterator := Board.BoardIterator_Create;
        Iterator.AddFilter_ObjectSet(MkSet(eComponentObject));
        Iterator.AddFilter_LayerSet(AllLayers);
        Iterator.AddFilter_Method(eProcessAll);

        Component := Iterator.FirstPCBObject;
        while (Component <> Nil) do
        begin
            if (Component <> TargetComp) then
            begin
                // Calculate distance: sqrt((x2-x1)^2 + (y2-y1)^2)
                Distance := Sqrt(
                    Sqr(Component.x - TargetComp.x) +
                    Sqr(Component.y - TargetComp.y)
                );

                if Distance <= RadiusCoord then
                begin
                    // Build neighbor JSON
                    NeighborJSON := '{';
                    NeighborJSON := NeighborJSON + '"designator": "' + Component.Name.Text + '", ';
                    NeighborJSON := NeighborJSON + '"distance_mm": ' + FloatToStr(CoordToMMs(Distance)) + ', ';
                    NeighborJSON := NeighborJSON + '"x_mm": ' + FloatToStr(CoordToMMs(Component.x - xorigin)) + ', ';
                    NeighborJSON := NeighborJSON + '"y_mm": ' + FloatToStr(CoordToMMs(Component.y - yorigin));
                    NeighborJSON := NeighborJSON + '}';

                    NeighborList.Add(NeighborJSON);
                end;
            end;

            Component := Iterator.NextPCBObject;
        end;

        Board.BoardIterator_Destroy(Iterator);

        // Build final JSON

    finally
        NeighborList.Free;
    end;
end;
```

#### Python Tool (`component_tools.py`):
```python
@mcp.tool()
async def get_component_neighbors(designator: str, radius_mm: float) -> str:
    """
    Find all components within a specified radius of a target component.

    Useful for:
    - Finding nearby decoupling capacitors
    - Analyzing component density
    - Checking minimum spacing requirements
    - Identifying potential interference

    Args:
        designator: Target component reference designator (e.g., "U1")
        radius_mm: Search radius in millimeters

    Returns:
        JSON array of nearby components with distances
    """
    response = await altium_bridge.call_script(
        "get_component_neighbors",
        {
            "designator": designator,
            "radius_mm": radius_mm
        }
    )

    if not response.success:
        return json.dumps({
            "success": False,
            "error": f"Failed to find neighbors: {response.error}"
        })

    return json.dumps(response.data, indent=2)
```

**Verified APIs**:
- ✅ `Board.GetPcbComponentByRefDes(Designator)` - Get component
- ✅ `Component.x`, `Component.y` - Component position
- ✅ `Component.Name.Text` - Component designator
- ✅ Math functions: `Sqrt()`, `Sqr()` - Distance calculation

**Effort**: 1 day

---

## Summary Checklist

For each feature, you need:

### ☐ Pascal Side (1-2 hours each)
1. [ ] Create `ExecuteXXX` function in appropriate executor file
2. [ ] Use ONLY verified APIs from VERIFIED_API_REFERENCE.md
3. [ ] Build JSON response using TStringList
4. [ ] Add error handling (null checks, try/finally)

### ☐ Routing (5 minutes)
1. [ ] Add `else if` case in `command_router.pas`
2. [ ] Map command name to executor function

### ☐ Python Side (30 minutes each)
1. [ ] Create `@mcp.tool()` function in appropriate tools file
2. [ ] Add comprehensive docstring
3. [ ] Call `altium_bridge.call_script(command_name, params)`
4. [ ] Handle response errors
5. [ ] Return JSON

### ☐ Testing (30 minutes each)
1. [ ] Open real Altium project
2. [ ] Test via Claude Desktop
3. [ ] Verify results are accurate
4. [ ] Test error cases (no board open, component not found, etc.)

---

## Total Effort Estimate

| Feature | Pascal | Router | Python | Test | Total |
|---------|--------|--------|--------|------|-------|
| get_board_extents | 2h | 5m | 30m | 30m | 4h |
| get_net_details | 4h | 5m | 30m | 1h | 5.5h |
| get_component_neighbors | 2h | 5m | 30m | 30m | 3.5h |
| find_components_by_pattern | 2h | 5m | 30m | 30m | 3.5h |
| get_layer_usage_stats | 3h | 5m | 30m | 1h | 5h |
| set_layer_visibility_by_type | 2h | 5m | 30m | 30m | 3.5h |
| analyze_power_distribution | 4h | 5m | 30m | 1h | 6h |
| get_net_routing_statistics | 3h | 5m | 30m | 1h | 5h |

**Total: ~36 hours (4.5 days) for all 8 Tier 1 features**

---

## What You Need to Start

1. ✅ **Verified API Reference** - Already created (VERIFIED_API_REFERENCE.md)
2. ✅ **Existing codebase patterns** - You have working examples in all executor files
3. ✅ **JSON helper functions** - Already have `AddJSONProperty`, `AddJSONNumber`, etc.
4. ✅ **Altium bridge** - Already working
5. ✅ **Test project** - Any open Altium PCB project

**You're ready to start implementing now!**

---

## Which Feature to Build First?

**Recommendation: `get_board_extents()`**

**Why:**
- Simplest (4 hours total)
- Immediate value ("How big is my board?")
- Tests the full stack (Pascal → Router → Python → MCP)
- Builds confidence in the pattern

**After that:**
1. `get_component_neighbors()` - Also simple, high value
2. `get_net_details()` - More complex, very useful
3. `find_components_by_pattern()` - Enhances existing search
4. Rest in priority order

Would you like me to implement `get_board_extents()` right now to show you the complete working example?
