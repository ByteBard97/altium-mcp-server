#!/usr/bin/env python3
"""
Enhanced Altium API parser using AST-like analysis
This version uses more sophisticated parsing to extract API patterns
"""
import re
from pathlib import Path
from collections import defaultdict
from typing import Dict, List, Set, Tuple
import json


class DelphiASTParser:
    """Simple AST-like parser for DelphiScript"""

    def __init__(self):
        self.tokens = []
        self.pos = 0

    def tokenize(self, code: str) -> List[Tuple[str, str]]:
        """Basic tokenization of Delphi code"""
        # Token patterns
        patterns = [
            ('COMMENT', r'{[^}]*}|//[^\n]*|\(\*[^*]*\*\)'),
            ('STRING', r"'[^']*'"),
            ('NUMBER', r'\b\d+\.?\d*\b'),
            ('IDENTIFIER', r'\b[a-zA-Z_][a-zA-Z0-9_]*\b'),
            ('OPERATOR', r':=|<=|>=|<>|\.\.|\+|-|\*|/|=|<|>'),
            ('PUNCTUATION', r'[();,:\[\].]'),
            ('WHITESPACE', r'\s+'),
        ]

        combined_pattern = '|'.join(f'(?P<{name}>{pattern})' for name, pattern in patterns)
        tokens = []

        for match in re.finditer(combined_pattern, code):
            kind = match.lastgroup
            value = match.group()
            if kind != 'WHITESPACE' and kind != 'COMMENT':
                tokens.append((kind, value))

        return tokens

    def extract_method_calls(self, tokens: List[Tuple[str, str]]) -> List[Tuple[str, str]]:
        """Extract object.method() patterns from tokens"""
        calls = []
        i = 0
        while i < len(tokens) - 3:
            if (tokens[i][0] == 'IDENTIFIER' and
                tokens[i+1] == ('PUNCTUATION', '.') and
                tokens[i+2][0] == 'IDENTIFIER' and
                tokens[i+3] == ('PUNCTUATION', '(')):

                obj_name = tokens[i][1]
                method_name = tokens[i+2][1]
                calls.append((obj_name, method_name))
                i += 4
            else:
                i += 1
        return calls

    def extract_property_access(self, tokens: List[Tuple[str, str]]) -> List[Tuple[str, str]]:
        """Extract object.property patterns from tokens"""
        properties = []
        i = 0
        while i < len(tokens) - 2:
            if (tokens[i][0] == 'IDENTIFIER' and
                tokens[i+1] == ('PUNCTUATION', '.') and
                tokens[i+2][0] == 'IDENTIFIER' and
                (i+3 >= len(tokens) or tokens[i+3] != ('PUNCTUATION', '('))):

                obj_name = tokens[i][1]
                prop_name = tokens[i+2][1]
                properties.append((obj_name, prop_name))
                i += 3
            else:
                i += 1
        return properties

    def extract_type_declarations(self, code: str) -> Dict[str, str]:
        """Extract variable type declarations"""
        types = {}
        # Pattern: identifier : type;
        pattern = r'(\w+)\s*:\s*(\w+)\s*;'
        for match in re.finditer(pattern, code):
            var_name, var_type = match.groups()
            types[var_name] = var_type
        return types


class EnhancedAltiumAPIParser:
    """Enhanced API parser using AST-like analysis"""

    def __init__(self, scripts_dir: str):
        self.scripts_dir = Path(scripts_dir)
        self.ast_parser = DelphiASTParser()

        self.api_data = {
            'objects': defaultdict(lambda: {
                'methods': set(),
                'properties': set(),
                'type': None,
                'examples': []
            }),
            'constants': set(),
            'type_mappings': {},  # variable -> type
        }

        # Known API types
        self.api_types = {
            # Servers
            'PCBServer', 'SCHServer', 'SchServer',
            # PCB types
            'IPCB_Board', 'IPCB_Component', 'IPCB_Track', 'IPCB_Via',
            'IPCB_Pad', 'IPCB_Arc', 'IPCB_Text', 'IPCB_Polygon', 'IPCB_Region',
            'IPCB_Rule', 'IPCB_Net', 'IPCB_Primitive', 'IPCB_Fill',
            # Schematic types
            'ISch_Sheet', 'ISch_Component', 'ISch_Pin', 'ISch_Iterator',
            'ISch_Wire', 'ISch_Bus', 'ISch_Port', 'ISch_Parameter',
            # Generic types
            'IProject', 'IDocument', 'INet', 'INetItem', 'IWorkspace',
            # Common variable names (map to their types)
            'Board', 'Component', 'Track', 'Via', 'Pad', 'Iterator',
            'Project', 'Document', 'Net', 'Sheet',
        }

    def parse_all_scripts(self):
        """Parse all DelphiScript files"""
        pas_files = list(self.scripts_dir.rglob("*.pas"))
        print(f"Found {len(pas_files)} DelphiScript files")

        for pas_file in pas_files:
            try:
                self.parse_file(pas_file)
            except Exception as e:
                print(f"Error parsing {pas_file}: {e}")

    def parse_file(self, filepath: Path):
        """Parse a single file using AST-like analysis"""
        code = filepath.read_text(encoding='utf-8', errors='ignore')

        # Tokenize
        tokens = self.ast_parser.tokenize(code)

        # Extract type declarations
        type_decls = self.ast_parser.extract_type_declarations(code)
        self.api_data['type_mappings'].update(type_decls)

        # Extract method calls
        method_calls = self.ast_parser.extract_method_calls(tokens)
        for obj_name, method_name in method_calls:
            # Resolve type if it's a variable
            obj_type = type_decls.get(obj_name, obj_name)

            if self.is_api_type(obj_type):
                self.api_data['objects'][obj_type]['methods'].add(method_name)

        # Extract property accesses
        property_accesses = self.ast_parser.extract_property_access(tokens)
        for obj_name, prop_name in property_accesses:
            # Resolve type if it's a variable
            obj_type = type_decls.get(obj_name, obj_name)

            if self.is_api_type(obj_type) and not prop_name.startswith('DM_'):
                self.api_data['objects'][obj_type]['properties'].add(prop_name)

        # Extract constants
        for token_type, token_value in tokens:
            if token_value.startswith('e') and token_value.endswith('Object'):
                self.api_data['constants'].add(token_value)
            elif token_value.startswith('e') and token_value.endswith('Layer'):
                self.api_data['constants'].add(token_value)

    def is_api_type(self, type_name: str) -> bool:
        """Check if a type is an Altium API type"""
        if type_name in self.api_types:
            return True
        if type_name.startswith('IPCB_') or type_name.startswith('ISch_'):
            return True
        if type_name.startswith('PCBServer') or type_name.startswith('SCHServer'):
            return True
        if type_name in ['Board', 'Component', 'Iterator', 'Project', 'Document', 'Net', 'Sheet']:
            return True
        return False

    def generate_json_output(self, output_file: str):
        """Generate JSON output"""
        output = {
            'objects': {},
            'constants': sorted(list(self.api_data['constants']))
        }

        for obj_type, data in self.api_data['objects'].items():
            output['objects'][obj_type] = {
                'methods': sorted(list(data['methods'])),
                'properties': sorted(list(data['properties']))
            }

        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(output, f, indent=2)

    def print_summary(self):
        """Print parsing summary"""
        total_objects = len(self.api_data['objects'])
        total_methods = sum(len(data['methods']) for data in self.api_data['objects'].values())
        total_props = sum(len(data['properties']) for data in self.api_data['objects'].values())

        print(f"\n=== Enhanced Parser Summary ===")
        print(f"API object types: {total_objects}")
        print(f"Total methods: {total_methods}")
        print(f"Total properties: {total_props}")
        print(f"Constants: {len(self.api_data['constants'])}")

        print("\nTop API objects:")
        sorted_objects = sorted(
            self.api_data['objects'].items(),
            key=lambda x: len(x[1]['methods']) + len(x[1]['properties']),
            reverse=True
        )
        for obj_type, data in sorted_objects[:10]:
            m_count = len(data['methods'])
            p_count = len(data['properties'])
            print(f"  {obj_type}: {m_count} methods, {p_count} properties")


def main():
    scripts_dir = "scripts-libraries"

    parser = EnhancedAltiumAPIParser(scripts_dir)
    print("Parsing DelphiScript files with enhanced AST parser...")
    parser.parse_all_scripts()

    print("\nGenerating output...")
    parser.generate_json_output("altium_api_enhanced.json")
    parser.print_summary()

    print("\nGenerated: altium_api_enhanced.json")


if __name__ == "__main__":
    main()
