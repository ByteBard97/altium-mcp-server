#!/usr/bin/env python3
"""
Test script for distributor integration
Checks if everything is properly installed and configured
"""

import sys
from pathlib import Path

# Add server directory to path
server_dir = Path(__file__).parent / "server"
sys.path.insert(0, str(server_dir))

def test_imports():
    """Test if all required modules can be imported"""
    print("Testing imports...")
    try:
        from distributor_config import DistributorConfig, is_nexar_configured
        print("[OK] distributor_config imported successfully")
    except ImportError as e:
        print(f"[FAIL] Failed to import distributor_config: {e}")
        return False

    try:
        from nexar_client import NexarClient
        print("[OK] nexar_client imported successfully")
    except ImportError as e:
        print(f"[FAIL] Failed to import nexar_client: {e}")
        return False

    try:
        from tools.distributor_tools import register_distributor_tools
        print("[OK] distributor_tools imported successfully")
    except ImportError as e:
        print(f"[FAIL] Failed to import distributor_tools: {e}")
        return False

    return True

def test_configuration():
    """Test configuration status"""
    print("\nTesting configuration...")
    from distributor_config import config, is_nexar_configured

    status = config.validate_configuration()
    print(f"\nConfiguration Status:")
    print(f"  Nexar configured: {status['nexar']['configured']}")
    print(f"  DigiKey configured: {status['digikey']['configured']}")
    print(f"  .env file exists: {status['env_file_exists']}")

    if not status['nexar']['configured']:
        print("\n[WARNING] Nexar API not configured")
        print("   To configure:")
        print("   1. Copy server/.env.example to server/.env")
        print("   2. Get API keys at https://nexar.com/api")
        print("   3. Add your credentials to server/.env")
    else:
        print("\n[OK] Nexar API is configured!")

    return status

def test_tools_registration():
    """Test if tools can be registered"""
    print("\nTesting tools registration...")
    try:
        # We can't actually register without a FastMCP instance,
        # but we can check if the function exists and is callable
        from tools.distributor_tools import register_distributor_tools
        print("[OK] register_distributor_tools function is available")
        return True
    except Exception as e:
        print(f"[FAIL] Error with distributor_tools: {e}")
        return False

if __name__ == "__main__":
    print("=" * 60)
    print("Distributor Integration Test Suite")
    print("=" * 60)

    # Test imports
    if not test_imports():
        print("\n[FAIL] Import test failed")
        sys.exit(1)

    # Test configuration
    config_status = test_configuration()

    # Test tools
    if not test_tools_registration():
        print("\n[FAIL] Tools registration test failed")
        sys.exit(1)

    print("\n" + "=" * 60)
    if config_status['nexar']['configured']:
        print("[OK] All tests passed! Distributor integration is ready.")
    else:
        print("[WARNING] Installation OK, but API keys not configured yet.")
    print("=" * 60)
