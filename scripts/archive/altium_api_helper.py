#!/usr/bin/env python3
"""
Helper for validating and generating Altium DelphiScript API calls
"""
import json
from typing import List, Dict, Optional

class AltiumAPIHelper:
    """Helper class to validate and suggest Altium API calls"""

    def __init__(self, json_file: str = "altium_api_reference.json"):
        with open(json_file, 'r') as f:
            self.api_data = json.load(f)

    def has_method(self, obj_name: str, method_name: str) -> bool:
        """Check if an object has a specific method"""
        if obj_name in self.api_data['all']['methods']:
            return method_name in self.api_data['all']['methods'][obj_name]
        return False

    def has_property(self, obj_name: str, property_name: str) -> bool:
        """Check if an object has a specific property"""
        if obj_name in self.api_data['all']['properties']:
            return property_name in self.api_data['all']['properties'][obj_name]
        return False

    def suggest_alternative(self, obj_name: str, attempted_name: str) -> Optional[List[str]]:
        """Suggest alternatives if a method/property doesn't exist"""
        suggestions = []

        # Check methods
        if obj_name in self.api_data['all']['methods']:
            for method in self.api_data['all']['methods'][obj_name]:
                if attempted_name.lower() in method.lower() or method.lower() in attempted_name.lower():
                    suggestions.append(f"method: {method}()")

        # Check properties
        if obj_name in self.api_data['all']['properties']:
            for prop in self.api_data['all']['properties'][obj_name]:
                if attempted_name.lower() in prop.lower() or prop.lower() in attempted_name.lower():
                    suggestions.append(f"property: {prop}")

        return suggestions if suggestions else None

    def get_object_methods(self, obj_name: str) -> List[str]:
        """Get all methods for an object"""
        if obj_name in self.api_data['all']['methods']:
            return sorted(self.api_data['all']['methods'][obj_name])
        return []

    def get_object_properties(self, obj_name: str) -> List[str]:
        """Get all properties for an object"""
        if obj_name in self.api_data['all']['properties']:
            return sorted(self.api_data['all']['properties'][obj_name])
        return []

    def validate_api_call(self, obj_name: str, member_name: str) -> Dict:
        """Validate an API call and provide feedback"""
        result = {
            'valid': False,
            'type': None,
            'suggestions': []
        }

        # Check if it's a method
        if self.has_method(obj_name, member_name):
            result['valid'] = True
            result['type'] = 'method'
            return result

        # Check if it's a property
        if self.has_property(obj_name, member_name):
            result['valid'] = True
            result['type'] = 'property'
            return result

        # Not found, suggest alternatives
        result['suggestions'] = self.suggest_alternative(obj_name, member_name) or []

        return result

    def get_example_code(self, obj_name: str, max_examples: int = 3) -> List[str]:
        """Get example code snippets featuring this object"""
        examples = []

        for category in ['SCH', 'PCB']:
            if category in self.api_data:
                for example in self.api_data[category]['examples']:
                    if obj_name in example['snippet']:
                        # Extract relevant lines
                        lines = example['snippet'].split('\n')
                        relevant_lines = [line for line in lines if obj_name in line]
                        if relevant_lines:
                            examples.extend(relevant_lines[:2])

                        if len(examples) >= max_examples * 2:
                            break
                if len(examples) >= max_examples * 2:
                    break

        return examples[:max_examples * 2]

    def generate_api_summary(self, obj_name: str) -> str:
        """Generate a formatted summary of an object's API"""
        methods = self.get_object_methods(obj_name)
        properties = self.get_object_properties(obj_name)

        summary = f"=== {obj_name} API ===\n\n"

        if methods:
            summary += f"Methods ({len(methods)}):\n"
            for method in methods:
                summary += f"  {obj_name}.{method}(...)\n"
            summary += "\n"

        if properties:
            summary += f"Properties ({len(properties)}):\n"
            for prop in properties:
                summary += f"  {obj_name}.{prop}\n"
            summary += "\n"

        examples = self.get_example_code(obj_name, max_examples=3)
        if examples:
            summary += "Example usage:\n"
            for ex in examples:
                summary += f"  {ex.strip()}\n"

        return summary


# Convenience functions for quick validation
def validate_call(obj: str, member: str) -> bool:
    """Quick validation of an API call"""
    helper = AltiumAPIHelper()
    result = helper.validate_api_call(obj, member)
    return result['valid']


def suggest_alternatives(obj: str, attempted: str) -> List[str]:
    """Quick alternative suggestions"""
    helper = AltiumAPIHelper()
    return helper.suggest_alternative(obj, attempted) or []


if __name__ == "__main__":
    # Test the helper
    helper = AltiumAPIHelper()

    # Test some API calls
    print("Testing API validation:")
    print(f"Board.GetObjectAtCursor: {helper.validate_api_call('Board', 'GetObjectAtCursor')}")
    print(f"Board.NonExistentMethod: {helper.validate_api_call('Board', 'NonExistentMethod')}")

    print("\n" + helper.generate_api_summary("PCBServer"))
