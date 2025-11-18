"""
Net-related tool handlers
"""
import json
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from mcp.server.fastmcp import FastMCP
    from ..altium_bridge import AltiumBridge


def register_net_tools(mcp: "FastMCP", altium_bridge: "AltiumBridge"):
    """Register all net-related tools"""

    @mcp.tool()
    async def get_all_nets() -> str:
        """
        Return every unique net name in the active PCB document.

        Returns:
            A JSON array of net names, e.g. ["GND", "VCC33", "USB_D+", ...]
        """
        response = await altium_bridge.call_script("get_all_nets", {})

        if not response.success:
            return json.dumps({"error": f"Failed to get nets: {response.error}"})

        # Result is already a JSON-serializable Python list
        return json.dumps(response.data, indent=2)

    @mcp.tool()
    async def create_net_class(class_name: str, net_names: list[str]) -> str:
        """
        Create a new net class and add specified nets to it

        Args:
            class_name: Name of the net class to create or modify
            net_names: List of net names to add to the class

        Returns:
            JSON object with the result of the operation
        """
        response = await altium_bridge.call_script("create_net_class", {
            "class_name": class_name,
            "net_names": net_names
        })

        if not response.success:
            return json.dumps({"success": False, "error": f"Failed to create net class: {response.error}"})

        return json.dumps(response.data, indent=2)
