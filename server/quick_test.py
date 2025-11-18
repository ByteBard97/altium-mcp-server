#!/usr/bin/env python3
"""
Quick test - Tests the most common tools without user interaction
Requires: Altium running with a PCB project open
"""
import asyncio
import json
from pathlib import Path
from altium_bridge import AltiumBridge

async def quick_test():
    print("\n" + "="*60)
    print("ALTIUM MCP QUICK TEST")
    print("="*60)
    print("\nTesting basic functionality...")
    print("Prerequisites: Altium running with PCB project open\n")

    # Setup paths
    mcp_dir = Path(__file__).parent
    default_script_path = mcp_dir / "AltiumScript" / "Altium_API.PrjScr"

    bridge = AltiumBridge(mcp_dir, default_script_path)
    await bridge.initialize()

    tests_passed = 0
    tests_failed = 0

    # Test 1: Get all component data
    print("\n[1/5] Testing: Get All Component Data...")
    try:
        result = await bridge.call_script("get_all_component_data", {})
        if result.success and isinstance(result.data, list):
            print(f"[PASSED] - Found {len(result.data)} components")
            tests_passed += 1
        else:
            print(f"[FAILED] - {result.error}")
            tests_failed += 1
    except Exception as e:
        print(f"[FAILED] - Exception: {e}")
        tests_failed += 1

    # Test 2: Get all nets
    print("\n[2/5] Testing: Get All Nets...")
    try:
        result = await bridge.call_script("get_all_nets", {})
        if result.success and isinstance(result.data, list):
            print(f"[PASSED] - Found {len(result.data)} nets")
            tests_passed += 1
        else:
            print(f"[FAILED] - {result.error}")
            tests_failed += 1
    except Exception as e:
        print(f"[FAILED] - Exception: {e}")
        tests_failed += 1

    # Test 3: Get PCB layers
    print("\n[3/5] Testing: Get PCB Layers...")
    try:
        result = await bridge.call_script("get_pcb_layers", {})
        if result.success:
            print(f"[PASSED] - Retrieved layer data")
            tests_passed += 1
        else:
            print(f"[FAILED] - {result.error}")
            tests_failed += 1
    except Exception as e:
        print(f"[FAILED] - Exception: {e}")
        tests_failed += 1

    # Test 4: Get PCB rules
    print("\n[4/5] Testing: Get PCB Rules...")
    try:
        result = await bridge.call_script("get_pcb_rules", {})
        if result.success:
            print(f"[PASSED] - Retrieved design rules")
            tests_passed += 1
        else:
            print(f"[FAILED] - {result.error}")
            tests_failed += 1
    except Exception as e:
        print(f"[FAILED] - Exception: {e}")
        tests_failed += 1

    # Test 5: Get layer stackup
    print("\n[5/5] Testing: Get Layer Stackup...")
    try:
        result = await bridge.call_script("get_pcb_layer_stackup", {})
        if result.success:
            print(f"[PASSED] - Retrieved stackup data")
            tests_passed += 1
        else:
            print(f"[FAILED] - {result.error}")
            tests_failed += 1
    except Exception as e:
        print(f"[FAILED] - Exception: {e}")
        tests_failed += 1

    # Summary
    print("\n" + "="*60)
    print("SUMMARY")
    print("="*60)
    total = tests_passed + tests_failed
    print(f"Tests run: {total}")
    print(f"[OK] Passed: {tests_passed}")
    print(f"[X] Failed: {tests_failed}")

    if tests_failed == 0:
        print("\n[SUCCESS] All basic tests passed!")
        print("\nNext steps:")
        print("  1. Run full test suite: python test_integration.py")
        print("  2. Deploy to Claude Desktop (see QUICK_START.md)")
    else:
        print(f"\n[WARNING] {tests_failed} tests failed")
        print("\nTroubleshooting:")
        print("  1. Make sure Altium is running")
        print("  2. Make sure a PCB project is open")
        print("  3. Check server/altium_mcp.log for errors")
        print("  4. Verify server/config.json has correct paths")

if __name__ == "__main__":
    asyncio.run(quick_test())
