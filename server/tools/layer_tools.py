"""
Layer-related tool handlers
"""
import json
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from mcp.server.fastmcp import FastMCP
    from ..altium_bridge import AltiumBridge


def register_layer_tools(mcp: "FastMCP", altium_bridge: "AltiumBridge"):
    """Register all layer-related tools"""

    @mcp.tool()
    async def get_pcb_layers() -> str:
        """
        Get detailed information about all layers in the current Altium PCB

        Returns:
            JSON object with detailed layer information including copper layers,
            mechanical layers, and special layers with their properties
        """
        response = await altium_bridge.call_script("get_pcb_layers", {})

        if not response.success:
            return json.dumps({"error": f"Failed to get PCB layers: {response.error}"})

        layers_data = response.data

        if not layers_data:
            return json.dumps({"message": "No PCB layers found in the current document"})

        return json.dumps(layers_data, indent=2)

    @mcp.tool()
    async def set_pcb_layer_visibility(layer_names: list[str], visible: bool) -> str:
        """
        Set visibility for specified PCB layers

        Args:
            layer_names: List of layer names to modify (e.g., ["Top Layer", "Bottom Layer", "Mechanical 1"])
            visible: Whether to show (True) or hide (False) the specified layers

        Returns:
            JSON object with the result of the operation
        """
        response = await altium_bridge.call_script("set_pcb_layer_visibility", {
            "layer_names": layer_names,
            "visible": visible
        })

        if not response.success:
            return json.dumps({"success": False, "error": f"Failed to set layer visibility: {response.error}"})

        return json.dumps(response.data, indent=2)

    @mcp.tool()
    async def get_pcb_layer_stackup() -> str:
        """
        Get the detailed layer stackup information from the current Altium PCB including
        copper thickness, dielectric materials, constants, and heights

        Returns:
            JSON object with detailed layer stackup information
        """
        response = await altium_bridge.call_script("get_pcb_layer_stackup", {})

        if not response.success:
            return json.dumps({"error": f"Failed to get PCB layer stackup: {response.error}"})

        stackup_data = response.data

        if not stackup_data:
            return json.dumps({"message": "No PCB layer stackup found in the current document"})

        return json.dumps(stackup_data, indent=2)
