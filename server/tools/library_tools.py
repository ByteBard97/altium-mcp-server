"""
Library search and component discovery tool handlers
"""
import json
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from mcp.server.fastmcp import FastMCP
    from ..altium_bridge import AltiumBridge


def register_library_tools(mcp: "FastMCP", altium_bridge: "AltiumBridge"):
    """Register all library search and component discovery tools"""

    @mcp.tool()
    async def list_component_libraries() -> str:
        """
        List all available component libraries

        Returns:
            JSON array with library names, paths, and types
        """
        response = await altium_bridge.call_script("list_component_libraries", {})

        if not response.success:
            return json.dumps({
                "success": False,
                "error": f"Failed to list libraries: {response.error}"
            })

        return json.dumps({
            "success": True,
            "data": response.data
        }, indent=2)

    @mcp.tool()
    async def search_components(query: str) -> str:
        """
        Search for components across all loaded libraries

        Args:
            query: Search query string (matches component name and description)

        Returns:
            JSON array with matching components including name, description, library, and footprint
        """
        response = await altium_bridge.call_script("search_components", {
            "query": query
        })

        if not response.success:
            return json.dumps({
                "success": False,
                "error": f"Failed to search components: {response.error}"
            })

        return json.dumps({
            "success": True,
            "query": query,
            "data": response.data
        }, indent=2)

    @mcp.tool()
    async def get_component_from_library(library_name: str, component_name: str) -> str:
        """
        Get detailed information about a specific component from a library

        Args:
            library_name: Name of the library containing the component
            component_name: Name of the component to retrieve

        Returns:
            JSON object with component details including pins, parameters, and footprint
        """
        response = await altium_bridge.call_script("get_component_from_library", {
            "library_name": library_name,
            "component_name": component_name
        })

        if not response.success:
            return json.dumps({
                "success": False,
                "error": f"Failed to get component: {response.error}"
            })

        return json.dumps({
            "success": True,
            "data": response.data
        }, indent=2)

    @mcp.tool()
    async def search_footprints(query: str) -> str:
        """
        Search for footprints across all loaded PCB libraries

        Args:
            query: Search query string (matches footprint name and description)

        Returns:
            JSON array with matching footprints including name, library, and dimensions
        """
        response = await altium_bridge.call_script("search_footprints", {
            "query": query
        })

        if not response.success:
            return json.dumps({
                "success": False,
                "error": f"Failed to search footprints: {response.error}"
            })

        return json.dumps({
            "success": True,
            "query": query,
            "data": response.data
        }, indent=2)
