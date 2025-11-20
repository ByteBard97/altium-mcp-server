"""
Project management tool handlers
"""
import json
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from mcp.server.fastmcp import FastMCP
    from ..altium_bridge import AltiumBridge


def register_project_tools(mcp: "FastMCP", altium_bridge: "AltiumBridge"):
    """Register all project management tools"""

    @mcp.tool()
    async def create_project(project_name: str, project_path: str, template: str = "blank") -> str:
        """
        Create a new Altium project with a blank PCB

        Args:
            project_name: Name of the project
            project_path: Directory path where project will be created
            template: Project template to use (blank, arduino, raspberry_pi)

        Returns:
            JSON object with success status and project file path
        """
        response = await altium_bridge.call_script("create_project", {
            "project_name": project_name,
            "project_path": project_path,
            "template": template
        })

        if not response.success:
            return json.dumps({
                "success": False,
                "error": f"Failed to create project: {response.error}"
            })

        return json.dumps({
            "success": True,
            "data": response.data
        }, indent=2)

    @mcp.tool()
    async def save_project() -> str:
        """
        Save the currently open project

        Returns:
            JSON object with success status and message
        """
        response = await altium_bridge.call_script("save_project", {})

        if not response.success:
            return json.dumps({
                "success": False,
                "error": f"Failed to save project: {response.error}"
            })

        return json.dumps({
            "success": True,
            "message": "Project saved successfully",
            "data": response.data
        }, indent=2)

    @mcp.tool()
    async def get_project_info() -> str:
        """
        Get detailed information about the currently open project including all documents

        Returns:
            JSON object with project name, path, file count, and list of all project documents.
            Each document includes:
            - kind: Document type (PCB, SCH, PCBLIB, SCHLIB, etc.)
            - file_name: Name of the file
            - full_path: Complete file path
        """
        response = await altium_bridge.call_script("get_project_info", {})

        if not response.success:
            return json.dumps({
                "success": False,
                "error": f"Failed to get project info: {response.error}"
            })

        return json.dumps({
            "success": True,
            "data": response.data
        }, indent=2)

    @mcp.tool()
    async def close_project() -> str:
        """
        Close the currently open project

        Returns:
            JSON object with success status and message
        """
        response = await altium_bridge.call_script("close_project", {})

        if not response.success:
            return json.dumps({
                "success": False,
                "error": f"Failed to close project: {response.error}"
            })

        return json.dumps({
            "success": True,
            "message": "Project closed successfully",
            "data": response.data
        }, indent=2)

    @mcp.tool()
    async def open_document(document_path: str, document_type: str) -> str:
        """
        Programmatically open and display a document in Altium Designer

        This tool allows you to open any document by its file path. The document will be
        opened if it's not already open, or brought to focus if it is.

        Args:
            document_path: Full path to the document file
            document_type: Type of document to open. Valid types:
                          - 'SCH' or 'Sch' for schematic documents
                          - 'PCB' for PCB documents
                          - 'SCHLIB' for schematic library documents
                          - 'PCBLIB' for PCB library documents
                          - 'OUTPUTJOB' for output job files
                          - 'Text' for text files

        Returns:
            JSON object with success status and document information

        Example:
            open_document("C:/Projects/MyBoard.PcbDoc", "PCB")
            open_document("C:/Projects/Schematic.SchDoc", "SCH")
        """
        response = await altium_bridge.call_script("open_document", {
            "document_path": document_path,
            "document_type": document_type
        })

        if not response.success:
            return json.dumps({
                "success": False,
                "error": f"Failed to open document: {response.error}"
            })

        return json.dumps({
            "success": True,
            "data": response.data
        }, indent=2)
