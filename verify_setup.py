#!/usr/bin/env python3
"""
Verify Altium MCP setup - checks if everything is configured correctly
"""
import os
import json
import glob
from pathlib import Path

def main():
    print("\n" + "="*60)
    print("ALTIUM MCP SETUP VERIFICATION")
    print("="*60)

    issues_found = []

    # Check 1: config.json exists
    print("\n[1/5] Checking config.json...")
    config_path = Path("server/config.json")
    if config_path.exists():
        print("  [OK] config.json exists")

        # Read config
        with open(config_path) as f:
            config = json.load(f)

        altium_exe = config.get("altium_exe_path", "")
        script_path = config.get("script_path", "")

        print(f"  Altium path: {altium_exe}")
        print(f"  Script path: {script_path}")
    else:
        print("  [ERROR] config.json not found")
        issues_found.append("config.json missing")
        return

    # Check 2: Altium executable exists
    print("\n[2/5] Checking Altium installation...")
    if os.path.exists(altium_exe):
        print(f"  [OK] Found Altium at: {altium_exe}")
    else:
        print(f"  [ERROR] Altium not found at: {altium_exe}")

        # Try to find Altium
        print("\n  Searching for Altium installations...")
        altium_base = r"C:\Program Files\Altium"
        if os.path.exists(altium_base):
            ad_dirs = glob.glob(os.path.join(altium_base, "AD*"))
            if ad_dirs:
                print(f"  Found {len(ad_dirs)} Altium installation(s):")
                for ad_dir in ad_dirs:
                    exe = os.path.join(ad_dir, "X2.EXE")
                    if os.path.exists(exe):
                        print(f"    [OK] {exe}")
                        print(f"\n  Update config.json to use: {exe}")
            else:
                print("  [ERROR] No Altium installations found")
        else:
            print(f"  [ERROR] {altium_base} directory not found")

        issues_found.append("Altium executable not found at configured path")

    # Check 3: DelphiScript project exists
    print("\n[3/5] Checking DelphiScript project...")
    if os.path.exists(script_path):
        print(f"  [OK] Script project found: {script_path}")
    else:
        print(f"  [ERROR] Script project not found: {script_path}")
        issues_found.append("DelphiScript project missing")

    # Check 4: DelphiScript files exist
    print("\n[4/5] Checking DelphiScript files...")
    required_files = [
        "server/AltiumScript/Altium_API.pas",
        "server/AltiumScript/Altium_API.PrjScr",
        "server/AltiumScript/pcb_utils.pas",
        "server/AltiumScript/schematic_utils.pas",
        "server/AltiumScript/other_utils.pas"
    ]

    all_exist = True
    for file in required_files:
        if os.path.exists(file):
            print(f"  [OK] {os.path.basename(file)}")
        else:
            print(f"  [ERROR] {os.path.basename(file)} missing")
            all_exist = False

    if not all_exist:
        issues_found.append("Some DelphiScript files missing")

    # Check 5: Python dependencies
    print("\n[5/5] Checking Python dependencies...")
    try:
        import mcp
        print(f"  [OK] mcp installed (version: {mcp.__version__ if hasattr(mcp, '__version__') else 'unknown'})")
    except ImportError:
        print("  [ERROR] mcp not installed")
        issues_found.append("mcp package not installed")

    try:
        import win32gui
        print("  [OK] pywin32 installed")
    except ImportError:
        print("  [ERROR] pywin32 not installed")
        issues_found.append("pywin32 package not installed")

    try:
        from PIL import Image
        print("  [OK] Pillow installed")
    except ImportError:
        print("  [ERROR] Pillow not installed")
        issues_found.append("Pillow package not installed")

    # Summary
    print("\n" + "="*60)
    print("SUMMARY")
    print("="*60)

    if not issues_found:
        print("\n[OK] ALL CHECKS PASSED!")
        print("\nYour setup is ready to use!")
        print("\nNext steps:")
        print("  1. Open Altium with a PCB project")
        print("  2. Run: python server/quick_test.py")
        print("  3. Or connect via Claude Desktop/Code")
    else:
        print(f"\n[ERROR] Found {len(issues_found)} issue(s):")
        for i, issue in enumerate(issues_found, 1):
            print(f"  {i}. {issue}")

        print("\nFixes:")
        if "Altium executable not found" in str(issues_found):
            print("\n  To fix Altium path:")
            print("  1. Find your Altium installation (usually C:\\Program Files\\Altium\\AD*)")
            print("  2. Edit server/config.json")
            print("  3. Update 'altium_exe_path' to point to X2.EXE")

        if any("not installed" in issue for issue in issues_found):
            print("\n  To install Python dependencies:")
            print("  conda activate altium-mcp-v2")
            print("  pip install mcp>=1.21.0 pywin32>=310 pillow>=11.1.0")

    print("\n" + "="*60)

if __name__ == "__main__":
    main()
