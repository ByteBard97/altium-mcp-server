"""
Test UliEngineering differential microstrip calculations
"""
from UliEngineering.Electronics.Microstrip import differential_microstrip_impedance

# Test with HDMI differential pair (100 Ohm target)
# Stackup: h=0.1mm, er=3.69, t=0.07mm (2oz)
# Typical values for 100 Ohm diff pair

# Try different widths and spacings
test_cases = [
    (0.15, 0.1),   # 0.15mm width, 0.1mm spacing
    (0.2, 0.15),   # 0.2mm width, 0.15mm spacing
    (0.1, 0.05),   # 0.1mm width, 0.05mm spacing
]

print("Testing UliEngineering differential_microstrip_impedance")
print("=" * 70)
print("Stackup: h=0.1mm, er=3.69 (FR408-HR), t=0.07mm (2oz copper)")
print()

for w, d in test_cases:
    result = differential_microstrip_impedance(
        w=w,      # trace width (mm)
        d=d,      # edge-to-edge spacing (mm)
        h=0.1,    # substrate height (mm)
        t=0.07,   # trace thickness (mm)
        e_r=3.69  # relative permittivity
    )

    print(f"Width: {w:.3f}mm ({w/0.0254:.2f} mils), Spacing: {d:.3f}mm ({d/0.0254:.2f} mils)")
    print(f"  Single-ended:  {result.single_ended_impedance:.2f} Ohms")
    print(f"  Differential:  {result.differential_impedance:.2f} Ohms")
    print(f"  Even-mode:     {result.even_mode_impedance:.2f} Ohms")
    print(f"  Odd-mode:      {result.odd_mode_impedance:.2f} Ohms")
    print()

print("=" * 70)
