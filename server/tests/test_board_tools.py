"""
Unit tests for board initialization tools (Phase 5)
Tests for set_board_size, add_board_outline, add_mounting_hole, and add_board_text
"""
import pytest
import json
from unittest.mock import AsyncMock, MagicMock
from server.tools.board_tools import register_board_tools


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


class TestSetBoardSize:
    """Tests for set_board_size tool"""

    @pytest.mark.asyncio
    async def test_set_board_size_success(self, mock_mcp, mock_altium_bridge):
        """Test successful board size setting"""
        # Setup mock response
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=True,
            data={"width": "100mm", "height": "80mm"}
        )

        # Register tools
        register_board_tools(mock_mcp, mock_altium_bridge)

        # Get the tool function
        set_board_size_func = mock_mcp.tool_handlers['set_board_size']

        # Call the tool
        result = await set_board_size_func(100, 80)

        # Parse result
        result_data = json.loads(result)

        # Assertions
        assert result_data['success'] is True
        assert result_data['data']['width'] == "100mm"
        assert result_data['data']['height'] == "80mm"
        mock_altium_bridge.call_script.assert_called_once_with(
            "set_board_size",
            {"width": 100, "height": 80}
        )


class TestAddBoardOutline:
    """Tests for add_board_outline tool"""

    @pytest.mark.asyncio
    async def test_add_board_outline_success(self, mock_mcp, mock_altium_bridge):
        """Test successful board outline addition"""
        # Setup mock response
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=True,
            data={"message": "Board outline added"}
        )

        # Register tools
        register_board_tools(mock_mcp, mock_altium_bridge)

        # Get the tool function
        add_board_outline_func = mock_mcp.tool_handlers['add_board_outline']

        # Call the tool
        result = await add_board_outline_func(0, 0, 100, 80)

        # Parse result
        result_data = json.loads(result)

        # Assertions
        assert result_data['success'] is True
        mock_altium_bridge.call_script.assert_called_once()


class TestAddMountingHole:
    """Tests for add_mounting_hole tool"""

    @pytest.mark.asyncio
    async def test_add_mounting_hole_success(self, mock_mcp, mock_altium_bridge):
        """Test successful mounting hole addition"""
        # Setup mock response
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=True,
            data={"message": "Mounting hole added", "hole_diameter": "3.2mm"}
        )

        # Register tools
        register_board_tools(mock_mcp, mock_altium_bridge)

        # Get the tool function
        add_mounting_hole_func = mock_mcp.tool_handlers['add_mounting_hole']

        # Call the tool
        result = await add_mounting_hole_func(10, 10, 3.2, None)

        # Parse result
        result_data = json.loads(result)

        # Assertions
        assert result_data['success'] is True
        mock_altium_bridge.call_script.assert_called_once()


class TestAddBoardText:
    """Tests for add_board_text tool"""

    @pytest.mark.asyncio
    async def test_add_board_text_success(self, mock_mcp, mock_altium_bridge):
        """Test successful board text addition"""
        # Setup mock response
        mock_altium_bridge.call_script.return_value = MockResponse(
            success=True,
            data={"message": "Text added to board", "text": "TEST PCB"}
        )

        # Register tools
        register_board_tools(mock_mcp, mock_altium_bridge)

        # Get the tool function
        add_board_text_func = mock_mcp.tool_handlers['add_board_text']

        # Call the tool
        result = await add_board_text_func("TEST PCB", 50, 40, "TopOverlay", 1.5)

        # Parse result
        result_data = json.loads(result)

        # Assertions
        assert result_data['success'] is True
        assert result_data['data']['text'] == "TEST PCB"
        mock_altium_bridge.call_script.assert_called_once()
