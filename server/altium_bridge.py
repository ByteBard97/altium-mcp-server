"""
Altium Bridge - Manages communication with Altium DelphiScript
"""
import asyncio
import json
import subprocess
from pathlib import Path
from typing import Any, Dict, Optional
from dataclasses import dataclass
import logging
import glob
import re
import os

logger = logging.getLogger(__name__)

@dataclass
class ScriptResult:
    """Result from Altium script execution"""
    success: bool
    data: Any
    error: Optional[str] = None

    def to_json(self) -> str:
        """Convert result to JSON string"""
        return json.dumps({
            "success": self.success,
            "data": self.data,
            "error": self.error
        }, indent=2)


class AltiumConfig:
    """Configuration manager for Altium paths"""

    def __init__(self, config_file: Path):
        self.config_file = config_file
        self.altium_exe_path = ""
        self.script_path = ""
        self.load_config()

    def load_config(self):
        """Load configuration from file or create default if it doesn't exist"""
        if self.config_file.exists():
            try:
                with open(self.config_file, "r") as f:
                    config = json.load(f)
                    self.altium_exe_path = config.get("altium_exe_path", "")
                    self.script_path = config.get("script_path", "")
                logger.info(f"Loaded configuration from {self.config_file}")
            except Exception as e:
                logger.error(f"Error loading configuration: {e}")
                self._create_default_config()
        else:
            logger.info("No configuration file found, creating default")
            self._create_default_config()

    def _create_default_config(self):
        """Create a default configuration file with improved Altium executable discovery"""

        # Try to find Altium directories dynamically
        altium_base_path = r"C:\Program Files\Altium"
        altium_exe_path = None

        if os.path.exists(altium_base_path):
            # Find all directories that match the pattern AD*
            ad_dirs = glob.glob(os.path.join(altium_base_path, "AD*"))

            if ad_dirs:
                # Sort directories by version number (extract the number after "AD")
                def get_version_number(dir_path):
                    match = re.search(r"AD(\d+)", os.path.basename(dir_path))
                    if match:
                        return int(match.group(1))
                    return 0

                # Sort directories by version number (highest first)
                ad_dirs.sort(key=get_version_number, reverse=True)

                # Try each directory until we find one with X2.EXE
                for ad_dir in ad_dirs:
                    potential_exe = os.path.join(ad_dir, "X2.EXE")
                    if os.path.exists(potential_exe):
                        altium_exe_path = potential_exe
                        break

        # Set the found path (or empty string if nothing found)
        self.altium_exe_path = altium_exe_path if altium_exe_path else ""

        # Save the configuration
        self.save_config()

    def save_config(self):
        """Save configuration to file"""
        config = {
            "altium_exe_path": self.altium_exe_path,
            "script_path": self.script_path
        }

        try:
            with open(self.config_file, "w") as f:
                json.dump(config, f, indent=2)
            logger.info(f"Saved configuration to {self.config_file}")
        except Exception as e:
            logger.error(f"Error saving configuration: {e}")

    def verify_paths(self):
        """Verify that the paths in the configuration exist"""
        altium_exists = self.altium_exe_path and os.path.exists(self.altium_exe_path)
        script_exists = self.script_path and os.path.exists(self.script_path)

        if not altium_exists:
            logger.warning(f"Altium executable not found at: {self.altium_exe_path}")
        if not script_exists:
            logger.warning(f"Script file not found at: {self.script_path}")

        return altium_exists and script_exists


class AltiumBridge:
    """
    Bridge between FastMCP server and Altium DelphiScript.

    Handles async communication with Altium using file-based IPC
    (can be upgraded to named pipes or ZeroMQ later).
    """

    def __init__(self, mcp_dir: Path, default_script_path: Path):
        self.mcp_dir = mcp_dir
        self.request_path = mcp_dir / "request.json"
        self.response_path = mcp_dir / "response.json"
        self.config_path = mcp_dir / "config.json"

        # Ensure the MCP directory exists
        self.mcp_dir.mkdir(exist_ok=True)

        # Load configuration
        self.config = AltiumConfig(self.config_path)

        # Set default script path if not configured
        if not self.config.script_path:
            self.config.script_path = str(default_script_path)
            self.config.save_config()

        self._lock = asyncio.Lock()  # Ensure serial access

    async def initialize(self):
        """Initialize the bridge"""
        # Verify paths
        self.config.verify_paths()

        logger.info(f"Altium executable: {self.config.altium_exe_path}")
        logger.info(f"Script project: {self.config.script_path}")

    async def call_script(
        self,
        command: str,
        params: Dict[str, Any],
        timeout: float = 120.0
    ) -> ScriptResult:
        """
        Call an Altium DelphiScript command.

        Args:
            command: Command name
            params: Command parameters
            timeout: Timeout in seconds

        Returns:
            ScriptResult with command output
        """
        async with self._lock:  # Serialize calls
            try:
                # Clean up any existing response file
                if self.response_path.exists():
                    self.response_path.unlink()

                # Write request file with command and parameters
                request_data = {
                    "command": command,
                    **params  # Include parameters directly in the main JSON object
                }

                with open(self.request_path, 'w') as f:
                    json.dump(request_data, f, indent=2)

                logger.info(f"Wrote request file for command: {command}")

                # Run the Altium script
                success = await self._run_altium_script()
                if not success:
                    return ScriptResult(
                        success=False,
                        data=None,
                        error="Failed to run Altium script"
                    )

                # Wait for the response file with timeout
                logger.info(f"Waiting for response file to appear...")
                start_time = asyncio.get_event_loop().time()
                while not self.response_path.exists():
                    if asyncio.get_event_loop().time() - start_time > timeout:
                        return ScriptResult(
                            success=False,
                            data=None,
                            error=f"Script timeout after {timeout}s"
                        )
                    await asyncio.sleep(0.5)

                # Read the response file
                logger.info("Response file found, reading response")
                with open(self.response_path, "r") as f:
                    response_text = f.read()

                # Log the raw response for debugging
                logger.debug(f"Raw response (first 200 chars): {response_text[:200]}")

                # Parse the JSON response with detailed error handling
                try:
                    response = json.loads(response_text)
                    logger.info(f"Successfully parsed JSON response")
                except json.JSONDecodeError as e:
                    logger.error(f"Error parsing JSON response: {e}")
                    # Try to manually fix common JSON issues
                    logger.info("Attempting to fix JSON response...")
                    fixed_text = response_text

                    # Fix double-quoted JSON arrays
                    if '"[' in fixed_text and ']"' in fixed_text:
                        fixed_text = fixed_text.replace('"[', '[').replace(']"', ']')

                    # Handle escaped quotes in JSON strings
                    fixed_text = fixed_text.replace('\\"', '"')

                    try:
                        response = json.loads(fixed_text)
                        logger.info("Successfully parsed fixed JSON response")
                    except json.JSONDecodeError as e2:
                        logger.error(f"Still failed to parse JSON after fixes: {e2}")
                        return ScriptResult(
                            success=False,
                            data=None,
                            error=f"Invalid JSON response: {e}"
                        )

                # Parse result
                if response.get("success"):
                    return ScriptResult(
                        success=True,
                        data=response.get("result"),
                        error=None
                    )
                else:
                    return ScriptResult(
                        success=False,
                        data=None,
                        error=response.get("error", "Unknown error")
                    )

            except Exception as e:
                logger.error(f"Script execution failed: {e}")
                return ScriptResult(
                    success=False,
                    data=None,
                    error=str(e)
                )

    async def _run_altium_script(self) -> bool:
        """Run the Altium bridge script"""
        if not os.path.exists(self.config.altium_exe_path):
            logger.error(f"Altium executable not found at: {self.config.altium_exe_path}")
            return False

        if not os.path.exists(self.config.script_path):
            logger.error(f"Script file not found at: {self.config.script_path}")
            return False

        try:
            # Command format: "X2.EXE" -RScriptingSystem:RunScript(ProjectName="path\file.PrjScr"|ProcName="ModuleName>Run")
            command = f'"{self.config.altium_exe_path}" -RScriptingSystem:RunScript(ProjectName="{self.config.script_path}"^|ProcName="Altium_API>Run")'

            logger.info(f"Running command: {command}")

            # Start the process
            process = subprocess.Popen(command, shell=True)

            # Don't wait for completion - Altium will run the script and generate the response
            logger.info(f"Launched Altium with script, process ID: {process.pid}")
            return True

        except Exception as e:
            logger.error(f"Error launching Altium: {e}")
            return False

    async def cleanup(self):
        """Cleanup resources"""
        # Clean up temp files
        for path in [self.request_path, self.response_path]:
            if path.exists():
                try:
                    path.unlink()
                except Exception as e:
                    logger.warning(f"Failed to cleanup {path}: {e}")

    @property
    def status(self) -> str:
        """Get bridge status"""
        if self.config.altium_exe_path and os.path.exists(self.config.altium_exe_path):
            return "ready"
        return "not configured"
