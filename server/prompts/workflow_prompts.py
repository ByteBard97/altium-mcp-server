"""
Workflow prompt templates for common Altium tasks
"""
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from mcp.server.fastmcp import FastMCP


def register_workflow_prompts(mcp: "FastMCP"):
    """Register all workflow prompt templates"""

    @mcp.prompt()
    async def create_symbol_workflow(component_type: str = "IC") -> list[dict]:
        """
        Guide user through creating a schematic symbol from a datasheet.

        Args:
            component_type: Type of component (IC, connector, discrete)
        """
        return [
            {
                "type": "text",
                "text": f"""I'll help you create a schematic symbol for a {component_type}.

**Step 1: Get Symbol Placement Rules**
First, I'll retrieve the pin placement rules to ensure proper formatting.

Let me call `get_symbol_placement_rules()` to understand the guidelines...

**Step 2: Define Component Pins**
I'll need from the datasheet:
- Pin numbers and names
- Pin types (input, output, power, ground, I/O)
- Preferred symbol orientation

**Step 3: Create the Symbol**
I'll generate the pin definitions and call `create_schematic_symbol()` with:
- Intelligent pin placement based on type
- Proper spacing and alignment
- Standard symbol conventions

**Ready to start?**
Please provide:
1. Component part number or name
2. Total pin count
3. Any specific requirements

Or share the datasheet and I'll extract the pin information."""
            }
        ]

    @mcp.prompt()
    async def duplicate_layout_workflow(circuit_type: str = "layout") -> list[dict]:
        """
        Step-by-step workflow for duplicating a layout pattern.

        Args:
            circuit_type: Type of circuit (power supply, differential pair, etc.)
        """
        return [
            {
                "type": "text",
                "text": f"""I'll guide you through duplicating a {circuit_type} pattern.

**Step 1: Select Source Components**
In Altium Designer:
1. Select all components that are part of your reference layout
2. Include all related components (ICs, passives, connectors)

**Step 2: Capture Pattern**
I'll call `layout_duplicator()` to:
- Record source component positions
- Capture relative placement
- Identify available destination components

**Step 3: Match Components**
I can intelligently match components by:
- Function (even if values differ)
- Footprint compatibility
- Circuit role

**Step 4: Apply Layout**
I'll call `layout_duplicator_apply()` to:
- Replicate relative positions
- Maintain spacing ratios
- Copy routing patterns (if available)

**Ready?**
Please select your source components in Altium, then I'll proceed with the duplication."""
            }
        ]

    @mcp.prompt()
    async def organize_nets_workflow() -> list[dict]:
        """
        Organize nets into functional classes.
        """
        return [
            {
                "type": "text",
                "text": """I'll help you organize your nets into classes by function.

**Step 1: Analyze Current Nets**
Let me get all nets from your board using `get_all_nets()`...

**Step 2: Categorize Nets**
I'll identify and group:
- **Power nets**: VCC, VDD, VBUS, +3V3, +5V, etc.
- **Ground nets**: GND, AGND, DGND, Earth
- **High-speed signals**: USB, PCIe, HDMI, LVDS
- **Differential pairs**: *_P/*_N pairs
- **Clock signals**: CLK, XTAL, OSC
- **Control signals**: CS, EN, RST
- **Data buses**: D0-D7, A0-A15

**Step 3: Create Net Classes**
For each category, I'll:
- Create appropriately named net class
- Add matching nets to the class
- Suggest design rules for each class

**Step 4: Review**
I'll provide a summary of:
- Nets organized by class
- Unclassified nets for review
- Recommended design rules

Let me start by retrieving your net list..."""
            }
        ]
