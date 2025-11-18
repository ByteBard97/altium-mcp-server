#!/usr/bin/env python3
"""
Test script for Altium MCP Server v2.0
Validates that all tools, resources, and prompts are registered correctly
"""

import sys
import pathlib

# Add lib directory to path
site_dir = pathlib.Path(__file__).with_name("lib")
sys.path.insert(0, str(site_dir))

import asyncio
import json
from pathlib import Path

# Import the main module
import main


def test_server_initialization():
    """Test that the server initializes correctly"""
    print("=" * 80)
    print("TEST: Server Initialization")
    print("=" * 80)

    try:
        assert main.mcp is not None, "MCP server not initialized"
        assert main.altium_bridge is not None, "Altium bridge not initialized"
        print("✅ Server initialized successfully")
        return True
    except Exception as e:
        print(f"❌ Server initialization failed: {e}")
        return False


def test_tools_registered():
    """Test that all tools are registered"""
    print("\n" + "=" * 80)
    print("TEST: Tools Registration")
    print("=" * 80)

    try:
        # Get all registered tools
        tools = main.mcp.list_tools()

        # Expected tools (23 total)
        expected_tools = [
            # Component tools
            "get_all_component_property_names",
            "get_component_property_values",
            "get_component_data",
            "get_all_designators",
            "get_component_pins",
            "get_selected_components_coordinates",
            "move_components",
            # Net tools
            "get_all_nets",
            "create_net_class",
            # Layer tools
            "get_pcb_layers",
            "set_pcb_layer_visibility",
            "get_pcb_layer_stackup",
            # Schematic tools
            "get_symbol_placement_rules",
            "get_library_symbol_reference",
            "create_schematic_symbol",
            "get_schematic_data",
            # Layout tools
            "layout_duplicator",
            "layout_duplicator_apply",
            "get_screenshot",
            "get_pcb_rules",
            # Output tools
            "get_output_job_containers",
            "run_output_jobs",
            "get_server_status"
        ]

        registered_tool_names = [tool.name for tool in tools]

        print(f"Found {len(registered_tool_names)} tools:")
        for tool in tools:
            print(f"  - {tool.name}: {tool.description[:60]}..." if len(tool.description) > 60 else f"  - {tool.name}: {tool.description}")

        # Check for missing tools
        missing_tools = set(expected_tools) - set(registered_tool_names)
        extra_tools = set(registered_tool_names) - set(expected_tools)

        if missing_tools:
            print(f"\n⚠️  Missing tools: {missing_tools}")
        if extra_tools:
            print(f"\n⚠️  Extra tools (not in expected list): {extra_tools}")

        if not missing_tools:
            print(f"\n✅ All {len(expected_tools)} expected tools registered successfully")
            return True
        else:
            print(f"\n❌ Missing {len(missing_tools)} tools")
            return False

    except Exception as e:
        print(f"❌ Tool registration test failed: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_resources_registered():
    """Test that all resources are registered"""
    print("\n" + "=" * 80)
    print("TEST: Resources Registration")
    print("=" * 80)

    try:
        # Get all registered resources
        resources = main.mcp.list_resources()

        # Expected resources (8 total)
        expected_resources = [
            "altium://project/current/info",
            "altium://project/current/components",
            "altium://project/current/nets",
            "altium://project/current/layers",
            "altium://project/current/stackup",
            "altium://project/current/rules",
            "altium://board/preview.png",
            "altium://board/preview"
        ]

        registered_resource_uris = [res.uri for res in resources]

        print(f"Found {len(registered_resource_uris)} resources:")
        for resource in resources:
            print(f"  - {resource.uri}")
            if hasattr(resource, 'description') and resource.description:
                print(f"    Description: {resource.description}")

        # Check for missing resources
        missing_resources = set(expected_resources) - set(registered_resource_uris)
        extra_resources = set(registered_resource_uris) - set(expected_resources)

        if missing_resources:
            print(f"\n⚠️  Missing resources: {missing_resources}")
        if extra_resources:
            print(f"\n⚠️  Extra resources (not in expected list): {extra_resources}")

        if not missing_resources:
            print(f"\n✅ All {len(expected_resources)} expected resources registered successfully")
            return True
        else:
            print(f"\n❌ Missing {len(missing_resources)} resources")
            return False

    except Exception as e:
        print(f"❌ Resource registration test failed: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_prompts_registered():
    """Test that all prompts are registered"""
    print("\n" + "=" * 80)
    print("TEST: Prompts Registration")
    print("=" * 80)

    try:
        # Get all registered prompts
        prompts = main.mcp.list_prompts()

        # Expected prompts (3 total)
        expected_prompts = [
            "create_symbol_workflow",
            "duplicate_layout_workflow",
            "organize_nets_workflow"
        ]

        registered_prompt_names = [prompt.name for prompt in prompts]

        print(f"Found {len(registered_prompt_names)} prompts:")
        for prompt in prompts:
            print(f"  - {prompt.name}")
            if hasattr(prompt, 'description') and prompt.description:
                print(f"    Description: {prompt.description[:60]}..." if len(prompt.description) > 60 else f"    Description: {prompt.description}")

        # Check for missing prompts
        missing_prompts = set(expected_prompts) - set(registered_prompt_names)
        extra_prompts = set(registered_prompt_names) - set(expected_prompts)

        if missing_prompts:
            print(f"\n⚠️  Missing prompts: {missing_prompts}")
        if extra_prompts:
            print(f"\n⚠️  Extra prompts (not in expected list): {extra_prompts}")

        if not missing_prompts:
            print(f"\n✅ All {len(expected_prompts)} expected prompts registered successfully")
            return True
        else:
            print(f"\n❌ Missing {len(missing_prompts)} prompts")
            return False

    except Exception as e:
        print(f"❌ Prompt registration test failed: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_module_structure():
    """Test that all required modules are present"""
    print("\n" + "=" * 80)
    print("TEST: Module Structure")
    print("=" * 80)

    server_dir = Path(__file__).parent
    required_modules = [
        "altium_bridge.py",
        "schemas.py",
        "resources/__init__.py",
        "resources/project_resources.py",
        "resources/board_resources.py",
        "tools/__init__.py",
        "tools/component_tools.py",
        "tools/net_tools.py",
        "tools/layer_tools.py",
        "tools/schematic_tools.py",
        "tools/layout_tools.py",
        "tools/output_tools.py",
        "prompts/__init__.py",
        "prompts/workflow_prompts.py"
    ]

    all_present = True
    for module in required_modules:
        module_path = server_dir / module
        if module_path.exists():
            print(f"  ✅ {module}")
        else:
            print(f"  ❌ {module} - NOT FOUND")
            all_present = False

    if all_present:
        print(f"\n✅ All {len(required_modules)} required modules present")
    else:
        print(f"\n❌ Some modules are missing")

    return all_present


def main_test():
    """Run all tests"""
    print("\n" + "=" * 80)
    print("ALTIUM MCP SERVER v2.0 - TEST SUITE")
    print("=" * 80)

    results = []

    # Run tests
    results.append(("Server Initialization", test_server_initialization()))
    results.append(("Module Structure", test_module_structure()))
    results.append(("Tools Registration", test_tools_registered()))
    results.append(("Resources Registration", test_resources_registered()))
    results.append(("Prompts Registration", test_prompts_registered()))

    # Print summary
    print("\n" + "=" * 80)
    print("TEST SUMMARY")
    print("=" * 80)

    passed = sum(1 for _, result in results if result)
    total = len(results)

    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status} - {test_name}")

    print("\n" + "=" * 80)
    print(f"RESULTS: {passed}/{total} tests passed")
    print("=" * 80)

    if passed == total:
        print("\n🎉 All tests passed! The server is ready to use.")
        return 0
    else:
        print(f"\n⚠️  {total - passed} test(s) failed. Please review the errors above.")
        return 1


if __name__ == "__main__":
    exit_code = main_test()
    sys.exit(exit_code)
