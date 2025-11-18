"""
Component-related tool handlers
"""
import json
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from mcp.server.fastmcp import FastMCP
    from ..altium_bridge import AltiumBridge


def register_component_tools(mcp: "FastMCP", altium_bridge: "AltiumBridge"):
    """Register all component-related tools"""

    @mcp.tool()
    async def get_all_component_property_names() -> str:
        """
        Get all available component property names (JSON keys) from all components

        Returns:
            JSON array with all unique property names
        """
        response = await altium_bridge.call_script("get_all_component_data", {})

        if not response.success:
            return json.dumps({"error": f"Failed to get component data: {response.error}"})

        components_data = response.data

        if not components_data:
            return json.dumps({"error": "No component data found"})

        try:
            # Extract all unique property names from all components
            property_names = set()
            for component in components_data:
                property_names.update(component.keys())

            # Convert set to sorted list for consistent output
            property_list = sorted(list(property_names))

            return json.dumps(property_list, indent=2)
        except Exception as e:
            return json.dumps({"error": f"Failed to process component data: {str(e)}"})

    @mcp.tool()
    async def get_component_property_values(property_name: str) -> str:
        """
        Get values of a specific property for all components

        Args:
            property_name: The name of the property to get values for

        Returns:
            JSON array with objects containing designator and property value
        """
        response = await altium_bridge.call_script("get_all_component_data", {})

        if not response.success:
            return json.dumps({"error": f"Failed to get component data: {response.error}"})

        components_data = response.data

        if not components_data:
            return json.dumps({"error": "No component data found"})

        try:
            # Extract the property values along with designators
            property_values = []
            for component in components_data:
                designator = component.get("designator")
                if designator and property_name in component:
                    property_values.append({
                        "designator": designator,
                        "value": component.get(property_name)
                    })

            return json.dumps(property_values, indent=2)
        except Exception as e:
            return json.dumps({"error": f"Failed to process component data: {str(e)}"})

    @mcp.tool()
    async def get_component_data(cmp_designators: list[str]) -> str:
        """
        Get all data for components in Altium

        Args:
            cmp_designators: List of designators of the components (e.g., ["R1", "C5", "U3"])

        Returns:
            JSON object with all component data for requested designators
        """
        response = await altium_bridge.call_script("get_all_component_data", {})

        if not response.success:
            return json.dumps({"error": f"Failed to get component data: {response.error}"})

        component_data = response.data

        if not component_data:
            return json.dumps({"error": "No component data found"})

        try:
            # Filter components by designator
            components = []
            missing_designators = []

            for designator in cmp_designators:
                found = False
                for component in component_data:
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
            return json.dumps({"error": f"Failed to process component data: {str(e)}"})

    @mcp.tool()
    async def get_all_designators() -> str:
        """
        Get all component designators from the current Altium board

        Returns:
            JSON array of all component designators on the current board
        """
        response = await altium_bridge.call_script("get_all_component_data", {})

        if not response.success:
            return json.dumps({"error": f"Failed to get component data: {response.error}"})

        component_data = response.data

        if not component_data:
            return json.dumps({"error": "No component data found"})

        try:
            # Extract designators
            designators = [comp.get("designator") for comp in component_data if "designator" in comp]

            return json.dumps(designators)
        except Exception as e:
            return json.dumps({"error": f"Failed to process component data: {str(e)}"})

    @mcp.tool()
    async def get_component_pins(cmp_designators: list[str]) -> str:
        """
        Get pin data for components in Altium

        Args:
            cmp_designators: List of designators of the components (e.g., ["R1", "C5", "U3"])

        Returns:
            JSON object with pin data for requested designators
        """
        response = await altium_bridge.call_script("get_component_pins", {"designators": cmp_designators})

        if not response.success:
            return json.dumps({"error": f"Failed to get pin data: {response.error}"})

        pins_data = response.data

        if not pins_data:
            return json.dumps({"message": "No pin data found for the specified components"})

        return json.dumps(pins_data, indent=2)

    @mcp.tool()
    async def get_selected_components_coordinates() -> str:
        """
        Get coordinates and positioning information for selected components in Altium layout

        Returns:
            JSON array with positioning data (designator, x, y, rotation, width, height)
        """
        response = await altium_bridge.call_script("get_selected_components_coordinates", {})

        if not response.success:
            return json.dumps({"error": f"Failed to get selected components coordinates: {response.error}"})

        components_coords = response.data

        if not components_coords:
            return json.dumps({"message": "No components are currently selected in the layout"})

        return json.dumps(components_coords, indent=2)

    @mcp.tool()
    async def move_components(cmp_designators: list[str], x_offset: float, y_offset: float, rotation: float = 0) -> str:
        """
        Move selected components by specified X and Y offsets in the PCB layout

        Args:
            cmp_designators: List of designators of the components to move (e.g., ["R1", "C5", "U3"])
            x_offset: X offset distance in mils
            y_offset: Y offset distance in mils
            rotation: New rotation angle in degrees (0-360), if 0 the rotation is not changed

        Returns:
            JSON object with the result of the move operation
        """
        response = await altium_bridge.call_script("move_components", {
            "designators": cmp_designators,
            "x_offset": x_offset,
            "y_offset": y_offset,
            "rotation": rotation
        })

        if not response.success:
            return json.dumps({"success": False, "error": f"Failed to move components: {response.error}"})

        return json.dumps({"success": True, "result": response.data}, indent=2)
