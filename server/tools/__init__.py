"""
Tool handlers for Altium MCP
Tools provide actions that can modify the design
"""
from .component_tools import register_component_tools
from .component_ops_tools import register_component_ops_tools
from .net_tools import register_net_tools
from .layer_tools import register_layer_tools
from .schematic_tools import register_schematic_tools
from .layout_tools import register_layout_tools
from .output_tools import register_output_tools
from .project_tools import register_project_tools
from .library_tools import register_library_tools
from .analysis_tools import register_analysis_tools
from .board_tools import register_board_tools
from .routing_tools import register_routing_tools

__all__ = [
    'register_component_tools',
    'register_component_ops_tools',
    'register_net_tools',
    'register_layer_tools',
    'register_schematic_tools',
    'register_layout_tools',
    'register_output_tools',
    'register_project_tools',
    'register_library_tools',
    'register_analysis_tools',
    'register_board_tools',
    'register_routing_tools'
]
