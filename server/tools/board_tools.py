"""
Board initialization tool handlers
"""
import json
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from mcp.server.fastmcp import FastMCP
    from ..altium_bridge import AltiumBridge


def register_board_tools(mcp: "FastMCP", altium_bridge: "AltiumBridge"):
    """Register all board initialization tools"""

    @mcp.tool()
    async def set_board_size(width: float, height: float) -> str:
        """
        Set the size of the PCB board

        Args:
            width: Board width in millimeters
            height: Board height in millimeters

        Returns:
            JSON object with success status
        """
        response = await altium_bridge.call_script("set_board_size", {
            "width": width,
            "height": height
        })

        if not response.success:
            return json.dumps({"success": False, "error": f"Failed to set board size: {response.error}"})

        return json.dumps({"success": True, "data": response.data}, indent=2)

    @mcp.tool()
    async def add_board_outline(x: float, y: float, width: float, height: float) -> str:
        """
        Add a rectangular board outline to the PCB

        Args:
            x: X coordinate of bottom-left corner in millimeters
            y: Y coordinate of bottom-left corner in millimeters
            width: Width of the board outline in millimeters
            height: Height of the board outline in millimeters

        Returns:
            JSON object with success status
        """
        response = await altium_bridge.call_script("add_board_outline", {
            "x": x,
            "y": y,
            "width": width,
            "height": height
        })

        if not response.success:
            return json.dumps({"success": False, "error": f"Failed to add board outline: {response.error}"})

        return json.dumps({"success": True, "data": response.data}, indent=2)

    @mcp.tool()
    async def add_mounting_hole(x: float, y: float, hole_diameter: float, pad_diameter: float = None) -> str:
        """
        Add a mounting hole to the PCB board

        Args:
            x: X coordinate in millimeters
            y: Y coordinate in millimeters
            hole_diameter: Diameter of the hole in millimeters
            pad_diameter: Diameter of the pad (optional, defaults to hole_diameter * 2)

        Returns:
            JSON object with success status and hole ID
        """
        params = {
            "x": x,
            "y": y,
            "hole_diameter": hole_diameter
        }

        if pad_diameter is not None:
            params["pad_diameter"] = pad_diameter

        response = await altium_bridge.call_script("add_mounting_hole", params)

        if not response.success:
            return json.dumps({"success": False, "error": f"Failed to add mounting hole: {response.error}"})

        return json.dumps({"success": True, "data": response.data}, indent=2)

    @mcp.tool()
    async def add_board_text(text: str, x: float, y: float, layer: str = "TopOverlay", size: float = 1.0) -> str:
        """
        Add text to the PCB board

        Args:
            text: Text string to add
            x: X coordinate in millimeters
            y: Y coordinate in millimeters
            layer: Layer name (default: "TopOverlay", can be "TopOverlay", "BottomOverlay", "TopSilkScreen", etc.)
            size: Text size in millimeters (default: 1.0)

        Returns:
            JSON object with success status and text ID
        """
        response = await altium_bridge.call_script("add_board_text", {
            "text": text,
            "x": x,
            "y": y,
            "layer": layer,
            "size": size
        })

        if not response.success:
            return json.dumps({"success": False, "error": f"Failed to add board text: {response.error}"})

        return json.dumps({"success": True, "data": response.data}, indent=2)

    @mcp.tool()
    async def get_board_outline() -> str:
        """
        Get the PCB board outline polygon coordinates

        Returns the board outline as an array of [x, y] coordinate pairs in mils.
        The outline is extracted from the actual board outline object in Altium,
        including support for arcs (approximated as line segments).

        Useful for:
        - Understanding actual board shape and dimensions
        - Calculating board area
        - Exporting board outline to other tools
        - Verifying board outline matches mechanical requirements
        - Visualizing board shape

        Returns:
            JSON array of coordinate pairs: [[x1, y1], [x2, y2], ...]
            Coordinates are in mils relative to board origin

        Example output:
            [
                [0, 0],
                [1000, 0],
                [1000, 800],
                [0, 800]
            ]
        """
        response = await altium_bridge.call_script("get_board_outline", {})

        if not response.success:
            return json.dumps({"success": False, "error": f"Failed to get board outline: {response.error}"})

        # Response.data is already the array of coordinate pairs
        return json.dumps(response.data, indent=2)
