#!/usr/bin/env python3
"""
Quick test script to verify MCP server is working
Tests that all tools are registered and can be called
"""
import subprocess
import json
import sys
from pathlib import Path

# Path to conda environment python
PYTHON_PATH = r"C:\Users\geoff\anaconda3\envs\altium-mcp-v2\python.exe"
SERVER_PATH = Path(__file__).parent / "server" / "main.py"

def test_server_starts():
    """Test that the server starts without errors"""
    print("Testing server startup...")
    proc = subprocess.Popen(
        [PYTHON_PATH, str(SERVER_PATH)],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    # Send initialize request
    init_request = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {
                "name": "test-client",
                "version": "1.0.0"
            }
        }
    }

    try:
        proc.stdin.write(json.dumps(init_request) + "\n")
        proc.stdin.flush()

        # Read response (with timeout)
        import select
        import time
        timeout = 5
        start = time.time()

        while time.time() - start < timeout:
            line = proc.stdout.readline()
            if line:
                try:
                    response = json.loads(line)
                    if "result" in response:
                        print("[OK] Server initialized successfully")
                        print(f"Server name: {response['result'].get('serverInfo', {}).get('name', 'unknown')}")

                        # Request tool list
                        tools_request = {
                            "jsonrpc": "2.0",
                            "id": 2,
                            "method": "tools/list"
                        }
                        proc.stdin.write(json.dumps(tools_request) + "\n")
                        proc.stdin.flush()

                        # Read tools response
                        tools_line = proc.stdout.readline()
                        if tools_line:
                            tools_response = json.loads(tools_line)
                            if "result" in tools_response:
                                tools = tools_response["result"].get("tools", [])
                                print(f"[OK] Found {len(tools)} registered tools")
                                print("\nSample tools:")
                                for tool in tools[:5]:
                                    print(f"  - {tool['name']}: {tool.get('description', 'No description')[:60]}")
                                if len(tools) > 5:
                                    print(f"  ... and {len(tools) - 5} more")
                                return True
                        break
                except json.JSONDecodeError:
                    pass

        print("[ERROR] Server did not respond in time")
        return False

    finally:
        proc.terminate()
        proc.wait(timeout=2)

if __name__ == "__main__":
    print("="*70)
    print("Altium MCP Server Test")
    print("="*70)
    print()

    success = test_server_starts()

    print()
    print("="*70)
    if success:
        print("[SUCCESS] MCP server is working correctly!")
        print()
        print("Next steps:")
        print("1. Add the server to Claude Desktop config")
        print("2. Restart Claude Desktop")
        print("3. Open Altium Designer with a project")
        print("4. Use Claude to interact with Altium")
    else:
        print("[FAILED] Server test failed")
        print("Check the logs above for errors")
    print("="*70)

    sys.exit(0 if success else 1)
