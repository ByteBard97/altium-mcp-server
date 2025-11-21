#!/usr/bin/env python3
"""
Mock test to demonstrate what distributor tools return
Shows tool output format without needing actual API keys
"""

import sys
import json
from pathlib import Path

# Add server directory to path
server_dir = Path(__file__).parent / "server"
sys.path.insert(0, str(server_dir))

def test_tool_without_api():
    """
    Show what tools are available and what they return without API keys
    """
    print("=" * 60)
    print("Available Distributor Tools")
    print("=" * 60)

    tools = [
        "search_component(query)",
        "get_component_availability(mpn)",
        "check_bom_availability()",
        "find_component_alternatives(mpn, reason)",
        "validate_bom_lifecycle()",
        "compare_distributor_pricing(mpn)"
    ]

    print("\nRegistered MCP Tools:")
    for i, tool in enumerate(tools, 1):
        print(f"   {i}. {tool}")

    print("\n" + "-" * 60)
    print("Tool Behavior Without API Keys:")
    print("-" * 60)

    print("""
When API keys are not configured, tools return:
{
  "error": "Nexar API not configured",
  "message": "Please set NEXAR_CLIENT_ID and NEXAR_CLIENT_SECRET...",
  "setup_instructions": "1. Sign up at https://nexar.com..."
}

This ensures graceful degradation - the MCP server works,
but distributor features require API keys.
    """)

    return True

def show_expected_output_with_api():
    """Show what the tools would return with real API keys"""
    print("\n" + "=" * 60)
    print("Expected Output With API Keys Configured")
    print("=" * 60)

    example_availability = {
        "success": True,
        "components_checked": 15,
        "total_cost_estimate": "$127.45",
        "availability_summary": {
            "in_stock": 12,
            "limited_stock": 2,
            "out_of_stock": 1
        },
        "issues": [
            {
                "designator": "U5",
                "mpn": "MAX3232CDR",
                "status": "out_of_stock",
                "alternatives_available": 3
            }
        ],
        "distributor_breakdown": {
            "DigiKey": {"in_stock": 10, "total_price": "$125.30"},
            "Mouser": {"in_stock": 12, "total_price": "$127.45"},
            "LCSC": {"in_stock": 8, "total_price": "$98.20"}
        }
    }

    print("\nExample: check_component_availability() output:")
    print(json.dumps(example_availability, indent=2))

    example_alternatives = {
        "success": True,
        "original_component": {
            "mpn": "MAX3232CDR",
            "status": "out_of_stock",
            "lifecycle": "Active"
        },
        "alternatives": [
            {
                "mpn": "MAX3232EIDR",
                "manufacturer": "Texas Instruments",
                "description": "RS-232 Interface IC",
                "price_at_1": "$2.87",
                "price_at_100": "$1.45",
                "stock": 15420,
                "compatibility": "Drop-in replacement",
                "datasheet": "https://..."
            },
            {
                "mpn": "MAX3232ECDR",
                "manufacturer": "Texas Instruments",
                "description": "RS-232 Interface IC",
                "price_at_1": "$2.65",
                "price_at_100": "$1.32",
                "stock": 8900,
                "compatibility": "Pin compatible",
                "datasheet": "https://..."
            }
        ]
    }

    print("\n\nExample: suggest_component_alternatives() output:")
    print(json.dumps(example_alternatives, indent=2))

    return True

def show_integration_with_altium():
    """Show how tools integrate with Altium MCP"""
    print("\n" + "=" * 60)
    print("Integration with Altium MCP Server")
    print("=" * 60)

    print("""
The distributor tools integrate seamlessly with your Altium project:

1. AUTOMATIC BOM EXTRACTION:
   - Uses get_schematic_components_with_parameters()
   - Extracts part numbers from component parameters
   - No manual BOM export needed

2. USER INTERACTION:
   Direct: "Check my BOM availability"
   Agent: Claude automatically checks during board review
   Workflow: /validate-bom prompt for guided process

3. TYPICAL WORKFLOW:
   User: "I'm planning a respin, check my design"

   Claude (automatically):
   - Extracts BOM from schematic
   - Checks component availability across distributors
   - Identifies obsolete parts
   - Suggests cost optimizations
   - Flags long lead times

   Claude responds:
   "I found 3 issues in your design:
    1. U5 (MAX3232CDR) is out of stock - suggest MAX3232EIDR
    2. C10-C15 use 6 different cap values - consolidate to save $12
    3. R8 is NRND - replace before production"

4. AVAILABLE VIA MCP TOOLS:
   - check_component_availability
   - detect_obsolete_components
   - suggest_component_alternatives
   - analyze_bom_cost_optimization
   - export_bom_with_pricing
""")

    return True

if __name__ == "__main__":
    test_tool_without_api()
    show_expected_output_with_api()
    show_integration_with_altium()

    print("\n" + "=" * 60)
    print("Next Steps:")
    print("=" * 60)
    print("""
1. Get Nexar API keys (free):
   - Visit https://nexar.com/api
   - Create account
   - Create application
   - Copy client ID and secret

2. Configure:
   - Copy server/.env.example to server/.env
   - Add your credentials to .env

3. Test with real data:
   - Restart MCP server
   - Ask Claude to check your BOM
   - Get real-time availability and pricing!

Documentation: docs/DISTRIBUTOR_INTEGRATION.md
Setup Guide: docs/API_SETUP_GUIDE.md
    """)
