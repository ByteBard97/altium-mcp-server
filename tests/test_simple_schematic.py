#!/usr/bin/env python3
"""
Simple test to check if we can get basic project info
"""
import sys
import asyncio
from pathlib import Path

# Add server directory to path
sys.path.insert(0, str(Path(__file__).parent / "server"))

from altium_bridge import AltiumBridge


async def test_project():
    """Test if project is open"""

    print("=" * 60)
    print("CHECKING ALTIUM PROJECT STATUS")
    print("=" * 60)
    print()

    # Initialize Altium bridge
    mcp_dir = Path(__file__).parent / "server"
    script_path = mcp_dir / "AltiumScript" / "Altium_API.PrjScr"

    print("[1/3] Initializing bridge...")
    bridge = AltiumBridge(mcp_dir, script_path)
    print("      [OK]")
    print()

    # Check if project is open
    print("[2/3] Checking if project is open...")
    try:
        response = await bridge.call_script("get_project_info", {})

        if response.success:
            print("      [OK] Project is open!")
            print(f"      Data: {response.data}")
        else:
            print(f"      [ERROR] {response.error}")
            print("\n      NOTE: Please open an Altium project before testing the schematic DSL")
            return False

    except Exception as e:
        print(f"      [ERROR] {e}")
        return False

    # Try getting schematic components (simpler than whole design)
    print()
    print("[3/3] Testing get_schematic_components_with_parameters...")
    try:
        response = await bridge.call_script("get_schematic_components_with_parameters", {})

        if response.success:
            print("      [OK] Got schematic data!")
            import json
            data = response.data
            if isinstance(data, str) and data.startswith("Result written to"):
                print(f"      {data}")
            else:
                print(f"      Component count: {len(data) if isinstance(data, list) else 'N/A'}")
            return True
        else:
            print(f"      [ERROR] {response.error}")
            return False

    except Exception as e:
        print(f"      [ERROR] {e}")
        import traceback
        traceback.print_exc()
        return False


if __name__ == "__main__":
    result = asyncio.run(test_project())
    sys.exit(0 if result else 1)
