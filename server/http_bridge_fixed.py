#!/usr/bin/env python3
"""
HTTP Bridge for Altium MCP Server - FIXED VERSION
Exposes MCP tools as HTTP endpoints for web frontends
"""

import asyncio
import json
import logging
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn

# Import the altium bridge
from altium_bridge import AltiumBridge
from pathlib import Path

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("AltiumHTTPBridge")

# Initialize FastAPI app
app = FastAPI(title="Altium HTTP Bridge", version="1.0.0")

# Enable CORS for ALL origins (for development)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Altium bridge
MCP_DIR = Path(__file__).parent
DEFAULT_SCRIPT_PATH = MCP_DIR / "AltiumScript" / "Altium_API.PrjScr"
altium_bridge = AltiumBridge(MCP_DIR, DEFAULT_SCRIPT_PATH)

@app.get("/")
async def health_check():
    """Health check endpoint"""
    bridge_status = altium_bridge.status
    return {
        "status": "running",
        "service": "Altium HTTP Bridge",
        "version": "1.0.0",
        "altium_connected": bridge_status == "ready"
    }

@app.post("/api/extract-board")
async def extract_board_data():
    """Extract full board data from Altium"""
    try:
        logger.info("Extracting board data from Altium...")

        # Get all nets
        nets_response = await altium_bridge.call_script("get_all_nets", {})
        if not nets_response.success:
            raise HTTPException(status_code=500, detail=f"Failed to get nets: {nets_response.error}")
        nets_data = nets_response.data

        # Get all components
        components_response = await altium_bridge.call_script("get_all_component_data", {})
        if not components_response.success:
            raise HTTPException(status_code=500, detail=f"Failed to get components: {components_response.error}")
        components_data = components_response.data

        # Get layer stackup
        stackup_response = await altium_bridge.call_script("get_pcb_layer_stackup", {})
        if not stackup_response.success:
            logger.warning(f"Failed to get layer stackup: {stackup_response.error}")
            layers_data = []
        else:
            layers_data = stackup_response.data

        # Extract layer names from layer stackup data
        layer_names = []
        if isinstance(layers_data, dict) and 'layers' in layers_data:
            layer_names = [layer.get('name', '') for layer in layers_data.get('layers', [])]
        elif isinstance(layers_data, list):
            layer_names = [layer.get('name', '') if isinstance(layer, dict) else str(layer) for layer in layers_data]

        # Get board outline
        outline_response = await altium_bridge.call_script("get_board_outline", {})
        if not outline_response.success:
            logger.warning(f"Failed to get board outline: {outline_response.error}")
            board_outline = []
        else:
            board_outline = outline_response.data if isinstance(outline_response.data, list) else []

        logger.info(f"Extracted {len(nets_data)} nets, {len(components_data)} components, {len(layer_names)} layers, {len(board_outline)} outline points")

        return {
            "success": True,
            "data": {
                "vias": [],
                "nets": [net.get("name", "") for net in nets_data] if isinstance(nets_data, list) else [],
                "components": components_data if isinstance(components_data, list) else [],
                "board_outline": board_outline,
                "layers": layer_names
            }
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error extracting board data: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

def main():
    """Run the HTTP bridge server"""
    logger.info("Starting Altium HTTP Bridge on port 8001...")
    uvicorn.run(app, host="0.0.0.0", port=8001, log_level="info")

if __name__ == "__main__":
    main()
