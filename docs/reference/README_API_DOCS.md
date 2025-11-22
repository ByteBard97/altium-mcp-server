# Altium DelphiScript API Documentation System

**Evidence-based API documentation extracted from 128 working DelphiScript examples**

This system solves the problem of hallucinated/non-existent Altium API methods by building comprehensive documentation directly from verified working code.

---

## 🎯 The Problem

Altium's DelphiScript API documentation is sparse. LLMs (including Claude) frequently hallucinate non-existent methods:

❌ **Common Hallucinations:**
```delphi
Component.SetPosition(x, y)        // Doesn't exist!
Component.SetRotation(angle)       // Doesn't exist!
Board.AddComponent(comp)           // Doesn't exist!
Pin.SetLocation(x, y)              // Doesn't exist!
```

✅ **Real API:**
```delphi
Component.MoveToXY(x, y)           // ✓ Verified
Component.Rotation := angle        // ✓ Verified
Board.AddPCBObject(comp)           // ✓ Verified
```

---

## 🛠️ The Solution

We built a comprehensive toolkit that:

1. **Parses all working examples** - Tokenizes and analyzes 128 DelphiScript files
2. **Extracts verified patterns** - Only includes methods/properties that actually exist
3. **Captures usage examples** - Shows real code from working scripts
4. **Validates new code** - Catches hallucinations before running in Altium
5. **Generates LLM-friendly docs** - Creates comprehensive reference documentation

---

## 📊 What We Extracted

**From 128 working scripts:**
- ✅ **82 API types** (IPCB_*, ISch_*, etc.)
- ✅ **224 methods** with signatures
- ✅ **1,254 properties** with usage examples
- ✅ **30 constants** (eTopLayer, eComponentObject, etc.)
- ✅ **20,660 lines** of comprehensive documentation

**Categories:**
- 58 PCB types (IPCB_Board, IPCB_Component, IPCB_Track, etc.)
- 16 Schematic types (ISch_Component, ISch_Pin, ISch_Sheet, etc.)
- Common types (Project, Document, Iterator, Net, etc.)

---

## 🚀 Quick Start

### 1. Generate API Reference (One-Time Setup)

```bash
# Parse all example scripts and extract API patterns
python enhanced_api_parser.py

# Generate comprehensive documentation
python build_api_docs.py

# Create consolidated LLM-friendly reference
python consolidate_docs.py
```

**Output Files:**
- `altium_api_enhanced.json` - Complete API reference (JSON)
- `docs/api/` - Structured documentation (79 type docs + overviews)
- `ALTIUM_API_COMPLETE_REFERENCE.md` - Single consolidated file (250KB, 20,660 lines)

---

## 📚 Documentation Structure

### For Humans:
```
docs/api/
├── index.md                    # Main index with all types
├── pcb-api.md                  # PCB API overview
├── schematic-api.md            # Schematic API overview
├── common-patterns.md          # Frequently used patterns
└── types/
    ├── IPCB_Board.md           # Complete Board API with examples
    ├── IPCB_Component.md       # Complete Component API with examples
    ├── ISch_Component.md       # Schematic component API
    └── ... (79 total type docs)
```

### For LLMs:
```
ALTIUM_API_COMPLETE_REFERENCE.md
├── Overview
├── Quick Reference
├── PCB API (with key types)
├── Schematic API (with key types)
├── Common Patterns
└── Complete Type Reference (all 79 types with methods, properties, examples)
```

---

## 🔧 Command-Line Tools

### Main CLI (`altium_api_cli.py`)

```bash
# Show API statistics
python altium_api_cli.py stats

# List all API types
python altium_api_cli.py list

# List only PCB types
python altium_api_cli.py list IPCB

# Show complete API for a type
python altium_api_cli.py show IPCB_Component

# Search for methods/properties
python altium_api_cli.py search MoveToXY

# Validate a script file
python altium_api_cli.py validate my_script.pas
```

### Script Validator (`validate_delphiscript.py`)

Catch API errors before running in Altium:

```bash
python validate_delphiscript.py my_script.pas
```

**Example Output:**
```
ERROR: Method 'SetPosition' not found on IPCB_Component
Did you mean: MoveToXY, MoveByXY, SetState_XLocation

WARNING: Property 'Angle' not found on IPCB_Component
Did you mean: Rotation
```

### Search Tool (`search_altium_api.py`)

Quick lookups:

```bash
python search_altium_api.py PCBServer
python search_altium_api.py Board
python search_altium_api.py --pattern "Iterator"
python search_altium_api.py --pcb
python search_altium_api.py --sch
```

---

## 📖 Example: IPCB_Component API

From `docs/api/types/IPCB_Component.md`:

```markdown
# IPCB_Component

**Category:** PCB
**API Surface:** 14 methods, 38 properties

## Methods

### `MoveToXY()`
**Observed signatures:**
```pascal
IPCB_Component.MoveToXY(DestinX + X, DestinY + Y)
```

**Examples:**
*From: Scripts - PCB\ComponentPlacement\ComponentPlacement.pas*
```pascal
Y := Distance * sin(DegToRad(DestinRot + Angle));
Destin.MoveToXY(DestinX + X, DestinY + Y);
Destin.Layer := Source.Layer;
```

### `LoadFromLibrary()`
**Examples:**
*From working scripts with actual usage context*

## Properties

### `Rotation`
**Common values:**
- `90.0`
- `Source.Rotation`
- `DestinRot - SourceRot + Source.Rotation`

**Example:**
```pascal
Destin.Rotation := DestinRot - SourceRot + Source.Rotation;
```

### `Layer`
**Common values:**
- `eTopLayer`
- `eBottomLayer`
- `Source.Layer`
```

---

## 🎓 Common Patterns

### Get Current Board/Schematic
```pascal
// PCB
Board : IPCB_Board;
Board := PCBServer.GetCurrentPCBBoard;
if Board = nil then exit;

// Schematic
Sheet : ISch_Sheet;
Sheet := SCHServer.GetCurrentSchDocument;
if Sheet = nil then exit;
```

### Move/Rotate Component
```pascal
Component : IPCB_Component;

// ✓ CORRECT
Component.MoveToXY(100, 200);      // Absolute position
Component.MoveByXY(10, 10);        // Relative movement
Component.Rotation := 90.0;        // Set rotation

// ❌ WRONG (hallucinated)
Component.SetPosition(100, 200);   // Method doesn't exist!
Component.SetRotation(90.0);       // Method doesn't exist!
```

### Iterate PCB Objects
```pascal
Iterator : IPCB_BoardIterator;
Obj : IPCB_Primitive;

Iterator := Board.BoardIterator_Create;
Iterator.AddFilter_ObjectSet(MkSet(eComponentObject));
Iterator.SetState_FilterAll;

Obj := Iterator.FirstPCBObject;
while Obj <> nil do
begin
    // Process object
    if Obj.ObjectId = eComponentObject then
    begin
        Component := Obj;
        // Work with component
    end;

    Obj := Iterator.NextPCBObject;
end;

Board.BoardIterator_Destroy(Iterator);
```

### Iterate Schematic Objects
```pascal
Iterator : ISch_Iterator;
Obj : ISch_GraphicalObject;

Iterator := Sheet.SchIterator_Create;
Iterator.SetState_FilterAll;
Iterator.AddFilter_ObjectSet(MkSet(eComponent));

Obj := Iterator.FirstSCHObject;
while Obj <> nil do
begin
    if Obj.ObjectId = eSchComponent then
    begin
        Component := Obj;
        // Work with component
    end;

    Obj := Iterator.NextSchObject;
end;

Sheet.SchIterator_Destroy(Iterator);
```

---

## 🤖 Using with LLMs

### Workflow for Generating DelphiScript:

1. **Before generating code, reference the API:**
   ```bash
   python altium_api_cli.py show IPCB_Component
   ```

2. **Generate code using verified methods:**
   ```delphi
   // Reference shows: MoveToXY(), not SetPosition()
   Component.MoveToXY(x, y);  // ✓ Use this
   ```

3. **Validate generated code:**
   ```bash
   python altium_api_cli.py validate generated_script.pas
   ```

4. **Fix any errors based on suggestions:**
   ```
   ERROR: Method 'SetPosition' not found
   Did you mean: MoveToXY
   ```

### LLM-Friendly Reference

The **ALTIUM_API_COMPLETE_REFERENCE.md** file (20,660 lines) contains:

- ✅ Quick reference with common operations
- ✅ All 82 types with complete API details
- ✅ Real code examples from working scripts
- ✅ Method signatures observed in practice
- ✅ Property usage patterns with common values
- ✅ Organized by category (PCB, Schematic, Common)

**File size:** 250KB - easily fits in LLM context windows

---

## 🗂️ Generated Files

| File | Purpose | Size |
|------|---------|------|
| `altium_api_enhanced.json` | Machine-readable API reference | ~358 KB |
| `ALTIUM_API_COMPLETE_REFERENCE.md` | Single consolidated doc for LLMs | ~250 KB |
| `docs/api/index.md` | Human-readable index | ~5 KB |
| `docs/api/pcb-api.md` | PCB API overview | ~800 B |
| `docs/api/schematic-api.md` | Schematic API overview | ~700 B |
| `docs/api/common-patterns.md` | Common usage patterns | ~500 B |
| `docs/api/types/*.md` | 79 individual type docs | ~200 KB total |

---

## 🔍 Verification Example

**Before (Hallucinated):**
```delphi
Component.SetPosition(x, y);           // ❌ Method doesn't exist
Component.SetRotation(angle);          // ❌ Method doesn't exist
```

**Validator Output:**
```
ERROR: Method 'SetPosition' not found on IPCB_Component
Available methods: MoveToXY, MoveByXY, SetState_XLocation, SetState_YLocation
```

**After (Verified):**
```delphi
Component.MoveToXY(x, y);              // ✓ Verified in ComponentPlacement.pas
Component.Rotation := angle;           // ✓ Verified in ComponentPlacement.pas
```

---

## 📈 Statistics

**Source Data:**
- 128 DelphiScript files analyzed
- From community repository: `scripts-libraries/`
- Categories: PCB, Schematic, General, Examples, Outputs

**Extracted:**
- 82 unique API types
- 224 verified methods
- 1,254 verified properties
- 30 constants/enums
- Hundreds of code examples

**Documentation:**
- 20,660 lines of API reference
- 79 type documentation pages
- Real signatures from working code
- Usage examples with context

---

## 🛣️ Roadmap

Future enhancements:

- [ ] Extract full method parameter signatures
- [ ] Infer return types from usage
- [ ] Add parameter type information
- [ ] Link to official Altium docs (when available)
- [ ] Build interactive web documentation
- [ ] Add unit tests for parser
- [ ] Support incremental updates

---

## 📝 License

Tools are open source. Example scripts are from the community scripts-libraries repository.

---

## 🙏 Credits

- **Source:** Community scripts from `scripts-libraries` repository
- **Parser:** Custom AST-based DelphiScript parser
- **Documentation Generator:** Automated extraction from working examples
- **Validator:** Pattern matching against verified API surface

---

## 🚦 Status

**✅ Ready to Use**

All tools are functional and have been tested on the complete scripts-libraries corpus.

The consolidated reference (`ALTIUM_API_COMPLETE_REFERENCE.md`) is optimized for LLM consumption and should be included in prompts when generating DelphiScript code.
