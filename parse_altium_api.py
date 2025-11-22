#!/usr/bin/env python3
"""
Parse Altium DelphiScript examples to build an API reference
"""
import re
import json
from pathlib import Path
from collections import defaultdict
from typing import Dict, List, Set

class AltiumAPIParser:
    def __init__(self, scripts_dir: str):
        self.scripts_dir = Path(scripts_dir)
        self.api_patterns = defaultdict(lambda: {
            'methods': defaultdict(set),  # object -> methods
            'properties': defaultdict(set),  # object -> properties
            'constants': set(),
            'examples': []
        })

        # Known Altium API objects (not UI forms)
        self.known_api_objects = {
            # Schematic
            'SCHServer', 'ISch_Sheet', 'ISch_Component', 'ISch_Pin', 'ISch_Iterator',
            'ISch_GraphicalObject', 'ISch_Port', 'ISch_Wire', 'ISch_Bus', 'ISch_Parameter',
            'ISch_Label', 'ISch_Designator', 'ISch_Implementation', 'ISch_Sheet',
            # PCB
            'PCBServer', 'IPCB_Board', 'IPCB_Component', 'IPCB_Track', 'IPCB_Via',
            'IPCB_Polygon', 'IPCB_Arc', 'IPCB_Text', 'IPCB_Pad', 'IPCB_Fill',
            'IPCB_Region', 'IPCB_Rule', 'IPCB_Net', 'IPCB_Primitive', 'IPCB_String',
            'IPCB_Dimension', 'IPCB_LayerStack', 'IPCB_LayerObject',
            # Generic
            'Board', 'Component', 'Pad', 'Via', 'Track', 'Net', 'Rule',
            # Libraries
            'SchLib', 'PCBLib', 'IntLib',
            # Workspace/Project
            'GetWorkspace', 'IProject', 'IDocument',
            # Design Manager
            'DesignManager',
        }

    def parse_all_scripts(self):
        """Parse all .pas files in the scripts directory"""
        pas_files = list(self.scripts_dir.rglob("*.pas"))
        print(f"Found {len(pas_files)} DelphiScript files")

        for pas_file in pas_files:
            try:
                self.parse_file(pas_file)
            except Exception as e:
                print(f"Error parsing {pas_file}: {e}")

    def parse_file(self, filepath: Path):
        """Parse a single .pas file for API patterns"""
        content = filepath.read_text(encoding='utf-8', errors='ignore')

        # Extract method calls: Object.Method(...)
        method_pattern = r'(\w+)\.(\w+)\s*\('
        for match in re.finditer(method_pattern, content):
            obj_type, method = match.groups()
            # Filter out common non-API patterns and focus on known API objects
            if obj_type not in ['Result', 'Self', 'inherited'] and self.is_likely_api_object(obj_type):
                self.api_patterns['all']['methods'][obj_type].add(method)

        # Extract property accesses: Object.Property (not followed by '(')
        property_pattern = r'(\w+)\.(\w+)(?!\s*\()'
        for match in re.finditer(property_pattern, content):
            obj_type, prop = match.groups()
            # Filter out method chaining and common non-API patterns
            if obj_type not in ['Result', 'Self', 'inherited'] and not prop.startswith('DM_') and self.is_likely_api_object(obj_type):
                self.api_patterns['all']['properties'][obj_type].add(prop)

        # Extract DM_ (Design Manager) properties
        dm_pattern = r'\.(\w*DM_\w+)'
        for match in re.finditer(dm_pattern, content):
            dm_prop = match.group(1)
            self.api_patterns['all']['properties']['DesignManager'].add(dm_prop)

        # Extract constants (MkSet, layer names, object types)
        const_patterns = [
            r'MkSet\(([^)]+)\)',
            r'\be\w+Layer\b',
            r'\be\w+Object\b',
        ]
        for pattern in const_patterns:
            for match in re.finditer(pattern, content):
                self.api_patterns['all']['constants'].add(match.group(0))

        # Store example usage with context
        if 'SCHServer' in content or 'PCBServer' in content:
            category = 'SCH' if 'SCHServer' in content else 'PCB'
            self.api_patterns[category]['examples'].append({
                'file': str(filepath.relative_to(self.scripts_dir)),
                'snippet': self.extract_interesting_snippet(content)
            })

    def is_likely_api_object(self, obj_name: str) -> bool:
        """Determine if an object name is likely an Altium API object (not a form/UI object)"""
        # Check if it's in our known list
        if obj_name in self.known_api_objects:
            return True

        # Check for common patterns
        if obj_name.startswith('IPCB_') or obj_name.startswith('ISch_'):
            return True

        # Filter out form objects
        if obj_name.startswith('TForm') or obj_name.startswith('T') and 'Form' in obj_name:
            return False

        # Common generic names
        if obj_name in ['Board', 'Component', 'Iterator', 'Net', 'Pad', 'Via', 'Track', 'Document', 'Project']:
            return True

        return False

    def extract_interesting_snippet(self, content: str, max_lines: int = 20) -> str:
        """Extract an interesting code snippet from the file"""
        lines = content.split('\n')
        # Look for main procedure/function
        for i, line in enumerate(lines):
            if 'procedure' in line.lower() or 'function' in line.lower():
                if 'begin' in ' '.join(lines[i:i+10]).lower():
                    # Found a procedure, grab some lines
                    return '\n'.join(lines[i:min(i+max_lines, len(lines))])
        return '\n'.join(lines[:max_lines])

    def generate_markdown_reference(self, output_file: str):
        """Generate a markdown API reference"""
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write("# Altium DelphiScript API Reference\n\n")
            f.write("*Extracted from community scripts in scripts-libraries*\n\n")
            f.write("---\n\n")

            # Group by major API categories
            sch_objects = ['SCHServer', 'ISch_Sheet', 'ISch_Component', 'ISch_Pin',
                          'ISch_Iterator', 'ISch_GraphicalObject']
            pcb_objects = ['PCBServer', 'IPCB_Board', 'IPCB_Component', 'IPCB_Track',
                          'IPCB_Via', 'IPCB_Polygon', 'IPCB_Arc', 'IPCB_Text']

            # Schematic API
            f.write("## Schematic API (SCH)\n\n")
            for obj in sch_objects:
                if obj in self.api_patterns['all']['methods'] or obj in self.api_patterns['all']['properties']:
                    f.write(f"### {obj}\n\n")

                    methods = sorted(self.api_patterns['all']['methods'].get(obj, []))
                    if methods:
                        f.write("**Methods:**\n")
                        for method in methods:
                            f.write(f"- `{method}()`\n")
                        f.write("\n")

                    props = sorted(self.api_patterns['all']['properties'].get(obj, []))
                    if props:
                        f.write("**Properties:**\n")
                        for prop in props:
                            f.write(f"- `{prop}`\n")
                        f.write("\n")

            # PCB API
            f.write("## PCB API\n\n")
            for obj in pcb_objects:
                if obj in self.api_patterns['all']['methods'] or obj in self.api_patterns['all']['properties']:
                    f.write(f"### {obj}\n\n")

                    methods = sorted(self.api_patterns['all']['methods'].get(obj, []))
                    if methods:
                        f.write("**Methods:**\n")
                        for method in methods:
                            f.write(f"- `{method}()`\n")
                        f.write("\n")

                    props = sorted(self.api_patterns['all']['properties'].get(obj, []))
                    if props:
                        f.write("**Properties:**\n")
                        for prop in props:
                            f.write(f"- `{prop}`\n")
                        f.write("\n")

            # Design Manager API
            f.write("## Design Manager API (DM_)\n\n")
            dm_props = sorted([p for p in self.api_patterns['all']['properties'].get('DesignManager', [])])
            if dm_props:
                f.write("**Properties:**\n")
                for prop in dm_props:
                    f.write(f"- `{prop}`\n")
                f.write("\n")

            # Constants
            f.write("## Constants & Enums\n\n")
            constants = sorted(self.api_patterns['all']['constants'])
            for const in constants[:50]:  # Limit to first 50
                f.write(f"- `{const}`\n")
            f.write("\n")

            # Examples
            f.write("## Example Scripts\n\n")
            for category in ['SCH', 'PCB']:
                if category in self.api_patterns and self.api_patterns[category]['examples']:
                    f.write(f"### {category} Examples\n\n")
                    for ex in self.api_patterns[category]['examples'][:5]:
                        f.write(f"**{ex['file']}:**\n")
                        f.write(f"```pascal\n{ex['snippet']}\n```\n\n")

    def generate_json_reference(self, output_file: str):
        """Generate a JSON API reference for programmatic use"""
        # Convert sets to lists for JSON serialization
        json_data = {}
        for category, data in self.api_patterns.items():
            json_data[category] = {
                'methods': {k: sorted(list(v)) for k, v in data['methods'].items()},
                'properties': {k: sorted(list(v)) for k, v in data['properties'].items()},
                'constants': sorted(list(data['constants'])),
                'examples': data['examples']
            }

        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(json_data, f, indent=2)

    def print_summary(self):
        """Print a summary of extracted API patterns"""
        total_objects = len(self.api_patterns['all']['methods'])
        total_methods = sum(len(methods) for methods in self.api_patterns['all']['methods'].values())
        total_properties = sum(len(props) for props in self.api_patterns['all']['properties'].values())

        print(f"\n=== API Extraction Summary ===")
        print(f"Unique object types: {total_objects}")
        print(f"Unique methods: {total_methods}")
        print(f"Unique properties: {total_properties}")
        print(f"Constants: {len(self.api_patterns['all']['constants'])}")

        print("\nTop 10 most-used objects:")
        method_counts = {obj: len(methods) for obj, methods in self.api_patterns['all']['methods'].items()}
        for obj, count in sorted(method_counts.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"  {obj}: {count} methods")

def main():
    scripts_dir = "scripts-libraries"

    parser = AltiumAPIParser(scripts_dir)
    print("Parsing DelphiScript files...")
    parser.parse_all_scripts()

    print("\nGenerating references...")
    parser.generate_markdown_reference("ALTIUM_API_REFERENCE.md")
    parser.generate_json_reference("altium_api_reference.json")

    parser.print_summary()

    print("\nGenerated:")
    print("  - ALTIUM_API_REFERENCE.md (human-readable)")
    print("  - altium_api_reference.json (machine-readable)")

if __name__ == "__main__":
    main()