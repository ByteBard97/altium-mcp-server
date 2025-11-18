#!/usr/bin/env python3
"""
Altium MCP Server v2.0
Modernized to use FastMCP 2.0 with modular architecture
"""

# --- force Python to treat server\lib as a site-directory ---
import pathlib
import site
site.addsitedir(str(pathlib.Path(__file__).with_name("lib")))
# ------------------------------------------------------------

from mcp.server.fastmcp import FastMCP
import logging
from pathlib import Path

# Import our modules
from altium_bridge import AltiumBridge
from resources import register_project_resources, register_board_resources
from tools import (
    register_component_tools,
    register_component_ops_tools,
    register_net_tools,
    register_layer_tools,
    register_schematic_tools,
    register_layout_tools,
    register_output_tools,
    register_project_tools,
    register_library_tools,
    register_analysis_tools,
    register_board_tools,
    register_routing_tools
)
from prompts import register_workflow_prompts

# Configure logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler('altium_mcp.log')
    ]
)
logger = logging.getLogger("AltiumMCPServer")

# Set MCP_DIR to the directory of the current Python file
MCP_DIR = Path(__file__).parent
DEFAULT_SCRIPT_PATH = MCP_DIR / "AltiumScript" / "Altium_API.PrjScr"

# Initialize FastMCP server
mcp = FastMCP(
    "AltiumMCP",
    version="2.0.0",
    description="AI-assisted PCB design with Altium Designer using FastMCP 2.0"
)

# Initialize Altium bridge (manages DelphiScript communication)
altium_bridge = AltiumBridge(MCP_DIR, DEFAULT_SCRIPT_PATH)

# ============================================================================
# REGISTER RESOURCES - Read-only project state
# ============================================================================
logger.info("Registering resources...")
register_project_resources(mcp, altium_bridge)
register_board_resources(mcp, altium_bridge)

# ============================================================================
# REGISTER TOOLS - Actions that modify the design
# ============================================================================
logger.info("Registering tools...")
register_component_tools(mcp, altium_bridge)
register_component_ops_tools(mcp, altium_bridge)
register_net_tools(mcp, altium_bridge)
register_layer_tools(mcp, altium_bridge)
register_schematic_tools(mcp, altium_bridge)
register_layout_tools(mcp, altium_bridge)
register_output_tools(mcp, altium_bridge)
register_project_tools(mcp, altium_bridge)
register_library_tools(mcp, altium_bridge)
register_analysis_tools(mcp, altium_bridge)
register_board_tools(mcp, altium_bridge)
register_routing_tools(mcp, altium_bridge)

# ============================================================================
# REGISTER PROMPTS - Guided workflows
# ============================================================================
logger.info("Registering prompts...")
register_workflow_prompts(mcp)

# ============================================================================
# LIFECYCLE MANAGEMENT
# ============================================================================

@mcp.on_initialize()
async def on_initialize():
    """Called when MCP client connects"""
    await altium_bridge.initialize()
    logger.info("Altium MCP Server v2.0 initialized")
    logger.info(f"Altium bridge status: {altium_bridge.status}")


@mcp.on_shutdown()
async def on_shutdown():
    """Called when MCP client disconnects"""
    await altium_bridge.cleanup()
    logger.info("Altium MCP Server shutdown complete")


# ============================================================================
# MAIN ENTRY POINT
# ============================================================================

def main():
    """Run the MCP server"""
    logger.info("Starting Altium MCP Server v2.0...")
    logger.info(f"Using MCP directory: {MCP_DIR}")

    # Initialize the directory
    MCP_DIR.mkdir(exist_ok=True)

    # Create the AltiumScript directory if it doesn't exist
    script_dir = MCP_DIR / "AltiumScript"
    script_dir.mkdir(exist_ok=True)

    # Print status
    print(f"Altium MCP Server v2.0")
    print(f"MCP Directory: {MCP_DIR}")
    print(f"Script Path: {DEFAULT_SCRIPT_PATH}")

    # Run with stdio transport (default for Claude Desktop)
    mcp.run(transport='stdio')


if __name__ == "__main__":
    main()
