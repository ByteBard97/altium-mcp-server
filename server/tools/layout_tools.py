"""
Layout-related tool handlers
"""
import json
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from mcp.server.fastmcp import FastMCP
    from ..altium_bridge import AltiumBridge


def register_layout_tools(mcp: "FastMCP", altium_bridge: "AltiumBridge"):
    """Register all layout-related tools"""

    @mcp.tool()
    async def layout_duplicator() -> str:
        """
        First step of layout duplication. Selects source components and returns data to match with destination components.

        Returns:
            JSON object with source and destination component data for matching
        """
        response = await altium_bridge.call_script("layout_duplicator", {})

        if not response.success:
            return json.dumps({"success": False, "error": f"Failed to start layout duplication: {response.error}"})

        components_data = response.data

        if not components_data:
            return json.dumps({"success": False, "error": "No component data returned from Altium"})

        return json.dumps(components_data, indent=2)

    @mcp.tool()
    async def layout_duplicator_apply(source_designators: list[str], destination_designators: list[str]) -> str:
        """
        Second step of layout duplication. Applies the layout of source components to destination components.

        Args:
            source_designators: List of source component designators (e.g., ["R1", "C5", "U3"])
            destination_designators: List of destination component designators (e.g., ["R10", "C15", "U7"])

        Returns:
            JSON object with the result of the layout duplication
        """
        response = await altium_bridge.call_script("layout_duplicator_apply", {
            "source_designators": source_designators,
            "destination_designators": destination_designators
        })

        if not response.success:
            return json.dumps({"success": False, "error": f"Failed to apply layout duplication: {response.error}"})

        return json.dumps(response.data, indent=2)

    @mcp.tool()
    async def get_screenshot(view_type: str = "pcb") -> str:
        """
        Take a screenshot of the Altium window

        Args:
            view_type: Type of view to capture - 'pcb' or 'sch'

        Returns:
            JSON object with screenshot data (base64 encoded) and metadata
        """
        response = await altium_bridge.call_script("take_view_screenshot", {"view_type": view_type.lower()})

        if not response.success:
            return json.dumps({"success": False, "error": f"Failed to capture screenshot: {response.error}"})

        return json.dumps(response.data)

    @mcp.tool()
    async def get_pcb_rules() -> str:
        """
        Get all design rules from the current Altium PCB

        Returns:
            JSON array of PCB design rules with their properties
        """
        response = await altium_bridge.call_script("get_pcb_rules", {})

        if not response.success:
            return json.dumps({"error": f"Failed to get PCB rules: {response.error}"})

        rules_data = response.data

        if not rules_data:
            return json.dumps({"message": "No PCB rules found in the current document"})

        return json.dumps(rules_data, indent=2)
