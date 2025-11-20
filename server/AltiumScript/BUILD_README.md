# Altium Script Build System

## Overview

This directory contains a modular Altium script codebase that uses Pascal units for organization during development, but compiles to a single Altium-compatible script file.

## Why?

Altium's scripting system doesn't support Pascal units (`unit`/`interface`/`implementation`). However, we want to maintain modular code for:
- Better organization
- Easier maintenance
- Reusable components
- Version control friendly structure

## How It Works

1. **Source Files** - Write code in modular `.pas` files with standard Pascal unit structure
2. **Build Script** - Run `build_script.py` to combine everything
3. **Output** - `Altium_API.pas` is generated in the format Altium expects

## File Structure

```
AltiumScript/
├── build_script.py          # Build tool
├── Altium_API.PrjScr         # Altium project file
├── Altium_API.pas            # 🔴 GENERATED - Don't edit!
│
├── globals.pas               # Global variables and constants
├── json_utils.pas            # JSON handling utilities
├── helpers.pas               # Helper functions
├── pcb_utils.pas             # PCB utility functions
├── component_placement.pas   # Component placement functions
├── routing.pas               # Routing functions
├── library_utils.pas         # Library functions
├── schematic_utils.pas       # Schematic functions
├── other_utils.pas           # Miscellaneous utilities
├── pcb_layout_duplicator.pas # Layout duplication
├── project_utils.pas         # Project management
├── board_init.pas            # Board initialization
├── command_router.pas        # Command routing
└── command_executors_*.pas   # Command executor modules
```

## Usage

### Development Workflow

1. **Edit source files** - Make changes to the modular `.pas` files
2. **Build** - Run the build script:
   ```bash
   cd server/AltiumScript
   python build_script.py
   ```
3. **Test in Altium** - Open `Altium_API.PrjScr` in Altium and run

### Build Script

The build script (`build_script.py`) does the following:

1. **Scans** all `.pas` files (except output and backups)
2. **Parses** each file to extract:
   - Function/procedure signatures
   - Implementation code
   - Dependencies
3. **Orders** files based on dependencies
4. **Generates** forward declarations for all functions
5. **Combines** everything into a single `Altium_API.pas` with:
   - Header comments
   - Uses clause
   - Global variables
   - Global constants
   - Forward declarations
   - All implementations

### What Gets Generated

The generated `Altium_API.pas` looks like:

```pascal
// Altium_API.pas
// Auto-generated combined script - DO NOT EDIT DIRECTLY

uses
    PCB, SCH, Workspace, Classes, SysUtils;

var
    RequestData : TStringList;
    ResponseData : TStringList;
    // ... more globals

const
    constScriptProjectName = 'Altium_API';
    // ... more constants

// ============================================================================
// FORWARD DECLARATIONS
// ============================================================================

// From globals.pas
function GetPCBServer: IPCB_ServerInterface; forward;
// ... more forwards

// ============================================================================
// IMPLEMENTATIONS
// ============================================================================

// From globals.pas
function GetPCBServer: IPCB_ServerInterface;
begin
    Result := PCBServer;
end;
// ... more implementations
```

## Important Notes

### ⚠️ DO NOT EDIT `Altium_API.pas` DIRECTLY

The `Altium_API.pas` file is **auto-generated**. Any manual edits will be overwritten on the next build.

Always edit the source `.pas` files instead.

### Source File Requirements

When writing source files, keep them as standard Pascal units:

```pascal
unit my_module;

interface

uses
    Classes, SysUtils, PCB, json_utils, globals;

function MyFunction(Param: String): String;

implementation

function MyFunction(Param: String): String;
begin
    Result := 'Hello ' + Param;
end;

end.
```

The build script will automatically:
- Strip `unit`/`interface`/`implementation` keywords
- Convert function declarations to forward declarations
- Combine all code properly

### Accessing Altium API

In source files, you can still use wrapper functions:
```pascal
Board := GetPCBServer.GetCurrentPCBBoard;
```

The build script will handle converting these as needed.

## Troubleshooting

### Build Fails

- Check Python is installed (Python 3.6+)
- Verify all source files are valid Pascal syntax
- Check for circular dependencies

### Altium Compilation Errors

- Make sure `Altium_API.pas` is up to date (run build script)
- Check the generated file for obvious issues
- Verify forward declarations match implementations

### "Can't access top level variable" Errors

This error occurs when trying to use Pascal units in Altium. Make sure:
1. You ran the build script
2. You're opening `Altium_API.pas` (not a unit file) in Altium
3. The build script completed successfully

## Future Improvements

- [ ] Automatic build on file change (file watcher)
- [ ] Better dependency resolution
- [ ] Validation of generated output
- [ ] Source map generation for debugging
- [ ] Integration with Altium's script project system
