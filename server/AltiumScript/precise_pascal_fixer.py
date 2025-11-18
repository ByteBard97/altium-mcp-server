#!/usr/bin/env python3
"""
More precise Pascal fixer that tracks function/procedure boundaries
"""
import re
from pathlib import Path

def fix_pascal_file(filepath):
    """Fix Pascal file by tracking function boundaries"""

    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    print(f"\n{'='*70}")
    print(f"Analyzing: {filepath.name}")
    print(f"{'='*70}")

    # Track state
    in_function = False
    function_name = ""
    depth = 0
    function_start_line = 0
    issues = []

    for i, line in enumerate(lines, 1):
        clean = re.sub(r'//.*$', '', line)
        clean = re.sub(r'\{[^}]*\}', '', clean).lower().strip()

        # Detect function/procedure start
        match = re.match(r'(function|procedure)\s+(\w+)', clean)
        if match:
            in_function = True
            function_name = match.group(2)
            function_start_line = i
            depth = 0
            print(f"Line {i:3d}: Start {match.group(1)} '{function_name}'")

        # Track begins
        if re.search(r'\bbegin\b', clean):
            depth += 1

        # Track ends
        if re.search(r'\bend[;\s]', clean) or clean == 'end':
            depth -= 1

            # If we just closed a function (depth back to -1)
            if depth == -1 and in_function:
                print(f"Line {i:3d}: Close function '{function_name}' (depth {depth})")
                in_function = False
                depth = 0

        # Detect next function starting while previous not closed
        if in_function and i > function_start_line + 2:
            next_match = re.match(r'(function|procedure)\s+(\w+)', clean)
            if next_match:
                issues.append({
                    'line': i,
                    'type': 'missing_end',
                    'function': function_name,
                    'message': f"Function '{function_name}' (started line {function_start_line}) never closed before next function"
                })
                print(f">>> Issue: Function '{function_name}' not closed! Depth is {depth}")
                # Try to fix by adding end before next function
                in_function = False

    # Check if last function was closed
    if in_function:
        issues.append({
            'line': len(lines),
            'type': 'missing_end',
            'function': function_name,
            'message': f"Function '{function_name}' (started line {function_start_line}) never closed"
        })
        print(f">>> Issue: Last function '{function_name}' not closed!")

    print(f"\nIssues found: {len(issues)}")
    for issue in issues:
        print(f"  Line {issue['line']}: {issue['message']}")

    return issues

# Analyze the problematic files
for filename in ['library_utils.pas', 'project_utils.pas']:
    filepath = Path(filename)
    if filepath.exists():
        issues = fix_pascal_file(filepath)
    else:
        print(f"File not found: {filename}")
