#!/usr/bin/env python3
"""
Custom Pascal linter that shows exactly where syntax errors are
"""
import re
import sys
from pathlib import Path

def lint_pascal_file(filepath):
    """Lint a Pascal file and show specific error locations"""

    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    print(f"\n{'='*70}")
    print(f"LINTING: {filepath.name}")
    print(f"{'='*70}\n")

    depth = 0
    errors = []
    warnings = []
    in_function = False
    function_name = ""
    function_start = 0

    for i, line in enumerate(lines, 1):
        original = line.rstrip()
        clean = re.sub(r'//.*$', '', line)
        clean = re.sub(r'\{[^}]*\}', '', clean).lower().strip()

        # Skip removed comments
        if 'removed' in original.lower():
            continue

        # Detect function/procedure
        match = re.match(r'(function|procedure)\s+(\w+)', clean)
        if match:
            if in_function and depth > 0:
                errors.append({
                    'line': i,
                    'severity': 'ERROR',
                    'message': f"Previous {function_name} (line {function_start}) never closed before new function starts",
                    'code': original[:60]
                })
            in_function = True
            function_name = match.group(2)
            function_start = i
            depth = 0

        # Track begins
        if re.search(r'\bbegin\b', clean):
            depth += 1

        # Track ends
        if re.search(r'\bend[;\s]', clean) or clean == 'end':
            depth -= 1

            # Extra end detected
            if depth < 0:
                errors.append({
                    'line': i,
                    'severity': 'ERROR',
                    'message': f"Extra 'end' - no matching 'begin' (depth went negative)",
                    'code': original[:60]
                })
                print(f"Line {i:4d}: [ERROR] {original[:60]}")
                print(f"          -> Extra 'end' statement\n")
                depth = 0  # Reset to avoid cascading errors

            # Function closing
            elif depth == 0 and in_function:
                in_function = False

        # Check for unclosed function at next function
        if in_function and i > function_start + 5:
            next_match = re.match(r'(function|procedure)\s+(\w+)', clean)
            if next_match and depth > 0:
                errors.append({
                    'line': function_start,
                    'severity': 'ERROR',
                    'message': f"Function '{function_name}' missing closing 'end;' (depth is {depth})",
                    'code': f"Missing {depth} end statement(s)"
                })

    # Check for unclosed last function
    if in_function and depth > 0:
        errors.append({
            'line': len(lines),
            'severity': 'ERROR',
            'message': f"Function '{function_name}' (line {function_start}) missing closing 'end;' (depth is {depth})",
            'code': f"Add 'end;' at end of file"
        })
        print(f"Line {len(lines):4d}: [ERROR] END OF FILE")
        print(f"          -> Function '{function_name}' never closed")
        print(f"          -> Need to add {depth} more 'end;' statement(s)\n")

    # Count total begin/end
    total_begins = 0
    total_ends = 0
    for line in lines:
        clean = re.sub(r'//.*$', '', line)
        clean = re.sub(r'\{[^}]*\}', '', clean).lower()
        if 'removed' not in line.lower():
            if re.search(r'\bbegin\b', clean):
                total_begins += 1
            if re.search(r'\bend[;\s]', clean) or clean.strip() == 'end':
                total_ends += 1

    # Print summary
    print(f"{'='*70}")
    print(f"SUMMARY FOR {filepath.name}")
    print(f"{'='*70}")
    print(f"Total begins: {total_begins}")
    print(f"Total ends:   {total_ends}")
    print(f"Difference:   {total_ends - total_begins:+d}")

    if total_begins == total_ends:
        print(f"\n[OK] BALANCED - File should compile correctly")
        return True
    else:
        diff = total_ends - total_begins
        if diff > 0:
            print(f"\n[ERROR] TOO MANY ENDS - Remove {diff} 'end;' statement(s)")
        else:
            print(f"\n[ERROR] MISSING ENDS - Add {-diff} 'end;' statement(s)")

    # Print all errors
    if errors:
        print(f"\n{len(errors)} Error(s) Found:")
        for err in errors:
            print(f"\n  Line {err['line']:4d}: {err['message']}")
            if err['code']:
                print(f"             {err['code']}")

    return len(errors) == 0 and total_begins == total_ends

def main():
    """Lint the 3 new Pascal files"""
    files = ['component_placement.pas', 'library_utils.pas', 'project_utils.pas']

    all_ok = True
    for filename in files:
        filepath = Path(filename)
        if filepath.exists():
            ok = lint_pascal_file(filepath)
            if not ok:
                all_ok = False
        else:
            print(f"File not found: {filename}")

    print(f"\n{'='*70}")
    if all_ok:
        print("[SUCCESS] ALL FILES OK - Ready to compile in Altium")
    else:
        print("[ERROR] ERRORS FOUND - Fix the issues above before compiling")
    print(f"{'='*70}\n")

    return 0 if all_ok else 1

if __name__ == "__main__":
    sys.exit(main())
