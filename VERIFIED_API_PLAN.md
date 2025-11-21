# Verified Altium API Plan for New Features

This document contains **verified** Altium API calls extracted from real working examples in `scripts-libraries/`. Every API call, object type, and member name listed here has been confirmed to exist and work.

## Feature 1: Schematic-PCB Sync Checker

### Goal
Compare schematic components with PCB components to find:
- Components in schematic but missing from PCB
- Components in PCB but missing from schematic
- Designator mismatches
- Parameter mismatches

### Verified API Calls (from ParamsToPCB.pas, GetPinData.pas)

```pascal
// Get Workspace and Project
Workspace := GetWorkspace;
Project := Workspace.DM_FocusedProject;

// Compile project (REQUIRED before accessing DM_DocumentFlattened)
Project.DM_Compile;

// Get flattened hierarchy (schematic side)
FlatHierarchy := Project.DM_DocumentFlattened;
if FlatHierarchy = Nil then
    // Project not compiled

// Iterate schematic components
for ComponentNum := 0 to FlatHierarchy.DM_ComponentCount - 1 do
begin
    Component := FlatHierarchy.DM_Components(ComponentNum);

    // Get component properties
    UniqueId := Component.DM_UniqueId;           // String

    // Get component parameters
    for ParamNum := 0 to Component.DM_ParameterCount - 1 do
    begin
        Parameter := Component.DM_Parameters(ParamNum);
        ParamName := Parameter.DM_Name;          // String
        ParamValue := Parameter.DM_Value;        // String
    end;
end;

// Get PCB Board
Board := PCBServer.GetCurrentPCBBoard;

// Iterate PCB components (using existing GetAllComponentData approach)
Iterator := Board.BoardIterator_Create;
Iterator.AddFilter_ObjectSet(MkSet(eComponentObject));
Component := Iterator.FirstPCBObject;
while Component <> Nil do
begin
    // Match with schematic using:
    SourceUniqueId := Component.SourceUniqueId;  // Matches Component.DM_UniqueId from schematic
    Designator := Component.Name.Text;

    Component := Iterator.NextPCBObject;
end;
Board.BoardIterator_Destroy(Iterator);
```

### Object Types
- `IWorkspace` - Workspace interface
- `IProject` - Project interface
- `IDocument` - Flattened hierarchy
- `IComponent` - Schematic component
- `IParameter` - Component parameter
- `IPCB_Board` - PCB board
- `IPCB_Component` - PCB component
- `IPCB_BoardIterator` - PCB iterator

### Implementation Plan
1. **DelphiScript function**: `GetSchematicPCBSync(ROOT_DIR: String): String`
   - Compile project
   - Get flattened hierarchy
   - Build map of schematic components: `UniqueId -> Designator, Parameters`
   - Get all PCB components via existing `GetAllComponentData`
   - Build map of PCB components: `SourceUniqueId -> Designator`
   - Compare maps and report mismatches as JSON

2. **Python tool**: `check_schematic_pcb_sync()`
   - Call DelphiScript function
   - Parse results
   - Return formatted report

---

## Feature 2: Component Parameter Export for BOM

### Goal
Export all component parameters from schematic to enable:
- External BOM analysis
- Parameter-based queries
- Integration with procurement databases

### Verified API Calls (from ParamsToPCB.pas)

```pascal
// Already covered above - same approach as sync checker
// The key is using FlatHierarchy.DM_Components and accessing DM_Parameters

// Additional: Get component library reference
Component.DM_LibReference;           // Library reference string
Component.DM_Description;            // Component description
```

### Implementation Plan
1. **DelphiScript function**: `GetSchematicComponentsWithParameters(ROOT_DIR: String): String`
   - Compile project
   - Get flattened hierarchy
   - For each component, export:
     - Designator
     - LibReference
     - Description
     - All parameters as key-value pairs
   - Return as JSON array

2. **Python tool**: `export_bom_with_parameters()`
   - Call DelphiScript function
   - Parse component data
   - Save as CSV/JSON for external tools
   - Can integrate with Octopart/Digi-Key APIs

---

## Feature 3: Enhanced Project Info

### Goal
Provide comprehensive project information including:
- All documents (SCH, PCB, etc.)
- Document paths and types
- Project output path

### Verified API Calls (from InteractiveHTMLBOM4Altium2.pas)

```pascal
// Get project
Project := GetWorkspace.DM_FocusedProject;

// Get project info
ProjectFileName := Project.DM_ProjectFileName;   // Full path to .PrjPcb
OutputPath := Project.DM_GetOutputPath;          // Output folder path

// Iterate documents
for i := 0 to Project.DM_LogicalDocumentCount - 1 do
begin
    Document := Project.DM_LogicalDocuments(i);

    DocumentKind := Document.DM_DocumentKind;    // 'PCB', 'SCH', etc.
    DocumentPath := Document.DM_FullPath;        // Full path to document
end;
```

### Implementation Plan
1. **DelphiScript function**: `GetEnhancedProjectInfo(ROOT_DIR: String): String`
   - Get project
   - Export project filename, output path
   - List all documents with types and paths
   - Return as JSON

2. **Python tool**: Update existing `get_project_info` to include documents list

---

## Feature 4: Open Document

### Goal
Programmatically open and show documents

### Verified API Calls (from HideShowParameters.pas)

```pascal
// Open document
Document := Client.OpenDocument('Sch', FullPath);  // Type: 'Sch', 'PCB', etc.

// Show document
Client.ShowDocument(Document);
```

### Implementation Plan
1. **DelphiScript function**: `OpenDocumentByPath(DocumentPath: String; DocumentType: String): String`
   - Call `Client.OpenDocument(DocumentType, DocumentPath)`
   - Call `Client.ShowDocument(Document)`
   - Return success/error

2. **Python tool**: `open_document(document_path: str, document_type: str)`

---

## Implementation Priority

1. **Schematic-PCB Sync Checker** (2 hours)
   - Highest value, prevents errors
   - All APIs verified and understood

2. **Component Parameter Export** (1 hour)
   - Enables BOM intelligence in Python
   - Simple extension of sync checker code

3. **Enhanced Project Info** (30 min)
   - Low complexity
   - Useful utility

4. **Open Document** (30 min)
   - Simple utility function

---

## Key Learnings from Examples

1. **ALWAYS call `Project.DM_Compile` before accessing `DM_DocumentFlattened`**
2. Use `Component.DM_UniqueId` (sch) ↔ `PCBComponent.SourceUniqueId` (PCB) for matching
3. Use iterators properly: Create → Use → Destroy
4. Check for nil before using interfaces
5. Use `MkSet()` for filter sets (e.g., `MkSet(eComponentObject)`)

---

## References

- `scripts-libraries/Scripts - General/ParamsToPCB/ParamsToPCB.pas` - Parameter access
- `scripts-libraries/Scripts - SCH/GetPinData/GetPinData.pas` - Net and pin access
- `scripts-libraries/Scripts - SCH/HideShowParametersSch/HideShowParameters.pas` - Document iteration
- `scripts-libraries/Scripts - Outputs/InteractiveHTMLBOM4Altium2/InteractiveHTMLBOM4Altium2.pas` - Project structure
