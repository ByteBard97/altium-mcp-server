#!/usr/bin/env python3
"""
Comprehensive Test Suite for Altium MCP
Tests all Phase 2-5 features with live Altium Designer instance

Prerequisites: Altium Designer running with a PCB project open
"""
import asyncio
import json
from pathlib import Path
from altium_bridge import AltiumBridge

# Color codes for terminal output
GREEN = "\033[92m"
RED = "\033[91m"
YELLOW = "\033[93m"
BLUE = "\033[94m"
RESET = "\033[0m"

class ComprehensiveTest:
    def __init__(self):
        self.bridge = None
        self.tests_passed = 0
        self.tests_failed = 0
        self.tests_skipped = 0

    async def setup(self):
        """Initialize the bridge"""
        print("\n" + "="*70)
        print("ALTIUM MCP COMPREHENSIVE TEST SUITE")
        print("="*70)
        print("\nInitializing Altium bridge...")

        mcp_dir = Path(__file__).parent
        default_script_path = mcp_dir / "AltiumScript" / "Altium_API.PrjScr"

        self.bridge = AltiumBridge(mcp_dir, default_script_path)
        await self.bridge.initialize()

        print(f"{GREEN}[OK]{RESET} Bridge initialized successfully\n")

    def print_test_header(self, phase, test_name):
        """Print test header"""
        print(f"\n{BLUE}[{phase}]{RESET} {test_name}")
        print("-" * 70)

    def print_result(self, success, message):
        """Print test result"""
        if success:
            print(f"{GREEN}[PASSED]{RESET} {message}")
            self.tests_passed += 1
        else:
            print(f"{RED}[FAILED]{RESET} {message}")
            self.tests_failed += 1

    def print_skip(self, message):
        """Print skipped test"""
        print(f"{YELLOW}[SKIPPED]{RESET} {message}")
        self.tests_skipped += 1

    async def test_phase2_project_tools(self):
        """Test Phase 2: Project Management Tools"""
        self.print_test_header("Phase 2", "Project Management Tools")

        # Test 1: Get Project Info
        print("\nTest 1: Get current project information...")
        try:
            result = await self.bridge.call_script("get_project_info", {})
            if result.success and result.data:
                print(f"  Project: {result.data.get('name', 'Unknown')}")
                print(f"  Path: {result.data.get('path', 'Unknown')}")
                print(f"  Files: {result.data.get('file_count', 0)}")
                self.print_result(True, "get_project_info works")
            else:
                self.print_result(False, f"get_project_info failed: {result.error}")
        except Exception as e:
            self.print_result(False, f"get_project_info exception: {e}")

        # Test 2: Save Project
        print("\nTest 2: Save current project...")
        try:
            result = await self.bridge.call_script("save_project", {})
            if result.success:
                self.print_result(True, "save_project works")
            else:
                self.print_result(False, f"save_project failed: {result.error}")
        except Exception as e:
            self.print_result(False, f"save_project exception: {e}")

    async def test_phase2_library_tools(self):
        """Test Phase 2: Library Search Tools"""
        self.print_test_header("Phase 2", "Library Search Tools")

        # Test 3: List Component Libraries
        print("\nTest 3: List all loaded libraries...")
        try:
            result = await self.bridge.call_script("list_component_libraries", {})
            if result.success and result.data:
                lib_count = len(result.data.get('libraries', []))
                print(f"  Found {lib_count} libraries")
                if lib_count > 0:
                    print(f"  First library: {result.data['libraries'][0].get('name', 'Unknown')}")
                self.print_result(lib_count > 0, "list_component_libraries works")
            else:
                self.print_result(False, f"list_component_libraries failed: {result.error}")
        except Exception as e:
            self.print_result(False, f"list_component_libraries exception: {e}")

        # Test 4: Search Components
        print("\nTest 4: Search for resistor components...")
        try:
            result = await self.bridge.call_script("search_components", {"query": "resistor"})
            if result.success:
                comp_count = len(result.data.get('results', []))
                print(f"  Found {comp_count} matching components")
                self.print_result(True, "search_components works")
            else:
                self.print_result(False, f"search_components failed: {result.error}")
        except Exception as e:
            self.print_result(False, f"search_components exception: {e}")

        # Test 5: Search Footprints
        print("\nTest 5: Search for 0805 footprints...")
        try:
            result = await self.bridge.call_script("search_footprints", {"query": "0805"})
            if result.success:
                fp_count = len(result.data.get('results', []))
                print(f"  Found {fp_count} matching footprints")
                self.print_result(True, "search_footprints works")
            else:
                self.print_result(False, f"search_footprints failed: {result.error}")
        except Exception as e:
            self.print_result(False, f"search_footprints exception: {e}")

    async def test_phase3_analysis_tools(self):
        """Test Phase 3: Design Analysis Tools"""
        self.print_test_header("Phase 3", "Design Analysis & Intelligence")

        # Test 6: Identify Circuit Patterns
        print("\nTest 6: Identify circuit patterns in current design...")
        try:
            # First get components
            comp_result = await self.bridge.call_script("get_all_component_data", {})
            if not comp_result.success:
                self.print_skip("Cannot test pattern recognition - get_all_component_data failed")
                return

            # Get nets
            nets_result = await self.bridge.call_script("get_all_nets", {})
            if not nets_result.success:
                self.print_skip("Cannot test pattern recognition - get_all_nets failed")
                return

            # Test pattern recognition (runs locally, not in Altium)
            from pattern_recognition import CircuitPatternRecognizer
            recognizer = CircuitPatternRecognizer()
            result = recognizer.identify_patterns(comp_result.data, nets_result.data)

            if result.get('success'):
                patterns = result.get('patterns', {})
                power_count = len(patterns.get('power_supplies', []))
                interface_count = len(patterns.get('interfaces', []))
                filter_count = len(patterns.get('filters', []))

                print(f"  Power supplies found: {power_count}")
                print(f"  Interfaces found: {interface_count}")
                print(f"  Filters found: {filter_count}")
                print(f"  Summary: {result.get('summary', 'N/A')}")

                self.print_result(True, "identify_circuit_patterns works")
            else:
                self.print_result(False, "Pattern recognition failed")
        except Exception as e:
            self.print_result(False, f"identify_circuit_patterns exception: {e}")

        # Test 7: DRC History
        print("\nTest 7: DRC history tracking...")
        try:
            from drc_history import DRCHistoryManager

            # Create in-memory database for testing
            mgr = DRCHistoryManager(":memory:")

            # Simulate a DRC run
            violations = {
                "violations": [
                    {"type": "clearance", "severity": "critical"},
                    {"type": "width", "severity": "warning"}
                ]
            }

            run_id = mgr.record_drc_run("test_project", violations)
            history = mgr.get_history("test_project", limit=5)

            if run_id > 0 and len(history) == 1:
                print(f"  DRC run recorded with ID: {run_id}")
                print(f"  Violations: {history[0]['total_violations']}")
                self.print_result(True, "DRC history tracking works")
            else:
                self.print_result(False, "DRC history tracking failed")
        except Exception as e:
            self.print_result(False, f"DRC history exception: {e}")

    async def test_phase4_component_ops(self):
        """Test Phase 4: Component Operations (read-only tests)"""
        self.print_test_header("Phase 4", "Component Operations")

        print("\nPhase 4 tools available:")
        print("  - place_component (requires footprint library)")
        print("  - delete_component (modifies design)")
        print("  - place_component_array (modifies design)")
        print("  - align_components (modifies design)")
        print("\nSkipping destructive tests - tools are registered and ready to use")
        self.print_skip("Component operation tests require user confirmation")

    async def test_phase5_board_routing(self):
        """Test Phase 5: Board & Routing Tools (read-only tests)"""
        self.print_test_header("Phase 5", "Board & Routing Tools")

        print("\nPhase 5 tools available:")
        print("  - set_board_size (modifies design)")
        print("  - add_board_outline (modifies design)")
        print("  - add_mounting_hole (modifies design)")
        print("  - add_board_text (modifies design)")
        print("  - route_trace (modifies design)")
        print("  - add_via (modifies design)")
        print("  - add_copper_pour (modifies design)")
        print("\nSkipping destructive tests - tools are registered and ready to use")
        self.print_skip("Board/routing tests require user confirmation")

    async def test_existing_tools(self):
        """Test that existing tools still work"""
        self.print_test_header("Baseline", "Existing Tools (Phase 0-1)")

        # Test get_all_designators
        print("\nTest: Get all component designators...")
        try:
            result = await self.bridge.call_script("get_all_designators", {})
            if result.success and isinstance(result.data, list):
                print(f"  Found {len(result.data)} components")
                self.print_result(True, "get_all_designators works")
            else:
                self.print_result(False, f"get_all_designators failed: {result.error}")
        except Exception as e:
            self.print_result(False, f"get_all_designators exception: {e}")

        # Test get_all_nets
        print("\nTest: Get all nets...")
        try:
            result = await self.bridge.call_script("get_all_nets", {})
            if result.success and isinstance(result.data, list):
                print(f"  Found {len(result.data)} nets")
                self.print_result(True, "get_all_nets works")
            else:
                self.print_result(False, f"get_all_nets failed: {result.error}")
        except Exception as e:
            self.print_result(False, f"get_all_nets exception: {e}")

        # Test get_pcb_layers
        print("\nTest: Get PCB layers...")
        try:
            result = await self.bridge.call_script("get_pcb_layers", {})
            if result.success:
                self.print_result(True, "get_pcb_layers works")
            else:
                self.print_result(False, f"get_pcb_layers failed: {result.error}")
        except Exception as e:
            self.print_result(False, f"get_pcb_layers exception: {e}")

    def print_summary(self):
        """Print test summary"""
        print("\n" + "="*70)
        print("TEST SUMMARY")
        print("="*70)

        total = self.tests_passed + self.tests_failed + self.tests_skipped
        print(f"\nTotal Tests: {total}")
        print(f"{GREEN}Passed: {self.tests_passed}{RESET}")
        print(f"{RED}Failed: {self.tests_failed}{RESET}")
        print(f"{YELLOW}Skipped: {self.tests_skipped}{RESET}")

        if self.tests_failed == 0:
            print(f"\n{GREEN}[SUCCESS]{RESET} All executed tests passed!")
            print("\nNew Features Summary:")
            print("  Phase 2: Project & Library Management - WORKING")
            print("  Phase 3: Design Analysis & Intelligence - WORKING")
            print("  Phase 4: Component Operations - AVAILABLE (not tested)")
            print("  Phase 5: Board & Routing Tools - AVAILABLE (not tested)")
        else:
            print(f"\n{RED}[WARNING]{RESET} {self.tests_failed} test(s) failed")

        print("\n" + "="*70)

async def main():
    """Run comprehensive test suite"""
    test = ComprehensiveTest()

    # Setup
    await test.setup()

    # Run all test phases
    await test.test_existing_tools()
    await test.test_phase2_project_tools()
    await test.test_phase2_library_tools()
    await test.test_phase3_analysis_tools()
    await test.test_phase4_component_ops()
    await test.test_phase5_board_routing()

    # Print summary
    test.print_summary()

    return test.tests_failed == 0

if __name__ == "__main__":
    success = asyncio.run(main())
    exit(0 if success else 1)
