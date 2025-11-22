# Altium DelphiScript API Search - Usage Guide

## Overview

The Altium MCP server now includes **semantic API search tools** that allow LLMs to query verified DelphiScript API documentation before writing code. This eliminates hallucinations by providing access to 1,672 verified API methods, properties, and functions extracted from 128 working examples.

## Available Tools

### 1. `search_delphiscript_api`

**Purpose**: Find API methods, properties, and functions using natural language queries

**When to use**: Before writing any DelphiScript code, use this tool to find the correct API methods

**Parameters**:
- `query` (required): Natural language description of what you want to do
- `n_results` (optional): Number of results to return (default: 10)
- `filter_category` (optional): Filter by category - "PCB", "Schematic", "Server", "delphi_stdlib", or "Common"

**Example queries**:
```
"move component to coordinates" → IPCB_Component.MoveToXY
"iterate all components on board" → IPCB_BoardIterator
"convert number to text" → IntToStr, FloatToStr
"get current PCB" → PCBServer.GetCurrentPCBBoard
"rotate component" → IPCB_Component.Rotation (property)
```

**Returns**: JSON with ranked results including:
- `full_name`: Complete method/property name (e.g., "IPCB_Component.MoveToXY")
- `type`: "method", "property", "api_type", "stdlib_function", etc.
- `category`: API category (PCB, Schematic, Server, delphi_stdlib)
- `parent_type`: For methods/properties, the type they belong to
- `distance`: Similarity score (lower is better)

### 2. `get_api_type_details`

**Purpose**: Get all methods and properties for a specific API type

**When to use**: After finding a type with `search_delphiscript_api`, use this to see all available operations

**Parameters**:
- `type_name` (required): API type name (e.g., "IPCB_Component", "PCBServer", "TStringList")

**Example**:
```
type_name: "IPCB_Component"
→ Returns all methods (MoveToXY, MoveByXY, etc.) and properties (X, Y, Rotation, Layer, etc.)
```

**Returns**: JSON with:
- `methods`: List of all methods on this type
- `properties`: List of all properties on this type
- `total_methods`: Count of methods
- `total_properties`: Count of properties

### 3. `list_delphi_stdlib_functions`

**Purpose**: List all Delphi standard library built-in functions

**When to use**: To discover available built-in functions for common operations

**Parameters**: None

**Returns**: JSON with all built-in functions grouped by category:
- **String**: IntToStr, Format, StringReplace, Trim, etc.
- **Math**: Round, Sqrt, Sin, Cos, Abs, etc.
- **UI**: ShowMessage, MessageDlg
- **Other**: FileExists, Now, etc.

## LLM Workflow

### When Writing DelphiScript Code:

1. **ALWAYS search first**: Before writing any code, use `search_delphiscript_api` to find the correct API
2. **Verify the API exists**: Only use methods/properties that appear in search results
3. **Check type details**: Use `get_api_type_details` to see all available operations on a type
4. **Never hallucinate**: If a method doesn't appear in search results, it likely doesn't exist

### Example Workflow:

**User Request**: "Move component R1 to position (100, 200)"

**Step 1 - Search for API**:
```
Tool: search_delphiscript_api
Query: "move component to coordinates"

Result:
1. IPCB_Component.MoveToXY (method, PCB)
2. IPCB_Component.MoveByXY (method, PCB)
```

**Step 2 - Get type details** (optional):
```
Tool: get_api_type_details
Type: "IPCB_Component"

Result:
- Methods: MoveToXY, MoveByXY, RotateAround, FlipComponent, ...
- Properties: X, Y, Rotation, Layer, Name, Comment, ...
```

**Step 3 - Write verified code**:
```pascal
var
    Board : IPCB_Board;
    Component : IPCB_Component;
begin
    Board := PCBServer.GetCurrentPCBBoard;
    if Board = nil then Exit;

    Component := Board.GetPcbComponentByRefDes('R1');
    if Component <> nil then
    begin
        PCBServer.PreProcess;
        Component.MoveToXY(100, 200);  // ✓ Verified API method
        PCBServer.PostProcess;
    end;
end;
```

## What's in the Database

### Coverage:
- **89 Altium API types** (IPCB_*, ISch_*, PCBServer, etc.)
- **241 API methods**
- **1,290 API properties**
- **41 Delphi built-in functions** (IntToStr, Format, ShowMessage, etc.)
- **7 Delphi built-in types** (TStringList, TList, TObjectList, etc.)

### Categories:
- **PCB API**: 58 types for PCB manipulation
- **Schematic API**: 16 types for schematic operations
- **Server Objects**: PCBServer, SCHServer, SchServer
- **Delphi Stdlib**: Built-in functions and types
- **Common**: Shared types like IProject, IDocument, INet

### Data Source:
All APIs extracted from **128 verified working DelphiScript examples** from the Altium scripts-libraries repository. Zero hallucinations - 100% verified.

## Integration with MCP

The API search tools are now registered in the MCP server and available for use. When the server starts, you'll see:

```
Registering API search tools...
```

The ChromaDB database is loaded lazily on first use (when the first query is made).

## Benefits

1. **Zero Hallucinations**: Only use verified API methods that actually exist
2. **Natural Language**: Query with "how do I..." instead of knowing exact method names
3. **Discovery**: Find related methods and properties through similarity search
4. **Fast**: In-memory vector search with sub-second response times
5. **Complete**: Covers both Altium-specific API and Delphi standard library

## Notes

- The vector database is persistent and doesn't need rebuilding
- Database size: 5.7 MB (1,672 documents)
- First query loads the database (~1-2 seconds), subsequent queries are instant
- Results are ranked by semantic similarity (lower distance = better match)
