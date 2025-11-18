"""
Schematic-related tool handlers
"""
import json
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from mcp.server.fastmcp import FastMCP
    from ..altium_bridge import AltiumBridge


def register_schematic_tools(mcp: "FastMCP", altium_bridge: "AltiumBridge"):
    """Register all schematic-related tools"""

    @mcp.tool()
    async def get_symbol_placement_rules() -> str:
        """
        Get schematic symbol placement rules from a local configuration file

        Returns:
            JSON object with rules for placing pins on schematic symbols
        """
        # Define the rules file path in the MCP directory
        rules_file_path = altium_bridge.mcp_dir / "symbol_placement_rules.txt"

        # Check if the rules file exists
        if not rules_file_path.exists():
            # Default rules content
            default_rules = (
                "Only place pins on the left and right side of the symbol. "
                "Place power rail pins at the upper right, ground pins in the bottom left, "
                "no connect pins in the bottom right, inputs on the left, outputs on the right, "
                "and try to group other pins together by similar functionality (for example, SPI, I2C, RGMII, etc.). "
                "Always separate groups by 100mil gaps unless there is extra spacing, then space out groups equal distance from each other. "
            )

            # Create a helpful message for the user
            message = {
                "success": False,
                "error": f"Rules file not found at: {rules_file_path}",
                "message": f"Let the user know that they can optionally update the file {rules_file_path} with custom symbol placement rules. "
                          f"Suggested content: {default_rules}"
            }

            return json.dumps(message, indent=2)

        # Read the rules file if it exists
        try:
            with open(rules_file_path, "r") as f:
                rules_content = f.read()

            # Return the rules with a message about how to modify them
            result = {
                "success": True,
                "message": f"Modify {rules_file_path} with custom symbol placement instructions",
                "rules": rules_content
            }

            return json.dumps(result, indent=2)

        except Exception as e:
            return json.dumps({
                "success": False,
                "error": f"Failed to read rules file: {str(e)}"
            }, indent=2)

    @mcp.tool()
    async def get_library_symbol_reference() -> str:
        """
        Get the currently open symbol from a schematic library to use as reference for creating a new symbol.
        This tool should be used before creating a new symbol to understand the structure of existing symbols.

        Returns:
            JSON object with the reference symbol data including pins, their types, positions, and orientations
        """
        response = await altium_bridge.call_script("get_library_symbol_reference", {})

        if not response.success:
            return json.dumps({"error": f"Failed to get symbol reference: {response.error}"})

        symbol_data = response.data

        if not symbol_data:
            return json.dumps({"error": "No symbol reference data found or no symbol is currently selected in the library"})

        return json.dumps(symbol_data, indent=2)

    @mcp.tool()
    async def create_schematic_symbol(symbol_name: str, description: str, pins: list[str]) -> str:
        """
        Before executing, run get_symbol_placement_rules first.
        Create a new schematic symbol in the current library with the specified pins
        Instructions: pins should be grouped together via function and only placed on
                      the left and right side in 100 mil increments

        Args:
            symbol_name: Name of the symbol to create
            description: Description of the schematic symbol
            pins: List of pin data in format ["pin_number|pin_name|pin_type|pin_orientation|x|y", ...]
                  Pin types: eElectricHiZ, eElectricInput, eElectricIO, eElectricOpenCollector,
                             eElectricOpenEmitter, eElectricOutput, eElectricPassive, eElectricPower
                  Pin orientations: eRotate0 (right), eRotate90 (down), eRotate180 (left), eRotate270 (up)
                  X,Y coordinates in mils

        Returns:
            JSON object with the result of the component creation
        """
        response = await altium_bridge.call_script("create_schematic_symbol", {
            "symbol_name": symbol_name,
            "description": description,
            "pins": pins
        })

        if not response.success:
            return json.dumps({"success": False, "error": f"Failed to create symbol: {response.error}"})

        return json.dumps(response.data, indent=2)

    @mcp.tool()
    async def get_schematic_data(cmp_designators: list[str]) -> str:
        """
        Get schematic data for components in Altium

        Args:
            cmp_designators: List of designators of the components (e.g., ["R1", "C5", "U3"])

        Returns:
            JSON object with schematic component data for requested designators
        """
        response = await altium_bridge.call_script("get_schematic_data", {})

        if not response.success:
            return json.dumps({"error": f"Failed to get schematic data: {response.error}"})

        schematic_data = response.data

        if not schematic_data:
            return json.dumps({"error": "No schematic data found"})

        try:
            # Filter components by designator
            components = []
            missing_designators = []

            for designator in cmp_designators:
                found = False
                for component in schematic_data:
                    if component.get("designator") == designator:
                        components.append(component)
                        found = True
                        break

                if not found:
                    missing_designators.append(designator)

            result = {
                "components": components,
            }

            if missing_designators:
                result["missing_designators"] = missing_designators

            return json.dumps(result, indent=2)
        except Exception as e:
            return json.dumps({"error": f"Failed to process schematic data: {str(e)}"})
