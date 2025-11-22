#!/usr/bin/env python3
"""Test API search in async context similar to MCP"""
import sys
import asyncio
from pathlib import Path

# Add server directory to path
sys.path.insert(0, str(Path(__file__).parent / "server"))

from server.tools.api_search_tools import run_with_timeout, get_vector_db

async def simulate_mcp_call():
    """Simulate how MCP would call the tool"""
    print("=" * 70)
    print("Simulating MCP Async Context")
    print("=" * 70)
    print("\nThis mimics how FastMCP calls async tools...\n")

    try:
        # This is exactly what the real tool does
        print("1. Getting event loop...")
        loop = asyncio.get_event_loop()
        print(f"   Event loop: {loop}")

        print("\n2. Initializing database with timeout...")
        db = await run_with_timeout(get_vector_db, 10.0)
        print("   [OK] Database initialized\n")

        print("3. Running query with timeout...")
        results = await run_with_timeout(
            db.query, 5.0,
            "move component", 5, filter_dict=None
        )
        print("   [OK] Query completed\n")

        print("4. Formatting results...")
        num_results = len(results.get('documents', [[]])[0])
        print(f"   Found {num_results} results\n")

        if results.get('metadatas') and results['metadatas'][0]:
            print("   Top 3 results:")
            for i, meta in enumerate(results['metadatas'][0][:3], 1):
                name = meta.get('full_name', meta.get('name', 'Unknown'))
                print(f"     {i}. {name}")

        print("\n" + "=" * 70)
        print("SUCCESS: Test completed in async context!")
        print("=" * 70)
        return True

    except asyncio.TimeoutError as e:
        print(f"\n[TIMEOUT] {e}")
        print("\nThis means the operation is hanging in async context!")
        return False
    except Exception as e:
        print(f"\n[ERROR] {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    print("\nNote: Watch for log messages with timestamps - they show internal progress\n")
    result = asyncio.run(simulate_mcp_call())
    sys.exit(0 if result else 1)
