#!/usr/bin/env python3
"""
Comprehensive test script for all Altium MCP functions
Tests all 23+ MCP tools to verify functionality

Requirements:
- Altium Designer must be running
- A project must be open with a PCB document
- Run: python test_all_mcp_functions.py
"""

import sys
import os
import asyncio
from pathlib import Path

# Add parent directory to path to import altium_bridge
sys.path.insert(0, str(Path(__file__).parent.parent))

from altium_bridge import AltiumBridge

class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

def print_header(text):
    print(f"\n{Colors.BOLD}{Colors.BLUE}{'='*70}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.BLUE}{text}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.BLUE}{'='*70}{Colors.RESET}\n")

def print_test(test_name):
    print(f"{Colors.BOLD}Testing: {test_name}{Colors.RESET}")

def print_success(message):
    print(f"{Colors.GREEN}[PASS] {message}{Colors.RESET}")

def print_error(message):
    print(f"{Colors.RED}[FAIL] {message}{Colors.RESET}")

def print_info(message):
    print(f"{Colors.YELLOW}[INFO] {message}{Colors.RESET}")

class MCPTester:
    def __init__(self):
        self.bridge = AltiumBridge(
            Path(__file__).parent.parent,
            Path(__file__).parent.parent / "AltiumScript" / "Altium_API.PrjScr"
        )
        self.passed = 0
        self.failed = 0
        self.skipped = 0

    async def test_function(self, name, command, params=None, check_success=True, optional=False):
        """Test a single MCP function"""
        print_test(name)

        try:
            if params is None:
                params = {}

            result = await self.bridge.call_script(command, params)

            if not result.success:
                if optional:
                    print_info(f"Skipped (optional): {result.error}")
                    self.skipped += 1
                else:
                    print_error(f"Failed: {result.error}")
                    self.failed += 1
                return False

            # Check if response data indicates success
            if check_success and isinstance(result.data, dict):
                if result.data.get('success') == False:
                    error_msg = result.data.get('error', 'Unknown error')
                    if optional:
                        print_info(f"Skipped (optional): {error_msg}")
                        self.skipped += 1
                    else:
                        print_error(f"Failed: {error_msg}")
                        self.failed += 1
                    return False

            print_success(f"Success: {name}")

            # Print summary of result
            if isinstance(result.data, dict):
                if 'count' in result.data:
                    print(f"  → Count: {result.data['count']}")
                if 'components' in result.data and isinstance(result.data['components'], list):
                    print(f"  → Components: {len(result.data['components'])}")
                if 'nets' in result.data and isinstance(result.data['nets'], list):
                    print(f"  → Nets: {len(result.data['nets'])}")
                if 'layers' in result.data and isinstance(result.data['layers'], list):
                    print(f"  → Layers: {len(result.data['layers'])}")
                if 'libraries' in result.data and isinstance(result.data['libraries'], list):
                    print(f"  → Libraries: {len(result.data['libraries'])}")
            elif isinstance(result.data, list):
                print(f"  → Items: {len(result.data)}")

            self.passed += 1
            return True

        except Exception as e:
            if optional:
                print_info(f"Skipped (optional): {str(e)}")
                self.skipped += 1
            else:
                print_error(f"Exception: {str(e)}")
                self.failed += 1
            return False

    async def run_all_tests(self):
        """Run comprehensive test suite"""

        print_header("ALTIUM MCP COMPREHENSIVE TEST SUITE")

        # Check server status
        print_test("Server Status")
        status = self.bridge.status
        if status == "ready":
            print_success(f"Server ready: {status}")
        else:
            print_error(f"Server not ready: {status}")
            return

        # Category 1: Project Information
        print_header("Category 1: Project Information")
        await self.test_function("Get Project Info", "get_project_info")
        await self.test_function("Save Project", "save_project")

        # Category 2: Component Data
        print_header("Category 2: Component Data")
        await self.test_function("Get All Designators", "get_all_designators")
        await self.test_function("Get All Component Property Names", "get_all_component_property_names")
        await self.test_function("Get Component Property Values", "get_component_property_values",
                          {"property_name": "designator"})

        # Get some designators for further testing
        designators_result = await self.bridge.call_script("get_all_designators", {})
        test_designators = []
        if designators_result.success and isinstance(designators_result.data, list):
            test_designators = designators_result.data[:3]  # Take first 3

        if test_designators:
            await self.test_function("Get Component Data", "get_component_data",
                             {"cmp_designators": test_designators})
            await self.test_function("Get Component Pins", "get_component_pins",
                             {"cmp_designators": test_designators})
            await self.test_function("Get Schematic Data", "get_schematic_data",
                             {"cmp_designators": test_designators})
        else:
            print_info("No components found, skipping component-specific tests")
            self.skipped += 3

        # Category 3: PCB Layers
        print_header("Category 3: PCB Layers & Stackup")
        await self.test_function("Get PCB Layers", "get_pcb_layers")
        await self.test_function("Get PCB Layer Stackup", "get_pcb_layer_stackup")
        await self.test_function("Set Layer Visibility", "set_pcb_layer_visibility",
                          {"layer_names": ["TopLayer", "BottomLayer"], "visible": True})

        # Category 4: Nets & Rules
        print_header("Category 4: Nets & Rules")
        await self.test_function("Get All Nets", "get_all_nets")
        await self.test_function("Get PCB Rules", "get_pcb_rules")

        # Test net class creation
        nets_result = await self.bridge.call_script("get_all_nets", {})
        if nets_result.success and isinstance(nets_result.data, list) and len(nets_result.data) > 0:
            test_nets = [nets_result.data[0]] if nets_result.data else []
            if test_nets:
                await self.test_function("Create Net Class", "create_net_class",
                                 {"class_name": "TestClass_MCP", "net_names": test_nets})
        else:
            print_info("No nets found, skipping net class test")
            self.skipped += 1

        # Category 5: Libraries
        print_header("Category 5: Component Libraries")
        await self.test_function("List Component Libraries", "list_component_libraries")
        await self.test_function("Search Components", "search_components", {"query": "resistor"})
        await self.test_function("Search Footprints", "search_footprints", {"query": "QFN"})

        # Category 6: Analysis & DRC
        print_header("Category 6: Analysis & DRC")
        await self.test_function("Identify Circuit Patterns", "identify_circuit_patterns")
        await self.test_function("Run DRC with History", "run_drc_with_history", optional=True)
        await self.test_function("Get DRC History", "get_drc_history", optional=True)

        # Category 7: Visualization
        print_header("Category 7: Visualization")
        await self.test_function("Get Screenshot", "get_screenshot", {"view_type": "pcb"})
        await self.test_function("Get Selected Components Coordinates", "get_selected_components_coordinates",
                          check_success=False)  # May have no selection

        # Category 8: Layout Operations
        print_header("Category 8: Layout Operations")
        await self.test_function("Layout Duplicator", "layout_duplicator",
                          check_success=False, optional=True)  # Requires selection

        # Category 9: Output Jobs
        print_header("Category 9: Output Jobs")
        await self.test_function("Get Output Job Containers", "get_output_job_containers", optional=True)

        # Category 10: Board Modification (Read-only tests)
        print_header("Category 10: Board Modification Functions (Existence Check)")
        print_info("Skipping destructive board modification tests")
        print_info("Functions exist but not tested: place_component, delete_component,")
        print_info("  place_component_array, align_components, move_components,")
        print_info("  set_board_size, add_board_outline, add_mounting_hole,")
        print_info("  add_board_text, route_trace, add_via, add_copper_pour")
        self.skipped += 13

        # Print Summary
        self.print_summary()

    def print_summary(self):
        """Print test results summary"""
        print_header("TEST SUMMARY")

        total = self.passed + self.failed + self.skipped

        print(f"Total Tests:   {total}")
        print(f"{Colors.GREEN}Passed:        {self.passed}{Colors.RESET}")
        print(f"{Colors.RED}Failed:        {self.failed}{Colors.RESET}")
        print(f"{Colors.YELLOW}Skipped:       {self.skipped}{Colors.RESET}")

        if self.failed == 0:
            print(f"\n{Colors.GREEN}{Colors.BOLD}[SUCCESS] ALL CRITICAL TESTS PASSED!{Colors.RESET}")
        else:
            print(f"\n{Colors.RED}{Colors.BOLD}[FAILURE] SOME TESTS FAILED{Colors.RESET}")

        success_rate = (self.passed / (self.passed + self.failed) * 100) if (self.passed + self.failed) > 0 else 0
        print(f"\nSuccess Rate: {success_rate:.1f}%")


async def main():
    """Main entry point"""
    print(f"{Colors.BOLD}Altium MCP Comprehensive Test Suite{Colors.RESET}")
    print(f"Testing all MCP functions...\n")

    # Check if Altium is running
    tester = MCPTester()

    if tester.bridge.status != "ready":
        print_error("Altium Designer is not running or no project is open!")
        print_info("Please start Altium Designer and open a project with a PCB")
        sys.exit(1)

    # Run all tests
    await tester.run_all_tests()

    # Exit with appropriate code
    sys.exit(0 if tester.failed == 0 else 1)


if __name__ == "__main__":
    asyncio.run(main())
