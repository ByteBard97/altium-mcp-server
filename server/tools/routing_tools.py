"""
Routing tool handlers
"""
import json
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from mcp.server.fastmcp import FastMCP
    from ..altium_bridge import AltiumBridge


def register_routing_tools(mcp: "FastMCP", altium_bridge: "AltiumBridge"):
    """Register all routing tools"""

    @mcp.tool()
    async def route_trace(x1: float, y1: float, x2: float, y2: float, layer: str, width: float, net_name: str = None) -> str:
        """
        Route a trace between two points on a specified layer

        Args:
            x1: Starting X coordinate in millimeters
            y1: Starting Y coordinate in millimeters
            x2: Ending X coordinate in millimeters
            y2: Ending Y coordinate in millimeters
            layer: Layer name (e.g., "TopLayer", "BottomLayer", "MidLayer1")
            width: Trace width in millimeters
            net_name: Optional net name to assign to the trace

        Returns:
            JSON object with success status and trace ID
        """
        params = {
            "x1": x1,
            "y1": y1,
            "x2": x2,
            "y2": y2,
            "layer": layer,
            "width": width
        }

        if net_name is not None:
            params["net_name"] = net_name

        response = await altium_bridge.call_script("route_trace", params)

        if not response.success:
            return json.dumps({"success": False, "error": f"Failed to route trace: {response.error}"})

        return json.dumps({"success": True, "data": response.data}, indent=2)

    @mcp.tool()
    async def add_via(x: float, y: float, diameter: float, hole_size: float, start_layer: str = "TopLayer", end_layer: str = "BottomLayer", net_name: str = None) -> str:
        """
        Place a via at specified coordinates

        Args:
            x: X coordinate in millimeters
            y: Y coordinate in millimeters
            diameter: Via diameter (pad size) in millimeters
            hole_size: Via hole diameter in millimeters
            start_layer: Starting layer name (default: "TopLayer")
            end_layer: Ending layer name (default: "BottomLayer")
            net_name: Optional net name to assign to the via

        Returns:
            JSON object with success status and via ID
        """
        params = {
            "x": x,
            "y": y,
            "diameter": diameter,
            "hole_size": hole_size,
            "start_layer": start_layer,
            "end_layer": end_layer
        }

        if net_name is not None:
            params["net_name"] = net_name

        response = await altium_bridge.call_script("add_via", params)

        if not response.success:
            return json.dumps({"success": False, "error": f"Failed to add via: {response.error}"})

        return json.dumps({"success": True, "data": response.data}, indent=2)

    @mcp.tool()
    async def add_copper_pour(x: float, y: float, width: float, height: float, layer: str, net_name: str, pour_over_same_net: bool = True) -> str:
        """
        Create a copper pour (filled polygon zone) on the PCB

        Args:
            x: X coordinate of bottom-left corner in millimeters
            y: Y coordinate of bottom-left corner in millimeters
            width: Width of the copper pour in millimeters
            height: Height of the copper pour in millimeters
            layer: Layer name (e.g., "TopLayer", "BottomLayer")
            net_name: Net name to assign to the copper pour (typically "GND" or a power net)
            pour_over_same_net: Whether to pour over objects on the same net (default: True)

        Returns:
            JSON object with success status and polygon ID
        """
        response = await altium_bridge.call_script("add_copper_pour", {
            "x": x,
            "y": y,
            "width": width,
            "height": height,
            "layer": layer,
            "net_name": net_name,
            "pour_over_same_net": pour_over_same_net
        })

        if not response.success:
            return json.dumps({"success": False, "error": f"Failed to add copper pour: {response.error}"})

        return json.dumps({"success": True, "data": response.data}, indent=2)
