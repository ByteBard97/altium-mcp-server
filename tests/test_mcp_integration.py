#!/usr/bin/env python3
"""
Test that API search tools are properly integrated in the MCP server
"""
import sys
from pathlib import Path

# Add server to path
sys.path.insert(0, str(Path(__file__).parent / "server"))

async def test_mcp_tools():
    """Test the MCP tool registrations"""
    print("="*70)
    print("Testing MCP Server Integration")
    print("="*70)

    # Import and check tool registration
    from tools import register_api_search_tools
    from mcp.server.fastmcp import FastMCP

    print("\n1. Creating test MCP server...")
    mcp = FastMCP("TestServer")

    print("2. Registering API search tools...")
    register_api_search_tools(mcp)

    print("3. Checking registered tools...")
    # Get list of tools (FastMCP 2.0 way)
    tool_list = await mcp.list_tools()

    # Check for our tools
    expected_tools = [
        'search_delphiscript_api',
        'get_api_type_details',
        'list_delphi_stdlib_functions'
    ]

    # Handle both list and object with .tools attribute
    if isinstance(tool_list, list):
        registered_tool_names = [tool.name for tool in tool_list]
    else:
        registered_tool_names = [tool.name for tool in tool_list.tools]

    print(f"\n   Total tools registered: {len(registered_tool_names)}")
    print(f"\n   API search tools found:")

    all_found = True
    for tool_name in expected_tools:
        found = tool_name in registered_tool_names
        status = "OK" if found else "MISSING"
        print(f"      [{status}] {tool_name}")
        if not found:
            all_found = False

    if all_found:
        print("\n" + "="*70)
        print("SUCCESS: All API search tools are registered in MCP server")
        print("="*70)
        return True
    else:
        print("\n" + "="*70)
        print("ERROR: Some tools are missing")
        print("="*70)
        return False

if __name__ == "__main__":
    import asyncio
    import os

    # Set Python path for imports
    os.environ['PYTHONPATH'] = str(Path(__file__).parent / "server")

    success = asyncio.run(test_mcp_tools())
    sys.exit(0 if success else 1)
