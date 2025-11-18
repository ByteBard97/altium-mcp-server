"""
Unit tests for project management tools
"""
import pytest
import json
from unittest.mock import AsyncMock, MagicMock, patch
from pathlib import Path
import sys

# Add parent directory to path to import modules
sys.path.insert(0, str(Path(__file__).parent.parent))

from tools.project_tools import register_project_tools
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
async def test_create_project_success(mock_mcp, mock_bridge):
    """Test successful project creation"""
    # Setup
    register_project_tools(mock_mcp, mock_bridge)
    create_project = mock_mcp.tool.call_args_list[0][0][0]

    # Mock successful response
    mock_bridge.call_script.return_value = ScriptResponse(
        success=True,
        data={
            "success": True,
            "project_file": "C:\\Projects\\TestProject\\TestProject.PrjPCB",
            "project_name": "TestProject",
            "template": "blank"
        },
        error=None
    )

    # Execute
    result = await create_project(
        project_name="TestProject",
        project_path="C:\\Projects\\TestProject",
        template="blank"
    )

    # Verify
    result_data = json.loads(result)
    assert result_data["success"] is True
    assert "TestProject.PrjPCB" in result_data["data"]["project_file"]

    # Verify bridge was called correctly
    mock_bridge.call_script.assert_called_once_with("create_project", {
        "project_name": "TestProject",
        "project_path": "C:\\Projects\\TestProject",
        "template": "blank"
    })


@pytest.mark.asyncio
async def test_create_project_failure(mock_mcp, mock_bridge):
    """Test project creation failure"""
    # Setup
    register_project_tools(mock_mcp, mock_bridge)
    create_project = mock_mcp.tool.call_args_list[0][0][0]

    # Mock failure response
    mock_bridge.call_script.return_value = ScriptResponse(
        success=False,
        data=None,
        error="No workspace available"
    )

    # Execute
    result = await create_project(
        project_name="TestProject",
        project_path="C:\\Projects\\TestProject"
    )

    # Verify
    result_data = json.loads(result)
    assert result_data["success"] is False
    assert "No workspace available" in result_data["error"]


@pytest.mark.asyncio
async def test_save_project_success(mock_mcp, mock_bridge):
    """Test successful project save"""
    # Setup
    register_project_tools(mock_mcp, mock_bridge)
    save_project = mock_mcp.tool.call_args_list[1][0][0]

    # Mock successful response
    mock_bridge.call_script.return_value = ScriptResponse(
        success=True,
        data={
            "success": True,
            "message": "Project saved successfully",
            "project_file": "TestProject.PrjPCB"
        },
        error=None
    )

    # Execute
    result = await save_project()

    # Verify
    result_data = json.loads(result)
    assert result_data["success"] is True
    assert "saved successfully" in result_data["message"]

    # Verify bridge was called
    mock_bridge.call_script.assert_called_once_with("save_project", {})


@pytest.mark.asyncio
async def test_save_project_no_project_open(mock_mcp, mock_bridge):
    """Test save project when no project is open"""
    # Setup
    register_project_tools(mock_mcp, mock_bridge)
    save_project = mock_mcp.tool.call_args_list[1][0][0]

    # Mock failure response
    mock_bridge.call_script.return_value = ScriptResponse(
        success=False,
        data=None,
        error="No project open"
    )

    # Execute
    result = await save_project()

    # Verify
    result_data = json.loads(result)
    assert result_data["success"] is False
    assert "No project open" in result_data["error"]


@pytest.mark.asyncio
async def test_get_project_info_success(mock_mcp, mock_bridge):
    """Test getting project info"""
    # Setup
    register_project_tools(mock_mcp, mock_bridge)
    get_project_info = mock_mcp.tool.call_args_list[2][0][0]

    # Mock successful response
    mock_bridge.call_script.return_value = ScriptResponse(
        success=True,
        data={
            "success": True,
            "name": "TestProject.PrjPCB",
            "path": "C:\\Projects\\TestProject",
            "file_count": 3,
            "pcb_count": 1,
            "schematic_count": 2,
            "other_count": 0
        },
        error=None
    )

    # Execute
    result = await get_project_info()

    # Verify
    result_data = json.loads(result)
    assert result_data["success"] is True
    assert result_data["data"]["file_count"] == 3
    assert result_data["data"]["pcb_count"] == 1
    assert result_data["data"]["schematic_count"] == 2


@pytest.mark.asyncio
async def test_close_project_success(mock_mcp, mock_bridge):
    """Test closing a project"""
    # Setup
    register_project_tools(mock_mcp, mock_bridge)
    close_project = mock_mcp.tool.call_args_list[3][0][0]

    # Mock successful response
    mock_bridge.call_script.return_value = ScriptResponse(
        success=True,
        data={
            "success": True,
            "message": "Project closed successfully",
            "project_name": "TestProject.PrjPCB"
        },
        error=None
    )

    # Execute
    result = await close_project()

    # Verify
    result_data = json.loads(result)
    assert result_data["success"] is True
    assert "closed successfully" in result_data["message"]


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
