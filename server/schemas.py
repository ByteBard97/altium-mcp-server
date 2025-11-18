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
