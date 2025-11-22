#!/usr/bin/env python3
"""Direct test of API search tool function"""
import sys
import asyncio
from pathlib import Path

# Add server to path
sys.path.insert(0, str(Path(__file__).parent / "server"))

async def test_search():
    """Test the search function directly"""
    from tools.api_search_tools import get_vector_db

    print("Testing direct vector DB query...")
    db = get_vector_db()
    results = db.query("move component to position", n_results=3)

    print("\nResults from vector DB:")
    print(f"  Documents: {len(results['documents'][0]) if results['documents'] else 0}")
    print(f"  Metadatas: {len(results['metadatas'][0]) if results['metadatas'] else 0}")

    if results['metadatas'] and results['metadatas'][0]:
        print("\n  First result:")
        print(f"    {results['metadatas'][0][0]}")

    # Now test through the registered tool function
    print("\n" + "="*70)
    print("Testing through MCP tool function...")
    print("="*70)

    from tools.api_search_tools import register_api_search_tools
    from mcp.server.fastmcp import FastMCP

    mcp = FastMCP("TestServer")
    register_api_search_tools(mcp)

    # Call the tool
    result = await mcp.call_tool("search_delphiscript_api", {
        "query": "move component to position",
        "n_results": 3
    })

    print("\nMCP Tool Result:")
    print(f"  Type: {type(result)}")
    print(f"  Content: {result}")

if __name__ == "__main__":
    asyncio.run(test_search())
