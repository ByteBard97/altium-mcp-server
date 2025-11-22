#!/usr/bin/env python3
"""
Search the extracted Altium API reference
"""
import json
import sys
from typing import List, Dict

class AltiumAPISearch:
    def __init__(self, json_file: str = "altium_api_reference.json"):
        with open(json_file, 'r') as f:
            self.api_data = json.load(f)

    def search_object(self, obj_name: str) -> Dict:
        """Search for a specific object and return its methods and properties"""
        result = {
            'methods': [],
            'properties': []
        }

        # Search in methods
        if obj_name in self.api_data['all']['methods']:
            result['methods'] = self.api_data['all']['methods'][obj_name]

        # Search in properties
        if obj_name in self.api_data['all']['properties']:
            result['properties'] = self.api_data['all']['properties'][obj_name]

        return result

    def search_method(self, method_name: str) -> List[str]:
        """Find which objects have a specific method"""
        objects = []
        for obj, methods in self.api_data['all']['methods'].items():
            if method_name in methods:
                objects.append(obj)
        return objects

    def search_property(self, property_name: str) -> List[str]:
        """Find which objects have a specific property"""
        objects = []
        for obj, properties in self.api_data['all']['properties'].items():
            if property_name in properties:
                objects.append(obj)
        return objects

    def search_pattern(self, pattern: str) -> Dict:
        """Search for a pattern across objects, methods, and properties"""
        pattern_lower = pattern.lower()
        result = {
            'objects': [],
            'methods': {},
            'properties': {}
        }

        # Search object names
        for obj in self.api_data['all']['methods'].keys():
            if pattern_lower in obj.lower():
                result['objects'].append(obj)

        # Search method names
        for obj, methods in self.api_data['all']['methods'].items():
            matching = [m for m in methods if pattern_lower in m.lower()]
            if matching:
                result['methods'][obj] = matching

        # Search property names
        for obj, properties in self.api_data['all']['properties'].items():
            matching = [p for p in properties if pattern_lower in p.lower()]
            if matching:
                result['properties'][obj] = matching

        return result

    def get_schematic_objects(self) -> List[str]:
        """Get all SCH-related objects"""
        return [obj for obj in self.api_data['all']['methods'].keys()
                if obj.startswith('ISch_') or obj == 'SCHServer']

    def get_pcb_objects(self) -> List[str]:
        """Get all PCB-related objects"""
        return [obj for obj in self.api_data['all']['methods'].keys()
                if obj.startswith('IPCB_') or obj == 'PCBServer']

    def get_example_usage(self, obj_name: str) -> List[Dict]:
        """Get example code snippets for an object"""
        examples = []

        for category in ['SCH', 'PCB']:
            if category in self.api_data:
                for example in self.api_data[category]['examples']:
                    # Check if object is mentioned in the example
                    if obj_name in example['snippet']:
                        examples.append({
                            'category': category,
                            'file': example['file'],
                            'snippet': example['snippet']
                        })

        return examples

    def print_object_info(self, obj_name: str):
        """Pretty print information about an object"""
        info = self.search_object(obj_name)

        if not info['methods'] and not info['properties']:
            print(f"Object '{obj_name}' not found in API reference")
            return

        print(f"\n=== {obj_name} ===\n")

        if info['methods']:
            print(f"Methods ({len(info['methods'])}):")
            for method in sorted(info['methods']):
                print(f"  - {method}()")
            print()

        if info['properties']:
            print(f"Properties ({len(info['properties'])}):")
            for prop in sorted(info['properties']):
                print(f"  - {prop}")
            print()

        # Show examples
        examples = self.get_example_usage(obj_name)
        if examples:
            print(f"Example usage ({len(examples)} found):")
            for ex in examples[:2]:  # Show first 2 examples
                print(f"\n  From: {ex['file']}")
                lines = ex['snippet'].split('\n')[:10]
                for line in lines:
                    if obj_name in line:
                        print(f"  >>> {line}")


def main():
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python search_altium_api.py <object_name>    # Search for an object")
        print("  python search_altium_api.py --pattern <text> # Search for a pattern")
        print("  python search_altium_api.py --sch             # List schematic objects")
        print("  python search_altium_api.py --pcb             # List PCB objects")
        sys.exit(1)

    searcher = AltiumAPISearch()

    if sys.argv[1] == '--pattern' and len(sys.argv) > 2:
        pattern = sys.argv[2]
        result = searcher.search_pattern(pattern)

        if result['objects']:
            print(f"\nObjects matching '{pattern}':")
            for obj in result['objects']:
                print(f"  - {obj}")

        if result['methods']:
            print(f"\nMethods matching '{pattern}':")
            for obj, methods in result['methods'].items():
                print(f"  {obj}:")
                for method in methods:
                    print(f"    - {method}()")

        if result['properties']:
            print(f"\nProperties matching '{pattern}':")
            for obj, props in result['properties'].items():
                print(f"  {obj}:")
                for prop in props:
                    print(f"    - {prop}")

    elif sys.argv[1] == '--sch':
        objects = searcher.get_schematic_objects()
        print("\nSchematic API Objects:")
        for obj in sorted(objects):
            print(f"  - {obj}")

    elif sys.argv[1] == '--pcb':
        objects = searcher.get_pcb_objects()
        print("\nPCB API Objects:")
        for obj in sorted(objects):
            print(f"  - {obj}")

    else:
        obj_name = sys.argv[1]
        searcher.print_object_info(obj_name)


if __name__ == "__main__":
    main()
