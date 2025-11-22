# Altium DelphiScript API Tools

Evidence-based toolkit for working with Altium's DelphiScript API, extracted from 128 working community scripts.

## The Problem

Altium's DelphiScript API documentation is sparse. AI tools (including me) hallucinate non-existent methods like:
- ❌ `Component.SetPosition()` (doesn't exist)
- ❌ `Board.AddComponent()` (doesn't exist)
- ❌ `Pin.SetLocation()` (doesn't exist)

## The Solution

Parse all working example scripts and extract **only verified API patterns**.

---

## Quick Start

### 1. Generate API Reference (one-time setup)

```bash
# Generate comprehensive API reference from example scripts
python enhanced_api_parser.py
```

**Output:**
- `altium_api_enhanced.json` - Complete API reference (82 types, 224 methods, 1254 properties)

---

## Tools

### 1. **API Command-Line Interface** (`altium_api_cli.py`)

Main tool for exploring the API:

```bash
# Show statistics
python altium_api_cli.py stats

# List all types
python altium_api_cli.py list

# List PCB types only
python altium_api_cli.py list IPCB

# Show specific type
python altium_api_cli.py show IPCB_Component

# Search for methods/properties
python altium_api_cli.py search MoveToXY

# Validate script
python altium_api_cli.py validate my_script.pas
```

**Example Output:**
```
$ python altium_api_cli.py show IPCB_Component

IPCB_Component
======================================================================

Methods (14):
  IPCB_Component.MoveToXY(...);        ✓ Verified
  IPCB_Component.MoveByXY(...);        ✓ Verified
  IPCB_Component.LoadFromLibrary(...); ✓ Verified

Properties (38):
  IPCB_Component.X
  IPCB_Component.Y
  IPCB_Component.Rotation
  IPCB_Component.Layer
```

### 2. **Script Validator** (`validate_delphiscript.py`)

Catch API errors before running in Altium:

```bash
python validate_delphiscript.py my_script.pas
```

**Example:**
```delphi
// This code:
Component.SetPosition(10, 20);  // ❌ Wrong!

// Validator output:
ERROR: Method 'SetPosition' not found on IPCB_Component
Did you mean: MoveToXY, MoveByXY
```

### 3. **API Search** (`search_altium_api.py`)

Quick lookups:

```bash
python search_altium_api.py PCBServer
python search_altium_api.py --pattern "Iterator"
python search_altium_api.py --pcb
```

---

## API Reference Highlights

### PCB API

**IPCB_Board (60 members)**
```delphi
Board : IPCB_Board;
Board := PCBServer.GetCurrentPCBBoard;

// Methods
Board.AddPCBObject(Component);
Board.GetObjectAtCursor(MkSet(eComponentObject), AllLayers, 'Select');
Board.BoardIterator_Create;

// Properties
Board.CurrentLayer := eTopLayer;
Board.LayerStack
Board.XOrigin, Board.YOrigin
```

**IPCB_Component (52 members)**
```delphi
Component : IPCB_Component;

// Methods
Component.MoveToXY(100, 200);        // ✓ Real method
Component.MoveByXY(10, 10);          // ✓ Real method
Component.LoadFromLibrary(...);      // ✓ Real method

// Properties
Component.Rotation := 90.0;
Component.Layer := eTopLayer;
Component.X, Component.Y
Component.Name, Component.Comment
```

### Schematic API

**ISch_Component**
```delphi
Comp : ISch_Component;

// Properties
Comp.Comment.CalculatedValueString
Comp.FullPartDesignator(0)
Comp.Selection
```

**ISch_Iterator**
```delphi
Iterator : ISch_Iterator;
Iterator := Sheet.SchIterator_Create;
Iterator.SetState_FilterAll;
Iterator.AddFilter_ObjectSet(FilterSet);

Obj := Iterator.FirstSCHObject;
while Obj <> nil do
begin
    // Process object
    Obj := Iterator.NextSchObject;
end;

Sheet.SchIterator_Destroy(Iterator);
```

---

## Verified Patterns

### Component Movement
```delphi
// ✓ CORRECT
Component.MoveToXY(x, y);
Component.Rotation := angle;

// ❌ WRONG (hallucinated)
Component.SetPosition(x, y);
Component.SetRotation(angle);
```

### Getting Current Board
```delphi
// ✓ CORRECT
Board := PCBServer.GetCurrentPCBBoard;

// ❌ WRONG
Board := PCBServer.GetBoard;
```

### Iterating Objects
```delphi
// ✓ CORRECT
Iterator := Board.BoardIterator_Create;
Iterator.AddFilter_ObjectSet(MkSet(eComponentObject));
Obj := Iterator.FirstPCBObject;
while Obj <> nil do
begin
    // Process
    Obj := Iterator.NextPCBObject;
end;
Board.BoardIterator_Destroy(Iterator);
```

---

## Statistics

**Extracted from:**
- 128 DelphiScript files
- Multiple script categories (PCB, SCH, General, Examples)

**API Coverage:**
- 82 API types
- 224 methods
- 1,254 properties
- 30 constants

**Categories:**
- 58 PCB types (IPCB_*)
- 16 Schematic types (ISch_*)
- Common types (Board, Component, Iterator, Project, Document)

---

## Integration with Claude/AI

When generating DelphiScript:

1. **Always check first:**
   ```bash
   python altium_api_cli.py show IPCB_Component
   ```

2. **Validate generated code:**
   ```bash
   python altium_api_cli.py validate generated_script.pas
   ```

3. **Search for similar methods:**
   ```bash
   python altium_api_cli.py search SetPosition
   ```

---

## Files Generated

```
altium_api_enhanced.json      # Complete API reference (JSON)
ALTIUM_API_REFERENCE.md       # Human-readable reference
altium_api_cli.py             # Main CLI tool
validate_delphiscript.py      # Script validator
enhanced_api_parser.py        # Parser (rerun to update)
search_altium_api.py          # Search utility
altium_api_helper.py          # Python library for programmatic use
```

---

## Future Enhancements

1. **Add parameter signatures** - Extract method parameters from examples
2. **Add return types** - Infer return types from usage
3. **Add examples per method** - Link to working code snippets
4. **Tree-sitter integration** - Use proper AST parsing
5. **Online documentation links** - Cross-reference official docs when available

---

## License

Tools are open source. Example scripts are from the community scripts-libraries repository.
