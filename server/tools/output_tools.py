"""
Output job-related tool handlers
"""
import json
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from mcp.server.fastmcp import FastMCP
    from ..altium_bridge import AltiumBridge


def register_output_tools(mcp: "FastMCP", altium_bridge: "AltiumBridge"):
    """Register all output-related tools"""

    @mcp.tool()
    async def get_output_job_containers() -> str:
        """
        Get all available output job containers from a specified OutJob file

        Returns:
            JSON array with all output job containers and their properties
        """
        response = await altium_bridge.call_script("get_output_job_containers", {})

        if not response.success:
            return json.dumps({"error": f"Failed to get output job containers: {response.error}"})

        containers_data = response.data

        if not containers_data:
            return json.dumps({"message": "No output job containers found"})

        # Response is already in JSON format
        return json.dumps(containers_data, indent=2) if isinstance(containers_data, dict) else containers_data

    @mcp.tool()
    async def run_output_jobs(container_names: list[str]) -> str:
        """
        Run specified output job containers

        Args:
            container_names: List of container names to run

        Returns:
            JSON object with results of running the output jobs
        """
        response = await altium_bridge.call_script("run_output_jobs", {"container_names": container_names})

        if not response.success:
            return json.dumps({"error": f"Failed to run output jobs: {response.error}"})

        result_data = response.data

        # If result_data is a string, it's already in JSON format
        if isinstance(result_data, str):
            return result_data

        # Otherwise, convert to JSON
        return json.dumps(result_data, indent=2)

    @mcp.tool()
    async def get_server_status() -> str:
        """Get the current status of the Altium MCP server"""
        import os

        status = {
            "server": "Running",
            "altium_exe": altium_bridge.config.altium_exe_path,
            "script_path": altium_bridge.config.script_path,
            "altium_found": os.path.exists(altium_bridge.config.altium_exe_path) if altium_bridge.config.altium_exe_path else False,
            "script_found": os.path.exists(altium_bridge.config.script_path) if altium_bridge.config.script_path else False,
            "bridge_status": altium_bridge.status
        }

        return json.dumps(status, indent=2)
