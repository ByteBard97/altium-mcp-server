#!/usr/bin/env python3
"""
Test detailed nsg-parts-search data including sellers and pricing
"""
import os
from pathlib import Path
from dotenv import load_dotenv
import json

# Load environment variables from server/.env
env_path = Path(__file__).parent / "server" / ".env"
load_dotenv(env_path)

from nsgsearch import NSG_OctopartSearch

def test_detailed():
    """Test detailed data from NSG search"""

    # Initialize
    client_id = os.getenv("NEXAR_CLIENT_ID")
    client_secret = os.getenv("NEXAR_CLIENT_SECRET")

    search = NSG_OctopartSearch()
    search.setCredentials(client_id, client_secret)
    search.startClient()

    # Search
    parts_list = ["STM32F103C8T6"]
    results = search.partsSearch(parts_list)

    if "STM32F103C8T6" in results and results["STM32F103C8T6"]["found"]:
        data = results["STM32F103C8T6"]["data"]

        print("=" * 70)
        print("DETAILED PART DATA")
        print("=" * 70)
        print()

        # Sellers/Availability
        print("SELLERS & AVAILABILITY:")
        print("-" * 70)
        sellers = data.get("sellers", [])
        for i, seller in enumerate(sellers[:5], 1):  # Top 5
            print(f"{i}. {seller}")
            print()

        # Pricing
        print()
        print("PRICING DATA:")
        print("-" * 70)
        print(f"Median Price @ 1000: {data.get('medianPrice1000')}")
        print()

        # Similar parts (alternatives)
        print()
        print("SIMILAR PARTS (Alternatives):")
        print("-" * 70)
        similar = data.get("similarParts", [])
        print(f"Found {len(similar)} similar parts")
        for i, part in enumerate(similar[:3], 1):
            print(f"{i}. {part}")
            print()

        # Full data dump to see structure
        print()
        print("FULL SELLERS DATA STRUCTURE:")
        print("-" * 70)
        if sellers:
            print(json.dumps(sellers[0], indent=2, default=str))

if __name__ == "__main__":
    test_detailed()
