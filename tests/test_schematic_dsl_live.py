#!/usr/bin/env python3
"""
Test script for the new Schematic DSL system
Tests end-to-end with live Altium connection
"""
import sys
import json
from pathlib import Path

# Add server directory to path
sys.path.insert(0, str(Path(__file__).parent / "server"))

from altium_bridge import AltiumBridge
from schematic_core.adapters.altium_json import AltiumJSONAdapter
from schematic_core.librarian import Librarian


def test_dsl_system():
    """Test the complete DSL system with live Altium"""

    print("=" * 80)
    print("TESTING SCHEMATIC DSL SYSTEM")
    print("=" * 80)
    print()

    # Initialize Altium bridge
    mcp_dir = Path(__file__).parent / "server"
    script_path = mcp_dir / "AltiumScript" / "Altium_API.PrjScr"

    print(f"[1/5] Initializing Altium Bridge...")
    print(f"      MCP Dir: {mcp_dir}")
    print(f"      Script:  {script_path}")

    bridge = AltiumBridge(mcp_dir, script_path)

    # Import asyncio for async operations
    import asyncio

    async def run_tests():
        print("      [OK] Bridge initialized")
        print()

        # Test 1: Get whole design JSON
        print("[2/5] Calling get_whole_design_json()...")
        try:
            response = await bridge.call_script("get_whole_design_json", {})

            if not response.success:
                print(f"      [ERROR] {response.error}")
                return False

            design_data = response.data

            # Show stats
            num_components = len(design_data.get("components", []))
            num_nets = len(design_data.get("nets", []))

            print(f"      [OK] Got design data")
            print(f"        - Components: {num_components}")
            print(f"        - Nets: {num_nets}")

            # Save raw JSON for inspection
            output_file = Path("test_design_output.json")
            with open(output_file, 'w') as f:
                json.dump(design_data, f, indent=2)
            print(f"        - Saved to: {output_file}")
            print()

        except Exception as e:
            print(f"      [ERROR] EXCEPTION: {e}")
            import traceback
            traceback.print_exc()
            return False

        # Test 2: Generate schematic index
        print("[3/5] Generating schematic index...")
        try:
            design_json = json.dumps(design_data)
            adapter = AltiumJSONAdapter(design_json)
            librarian = Librarian(adapter)

            index = librarian.get_index()

            print("      [OK] Index generated")
            print()
            print(index)
            print()

            # Save index
            index_file = Path("test_schematic_index.txt")
            with open(index_file, 'w') as f:
                f.write(index)
            print(f"        - Saved to: {index_file}")
            print()

        except Exception as e:
            print(f"      [ERROR] EXCEPTION: {e}")
            import traceback
            traceback.print_exc()
            return False

        # Test 3: Get a specific page
        print("[4/5] Getting first schematic page DSL...")
        try:
            # Get list of pages from the index
            pages = [comp.page for comp in adapter.get_components() if comp.page]
            if pages:
                first_page = sorted(set(pages))[0]
                print(f"      Page: {first_page}")

                page_dsl = librarian.get_page(first_page)

                print("      [OK] Page DSL generated")
                print()
                print(page_dsl[:1000] + "..." if len(page_dsl) > 1000 else page_dsl)
                print()

                # Save page DSL
                page_file = Path("test_page_dsl.txt")
                with open(page_file, 'w') as f:
                    f.write(page_dsl)
                print(f"        - Saved to: {page_file}")
                print()
            else:
                print("      ! No pages found in design")

        except Exception as e:
            print(f"      [ERROR] EXCEPTION: {e}")
            import traceback
            traceback.print_exc()
            return False

        # Test 4: Get context for a component
        print("[5/5] Getting context for first component...")
        try:
            components = adapter.get_components()
            if components:
                first_comp = components[0]
                print(f"      Component: {first_comp.designator}")

                context_dsl = librarian.get_context([first_comp.designator])

                print("      [OK] Context DSL generated")
                print()
                print(context_dsl[:1000] + "..." if len(context_dsl) > 1000 else context_dsl)
                print()

                # Save context DSL
                context_file = Path("test_context_dsl.txt")
                with open(context_file, 'w') as f:
                    f.write(context_dsl)
                print(f"        - Saved to: {context_file}")
                print()
            else:
                print("      ! No components found in design")

        except Exception as e:
            print(f"      [ERROR] EXCEPTION: {e}")
            import traceback
            traceback.print_exc()
            return False

        print("=" * 80)
        print("ALL TESTS PASSED!")
        print("=" * 80)
        print()
        print("Output files:")
        print("  - test_design_output.json     (Raw Altium JSON)")
        print("  - test_schematic_index.txt    (Design overview)")
        print("  - test_page_dsl.txt           (Single page DSL)")
        print("  - test_context_dsl.txt        (Component context)")
        print()

        return True

    # Run async tests
    result = asyncio.run(run_tests())
    return result


if __name__ == "__main__":
    try:
        success = test_dsl_system()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n\nTest interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n\nFATAL ERROR: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)