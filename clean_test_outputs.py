#!/usr/bin/env python3
"""
Clean cached test output files before running tests
"""
from pathlib import Path

# List of test output files to clean
test_outputs = [
    "test_design_output.json",
    "test_schematic_index.txt",
    "test_page_dsl.txt",
    "test_context_dsl.txt",
]

def clean_test_outputs():
    """Delete all test output files"""
    deleted = []
    not_found = []

    for filename in test_outputs:
        filepath = Path(filename)
        if filepath.exists():
            filepath.unlink()
            deleted.append(filename)
        else:
            not_found.append(filename)

    if deleted:
        print(f"Deleted {len(deleted)} test output file(s):")
        for f in deleted:
            print(f"  - {f}")

    if not_found and not deleted:
        print("No test output files found (already clean)")

    print()

if __name__ == "__main__":
    clean_test_outputs()
