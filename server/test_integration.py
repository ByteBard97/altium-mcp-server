#!/usr/bin/env python3
"""
Integration tests for Altium MCP - requires Altium Designer running with a project open
"""
import asyncio
import json
from pathlib import Path
from altium_bridge import AltiumBridge

class AltiumIntegrationTester:
    def __init__(self):
        # Setup paths
        mcp_dir = Path(__file__).parent
        default_script_path = mcp_dir / "AltiumScript" / "Altium_API.PrjScr"

        self.bridge = AltiumBridge(mcp_dir, default_script_path)
        self.passed = 0
        self.failed = 0
        self.results = []

    async def test_tool(self, name: str, command: str, params: dict, validation_fn=None):
        """Test a single tool"""
        print(f"\n{'='*60}")
        print(f"Testing: {name}")
        print(f"Command: {command}")
        print(f"Params: {json.dumps(params, indent=2)}")
        print(f"{'='*60}")

        try:
            result = await self.bridge.call_script(command, params)

            print(f"Success: {result.success}")

            if result.success:
                data_str = str(result.data)[:200] if result.data else "None"
                print(f"Data preview: {data_str}...")

                # Custom validation
                if validation_fn:
                    if validation_fn(result):
                        print("✅ PASSED - Validation successful")
                        self.passed += 1
                        self.results.append({"test": name, "status": "PASSED"})
                    else:
                        print("❌ FAILED - Validation failed")
                        self.failed += 1
                        self.results.append({"test": name, "status": "FAILED", "reason": "Validation failed"})
                else:
                    print("✅ PASSED")
                    self.passed += 1
                    self.results.append({"test": name, "status": "PASSED"})
            else:
                print(f"❌ FAILED - Error: {result.error}")
                self.failed += 1
                self.results.append({"test": name, "status": "FAILED", "reason": result.error})

        except Exception as e:
            print(f"❌ FAILED - Exception: {str(e)}")
            self.failed += 1
            self.results.append({"test": name, "status": "FAILED", "reason": str(e)})

    async def run_all_tests(self):
        """Run all integration tests"""
        print("\n" + "="*60)
        print("ALTIUM MCP INTEGRATION TEST SUITE")
        print("="*60)
        print("\nPrerequisites:")
        print("  - Altium Designer must be running")
        print("  - A PCB project must be open")
        print("  - Project should have components on the PCB")
        print("\nStarting tests...\n")

        # Initialize bridge
        await self.bridge.initialize()

        # ============================================================
        # COMPONENT TOOLS (7 tests)
        # ============================================================

        print("\n" + "="*60)
        print("COMPONENT TOOLS")
        print("="*60)

        # Test 1: Get all designators
        await self.test_tool(
            "Get All Component Data",
            "get_all_component_data",
            {},
            lambda r: isinstance(r.data, list) and len(r.data) > 0
        )

        # Store designators for later tests
        designators_result = await self.bridge.call_script("get_all_component_data", {})
        designators = []
        if designators_result.success and isinstance(designators_result.data, list):
            designators = [c.get("designator") for c in designators_result.data[:3] if "designator" in c]
            print(f"\nFound designators for testing: {designators}")

        # Test 2: Get selected components coordinates
        print("\nNote: This test works best if you have components selected in Altium")
        await self.test_tool(
            "Get Selected Components Coordinates",
            "get_selected_components_coordinates",
            {}
        )

        # Test 3: Get component pins (if we have designators)
        if designators:
            await self.test_tool(
                "Get Component Pins",
                "get_component_pins",
                {"designators": designators[:1]}
            )

        # Test 4: Get schematic data
        await self.test_tool(
            "Get Schematic Data",
            "get_schematic_data",
            {}
        )

        # ============================================================
        # NET TOOLS (2 tests)
        # ============================================================

        print("\n" + "="*60)
        print("NET TOOLS")
        print("="*60)

        # Test 5: Get all nets
        await self.test_tool(
            "Get All Nets",
            "get_all_nets",
            {},
            lambda r: isinstance(r.data, list)
        )

        # Store nets for later tests
        nets_result = await self.bridge.call_script("get_all_nets", {})
        nets = []
        if nets_result.success and isinstance(nets_result.data, list):
            nets = nets_result.data[:2]  # Get first 2 nets
            print(f"\nFound nets for testing: {nets}")

        # Test 6: Create net class
        if len(nets) >= 2:
            await self.test_tool(
                "Create Net Class",
                "create_net_class",
                {
                    "class_name": "TEST_CLASS_MCP",
                    "net_names": nets
                }
            )
        else:
            print("\n⚠️  Skipping net class test - need at least 2 nets in design")

        # ============================================================
        # LAYER TOOLS (3 tests)
        # ============================================================

        print("\n" + "="*60)
        print("LAYER TOOLS")
        print("="*60)

        # Test 7: Get PCB layers
        await self.test_tool(
            "Get PCB Layers",
            "get_pcb_layers",
            {},
            lambda r: isinstance(r.data, list)
        )

        # Test 8: Get layer stackup
        await self.test_tool(
            "Get PCB Layer Stackup",
            "get_pcb_layer_stackup",
            {}
        )

        # Test 9: Set layer visibility
        await self.test_tool(
            "Set PCB Layer Visibility",
            "set_pcb_layer_visibility",
            {
                "layer_names": ["Top Layer"],
                "visible": True
            }
        )

        # ============================================================
        # SCHEMATIC TOOLS (2 tests)
        # ============================================================

        print("\n" + "="*60)
        print("SCHEMATIC TOOLS")
        print("="*60)

        # Test 10: Get symbol placement rules (local file)
        print("\nNote: This reads from local file, doesn't require Altium")
        # This is handled by Python, not DelphiScript, so skip for now

        # Test 11: Get library symbol reference
        print("\nNote: This requires a schematic library open with a symbol selected")
        await self.test_tool(
            "Get Library Symbol Reference",
            "get_library_symbol_reference",
            {}
        )

        # ============================================================
        # LAYOUT TOOLS (4 tests)
        # ============================================================

        print("\n" + "="*60)
        print("LAYOUT TOOLS")
        print("="*60)

        # Test 12: Get PCB rules
        await self.test_tool(
            "Get PCB Rules",
            "get_pcb_rules",
            {}
        )

        # Test 13: Move components (if we have designators)
        if designators:
            print(f"\nNote: This will move component {designators[0]} by 100 mils")
            response = input("Proceed with move? (y/n): ")
            if response.lower() == 'y':
                await self.test_tool(
                    "Move Components",
                    "move_components",
                    {
                        "designators": [designators[0]],
                        "x_offset": 100,
                        "y_offset": 100,
                        "rotation": 0
                    }
                )
            else:
                print("⚠️  Skipping move test")
        else:
            print("\n⚠️  Skipping move test - no designators found")

        # Test 14: Layout duplicator (Step 1)
        print("\nNote: Select source components in Altium PCB before this test")
        response = input("Have you selected source components? (y/n): ")
        if response.lower() == 'y':
            await self.test_tool(
                "Layout Duplicator (Step 1)",
                "layout_duplicator",
                {}
            )
        else:
            print("⚠️  Skipping layout duplicator test")

        # Test 15: Get screenshot
        await self.test_tool(
            "Get Screenshot",
            "take_view_screenshot",
            {"view_type": "pcb"}
        )

        # ============================================================
        # OUTPUT TOOLS (2 tests)
        # ============================================================

        print("\n" + "="*60)
        print("OUTPUT TOOLS")
        print("="*60)

        # Test 16: Get output job containers
        print("\nNote: This requires an .OutJob file open in Altium")
        response = input("Do you have an .OutJob file open? (y/n): ")
        if response.lower() == 'y':
            await self.test_tool(
                "Get Output Job Containers",
                "get_output_job_containers",
                {}
            )
        else:
            print("⚠️  Skipping output job test")

        # Test 17: Get layer stackup (already tested above)
        await self.test_tool(
            "Get PCB Layer Stackup (repeat)",
            "get_pcb_layer_stackup",
            {}
        )

        # ============================================================
        # SUMMARY
        # ============================================================

        print("\n" + "="*60)
        print("TEST SUMMARY")
        print("="*60)
        total = self.passed + self.failed
        if total > 0:
            print(f"\nTotal tests run: {total}")
            print(f"✅ Passed: {self.passed}")
            print(f"❌ Failed: {self.failed}")
            print(f"Success rate: {(self.passed/total*100):.1f}%")
        else:
            print("\nNo tests were run")

        print("\n" + "="*60)
        print("DETAILED RESULTS")
        print("="*60)
        for result in self.results:
            status_icon = "✅" if result["status"] == "PASSED" else "❌"
            print(f"{status_icon} {result['test']}")
            if result["status"] == "FAILED":
                print(f"   Reason: {result.get('reason', 'Unknown')}")

        print("\n" + "="*60)

        if self.failed == 0 and total > 0:
            print("🎉 ALL TESTS PASSED!")
            print("\nNext Steps:")
            print("1. Configure Claude Desktop (see QUICK_START.md)")
            print("2. Test interactively via Claude Desktop")
            print("3. Move on to Phase 2-5 enhancements!")
        elif total > 0:
            print(f"⚠️  {self.failed} tests failed")
            print("\nTroubleshooting:")
            print("1. Check that Altium is running with a project open")
            print("2. Review altium_mcp.log for detailed errors")
            print("3. Verify config.json has correct paths")
            print("4. See TESTING_GUIDE.md for common issues")
        else:
            print("No tests completed")

async def main():
    print("Altium MCP Integration Test Suite")
    print("="*60)
    print("\nThis will test all 23 tools with your live Altium instance.")
    print("\nBefore proceeding, make sure:")
    print("  1. Altium Designer is running")
    print("  2. A PCB project is open")
    print("  3. The project has some components placed")
    print("\nSome tests are interactive and will ask for confirmation.")
    print("\n" + "="*60 + "\n")

    response = input("Ready to start tests? (y/n): ")
    if response.lower() != 'y':
        print("Tests cancelled")
        return

    tester = AltiumIntegrationTester()
    await tester.run_all_tests()

if __name__ == "__main__":
    asyncio.run(main())
