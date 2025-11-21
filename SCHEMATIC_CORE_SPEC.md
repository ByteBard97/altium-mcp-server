# Schematic Core - Technical Specification v0.3

**Project:** Unified Schematic DSL Generator
**Architecture:** Hexagonal (Ports & Adapters)
**Language:** Python 3.10+
**Status:** Phase 1 - Altium Adapter

---

## 1. Overview

This library ingests electronic schematic data from EDA tools (Altium, KiCad) and converts it into a token-efficient Domain Specific Language (DSL) optimized for Large Language Model consumption.

### 1.1 Core Principles

- **Nuke and Rebuild**: Full data refresh on each query, no incremental updates
- **Net-Centric**: Connectivity is defined only in the NETS section
- **Token Efficiency**: Compress simple passives, expand complex ICs
- **Tool Agnostic**: Core logic has zero dependencies on EDA tool APIs

### 1.2 Architecture Diagram

```
┌─────────────────────┐
│  Altium MCP Tool    │──┐
└─────────────────────┘  │
                         ├──▶ [Adapter] ──▶ [Librarian] ──▶ [DSL Emitter] ──▶ Output
┌─────────────────────┐  │        ▲              ▲
│  KiCad S-Expr File  │──┘        │              │
└─────────────────────┘      Unified Model    Atlas Logic
```

---

## 2. Module Specifications

### 2.1 File Structure

```
server/schematic_core/
├── __init__.py
├── models.py          # Data classes: Component, Net, Pin
├── interfaces.py      # Abstract SchematicProvider interface
├── librarian.py       # State manager, Atlas builder, navigation
├── dsl_emitter.py     # DSL v0.3 text generation
└── adapters/
    ├── __init__.py
    ├── altium_json.py # Altium JSON adapter (Phase 1)
    └── kicad_sexp.py  # KiCad adapter (Phase 2 - stub only)
```

---

## 3. Data Models (`models.py`)

### 3.1 Pin Class

```python
@dataclass
class Pin:
    designator: str  # "1", "22", "A1"
    name: str        # "VCC", "PA9_TX", "" for unnamed
    net: str         # Net name this pin connects to
```

**Validation Rules:**
- `designator` must not be empty
- `name` can be empty string (for simple passives)
- `net` can be empty for no-connects

---

### 3.2 Component Class

```python
@dataclass
class Component:
    refdes: str           # "U1", "R5", "U1A" (for multi-part)
    value: str            # "10k", "STM32F407VGT6"
    footprint: str        # "0805", "LQFP-100"
    mpn: str              # Manufacturer Part Number
    page: str             # "Main_Sheet", "Power_Module"
    description: str      # "ARM Cortex-M4 MCU, 168MHz"
    pins: List[Pin]       # All pins with connectivity
    location: tuple       # (x, y) in mils - captured but not emitted
    properties: Dict[str, str]  # Additional metadata
    multipart_parent: Optional[str] = None  # "U1" for U1A/U1B/U1C
```

**Derived Properties:**

#### `derived_type() -> str`
Maps RefDes prefix to standard type category.

| Prefix | Type | Category |
|--------|------|----------|
| R | RES | Passive |
| C | CAP | Passive |
| L, FB | IND | Passive |
| F | FUSE | Passive |
| D, LED | DIODE | Active |
| Q | TRANSISTOR | Active |
| U | IC | Active |
| J, P, CN, CONN | CONN | Active |
| SW | SWITCH | Active |
| X, Y | OSC | Active |
| **Other** | ACTIVE | Active |

#### `is_complex() -> bool`
Returns `True` if component needs full DEF block in DSL.

**Heuristic:**
```python
def is_complex(self) -> bool:
    if len(self.pins) > 4:
        return True

    # Check if any pin has semantic name (not just "1", "2", "A", "K")
    simple_names = {"1", "2", "3", "4", "A", "K", ""}
    for pin in self.pins:
        if pin.name and pin.name not in simple_names:
            return True

    return False
```

**Examples:**
- `R1` (2 pins, no names) → `False` (Simple)
- `LED1` (2 pins, "A"/"K") → `False` (Simple)
- `U1` (8 pins) → `True` (Complex by count)
- `Q1` (3 pins, "G"/"D"/"S") → `True` (Complex by pin names)

#### `is_passive() -> bool`
Returns `True` if `derived_type()` returns `"RES"`, `"CAP"`, `"IND"`, or `"FUSE"`.

---

### 3.3 Net Class

```python
@dataclass
class Net:
    name: str                    # "UART_TX", "GND", "Net_U1_5"
    pages: Set[str]              # {"Main_Sheet", "Connector_Page"}
    members: List[Tuple[str, str]]  # [("U1", "22"), ("R1", "1")]
```

**Derived Properties:**

#### `is_global() -> bool`
Returns `True` if net should be summarized (not fully expanded).

**Heuristic:**
```python
def is_global(self) -> bool:
    # Regex for power/ground nets
    power_pattern = r'^(P?GND|VSS|VCC|VDD|VEE|VBAT|\+?(\d+V\d*|\d*V\d+)|\+?(\d+V)|.*_GND|.*_VCC)$'
    if re.match(power_pattern, self.name, re.IGNORECASE):
        return True

    # More than 15 connections
    if len(self.members) > 15:
        return True

    # More than 3 pages
    if len(self.pages) > 3:
        return True

    return False
```

#### `is_inter_page() -> bool`
Returns `True` if `len(self.pages) > 1`.

---

## 4. Provider Interface (`interfaces.py`)

```python
from abc import ABC, abstractmethod
from typing import List
from .models import Component, Net

class SchematicProvider(ABC):
    """Contract for EDA tool adapters."""

    @abstractmethod
    def fetch_raw_data(self) -> None:
        """
        Fetch data from source (API call, file read, etc.).
        Updates internal state. Returns nothing.
        """
        pass

    @abstractmethod
    def get_components(self) -> List[Component]:
        """Returns normalized Component objects."""
        pass

    @abstractmethod
    def get_nets(self) -> List[Net]:
        """Returns normalized Net objects."""
        pass
```

**Contract Guarantees:**
- `fetch_raw_data()` must be idempotent (can be called multiple times)
- `get_components()` and `get_nets()` can be called multiple times after `fetch_raw_data()`
- Provider must handle missing/malformed data gracefully (use defaults)

---

## 5. Librarian (`librarian.py`)

The state manager and navigator. Builds the "Atlas" (net-to-pages mapping) and provides query methods.

### 5.1 State Variables

```python
class Librarian:
    def __init__(self, provider: SchematicProvider):
        self.provider = provider
        self.dirty = True
        self.components: List[Component] = []
        self.nets: List[Net] = []
        self.net_page_map: Dict[str, Set[str]] = {}  # The Atlas
```

### 5.2 Methods

#### `refresh() -> None`
```python
def refresh(self) -> None:
    """Nuke and rebuild all state if dirty."""
    if not self.dirty:
        return

    self.provider.fetch_raw_data()
    self.components = self.provider.get_components()
    self.nets = self.provider.get_nets()

    # Build Atlas
    self.net_page_map = {}
    for net in self.nets:
        self.net_page_map[net.name] = net.pages

    self.dirty = False
```

#### `get_index() -> str`
Returns a high-level summary of pages and inter-page signals.

**Format:**
```
# SCHEMATIC INDEX

## Pages
- Main_Sheet (25 components, 40 nets)
- Power_Module (8 components, 15 nets)
- Connector_Page (5 components, 12 nets)

## Inter-Page Signals
- UART_TX: Main_Sheet ↔ Connector_Page
- I2C_SDA: Main_Sheet ↔ Sensor_Sheet
- 3V3: ALL_PAGES (Power Rail)
- GND: ALL_PAGES (Ground)
```

#### `get_page(page_name: str) -> str`
Returns DSL for a single page.

**Logic:**
1. Filter `self.components` by `page == page_name`
2. Filter `self.nets` to include only nets with pins on this page
3. Call `dsl_emitter.emit_page_dsl(components, nets, net_page_map)`

#### `get_context(refdes_list: List[str]) -> str`
Returns DSL for a "context bubble" around specific components.

**Logic (1-Hop Traversal):**
1. **Primary Components**: Get full details for components in `refdes_list`
2. **Connected Nets**: Find all nets connected to primary components' pins
3. **Neighbor Components**: Find all components connected to those nets
4. **Classification**:
   - Primary: Full `DEF` block with all pins
   - Neighbor (Passive): Inline in `NET` line (e.g., `R5.1`)
   - Neighbor (Active): Simplified summary in `# CONTEXT_NEIGHBORS` section
   - Global Nets: Summarize connections (e.g., `GND (Connected to U1.10 + 140 others)`)
5. Call `dsl_emitter.emit_context_dsl(...)`

---

## 6. DSL Emitter (`dsl_emitter.py`)

Generates the v0.3 DSL text output.

### 6.1 Core Principles

1. **Net-Centric Connectivity**: Connections ONLY in `# NETS` section
2. **Compressed Passives**: Simple components (R, C, L with ≤4 pins) have no `COMP` block
3. **Expanded Actives**: Complex components get full `DEF` blocks with pin listings
4. **Inline Pin Hints**: Format as `U1.22(PA9_TX)` for complex pins

### 6.2 Output Format

```
# PAGE: <page_name>

# COMPONENTS
<complex component blocks>

# NETS
<net blocks>
```

### 6.3 Complex Component Block Format

```
DEF <derived_type> <description>
COMP <refdes> (<value>)
  MPN: <mpn>
  FP: <footprint>
  PINS:
    <pin_designator>: <pin_name>
    ...
```

**Rules:**
- Omit `MPN:` line if empty
- Omit `FP:` line if empty
- If `description` is empty, use `derived_type` only
- Sort pins alphabetically by designator

**Example:**
```
DEF IC ARM Cortex-M4 MCU, 168MHz
COMP U1 (STM32F407VGT6)
  MPN: STM32F407VGT6
  FP: LQFP-100
  PINS:
    1: VDD
    2: PA0
    3: PA1
    22: PA9_TX
```

### 6.4 Net Block Format

#### Standard Net
```
NET <net_name>
  CON: <comp.pin>, <comp.pin>, ...
```

#### Inter-Page Net
```
NET <net_name>
  LINKS: <page1>, <page2>
  CON: <comp.pin>, ...
```

#### Global Net (Summarized)
```
NET <net_name>
  LINKS: ALL_PAGES
  CON: <comp.pin>, ... (+ N others)
```

**Pin Format Rules:**
- Simple pin: `R1.1`
- Complex pin with name: `U1.22(PA9_TX)`
- Passive component (no COMP block): Just list inline `R5.1`

**Example:**
```
NET UART_TX
  LINKS: Main_Sheet, Connector_Page
  CON: U1.22(PA9_TX), R1.1, J1.3(TX)

NET GND
  LINKS: ALL_PAGES
  CON: U1.10, U1.50, C1.2, C2.2 (+ 145 others)
```

### 6.5 Formatting Conventions

- **Indentation**: 2 spaces
- **Sorting**:
  - Components: Alphabetical by refdes
  - Nets: Alphabetical by net name
  - Pins: Alphabetical by designator
- **Line Wrapping**: None (LLM can handle long lines)
- **Truncation**: For global nets with >10 connections, show first 10 then `(+ N others)`

### 6.6 Context DSL Additions

For context bubbles, add a neighbor summary section:

```
# CONTEXT_NEIGHBORS
U2 (LM358) - Dual Op-Amp
U3 (TLV3501) - Comparator
```

---

## 7. Altium JSON Adapter (`adapters/altium_json.py`)

**Status**: Blocked pending sample JSON structure.

**Requirements:**
- Implement `SchematicProvider` interface
- Parse JSON from existing Altium MCP tools
- Map Altium-specific field names to unified model
- Handle missing fields gracefully with defaults

**Field Mapping (Tentative - needs sample JSON to confirm):**
```python
# Component mapping
refdes = json_obj["Designator"]
value = json_obj.get("Value", "")
page = json_obj.get("OwnerDocument", "Unknown")
mpn = json_obj.get("Parameters", {}).get("Part Number", "")
description = json_obj.get("Description", "")

# Pin mapping
for pin_data in json_obj.get("Pins", []):
    pin = Pin(
        designator=pin_data["Number"],
        name=pin_data.get("Name", ""),
        net=pin_data.get("Net", "")
    )
```

**TODO**: Finalize mapping after receiving `altium_sample.json`.

---

## 8. Testing Strategy

### 8.1 Mock Data (`tests/mock_data.py`)

Create realistic test data representing a typical schematic page:

**Components:**
- `U1`: STM32F407VGT6 (100-pin MCU)
- `U2`: LM1117-3.3 (3-pin LDO regulator)
- `R1`, `R2`, `R3`: Various resistors
- `C1`, `C2`, `C3`: Capacitors
- `LED1`: LED
- `J1`: 10-pin connector

**Nets:**
- `VCC`, `GND` (global)
- `UART_TX`, `UART_RX` (inter-page)
- `ADC_IN`, `GPIO1` (local)

### 8.2 Test Cases

#### Test: `test_component_classification`
- Verify `is_complex()` logic
- Verify `derived_type()` mapping
- Verify `is_passive()` logic

#### Test: `test_net_global_detection`
- Test power rail regex
- Test connection count threshold
- Test page count threshold

#### Test: `test_dsl_output_format`
- Verify indentation
- Verify sorting
- Verify pin format (inline vs expanded)

#### Test: `test_atlas_building`
- Verify net-to-pages mapping
- Verify inter-page detection

#### Test: `test_context_bubble`
- Verify 1-hop traversal
- Verify neighbor classification
- Verify global net truncation

---

## 9. Integration with MCP Server

### 9.1 New MCP Tools

Add to `server/main.py`:

```python
@mcp.tool()
def get_schematic_index() -> str:
    """Get high-level schematic overview with page list and inter-page signals."""
    provider = AltiumJSONAdapter(mcp_client)
    librarian = Librarian(provider)
    return librarian.get_index()

@mcp.tool()
def get_schematic_page(page_name: str) -> str:
    """Get DSL representation of a single schematic page."""
    provider = AltiumJSONAdapter(mcp_client)
    librarian = Librarian(provider)
    return librarian.get_page(page_name)

@mcp.tool()
def get_schematic_context(refdes: str) -> str:
    """Get DSL representation of context bubble around a component."""
    provider = AltiumJSONAdapter(mcp_client)
    librarian = Librarian(provider)
    return librarian.get_context([refdes])
```

### 9.2 Dependencies

```python
# No external dependencies needed beyond standard library
import re
import json
from typing import List, Dict, Set, Tuple, Optional
from dataclasses import dataclass, field
from abc import ABC, abstractmethod
```

---

## 10. Development Phases

### Phase 1 (Current)
- ✅ Spec complete
- 🔄 Implement `models.py`
- 🔄 Implement `interfaces.py`
- 🔄 Implement `librarian.py`
- 🔄 Implement `dsl_emitter.py`
- 🔄 Create `tests/mock_data.py`
- ⏸️ Get `altium_sample.json` (blocking adapter)
- ⏸️ Implement `adapters/altium_json.py`
- 🔄 Unit tests
- 🔄 Integration with MCP server

### Phase 2 (Future)
- KiCad adapter
- Bulk export optimization (`get_whole_design_json`)
- Spatial queries using location data
- Hierarchical schematic support

---

## 11. Open Questions

1. **Multi-page components**: If U1 spans multiple pages (e.g., U1A on Page1, U1B on Page2), should we merge them or keep separate?
   - **Decision**: Keep separate, use `multipart_parent` field to link them.

2. **No-connect pins**: Should we list NC pins in the DSL?
   - **Decision**: Yes, show as `NC` in net name.

3. **Global net threshold tuning**: Is 15 connections the right limit?
   - **Decision**: Start with 15, adjust based on real-world usage.

---

## 12. Success Criteria

The implementation is complete when:

1. ✅ All unit tests pass
2. ✅ Mock data produces valid DSL output
3. ✅ DSL output matches v0.3 format specification
4. ✅ Altium adapter correctly maps sample JSON
5. ✅ MCP tools are callable and return DSL strings
6. ✅ LLM can successfully reason about circuit patterns using DSL output

---

## Appendix A: Example DSL Output

```
# PAGE: Main_Sheet

# COMPONENTS
DEF IC ARM Cortex-M4 MCU, 168MHz
COMP U1 (STM32F407VGT6)
  MPN: STM32F407VGT6
  FP: LQFP-100
  PINS:
    1: VDD
    2: PA0
    10: GND
    22: PA9_TX
    23: PA10_RX
    50: VSS

DEF IC Linear Regulator 3.3V
COMP U2 (LM1117-3.3)
  MPN: LM1117IMP-3.3
  FP: SOT223
  PINS:
    1: GND
    2: VOUT
    3: VIN

DEF CONN 10-pin header
COMP J1 (CONN_10)
  FP: HDR-1x10
  PINS:
    1: VCC
    2: GND
    3: TX
    4: RX

# NETS
NET VCC
  LINKS: ALL_PAGES
  CON: U2.3, J1.1, C1.1 (+ 12 others)

NET 3V3
  CON: U2.2, U1.1, U1.50, C2.1, C3.1, R1.1

NET GND
  LINKS: ALL_PAGES
  CON: U1.10, U2.1, J1.2, C1.2, C2.2, C3.2 (+ 25 others)

NET UART_TX
  LINKS: Main_Sheet, Connector_Page
  CON: U1.22(PA9_TX), R1.1, J1.3(TX)

NET UART_RX
  LINKS: Main_Sheet, Connector_Page
  CON: U1.23(PA10_RX), R2.1, J1.4(RX)

NET ADC_IN
  CON: U1.2(PA0), R3.2
```

---

## Appendix B: Parallelization Guide

This spec is designed for parallel development by multiple agents:

| Module | Dependencies | Can Start Immediately? |
|--------|-------------|----------------------|
| `models.py` | None | ✅ Yes |
| `interfaces.py` | `models.py` | ✅ Yes (after models) |
| `dsl_emitter.py` | `models.py` | ✅ Yes |
| `librarian.py` | `models.py`, `interfaces.py`, `dsl_emitter.py` | ⚠️ After deps |
| `tests/mock_data.py` | `models.py` | ✅ Yes |
| `adapters/altium_json.py` | `models.py`, `interfaces.py`, sample JSON | ❌ Blocked on JSON |

**Recommended Parallel Tracks:**
- **Track A**: `models.py` → `interfaces.py` → `librarian.py`
- **Track B**: `models.py` → `dsl_emitter.py` → test with mock data
- **Track C**: `tests/mock_data.py` → unit tests

---

**END OF SPECIFICATION**
