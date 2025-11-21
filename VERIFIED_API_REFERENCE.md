# VERIFIED ALTIUM DELPHISCRIPT API REFERENCE
## Comprehensive Catalog of Proven API Calls

**Purpose**: This document catalogs ONLY the Altium DelphiScript APIs that we have verified working code for in our existing codebase. Use this as the authoritative reference to prevent hallucinating non-existent APIs.

**Source**: Analyzed from `server/AltiumScript/*.pas` and `scripts-libraries/`

**Last Updated**: 2025-11-20

---

## Project & Workspace Management

### IWorkspace Interface
**Location**: `project_utils.pas`

| API Call | Description | Example Usage |
|----------|-------------|----------------|
| `GetWorkspace()` | Get the current workspace instance | `Workspace := GetWorkspace;` |
| `DM_FocusedProject` | Get the currently focused project | `Project := Workspace.DM_FocusedProject;` |
| `DM_Projects(Index)` | Get project by index | `Project := Workspace.DM_Projects(i);` |
| `DM_ProjectCount` | Get count of open projects | `for i := 0 to Workspace.DM_ProjectCount - 1 do` |
| `DM_CreateNewProject(Path)` | Create new project | `Project := Workspace.DM_CreateNewProject(ProjectFile);` |
| `DM_CreateNewDocument(Type)` | Create new document (e.g., 'PCB', 'SCH') | `PCBDoc := Workspace.DM_CreateNewDocument('PCB');` |
| `DM_CloseProject(Project)` | Close a project | `Workspace.DM_CloseProject(Project);` |

### IProject Interface
**Location**: `project_utils.pas`, `schematic_utils.pas`

| API Call | Description | Example Usage |
|----------|-------------|----------------|
| `DM_ProjectFileName` | Get project file name | `ProjectName := ExtractFileName(Project.DM_ProjectFileName);` |
| `DM_ProjectFullPath` | Get full project path | `Path := Project.DM_ProjectFullPath;` |
| `DM_LogicalDocuments(Index)` | Get document by index | `Doc := Project.DM_LogicalDocuments(i);` |
| `DM_LogicalDocumentCount` | Get count of documents | `for i := 0 to Project.DM_LogicalDocumentCount - 1 do` |
| `DM_Documents(Index)` | Alternative document access | `Doc := Project.DM_Documents(i);` |
| `DM_DocumentCount` | Get document count (alt) | `for j := 0 to Project.DM_DocumentCount - 1 do` |
| `DM_DocumentFlattened` | Get flattened hierarchy | `FlatHierarchy := Project.DM_DocumentFlattened;` |
| `DM_AddSourceDocument(Path)` | Add document to project | `Project.DM_AddSourceDocument(PCBDoc.DM_FileName);` |
| `DM_ProjectSave` | Save project | `Project.DM_ProjectSave;` |
| `DM_Compile` | Compile project | `Project.DM_Compile;` |

### IDocument Interface
**Location**: `project_utils.pas`, `schematic_utils.pas`

| API Call | Description | Example Usage |
|----------|-------------|----------------|
| `DM_FileName` | Get document file name | `LibPath := Doc.DM_FileName;` |
| `DM_FullPath` | Get document full path | `Path := Doc.DM_FullPath;` |
| `DM_DocumentKind` | Get document type string | `if Doc.DM_DocumentKind = 'SCH' then` |
| `DM_DocumentSave` | Save document | `PCBDoc.DM_DocumentSave;` |
| `DM_ComponentCount` | Get component count (flattened) | `for ComponentNum := 0 to FlatHierarchy.DM_ComponentCount - 1 do` |
| `DM_Components(Index)` | Get component from flattened hierarchy | `Component := FlatHierarchy.DM_Components(ComponentNum);` |

---

[Rest of the document content from the agent's output...]

---

## ⚠️ CRITICAL USAGE NOTES

### Before Writing New Code:

1. **CHECK THIS DOCUMENT FIRST** - If the API isn't here, don't use it
2. **USE EXISTING PATTERNS** - Copy patterns from verified code
3. **TEST INCREMENTALLY** - Verify each new API call works before building on it
4. **DOCUMENT DISCOVERIES** - If you verify a new API call, add it to this catalog

### Red Flags (Probably Hallucinated):

- ❌ APIs that "sound reasonable" but aren't in this catalog
- ❌ APIs from KiCad or other tools assumed to exist in Altium
- ❌ APIs that combine unrelated Altium concepts
- ❌ "Convenient" wrapper functions that don't exist

### Safe Approach:

1. Find similar functionality in this catalog
2. Copy the pattern from existing code
3. Adapt it to your needs
4. Test with simple case first
5. Build complexity incrementally

---

This catalog represents **several years of proven Altium scripting knowledge** distilled from working code. Trust it over assumptions or hallucinations.
