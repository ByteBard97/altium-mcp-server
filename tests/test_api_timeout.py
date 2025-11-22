#!/usr/bin/env python3
"""Test API search with timeout"""
import sys
import asyncio
from pathlib import Path

# Add server directory to path
sys.path.insert(0, str(Path(__file__).parent / "server"))

async def test_api_search():
    """Test the API search with timeout"""
    from server.tools.api_search_tools import run_with_timeout, get_vector_db

    print("Testing API search with timeout...")
    print(f"DB Init Timeout: 10.0s")
    print(f"Query Timeout: 5.0s\n")

    try:
        print("1. Initializing database (max 10s)...")
        db = await run_with_timeout(get_vector_db, 10.0)
        print("   [OK] Database initialized successfully\n")

        print("2. Running test query: 'move component' (max 5s)...")
        results = await run_with_timeout(
            db.query, 5.0,
            "move component", 5, filter_dict=None
        )
        print(f"   [OK] Query completed successfully")
        print(f"   Found {len(results.get('documents', [[]])[0])} results\n")

        # Show top results
        if results.get('metadatas') and results['metadatas'][0]:
            print("   Top 3 results:")
            for i, meta in enumerate(results['metadatas'][0][:3], 1):
                name = meta.get('full_name', meta.get('name', 'Unknown'))
                category = meta.get('category', 'unknown')
                print(f"     {i}. {name} ({category})")

        print("\n[OK] All tests passed!")
        return True

    except TimeoutError as e:
        print(f"   [TIMEOUT] {e}")
        return False
    except Exception as e:
        print(f"   [ERROR] {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    result = asyncio.run(test_api_search())
    sys.exit(0 if result else 1)
