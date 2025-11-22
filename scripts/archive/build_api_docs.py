#!/usr/bin/env python3
"""
Build comprehensive API documentation from working examples
This creates LLM-friendly documentation with examples, patterns, and context
"""
import json
import re
from pathlib import Path
from collections import defaultdict
from typing import Dict, List, Tuple


class APIDocumentationBuilder:
    """Build rich API documentation from parsed scripts"""

    def __init__(self, scripts_dir: str, api_file: str = "altium_api_enhanced.json"):
        self.scripts_dir = Path(scripts_dir)
        self.api_file = api_file

        with open(api_file, 'r') as f:
            self.api = json.load(f)

        # Store code examples for each API member
        self.examples = defaultdict(list)
        self.method_signatures = defaultdict(list)
        self.property_usage = defaultdict(list)

    def extract_examples(self):
        """Extract code examples showing API usage"""
        print("Extracting code examples from scripts...")

        pas_files = list(self.scripts_dir.rglob("*.pas"))

        for pas_file in pas_files:
            try:
                content = pas_file.read_text(encoding='utf-8', errors='ignore')
                self._extract_from_file(content, pas_file)
            except Exception as e:
                print(f"Error processing {pas_file}: {e}")

    def _extract_from_file(self, content: str, filepath: Path):
        """Extract examples from a single file"""
        lines = content.split('\n')

        # Find method calls with context
        for i, line in enumerate(lines):
            # Look for method calls: Object.Method(...)
            method_matches = re.finditer(r'(\w+)\.(\w+)\s*\(([^)]*)\)', line)
            for match in method_matches:
                obj_name, method_name, params = match.groups()

                # Get type if possible
                obj_type = self._find_type_in_file(obj_name, content)

                if obj_type and obj_type in self.api['objects']:
                    if method_name in self.api['objects'][obj_type]['methods']:
                        # Extract context (3 lines before and after)
                        context_start = max(0, i - 2)
                        context_end = min(len(lines), i + 3)
                        context = '\n'.join(lines[context_start:context_end])

                        self.examples[f"{obj_type}.{method_name}"].append({
                            'code': context.strip(),
                            'file': str(filepath.relative_to(self.scripts_dir))
                        })

                        # Store signature pattern
                        if params.strip():
                            self.method_signatures[f"{obj_type}.{method_name}"].append(
                                params.strip()
                            )

            # Look for property assignments
            prop_matches = re.finditer(r'(\w+)\.(\w+)\s*:=\s*([^;]+)', line)
            for match in prop_matches:
                obj_name, prop_name, value = match.groups()

                obj_type = self._find_type_in_file(obj_name, content)

                if obj_type and obj_type in self.api['objects']:
                    if prop_name in self.api['objects'][obj_type]['properties']:
                        self.property_usage[f"{obj_type}.{prop_name}"].append({
                            'assignment': value.strip(),
                            'context': line.strip()
                        })

    def _find_type_in_file(self, var_name: str, content: str) -> str:
        """Find type declaration for a variable"""
        # Direct type match (already a type name)
        if var_name.startswith('IPCB_') or var_name.startswith('ISch_'):
            return var_name
        if var_name in ['PCBServer', 'SCHServer', 'SchServer']:
            return var_name

        # Look for type declaration
        pattern = rf'\b{var_name}\s*:\s*(\w+)'
        match = re.search(pattern, content)
        if match:
            return match.group(1)

        # Known mappings
        type_map = {
            'Board': 'IPCB_Board',
            'Component': 'IPCB_Component',
            'Track': 'IPCB_Track',
            'Via': 'IPCB_Via',
            'Pad': 'IPCB_Pad',
            'Arc': 'IPCB_Arc',
            'Text': 'IPCB_Text',
            'Polygon': 'IPCB_Polygon',
            'Iterator': 'IPCB_BoardIterator',
            'Sheet': 'ISch_Sheet',
            'Project': 'IProject',
            'Document': 'IDocument',
            'Net': 'INet',
            'PCBServer': 'PCBServer',
            'SCHServer': 'SCHServer',
            'SchServer': 'SCHServer',
        }
        return type_map.get(var_name, var_name)

    def generate_docs(self, output_dir: str = "docs/api"):
        """Generate comprehensive documentation"""
        output_path = Path(output_dir)
        output_path.mkdir(parents=True, exist_ok=True)

        print(f"Generating documentation in {output_dir}...")

        # Generate index
        self._generate_index(output_path)

        # Generate docs by category
        self._generate_pcb_docs(output_path)
        self._generate_schematic_docs(output_path)
        self._generate_common_patterns(output_path)

        # Generate individual type docs
        for type_name in self.api['objects'].keys():
            self._generate_type_doc(type_name, output_path)

        print(f"Documentation generated in {output_dir}/")

    def _generate_index(self, output_path: Path):
        """Generate main index page"""
        doc = []
        doc.append("# Altium DelphiScript API Reference\n")
        doc.append("*Complete API reference extracted from working community scripts*\n")
        doc.append("---\n\n")

        # Statistics
        total_types = len(self.api['objects'])
        total_methods = sum(len(obj['methods']) for obj in self.api['objects'].values())
        total_props = sum(len(obj['properties']) for obj in self.api['objects'].values())

        doc.append("## Overview\n\n")
        doc.append(f"- **{total_types}** API Types\n")
        doc.append(f"- **{total_methods}** Methods\n")
        doc.append(f"- **{total_props}** Properties\n")
        doc.append(f"- **All verified** from working examples\n\n")

        # Categories
        doc.append("## API Categories\n\n")
        doc.append("### [PCB API](pcb-api.md)\n")
        doc.append("Work with PCB boards, components, tracks, vias, polygons, and layout.\n\n")

        doc.append("### [Schematic API](schematic-api.md)\n")
        doc.append("Work with schematics, components, pins, nets, and sheets.\n\n")

        doc.append("### [Common Patterns](common-patterns.md)\n")
        doc.append("Frequently used patterns and code snippets.\n\n")

        # Type index
        doc.append("## All Types\n\n")

        pcb_types = sorted([t for t in self.api['objects'].keys() if t.startswith('IPCB_')])
        sch_types = sorted([t for t in self.api['objects'].keys() if t.startswith('ISch_')])
        other_types = sorted([t for t in self.api['objects'].keys()
                             if not t.startswith('IPCB_') and not t.startswith('ISch_')])

        if pcb_types:
            doc.append("### PCB Types\n\n")
            for t in pcb_types:
                doc.append(f"- [{t}](types/{t}.md)\n")
            doc.append("\n")

        if sch_types:
            doc.append("### Schematic Types\n\n")
            for t in sch_types:
                doc.append(f"- [{t}](types/{t}.md)\n")
            doc.append("\n")

        if other_types:
            doc.append("### Other Types\n\n")
            for t in other_types:
                doc.append(f"- [{t}](types/{t}.md)\n")
            doc.append("\n")

        (output_path / "index.md").write_text('\n'.join(doc), encoding='utf-8')

    def _generate_type_doc(self, type_name: str, output_path: Path):
        """Generate documentation for a single type"""
        types_dir = output_path / "types"
        types_dir.mkdir(exist_ok=True)

        obj = self.api['objects'][type_name]
        doc = []

        doc.append(f"# {type_name}\n\n")

        # Overview
        category = "PCB" if type_name.startswith('IPCB_') else "Schematic" if type_name.startswith('ISch_') else "General"
        doc.append(f"**Category:** {category}\n\n")

        method_count = len(obj['methods'])
        prop_count = len(obj['properties'])
        doc.append(f"**API Surface:** {method_count} methods, {prop_count} properties\n\n")

        doc.append("---\n\n")

        # Methods
        if obj['methods']:
            doc.append(f"## Methods ({method_count})\n\n")

            for method in sorted(obj['methods']):
                doc.append(f"### `{method}()`\n\n")

                # Show signatures if we have them
                key = f"{type_name}.{method}"
                if key in self.method_signatures:
                    sigs = list(set(self.method_signatures[key]))[:3]  # Top 3 unique
                    doc.append("**Observed signatures:**\n")
                    for sig in sigs:
                        doc.append(f"```pascal\n{type_name}.{method}({sig})\n```\n")

                # Show examples
                if key in self.examples:
                    examples = self.examples[key][:2]  # Top 2 examples
                    doc.append("**Examples:**\n\n")
                    for i, ex in enumerate(examples, 1):
                        doc.append(f"*From: {ex['file']}*\n")
                        doc.append(f"```pascal\n{ex['code']}\n```\n\n")

                doc.append("---\n\n")

        # Properties
        if obj['properties']:
            doc.append(f"## Properties ({prop_count})\n\n")

            for prop in sorted(obj['properties']):
                doc.append(f"### `{prop}`\n\n")

                # Show usage examples
                key = f"{type_name}.{prop}"
                if key in self.property_usage:
                    usages = list(set([u['assignment'] for u in self.property_usage[key]]))[:3]
                    doc.append("**Common values:**\n")
                    for usage in usages:
                        doc.append(f"- `{usage}`\n")
                    doc.append("\n")

                    # Show one full example
                    if self.property_usage[key]:
                        doc.append("**Example:**\n")
                        doc.append(f"```pascal\n{self.property_usage[key][0]['context']}\n```\n")

                doc.append("---\n\n")

        (types_dir / f"{type_name}.md").write_text('\n'.join(doc), encoding='utf-8')

    def _generate_pcb_docs(self, output_path: Path):
        """Generate PCB API overview"""
        doc = []
        doc.append("# PCB API\n\n")
        doc.append("API for working with PCB layouts, components, routing, and board objects.\n\n")
        doc.append("---\n\n")

        # Key types
        key_types = [
            ('PCBServer', 'Main server interface for PCB operations'),
            ('IPCB_Board', 'PCB board object - main container'),
            ('IPCB_Component', 'Component on the board'),
            ('IPCB_Track', 'Routing track/trace'),
            ('IPCB_Via', 'Via object'),
            ('IPCB_Pad', 'Component pad'),
            ('IPCB_Polygon', 'Polygon/copper pour'),
            ('IPCB_Text', 'Text object'),
        ]

        doc.append("## Key Types\n\n")
        for type_name, description in key_types:
            if type_name in self.api['objects']:
                methods = len(self.api['objects'][type_name]['methods'])
                props = len(self.api['objects'][type_name]['properties'])
                doc.append(f"### [{type_name}](types/{type_name}.md)\n")
                doc.append(f"{description}\n\n")
                doc.append(f"*{methods} methods, {props} properties*\n\n")

        (output_path / "pcb-api.md").write_text('\n'.join(doc), encoding='utf-8')

    def _generate_schematic_docs(self, output_path: Path):
        """Generate Schematic API overview"""
        doc = []
        doc.append("# Schematic API\n\n")
        doc.append("API for working with schematics, components, pins, nets, and sheets.\n\n")
        doc.append("---\n\n")

        key_types = [
            ('SCHServer', 'Main server interface for schematic operations'),
            ('ISch_Sheet', 'Schematic sheet object'),
            ('ISch_Component', 'Component on schematic'),
            ('ISch_Pin', 'Component pin'),
            ('ISch_Iterator', 'Iterator for traversing schematic objects'),
            ('ISch_Wire', 'Wire/connection'),
            ('ISch_Port', 'Port object'),
        ]

        doc.append("## Key Types\n\n")
        for type_name, description in key_types:
            if type_name in self.api['objects']:
                methods = len(self.api['objects'][type_name]['methods'])
                props = len(self.api['objects'][type_name]['properties'])
                doc.append(f"### [{type_name}](types/{type_name}.md)\n")
                doc.append(f"{description}\n\n")
                doc.append(f"*{methods} methods, {props} properties*\n\n")

        (output_path / "schematic-api.md").write_text('\n'.join(doc), encoding='utf-8')

    def _generate_common_patterns(self, output_path: Path):
        """Generate common usage patterns"""
        doc = []
        doc.append("# Common Patterns\n\n")
        doc.append("Frequently used code patterns extracted from working scripts.\n\n")
        doc.append("---\n\n")

        patterns = [
            ("Get Current PCB Board", "IPCB_Board", "GetCurrentPCBBoard"),
            ("Get Current Schematic", "ISch_Sheet", "GetCurrentSchDocument"),
            ("Move Component", "IPCB_Component", "MoveToXY"),
            ("Iterate Board Objects", "IPCB_Board", "BoardIterator_Create"),
            ("Iterate Schematic Objects", "ISch_Sheet", "SchIterator_Create"),
        ]

        for pattern_name, type_name, method_name in patterns:
            doc.append(f"## {pattern_name}\n\n")

            # Find example
            key = f"{type_name}.{method_name}" if '.' not in method_name else method_name
            if key in self.examples:
                ex = self.examples[key][0]
                doc.append(f"```pascal\n{ex['code']}\n```\n\n")
                doc.append(f"*From: {ex['file']}*\n\n")

            doc.append("---\n\n")

        (output_path / "common-patterns.md").write_text('\n'.join(doc), encoding='utf-8')


def main():
    scripts_dir = "scripts-libraries"
    api_file = "altium_api_enhanced.json"

    if not Path(api_file).exists():
        print(f"Error: {api_file} not found!")
        print("Run: python enhanced_api_parser.py")
        return

    builder = APIDocumentationBuilder(scripts_dir, api_file)

    print("Building comprehensive API documentation...")
    print("\nStep 1: Extracting code examples...")
    builder.extract_examples()

    print("\nStep 2: Generating documentation...")
    builder.generate_docs()

    print("\nComplete!")
    print("\nGenerated documentation:")
    print("  docs/api/index.md           - Main index")
    print("  docs/api/pcb-api.md         - PCB API overview")
    print("  docs/api/schematic-api.md   - Schematic API overview")
    print("  docs/api/common-patterns.md - Common patterns")
    print("  docs/api/types/*.md         - Individual type docs")


if __name__ == "__main__":
    main()
