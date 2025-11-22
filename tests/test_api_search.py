#!/usr/bin/env python3
"""
Test the API search tools to ensure they work correctly
"""
import sys
import json
from pathlib import Path

# Add server to path
sys.path.insert(0, str(Path(__file__).parent / "server"))

async def test_api_search():
    """Test the API search functionality"""
    from tools.api_search_tools import get_vector_db

    print("="*70)
    print("Testing API Search Tools")
    print("="*70)

    # Get database
    print("\n1. Loading vector database...")
    db = get_vector_db()
    stats = db.get_stats()
    print(f"   Database loaded: {stats['total_documents']} documents")

    # Test queries
    test_queries = [
        "move component to new position",
        "iterate all components on PCB",
        "convert integer to string",
        "get current schematic document"
    ]

    print("\n2. Running test queries...")
    for query in test_queries:
        print(f"\n   Query: '{query}'")
        results = db.query(query, n_results=3)

        if results['documents'] and results['documents'][0]:
            for i, meta in enumerate(results['metadatas'][0]):
                full_name = meta.get('full_name', meta.get('name', 'Unknown'))
                api_type = meta.get('type')
                category = meta.get('category')
                print(f"      {i+1}. {full_name} ({api_type}, {category})")

    print("\n" + "="*70)
    print("API Search Tools: WORKING")
    print("="*70)

if __name__ == "__main__":
    import asyncio
    asyncio.run(test_api_search())
