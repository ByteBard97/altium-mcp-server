#!/usr/bin/env python3
"""
Extract built-in Delphi/Pascal standard library usage from scripts
"""
import re
from pathlib import Path
from collections import defaultdict
import json


class DelphiStdLibExtractor:
    """Extract standard Delphi library functions, types, and methods"""

    def __init__(self, scripts_dir: str):
        self.scripts_dir = Path(scripts_dir)

        # Known Delphi built-in functions (not Altium-specific)
        self.stdlib_functions = {
            # String functions
            'IntToStr', 'StrToInt', 'StrToFloat', 'FloatToStr', 'Format',
            'StringReplace', 'Trim', 'UpperCase', 'LowerCase', 'Pos',
            'Copy', 'Delete', 'Insert', 'Length', 'SetLength',
            # Conversion
            'StrToIntDef', 'StrToFloatDef', 'IntToHex', 'HexToInt',
            # Math
            'Round', 'Trunc', 'Ceil', 'Floor', 'Sqrt', 'Sqr', 'Abs',
            'Sin', 'Cos', 'Tan', 'ArcTan', 'DegToRad', 'RadToDeg',
            # Date/Time
            'Now', 'Date', 'Time', 'FormatDateTime', 'EncodeDate', 'DecodeDate',
            # UI
            'ShowMessage', 'MessageDlg',
            # File/Path
            'ExtractFileName', 'ExtractFilePath', 'ExtractFileExt',
            'ChangeFileExt', 'FileExists', 'DirectoryExists',
            'IncludeTrailingPathDelimiter', 'ExcludeTrailingPathDelimiter',
            # Other
            'VarToStr', 'VarIsNull', 'Assigned', 'FreeAndNil',
        }

        # Known Delphi built-in types
        self.stdlib_types = {
            # Collections
            'TStringList', 'TList', 'TObjectList', 'TInterfaceList',
            # Streams
            'TFileStream', 'TMemoryStream', 'TStringStream',
            # Other
            'TDateTime', 'TRect', 'TPoint', 'TColor',
        }

        self.extracted = {
            'functions': defaultdict(int),  # function -> count
            'types': defaultdict(lambda: {
                'usage_count': 0,
                'methods': defaultdict(int),
                'properties': set()
            }),
            'examples': defaultdict(list)
        }

    def extract_all(self):
        """Extract from all scripts"""
        pas_files = list(self.scripts_dir.rglob("*.pas"))
        print(f"Analyzing {len(pas_files)} files for Delphi stdlib usage...")

        for pas_file in pas_files:
            try:
                content = pas_file.read_text(encoding='utf-8', errors='ignore')
                self._extract_from_file(content, pas_file)
            except Exception as e:
                print(f"Error: {pas_file}: {e}")

    def _extract_from_file(self, content: str, filepath: Path):
        """Extract stdlib usage from one file"""
        lines = content.split('\n')

        # Extract function calls
        for func_name in self.stdlib_functions:
            pattern = rf'\b{func_name}\s*\('
            matches = list(re.finditer(pattern, content))
            if matches:
                self.extracted['functions'][func_name] += len(matches)

                # Get example
                if len(self.extracted['examples'][func_name]) < 3:
                    for match in matches[:1]:
                        # Find the line
                        line_idx = content[:match.start()].count('\n')
                        if line_idx < len(lines):
                            self.extracted['examples'][func_name].append({
                                'code': lines[line_idx].strip(),
                                'file': str(filepath.relative_to(self.scripts_dir))
                            })

        # Extract type usage and methods
        for type_name in self.stdlib_types:
            # Find type declarations
            type_pattern = rf'\b\w+\s*:\s*{type_name}\b'
            if re.search(type_pattern, content):
                self.extracted['types'][type_name]['usage_count'] += 1

            # Find method calls on this type
            method_pattern = rf'\b\w+\.(\w+)\s*(?:\(|;|:=)'
            for i, line in enumerate(lines):
                # Check if this line has a variable of this type
                if type_name in line or f': {type_name}' in line:
                    # Look for method calls
                    for match in re.finditer(r'\.(\w+)\s*\(', line):
                        method = match.group(1)
                        self.extracted['types'][type_name]['methods'][method] += 1

    def generate_documentation(self, output_file: str = "DELPHI_STDLIB_REFERENCE.md"):
        """Generate documentation for Delphi stdlib usage"""
        doc = []

        doc.append("# Delphi Standard Library Reference\n")
        doc.append("*Built-in Delphi/Pascal functions and types used in Altium scripts*\n")
        doc.append("*Extracted from actual usage in 128 working examples*\n\n")
        doc.append("="*80 + "\n\n")

        # Functions
        doc.append("## Built-in Functions\n\n")
        doc.append("Functions used in the scripts (sorted by frequency):\n\n")

        sorted_funcs = sorted(self.extracted['functions'].items(),
                            key=lambda x: x[1], reverse=True)

        for func_name, count in sorted_funcs:
            doc.append(f"### `{func_name}()`\n\n")
            doc.append(f"**Usage count:** {count} times\n\n")

            # Show examples
            if func_name in self.extracted['examples']:
                doc.append("**Examples:**\n\n")
                for ex in self.extracted['examples'][func_name][:2]:
                    doc.append(f"```pascal\n{ex['code']}\n```\n")
                    doc.append(f"*From: {ex['file']}*\n\n")

            doc.append("---\n\n")

        # Types
        doc.append("## Built-in Types\n\n")

        sorted_types = sorted(self.extracted['types'].items(),
                            key=lambda x: x[1]['usage_count'], reverse=True)

        for type_name, data in sorted_types:
            if data['usage_count'] > 0:
                doc.append(f"### {type_name}\n\n")
                doc.append(f"**Usage count:** {data['usage_count']} declarations\n\n")

                # Show methods
                if data['methods']:
                    doc.append("**Common methods:**\n\n")
                    sorted_methods = sorted(data['methods'].items(),
                                          key=lambda x: x[1], reverse=True)
                    for method, count in sorted_methods[:10]:
                        doc.append(f"- `{method}()` - used {count} times\n")
                    doc.append("\n")

                doc.append("---\n\n")

        # Write output
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write('\n'.join(doc))

        print(f"\nGenerated: {output_file}")

    def generate_json(self, output_file: str = "delphi_stdlib.json"):
        """Generate JSON output"""
        output = {
            'functions': dict(self.extracted['functions']),
            'types': {}
        }

        for type_name, data in self.extracted['types'].items():
            if data['usage_count'] > 0:
                output['types'][type_name] = {
                    'usage_count': data['usage_count'],
                    'methods': dict(data['methods']),
                    'properties': list(data['properties'])
                }

        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(output, f, indent=2)

        print(f"Generated: {output_file}")

    def print_summary(self):
        """Print summary"""
        total_funcs = len([f for f, c in self.extracted['functions'].items() if c > 0])
        total_types = len([t for t, d in self.extracted['types'].items() if d['usage_count'] > 0])

        print(f"\n=== Delphi Stdlib Extraction Summary ===")
        print(f"Built-in functions found: {total_funcs}")
        print(f"Built-in types found: {total_types}")

        print("\nMost used functions:")
        sorted_funcs = sorted(self.extracted['functions'].items(),
                            key=lambda x: x[1], reverse=True)
        for func, count in sorted_funcs[:10]:
            print(f"  {func:<25} {count} times")

        print("\nMost used types:")
        sorted_types = sorted(self.extracted['types'].items(),
                            key=lambda x: x[1]['usage_count'], reverse=True)
        for type_name, data in sorted_types[:10]:
            if data['usage_count'] > 0:
                print(f"  {type_name:<25} {data['usage_count']} declarations")


def main():
    scripts_dir = "scripts-libraries"

    extractor = DelphiStdLibExtractor(scripts_dir)
    print("Extracting Delphi standard library usage...")
    extractor.extract_all()

    print("\nGenerating documentation...")
    extractor.generate_documentation()
    extractor.generate_json()

    extractor.print_summary()


if __name__ == "__main__":
    main()
