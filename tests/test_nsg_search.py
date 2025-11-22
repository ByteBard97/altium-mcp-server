#!/usr/bin/env python3
"""
Test nsg-parts-search library
"""
import os
from pathlib import Path
from dotenv import load_dotenv
import json

# Load environment variables from server/.env
env_path = Path(__file__).parent / "server" / ".env"
load_dotenv(env_path)

from nsgsearch import NSG_OctopartSearch

def test_nsg_search():
    """Test NSG parts search library"""

    print("=" * 70)
    print("TESTING NSG-PARTS-SEARCH LIBRARY")
    print("=" * 70)
    print()

    # Get credentials
    client_id = os.getenv("NEXAR_CLIENT_ID")
    client_secret = os.getenv("NEXAR_CLIENT_SECRET")

    if not client_id or not client_secret:
        print("ERROR: NEXAR_CLIENT_ID or NEXAR_CLIENT_SECRET not set")
        return

    print("[OK] Credentials loaded from .env")
    print()

    # Initialize search client
    search = NSG_OctopartSearch()
    search.setCredentials(client_id, client_secret)
    search.startClient()

    print("[OK] NSG client initialized")
    print()

    # Test search for a common part
    print("[TEST] Searching for STM32F103C8T6...")
    print("-" * 70)

    parts_list = ["STM32F103C8T6"]
    results = search.partsSearch(parts_list)

    print("Results structure:")
    print(json.dumps(results, indent=2, default=str)[:2000])
    print()

    if "STM32F103C8T6" in results:
        part_data = results["STM32F103C8T6"]
        print(f"Found: {part_data.get('found')}")

        if part_data.get('found'):
            data = part_data.get('data', {})
            print(f"Manufacturer: {data.get('manufacturer', 'N/A')}")
            print(f"Description: {data.get('shortDescription', 'N/A')[:100]}")

            # Check what fields are available
            print()
            print("Available fields:")
            for key in data.keys():
                print(f"  - {key}")

    print()
    print("=" * 70)
    print("TEST COMPLETE")
    print("=" * 70)

if __name__ == "__main__":
    test_nsg_search()
