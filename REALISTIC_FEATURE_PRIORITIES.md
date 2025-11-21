# Realistic Feature Priorities for Altium MCP
## Based on VERIFIED Altium APIs Only

**Critical Constraint**: This document only recommends features we can build with **verified, working Altium APIs** from our existing codebase.

**Reference**: See `VERIFIED_API_REFERENCE.md` for the complete API catalog.

---

## 🟢 TIER 1: Proven Feasible (Can Start Now)

### 1. Enhanced Board Information Tools ⭐⭐⭐⭐⭐

**API Foundation**:
- ✅ `Board.BoardIterator_Create` - iterate all objects
- ✅ `Component.BoundingRectangleNoNameComment` - get bounds
- ✅ `Board.XOrigin`, `Board.YOrigin` - coordinate system

#### A. `get_board_extents()`
```pascal
// Calculate board bounding box
function GetBoardExtents(): String;
var
    Board: IPCB_Board;
    Iterator: IPCB_BoardIterator;
    Component: IPCB_Component;
    MinX, MinY, MaxX, MaxY: TCoord;
begin
    Board := GetPCBServer.GetCurrentPCBBoard;
    Iterator := Board.BoardIterator_Create;
    Iterator.AddFilter_ObjectSet(MkSet(eComponentObject));

    // Find min/max coordinates
    Component := Iterator.FirstPCBObject;
    while (Component <> Nil) do
    begin
        Rect := Component.BoundingRectangleNoNameComment;
        // Track min/max
        Component := Iterator.NextPCBObject;
    end;

    // Return JSON with extents
end;
```

**Use Cases**:
- "What's the board bounding box?"
- "How big is my design?"
- "What are the board dimensions?"

**Effort**: 1 day

---

#### B. `get_net_details(net_name: str)`
```pascal
// Get detailed net information
function GetNetDetails(NetName: String): String;
var
    Board: IPCB_Board;
    Net: IPCB_Net;
    Iterator: IPCB_BoardIterator;
    Track: IPCB_Track;
    Via: IPCB_Via;
    Pad: IPCB_Pad;
begin
    Board := GetPCBServer.GetCurrentPCBBoard;
    Net := Board.FindNet(NetName);

    if Net = Nil then Exit;

    // Iterate tracks on this net
    Iterator := Board.BoardIterator_Create;
    Iterator.AddFilter_ObjectSet(MkSet(eTrackObject));

    Track := Iterator.FirstPCBObject;
    while (Track <> Nil) do
    begin
        if (Track.Net = Net) then
        begin
            // Record track details (coordinates, width, layer)
        end;
        Track := Iterator.NextPCBObject;
    end;

    // Same for vias, pads
    // Return JSON with net routing details
end;
```

**Use Cases**:
- "Show me how GND is routed"
- "What vias are on USB_DP?"
- "How wide are the power traces?"

**Effort**: 2 days

---

#### C. `get_component_neighbors(designator: str, radius_mm: float)`
```pascal
// Find components within radius
function GetComponentNeighbors(Designator: String; RadiusMM: Float): String;
var
    Board: IPCB_Board;
    TargetComp, Component: IPCB_Component;
    Iterator: IPCB_BoardIterator;
    Distance: TCoord;
    RadiusCoord: TCoord;
begin
    Board := GetPCBServer.GetCurrentPCBBoard;
    TargetComp := Board.GetPcbComponentByRefDes(Designator);

    RadiusCoord := MMsToCoord(RadiusMM);

    Iterator := Board.BoardIterator_Create;
    Iterator.AddFilter_ObjectSet(MkSet(eComponentObject));

    Component := Iterator.FirstPCBObject;
    while (Component <> Nil) do
    begin
        // Calculate distance between components
        Distance := Sqrt(Sqr(Component.x - TargetComp.x) + Sqr(Component.y - TargetComp.y));

        if (Distance <= RadiusCoord) and (Component <> TargetComp) then
        begin
            // Add to neighbors list
        end;

        Component := Iterator.NextPCBObject;
    end;

    // Return JSON with neighbors
end;
```

**Use Cases**:
- "What components are near U1?"
- "Show components within 10mm of C12"
- "Find nearby decoupling capacitors"

**Effort**: 1 day

---

### 2. Component Intelligence (Local) ⭐⭐⭐⭐

**API Foundation**:
- ✅ `Component.Name.Text` - designator
- ✅ `Component.SourceDescription` - description
- ✅ `Component.Pattern` - footprint
- ✅ `FlatHierarchy.DM_Components` - schematic data
- ✅ `Parameter.DM_Name`, `Parameter.DM_Value` - parameters

#### A. `find_components_by_pattern(pattern: str)`
```pascal
// Search components by various criteria
function FindComponentsByPattern(Pattern: String): String;
var
    Board: IPCB_Board;
    Iterator: IPCB_BoardIterator;
    Component: IPCB_Component;
begin
    Board := GetPCBServer.GetCurrentPCBBoard;
    Iterator := Board.BoardIterator_Create;
    Iterator.AddFilter_ObjectSet(MkSet(eComponentObject));

    Component := Iterator.FirstPCBObject;
    while (Component <> Nil) do
    begin
        // Check if designator, description, or footprint matches pattern
        if (Pos(Pattern, Component.Name.Text) > 0) or
           (Pos(Pattern, Component.SourceDescription) > 0) or
           (Pos(Pattern, Component.Pattern) > 0) then
        begin
            // Add to results
        end;

        Component := Iterator.NextPCBObject;
    end;

    // Return JSON with matches
end;
```

**Use Cases**:
- "Find all resistors"
- "Search for components with '0402' footprint"
- "Find capacitors with 'decoupling' in description"

**Effort**: 1 day

---

#### B. `get_component_footprint_info(designators: list)`
```pascal
// Get detailed footprint information
function GetComponentFootprintInfo(Designators: String): String;
var
    Board: IPCB_Board;
    Component: IPCB_Component;
    Iterator: IPCB_GroupIterator;
    Primitive: IPCB_Primitive;
begin
    Board := GetPCBServer.GetCurrentPCBBoard;

    // For each requested designator
    Component := Board.GetPcbComponentByRefDes(Designator);

    // Iterate primitives in component
    Iterator := Component.GroupIterator_Create;
    Iterator.SetState_FilterAll;

    Primitive := Iterator.FirstPCBObject;
    while (Primitive <> Nil) do
    begin
        // Record primitive type, dimensions, layer
        Primitive := Iterator.NextPCBObject;
    end;

    Component.GroupIterator_Destroy(Iterator);

    // Return JSON with footprint details
end;
```

**Use Cases**:
- "What's the actual footprint size of U1?"
- "Get pad dimensions for C12"
- "Show footprint details for resistor array"

**Effort**: 2 days

---

### 3. Enhanced Layer Management ⭐⭐⭐⭐

**API Foundation**:
- ✅ `LayerStack_V7.FirstLayer`, `NextLayer` - iterate layers
- ✅ `LayerObject_V7.Name`, `LayerID` - layer info
- ✅ `Board.LayerIsDisplayed[Layer]` - visibility control

#### A. `get_layer_usage_stats()`
```pascal
// Analyze layer usage
function GetLayerUsageStats(): String;
var
    Board: IPCB_Board;
    LayerStack: IPCB_LayerStack_V7;
    Layer: IPCB_LayerObject_V7;
    Iterator: IPCB_BoardIterator;
    Track: IPCB_Track;
    Via: IPCB_Via;
begin
    Board := GetPCBServer.GetCurrentPCBBoard;
    LayerStack := Board.LayerStack_V7;

    Layer := LayerStack.FirstLayer;
    while (Layer <> Nil) do
    begin
        // Count tracks on this layer
        Iterator := Board.BoardIterator_Create;
        Iterator.AddFilter_ObjectSet(MkSet(eTrackObject));
        Iterator.AddFilter_LayerSet(MkSet(Layer.LayerID));

        TrackCount := 0;
        Track := Iterator.FirstPCBObject;
        while (Track <> Nil) do
        begin
            Inc(TrackCount);
            Track := Iterator.NextPCBObject;
        end;

        Board.BoardIterator_Destroy(Iterator);

        // Record stats for this layer
        Layer := LayerStack.NextLayer(Layer);
    end;

    // Return JSON with layer usage statistics
end;
```

**Use Cases**:
- "Which layers are actually used?"
- "How many traces on each layer?"
- "Layer utilization analysis"

**Effort**: 2 days

---

#### B. `set_layer_visibility_by_type(layer_type: str, visible: bool)`
```pascal
// Control layer visibility by type
function SetLayerVisibilityByType(LayerType: String; Visible: Boolean): String;
var
    Board: IPCB_Board;
    LayerStack: IPCB_LayerStack_V7;
    Layer: IPCB_LayerObject_V7;
begin
    Board := GetPCBServer.GetCurrentPCBBoard;
    LayerStack := Board.LayerStack_V7;

    Layer := LayerStack.FirstLayer;
    while (Layer <> Nil) do
    begin
        case LayerType of
            'copper':
                if ILayer.IsSignalLayer(Layer.LayerID) then
                    Board.LayerIsDisplayed[Layer.LayerID] := Visible;

            'mechanical':
                if ILayer.IsMechanicalLayer(Layer.LayerID) then
                    Board.LayerIsDisplayed[Layer.LayerID] := Visible;

            'silkscreen':
                if (Layer.LayerID = eTopOverlay) or (Layer.LayerID = eBottomOverlay) then
                    Board.LayerIsDisplayed[Layer.LayerID] := Visible;
        end;

        Layer := LayerStack.NextLayer(Layer);
    end;

    GetClient.SendMessage('PCB:Zoom', 'Action=Redraw', 255, GetClient.CurrentView);
end;
```

**Use Cases**:
- "Hide all mechanical layers"
- "Show only copper layers"
- "Toggle silkscreen visibility"

**Effort**: 1 day

---

### 4. Design Analysis Tools ⭐⭐⭐⭐

**API Foundation**:
- ✅ `Component.SourceUniqueId` - schematic link
- ✅ `Pad.Net` - net connection
- ✅ `Track.Width`, `Track.Layer` - routing info

#### A. `analyze_power_distribution_quality(power_nets: list)`
```pascal
// Analyze power net quality
function AnalyzePowerDistribution(PowerNets: String): String;
var
    Board: IPCB_Board;
    Net: IPCB_Net;
    Iterator: IPCB_BoardIterator;
    Track: IPCB_Track;
    TotalLength, MinWidth, MaxWidth: TCoord;
begin
    Board := GetPCBServer.GetCurrentPCBBoard;

    // For each power net
    Net := Board.FindNet(NetName);

    // Analyze tracks
    Iterator := Board.BoardIterator_Create;
    Iterator.AddFilter_ObjectSet(MkSet(eTrackObject));

    Track := Iterator.FirstPCBObject;
    while (Track <> Nil) do
    begin
        if (Track.Net = Net) then
        begin
            // Calculate track length
            Length := Sqrt(Sqr(Track.X2 - Track.X1) + Sqr(Track.Y2 - Track.Y1));
            TotalLength := TotalLength + Length;

            // Track min/max widths
            if (Track.Width < MinWidth) or (MinWidth = 0) then
                MinWidth := Track.Width;
            if (Track.Width > MaxWidth) then
                MaxWidth := Track.Width;
        end;

        Track := Iterator.NextPCBObject;
    end;

    // Return analysis: total length, width variation, via count
end;
```

**Use Cases**:
- "Analyze 3.3V power distribution"
- "Check GND net quality"
- "Power integrity check"

**Effort**: 2-3 days

---

#### B. `get_net_routing_statistics(net_names: list)`
```pascal
// Detailed routing statistics
function GetNetRoutingStatistics(NetNames: String): String;
var
    Board: IPCB_Board;
    Net: IPCB_Net;
    Iterator: IPCB_BoardIterator;
    Track: IPCB_Track;
    Via: IPCB_Via;
    Pad: IPCB_Pad;
begin
    Board := GetPCBServer.GetCurrentPCBBoard;

    for each NetName in NetNames do
    begin
        Net := Board.FindNet(NetName);

        // Count tracks, vias, pads
        // Calculate total route length
        // Track layer usage
        // Measure stub lengths
        // Check width consistency
    end;

    // Return comprehensive routing statistics
end;
```

**Use Cases**:
- "Get routing stats for USB signals"
- "Analyze differential pair routing"
- "Check high-speed net characteristics"

**Effort**: 2-3 days

---

## 🟡 TIER 2: Feasible with External Integration

### 5. Component Availability & Pricing ⭐⭐⭐⭐⭐

**API Foundation**:
- ✅ We have component parameters from schematic
- ⚠️ Requires external API integration (Digi-Key, Mouser, Octopart)

**Implementation Strategy**:
1. Extract manufacturer part numbers from component parameters
2. Call external APIs (Digi-Key API, Octopart API)
3. Cache results for performance
4. Return availability and pricing data

**Python Side Implementation**:
```python
import requests
from typing import Dict, List

class ComponentIntelligence:
    def __init__(self, digikey_api_key: str):
        self.digikey_api_key = digikey_api_key
        self.cache = {}

    async def check_availability(self, part_numbers: List[str]) -> Dict:
        """Check component availability via Digi-Key API"""
        results = {}
        for pn in part_numbers:
            if pn in self.cache:
                results[pn] = self.cache[pn]
            else:
                # Call Digi-Key API
                data = await self._query_digikey(pn)
                self.cache[pn] = data
                results[pn] = data
        return results
```

**Tools to Add**:
1. `check_component_availability(designators: list)` - External API call
2. `get_bom_cost_estimate(quantity: int)` - Aggregate pricing
3. `suggest_alternatives(designator: str)` - Part search APIs

**Effort**: 3-4 days (including API integration, caching, error handling)

**Value**: ⭐⭐⭐⭐⭐ (This is Flux AI's killer feature)

---

### 6. Enhanced Documentation Generation ⭐⭐⭐⭐

**API Foundation**:
- ✅ All component and net data available
- ⚠️ Requires template generation (Python side)

#### A. `generate_design_documentation(sections: list)`

**Python Implementation**:
```python
async def generate_design_documentation(sections: List[str]) -> str:
    """Generate comprehensive design documentation"""

    # Get data from Altium
    project_info = await altium_bridge.call_script("get_project_info", {})
    component_data = await altium_bridge.call_script("get_all_designators", {})
    net_data = await altium_bridge.call_script("get_all_nets", {})
    layer_data = await altium_bridge.call_script("get_pcb_layers", {})

    # Generate markdown documentation
    doc = f"""# {project_info['project_name']} Design Documentation

## Project Overview
- **Project**: {project_info['project_name']}
- **Path**: {project_info['project_path']}
- **Component Count**: {len(component_data)}
- **Net Count**: {len(net_data)}

## Layer Stackup
{generate_stackup_table(layer_data)}

## Component List
{generate_component_table(component_data)}

## Critical Nets
{generate_net_table(net_data)}
"""

    return doc
```

**Effort**: 2-3 days

---

### 7. Manufacturing Integration ⭐⭐⭐

**API Foundation**:
- ✅ Component positions from existing APIs
- ✅ Footprint data from existing APIs
- ⚠️ Requires fabrication house API knowledge (JLCPCB, PCBWay)

#### A. `calculate_jlcpcb_cost(quantity: int, layers: int)`

**Python Implementation**:
```python
async def calculate_jlcpcb_cost(quantity: int, layers: int, width_mm: float, height_mm: float) -> Dict:
    """Calculate JLCPCB fabrication cost"""

    # Get board dimensions from Altium
    extents = await altium_bridge.call_script("get_board_extents", {})

    # Calculate based on JLCPCB pricing rules
    area_dm2 = (width_mm * height_mm) / 10000

    base_cost = JLCPCB_PRICING[layers][quantity]
    area_cost = area_dm2 * AREA_MULTIPLIER

    return {
        "fabrication_cost": base_cost + area_cost,
        "quantity": quantity,
        "price_per_board": (base_cost + area_cost) / quantity
    }
```

**Effort**: 2-3 days (pricing tables, API integration)

---

## ❌ TIER 3: NOT Feasible (No APIs Available)

### What We CANNOT Do

#### 1. **Real-Time Visual Rendering with Custom Highlighting**
- ❌ No rendering API in DelphiScript
- ❌ Cannot programmatically generate layer-specific images
- ⚠️ We CAN take screenshots, but not with custom annotations

**Alternative**: Enhanced screenshot tool with post-processing

---

#### 2. **Direct Gerber/PDF/SVG Export**
- ❌ No direct export APIs in our verified catalog
- ⚠️ Output jobs exist but unclear if scriptable

**Alternative**: Document how to use output jobs manually

---

#### 3. **3D Model Export**
- ❌ No 3D API access visible
- ❌ STEP/VRML export not in verified APIs

**Alternative**: Not feasible

---

#### 4. **Active Layer Setting**
- ❌ No `SetActiveLayer` API found
- ⚠️ Can read active layer, but not set it programmatically

**Alternative**: Not feasible

---

#### 5. **Dynamic Layer Addition**
- ❌ No layer creation/modification APIs
- ⚠️ Layer stackup is read-only in our verified APIs

**Alternative**: Not feasible

---

## 📋 Implementation Roadmap

### Week 1: Board Information Suite
- Day 1: `get_board_extents()`
- Day 2-3: `get_net_details()`
- Day 4: `get_component_neighbors()`
- Day 5: `find_components_by_pattern()`

**Deliverable**: Enhanced board querying capabilities

---

### Week 2: Layer & Analysis Tools
- Day 1-2: `get_layer_usage_stats()`
- Day 2: `set_layer_visibility_by_type()`
- Day 3-4: `analyze_power_distribution_quality()`
- Day 5: `get_net_routing_statistics()`

**Deliverable**: Professional-grade design analysis

---

### Week 3-4: External Integration
- Week 3: Component availability APIs (Digi-Key integration)
- Week 4: Documentation generation + manufacturing cost

**Deliverable**: Supply chain intelligence

---

## 🎯 Success Criteria

After implementing Tier 1 + Tier 2:

### What AI Can Do:
- ✅ Understand board layout geometrically
- ✅ Analyze net routing quality
- ✅ Find components intelligently
- ✅ Check layer usage
- ✅ Verify power distribution
- ✅ Get component availability (external)
- ✅ Estimate manufacturing costs
- ✅ Generate documentation

### What AI Still Cannot Do:
- ❌ Real-time custom rendering
- ❌ Direct export (Gerber, PDF, etc.)
- ❌ 3D model export
- ❌ Modify layer stackup
- ❌ Set active layer programmatically

---

## 💡 Key Insight

**The highest-value features we CAN build are:**

1. **Board Intelligence** - Full geometric and routing analysis
2. **Component Intelligence** - With external API integration for availability
3. **Design Quality Analysis** - Power distribution, routing stats, layer usage
4. **Documentation Automation** - Generate comprehensive design docs

**This makes Altium MCP competitive with Flux AI** in areas that matter most for AI-assisted design:
- Understanding the board ✅
- Knowing what's available ✅
- Validating design quality ✅
- Documenting decisions ✅

**We cannot match Flux on:**
- Visual rendering (browser-based)
- One-click exports (browser-based)

**But we EXCEED Flux on:**
- Professional Altium integration
- Enterprise workflows
- Existing project support
- Design analysis depth

---

## 📊 ROI Analysis

| Feature Category | Development Time | Requires External APIs | AI Value | User Impact |
|------------------|------------------|------------------------|----------|-------------|
| Board Information | 4-5 days | No | ⭐⭐⭐⭐⭐ | High |
| Layer Management | 3 days | No | ⭐⭐⭐⭐ | Medium |
| Design Analysis | 4-5 days | No | ⭐⭐⭐⭐⭐ | High |
| Component Availability | 3-4 days | Yes (Digi-Key) | ⭐⭐⭐⭐⭐ | Very High |
| Documentation | 2-3 days | No | ⭐⭐⭐⭐ | High |
| Manufacturing Cost | 2-3 days | Partial (pricing tables) | ⭐⭐⭐⭐ | High |

**Best ROI**: Board Information + Component Availability = 7-9 days for transformational capability

---

## 🚀 Recommendation

**Start with Week 1-2 (Tier 1 features)**: 10 days of development gets you:
- Complete board geometric intelligence
- Net routing analysis
- Layer management
- Power distribution checking

**This alone makes Altium MCP more intelligent than 90% of AI PCB tools.**

Then add Week 3-4 (Tier 2) for supply chain intelligence and documentation.

**Total: 4 weeks to market-leading AI-assisted PCB design capabilities.**
