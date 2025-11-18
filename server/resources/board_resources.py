"""
Board-level resource handlers
"""
import json
import base64
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from mcp.server.fastmcp import FastMCP
    from ..altium_bridge import AltiumBridge


def register_board_resources(mcp: "FastMCP", altium_bridge: "AltiumBridge"):
    """Register all board-level resources"""

    @mcp.resource("altium://board/preview.png")
    async def get_board_preview() -> str:
        """Get board preview image as base64-encoded PNG"""
        result = await altium_bridge.call_script("take_view_screenshot", {"view_type": "pcb"})

        if not result.success:
            return json.dumps({
                "error": f"Failed to capture screenshot: {result.error}"
            }, indent=2)

        # The result should contain image_data as base64
        if isinstance(result.data, dict) and "image_data" in result.data:
            return json.dumps({
                "success": True,
                "image_format": "PNG",
                "encoding": "base64",
                "image_data": result.data["image_data"]
            }, indent=2)

        return json.dumps({
            "error": "Screenshot data format unexpected"
        }, indent=2)

    @mcp.resource("altium://board/preview")
    async def get_board_preview_json() -> str:
        """Get board preview metadata"""
        result = await altium_bridge.call_script("take_view_screenshot", {"view_type": "pcb"})

        if not result.success:
            return json.dumps({
                "error": f"Failed to capture screenshot: {result.error}"
            }, indent=2)

        # Return metadata without the full image
        metadata = {
            "success": result.success,
            "view_type": "pcb",
            "available": True
        }

        if isinstance(result.data, dict):
            metadata.update({
                "width": result.data.get("width"),
                "height": result.data.get("height"),
                "window_title": result.data.get("window_title")
            })

        return json.dumps(metadata, indent=2)
