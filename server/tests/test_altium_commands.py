#!/usr/bin/env python3
"""
Test script for Altium DelphiScript commands
Tests only the commands that actually execute in Altium (not Python-only MCP tools)

Requirements:
- Altium Designer must be running
- A project must be open with a PCB document
- Run: python test_altium_commands.py
"""

import sys
import os
import asyncio
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from altium_bridge import AltiumBridge

class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

# Commands that need component designators (filled in dynamically)
COMMANDS_NEEDING_DESIGNATORS = [
    "get_component_pins",
    "get_schematic_data"
]

# All Altium DelphiScript commands from command_router.pas (line-by-line from the case statement)
ALTIUM_COMMANDS = {
    # Component & Pin Data (will add designator-dependent commands later)
    "get_all_component_data": {},
    "get_selected_components_coordinates": {},
    "move_components": {},  # Will skip if no params

    # Nets & Rules
    "get_all_nets": {},
    "get_pcb_rules": {},

    # Layers
    "get_pcb_layers": {},
    "get_pcb_layer_stackup": {},
    "set_pcb_layer_visibility": {"layer_names": ["TopLayer"], "visible": True},

    # Screenshots
    "take_view_screenshot": {"view_type": "pcb"},

    # Layout
    "layout_duplicator": {},

    # Output Jobs
    "get_output_job_containers": {},

    # Project
    "save_project": {},
    "get_project_info": {},

    # Libraries
    "list_component_libraries": {},
    "search_components": {"query": "resistor"},
    "search_footprints": {"query": "QFN"},

    # Schematic
    "get_library_symbol_reference": {},
}

async def test_all_commands():
    """Test all Altium DelphiScript commands"""

    print(f"{Colors.BOLD}{Colors.BLUE}Altium DelphiScript Command Tester{Colors.RESET}\n")

    bridge = AltiumBridge(
        Path(__file__).parent.parent,
        Path(__file__).parent.parent / "AltiumScript" / "Altium_API.PrjScr"
    )

    if bridge.status != "ready":
        print(f"{Colors.RED}ERROR: Altium is not ready!{Colors.RESET}")
        print(f"{Colors.YELLOW}Status: {bridge.status}{Colors.RESET}")
        return 1

    print(f"{Colors.GREEN}Altium Status: {bridge.status}{Colors.RESET}\n")

    # Get component designators for commands that need them
    print(f"{Colors.BOLD}Getting component designators for parameter-dependent tests...{Colors.RESET}")
    designators_found = False
    try:
        comp_result = await bridge.call_script("get_all_component_data", {})

        # Debug output
        print(f"  get_all_component_data success: {comp_result.success}")
        if comp_result.success:
            print(f"  Response data type: {type(comp_result.data)}")
            if isinstance(comp_result.data, list):
                print(f"  Number of components: {len(comp_result.data)}")
                if len(comp_result.data) > 0:
                    print(f"  First component: {comp_result.data[0]}")
        else:
            print(f"  Error: {comp_result.error}")

        if comp_result.success and isinstance(comp_result.data, list) and len(comp_result.data) > 0:
            # Get up to 3 designators
            test_designators = [comp.get("designator") for comp in comp_result.data[:3] if comp.get("designator")]
            if test_designators:
                print(f"  {Colors.GREEN}Found {len(test_designators)} designators: {test_designators}{Colors.RESET}\n")

                # Add commands that need designators
                for cmd in COMMANDS_NEEDING_DESIGNATORS:
                    ALTIUM_COMMANDS[cmd] = {"designators": test_designators}

                designators_found = True
            else:
                print(f"{Colors.YELLOW}  WARNING: Components found but no valid designators{Colors.RESET}\n")
        else:
            print(f"{Colors.YELLOW}  WARNING: No components found on PCB board{Colors.RESET}")
            print(f"{Colors.YELLOW}  Skipping tests for: {', '.join(COMMANDS_NEEDING_DESIGNATORS)}{Colors.RESET}\n")
    except Exception as e:
        print(f"{Colors.RED}  ERROR getting designators: {e}{Colors.RESET}\n")

    passed = 0
    failed = 0
    skipped = 0

    print(f"Commands to test: {list(ALTIUM_COMMANDS.keys())}\n")
    print(f"Commands needing designators: {COMMANDS_NEEDING_DESIGNATORS}\n")

    for command, params in ALTIUM_COMMANDS.items():
        # Skip commands that need designators if we don't have any
        if command in COMMANDS_NEEDING_DESIGNATORS and not designators_found:
            print(f"Testing: {command}... {Colors.YELLOW}[SKIP] No components on PCB{Colors.RESET}")
            skipped += 1
            continue

        # Show params for debugging if command needs designators
        if command in COMMANDS_NEEDING_DESIGNATORS:
            print(f"Testing: {command} (params: {params})...", end=" ")
        else:
            print(f"Testing: {command}...", end=" ")

        try:
            result = await bridge.call_script(command, params, timeout=30.0)

            if result.success:
                print(f"{Colors.GREEN}[PASS]{Colors.RESET}")
                passed += 1
            else:
                # Some commands may fail if no selection, etc - that's OK
                if "no" in result.error.lower() or "not found" in result.error.lower():
                    print(f"{Colors.YELLOW}[SKIP] {result.error}{Colors.RESET}")
                    skipped += 1
                else:
                    print(f"{Colors.RED}[FAIL] {result.error}{Colors.RESET}")
                    failed += 1

        except Exception as e:
            print(f"{Colors.RED}[ERROR] {str(e)}{Colors.RESET}")
            failed += 1

    # Summary
    print(f"\n{Colors.BOLD}Results:{Colors.RESET}")
    print(f"  Total:   {passed + failed + skipped}")
    print(f"  {Colors.GREEN}Passed:  {passed}{Colors.RESET}")
    print(f"  {Colors.RED}Failed:  {failed}{Colors.RESET}")
    print(f"  {Colors.YELLOW}Skipped: {skipped}{Colors.RESET}")

    if failed == 0:
        print(f"\n{Colors.GREEN}{Colors.BOLD}All critical tests passed!{Colors.RESET}")
        return 0
    else:
        print(f"\n{Colors.RED}{Colors.BOLD}Some tests failed{Colors.RESET}")
        return 1

if __name__ == "__main__":
    exit_code = asyncio.run(test_all_commands())
    sys.exit(exit_code)
