#!/usr/bin/env python3
import re
import sys

def analyze_file(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    depth = 0
    max_depth = 0
    issues = []

    print(f"\n{'='*70}")
    print(f"Analyzing: {filename}")
    print(f"{'='*70}\n")

    for i, line in enumerate(lines, 1):
        # Remove comments
        clean = re.sub(r'//.*$', '', line)
        clean = re.sub(r'\{[^}]*\}', '', clean).lower()

        # Skip if line has "removed" comment
        if 'removed' in line.lower():
            continue

        # Check for begin
        if re.search(r'\bbegin\b', clean):
            depth += 1
            max_depth = max(max_depth, depth)
            if depth <= 5:  # Only show first 5 levels
                print(f"Line {i:3d}: {'  ' * (depth-1)}BEGIN (depth → {depth})  {line.strip()[:50]}")

        # Check for end (not end.)
        if re.search(r'\bend[;\s]', clean) or clean.strip() == 'end':
            if depth > 0:
                print(f"Line {i:3d}: {'  ' * (depth-1)}END   (depth → {depth-1})")
                depth -= 1
            else:
                issues.append((i, line.strip()))
                print(f"Line {i:3d}: *** EXTRA END *** (depth was 0) - {line.strip()[:40]}")

    print(f"\n{'='*70}")
    print(f"Summary for {filename}")
    print(f"{'='*70}")
    print(f"Final depth: {depth} (should be 0)")
    print(f"Max depth reached: {max_depth}")

    if depth > 0:
        print(f"\n⚠️  Missing {depth} end statement(s)")
        print("Need to ADD ends")
    elif depth < 0:
        print(f"\n⚠️  Extra {-depth} end statement(s)")
        print("Need to REMOVE ends")
    else:
        print(f"\n✅ Perfect balance!")

    if issues:
        print(f"\nExtra end statements found at:")
        for line_num, line_text in issues:
            print(f"  Line {line_num}: {line_text}")

    return depth

# Analyze the 3 new files
for filename in ['component_placement.pas', 'library_utils.pas', 'project_utils.pas']:
    try:
        analyze_file(filename)
    except FileNotFoundError:
        print(f"File not found: {filename}")
    except Exception as e:
        print(f"Error analyzing {filename}: {e}")
