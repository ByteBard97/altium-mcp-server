"""Test API search performance directly"""
import time
import sys
from pathlib import Path

# Add to path
sys.path.insert(0, str(Path(__file__).parent))

from build_vector_db import AltiumAPIVectorDB

def test_search():
    print("Initializing database...")
    start = time.time()

    db_path = Path(__file__).parent / "server" / "chroma_db"
    print(f"Database path: {db_path}")
    print(f"Exists: {db_path.exists()}")

    db = AltiumAPIVectorDB(db_path=str(db_path))
    init_time = time.time() - start
    print(f"[OK] Database initialized in {init_time:.2f}s\n")

    # Test queries
    queries = [
        "move component to coordinates",
        "iterate all components on board",
        "convert integer to string",
        "get current PCB board"
    ]

    for query in queries:
        print(f"Query: '{query}'")
        start = time.time()

        results = db.query(query, n_results=5)

        query_time = time.time() - start
        num_results = len(results['documents'][0]) if results['documents'] else 0

        print(f"  Time: {query_time:.2f}s")
        print(f"  Results: {num_results}")

        if num_results > 0:
            for i, (meta, dist) in enumerate(zip(results['metadatas'][0][:3], results['distances'][0][:3])):
                print(f"    {i+1}. {meta.get('full_name', meta.get('name'))} (distance: {dist:.4f})")
        print()

if __name__ == "__main__":
    test_search()
