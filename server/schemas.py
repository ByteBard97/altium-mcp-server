"""
Type definitions and schemas for Altium MCP tools
"""
from typing import List, Dict, Any, Optional
from dataclasses import dataclass


# Pin type constants
PIN_TYPES = [
    "eElectricHiZ",
    "eElectricInput",
    "eElectricIO",
    "eElectricOpenCollector",
    "eElectricOpenEmitter",
    "eElectricOutput",
    "eElectricPassive",
    "eElectricPower"
]

# Pin orientation constants
PIN_ORIENTATIONS = [
    "eRotate0",    # right
    "eRotate90",   # down
    "eRotate180",  # left
    "eRotate270"   # up
]


@dataclass
class ComponentData:
    """Component data structure"""
    designator: str
    value: Optional[str] = None
    footprint: Optional[str] = None
    description: Optional[str] = None
    properties: Optional[Dict[str, Any]] = None


@dataclass
class PinData:
    """Pin data structure"""
    pin_number: str
    pin_name: str
    pin_type: str
    orientation: str
    x: float
    y: float


@dataclass
class LayerData:
    """PCB layer data structure"""
    name: str
    layer_id: str
    is_copper: bool
    is_mechanical: bool
    is_visible: bool
    is_enabled: bool


@dataclass
class NetData:
    """Net data structure"""
    net_name: str
    components: List[str]
    pins: List[str]


@dataclass
class RuleData:
    """Design rule data structure"""
    rule_name: str
    rule_type: str
    scope: str
    parameters: Dict[str, Any]


@dataclass
class StackupLayerData:
    """Layer stackup data structure"""
    layer_name: str
    layer_type: str
    thickness: float
    material: Optional[str] = None
    dielectric_constant: Optional[float] = None


# Tool parameter schemas
class ToolSchemas:
    """Schema definitions for tool parameters"""

    @staticmethod
    def create_schematic_symbol() -> Dict[str, Any]:
        """Schema for create_schematic_symbol tool"""
        return {
            "symbol_name": {"type": "string", "description": "Name of the symbol to create"},
            "description": {"type": "string", "description": "Description of the schematic symbol"},
            "pins": {
                "type": "array",
                "items": {"type": "string"},
                "description": "Pin definitions in format: pin_number|pin_name|pin_type|orientation|x|y"
            }
        }

    @staticmethod
    def move_components() -> Dict[str, Any]:
        """Schema for move_components tool"""
        return {
            "cmp_designators": {
                "type": "array",
                "items": {"type": "string"},
                "description": "List of component designators to move"
            },
            "x_offset": {"type": "number", "description": "X offset in mils"},
            "y_offset": {"type": "number", "description": "Y offset in mils"},
            "rotation": {"type": "number", "description": "Rotation angle in degrees (0-360)", "default": 0}
        }

    @staticmethod
    def create_net_class() -> Dict[str, Any]:
        """Schema for create_net_class tool"""
        return {
            "class_name": {"type": "string", "description": "Name of the net class"},
            "net_names": {
                "type": "array",
                "items": {"type": "string"},
                "description": "List of net names to add to the class"
            }
        }

    @staticmethod
    def set_pcb_layer_visibility() -> Dict[str, Any]:
        """Schema for set_pcb_layer_visibility tool"""
        return {
            "layer_names": {
                "type": "array",
                "items": {"type": "string"},
                "description": "List of layer names to modify"
            },
            "visible": {"type": "boolean", "description": "Whether to show (true) or hide (false) the layers"}
        }

    @staticmethod
    def layout_duplicator_apply() -> Dict[str, Any]:
        """Schema for layout_duplicator_apply tool"""
        return {
            "source_designators": {
                "type": "array",
                "items": {"type": "string"},
                "description": "Source component designators"
            },
            "destination_designators": {
                "type": "array",
                "items": {"type": "string"},
                "description": "Destination component designators (must match source length)"
            }
        }

    @staticmethod
    def run_drc_with_history() -> Dict[str, Any]:
        """Schema for run_drc_with_history tool"""
        return {
            "project_path": {
                "type": "string",
                "description": "Path to the project (used as identifier in history). If empty, uses current project.",
                "default": ""
            }
        }

    @staticmethod
    def get_drc_history() -> Dict[str, Any]:
        """Schema for get_drc_history tool"""
        return {
            "project_path": {
                "type": "string",
                "description": "Path to the project. If empty, uses current project.",
                "default": ""
            },
            "limit": {
                "type": "integer",
                "description": "Maximum number of historical runs to return",
                "default": 10
            }
        }

    @staticmethod
    def get_drc_run_details() -> Dict[str, Any]:
        """Schema for get_drc_run_details tool"""
        return {
            "run_id": {
                "type": "integer",
                "description": "The ID of the DRC run to retrieve"
            }
        }

    @staticmethod
    def identify_circuit_patterns() -> Dict[str, Any]:
        """Schema for identify_circuit_patterns tool"""
        return {}  # No parameters required

    # ========================================================================
    # Phase 2: Project Management Tools
    # ========================================================================

    @staticmethod
    def create_project() -> Dict[str, Any]:
        """Schema for create_project tool"""
        return {
            "project_name": {
                "type": "string",
                "description": "Name of the project"
            },
            "project_path": {
                "type": "string",
                "description": "Directory path where project will be created"
            },
            "template": {
                "type": "string",
                "description": "Project template to use",
                "enum": ["blank", "arduino", "raspberry_pi"],
                "default": "blank"
            }
        }

    @staticmethod
    def save_project() -> Dict[str, Any]:
        """Schema for save_project tool"""
        return {
            # No parameters required
        }

    @staticmethod
    def get_project_info() -> Dict[str, Any]:
        """Schema for get_project_info tool"""
        return {
            # No parameters required
        }

    @staticmethod
    def close_project() -> Dict[str, Any]:
        """Schema for close_project tool"""
        return {
            # No parameters required
        }

    # ========================================================================
    # Phase 2: Library Search Tools
    # ========================================================================

    @staticmethod
    def list_component_libraries() -> Dict[str, Any]:
        """Schema for list_component_libraries tool"""
        return {
            # No parameters required
        }

    @staticmethod
    def search_components() -> Dict[str, Any]:
        """Schema for search_components tool"""
        return {
            "query": {
                "type": "string",
                "description": "Search query string (matches component name and description)"
            }
        }

    @staticmethod
    def get_component_from_library() -> Dict[str, Any]:
        """Schema for get_component_from_library tool"""
        return {
            "library_name": {
                "type": "string",
                "description": "Name of the library containing the component"
            },
            "component_name": {
                "type": "string",
                "description": "Name of the component to retrieve"
            }
        }

    @staticmethod
    def search_footprints() -> Dict[str, Any]:
        """Schema for search_footprints tool"""
        return {
            "query": {
                "type": "string",
                "description": "Search query string (matches footprint name and description)"
            }
        }

    @staticmethod
    def set_board_size() -> Dict[str, Any]:
        """Schema for set_board_size tool"""
        return {
            "width": {
                "type": "number",
                "description": "Board width in millimeters"
            },
            "height": {
                "type": "number",
                "description": "Board height in millimeters"
            }
        }

    @staticmethod
    def add_board_outline() -> Dict[str, Any]:
        """Schema for add_board_outline tool"""
        return {
            "x": {
                "type": "number",
                "description": "X coordinate of bottom-left corner in millimeters"
            },
            "y": {
                "type": "number",
                "description": "Y coordinate of bottom-left corner in millimeters"
            },
            "width": {
                "type": "number",
                "description": "Width of the board outline in millimeters"
            },
            "height": {
                "type": "number",
                "description": "Height of the board outline in millimeters"
            }
        }

    @staticmethod
    def add_mounting_hole() -> Dict[str, Any]:
        """Schema for add_mounting_hole tool"""
        return {
            "x": {
                "type": "number",
                "description": "X coordinate in millimeters"
            },
            "y": {
                "type": "number",
                "description": "Y coordinate in millimeters"
            },
            "hole_diameter": {
                "type": "number",
                "description": "Diameter of the hole in millimeters"
            },
            "pad_diameter": {
                "type": "number",
                "description": "Diameter of the pad (optional, defaults to hole_diameter * 2)",
                "default": None
            }
        }

    @staticmethod
    def add_board_text() -> Dict[str, Any]:
        """Schema for add_board_text tool"""
        return {
            "text": {
                "type": "string",
                "description": "Text string to add"
            },
            "x": {
                "type": "number",
                "description": "X coordinate in millimeters"
            },
            "y": {
                "type": "number",
                "description": "Y coordinate in millimeters"
            },
            "layer": {
                "type": "string",
                "description": "Layer name (default: TopOverlay)",
                "default": "TopOverlay"
            },
            "size": {
                "type": "number",
                "description": "Text size in millimeters (default: 1.0)",
                "default": 1.0
            }
        }

    @staticmethod
    def route_trace() -> Dict[str, Any]:
        """Schema for route_trace tool"""
        return {
            "x1": {
                "type": "number",
                "description": "Starting X coordinate in millimeters"
            },
            "y1": {
                "type": "number",
                "description": "Starting Y coordinate in millimeters"
            },
            "x2": {
                "type": "number",
                "description": "Ending X coordinate in millimeters"
            },
            "y2": {
                "type": "number",
                "description": "Ending Y coordinate in millimeters"
            },
            "layer": {
                "type": "string",
                "description": "Layer name (e.g., TopLayer, BottomLayer, MidLayer1)"
            },
            "width": {
                "type": "number",
                "description": "Trace width in millimeters"
            },
            "net_name": {
                "type": "string",
                "description": "Optional net name to assign to the trace",
                "default": None
            }
        }

    @staticmethod
    def add_via() -> Dict[str, Any]:
        """Schema for add_via tool"""
        return {
            "x": {
                "type": "number",
                "description": "X coordinate in millimeters"
            },
            "y": {
                "type": "number",
                "description": "Y coordinate in millimeters"
            },
            "diameter": {
                "type": "number",
                "description": "Via diameter (pad size) in millimeters"
            },
            "hole_size": {
                "type": "number",
                "description": "Via hole diameter in millimeters"
            },
            "start_layer": {
                "type": "string",
                "description": "Starting layer name (default: TopLayer)",
                "default": "TopLayer"
            },
            "end_layer": {
                "type": "string",
                "description": "Ending layer name (default: BottomLayer)",
                "default": "BottomLayer"
            },
            "net_name": {
                "type": "string",
                "description": "Optional net name to assign to the via",
                "default": None
            }
        }

    @staticmethod
    def add_copper_pour() -> Dict[str, Any]:
        """Schema for add_copper_pour tool"""
        return {
            "x": {
                "type": "number",
                "description": "X coordinate of bottom-left corner in millimeters"
            },
            "y": {
                "type": "number",
                "description": "Y coordinate of bottom-left corner in millimeters"
            },
            "width": {
                "type": "number",
                "description": "Width of the copper pour in millimeters"
            },
            "height": {
                "type": "number",
                "description": "Height of the copper pour in millimeters"
            },
            "layer": {
                "type": "string",
                "description": "Layer name (e.g., TopLayer, BottomLayer)"
            },
            "net_name": {
                "type": "string",
                "description": "Net name to assign to the copper pour (typically GND or a power net)"
            },
            "pour_over_same_net": {
                "type": "boolean",
                "description": "Whether to pour over objects on the same net (default: True)",
                "default": True
            }
        }


# Resource URIs
class ResourceURIs:
    """Resource URI constants"""
    PROJECT_INFO = "altium://project/current/info"
    PROJECT_COMPONENTS = "altium://project/current/components"
    PROJECT_NETS = "altium://project/current/nets"
    PROJECT_LAYERS = "altium://project/current/layers"
    PROJECT_STACKUP = "altium://project/current/stackup"
    PROJECT_RULES = "altium://project/current/rules"
    BOARD_PREVIEW = "altium://board/preview"
    BOARD_PREVIEW_PNG = "altium://board/preview.png"
