#!/usr/bin/env python3
"""
Validate DelphiScript code against the extracted Altium API
"""
import json
import re
import sys
from typing import List, Dict, Tuple


class DelphiScriptValidator:
    """Validate DelphiScript code against extracted API"""

    def __init__(self, api_file: str = "altium_api_enhanced.json"):
        with open(api_file, 'r') as f:
            self.api = json.load(f)

    def validate_code(self, code: str) -> Dict:
        """Validate DelphiScript code and return issues"""
        issues = {
            'errors': [],
            'warnings': [],
            'suggestions': []
        }

        # Extract method calls: Object.Method()
        method_pattern = r'(\w+)\.(\w+)\s*\('
        for match in re.finditer(method_pattern, code):
            obj_name, method_name = match.groups()

            # Try to find the type
            obj_type = self.infer_type(obj_name, code)

            if obj_type and obj_type in self.api['objects']:
                if method_name not in self.api['objects'][obj_type]['methods']:
                    # Check if it's a property being called as method
                    if method_name in self.api['objects'][obj_type]['properties']:
                        issues['errors'].append({
                            'line': match.group(0),
                            'issue': f"'{method_name}' is a property, not a method",
                            'object': obj_type
                        })
                    else:
                        # Suggest similar methods
                        similar = self.find_similar(
                            method_name,
                            self.api['objects'][obj_type]['methods']
                        )
                        issues['errors'].append({
                            'line': match.group(0),
                            'issue': f"Method '{method_name}' not found on {obj_type}",
                            'suggestions': similar
                        })

        # Extract property accesses: Object.Property (not followed by ()
        prop_pattern = r'(\w+)\.(\w+)(?!\s*\()'
        for match in re.finditer(prop_pattern, code):
            obj_name, prop_name = match.groups()

            obj_type = self.infer_type(obj_name, code)

            if obj_type and obj_type in self.api['objects']:
                if prop_name not in self.api['objects'][obj_type]['properties']:
                    # Check if it's a method being accessed as property
                    if prop_name in self.api['objects'][obj_type]['methods']:
                        issues['warnings'].append({
                            'line': match.group(0),
                            'issue': f"'{prop_name}' is a method, you may need to call it with ()"
                        })
                    else:
                        # Suggest similar properties
                        similar = self.find_similar(
                            prop_name,
                            self.api['objects'][obj_type]['properties']
                        )
                        if similar:
                            issues['warnings'].append({
                                'line': match.group(0),
                                'issue': f"Property '{prop_name}' not found on {obj_type}",
                                'suggestions': similar
                            })

        return issues

    def infer_type(self, var_name: str, code: str) -> str:
        """Try to infer the type of a variable from code"""
        # Look for type declaration: var_name : Type
        type_pattern = rf'\b{var_name}\s*:\s*(\w+)'
        match = re.search(type_pattern, code)
        if match:
            return match.group(1)

        # Look for assignment from known factory
        if var_name == 'Board':
            return 'IPCB_Board'
        elif var_name == 'Component':
            return 'IPCB_Component'
        elif var_name in ['SCHServer', 'PCBServer']:
            return var_name

        return None

    def find_similar(self, name: str, candidates: List[str], max_results: int = 3) -> List[str]:
        """Find similar names in candidates"""
        name_lower = name.lower()
        similar = []

        for candidate in candidates:
            candidate_lower = candidate.lower()

            # Check if one contains the other
            if name_lower in candidate_lower or candidate_lower in name_lower:
                similar.append(candidate)
            # Check for similar starting
            elif candidate_lower.startswith(name_lower[:3]) or name_lower.startswith(candidate_lower[:3]):
                similar.append(candidate)

        return similar[:max_results]

    def get_api_info(self, obj_type: str) -> Dict:
        """Get API information for a type"""
        if obj_type in self.api['objects']:
            return self.api['objects'][obj_type]
        return None

    def print_validation_results(self, issues: Dict):
        """Pretty print validation results"""
        if not issues['errors'] and not issues['warnings']:
            print("✓ No issues found!")
            return

        if issues['errors']:
            print(f"\n{'='*60}")
            print(f"ERRORS ({len(issues['errors'])})")
            print('='*60)
            for error in issues['errors']:
                print(f"\n  Code: {error['line']}")
                print(f"  Issue: {error['issue']}")
                if 'suggestions' in error and error['suggestions']:
                    print(f"  Did you mean: {', '.join(error['suggestions'])}")

        if issues['warnings']:
            print(f"\n{'='*60}")
            print(f"WARNINGS ({len(issues['warnings'])})")
            print('='*60)
            for warning in issues['warnings']:
                print(f"\n  Code: {warning['line']}")
                print(f"  Issue: {warning['issue']}")
                if 'suggestions' in warning and warning['suggestions']:
                    print(f"  Did you mean: {', '.join(warning['suggestions'])}")


def main():
    if len(sys.argv) < 2:
        print("Usage: python validate_delphiscript.py <file.pas>")
        print("   or: python validate_delphiscript.py --check '<code snippet>'")
        sys.exit(1)

    validator = DelphiScriptValidator()

    if sys.argv[1] == '--check':
        code = sys.argv[2]
    else:
        with open(sys.argv[1], 'r', encoding='utf-8') as f:
            code = f.read()

    print("Validating DelphiScript code...")
    issues = validator.validate_code(code)
    validator.print_validation_results(issues)


if __name__ == "__main__":
    # Test with some example code
    test_code = '''
    var
        Board : IPCB_Board;
        Component : IPCB_Component;
    begin
        Board := PCBServer.GetCurrentPCBBoard;
        Component.MoveToXY(100, 200);
        Component.SetPosition(10, 20);  // Wrong method!
        Board.CurrentLayer := eTopLayer;
    end;
    '''

    validator = DelphiScriptValidator()
    print("Testing validation with example code:\n")
    issues = validator.validate_code(test_code)
    validator.print_validation_results(issues)
