"""
Unit tests for component operation tools (Phase 4)
Tests for place_component, delete_component, place_component_array, and align_components
"""
import pytest
import json
from unittest.mock import AsyncMock, MagicMock
from server.tools.component_ops_tools import register_component_ops_tools


class MockResponse:
    """Mock response from altium_bridge.call_script"""
    def __init__(self, success: bool, data: dict = None, error: str = None):
        self.success = success
        self.data = data if data else {}
        self.error = error


@pytest.fixture
def mock_altium_bridge():
    """Create a mock AltiumBridge"""
    bridge = MagicMock()
    bridge.call_script = AsyncMock()
    return bridge


@pytest.fixture
def mock_mcp():
    """Create a mock FastMCP server"""
    mcp = MagicMock()
    mcp.tool_handlers = {}

    def tool_decorator():
        def decorator(func):
            mcp.tool_handlers[func.__name__] = func
            return func
        return decorator

    mcp.tool = tool_decorator
    return mcp


class TestPlaceComponent:
    """Tests for place_component tool"""

    @pytest.mark.asyncio
    async def test_place_component_success(self, mock_mcp, mock_altium_bridge):
        """Test successful component placement"""
        # Setup mock response
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=True,
            data={
                "success": True,
                "designator": "R1",
                "footprint": "0805",
                "x": 10.0,
                "y": 20.0,
                "layer": 0,
                "rotation": 0
            }
        )

        # Register tools
        register_component_ops_tools(mock_mcp, mock_altium_bridge)

        # Call the tool
        place_component = mock_mcp.tool_handlers['place_component']
        result = await place_component("R1", "0805", 10.0, 20.0, 0, 0)

        # Parse result
        result_data = json.loads(result)

        # Verify result
        assert result_data["success"] is True
        assert result_data["designator"] == "R1"
        assert result_data["footprint"] == "0805"

        # Verify bridge was called correctly
        mock_altium_bridge.call_script.assert_called_once_with(
            "place_component",
            {
                "designator": "R1",
                "footprint": "0805",
                "x": 10.0,
                "y": 20.0,
                "layer": 0,
                "rotation": 0
            }
        )

    @pytest.mark.asyncio
    async def test_place_component_with_rotation(self, mock_mcp, mock_altium_bridge):
        """Test component placement with rotation"""
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=True,
            data={
                "success": True,
                "designator": "C1",
                "footprint": "0805",
                "x": 15.0,
                "y": 25.0,
                "layer": 1,
                "rotation": 90
            }
        )

        register_component_ops_tools(mock_mcp, mock_altium_bridge)
        place_component = mock_mcp.tool_handlers['place_component']
        result = await place_component("C1", "0805", 15.0, 25.0, 1, 90)

        result_data = json.loads(result)
        assert result_data["success"] is True
        assert result_data["rotation"] == 90
        assert result_data["layer"] == 1

    @pytest.mark.asyncio
    async def test_place_component_footprint_not_found(self, mock_mcp, mock_altium_bridge):
        """Test component placement when footprint is not found"""
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=False,
            error="Footprint not found: UNKNOWN_FOOTPRINT"
        )

        register_component_ops_tools(mock_mcp, mock_altium_bridge)
        place_component = mock_mcp.tool_handlers['place_component']
        result = await place_component("R1", "UNKNOWN_FOOTPRINT", 10.0, 20.0, 0, 0)

        result_data = json.loads(result)
        assert result_data["success"] is False
        assert "Footprint not found" in result_data["error"]


class TestDeleteComponent:
    """Tests for delete_component tool"""

    @pytest.mark.asyncio
    async def test_delete_component_success(self, mock_mcp, mock_altium_bridge):
        """Test successful component deletion"""
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=True,
            data={
                "success": True,
                "message": "Component deleted: R1"
            }
        )

        register_component_ops_tools(mock_mcp, mock_altium_bridge)
        delete_component = mock_mcp.tool_handlers['delete_component']
        result = await delete_component("R1")

        result_data = json.loads(result)
        assert result_data["success"] is True
        assert "deleted" in result_data["message"].lower()

        mock_altium_bridge.call_script.assert_called_once_with(
            "delete_component",
            {"designator": "R1"}
        )

    @pytest.mark.asyncio
    async def test_delete_component_not_found(self, mock_mcp, mock_altium_bridge):
        """Test deletion of non-existent component"""
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=False,
            error="Component not found: R999"
        )

        register_component_ops_tools(mock_mcp, mock_altium_bridge)
        delete_component = mock_mcp.tool_handlers['delete_component']
        result = await delete_component("R999")

        result_data = json.loads(result)
        assert result_data["success"] is False
        assert "not found" in result_data["error"].lower()


class TestPlaceComponentArray:
    """Tests for place_component_array tool"""

    @pytest.mark.asyncio
    async def test_place_component_array_success(self, mock_mcp, mock_altium_bridge):
        """Test successful component array placement"""
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=True,
            data={
                "success": True,
                "count": 6,
                "components": ["R1", "R2", "R3", "R4", "R5", "R6"]
            }
        )

        register_component_ops_tools(mock_mcp, mock_altium_bridge)
        place_component_array = mock_mcp.tool_handlers['place_component_array']
        result = await place_component_array(
            "0805", "R", 10.0, 10.0, 5.0, 5.0, 2, 3
        )

        result_data = json.loads(result)
        assert result_data["success"] is True
        assert result_data["count"] == 6
        assert len(result_data["components"]) == 6

        mock_altium_bridge.call_script.assert_called_once_with(
            "place_component_array",
            {
                "footprint": "0805",
                "ref_des": "R",
                "start_x": 10.0,
                "start_y": 10.0,
                "spacing_x": 5.0,
                "spacing_y": 5.0,
                "rows": 2,
                "cols": 3
            }
        )

    @pytest.mark.asyncio
    async def test_place_component_array_single_row(self, mock_mcp, mock_altium_bridge):
        """Test placing a single row of components"""
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=True,
            data={
                "success": True,
                "count": 4,
                "components": ["C1", "C2", "C3", "C4"]
            }
        )

        register_component_ops_tools(mock_mcp, mock_altium_bridge)
        place_component_array = mock_mcp.tool_handlers['place_component_array']
        result = await place_component_array(
            "0805", "C", 0.0, 0.0, 5.0, 0.0, 1, 4
        )

        result_data = json.loads(result)
        assert result_data["success"] is True
        assert result_data["count"] == 4


class TestAlignComponents:
    """Tests for align_components tool"""

    @pytest.mark.asyncio
    async def test_align_components_left(self, mock_mcp, mock_altium_bridge):
        """Test left alignment of components"""
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=True,
            data={
                "success": True,
                "message": "Components aligned",
                "alignment": "left",
                "count": 3
            }
        )

        register_component_ops_tools(mock_mcp, mock_altium_bridge)
        align_components = mock_mcp.tool_handlers['align_components']
        result = await align_components("R1,R2,R3", "left")

        result_data = json.loads(result)
        assert result_data["success"] is True
        assert result_data["alignment"] == "left"
        assert result_data["count"] == 3

        mock_altium_bridge.call_script.assert_called_once_with(
            "align_components",
            {
                "designators": "R1,R2,R3",
                "alignment": "left"
            }
        )

    @pytest.mark.asyncio
    async def test_align_components_all_directions(self, mock_mcp, mock_altium_bridge):
        """Test alignment in all four directions"""
        register_component_ops_tools(mock_mcp, mock_altium_bridge)
        align_components = mock_mcp.tool_handlers['align_components']

        for alignment in ["left", "right", "top", "bottom"]:
            mock_altium_bridge.call_script.return_value = MockResponse(
                success=True,
                data={
                    "success": True,
                    "message": "Components aligned",
                    "alignment": alignment,
                    "count": 2
                }
            )

            result = await align_components("R1,R2", alignment)
            result_data = json.loads(result)

            assert result_data["success"] is True
            assert result_data["alignment"] == alignment

    @pytest.mark.asyncio
    async def test_align_components_component_not_found(self, mock_mcp, mock_altium_bridge):
        """Test alignment when a component is not found"""
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=False,
            error="Component not found: R999"
        )

        register_component_ops_tools(mock_mcp, mock_altium_bridge)
        align_components = mock_mcp.tool_handlers['align_components']
        result = await align_components("R1,R999", "left")

        result_data = json.loads(result)
        assert result_data["success"] is False
        assert "not found" in result_data["error"].lower()


class TestIntegration:
    """Integration tests for component operations workflow"""

    @pytest.mark.asyncio
    async def test_place_and_delete_workflow(self, mock_mcp, mock_altium_bridge):
        """Test placing and then deleting a component"""
        register_component_ops_tools(mock_mcp, mock_altium_bridge)

        # Place component
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=True,
            data={"success": True, "designator": "R1", "footprint": "0805"}
        )

        place_component = mock_mcp.tool_handlers['place_component']
        result = await place_component("R1", "0805", 10.0, 20.0, 0, 0)
        result_data = json.loads(result)
        assert result_data["success"] is True

        # Delete component
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=True,
            data={"success": True, "message": "Component deleted: R1"}
        )

        delete_component = mock_mcp.tool_handlers['delete_component']
        result = await delete_component("R1")
        result_data = json.loads(result)
        assert result_data["success"] is True

    @pytest.mark.asyncio
    async def test_place_array_and_align_workflow(self, mock_mcp, mock_altium_bridge):
        """Test placing an array and then aligning some components"""
        register_component_ops_tools(mock_mcp, mock_altium_bridge)

        # Place array
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=True,
            data={
                "success": True,
                "count": 4,
                "components": ["R1", "R2", "R3", "R4"]
            }
        )

        place_component_array = mock_mcp.tool_handlers['place_component_array']
        result = await place_component_array(
            "0805", "R", 10.0, 10.0, 5.0, 5.0, 2, 2
        )
        result_data = json.loads(result)
        assert result_data["success"] is True
        assert result_data["count"] == 4

        # Align components
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=True,
            data={
                "success": True,
                "message": "Components aligned",
                "alignment": "left",
                "count": 2
            }
        )

        align_components = mock_mcp.tool_handlers['align_components']
        result = await align_components("R1,R3", "left")
        result_data = json.loads(result)
        assert result_data["success"] is True
