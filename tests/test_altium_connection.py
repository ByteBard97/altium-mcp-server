#!/usr/bin/env python3
"""
Simple test to check if Altium is responding
"""
import sys
import asyncio
from pathlib import Path

# Add server directory to path
sys.path.insert(0, str(Path(__file__).parent / "server"))

from altium_bridge import AltiumBridge


async def test_connection():
    """Test basic Altium connection"""

    print("=" * 60)
    print("TESTING ALTIUM CONNECTION")
    print("=" * 60)
    print()

    # Initialize Altium bridge
    mcp_dir = Path(__file__).parent / "server"
    script_path = mcp_dir / "AltiumScript" / "Altium_API.PrjScr"

    print("[1/2] Initializing bridge...")
    bridge = AltiumBridge(mcp_dir, script_path)
    print("      [OK] Bridge initialized")
    print()

    # Try a simple command
    print("[2/2] Testing simple command (list_component_libraries)...")
    try:
        response = await bridge.call_script("list_component_libraries", {})

        if response.success:
            print("      [OK] Altium responded!")
            print(f"      Response: {str(response.data)[:200]}...")
            print()
            print("=" * 60)
            print("CONNECTION TEST PASSED!")
            print("=" * 60)
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
    result = asyncio.run(test_connection())
    sys.exit(0 if result else 1)
