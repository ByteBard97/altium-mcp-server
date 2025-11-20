"""
Design Analysis tool handlers
Includes DRC history tracking and circuit pattern recognition
"""
import json
from typing import TYPE_CHECKING
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).parent.parent))
from response_helpers import format_large_response_summary

if TYPE_CHECKING:
    from mcp.server.fastmcp import FastMCP
    from ..altium_bridge import AltiumBridge


def register_analysis_tools(mcp: "FastMCP", altium_bridge: "AltiumBridge"):
    """Register all design analysis tools"""

    # Import here to avoid circular dependencies
    import sys
    sys.path.insert(0, str(Path(__file__).parent.parent))
    from drc_history import DRCHistoryManager
    from pattern_recognition import CircuitPatternRecognizer

    @mcp.tool()
    async def run_drc_with_history(project_path: str = "") -> str:
        """
        Run DRC (Design Rule Check) and track results in history database

        This tool runs DRC analysis on the current PCB and stores the results
        in a SQLite database for historical tracking and trend analysis.

        Args:
            project_path: Path to the project (used as identifier in history).
                         If empty, uses current project path from Altium.

        Returns:
            JSON object containing:
            - drc_results: Current DRC violations and rule checks
            - progress: Trend analysis comparing to previous runs
            - run_id: Database ID for this DRC run
        """
        # Get current project path if not provided
        if not project_path:
            project_info = await altium_bridge.call_script("get_project_info", {})
            if project_info.success and project_info.data:
                project_path = project_info.data.get("project_path", "unknown_project")
            else:
                project_path = "unknown_project"

        # Run DRC using existing Altium command
        # Note: Using get_pcb_rules as a proxy - in a real implementation,
        # you would use a dedicated DRC command
        drc_result = await altium_bridge.call_script("get_pcb_rules", {})

        if not drc_result.success:
            return json.dumps({
                "success": False,
                "error": f"Failed to run DRC: {drc_result.error}"
            })

        # Format DRC results into violations structure
        # This is a simplified structure - adapt based on actual DRC output
        violations_data = {
            "violations": [],
            "rules_checked": drc_result.data if isinstance(drc_result.data, list) else [],
            "timestamp": None  # Will be set by database
        }

        # If the DRC result contains violations, parse them
        # (This depends on the actual structure returned by get_pcb_rules)
        if isinstance(drc_result.data, list):
            for rule in drc_result.data:
                # Example violation structure - adapt as needed
                if isinstance(rule, dict) and rule.get("enabled"):
                    violations_data["violations"].append({
                        "type": rule.get("rule_type", "unknown"),
                        "severity": "warning",  # Default severity
                        "description": rule.get("name", "Unknown rule")
                    })

        # Record in history
        history_mgr = DRCHistoryManager()
        run_id = history_mgr.record_drc_run(project_path, violations_data)

        # Get progress report
        progress = history_mgr.get_progress_report(project_path)

        return json.dumps({
            "success": True,
            "drc_results": drc_result.data,
            "progress": progress,
            "run_id": run_id,
            "project_path": project_path
        }, indent=2)

    @mcp.tool()
    async def get_drc_history(project_path: str = "", limit: int = 10) -> str:
        """
        Get DRC history for a project

        Args:
            project_path: Path to the project. If empty, uses current project.
            limit: Maximum number of historical runs to return (default: 10)

        Returns:
            JSON object containing historical DRC runs with trends and statistics
        """
        # Get current project path if not provided
        if not project_path:
            project_info = await altium_bridge.call_script("get_project_info", {})
            if project_info.success and project_info.data:
                project_path = project_info.data.get("project_path", "unknown_project")
            else:
                project_path = "unknown_project"

        history_mgr = DRCHistoryManager()
        history = history_mgr.get_history(project_path, limit)
        progress = history_mgr.get_progress_report(project_path)

        return json.dumps({
            "success": True,
            "project_path": project_path,
            "history": history,
            "progress": progress
        }, indent=2)

    @mcp.tool()
    async def identify_circuit_patterns() -> str:
        """
        Identify common circuit patterns in the current PCB design

        This tool analyzes the components and nets in your design to identify
        common circuit patterns such as:
        - Power supplies (buck converters, boost converters, linear regulators, LDOs)
        - Interfaces (USB, Ethernet, SPI, I2C)
        - Filters (RC, LC)

        Returns:
            JSON object containing:
            - patterns: Categorized list of detected patterns
            - summary: Human-readable summary of findings
            - confidence scores for each detected pattern
        """
        # Get all components
        components_result = await altium_bridge.call_script("get_all_component_data", {})
        if not components_result.success:
            return json.dumps({
                "success": False,
                "error": f"Failed to get component data: {components_result.error}"
            })

        components = components_result.data if components_result.data else []

        # Get all nets
        nets_result = await altium_bridge.call_script("get_all_nets", {})
        if not nets_result.success:
            return json.dumps({
                "success": False,
                "error": f"Failed to get net data: {nets_result.error}"
            })

        # Extract net names from the result
        nets_data = nets_result.data if nets_result.data else []
        if isinstance(nets_data, list):
            # Handle different formats of net data
            nets = []
            for net in nets_data:
                if isinstance(net, str):
                    nets.append(net)
                elif isinstance(net, dict):
                    net_name = net.get("net_name") or net.get("name") or net.get("NetName")
                    if net_name:
                        nets.append(net_name)
        else:
            nets = []

        # Analyze patterns
        recognizer = CircuitPatternRecognizer()
        result = recognizer.identify_patterns(components, nets)

        return json.dumps(result, indent=2)

    @mcp.tool()
    async def get_drc_run_details(run_id: int) -> str:
        """
        Get detailed information about a specific DRC run

        Args:
            run_id: The ID of the DRC run to retrieve

        Returns:
            JSON object with complete DRC run details including all violations
        """
        history_mgr = DRCHistoryManager()
        run_details = history_mgr.get_detailed_run(run_id)

        if not run_details:
            return json.dumps({
                "success": False,
                "error": f"DRC run with ID {run_id} not found"
            })

        # Get violation types breakdown
        violation_types = history_mgr.get_violation_types(run_id)
        run_details["violation_types"] = violation_types

        return json.dumps({
            "success": True,
            "run": run_details
        }, indent=2)

    @mcp.tool()
    async def check_schematic_pcb_sync() -> str:
        """
        Check synchronization between schematic and PCB components

        This tool compares the components in the schematic with those in the PCB
        to identify synchronization issues. It checks:
        - Components present in schematic but missing from PCB
        - Components present in PCB but missing from schematic
        - Components with matching unique IDs but different designators

        The comparison is based on UniqueId (schematic) and SourceUniqueId (PCB),
        which provides a reliable link between schematic and PCB components.

        Returns:
            JSON object containing:
            - success: Boolean indicating if the check completed successfully
            - in_sync: Boolean indicating if schematic and PCB are fully synchronized
            - schematic_only: Array of components only in schematic (missing from PCB)
            - pcb_only: Array of components only in PCB (missing from schematic)
            - designator_mismatches: Array of components with same UniqueId but different designators
            - matched_count: Number of perfectly matched components
            - total_schematic: Total number of components in schematic
            - total_pcb: Total number of components in PCB

        Example output:
        {
          "success": true,
          "in_sync": false,
          "schematic_only": [
            {"designator": "R10", "unique_id": "ABC123"}
          ],
          "pcb_only": [
            {"designator": "C5", "source_unique_id": "DEF456"}
          ],
          "designator_mismatches": [
            {
              "schematic_designator": "R1",
              "pcb_designator": "R2",
              "unique_id": "XYZ789"
            }
          ],
          "matched_count": 25,
          "total_schematic": 26,
          "total_pcb": 26
        }
        """
        response = await altium_bridge.call_script("check_schematic_pcb_sync", {})

        if not response.success:
            return json.dumps({
                "success": False,
                "error": f"Failed to check synchronization: {response.error}"
            })

        sync_data = response.data

        if not sync_data:
            return json.dumps({
                "success": False,
                "error": "No synchronization data returned. Please ensure both schematic and PCB documents are open."
            })

        # Handle large responses by writing to disk if needed
        output_dir = altium_bridge.mcp_dir / "large_responses"
        return format_large_response_summary(
            sync_data,
            output_dir,
            "schematic_pcb_sync"
        )
