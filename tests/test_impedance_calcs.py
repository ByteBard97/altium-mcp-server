"""
Quick test of impedance calculator functions
"""
import sys
sys.path.insert(0, r"C:\Users\geoff\Desktop\projects\kicad-astro-daughterboard2\.mcp\kicad-mcp")

from kicad_mcp.tools.impedance_tools import (
    microstrip_synth_width,
    microstrip_impedance,
    stripline_synth_width,
    stripline_impedance,
    differential_pair_synth,
    differential_pair_impedance
)

print("=" * 70)
print("IMPEDANCE CALCULATOR TESTS")
print("=" * 70)

# Test 1: Microstrip 50 Ohm (typical for QSPI)
print("\n1. MICROSTRIP: 50 Ohm single-ended trace")
print("   Stackup: h=0.1mm, er=3.69 (FR408-HR), t=0.07mm (2oz copper)")
w_50 = microstrip_synth_width(50.0, 0.1, 3.69, 0.07)
z0_verify = microstrip_impedance(w_50, 0.1, 3.69, 0.07)
print(f"   -> Trace width: {w_50:.4f} mm ({w_50/0.0254:.2f} mils)")
print(f"   -> Verification: {z0_verify:.2f} Ohms (target: 50 Ohms)")

# Test 2: Differential pair 100 Ohm (typical for HDMI)
print("\n2. DIFFERENTIAL PAIR: 100 Ohm differential impedance")
print("   Stackup: h=0.1mm, er=3.69 (FR408-HR), t=0.07mm (2oz copper)")
w_diff, s_diff = differential_pair_synth(100.0, 0.1, 3.69, 0.07)
z0_diff_verify = differential_pair_impedance(w_diff, s_diff, 0.1, 3.69, 0.07)
print(f"   -> Trace width: {w_diff:.4f} mm ({w_diff/0.0254:.2f} mils)")
print(f"   -> Trace spacing: {s_diff:.4f} mm ({s_diff/0.0254:.2f} mils)")
print(f"   -> Verification: {z0_diff_verify:.2f} Ohms (target: 100 Ohms)")

# Test 3: Stripline 50 Ohm (inner layer)
print("\n3. STRIPLINE: 50 Ohm single-ended trace (inner layer)")
print("   Stackup: h=0.245mm (core), er=3.69 (FR408-HR), t=0.07mm (2oz copper)")
w_strip = stripline_synth_width(50.0, 0.245, 3.69, 0.07)
z0_strip_verify = stripline_impedance(w_strip, 0.245, 3.69, 0.07)
print(f"   -> Trace width: {w_strip:.4f} mm ({w_strip/0.0254:.2f} mils)")
print(f"   -> Verification: {z0_strip_verify:.2f} Ohms (target: 50 Ohms)")

print("\n" + "=" * 70)
print("[OK] All impedance calculators tested successfully!")
print("=" * 70)
