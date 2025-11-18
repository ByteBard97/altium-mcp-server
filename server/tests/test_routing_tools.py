"""
Unit tests for routing tools (Phase 5)
Tests for route_trace, add_via, and add_copper_pour
"""
import pytest
import json
from unittest.mock import AsyncMock, MagicMock
from server.tools.routing_tools import register_routing_tools


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


class TestRouteTrace:
    """Tests for route_trace tool"""

    @pytest.mark.asyncio
    async def test_route_trace_success(self, mock_mcp, mock_altium_bridge):
        """Test successful trace routing"""
        # Setup mock response
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=True,
            data={"message": "Trace routed", "width": "0.25mm", "layer": "TopLayer"}
        )

        # Register tools
        register_routing_tools(mock_mcp, mock_altium_bridge)

        # Get the tool function
        route_trace_func = mock_mcp.tool_handlers['route_trace']

        # Call the tool
        result = await route_trace_func(10, 10, 50, 50, "TopLayer", 0.25, "GND")

        # Parse result
        result_data = json.loads(result)

        # Assertions
        assert result_data['success'] is True
        assert result_data['data']['layer'] == "TopLayer"
        mock_altium_bridge.call_script.assert_called_once()

    @pytest.mark.asyncio
    async def test_route_trace_without_net(self, mock_mcp, mock_altium_bridge):
        """Test trace routing without net assignment"""
        # Setup mock response
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=True,
            data={"message": "Trace routed"}
        )

        # Register tools
        register_routing_tools(mock_mcp, mock_altium_bridge)

        # Get the tool function
        route_trace_func = mock_mcp.tool_handlers['route_trace']

        # Call the tool (no net name)
        result = await route_trace_func(0, 0, 10, 10, "BottomLayer", 0.5, None)

        # Parse result
        result_data = json.loads(result)

        # Assertions
        assert result_data['success'] is True


class TestAddVia:
    """Tests for add_via tool"""

    @pytest.mark.asyncio
    async def test_add_via_success(self, mock_mcp, mock_altium_bridge):
        """Test successful via addition"""
        # Setup mock response
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=True,
            data={
                "message": "Via added",
                "diameter": "0.6mm",
                "hole_size": "0.3mm",
                "start_layer": "TopLayer",
                "end_layer": "BottomLayer"
            }
        )

        # Register tools
        register_routing_tools(mock_mcp, mock_altium_bridge)

        # Get the tool function
        add_via_func = mock_mcp.tool_handlers['add_via']

        # Call the tool
        result = await add_via_func(25, 25, 0.6, 0.3, "TopLayer", "BottomLayer", "VCC")

        # Parse result
        result_data = json.loads(result)

        # Assertions
        assert result_data['success'] is True
        assert result_data['data']['diameter'] == "0.6mm"
        mock_altium_bridge.call_script.assert_called_once()


class TestAddCopperPour:
    """Tests for add_copper_pour tool"""

    @pytest.mark.asyncio
    async def test_add_copper_pour_success(self, mock_mcp, mock_altium_bridge):
        """Test successful copper pour addition"""
        # Setup mock response
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=True,
            data={
                "message": "Copper pour added",
                "net": "GND",
                "layer": "BottomLayer"
            }
        )

        # Register tools
        register_routing_tools(mock_mcp, mock_altium_bridge)

        # Get the tool function
        add_copper_pour_func = mock_mcp.tool_handlers['add_copper_pour']

        # Call the tool
        result = await add_copper_pour_func(0, 0, 100, 80, "BottomLayer", "GND", True)

        # Parse result
        result_data = json.loads(result)

        # Assertions
        assert result_data['success'] is True
        assert result_data['data']['net'] == "GND"
        assert result_data['data']['layer'] == "BottomLayer"
        mock_altium_bridge.call_script.assert_called_once()

    @pytest.mark.asyncio
    async def test_add_copper_pour_error(self, mock_mcp, mock_altium_bridge):
        """Test copper pour with error"""
        # Setup mock response
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=False,
            error="Invalid layer name"
        )

        # Register tools
        register_routing_tools(mock_mcp, mock_altium_bridge)

        # Get the tool function
        add_copper_pour_func = mock_mcp.tool_handlers['add_copper_pour']

        # Call the tool
        result = await add_copper_pour_func(0, 0, 100, 80, "InvalidLayer", "GND", True)

        # Parse result
        result_data = json.loads(result)

        # Assertions
        assert result_data['success'] is False
        assert "error" in result_data
