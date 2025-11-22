#!/usr/bin/env python
"""
Test script to extract PCB stackup from KiCad using pcbnew API
Run with KiCad's embedded Python:
    "C:/Program Files/KiCad/9.0/bin/python.exe" test_kicad_stackup.py
"""
import pcbnew
import sys

# Load the KiCad PCB file
pcb_file = r"C:\Users\geoff\Desktop\projects\kicad-astro-daughterboard2\Astro-DB_rev00005\Astro-DB_rev00005.kicad_pcb"

print(f"Loading PCB: {pcb_file}")
board = pcbnew.LoadBoard(pcb_file)

if not board:
    print("ERROR: Failed to load board")
    sys.exit(1)

print(f"Board loaded: {board.GetFileName()}")

# Get the stackup
stackup = board.GetStackupOrDefault()
print(f"\nStackup type: {type(stackup)}")
print(f"Stackup methods: {[x for x in dir(stackup) if not x.startswith('_')][:20]}")

# Explore BOARD_STACKUP object
print(f"\nAll stackup attributes:")
all_attrs = [x for x in dir(stackup) if not x.startswith('_')]
for attr in all_attrs:
    print(f"  {attr}")

# Check design settings
design_settings = board.GetDesignSettings()
print(f"\nDesign settings type: {type(design_settings)}")
print(f"Design settings methods: {[x for x in dir(design_settings) if 'stack' in x.lower()]}")

# Try getting stackup from design settings
if hasattr(design_settings, 'GetStackupDescriptor'):
    desc = design_settings.GetStackupDescriptor()
    print(f"\nStackup descriptor: {desc}")
    print(f"Descriptor methods: {[x for x in dir(desc) if not x.startswith('_')][:30]}")

print("\n✅ Stackup extraction complete!")
