#!/usr/bin/env python3
"""
Comprehensive CLI tool for working with Altium DelphiScript API
"""
import json
import sys
from pathlib import Path


class AltiumAPICLI:
    """Command-line interface for Altium API reference"""

    def __init__(self, api_file: str = "altium_api_enhanced.json"):
        self.api_file = Path(api_file)
        if not self.api_file.exists():
            print(f"Error: API file '{api_file}' not found!")
            print("Run: python enhanced_api_parser.py")
            sys.exit(1)

        with open(api_file, 'r') as f:
            self.api = json.load(f)

    def cmd_list_types(self, filter_prefix: str = None):
        """List all API types"""
        types = sorted(self.api['objects'].keys())

        if filter_prefix:
            types = [t for t in types if t.startswith(filter_prefix)]

        print(f"\nFound {len(types)} API types:")
        for t in types:
            method_count = len(self.api['objects'][t]['methods'])
            prop_count = len(self.api['objects'][t]['properties'])
            print(f"  {t:<30} {method_count} methods, {prop_count} properties")

    def cmd_show_type(self, type_name: str):
        """Show details for a specific type"""
        if type_name not in self.api['objects']:
            print(f"Type '{type_name}' not found!")
            # Suggest similar
            similar = [t for t in self.api['objects'].keys()
                      if type_name.lower() in t.lower()]
            if similar:
                print(f"Did you mean: {', '.join(similar[:5])}")
            return

        obj = self.api['objects'][type_name]

        print(f"\n{'='*70}")
        print(f"{type_name}")
        print('='*70)

        if obj['methods']:
            print(f"\nMethods ({len(obj['methods'])}):")
            for method in sorted(obj['methods']):
                print(f"  {type_name}.{method}(...);")

        if obj['properties']:
            print(f"\nProperties ({len(obj['properties'])}):")
            for prop in sorted(obj['properties']):
                print(f"  {type_name}.{prop}")

    def cmd_search(self, query: str):
        """Search for methods/properties matching query"""
        query_lower = query.lower()
        results = {
            'types': [],
            'methods': {},
            'properties': {}
        }

        # Search type names
        for type_name in self.api['objects'].keys():
            if query_lower in type_name.lower():
                results['types'].append(type_name)

        # Search methods and properties
        for type_name, obj in self.api['objects'].items():
            matching_methods = [m for m in obj['methods'] if query_lower in m.lower()]
            if matching_methods:
                results['methods'][type_name] = matching_methods

            matching_props = [p for p in obj['properties'] if query_lower in p.lower()]
            if matching_props:
                results['properties'][type_name] = matching_props

        # Print results
        total = len(results['types']) + len(results['methods']) + len(results['properties'])
        print(f"\nFound {total} matches for '{query}':")

        if results['types']:
            print(f"\nTypes ({len(results['types'])}):")
            for t in results['types']:
                print(f"  {t}")

        if results['methods']:
            print(f"\nMethods:")
            for type_name, methods in results['methods'].items():
                for method in methods:
                    print(f"  {type_name}.{method}()")

        if results['properties']:
            print(f"\nProperties:")
            for type_name, props in results['properties'].items():
                for prop in props:
                    print(f"  {type_name}.{prop}")

    def cmd_validate(self, code_or_file: str):
        """Validate DelphiScript code"""
        from validate_delphiscript import DelphiScriptValidator

        validator = DelphiScriptValidator(self.api_file)

        # Check if it's a file
        if Path(code_or_file).exists():
            with open(code_or_file, 'r', encoding='utf-8') as f:
                code = f.read()
        else:
            code = code_or_file

        issues = validator.validate_code(code)
        validator.print_validation_results(issues)

    def cmd_stats(self):
        """Show API statistics"""
        total_types = len(self.api['objects'])
        total_methods = sum(len(obj['methods']) for obj in self.api['objects'].values())
        total_props = sum(len(obj['properties']) for obj in self.api['objects'].values())
        total_constants = len(self.api['constants'])

        print("\n=== Altium API Statistics ===")
        print(f"Total API types:  {total_types}")
        print(f"Total methods:    {total_methods}")
        print(f"Total properties: {total_props}")
        print(f"Total constants:  {total_constants}")

        # Count by category
        pcb_types = [t for t in self.api['objects'].keys() if t.startswith('IPCB_')]
        sch_types = [t for t in self.api['objects'].keys() if t.startswith('ISch_')]

        print(f"\nPCB types:        {len(pcb_types)}")
        print(f"Schematic types:  {len(sch_types)}")

        # Top 5 types by total API surface
        print("\nTypes with most API members:")
        sorted_types = sorted(
            self.api['objects'].items(),
            key=lambda x: len(x[1]['methods']) + len(x[1]['properties']),
            reverse=True
        )
        for type_name, obj in sorted_types[:5]:
            total = len(obj['methods']) + len(obj['properties'])
            print(f"  {type_name:<30} {total} members")

    def cmd_help(self):
        """Show help message"""
        print("""
Altium DelphiScript API CLI

Usage:
  python altium_api_cli.py list [prefix]     List all API types (optionally filtered)
  python altium_api_cli.py show <type>       Show details for a specific type
  python altium_api_cli.py search <query>    Search for methods/properties
  python altium_api_cli.py validate <file>   Validate DelphiScript file
  python altium_api_cli.py stats             Show API statistics
  python altium_api_cli.py help              Show this help

Examples:
  python altium_api_cli.py list IPCB         List all PCB types
  python altium_api_cli.py show IPCB_Board   Show Board API
  python altium_api_cli.py search MoveToXY   Find MoveToXY methods
  python altium_api_cli.py validate code.pas Validate a script file
""")


def main():
    if len(sys.argv) < 2:
        cli = AltiumAPICLI()
        cli.cmd_help()
        sys.exit(0)

    cli = AltiumAPICLI()
    command = sys.argv[1].lower()

    if command == 'list':
        prefix = sys.argv[2] if len(sys.argv) > 2 else None
        cli.cmd_list_types(prefix)

    elif command == 'show':
        if len(sys.argv) < 3:
            print("Error: Missing type name")
            print("Usage: python altium_api_cli.py show <type>")
            sys.exit(1)
        cli.cmd_show_type(sys.argv[2])

    elif command == 'search':
        if len(sys.argv) < 3:
            print("Error: Missing search query")
            print("Usage: python altium_api_cli.py search <query>")
            sys.exit(1)
        cli.cmd_search(sys.argv[2])

    elif command == 'validate':
        if len(sys.argv) < 3:
            print("Error: Missing code or file")
            print("Usage: python altium_api_cli.py validate <file>")
            sys.exit(1)
        cli.cmd_validate(sys.argv[2])

    elif command == 'stats':
        cli.cmd_stats()

    elif command == 'help':
        cli.cmd_help()

    else:
        print(f"Unknown command: {command}")
        cli.cmd_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
