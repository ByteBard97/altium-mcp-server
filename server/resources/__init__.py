"""
Resource handlers for Altium MCP
Resources provide read-only access to project state
"""
from .project_resources import register_project_resources
from .board_resources import register_board_resources

__all__ = ['register_project_resources', 'register_board_resources']
