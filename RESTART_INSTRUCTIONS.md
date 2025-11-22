# Session Restart Instructions - Schematic DSL Integration

**Date Created:** 2025-11-21
**Status:** Integration complete, ready for testing with real Altium project

---

## What We Built

We implemented a **Unified Schematic Core** system that converts Altium schematics into an LLM-optimized DSL (Domain Specific Language) format. This makes circuit analysis much more token-efficient and easier for AI reasoning.

### Architecture

```
[Altium Designer]
    ↓ DelphiScript
[GetWholeDesignJSON] - Bulk export (1 call instead of hundreds)
    ↓ JSON
[AltiumJSONAdapter] - Transforms to unified model
    ↓
[Librarian] - State manager, Atlas builder, navigation
    ↓
[DSL Emitter] - Generates token-efficient text format
    ↓
[MCP Tools] - Exposed to Claude Code
```

---

## Current Status

### ✅ **COMPLETE - All Code Implemented**

| Component | Status | Location |
|-----------|--------|----------|
| Data Models | ✅ Done | `server/schematic_core/models.py` (186 lines) |
| DSL Emitter | ✅ Done | `server/schematic_core/dsl_emitter.py` (373 lines) |
| Librarian | ✅ Done | `server/schematic_core/librarian.py` (431 lines) |
| Altium Adapter | ✅ Done | `server/schematic_core/adapters/altium_json.py` |
| DelphiScript | ✅ Done | `server/AltiumScript/schematic_utils.pas` (GetWholeDesignJSON) |
| MCP Integration | ✅ Done | `server/tools/schematic_tools.py` (4 new tools) |
| Tests | ✅ Done | All unit tests passing (21/21 tests) |

### ⚠️ **NEEDS TESTING**

- MCP server was restarted after integration
- Need to test with real Altium Astro-DB project
- Need to verify DelphiScript function works in live Altium

---

## New MCP Tools Available

After MCP server restart, these tools are ready:

### 1. `get_whole_design_json()`
- **Purpose:** Bulk export of entire schematic design
- **Returns:** JSON with all components, pins, nets
- **Use Case:** Fast data extraction (1 call vs hundreds)

### 2. `get_schematic_index()`
- **Purpose:** High-level overview of schematic structure
- **Returns:** Text showing pages, component counts, inter-page signals
- **Use Case:** Understanding project structure

### 3. `get_schematic_page(page_name)`
- **Purpose:** LLM-optimized DSL for a single schematic page
- **Args:** `page_name` (e.g., "Power_Switches.SchDoc")
- **Returns:** DSL text with components and connectivity
- **Use Case:** Focused analysis of one page

### 4. `get_schematic_context(refdes_list)`
- **Purpose:** "Context bubble" around specific components
- **Args:** List of component designators (e.g., ["U1", "R5"])
- **Returns:** DSL showing 1-hop connectivity graph
- **Use Case:** Understanding what connects to a component

---

## Test Plan

### Test 1: Verify Altium Script Loaded
```
1. Check if Altium Designer has the project open: Astro-DB.PrjPCB
2. Verify script is running (check PowerSplit connection or HTTP bridge)
3. Location: C:\Users\geoff\Desktop\projects\thalia\LiberV1.1\daughterboard\
```

### Test 2: Call Bulk Export
```
Command: get_whole_design_json()
Expected: Large JSON file with:
  - 409 components from 13 schematic sheets
  - All pins with net connectivity
  - Net list with page counts
```

### Test 3: Generate Index
```
Command: get_schematic_index()
Expected: Text output showing:
  - List of 13 pages (power_input, battery_charger, uC_Peripherals, etc.)
  - Inter-page signals (UART, I2C, power rails)
  - Global nets (GND, VCC, etc.)
```

### Test 4: View Single Page
```
Command: get_schematic_page("Power_Switches.SchDoc")
Expected: DSL format showing:
  - Complex components (U1 - LTC7003 gate driver) with full pin listings
  - Simple passives (R1, C1) inline in NET lines
  - Net connectivity with LINKS to other pages
```

### Test 5: Context Bubble
```
Command: get_schematic_context(["U1"])
Expected: DSL showing:
  - Full details of U1 (16-pin gate driver IC)
  - All nets connected to U1
  - Neighbor components (passive inline, active summarized)
  - Global nets (GND) with truncated connections
```

---

## Known Issues

1. **Unicode in test output:** Minor console encoding issue with arrow character (↔) in Windows
   - Status: Cosmetic only, doesn't affect functionality
   - Fix: Not critical, tests still pass

2. **First-time import:** Python might need to import schematic_core modules
   - Status: Should work automatically via sys.path
   - Fix: Already added to imports in schematic_tools.py

---

## Files Modified (Last Session)

- `server/tools/schematic_tools.py` - Added 4 new MCP tools (lines 223-389)
- `server/AltiumScript/Altium_API.pas` - Regenerated with GetWholeDesignJSON
- All Python modules in `server/schematic_core/` - Fully implemented

---

## Commands to Run

### Quick Verification
```python
# Test if modules load
from schematic_core.adapters.altium_json import AltiumJSONAdapter
from schematic_core.librarian import Librarian
print("✅ Modules loaded successfully")

# Test with sample data
with open("server/schematic_core/altium_sample.json") as f:
    import json
    data = json.load(f)
    adapter = AltiumJSONAdapter(json.dumps(data))
    librarian = Librarian(adapter)
    print(librarian.get_index())
```

### Live Testing with Altium
```
1. Ensure Altium project is open: Astro-DB
2. Call: get_schematic_index()
3. Call: get_schematic_page("power_input.SchDoc")
4. Call: get_schematic_context(["U1"])
```

---

## Success Criteria

✅ **Phase 1:** MCP tools are callable (no import errors)
✅ **Phase 2:** get_whole_design_json() returns valid JSON from Altium
✅ **Phase 3:** get_schematic_index() shows all 13 pages
✅ **Phase 4:** get_schematic_page() generates proper DSL format
✅ **Phase 5:** get_schematic_context() performs 1-hop traversal correctly

---

## Next Steps After Testing

If all tests pass:
1. ✅ System is production-ready
2. Use for circuit analysis, debugging, documentation
3. Consider adding more DSL features (v0.4, v0.5)

If issues found:
1. Check DelphiScript function in Altium (GetWholeDesignJSON)
2. Verify JSON structure matches expected format
3. Debug adapter or librarian logic
4. Run unit tests: `python server/schematic_core/test_integration.py`

---

## Quick Context for Claude Code

**You are testing the Schematic DSL system we built.**

What to do:
1. Check that MCP server is running
2. Verify Altium project (Astro-DB) is open
3. Call the 4 new MCP tools to test end-to-end functionality
4. Report any errors or unexpected behavior

Key insight: This system converts verbose Altium JSON into compact DSL optimized for LLM reasoning about circuits.

---

**Ready to test!** 🚀
