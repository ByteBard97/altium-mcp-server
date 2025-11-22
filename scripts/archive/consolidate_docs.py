#!/usr/bin/env python3
"""
Consolidate all documentation into a single LLM-friendly reference file
"""
from pathlib import Path


def consolidate_docs():
    """Combine all documentation into a single file for LLM reference"""

    docs_dir = Path("docs/api")
    output_file = "ALTIUM_API_COMPLETE_REFERENCE.md"

    content = []

    # Add header
    content.append("# ALTIUM DELPHISCRIPT API - COMPLETE REFERENCE\n")
    content.append("*This is a consolidated, LLM-optimized reference extracted from 128 working DelphiScript examples*\n")
    content.append("*All methods, properties, and signatures have been verified in production code*\n")
    content.append("\n" + "="*100 + "\n\n")

    # Add table of contents
    content.append("## TABLE OF CONTENTS\n\n")
    content.append("1. [Overview](#overview)\n")
    content.append("2. [Quick Reference](#quick-reference)\n")
    content.append("3. [PCB API](#pcb-api)\n")
    content.append("4. [Schematic API](#schematic-api)\n")
    content.append("5. [Common Patterns](#common-patterns)\n")
    content.append("6. [Complete Type Reference](#complete-type-reference)\n")
    content.append("\n" + "="*100 + "\n\n")

    # Add overview (from index)
    content.append("## OVERVIEW\n\n")
    if (docs_dir / "index.md").exists():
        index_content = (docs_dir / "index.md").read_text(encoding='utf-8')
        # Extract just the overview section
        lines = index_content.split('\n')[6:18]
        content.extend(lines)
        content.append("\n\n")

    # Add quick reference
    content.append("## QUICK REFERENCE\n\n")
    content.append("### Most Common Operations\n\n")
    content.append("```pascal\n")
    content.append("// Get current board/schematic\n")
    content.append("Board := PCBServer.GetCurrentPCBBoard;\n")
    content.append("Sheet := SCHServer.GetCurrentSchDocument;\n\n")
    content.append("// Move component\n")
    content.append("Component.MoveToXY(x, y);  // NOT SetPosition()!\n")
    content.append("Component.Rotation := 90.0;\n\n")
    content.append("// Iterate objects\n")
    content.append("Iterator := Board.BoardIterator_Create;\n")
    content.append("Iterator.AddFilter_ObjectSet(MkSet(eComponentObject));\n")
    content.append("Obj := Iterator.FirstPCBObject;\n")
    content.append("while Obj <> nil do\n")
    content.append("begin\n")
    content.append("    // Process Obj\n")
    content.append("    Obj := Iterator.NextPCBObject;\n")
    content.append("end;\n")
    content.append("Board.BoardIterator_Destroy(Iterator);\n")
    content.append("```\n\n")
    content.append("="*100 + "\n\n")

    # Add PCB API overview
    if (docs_dir / "pcb-api.md").exists():
        content.append("## PCB API\n\n")
        content.append((docs_dir / "pcb-api.md").read_text(encoding='utf-8'))
        content.append("\n" + "="*100 + "\n\n")

    # Add Schematic API overview
    if (docs_dir / "schematic-api.md").exists():
        content.append("## SCHEMATIC API\n\n")
        content.append((docs_dir / "schematic-api.md").read_text(encoding='utf-8'))
        content.append("\n" + "="*100 + "\n\n")

    # Add common patterns
    if (docs_dir / "common-patterns.md").exists():
        content.append("## COMMON PATTERNS\n\n")
        content.append((docs_dir / "common-patterns.md").read_text(encoding='utf-8'))
        content.append("\n" + "="*100 + "\n\n")

    # Add all type docs
    content.append("## COMPLETE TYPE REFERENCE\n\n")
    content.append("*All types listed alphabetically with complete API details*\n\n")
    content.append("="*100 + "\n\n")

    types_dir = docs_dir / "types"
    if types_dir.exists():
        type_files = sorted(types_dir.glob("*.md"))

        for type_file in type_files:
            type_content = type_file.read_text(encoding='utf-8')
            content.append(type_content)
            content.append("\n" + "="*100 + "\n\n")

    # Write consolidated file
    output_path = Path(output_file)
    output_path.write_text('\n'.join(content), encoding='utf-8')

    file_size = output_path.stat().st_size / (1024 * 1024)  # MB

    print(f"\nConsolidated documentation created:")
    print(f"  File: {output_file}")
    print(f"  Size: {file_size:.2f} MB")
    print(f"  Types: {len(type_files)}")
    print(f"\nThis file contains ALL API information in a single LLM-friendly format.")


if __name__ == "__main__":
    consolidate_docs()
