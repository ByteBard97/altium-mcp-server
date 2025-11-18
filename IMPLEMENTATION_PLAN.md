# Altium MCP Enhancement Implementation Plan

## Overview

This plan outlines a phased approach to bring the Altium MCP plugin to feature parity with the enhanced KiCad MCP implementations while maintaining its unique strengths in symbol creation and layout intelligence.

**Timeline:** 8-12 weeks
**Effort:** ~200-300 hours
**Phases:** 5 major phases

---

## Phase 1: MCP Protocol Modernization (Week 1-2)

### Goals
- Upgrade to MCP 2.1.0 protocol specification
- Add Resources capability for read-only project state access
- Implement JSON Schema validation for all tools
- Add Prompt templates for common workflows

### Priority: ⭐⭐⭐ CRITICAL (Foundation for everything else)

---

### Task 1.1: Add MCP Resources Capability

**Effort:** 16 hours

**Resources to Implement:**

```python
# In server/main.py - Add resource definitions

RESOURCE_DEFINITIONS = [
    {
        "uri": "altium://project/current/info",
        "name": "Current Project Info",
        "description": "Metadata about the currently open Altium project",
        "mimeType": "application/json"
    },
    {
        "uri": "altium://project/current/board",
        "name": "Current Board Properties",
        "description": "Properties of the active PCB board",
        "mimeType": "application/json"
    },
    {
        "uri": "altium://project/current/components",
        "name": "Component List",
        "description": "All components on the current PCB with properties",
        "mimeType": "application/json"
    },
    {
        "uri": "altium://project/current/nets",
        "name": "Net List",
        "description": "All electrical nets in the current design",
        "mimeType": "application/json"
    },
    {
        "uri": "altium://project/current/layers",
        "name": "Layer Stack",
        "description": "PCB layer configuration and properties",
        "mimeType": "application/json"
    },
    {
        "uri": "altium://project/current/stackup",
        "name": "Layer Stackup Details",
        "description": "Detailed stackup with materials and impedance data",
        "mimeType": "application/json"
    },
    {
        "uri": "altium://project/current/rules",
        "name": "Design Rules",
        "description": "All PCB design rules and constraints",
        "mimeType": "application/json"
    },
    {
        "uri": "altium://board/preview.png",
        "name": "Board Preview Image",
        "description": "Visual preview of the PCB board",
        "mimeType": "image/png"
    }
]
```

**Implementation Steps:**

1. **Update server/main.py:**
   ```python
   from mcp import types

   @server.list_resources()
   async def list_resources() -> list[types.Resource]:
       """List available resources"""
       return [
           types.Resource(
               uri=r["uri"],
               name=r["name"],
               description=r["description"],
               mimeType=r["mimeType"]
           )
           for r in RESOURCE_DEFINITIONS
       ]

   @server.read_resource()
   async def read_resource(uri: str) -> str:
       """Read a resource by URI"""
       if uri == "altium://project/current/info":
           return await get_project_info_resource()
       elif uri == "altium://project/current/components":
           return await get_components_resource()
       # ... handle other URIs
       else:
           raise ValueError(f"Unknown resource URI: {uri}")
   ```

2. **Create resource handlers in server/resources.py:**
   ```python
   async def get_project_info_resource() -> str:
       """Get current project information"""
       result = await call_altium_script("get_project_info", {})
       return json.dumps(result, indent=2)

   async def get_components_resource() -> str:
       """Get all components with properties"""
       # Combine existing tools
       designators = await call_altium_script("get_all_designators", {})
       if not designators.get("success"):
           return json.dumps({"error": "Failed to get components"})

       components = []
       for des in designators.get("result", []):
           props = await call_altium_script("get_component_data", {
               "cmp_designators": [des]
           })
           if props.get("success"):
               components.append(props.get("result"))

       return json.dumps(components, indent=2)
   ```

3. **Add DelphiScript support (server/AltiumScript/other_utils.pas):**
   ```pascal
   function GetProjectInfo: TStringList;
   begin
       Result := TStringList.Create;
       try
           if GetWorkspace.DM_FocusedProject <> nil then begin
               Result.Add('"name": "' + GetWorkspace.DM_FocusedProject.DM_ProjectFileName + '"');
               Result.Add('"path": "' + GetWorkspace.DM_FocusedProject.DM_ProjectFullPath + '"');
               // Add more project metadata
           end;
       except
           on E: Exception do
               Result.Add('"error": "' + E.Message + '"');
       end;
   end;
   ```

**Testing:**
```bash
# Test resource listing
echo '{"jsonrpc":"2.0","id":1,"method":"resources/list","params":{}}' | python server/main.py

# Test resource reading
echo '{"jsonrpc":"2.0","id":2,"method":"resources/read","params":{"uri":"altium://project/current/info"}}' | python server/main.py
```

---

### Task 1.2: Add JSON Schema Definitions

**Effort:** 12 hours

**Create server/schemas.py:**

```python
TOOL_SCHEMAS = {
    "get_all_designators": {
        "name": "get_all_designators",
        "description": "Returns all component designators on the current PCB board",
        "inputSchema": {
            "type": "object",
            "properties": {},
            "required": []
        }
    },

    "get_component_data": {
        "name": "get_component_data",
        "description": "Retrieves complete data for specified components including all properties",
        "inputSchema": {
            "type": "object",
            "properties": {
                "cmp_designators": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "List of component designators (e.g., ['R1', 'C5', 'U3'])",
                    "minItems": 1
                }
            },
            "required": ["cmp_designators"]
        }
    },

    "create_schematic_symbol": {
        "name": "create_schematic_symbol",
        "description": "Creates a new schematic symbol in the currently open library with intelligent pin placement",
        "inputSchema": {
            "type": "object",
            "properties": {
                "symbol_name": {
                    "type": "string",
                    "description": "Name for the new symbol",
                    "minLength": 1
                },
                "description": {
                    "type": "string",
                    "description": "Description of the symbol"
                },
                "pins": {
                    "type": "array",
                    "items": {
                        "type": "string",
                        "description": "Pin definition: 'pin_number|pin_name|pin_type|pin_orientation|x|y'"
                    },
                    "description": "List of pin definitions",
                    "minItems": 1
                }
            },
            "required": ["symbol_name", "description", "pins"]
        }
    },

    "create_net_class": {
        "name": "create_net_class",
        "description": "Creates or modifies a net class and adds specified nets to it",
        "inputSchema": {
            "type": "object",
            "properties": {
                "class_name": {
                    "type": "string",
                    "description": "Name of the net class to create/modify",
                    "minLength": 1
                },
                "net_names": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "List of net names to add to the class",
                    "minItems": 1
                }
            },
            "required": ["class_name", "net_names"]
        }
    },

    "move_components": {
        "name": "move_components",
        "description": "Moves specified components by XY offset and optionally rotates them",
        "inputSchema": {
            "type": "object",
            "properties": {
                "cmp_designators": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "List of component designators to move",
                    "minItems": 1
                },
                "x_offset": {
                    "type": "number",
                    "description": "X offset in mils (1000 mils = 1 inch)"
                },
                "y_offset": {
                    "type": "number",
                    "description": "Y offset in mils"
                },
                "rotation": {
                    "type": "number",
                    "description": "Rotation angle in degrees (0-360, 0 = no rotation)",
                    "minimum": 0,
                    "maximum": 360,
                    "default": 0
                }
            },
            "required": ["cmp_designators", "x_offset", "y_offset"]
        }
    },

    "layout_duplicator_apply": {
        "name": "layout_duplicator_apply",
        "description": "Applies layout pattern from source components to destination components",
        "inputSchema": {
            "type": "object",
            "properties": {
                "source_designators": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Source component designators",
                    "minItems": 1
                },
                "destination_designators": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Destination component designators (must match source length)",
                    "minItems": 1
                }
            },
            "required": ["source_designators", "destination_designators"]
        }
    }

    # TODO: Add schemas for all 23 existing tools
}
```

**Update tool registration:**

```python
# In server/main.py

@server.list_tools()
async def list_tools() -> list[types.Tool]:
    """List available tools with schemas"""
    return [
        types.Tool(
            name=schema["name"],
            description=schema["description"],
            inputSchema=schema["inputSchema"]
        )
        for schema in TOOL_SCHEMAS.values()
    ]
```

---

### Task 1.3: Add Prompt Templates

**Effort:** 8 hours

**Create server/prompts.py:**

```python
PROMPT_TEMPLATES = [
    {
        "name": "create_symbol_from_datasheet",
        "description": "Guide user through creating a schematic symbol from a datasheet",
        "arguments": [
            {
                "name": "component_type",
                "description": "Type of component (e.g., IC, connector, discrete)",
                "required": True
            }
        ]
    },
    {
        "name": "duplicate_layout_workflow",
        "description": "Step-by-step workflow for duplicating a layout pattern",
        "arguments": [
            {
                "name": "circuit_type",
                "description": "Type of circuit to duplicate (e.g., power supply, differential pair)",
                "required": True
            }
        ]
    },
    {
        "name": "organize_nets_by_function",
        "description": "Organize nets into classes by their function",
        "arguments": []
    }
]

def get_prompt_content(prompt_name: str, arguments: dict) -> str:
    """Generate prompt content based on template"""

    if prompt_name == "create_symbol_from_datasheet":
        return f"""I'll help you create a schematic symbol for a {arguments.get('component_type', 'component')}.

First, let me check the symbol placement rules:
- I'll call get_symbol_placement_rules() to understand formatting guidelines

Then, we'll need:
1. Component pin count and names from the datasheet
2. Pin types (input, output, power, ground, etc.)
3. Preferred symbol orientation

Let's start by getting the placement rules, then I'll guide you through defining each pin."""

    elif prompt_name == "duplicate_layout_workflow":
        return f"""I'll guide you through duplicating a {arguments.get('circuit_type', 'layout')} pattern.

Step 1: First, select your source components in Altium
- Select all components that are part of the reference layout

Step 2: I'll call layout_duplicator() to capture the pattern
- This will return the source component data and available destinations

Step 3: We'll match source components to destinations
- I can intelligently match by function even if values differ

Step 4: I'll call layout_duplicator_apply() to replicate the layout
- The relative positioning and routing will be duplicated

Ready to start? Please select your source components in Altium."""

    elif prompt_name == "organize_nets_by_function":
        return """I'll help you organize your nets into classes by function.

First, let me get all nets from your board:
- I'll call get_all_nets() to see what we're working with

Then, we can create net classes for:
- Power nets (VCC, VDD, etc.)
- Ground nets (GND, AGND, DGND)
- High-speed signals (USB, PCIe, HDMI)
- Differential pairs
- Control signals
- Other functional groups

Let me start by getting your net list..."""

    return ""
```

**Register prompts:**

```python
# In server/main.py

@server.list_prompts()
async def list_prompts() -> list[types.Prompt]:
    """List available prompt templates"""
    return [
        types.Prompt(
            name=p["name"],
            description=p["description"],
            arguments=[
                types.PromptArgument(
                    name=arg["name"],
                    description=arg["description"],
                    required=arg["required"]
                )
                for arg in p["arguments"]
            ]
        )
        for p in PROMPT_TEMPLATES
    ]

@server.get_prompt()
async def get_prompt(name: str, arguments: dict) -> types.GetPromptResult:
    """Get a specific prompt with arguments filled in"""
    content = get_prompt_content(name, arguments)

    return types.GetPromptResult(
        description=f"Workflow: {name}",
        messages=[
            types.PromptMessage(
                role="user",
                content=types.TextContent(
                    type="text",
                    text=content
                )
            )
        ]
    )
```

---

## Phase 2: Project & Library Management (Week 3-4)

### Goals
- Add project creation and save operations
- Implement library search and component discovery
- Add project information queries

### Priority: ⭐⭐⭐ HIGH

---

### Task 2.1: Project Management Tools

**Effort:** 20 hours

**New Tools to Add:**

1. **create_project**
2. **save_project**
3. **get_project_info** (enhanced version)
4. **close_project**

**Implementation:**

**Python Server (server/main.py):**

```python
@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[types.TextContent]:
    """Execute a tool"""

    # Add new project management tools
    if name == "create_project":
        result = await create_project_tool(arguments)
    elif name == "save_project":
        result = await save_project_tool(arguments)
    elif name == "close_project":
        result = await close_project_tool(arguments)
    # ... existing tools

    return [types.TextContent(type="text", text=json.dumps(result))]

async def create_project_tool(args: dict) -> dict:
    """Create a new Altium project"""
    project_name = args.get("project_name")
    project_path = args.get("project_path")
    template = args.get("template", "blank")

    params = {
        "project_name": project_name,
        "project_path": project_path,
        "template": template
    }

    return await call_altium_script("create_project", params)

async def save_project_tool(args: dict) -> dict:
    """Save the current project"""
    return await call_altium_script("save_project", {})
```

**DelphiScript (server/AltiumScript/project_utils.pas):**

```pascal
unit project_utils;

interface

function CreateProject(const ProjectName, ProjectPath, Template: String): String;
function SaveProject: String;
function GetProjectInfo: String;
function CloseProject: String;

implementation

function CreateProject(const ProjectName, ProjectPath, Template: String): String;
var
    Workspace: IWorkspace;
    Project: IProject;
    ProjectFile: String;
    PCBDoc: IDocument;
begin
    Result := '';
    try
        Workspace := GetWorkspace;
        if Workspace = nil then
        begin
            Result := '{"success": false, "message": "No workspace available"}';
            Exit;
        end;

        // Create project file
        ProjectFile := ProjectPath + '\' + ProjectName + '.PrjPCB';

        // Create new project
        Project := Workspace.DM_CreateNewProject(ProjectFile);
        if Project = nil then
        begin
            Result := '{"success": false, "message": "Failed to create project"}';
            Exit;
        end;

        // Add a blank PCB document
        PCBDoc := Workspace.DM_CreateNewDocument('PCB');
        if PCBDoc <> nil then
        begin
            Project.DM_AddSourceDocument(PCBDoc.DM_FileName);
            PCBDoc.DM_DocumentSave;
        end;

        // Save project
        Project.DM_ProjectSave;

        Result := '{"success": true, "project_file": "' + ProjectFile + '"}';
    except
        on E: Exception do
            Result := '{"success": false, "message": "' + E.Message + '"}';
    end;
end;

function SaveProject: String;
var
    Project: IProject;
begin
    Result := '';
    try
        Project := GetWorkspace.DM_FocusedProject;
        if Project = nil then
        begin
            Result := '{"success": false, "message": "No project open"}';
            Exit;
        end;

        Project.DM_ProjectSave;
        Result := '{"success": true, "message": "Project saved"}';
    except
        on E: Exception do
            Result := '{"success": false, "message": "' + E.Message + '"}';
    end;
end;

function GetProjectInfo: String;
var
    Project: IProject;
    JsonBuilder: TStringList;
begin
    JsonBuilder := TStringList.Create;
    try
        Project := GetWorkspace.DM_FocusedProject;
        if Project = nil then
        begin
            Result := '{"success": false, "message": "No project open"}';
            Exit;
        end;

        JsonBuilder.Add('{');
        JsonBuilder.Add('  "success": true,');
        JsonBuilder.Add('  "name": "' + ExtractFileName(Project.DM_ProjectFileName) + '",');
        JsonBuilder.Add('  "path": "' + Project.DM_ProjectFullPath + '",');
        JsonBuilder.Add('  "file_count": ' + IntToStr(Project.DM_DocumentCount));
        JsonBuilder.Add('}');

        Result := JsonBuilder.Text;
    finally
        JsonBuilder.Free;
    end;
end;

end.
```

**Update Altium_API.pas to route commands:**

```pascal
// In Altium_API.pas, add to command routing:

if command = 'create_project' then
begin
    project_name := GetParamValue('project_name');
    project_path := GetParamValue('project_path');
    template := GetParamValue('template');
    result := project_utils.CreateProject(project_name, project_path, template);
end
else if command = 'save_project' then
begin
    result := project_utils.SaveProject;
end
else if command = 'get_project_info' then
begin
    result := project_utils.GetProjectInfo;
end
```

**Add schemas:**

```python
# In server/schemas.py

TOOL_SCHEMAS["create_project"] = {
    "name": "create_project",
    "description": "Create a new Altium project with a blank PCB",
    "inputSchema": {
        "type": "object",
        "properties": {
            "project_name": {
                "type": "string",
                "description": "Name of the project",
                "minLength": 1
            },
            "project_path": {
                "type": "string",
                "description": "Directory path where project will be created"
            },
            "template": {
                "type": "string",
                "description": "Project template to use",
                "enum": ["blank", "arduino", "raspberry_pi"],
                "default": "blank"
            }
        },
        "required": ["project_name", "project_path"]
    }
}

TOOL_SCHEMAS["save_project"] = {
    "name": "save_project",
    "description": "Save the currently open project",
    "inputSchema": {
        "type": "object",
        "properties": {},
        "required": []
    }
}
```

---

### Task 2.2: Library Search & Component Discovery

**Effort:** 24 hours

**New Tools:**

1. **search_components** - Search for components across libraries
2. **list_component_libraries** - List available component libraries
3. **get_component_from_library** - Get component details from library
4. **search_footprints** - Search for footprints

**DelphiScript (server/AltiumScript/library_utils.pas):**

```pascal
unit library_utils;

interface

function ListComponentLibraries: String;
function SearchComponents(const Query: String): String;
function GetComponentFromLibrary(const LibName, CompName: String): String;
function SearchFootprints(const Query: String): String;

implementation

uses
    IntegratedLibraryManager;

function ListComponentLibraries: String;
var
    LibManager: IIntegratedLibraryManager;
    LibCount, i: Integer;
    Lib: IComponentLibrary;
    JsonBuilder: TStringList;
begin
    JsonBuilder := TStringList.Create;
    try
        LibManager := IntegratedLibraryManager;
        if LibManager = nil then
        begin
            Result := '{"success": false, "message": "Library manager not available"}';
            Exit;
        end;

        JsonBuilder.Add('{');
        JsonBuilder.Add('  "success": true,');
        JsonBuilder.Add('  "libraries": [');

        LibCount := LibManager.GetLibraryCount;
        for i := 0 to LibCount - 1 do
        begin
            Lib := LibManager.GetLibrary(i);
            if Lib <> nil then
            begin
                JsonBuilder.Add('    {');
                JsonBuilder.Add('      "name": "' + Lib.GetLibraryName + '",');
                JsonBuilder.Add('      "path": "' + Lib.GetLibraryPath + '",');
                JsonBuilder.Add('      "type": "' + Lib.GetLibraryType + '"');
                JsonBuilder.Add('    }');
                if i < LibCount - 1 then
                    JsonBuilder.Add('    ,');
            end;
        end;

        JsonBuilder.Add('  ]');
        JsonBuilder.Add('}');

        Result := JsonBuilder.Text;
    finally
        JsonBuilder.Free;
    end;
end;

function SearchComponents(const Query: String): String;
var
    LibManager: IIntegratedLibraryManager;
    CompCount, i: Integer;
    CompInfo: IComponentInfo;
    JsonBuilder: TStringList;
    SearchQuery: String;
begin
    JsonBuilder := TStringList.Create;
    try
        LibManager := IntegratedLibraryManager;
        if LibManager = nil then
        begin
            Result := '{"success": false, "message": "Library manager not available"}';
            Exit;
        end;

        SearchQuery := LowerCase(Query);

        JsonBuilder.Add('{');
        JsonBuilder.Add('  "success": true,');
        JsonBuilder.Add('  "query": "' + Query + '",');
        JsonBuilder.Add('  "results": [');

        CompCount := LibManager.GetComponentCount;
        for i := 0 to CompCount - 1 do
        begin
            CompInfo := LibManager.GetComponentInfo(i);
            if CompInfo <> nil then
            begin
                // Check if component matches search query
                if (Pos(SearchQuery, LowerCase(CompInfo.GetComponentName)) > 0) or
                   (Pos(SearchQuery, LowerCase(CompInfo.GetComponentDescription)) > 0) then
                begin
                    JsonBuilder.Add('    {');
                    JsonBuilder.Add('      "name": "' + CompInfo.GetComponentName + '",');
                    JsonBuilder.Add('      "description": "' + CompInfo.GetComponentDescription + '",');
                    JsonBuilder.Add('      "library": "' + CompInfo.GetLibraryName + '",');
                    JsonBuilder.Add('      "footprint": "' + CompInfo.GetFootprint + '"');
                    JsonBuilder.Add('    },');
                end;
            end;
        end;

        // Remove trailing comma
        if JsonBuilder.Count > 4 then
            JsonBuilder[JsonBuilder.Count - 1] := StringReplace(
                JsonBuilder[JsonBuilder.Count - 1], ',', '', [rfReplaceAll]
            );

        JsonBuilder.Add('  ]');
        JsonBuilder.Add('}');

        Result := JsonBuilder.Text;
    finally
        JsonBuilder.Free;
    end;
end;

end.
```

---

## Phase 3: Design Analysis & Intelligence (Week 5-6)

### Goals
- Add DRC history tracking system
- Implement circuit pattern recognition
- Add advanced BOM analysis tools
- Implement netlist analysis

### Priority: ⭐⭐⭐ HIGH (Unique value-add)

---

### Task 3.1: DRC History Tracking

**Effort:** 16 hours

**Create server/drc_history.py:**

```python
import json
import sqlite3
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

class DRCHistoryManager:
    """Manage DRC check history and track progress over time"""

    def __init__(self, db_path: Optional[str] = None):
        if db_path is None:
            db_path = Path.home() / ".altium-mcp" / "drc_history.db"

        self.db_path = Path(db_path)
        self.db_path.parent.mkdir(parents=True, exist_ok=True)

        self._init_database()

    def _init_database(self):
        """Initialize the DRC history database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS drc_runs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                project_path TEXT NOT NULL,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                total_violations INTEGER,
                critical_count INTEGER,
                warning_count INTEGER,
                info_count INTEGER,
                violation_data TEXT
            )
        """)

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS violation_types (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                drc_run_id INTEGER,
                violation_type TEXT,
                count INTEGER,
                FOREIGN KEY (drc_run_id) REFERENCES drc_runs(id)
            )
        """)

        conn.commit()
        conn.close()

    def record_drc_run(self, project_path: str, violations: Dict) -> int:
        """Record a DRC run and return the run ID"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()

        # Count violations by severity
        critical_count = sum(1 for v in violations.get("violations", [])
                           if v.get("severity") == "critical")
        warning_count = sum(1 for v in violations.get("violations", [])
                          if v.get("severity") == "warning")
        info_count = sum(1 for v in violations.get("violations", [])
                       if v.get("severity") == "info")

        cursor.execute("""
            INSERT INTO drc_runs
            (project_path, total_violations, critical_count, warning_count, info_count, violation_data)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (
            project_path,
            len(violations.get("violations", [])),
            critical_count,
            warning_count,
            info_count,
            json.dumps(violations)
        ))

        run_id = cursor.lastrowid

        # Record violation types
        violation_counts = {}
        for v in violations.get("violations", []):
            vtype = v.get("type", "unknown")
            violation_counts[vtype] = violation_counts.get(vtype, 0) + 1

        for vtype, count in violation_counts.items():
            cursor.execute("""
                INSERT INTO violation_types (drc_run_id, violation_type, count)
                VALUES (?, ?, ?)
            """, (run_id, vtype, count))

        conn.commit()
        conn.close()

        return run_id

    def get_history(self, project_path: str, limit: int = 10) -> List[Dict]:
        """Get DRC history for a project"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()

        cursor.execute("""
            SELECT id, timestamp, total_violations, critical_count,
                   warning_count, info_count
            FROM drc_runs
            WHERE project_path = ?
            ORDER BY timestamp DESC
            LIMIT ?
        """, (project_path, limit))

        runs = []
        for row in cursor.fetchall():
            runs.append({
                "id": row[0],
                "timestamp": row[1],
                "total_violations": row[2],
                "critical": row[3],
                "warnings": row[4],
                "info": row[5]
            })

        conn.close()
        return runs

    def get_progress_report(self, project_path: str) -> Dict:
        """Generate a progress report comparing recent DRC runs"""
        history = self.get_history(project_path, limit=5)

        if len(history) < 2:
            return {
                "success": True,
                "message": "Need at least 2 DRC runs to show progress",
                "history": history
            }

        latest = history[0]
        previous = history[1]

        # Calculate changes
        total_change = latest["total_violations"] - previous["total_violations"]
        critical_change = latest["critical"] - previous["critical"]
        warning_change = latest["warnings"] - previous["warnings"]

        # Determine trend
        if total_change < 0:
            trend = "improving"
        elif total_change > 0:
            trend = "declining"
        else:
            trend = "stable"

        return {
            "success": True,
            "trend": trend,
            "latest_run": latest,
            "previous_run": previous,
            "changes": {
                "total": total_change,
                "critical": critical_change,
                "warnings": warning_change
            },
            "history": history
        }
```

**New Tool: run_drc_with_history**

```python
# In server/main.py

async def run_drc_with_history_tool(args: dict) -> dict:
    """Run DRC and track in history"""
    project_path = args.get("project_path", "")

    # Run DRC using existing Altium command
    drc_result = await call_altium_script("get_pcb_rules", {})

    if not drc_result.get("success"):
        return drc_result

    # Record in history
    history_mgr = DRCHistoryManager()
    run_id = history_mgr.record_drc_run(project_path, drc_result)

    # Get progress report
    progress = history_mgr.get_progress_report(project_path)

    return {
        "success": True,
        "drc_results": drc_result,
        "history": progress,
        "run_id": run_id
    }
```

---

### Task 3.2: Circuit Pattern Recognition

**Effort:** 24 hours

**Create server/pattern_recognition.py:**

```python
from typing import Dict, List, Optional
import re

class CircuitPatternRecognizer:
    """Recognize common circuit patterns in PCB designs"""

    POWER_SUPPLY_PATTERNS = {
        "buck_converter": {
            "components": ["inductor", "diode", "mosfet", "capacitor"],
            "min_components": 4,
            "description": "Buck DC-DC converter topology"
        },
        "boost_converter": {
            "components": ["inductor", "diode", "mosfet", "capacitor"],
            "min_components": 4,
            "description": "Boost DC-DC converter topology"
        },
        "linear_regulator": {
            "components": ["regulator_ic", "capacitor"],
            "min_components": 3,
            "description": "Linear voltage regulator"
        },
        "ldo": {
            "components": ["ldo_ic", "capacitor"],
            "min_components": 2,
            "description": "Low dropout regulator"
        }
    }

    INTERFACE_PATTERNS = {
        "usb_interface": {
            "components": ["usb_connector", "resistor", "capacitor"],
            "nets": ["USB_D+", "USB_D-", "USB_VBUS"],
            "description": "USB interface circuit"
        },
        "ethernet_interface": {
            "components": ["rj45", "transformer", "resistor"],
            "nets": ["ETH_TX", "ETH_RX"],
            "description": "Ethernet interface"
        }
    }

    FILTER_PATTERNS = {
        "rc_filter": {
            "components": ["resistor", "capacitor"],
            "min_components": 2,
            "description": "RC low-pass filter"
        },
        "lc_filter": {
            "components": ["inductor", "capacitor"],
            "min_components": 2,
            "description": "LC filter"
        }
    }

    def identify_patterns(self, components: List[Dict], nets: List[str]) -> Dict:
        """Identify circuit patterns in the design"""

        patterns_found = {
            "power_supplies": [],
            "interfaces": [],
            "filters": [],
            "other": []
        }

        # Analyze power supply patterns
        patterns_found["power_supplies"] = self._find_power_patterns(components)

        # Analyze interface patterns
        patterns_found["interfaces"] = self._find_interface_patterns(components, nets)

        # Analyze filter patterns
        patterns_found["filters"] = self._find_filter_patterns(components)

        return {
            "success": True,
            "patterns": patterns_found,
            "summary": self._generate_summary(patterns_found)
        }

    def _find_power_patterns(self, components: List[Dict]) -> List[Dict]:
        """Find power supply topologies"""
        found_patterns = []

        # Look for buck converters
        inductors = [c for c in components if self._is_inductor(c)]
        diodes = [c for c in components if self._is_diode(c)]
        mosfets = [c for c in components if self._is_mosfet(c)]
        caps = [c for c in components if self._is_capacitor(c)]

        if inductors and diodes and mosfets and len(caps) >= 2:
            found_patterns.append({
                "type": "buck_converter",
                "confidence": 0.8,
                "components": [c["designator"] for c in inductors[:1] + diodes[:1] + mosfets[:1] + caps[:2]],
                "description": "Buck DC-DC converter (switching regulator)"
            })

        # Look for linear regulators
        regulators = [c for c in components if self._is_regulator_ic(c)]
        for reg in regulators:
            found_patterns.append({
                "type": "linear_regulator",
                "confidence": 0.9,
                "components": [reg["designator"]],
                "description": f"Linear regulator: {reg.get('value', 'Unknown')}"
            })

        return found_patterns

    def _find_interface_patterns(self, components: List[Dict], nets: List[str]) -> List[Dict]:
        """Find communication interface patterns"""
        found_patterns = []

        # USB detection
        usb_nets = [n for n in nets if "USB" in n.upper()]
        usb_connectors = [c for c in components if "USB" in c.get("value", "").upper()]

        if usb_nets or usb_connectors:
            found_patterns.append({
                "type": "usb_interface",
                "confidence": 0.9,
                "nets": usb_nets,
                "components": [c["designator"] for c in usb_connectors],
                "description": "USB interface detected"
            })

        # Ethernet detection
        eth_nets = [n for n in nets if "ETH" in n.upper() or "ENET" in n.upper()]
        rj45_connectors = [c for c in components if "RJ45" in c.get("value", "").upper()]

        if eth_nets or rj45_connectors:
            found_patterns.append({
                "type": "ethernet_interface",
                "confidence": 0.9,
                "nets": eth_nets,
                "components": [c["designator"] for c in rj45_connectors],
                "description": "Ethernet interface detected"
            })

        return found_patterns

    def _is_inductor(self, component: Dict) -> bool:
        """Check if component is an inductor"""
        designator = component.get("designator", "")
        value = component.get("value", "")
        return designator.startswith("L") or "H" in value.upper()

    def _is_capacitor(self, component: Dict) -> bool:
        """Check if component is a capacitor"""
        designator = component.get("designator", "")
        return designator.startswith("C")

    def _is_diode(self, component: Dict) -> bool:
        """Check if component is a diode"""
        designator = component.get("designator", "")
        return designator.startswith("D")

    def _is_mosfet(self, component: Dict) -> bool:
        """Check if component is a MOSFET"""
        designator = component.get("designator", "")
        value = component.get("value", "")
        return designator.startswith("Q") or "MOSFET" in value.upper() or "FET" in value.upper()

    def _is_regulator_ic(self, component: Dict) -> bool:
        """Check if component is a voltage regulator IC"""
        value = component.get("value", "").upper()
        designator = component.get("designator", "")

        regulator_keywords = ["LM", "AMS1117", "7805", "LDO", "REG"]
        return designator.startswith("U") and any(kw in value for kw in regulator_keywords)

    def _generate_summary(self, patterns: Dict) -> str:
        """Generate human-readable summary of found patterns"""
        summary_parts = []

        power_count = len(patterns["power_supplies"])
        if power_count > 0:
            summary_parts.append(f"{power_count} power supply circuit(s)")

        interface_count = len(patterns["interfaces"])
        if interface_count > 0:
            summary_parts.append(f"{interface_count} interface circuit(s)")

        filter_count = len(patterns["filters"])
        if filter_count > 0:
            summary_parts.append(f"{filter_count} filter circuit(s)")

        if summary_parts:
            return "Found: " + ", ".join(summary_parts)
        else:
            return "No recognizable circuit patterns found"
```

**New Tool: identify_circuit_patterns**

```python
# In server/main.py

async def identify_circuit_patterns_tool(args: dict) -> dict:
    """Identify common circuit patterns in the design"""

    # Get all components
    components_result = await call_altium_script("get_all_designators", {})
    if not components_result.get("success"):
        return components_result

    designators = components_result.get("result", [])

    # Get component data
    components_data_result = await call_altium_script("get_component_data", {
        "cmp_designators": designators
    })
    if not components_data_result.get("success"):
        return components_data_result

    components = components_data_result.get("result", [])

    # Get nets
    nets_result = await call_altium_script("get_all_nets", {})
    if not nets_result.get("success"):
        return nets_result

    nets = nets_result.get("result", [])

    # Analyze patterns
    recognizer = CircuitPatternRecognizer()
    return recognizer.identify_patterns(components, nets)
```

---

## Phase 4: Component Operations Enhancement (Week 7)

### Goals
- Fix component placement (currently noted as broken)
- Add component array placement
- Add component alignment tools
- Add component deletion

### Priority: ⭐⭐ MEDIUM

---

### Task 4.1: Fix Component Placement

**Effort:** 16 hours

**DelphiScript (server/AltiumScript/component_placement.pas):**

```pascal
unit component_placement;

interface

uses
    PCB;

function PlaceComponent(
    const Designator, Footprint: String;
    const X, Y: Double;
    const Layer, Rotation: Integer
): String;

function DeleteComponent(const Designator: String): String;
function PlaceComponentArray(
    const Footprint, RefDes: String;
    const StartX, StartY, SpacingX, SpacingY: Double;
    const Rows, Cols: Integer
): String;
function AlignComponents(
    const Designators: TStringList;
    const Alignment: String
): String;

implementation

function PlaceComponent(
    const Designator, Footprint: String;
    const X, Y: Double;
    const Layer, Rotation: Integer
): String;
var
    Board: IPCB_Board;
    Component: IPCB_Component;
    FootprintLib: IFootprintLibrary;
    LibFootprint: IPCB_LibComponent;
begin
    Result := '';
    try
        Board := PCBServer.GetCurrentPCBBoard;
        if Board = nil then
        begin
            Result := '{"success": false, "message": "No board open"}';
            Exit;
        end;

        // Find footprint in libraries
        LibFootprint := FindFootprintInLibraries(Footprint);
        if LibFootprint = nil then
        begin
            Result := '{"success": false, "message": "Footprint not found: ' + Footprint + '"}';
            Exit;
        end;

        PCBServer.PreProcess;
        try
            // Create component
            Component := PCBServer.PCBObjectFactory(eComponentObject, eNoDimension, eCreate_Default);
            if Component = nil then
            begin
                Result := '{"success": false, "message": "Failed to create component"}';
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
            CopyFootprintPrimitives(LibFootprint, Component);

            // Add to board
            Board.AddPCBObject(Component);

            PCBServer.SendMessageToRobots(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Component.I_ObjectAddress);

            Result := '{"success": true, "designator": "' + Designator + '"}';
        finally
            PCBServer.PostProcess;
        end;

        // Refresh view
        Client.SendMessage('PCB:Zoom', 'Action=Redraw', 255, Client.CurrentView);

    except
        on E: Exception do
            Result := '{"success": false, "message": "' + E.Message + '"}';
    end;
end;

function CopyFootprintPrimitives(LibFootprint: IPCB_LibComponent; Component: IPCB_Component): Boolean;
var
    Iterator: IPCB_GroupIterator;
    Primitive: IPCB_Primitive;
    NewPrimitive: IPCB_Primitive;
begin
    Result := True;
    try
        Iterator := LibFootprint.GroupIterator_Create;
        Iterator.AddFilter_ObjectSet(MkSet(eTrackObject, eArcObject, ePadObject, eTextObject, eFillObject));

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

function DeleteComponent(const Designator: String): String;
var
    Board: IPCB_Board;
    Component: IPCB_Component;
begin
    Result := '';
    try
        Board := PCBServer.GetCurrentPCBBoard;
        if Board = nil then
        begin
            Result := '{"success": false, "message": "No board open"}';
            Exit;
        end;

        // Find component
        Component := Board.GetPcbComponentByRefDes(Designator);
        if Component = nil then
        begin
            Result := '{"success": false, "message": "Component not found: ' + Designator + '"}';
            Exit;
        end;

        PCBServer.PreProcess;
        try
            // Remove component
            Board.RemovePCBObject(Component);
            PCBServer.DestroyPCBObject(Component);

            Result := '{"success": true, "message": "Component deleted"}';
        finally
            PCBServer.PostProcess;
        end;

        // Refresh
        Client.SendMessage('PCB:Zoom', 'Action=Redraw', 255, Client.CurrentView);

    except
        on E: Exception do
            Result := '{"success": false, "message": "' + E.Message + '"}';
    end;
end;

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
begin
    JsonBuilder := TStringList.Create;
    try
        JsonBuilder.Add('{');
        JsonBuilder.Add('  "success": true,');
        JsonBuilder.Add('  "components": [');

        for Row := 0 to Rows - 1 do
        begin
            for Col := 0 to Cols - 1 do
            begin
                // Calculate position
                X := StartX + (Col * SpacingX);
                Y := StartY + (Row * SpacingY);

                // Generate designator (e.g., R1, R2, R3...)
                Designator := RefDes + IntToStr(Row * Cols + Col + 1);

                // Place component
                PlaceResult := PlaceComponent(Designator, Footprint, X, Y, 0, 0);

                JsonBuilder.Add('    "' + Designator + '",');
            end;
        end;

        // Remove trailing comma
        if JsonBuilder.Count > 3 then
            JsonBuilder[JsonBuilder.Count - 1] := StringReplace(
                JsonBuilder[JsonBuilder.Count - 1], ',', '', [rfReplaceAll]
            );

        JsonBuilder.Add('  ]');
        JsonBuilder.Add('}');

        Result := JsonBuilder.Text;
    finally
        JsonBuilder.Free;
    end;
end;

function AlignComponents(
    const Designators: TStringList;
    const Alignment: String
): String;
var
    Board: IPCB_Board;
    Components: array of IPCB_Component;
    i: Integer;
    AlignCoord: TCoord;
    Component: IPCB_Component;
begin
    Result := '';
    try
        Board := PCBServer.GetCurrentPCBBoard;
        if Board = nil then
        begin
            Result := '{"success": false, "message": "No board open"}';
            Exit;
        end;

        // Get all components
        SetLength(Components, Designators.Count);
        for i := 0 to Designators.Count - 1 do
        begin
            Components[i] := Board.GetPcbComponentByRefDes(Designators[i]);
            if Components[i] = nil then
            begin
                Result := '{"success": false, "message": "Component not found: ' + Designators[i] + '"}';
                Exit;
            end;
        end;

        // Calculate alignment coordinate
        if Alignment = 'left' then
        begin
            AlignCoord := Components[0].x;
            for i := 1 to Length(Components) - 1 do
                if Components[i].x < AlignCoord then
                    AlignCoord := Components[i].x;
        end
        else if Alignment = 'right' then
        begin
            AlignCoord := Components[0].x;
            for i := 1 to Length(Components) - 1 do
                if Components[i].x > AlignCoord then
                    AlignCoord := Components[i].x;
        end
        else if Alignment = 'top' then
        begin
            AlignCoord := Components[0].y;
            for i := 1 to Length(Components) - 1 do
                if Components[i].y > AlignCoord then
                    AlignCoord := Components[i].y;
        end
        else if Alignment = 'bottom' then
        begin
            AlignCoord := Components[0].y;
            for i := 1 to Length(Components) - 1 do
                if Components[i].y < AlignCoord then
                    AlignCoord := Components[i].y;
        end;

        // Apply alignment
        PCBServer.PreProcess;
        try
            for i := 0 to Length(Components) - 1 do
            begin
                Component := Components[i];
                if (Alignment = 'left') or (Alignment = 'right') then
                    Component.x := AlignCoord
                else
                    Component.y := AlignCoord;
            end;
        finally
            PCBServer.PostProcess;
        end;

        Result := '{"success": true, "message": "Components aligned"}';

    except
        on E: Exception do
            Result := '{"success": false, "message": "' + E.Message + '"}';
    end;
end;

end.
```

---

## Phase 5: Board & Routing Tools (Week 8)

### Goals
- Add board initialization tools (size, outline, text, holes)
- Add trace routing capabilities
- Add via placement
- Add copper pour/zone management

### Priority: ⭐⭐ MEDIUM

---

### Task 5.1: Board Initialization Tools

**Effort:** 20 hours

**Create server/AltiumScript/board_init.pas**

---

## Implementation Checklist

### Phase 1: MCP Protocol Modernization ✓
- [ ] Add MCP Resources capability (8 resources)
- [ ] Create JSON Schema definitions for all 23 existing tools
- [ ] Add 3 Prompt templates
- [ ] Update to MCP 2.1 protocol with JSON-RPC 2.0
- [ ] Test resource reading and prompt invocation

### Phase 2: Project Management ✓
- [ ] Implement create_project tool
- [ ] Implement save_project tool
- [ ] Enhance get_project_info tool
- [ ] Implement search_components tool
- [ ] Implement list_component_libraries tool
- [ ] Add DelphiScript library_utils.pas module
- [ ] Test project lifecycle

### Phase 3: Design Analysis ✓
- [ ] Create DRCHistoryManager class
- [ ] Implement SQLite database for tracking
- [ ] Add run_drc_with_history tool
- [ ] Create CircuitPatternRecognizer class
- [ ] Implement pattern detection algorithms
- [ ] Add identify_circuit_patterns tool
- [ ] Test pattern recognition on sample boards

### Phase 4: Component Operations ✓
- [ ] Fix PlaceComponent in DelphiScript
- [ ] Implement footprint library search
- [ ] Implement DeleteComponent
- [ ] Implement PlaceComponentArray
- [ ] Implement AlignComponents
- [ ] Add component_placement.pas module
- [ ] Test all component operations

### Phase 5: Board & Routing ✓
- [ ] Implement set_board_size tool
- [ ] Implement add_board_outline tool
- [ ] Implement add_mounting_hole tool
- [ ] Implement add_board_text tool
- [ ] Implement route_trace tool
- [ ] Implement add_via tool
- [ ] Implement add_copper_pour tool
- [ ] Create board_init.pas and routing.pas modules
- [ ] Test board creation workflow

---

## Testing Strategy

### Unit Tests
```python
# tests/test_resources.py
import pytest
from server.main import read_resource

@pytest.mark.asyncio
async def test_project_info_resource():
    result = await read_resource("altium://project/current/info")
    assert result is not None
    assert "name" in result

# tests/test_drc_history.py
from server.drc_history import DRCHistoryManager

def test_record_drc_run():
    mgr = DRCHistoryManager(":memory:")
    run_id = mgr.record_drc_run("/test/project", {"violations": []})
    assert run_id > 0

# tests/test_pattern_recognition.py
from server.pattern_recognition import CircuitPatternRecognizer

def test_identify_buck_converter():
    components = [
        {"designator": "L1", "value": "10uH"},
        {"designator": "D1", "value": "Diode"},
        {"designator": "Q1", "value": "MOSFET"},
        {"designator": "C1", "value": "10uF"},
        {"designator": "C2", "value": "100uF"}
    ]
    recognizer = CircuitPatternRecognizer()
    result = recognizer.identify_patterns(components, [])
    assert len(result["patterns"]["power_supplies"]) > 0
```

### Integration Tests
```python
# tests/integration/test_workflow.py

async def test_full_project_workflow():
    # Create project
    result = await call_tool("create_project", {
        "project_name": "TestBoard",
        "project_path": "/tmp/test"
    })
    assert result["success"]

    # Place components
    result = await call_tool("place_component_array", {
        "footprint": "0805",
        "ref_des": "R",
        "start_x": 0,
        "start_y": 0,
        "spacing_x": 5,
        "spacing_y": 5,
        "rows": 2,
        "cols": 2
    })
    assert result["success"]

    # Run DRC with history
    result = await call_tool("run_drc_with_history", {
        "project_path": "/tmp/test"
    })
    assert result["success"]
    assert "history" in result
```

---

## Documentation Updates

### README.md Updates
```markdown
## New Features in v2.0

### MCP 2.1 Protocol Support
- **Resources**: Read-only access to project state
- **Prompts**: Guided workflows for common tasks
- **JSON Schema**: Full validation for all 46 tools (23 original + 23 new)

### Design Analysis
- **DRC History Tracking**: Track design rule violations over time
- **Circuit Pattern Recognition**: Automatically identify power supplies, interfaces, filters
- **Progress Monitoring**: See how your design improves with each iteration

### Project Management
- Create and manage Altium projects programmatically
- Search component libraries
- Advanced BOM analysis

### Enhanced Component Operations
- Fixed component placement (now working reliably!)
- Component arrays with automatic designator assignment
- Component alignment tools
- Component deletion

### Board Design Tools
- Board initialization (size, outline, mounting holes)
- Trace routing with constraints
- Via placement
- Copper pour management
```

---

## Migration Guide

For users upgrading from v1.x:

1. **Backup**: All existing tools remain functional
2. **Configuration**: No config changes required
3. **New Features**: Opt-in to new resources and prompts
4. **Breaking Changes**: None - fully backward compatible

---

## Performance Targets

- Resource reads: < 500ms
- Tool execution: < 2s (simple operations)
- Tool execution: < 10s (complex operations like pattern recognition)
- DRC history query: < 100ms
- Database operations: < 50ms

---

## Estimated Timeline

| Phase | Duration | Cumulative |
|-------|----------|------------|
| Phase 1: MCP Protocol | 2 weeks | 2 weeks |
| Phase 2: Project Management | 2 weeks | 4 weeks |
| Phase 3: Design Analysis | 2 weeks | 6 weeks |
| Phase 4: Component Operations | 1 week | 7 weeks |
| Phase 5: Board & Routing | 1 week | 8 weeks |
| Testing & Documentation | 1-2 weeks | 9-10 weeks |
| Buffer for issues | 1-2 weeks | 10-12 weeks |

**Total: 8-12 weeks**

---

## Success Metrics

- ✓ All 23 existing tools have JSON schemas
- ✓ 8 resources providing project state
- ✓ 3+ prompt templates for common workflows
- ✓ DRC history database tracking violations
- ✓ Pattern recognition identifies 5+ circuit types
- ✓ Component placement reliability > 95%
- ✓ Test coverage > 70%
- ✓ Documentation for all new features

---

## Next Steps

1. **Week 1**: Start with Task 1.1 - Implement Resources
2. **Review**: After Phase 1, review with users for feedback
3. **Iterate**: Adjust priorities based on user needs
4. **Release**: Beta release after Phase 3 (core value features)
5. **Full Release**: After all phases complete with testing

---

## Questions for Discussion

1. Which phase should we prioritize if timeline is tight?
2. Are there specific circuit patterns to recognize beyond those listed?
3. Should we add cross-platform support (Linux/macOS)?
4. Do you want automated testing in CI/CD?
5. Should we create video tutorials for new features?
