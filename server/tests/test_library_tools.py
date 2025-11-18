"""
Unit tests for library search and component discovery tools
"""
import pytest
import json
from unittest.mock import AsyncMock, MagicMock, patch
from pathlib import Path
import sys

# Add parent directory to path to import modules
sys.path.insert(0, str(Path(__file__).parent.parent))

from tools.library_tools import register_library_tools
from altium_bridge import ScriptResponse


@pytest.fixture
def mock_mcp():
    """Create a mock FastMCP instance"""
    mcp = MagicMock()
    mcp.tool = MagicMock(return_value=lambda f: f)
    return mcp


@pytest.fixture
def mock_bridge():
    """Create a mock AltiumBridge instance"""
    bridge = MagicMock()
    bridge.call_script = AsyncMock()
    return bridge


@pytest.mark.asyncio
async def test_list_component_libraries_success(mock_mcp, mock_bridge):
    """Test listing component libraries"""
    # Setup
    register_library_tools(mock_mcp, mock_bridge)
    list_libraries = mock_mcp.tool.call_args_list[0][0][0]

    # Mock successful response
    mock_bridge.call_script.return_value = ScriptResponse(
        success=True,
        data={
            "success": True,
            "libraries": [
                {
                    "name": "Resistors.SchLib",
                    "path": "C:\\Libraries\\Resistors.SchLib",
                    "type": "Schematic Library"
                },
                {
                    "name": "Capacitors.SchLib",
                    "path": "C:\\Libraries\\Capacitors.SchLib",
                    "type": "Schematic Library"
                },
                {
                    "name": "SMD_0805.PcbLib",
                    "path": "C:\\Libraries\\SMD_0805.PcbLib",
                    "type": "PCB Library"
                }
            ]
        },
        error=None
    )

    # Execute
    result = await list_libraries()

    # Verify
    result_data = json.loads(result)
    assert result_data["success"] is True
    assert len(result_data["data"]["libraries"]) == 3
    assert result_data["data"]["libraries"][0]["name"] == "Resistors.SchLib"

    # Verify bridge was called
    mock_bridge.call_script.assert_called_once_with("list_component_libraries", {})


@pytest.mark.asyncio
async def test_list_component_libraries_no_workspace(mock_mcp, mock_bridge):
    """Test listing libraries when no workspace is available"""
    # Setup
    register_library_tools(mock_mcp, mock_bridge)
    list_libraries = mock_mcp.tool.call_args_list[0][0][0]

    # Mock failure response
    mock_bridge.call_script.return_value = ScriptResponse(
        success=False,
        data=None,
        error="No workspace available"
    )

    # Execute
    result = await list_libraries()

    # Verify
    result_data = json.loads(result)
    assert result_data["success"] is False
    assert "No workspace available" in result_data["error"]


@pytest.mark.asyncio
async def test_search_components_success(mock_mcp, mock_bridge):
    """Test searching for components"""
    # Setup
    register_library_tools(mock_mcp, mock_bridge)
    search_components = mock_mcp.tool.call_args_list[1][0][0]

    # Mock successful response
    mock_bridge.call_script.return_value = ScriptResponse(
        success=True,
        data={
            "success": True,
            "query": "LM358",
            "results": [
                {
                    "name": "LM358",
                    "description": "Dual Op-Amp",
                    "library": "OpAmps.SchLib",
                    "library_path": "C:\\Libraries\\OpAmps.SchLib"
                },
                {
                    "name": "LM358N",
                    "description": "Dual Op-Amp DIP-8",
                    "library": "OpAmps.SchLib",
                    "library_path": "C:\\Libraries\\OpAmps.SchLib"
                }
            ],
            "match_count": 2
        },
        error=None
    )

    # Execute
    result = await search_components(query="LM358")

    # Verify
    result_data = json.loads(result)
    assert result_data["success"] is True
    assert result_data["query"] == "LM358"
    assert len(result_data["data"]["results"]) == 2
    assert result_data["data"]["results"][0]["name"] == "LM358"

    # Verify bridge was called correctly
    mock_bridge.call_script.assert_called_once_with("search_components", {
        "query": "LM358"
    })


@pytest.mark.asyncio
async def test_search_components_no_results(mock_mcp, mock_bridge):
    """Test searching for components with no results"""
    # Setup
    register_library_tools(mock_mcp, mock_bridge)
    search_components = mock_mcp.tool.call_args_list[1][0][0]

    # Mock response with no results
    mock_bridge.call_script.return_value = ScriptResponse(
        success=True,
        data={
            "success": True,
            "query": "NONEXISTENT",
            "results": [],
            "match_count": 0
        },
        error=None
    )

    # Execute
    result = await search_components(query="NONEXISTENT")

    # Verify
    result_data = json.loads(result)
    assert result_data["success"] is True
    assert len(result_data["data"]["results"]) == 0
    assert result_data["data"]["match_count"] == 0


@pytest.mark.asyncio
async def test_get_component_from_library_success(mock_mcp, mock_bridge):
    """Test getting a specific component from a library"""
    # Setup
    register_library_tools(mock_mcp, mock_bridge)
    get_component = mock_mcp.tool.call_args_list[2][0][0]

    # Mock successful response
    mock_bridge.call_script.return_value = ScriptResponse(
        success=True,
        data={
            "success": True,
            "name": "LM358",
            "description": "Dual Op-Amp",
            "library": "OpAmps.SchLib",
            "pin_count": 8,
            "pins": []
        },
        error=None
    )

    # Execute
    result = await get_component(
        library_name="OpAmps.SchLib",
        component_name="LM358"
    )

    # Verify
    result_data = json.loads(result)
    assert result_data["success"] is True
    assert result_data["data"]["name"] == "LM358"
    assert result_data["data"]["pin_count"] == 8

    # Verify bridge was called correctly
    mock_bridge.call_script.assert_called_once_with("get_component_from_library", {
        "library_name": "OpAmps.SchLib",
        "component_name": "LM358"
    })


@pytest.mark.asyncio
async def test_get_component_from_library_not_found(mock_mcp, mock_bridge):
    """Test getting a component that doesn't exist"""
    # Setup
    register_library_tools(mock_mcp, mock_bridge)
    get_component = mock_mcp.tool.call_args_list[2][0][0]

    # Mock failure response
    mock_bridge.call_script.return_value = ScriptResponse(
        success=False,
        data=None,
        error="Component not found: NONEXISTENT in library: OpAmps.SchLib"
    )

    # Execute
    result = await get_component(
        library_name="OpAmps.SchLib",
        component_name="NONEXISTENT"
    )

    # Verify
    result_data = json.loads(result)
    assert result_data["success"] is False
    assert "not found" in result_data["error"]


@pytest.mark.asyncio
async def test_search_footprints_success(mock_mcp, mock_bridge):
    """Test searching for footprints"""
    # Setup
    register_library_tools(mock_mcp, mock_bridge)
    search_footprints = mock_mcp.tool.call_args_list[3][0][0]

    # Mock successful response
    mock_bridge.call_script.return_value = ScriptResponse(
        success=True,
        data={
            "success": True,
            "query": "0805",
            "results": [
                {
                    "name": "RES_0805",
                    "library": "SMD_Footprints.PcbLib",
                    "library_path": "C:\\Libraries\\SMD_Footprints.PcbLib",
                    "pad_count": 2
                },
                {
                    "name": "CAP_0805",
                    "library": "SMD_Footprints.PcbLib",
                    "library_path": "C:\\Libraries\\SMD_Footprints.PcbLib",
                    "pad_count": 2
                }
            ],
            "match_count": 2
        },
        error=None
    )

    # Execute
    result = await search_footprints(query="0805")

    # Verify
    result_data = json.loads(result)
    assert result_data["success"] is True
    assert result_data["query"] == "0805"
    assert len(result_data["data"]["results"]) == 2
    assert result_data["data"]["results"][0]["pad_count"] == 2

    # Verify bridge was called correctly
    mock_bridge.call_script.assert_called_once_with("search_footprints", {
        "query": "0805"
    })


@pytest.mark.asyncio
async def test_search_footprints_no_results(mock_mcp, mock_bridge):
    """Test searching for footprints with no results"""
    # Setup
    register_library_tools(mock_mcp, mock_bridge)
    search_footprints = mock_mcp.tool.call_args_list[3][0][0]

    # Mock response with no results
    mock_bridge.call_script.return_value = ScriptResponse(
        success=True,
        data={
            "success": True,
            "query": "NONEXISTENT",
            "results": [],
            "match_count": 0
        },
        error=None
    )

    # Execute
    result = await search_footprints(query="NONEXISTENT")

    # Verify
    result_data = json.loads(result)
    assert result_data["success"] is True
    assert len(result_data["data"]["results"]) == 0


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
