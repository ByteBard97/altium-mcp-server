"""
Distributor integration tool handlers

These tools provide access to real-time component availability, pricing,
and lifecycle information through the Nexar API.
"""
import json
from typing import TYPE_CHECKING
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).parent.parent))
from nexar_client import NexarClient

if TYPE_CHECKING:
    from mcp.server.fastmcp import FastMCP
    from ..altium_bridge import AltiumBridge


def register_distributor_tools(mcp: "FastMCP", altium_bridge: "AltiumBridge"):
    """Register all distributor-related tools"""

    # Initialize Nexar client (will check environment variables for credentials)
    nexar_client = NexarClient()

    def _check_api_configured() -> tuple[bool, dict]:
        """Check if Nexar API is configured and return appropriate response"""
        if not nexar_client.is_configured():
            return False, {
                "error": "Nexar API not configured",
                "message": "Please set NEXAR_CLIENT_ID and NEXAR_CLIENT_SECRET environment variables to use distributor integration features.",
                "setup_instructions": "1. Sign up for a free Nexar account at https://nexar.com\n2. Create API credentials\n3. Set environment variables: NEXAR_CLIENT_ID and NEXAR_CLIENT_SECRET"
            }
        return True, {}

    @mcp.tool()
    async def search_component(query: str) -> str:
        """
        Search for components by MPN or keyword

        This tool searches across multiple distributors to find components matching
        your query. Results include manufacturer info, descriptions, and availability.

        Args:
            query: MPN (manufacturer part number) or keyword to search for
                   Examples: "STM32F407", "0603 10k resistor", "ATmega328P"

        Returns:
            JSON object with search results including:
            - MPN and manufacturer
            - Description and category
            - Availability across distributors
            - Pricing information

        Example:
            search_component("STM32F407VGT6")
        """
        configured, error_response = _check_api_configured()
        if not configured:
            return json.dumps(error_response, indent=2)

        try:
            results = await nexar_client.search_component(query, limit=10)

            if not results:
                return json.dumps({
                    "success": False,
                    "message": f"No components found matching '{query}'",
                    "query": query
                }, indent=2)

            # Format results for easy reading
            parts = results.get("results", [])
            formatted_results = []

            for result in parts:
                part = result.get("part", {})
                manufacturer = part.get("manufacturer", {})
                category = part.get("category", {})
                sellers = part.get("sellers", [])

                # Calculate total stock across all distributors
                total_stock = sum(
                    offer.get("inventoryLevel", 0)
                    for seller in sellers
                    for offer in seller.get("offers", [])
                )

                formatted_results.append({
                    "mpn": part.get("mpn"),
                    "manufacturer": manufacturer.get("name"),
                    "description": part.get("description"),
                    "category": category.get("name"),
                    "total_stock": total_stock,
                    "distributors_count": len(sellers)
                })

            return json.dumps({
                "success": True,
                "query": query,
                "results_count": len(formatted_results),
                "parts": formatted_results,
                "message": f"Found {len(formatted_results)} components matching '{query}'"
            }, indent=2)

        except Exception as e:
            return json.dumps({
                "success": False,
                "error": f"Search failed: {str(e)}",
                "query": query
            }, indent=2)

    @mcp.tool()
    async def get_component_availability(mpn: str) -> str:
        """
        Get detailed availability and pricing for a specific component

        This tool provides comprehensive information about a single component,
        including stock levels, pricing tiers, and distributor details.

        Args:
            mpn: Manufacturer part number (e.g., "STM32F407VGT6", "RC0805FR-0710KL")

        Returns:
            JSON object with:
            - Component details (MPN, manufacturer, description)
            - Lifecycle status
            - Datasheet URL
            - Stock levels by distributor
            - Pricing tiers with MOQ information
            - Direct purchase links

        Example:
            get_component_availability("STM32F407VGT6")
        """
        configured, error_response = _check_api_configured()
        if not configured:
            return json.dumps(error_response, indent=2)

        try:
            part_data = await nexar_client.get_component_availability(mpn)

            if not part_data:
                return json.dumps({
                    "success": False,
                    "message": f"Component not found: {mpn}",
                    "mpn": mpn
                }, indent=2)

            # Extract and format key information
            manufacturer = part_data.get("manufacturer", {})
            category = part_data.get("category", {})
            datasheet = part_data.get("bestDatasheet", {})
            sellers = part_data.get("sellers", [])

            # Format distributor information
            distributors = []
            total_stock = 0

            for seller in sellers:
                company = seller.get("company", {})
                offers = seller.get("offers", [])

                for offer in offers:
                    stock = offer.get("inventoryLevel", 0)
                    total_stock += stock

                    # Format pricing tiers
                    pricing_tiers = []
                    for price_tier in offer.get("prices", []):
                        pricing_tiers.append({
                            "quantity": price_tier.get("quantity"),
                            "price": price_tier.get("price"),
                            "currency": price_tier.get("currency")
                        })

                    distributors.append({
                        "name": company.get("name"),
                        "sku": offer.get("sku"),
                        "stock": stock,
                        "moq": offer.get("moq"),
                        "packaging": offer.get("packaging"),
                        "url": offer.get("clickUrl"),
                        "pricing": pricing_tiers,
                        "last_updated": offer.get("updated")
                    })

            result = {
                "success": True,
                "component": {
                    "mpn": part_data.get("mpn"),
                    "manufacturer": manufacturer.get("name"),
                    "description": part_data.get("description"),
                    "category": category.get("name"),
                    "lifecycle_status": part_data.get("lifecycleStatus"),
                    "datasheet": datasheet.get("url")
                },
                "availability": {
                    "total_stock": total_stock,
                    "distributors_count": len(distributors),
                    "distributors": distributors
                },
                "summary": f"{mpn}: {total_stock} units available from {len(distributors)} distributor(s)"
            }

            return json.dumps(result, indent=2)

        except Exception as e:
            return json.dumps({
                "success": False,
                "error": f"Failed to get availability: {str(e)}",
                "mpn": mpn
            }, indent=2)

    @mcp.tool()
    async def check_bom_availability() -> str:
        """
        Check availability and pricing for all components in the current BOM

        This tool analyzes your entire bill of materials, checking real-time
        availability and pricing for each component. It identifies potential
        supply chain issues and provides a comprehensive cost analysis.

        Returns:
            JSON object with:
            - Summary statistics (total components, available, unavailable)
            - Detailed availability for each component
            - Total BOM cost estimate
            - Components with low stock warnings
            - Components with lifecycle concerns

        Example:
            check_bom_availability()
        """
        configured, error_response = _check_api_configured()
        if not configured:
            return json.dumps(error_response, indent=2)

        try:
            # Get all schematic components with parameters
            response = await altium_bridge.call_script("get_schematic_components_with_parameters", {})

            if not response.success:
                return json.dumps({
                    "error": f"Failed to get BOM data: {response.error}",
                    "message": "Ensure a project is open and compiled in Altium"
                }, indent=2)

            components_data = response.data
            if not components_data:
                return json.dumps({
                    "error": "No components found in schematic",
                    "message": "Open and compile a project in Altium first"
                }, indent=2)

            # Process each component
            bom_analysis = []
            total_cost_estimate = 0
            components_with_issues = []
            components_available = 0
            components_checked = 0

            for component in components_data:
                designator = component.get("designator", "")
                parameters = component.get("parameters", {})

                # Try to find MPN in parameters (common parameter names)
                mpn = (parameters.get("Part Number") or
                       parameters.get("MPN") or
                       parameters.get("Manufacturer Part Number") or
                       parameters.get("ManufacturerPartNumber"))

                if not mpn:
                    # Skip components without MPN (like connectors, test points, etc.)
                    continue

                components_checked += 1

                # Check availability for this component
                part_data = await nexar_client.get_component_availability(mpn)

                if not part_data:
                    components_with_issues.append({
                        "designator": designator,
                        "mpn": mpn,
                        "issue": "Not found in distributor database"
                    })
                    bom_analysis.append({
                        "designator": designator,
                        "mpn": mpn,
                        "status": "not_found"
                    })
                    continue

                # Calculate availability
                sellers = part_data.get("sellers", [])
                total_stock = sum(
                    offer.get("inventoryLevel", 0)
                    for seller in sellers
                    for offer in seller.get("offers", [])
                )

                # Get best price (unit price at quantity 1)
                best_price = float('inf')
                for seller in sellers:
                    for offer in seller.get("offers", []):
                        prices = offer.get("prices", [])
                        if prices:
                            unit_price = prices[0].get("price", float('inf'))
                            if unit_price < best_price:
                                best_price = unit_price

                if best_price != float('inf'):
                    total_cost_estimate += best_price

                # Check for issues
                lifecycle = part_data.get("lifecycleStatus", "")
                if lifecycle in ["NRND", "Obsolete", "Not Recommended for New Designs"]:
                    components_with_issues.append({
                        "designator": designator,
                        "mpn": mpn,
                        "issue": f"Lifecycle: {lifecycle}"
                    })

                if total_stock < 100:
                    components_with_issues.append({
                        "designator": designator,
                        "mpn": mpn,
                        "issue": f"Low stock: {total_stock} units"
                    })

                if total_stock > 0:
                    components_available += 1

                bom_analysis.append({
                    "designator": designator,
                    "mpn": mpn,
                    "manufacturer": part_data.get("manufacturer", {}).get("name"),
                    "stock": total_stock,
                    "lifecycle": lifecycle,
                    "unit_price": best_price if best_price != float('inf') else None,
                    "status": "available" if total_stock > 0 else "unavailable"
                })

            result = {
                "success": True,
                "summary": {
                    "total_components_checked": components_checked,
                    "components_available": components_available,
                    "components_with_issues": len(components_with_issues),
                    "estimated_unit_cost": round(total_cost_estimate, 2),
                    "currency": "USD"
                },
                "issues": components_with_issues,
                "detailed_analysis": bom_analysis,
                "message": f"Checked {components_checked} components: {components_available} available, {len(components_with_issues)} with issues"
            }

            return json.dumps(result, indent=2)

        except Exception as e:
            return json.dumps({
                "success": False,
                "error": f"BOM check failed: {str(e)}"
            }, indent=2)

    @mcp.tool()
    async def find_component_alternatives(mpn: str, reason: str) -> str:
        """
        Find alternative components to replace a specific part

        This tool helps you find suitable replacements when a component is
        unavailable, obsolete, or when you need a cost-effective alternative.

        Args:
            mpn: Manufacturer part number to find alternatives for
            reason: Why you need alternatives (e.g., "obsolete", "out of stock",
                    "cost reduction", "lead time")

        Returns:
            JSON object with:
            - Original component details
            - List of alternative parts in same category
            - Availability and pricing comparison
            - Key differences to consider

        Example:
            find_component_alternatives("STM32F407VGT6", "out of stock")
        """
        configured, error_response = _check_api_configured()
        if not configured:
            return json.dumps(error_response, indent=2)

        try:
            # Get original part details
            original_part = await nexar_client.get_component_availability(mpn)

            if not original_part:
                return json.dumps({
                    "success": False,
                    "message": f"Original component not found: {mpn}",
                    "mpn": mpn
                }, indent=2)

            # Find alternatives
            alternatives = await nexar_client.find_alternatives(mpn, limit=5)

            if not alternatives:
                return json.dumps({
                    "success": False,
                    "message": f"No alternatives found for {mpn}",
                    "original_component": {
                        "mpn": mpn,
                        "manufacturer": original_part.get("manufacturer", {}).get("name"),
                        "description": original_part.get("description")
                    }
                }, indent=2)

            # Format alternatives
            formatted_alternatives = []
            for alt_part in alternatives:
                manufacturer = alt_part.get("manufacturer", {})
                sellers = alt_part.get("sellers", [])

                total_stock = sum(
                    offer.get("inventoryLevel", 0)
                    for seller in sellers
                    for offer in seller.get("offers", [])
                )

                # Get best price
                best_price = float('inf')
                for seller in sellers:
                    for offer in seller.get("offers", []):
                        prices = offer.get("prices", [])
                        if prices:
                            unit_price = prices[0].get("price", float('inf'))
                            if unit_price < best_price:
                                best_price = unit_price

                formatted_alternatives.append({
                    "mpn": alt_part.get("mpn"),
                    "manufacturer": manufacturer.get("name"),
                    "description": alt_part.get("description"),
                    "lifecycle": alt_part.get("lifecycleStatus"),
                    "stock": total_stock,
                    "unit_price": best_price if best_price != float('inf') else None,
                    "distributors": len(sellers)
                })

            result = {
                "success": True,
                "reason": reason,
                "original_component": {
                    "mpn": mpn,
                    "manufacturer": original_part.get("manufacturer", {}).get("name"),
                    "description": original_part.get("description"),
                    "category": original_part.get("category", {}).get("name")
                },
                "alternatives_count": len(formatted_alternatives),
                "alternatives": formatted_alternatives,
                "message": f"Found {len(formatted_alternatives)} alternatives for {mpn}",
                "recommendation": "Review each alternative carefully to ensure compatibility with your design requirements"
            }

            return json.dumps(result, indent=2)

        except Exception as e:
            return json.dumps({
                "success": False,
                "error": f"Failed to find alternatives: {str(e)}",
                "mpn": mpn
            }, indent=2)

    @mcp.tool()
    async def validate_bom_lifecycle() -> str:
        """
        Validate lifecycle status of all components in the BOM

        This tool checks each component's lifecycle status to identify parts
        that are obsolete, NRND (Not Recommended for New Designs), or have
        other lifecycle concerns that could impact long-term production.

        Returns:
            JSON object with:
            - Overall BOM health score
            - List of components by lifecycle status
            - Recommended actions for problematic parts
            - Parts nearing end-of-life

        Example:
            validate_bom_lifecycle()
        """
        configured, error_response = _check_api_configured()
        if not configured:
            return json.dumps(error_response, indent=2)

        try:
            # Get all schematic components
            response = await altium_bridge.call_script("get_schematic_components_with_parameters", {})

            if not response.success:
                return json.dumps({
                    "error": f"Failed to get BOM data: {response.error}",
                    "message": "Ensure a project is open and compiled in Altium"
                }, indent=2)

            components_data = response.data
            if not components_data:
                return json.dumps({
                    "error": "No components found in schematic"
                }, indent=2)

            # Track lifecycle statuses
            lifecycle_summary = {
                "Active": [],
                "NRND": [],
                "Obsolete": [],
                "Unknown": [],
                "Not Found": []
            }

            components_checked = 0

            for component in components_data:
                designator = component.get("designator", "")
                parameters = component.get("parameters", {})

                # Find MPN
                mpn = (parameters.get("Part Number") or
                       parameters.get("MPN") or
                       parameters.get("Manufacturer Part Number") or
                       parameters.get("ManufacturerPartNumber"))

                if not mpn:
                    continue

                components_checked += 1

                # Check lifecycle status
                lifecycle_status = await nexar_client.check_lifecycle_status(mpn)

                component_info = {
                    "designator": designator,
                    "mpn": mpn,
                    "description": component.get("description", "")
                }

                if not lifecycle_status:
                    lifecycle_summary["Not Found"].append(component_info)
                elif lifecycle_status in ["NRND", "Not Recommended for New Designs"]:
                    lifecycle_summary["NRND"].append(component_info)
                elif lifecycle_status == "Obsolete":
                    lifecycle_summary["Obsolete"].append(component_info)
                elif lifecycle_status == "Active":
                    lifecycle_summary["Active"].append(component_info)
                else:
                    component_info["status"] = lifecycle_status
                    lifecycle_summary["Unknown"].append(component_info)

            # Calculate health score
            total_components = components_checked
            problematic = len(lifecycle_summary["NRND"]) + len(lifecycle_summary["Obsolete"])
            health_score = 100 - (problematic / total_components * 100) if total_components > 0 else 0

            # Generate recommendations
            recommendations = []
            if lifecycle_summary["Obsolete"]:
                recommendations.append({
                    "priority": "HIGH",
                    "action": "Replace obsolete components immediately",
                    "count": len(lifecycle_summary["Obsolete"])
                })
            if lifecycle_summary["NRND"]:
                recommendations.append({
                    "priority": "MEDIUM",
                    "action": "Plan to replace NRND components for long-term production",
                    "count": len(lifecycle_summary["NRND"])
                })
            if lifecycle_summary["Not Found"]:
                recommendations.append({
                    "priority": "LOW",
                    "action": "Verify MPNs for components not found in database",
                    "count": len(lifecycle_summary["Not Found"])
                })

            result = {
                "success": True,
                "summary": {
                    "health_score": round(health_score, 1),
                    "total_components_checked": components_checked,
                    "active": len(lifecycle_summary["Active"]),
                    "nrnd": len(lifecycle_summary["NRND"]),
                    "obsolete": len(lifecycle_summary["Obsolete"]),
                    "unknown": len(lifecycle_summary["Unknown"]),
                    "not_found": len(lifecycle_summary["Not Found"])
                },
                "lifecycle_breakdown": lifecycle_summary,
                "recommendations": recommendations,
                "message": f"BOM Health Score: {round(health_score, 1)}% - {problematic} of {total_components} components need attention"
            }

            return json.dumps(result, indent=2)

        except Exception as e:
            return json.dumps({
                "success": False,
                "error": f"Lifecycle validation failed: {str(e)}"
            }, indent=2)

    @mcp.tool()
    async def compare_distributor_pricing(mpn: str) -> str:
        """
        Compare pricing across different distributors for a component

        This tool provides a detailed price comparison across all available
        distributors, helping you find the best deal and optimal order quantity.

        Args:
            mpn: Manufacturer part number to compare pricing for

        Returns:
            JSON object with:
            - Best price and recommended distributor
            - Pricing comparison table across distributors
            - Pricing tiers for bulk ordering
            - MOQ (Minimum Order Quantity) for each distributor
            - Total cost calculations at different quantities

        Example:
            compare_distributor_pricing("STM32F407VGT6")
        """
        configured, error_response = _check_api_configured()
        if not configured:
            return json.dumps(error_response, indent=2)

        try:
            distributor_data = await nexar_client.compare_distributor_pricing(mpn)

            if not distributor_data:
                return json.dumps({
                    "success": False,
                    "message": f"No pricing data found for {mpn}",
                    "mpn": mpn
                }, indent=2)

            if not distributor_data:
                return json.dumps({
                    "success": False,
                    "message": f"No distributors have {mpn} in stock",
                    "mpn": mpn
                }, indent=2)

            # Find best deal
            best_distributor = distributor_data[0]  # Already sorted by price
            best_price = best_distributor.get("pricing_tiers", [{}])[0].get("price", 0)

            # Format comparison
            comparison_table = []
            for dist in distributor_data:
                pricing_tiers = dist.get("pricing_tiers", [])
                unit_price = pricing_tiers[0].get("price") if pricing_tiers else None

                comparison_table.append({
                    "distributor": dist.get("distributor"),
                    "sku": dist.get("sku"),
                    "stock": dist.get("stock"),
                    "moq": dist.get("moq"),
                    "packaging": dist.get("packaging"),
                    "unit_price": unit_price,
                    "pricing_tiers": [
                        {
                            "quantity": tier.get("quantity"),
                            "price": tier.get("price"),
                            "total": round(tier.get("quantity", 0) * tier.get("price", 0), 2)
                        }
                        for tier in pricing_tiers[:5]  # Show first 5 tiers
                    ],
                    "url": dist.get("url")
                })

            result = {
                "success": True,
                "component": {
                    "mpn": mpn
                },
                "best_deal": {
                    "distributor": best_distributor.get("distributor"),
                    "unit_price": best_price,
                    "stock": best_distributor.get("stock"),
                    "url": best_distributor.get("url")
                },
                "distributors_count": len(comparison_table),
                "comparison": comparison_table,
                "message": f"Best price: ${best_price} from {best_distributor.get('distributor')}",
                "note": "Prices shown are per unit. Check pricing tiers for volume discounts."
            }

            return json.dumps(result, indent=2)

        except Exception as e:
            return json.dumps({
                "success": False,
                "error": f"Price comparison failed: {str(e)}",
                "mpn": mpn
            }, indent=2)
