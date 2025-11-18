"""
Project-level resource handlers
"""
import json
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from mcp.server.fastmcp import FastMCP
    from ..altium_bridge import AltiumBridge


def register_project_resources(mcp: "FastMCP", altium_bridge: "AltiumBridge"):
    """Register all project-level resources"""

    @mcp.resource("altium://project/current/info")
    async def get_project_info() -> str:
        """Get current project metadata"""
        result = await altium_bridge.call_script("get_project_info", {})
        return result.to_json()

    @mcp.resource("altium://project/current/components")
    async def get_all_components() -> str:
        """Get all components with properties"""
        # Get all component data
        result = await altium_bridge.call_script("get_all_component_data", {})

        if not result.success:
            return json.dumps({"error": "Failed to get components"}, indent=2)

        return json.dumps({"components": result.data}, indent=2)

    @mcp.resource("altium://project/current/nets")
    async def get_all_nets() -> str:
        """Get all electrical nets"""
        result = await altium_bridge.call_script("get_all_nets", {})
        return result.to_json()

    @mcp.resource("altium://project/current/layers")
    async def get_layer_stack() -> str:
        """Get PCB layer configuration"""
        result = await altium_bridge.call_script("get_pcb_layers", {})
        return result.to_json()

    @mcp.resource("altium://project/current/stackup")
    async def get_layer_stackup() -> str:
        """Get detailed stackup with impedance data"""
        result = await altium_bridge.call_script("get_pcb_layer_stackup", {})
        return result.to_json()

    @mcp.resource("altium://project/current/rules")
    async def get_design_rules() -> str:
        """Get all design rules"""
        result = await altium_bridge.call_script("get_pcb_rules", {})
        return result.to_json()
