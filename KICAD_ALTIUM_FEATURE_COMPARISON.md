# KiCad vs Altium MCP Server Feature Comparison

## Executive Summary

**KiCad MCP Servers:** 52 tools across 2 specialized servers
- TypeScript Server (Design): 41 tools
- Python Server (Analysis): 11 tools

**Altium MCP Server:** 45 tools in unified server
- Covers most essential functionality
- Missing some advanced analysis and export capabilities

---

## Feature Comparison Matrix

### ✅ Features Present in BOTH

| Feature Category | KiCad | Altium | Notes |
|-----------------|-------|--------|-------|
| **Project Management** | ✅ | ✅ | Both have create, open, save, get info |
| **Component Placement** | ✅ | ✅ | Full component manipulation |
| **Component Movement** | ✅ | ✅ | Move, rotate, position control |
| **Component Deletion** | ✅ | ✅ | Remove components from board |
| **Board Size Setting** | ✅ | ✅ | Set PCB dimensions |
| **Board Outline** | ✅ | ✅ | Add board outline shapes |
| **Mounting Holes** | ✅ | ✅ | Add mounting holes |
| **Board Text** | ✅ | ✅ | Add text annotations |
| **Layer Management** | ✅ | ✅ | Layer info and visibility |
| **Net Management** | ✅ | ✅ | Get nets, create net classes |
| **Trace Routing** | ✅ | ✅ | Route copper traces |
| **Via Placement** | ✅ | ✅ | Add vias between layers |
| **Copper Pour/Zone** | ✅ | ✅ | Create ground planes |
| **DRC** | ✅ | ✅ | Design rule checking |
| **Component Search** | ✅ | ✅ | Library search |
| **Footprint Search** | ✅ | ✅ | Find footprints |
| **Schematic Symbols** | ✅ | ✅ | Symbol creation/management |
| **BOM Export** | ✅ | ✅ | Generate BOM data |

### ⚠️ Features in KiCad, MISSING or LIMITED in Altium

| Feature | KiCad Implementation | Altium Status | Feasibility |
|---------|---------------------|---------------|-------------|
| **Gerber Export** | ✅ Full export tool | ❌ Missing | 🟢 HIGH - Can use output jobs |
| **PDF Export** | ✅ Multi-layer PDF | ❌ Missing | 🟢 HIGH - Can use output jobs |
| **SVG Export** | ✅ Vector graphics | ❌ Missing | 🟢 HIGH - Can use output jobs |
| **3D Model Export** | ✅ STEP/STL/VRML/OBJ | ❌ Missing | 🟡 MEDIUM - Need 3D API access |
| **Position File Export** | ✅ Pick-and-place | ❌ Missing | 🟢 HIGH - Can use output jobs |
| **Netlist Export** | ✅ Multiple formats | ❌ Missing | 🟢 HIGH - Altium has netlist API |
| **VRML Export** | ✅ Dedicated tool | ❌ Missing | 🟡 MEDIUM - 3D export capability |
| **Component Grouping** | ✅ Create groups | ❌ Missing | 🟡 MEDIUM - Need grouping API |
| **Component Replace** | ✅ Swap components | ❌ Missing | 🟢 HIGH - Delete + Place |
| **Component Find** | ✅ Search by ref/value | ⚠️ Limited | 🟢 HIGH - Enhance existing search |
| **Component Annotation** | ✅ Add comments | ❌ Missing | 🟡 MEDIUM - Text placement |
| **Active Layer Setting** | ✅ Set active layer | ❌ Missing | 🟢 HIGH - Layer API exists |
| **Board Extents** | ✅ Get bounding box | ❌ Missing | 🟢 HIGH - Geometry API |
| **Board 2D View** | ✅ Generate image | ⚠️ Screenshot only | 🟡 MEDIUM - Have screenshot tool |
| **Layer Addition** | ✅ Add new layers | ❌ Missing | 🔴 LOW - Complex layer stack |
| **Design Rules Set** | ✅ Configure rules | ⚠️ Get only | 🟡 MEDIUM - Rules API complex |
| **Design Rules Get** | ✅ | ✅ | Already implemented |
| **Clearance Check** | ✅ Check between items | ❌ Missing | 🟡 MEDIUM - Need DRC API |
| **DRC Violations** | ✅ Get violation list | ⚠️ Via history | 🟢 HIGH - Enhance DRC tool |
| **Net to Class Assign** | ✅ Assign nets | ❌ Missing | 🟢 HIGH - Extend net class tool |
| **Layer Constraints** | ✅ Per-layer rules | ❌ Missing | 🟡 MEDIUM - Complex rules API |
| **Schematic Wire** | ✅ Add wires | ❌ Missing | 🔴 LOW - Schematic API limited |
| **UI Management** | ✅ Check/launch UI | ❌ Missing | 🟢 HIGH - Process management |
| **Project List** | ✅ Find all projects | ❌ Missing | 🟢 HIGH - File system search |
| **Thumbnail Generation** | ✅ PCB preview image | ⚠️ Screenshot only | 🟡 MEDIUM - Export to image |
| **BOM Analysis** | ✅ Detailed analysis | ⚠️ Export only | 🟢 HIGH - Parse BOM data |
| **Netlist Extraction** | ✅ From schematic | ❌ Missing | 🟡 MEDIUM - Netlist API |
| **Pattern Recognition** | ✅ 7+ pattern types | ✅ Basic patterns | 🟢 HIGH - Already have tool |
| **Boundary Validation** | ✅ Component bounds | ❌ Missing | 🟡 MEDIUM - Geometry checks |

### ✨ Features in Altium, MISSING in KiCad

| Feature | Altium Implementation | Advantage |
|---------|----------------------|-----------|
| **DRC History** | ✅ SQLite database tracking | Trend analysis over time |
| **Layout Duplicator** | ✅ 2-step duplication | Copy layout patterns |
| **Component Alignment** | ✅ Align to edges | Precise alignment tool |
| **Component Array** | ✅ Grid placement | Quick pattern creation |
| **Layer Stackup** | ✅ Detailed stackup info | Complete material data |
| **Schematic-PCB Sync** | ✅ Sync checking | UniqueId correlation |
| **Screenshot Capture** | ✅ Altium window capture | Visual documentation |
| **Symbol Reference** | ✅ Get library symbols | Template-based creation |
| **Component Pins** | ✅ Pin data retrieval | Detailed pin info |
| **Property Names** | ✅ All property discovery | Dynamic property access |
| **Property Values** | ✅ Bulk property query | Efficient data access |
| **Selected Components** | ✅ Get selected coords | Work with selection |
| **Document Management** | ✅ Open any document type | Multi-document support |
| **Output Job Execution** | ✅ Run output jobs | Automated workflows |

---

## Analysis by Category

### 1. PROJECT MANAGEMENT
**Both:** ✅ Complete parity
- Create, open, save, get info
- **Altium advantage:** Document management (open_document)
- **KiCad advantage:** Project listing (find all projects on system)

### 2. COMPONENT MANAGEMENT
**Altium:** Strong ✅
- **Better:** Pin data, property discovery, selected components, alignment, array placement
- **Missing:** Component grouping, component replacement, annotation

**Recommendation:** Add component replacement (delete+place wrapper)

### 3. BOARD DESIGN
**Both:** Good coverage ✅
- **Altium advantage:** Layer stackup details, screenshot capture
- **KiCad advantage:** Layer addition, board extents, 2D view generation

**Recommendation:** Add board extents calculation, enhance layer tools

### 4. ROUTING
**Both:** ✅ Complete parity
- Trace routing, via placement, copper pour
- Both have net class creation

**Recommendation:** Add net-to-class assignment in Altium

### 5. DESIGN RULES
**Altium:** Basic ✅ (get rules, DRC with history)
**KiCad:** Advanced ✅ (set rules, clearance check, layer constraints)

**Recommendation:** Add design rule modification capabilities

### 6. EXPORT/OUTPUT
**KiCad:** Comprehensive export suite ✅
- 8 export tools: Gerber, PDF, SVG, 3D, BOM, Netlist, Position, VRML

**Altium:** Output jobs only ⚠️
- Can execute output jobs
- Missing direct export tools

**Recommendation:** HIGH PRIORITY - Add export wrappers using output jobs

### 7. ANALYSIS/VALIDATION
**Altium:** Strong ✅
- DRC history tracking with trends
- Schematic-PCB sync checking
- Circuit pattern recognition

**KiCad:** Good ✅
- BOM analysis with cost estimation
- Netlist extraction
- Boundary validation
- Pattern recognition (7+ types)

**Recommendation:** Add BOM analysis tool, netlist extraction

### 8. SCHEMATIC
**Both:** Basic symbol management ✅
**Altium advantage:** Symbol reference templates, schematic data queries
**KiCad advantage:** Wire placement (limited)

**Recommendation:** Low priority - schematic API is complex

---

## Implementation Priority Recommendations

### 🟢 HIGH PRIORITY (Easy + High Value)

1. **Export Tools** - Use output jobs API
   - `export_gerber()`
   - `export_pdf()`
   - `export_bom_csv()`
   - `export_position_file()`
   - `export_netlist()`

2. **Enhanced Component Tools**
   - `replace_component()` - wrapper around delete + place
   - `find_component()` - enhance search capabilities
   - `assign_net_to_class()` - extend net class tool

3. **Board Information**
   - `get_board_extents()` - calculate bounding box
   - `get_drc_violations()` - parse DRC results

4. **Project Discovery**
   - `list_projects()` - scan file system for .PrjPcb files

5. **UI Management**
   - `check_altium_ui()` - process detection
   - `launch_altium_ui()` - process launching

### 🟡 MEDIUM PRIORITY (Moderate Effort)

6. **Enhanced Analysis**
   - `analyze_bom()` - parse and analyze BOM files
   - `extract_netlist()` - get netlist from schematic

7. **Layer Management**
   - `set_active_layer()` - change current layer
   - `get_layer_constraints()` - per-layer rules

8. **3D Export** (if API available)
   - `export_3d()` - STEP/STL export

9. **Image Generation**
   - `generate_pcb_thumbnail()` - enhance screenshot to thumbnail
   - `get_board_2d_view()` - render to image

### 🔴 LOW PRIORITY (Complex/Limited Value)

10. **Layer Addition** - Complex layer stack management
11. **Schematic Wiring** - Limited schematic API
12. **Design Rule Modification** - Complex rules engine
13. **Component Grouping** - If grouping API exists

---

## Feasibility Assessment

### ✅ **HIGHLY FEASIBLE** (Already have APIs/patterns)
- All export tools using output jobs
- Component replacement (delete + place)
- Board extents calculation
- Project file discovery
- UI process management
- Enhanced find/search
- Net class assignment

### 🟡 **MODERATELY FEASIBLE** (Need API exploration)
- BOM file parsing and analysis
- Netlist extraction from schematic
- Active layer setting
- Layer constraint queries
- 3D model export
- Thumbnail generation beyond screenshot
- Clearance checking
- Component annotations

### 🔴 **CHALLENGING** (Complex APIs or limitations)
- Dynamic layer addition to stackup
- Schematic wire routing
- Full design rule modification
- Component grouping (if no API)
- VRML export

---

## Summary Statistics

| Category | KiCad | Altium | Overlap | KiCad Only | Altium Only |
|----------|-------|--------|---------|------------|-------------|
| **Project** | 4 | 5 | 4 | 1 | 1 |
| **Component** | 10 | 11 | 7 | 3 | 4 |
| **Board** | 10 | 4 | 4 | 6 | 0 |
| **Routing** | 4 | 3 | 3 | 1 | 0 |
| **Design Rules** | 9 | 2 | 1 | 8 | 1 |
| **Export** | 8 | 3 | 1 | 7 | 2 |
| **Schematic** | 3 | 5 | 1 | 2 | 4 |
| **Analysis** | 8 | 5 | 3 | 5 | 2 |
| **Library** | 0 | 4 | 0 | 0 | 4 |
| **TOTAL** | 52 | 45 | ~24 | ~28 | ~21 |

---

## Recommended Implementation Plan

### Phase 1: Export Tools (2-3 days)
Add 5 export tools using output jobs API:
- Gerber, PDF, BOM CSV, Position file, Netlist

### Phase 2: Enhanced Component Operations (1-2 days)
- Component replacement
- Enhanced find/search
- Net to class assignment

### Phase 3: Board Information (1 day)
- Board extents
- Enhanced DRC violations access

### Phase 4: Analysis Tools (2-3 days)
- BOM analysis from files
- Project listing
- Netlist extraction

### Phase 5: UI & Advanced (2-3 days)
- UI management
- Thumbnail generation
- Layer constraints
- Active layer setting

**Total Estimated Effort:** 8-12 development days for HIGH + MEDIUM priority features

---

## Conclusion

**Altium MCP is competitive with KiCad MCP** with 45 vs 52 tools. The main gaps are:

1. **Export functionality** - Easily addressable with output jobs
2. **Advanced design rule access** - Lower priority
3. **Some analysis tools** - Medium priority

**Recommendation:** Focus on Phase 1-3 (export tools, component ops, board info) to achieve feature parity in the most commonly used areas. This represents about 4-6 days of development work.

The Altium MCP already has unique advantages (DRC history, layout duplicator, sync checking) that KiCad lacks, making it a strong offering once export tools are added.
