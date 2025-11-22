#!/usr/bin/env python3
"""
Quick test of distributor integration via Nexar client
"""
import asyncio
import sys
import json
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables from server/.env
env_path = Path(__file__).parent / "server" / ".env"
load_dotenv(env_path)

# Add server directory to path
server_dir = Path(__file__).parent / "server"
sys.path.insert(0, str(server_dir))

from nexar_client import NexarClient

async def test_nexar():
    """Test Nexar API client"""

    print("=" * 70)
    print("TESTING NEXAR DISTRIBUTOR INTEGRATION")
    print("=" * 70)
    print()

    # Initialize client
    client = NexarClient()

    if not client.is_configured():
        print("ERROR: Nexar API not configured!")
        print("Please set NEXAR_CLIENT_ID and NEXAR_CLIENT_SECRET in .env")
        return

    print(f"[OK] Nexar client configured")
    print()

    # Test 1: Search for a common component
    print("[TEST 1] Searching for STM32F103C8T6 microcontroller...")
    print("-" * 70)
    try:
        results = await client.search_component("STM32F103C8T6", limit=3)

        if results and "results" in results:
            parts = results["results"]
            print(f"Found {len(parts)} results:")
            print()

            for i, result in enumerate(parts, 1):
                part = result.get("part", {})
                manufacturer = part.get("manufacturer", {})
                sellers = part.get("sellers", [])

                total_stock = sum(
                    offer.get("inventoryLevel", 0)
                    for seller in sellers
                    for offer in seller.get("offers", [])
                )

                print(f"{i}. MPN: {part.get('mpn')}")
                print(f"   Manufacturer: {manufacturer.get('name')}")
                print(f"   Description: {part.get('description', 'N/A')[:80]}")
                print(f"   Total Stock: {total_stock:,}")
                print(f"   Distributors: {len(sellers)}")
                print()
        else:
            print("No results found")
            print()

    except Exception as e:
        print(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
        print()

    # Test 2: Get detailed availability
    print("[TEST 2] Getting detailed availability for STM32F103C8T6...")
    print("-" * 70)
    try:
        details = await client.get_component_details("STM32F103C8T6")

        if details:
            part = details.get("part", {})
            sellers = part.get("sellers", [])

            print(f"MPN: {part.get('mpn')}")
            print(f"Manufacturer: {part.get('manufacturer', {}).get('name')}")
            print()
            print("Stock by Distributor:")

            for seller in sellers[:5]:  # Top 5 distributors
                offers = seller.get("offers", [])
                if offers:
                    offer = offers[0]
                    print(f"  • {seller.get('company', {}).get('name', 'Unknown'):15s}: "
                          f"{offer.get('inventoryLevel', 0):8,} units @ "
                          f"${offer.get('prices', [{}])[0].get('price', 0):.4f}")
            print()
        else:
            print("No details found")
            print()

    except Exception as e:
        print(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
        print()

    print("=" * 70)
    print("TEST COMPLETE")
    print("=" * 70)

if __name__ == "__main__":
    asyncio.run(test_nexar())
