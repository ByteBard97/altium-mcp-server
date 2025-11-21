"""
Schematic-related tool handlers
"""
import json
from pathlib import Path
from typing import TYPE_CHECKING
import sys
sys.path.insert(0, str(Path(__file__).parent.parent))
from response_helpers import format_large_response_summary

if TYPE_CHECKING:
    from mcp.server.fastmcp import FastMCP
    from ..altium_bridge import AltiumBridge


def register_schematic_tools(mcp: "FastMCP", altium_bridge: "AltiumBridge"):
    """Register all schematic-related tools"""

    @mcp.tool()
    async def get_symbol_placement_rules() -> str:
        """
        Get schematic symbol placement rules from a local configuration file

        Returns:
            JSON object with rules for placing pins on schematic symbols
        """
        # Define the rules file path in the MCP directory
        rules_file_path = altium_bridge.mcp_dir / "symbol_placement_rules.txt"

        # Check if the rules file exists
        if not rules_file_path.exists():
            # Default rules content
            default_rules = (
                "Only place pins on the left and right side of the symbol. "
                "Place power rail pins at the upper right, ground pins in the bottom left, "
                "no connect pins in the bottom right, inputs on the left, outputs on the right, "
                "and try to group other pins together by similar functionality (for example, SPI, I2C, RGMII, etc.). "
                "Always separate groups by 100mil gaps unless there is extra spacing, then space out groups equal distance from each other. "
            )

            # Create a helpful message for the user
            message = {
                "success": False,
                "error": f"Rules file not found at: {rules_file_path}",
                "message": f"Let the user know that they can optionally update the file {rules_file_path} with custom symbol placement rules. "
                          f"Suggested content: {default_rules}"
            }

            return json.dumps(message, indent=2)

        # Read the rules file if it exists
        try:
            with open(rules_file_path, "r") as f:
                rules_content = f.read()

            # Return the rules with a message about how to modify them
            result = {
                "success": True,
                "message": f"Modify {rules_file_path} with custom symbol placement instructions",
                "rules": rules_content
            }

            return json.dumps(result, indent=2)

        except Exception as e:
            return json.dumps({
                "success": False,
                "error": f"Failed to read rules file: {str(e)}"
            }, indent=2)

    @mcp.tool()
    async def get_library_symbol_reference() -> str:
        """
        Get the currently open symbol from a schematic library to use as reference for creating a new symbol.
        This tool should be used before creating a new symbol to understand the structure of existing symbols.

        Returns:
            JSON object with the reference symbol data including pins, their types, positions, and orientations
        """
        response = await altium_bridge.call_script("get_library_symbol_reference", {})

        if not response.success:
            return json.dumps({"error": f"Failed to get symbol reference: {response.error}"})

        symbol_data = response.data

        if not symbol_data:
            return json.dumps({"error": "No symbol reference data found or no symbol is currently selected in the library"})

        return json.dumps(symbol_data, indent=2)

    @mcp.tool()
    async def create_schematic_symbol(symbol_name: str, description: str, pins: list[str]) -> str:
        """
        Before executing, run get_symbol_placement_rules first.
        Create a new schematic symbol in the current library with the specified pins
        Instructions: pins should be grouped together via function and only placed on
                      the left and right side in 100 mil increments

        Args:
            symbol_name: Name of the symbol to create
            description: Description of the schematic symbol
            pins: List of pin data in format ["pin_number|pin_name|pin_type|pin_orientation|x|y", ...]
                  Pin types: eElectricHiZ, eElectricInput, eElectricIO, eElectricOpenCollector,
                             eElectricOpenEmitter, eElectricOutput, eElectricPassive, eElectricPower
                  Pin orientations: eRotate0 (right), eRotate90 (down), eRotate180 (left), eRotate270 (up)
                  X,Y coordinates in mils

        Returns:
            JSON object with the result of the component creation
        """
        response = await altium_bridge.call_script("create_schematic_symbol", {
            "symbol_name": symbol_name,
            "description": description,
            "pins": pins
        })

        if not response.success:
            return json.dumps({"success": False, "error": f"Failed to create symbol: {response.error}"})

        return json.dumps(response.data, indent=2)

    @mcp.tool()
    async def get_schematic_data(cmp_designators: list[str]) -> str:
        """
        Get schematic data for components in Altium

        Args:
            cmp_designators: List of designators of the components (e.g., ["R1", "C5", "U3"])

        Returns:
            JSON object with schematic component data for requested designators
        """
        response = await altium_bridge.call_script("get_schematic_data", {})

        if not response.success:
            return json.dumps({"error": f"Failed to get schematic data: {response.error}"})

        schematic_data = response.data

        if not schematic_data:
            return json.dumps({"error": "No schematic data found"})

        try:
            # Filter components by designator
            components = []
            missing_designators = []

            for designator in cmp_designators:
                found = False
                for component in schematic_data:
                    if component.get("designator") == designator:
                        components.append(component)
                        found = True
                        break

                if not found:
                    missing_designators.append(designator)

            result = {
                "components": components,
            }

            if missing_designators:
                result["missing_designators"] = missing_designators

            return json.dumps(result, indent=2)
        except Exception as e:
            return json.dumps({"error": f"Failed to process schematic data: {str(e)}"})

    @mcp.tool()
    async def get_schematic_components_with_parameters() -> str:
        """
        Get all schematic component parameters for BOM analysis

        This function exports all components from the flattened schematic hierarchy
        with their basic properties (designator, lib_reference, description, footprint)
        and all associated parameters. This is useful for:
        - BOM generation and analysis
        - Component parameter auditing
        - Design validation
        - Export to external tools

        Returns:
            JSON array with all components and their parameters

        Example output:
        [
          {
            "designator": "R1",
            "lib_reference": "RES",
            "description": "100k 0402 1% 50V",
            "footprint": "RESC1005X40N",
            "parameters": {
              "Manufacturer": "Yageo",
              "Part Number": "RC0402FR-07100KL",
              "Value": "100k",
              "Tolerance": "1%",
              "Power": "1/16W"
            }
          },
          ...
        ]
        """
        response = await altium_bridge.call_script("get_schematic_components_with_parameters", {})

        if not response.success:
            return json.dumps({"error": f"Failed to get component parameters: {response.error}"})

        components_data = response.data

        if not components_data:
            return json.dumps({"error": "No component data found. Please ensure a project is open and compiled."})

        # Handle large responses by writing to disk if needed
        output_dir = altium_bridge.mcp_dir / "large_responses"
        return format_large_response_summary(
            components_data,
            output_dir,
            "schematic_components_with_parameters"
        )

    # ============================================================================
    # SCHEMATIC DSL TOOLS - LLM-Optimized Format
    # ============================================================================

    @mcp.tool()
    async def get_whole_design_json() -> str:
        """
        Get the entire schematic design in one efficient JSON call.

        This function exports ALL schematic sheets with components, pins, and nets
        in a single bulk operation. Much faster than multiple individual calls.

        Returns:
            JSON object with:
            - components: Array of all components with pins and parameters
            - nets: Array of all nets with page counts

        Example usage:
            Use this as the data source for schematic analysis, DSL generation,
            or any operation that needs complete schematic connectivity.
        """
        response = await altium_bridge.call_script("get_whole_design_json", {})

        if not response.success:
            return json.dumps({"error": f"Failed to get whole design: {response.error}"})

        design_data = response.data

        if not design_data:
            return json.dumps({"error": "No design data found. Please ensure a project is open."})

        # Handle large responses by writing to disk if needed
        output_dir = altium_bridge.mcp_dir / "large_responses"
        return format_large_response_summary(
            design_data,
            output_dir,
            "whole_design_json"
        )

    @mcp.tool()
    async def get_schematic_index() -> str:
        """
        Get a high-level overview of the schematic design.

        Returns an LLM-optimized index showing:
        - List of all schematic pages with component/net counts
        - Inter-page signals (nets that cross sheet boundaries)
        - Global nets (power/ground rails)

        This is perfect for:
        - Understanding overall schematic structure
        - Finding which page contains specific functionality
        - Identifying how sheets are interconnected

        Returns:
            Human-readable text index in DSL format
        """
        # Import schematic core modules
        from schematic_core.adapters.altium_json import AltiumJSONAdapter
        from schematic_core.librarian import Librarian

        try:
            # Get design data from Altium
            response = await altium_bridge.call_script("get_whole_design_json", {})

            if not response.success:
                return f"Error: Failed to get design data: {response.error}"

            design_json = json.dumps(response.data)

            # Transform through adapter and generate index
            adapter = AltiumJSONAdapter(design_json)
            librarian = Librarian(adapter)

            return librarian.get_index()

        except Exception as e:
            return f"Error generating schematic index: {str(e)}"

    @mcp.tool()
    async def get_schematic_page(page_name: str) -> str:
        """
        Get an LLM-optimized DSL representation of a single schematic page.

        This generates a token-efficient format showing:
        - Complex components (ICs, connectors) with full pin listings
        - Simple passives (R, C, L) inline in net connections
        - Net connectivity with inter-page links
        - Global nets with connection summaries

        Args:
            page_name: Name of the schematic sheet (e.g., "Power_Switches.SchDoc")

        Perfect for:
        - Focused analysis of one schematic sheet
        - Understanding connectivity on a specific page
        - Reviewing design before layout

        Returns:
            DSL format text optimized for LLM consumption
        """
        from schematic_core.adapters.altium_json import AltiumJSONAdapter
        from schematic_core.librarian import Librarian

        try:
            # Get design data from Altium
            response = await altium_bridge.call_script("get_whole_design_json", {})

            if not response.success:
                return f"Error: Failed to get design data: {response.error}"

            design_json = json.dumps(response.data)

            # Transform and generate page DSL
            adapter = AltiumJSONAdapter(design_json)
            librarian = Librarian(adapter)

            return librarian.get_page(page_name)

        except Exception as e:
            return f"Error generating page DSL: {str(e)}"

    @mcp.tool()
    async def get_schematic_context(refdes_list: list[str]) -> str:
        """
        Get a "context bubble" around specific components.

        Performs a 1-hop graph traversal to show:
        - Primary components (full details with all pins)
        - Connected nets
        - Neighbor components (summary for active, inline for passive)
        - Smart truncation of global nets (GND, VCC)

        Args:
            refdes_list: List of component designators (e.g., ["U1", "R5", "C10"])

        Perfect for:
        - Understanding what connects to a specific IC
        - Debugging connectivity issues
        - Finding related components quickly

        Example:
            get_schematic_context(["U1"]) - Shows U1 and everything directly connected

        Returns:
            DSL format showing focused connectivity context
        """
        from schematic_core.adapters.altium_json import AltiumJSONAdapter
        from schematic_core.librarian import Librarian

        try:
            # Get design data from Altium
            response = await altium_bridge.call_script("get_whole_design_json", {})

            if not response.success:
                return f"Error: Failed to get design data: {response.error}"

            design_json = json.dumps(response.data)

            # Transform and generate context DSL
            adapter = AltiumJSONAdapter(design_json)
            librarian = Librarian(adapter)

            return librarian.get_context(refdes_list)

        except Exception as e:
            return f"Error generating context: {str(e)}"

    @mcp.tool()
    async def rebuild_delphiscript() -> str:
        """
        Rebuild the Altium DelphiScript (Altium_API.pas) from source files and automatically reload it.
        This runs build_script.py which combines all the modular .pas files,
        then uses PowerShell to activate Altium and send F9 to recompile the script.

        Returns:
            Success message with line count and reload status
        """
        import subprocess
        import time

        script_dir = altium_bridge.mcp_dir / "AltiumScript"
        build_script = script_dir / "build_script.py"

        try:
            # Step 1: Run build script
            result = subprocess.run(
                ["python", str(build_script)],
                cwd=str(script_dir),
                capture_output=True,
                text=True,
                timeout=30
            )

            if result.returncode != 0:
                return json.dumps({
                    "success": False,
                    "error": "Build failed",
                    "stdout": result.stdout,
                    "stderr": result.stderr
                }, indent=2)

            # Extract line count from output
            lines = "unknown"
            for line in result.stdout.split('\n'):
                if 'lines' in line.lower():
                    lines = line.strip()
                    break

            # Step 2: Activate Altium window and send F9 to recompile
            try:
                # PowerShell script to activate Altium and send F9
                ps_script = '''
                Add-Type -AssemblyName System.Windows.Forms
                $wshell = New-Object -ComObject wscript.shell
                if ($wshell.AppActivate('Altium Designer')) {
                    Start-Sleep -Milliseconds 500
                    [System.Windows.Forms.SendKeys]::SendWait('{F9}')
                    Write-Output 'Sent F9 to Altium Designer'
                } else {
                    Write-Output 'Could not activate Altium Designer window'
                }
                '''

                reload_result = subprocess.run(
                    ["powershell", "-Command", ps_script],
                    capture_output=True,
                    text=True,
                    timeout=5
                )

                reload_success = "Sent F9" in reload_result.stdout

                return json.dumps({
                    "success": True,
                    "message": "DelphiScript rebuilt and reloaded automatically!" if reload_success else "DelphiScript rebuilt (auto-reload may have failed)",
                    "details": lines,
                    "auto_reload": reload_success,
                    "reload_output": reload_result.stdout.strip(),
                    "note": "The script should automatically recompile in Altium Designer"
                }, indent=2)

            except Exception as reload_error:
                return json.dumps({
                    "success": True,
                    "message": "DelphiScript rebuilt successfully, but auto-reload failed",
                    "details": lines,
                    "reload_error": str(reload_error),
                    "next_step": "Manually press F9 in Altium to reload the script"
                }, indent=2)

        except subprocess.TimeoutExpired:
            return json.dumps({
                "success": False,
                "error": "Build script timed out after 30 seconds"
            }, indent=2)
        except Exception as e:
            return json.dumps({
                "success": False,
                "error": f"Failed to run build script: {str(e)}"
            }, indent=2)
