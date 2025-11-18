#!/usr/bin/env python3
"""
Validate DelphiScript/Pascal files for common syntax errors
This is a simple checker - not as good as a real Pascal compiler, but catches common issues
"""
import re
import sys
from pathlib import Path

class PascalValidator:
    def __init__(self):
        self.errors = []
        self.warnings = []

    def validate_file(self, filepath):
        """Validate a Pascal file for common syntax errors"""
        print(f"\n{'='*70}")
        print(f"Validating: {filepath.name}")
        print(f"{'='*70}")

        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            lines = content.split('\n')

        self.errors = []
        self.warnings = []

        # Check for common syntax issues
        self.check_begin_end_pairs(content, lines)
        self.check_semicolons(lines)
        self.check_string_quotes(lines)
        self.check_procedure_function_syntax(lines)
        self.check_exception_handlers(lines)

        # Report results
        if self.errors:
            print(f"\n[ERRORS] {len(self.errors)} error(s) found:")
            for error in self.errors:
                print(f"  Line {error['line']}: {error['message']}")
        else:
            print("\n[OK] No syntax errors detected")

        if self.warnings:
            print(f"\n[WARNINGS] {len(self.warnings)} warning(s) found:")
            for warning in self.warnings:
                print(f"  Line {warning['line']}: {warning['message']}")

        return len(self.errors) == 0

    def check_begin_end_pairs(self, content, lines):
        """Check if begin/end pairs are balanced"""
        # Remove comments
        content_no_comments = re.sub(r'\{[^}]*\}', '', content)
        content_no_comments = re.sub(r'//.*$', '', content_no_comments, flags=re.MULTILINE)

        # Count begin/end pairs (case insensitive)
        begins = len(re.findall(r'\bbegin\b', content_no_comments, re.IGNORECASE))
        ends = len(re.findall(r'\bend\b', content_no_comments, re.IGNORECASE))

        if begins != ends:
            self.errors.append({
                'line': '?',
                'message': f"Unbalanced begin/end: {begins} begin(s), {ends} end(s)"
            })

    def check_semicolons(self, lines):
        """Check for missing semicolons after common statements"""
        for i, line in enumerate(lines, 1):
            stripped = line.strip()

            # Skip comments and empty lines
            if not stripped or stripped.startswith('//') or stripped.startswith('{'):
                continue

            # Check for statements that should end with semicolon
            # but don't (excluding begin, end, then, else, do)
            if stripped and not any(stripped.endswith(word) for word in ['begin', 'end', 'then', 'else', 'do', 'var', 'const', 'type', 'interface', 'implementation', 'uses']):
                # If line contains assignment or procedure call and doesn't end with semicolon
                if ':=' in stripped or '(' in stripped:
                    if not stripped.endswith(';') and not stripped.endswith(','):
                        # Check next line - if it starts with 'else', 'end', 'except', etc., semicolon might be optional
                        if i < len(lines):
                            next_line = lines[i].strip()
                            if not any(next_line.startswith(word) for word in ['else', 'end', 'except', 'finally', 'until']):
                                self.warnings.append({
                                    'line': i,
                                    'message': f"Possible missing semicolon: '{stripped[:50]}...'"
                                })

    def check_string_quotes(self, lines):
        """Check for unclosed string literals"""
        for i, line in enumerate(lines, 1):
            # Skip comments
            if line.strip().startswith('//'):
                continue

            # Count single quotes (Pascal string delimiter)
            # Ignore doubled quotes (escaped quotes)
            clean_line = line.replace("''", "")
            quotes = clean_line.count("'")

            if quotes % 2 != 0:
                self.errors.append({
                    'line': i,
                    'message': f"Unclosed string literal (odd number of quotes)"
                })

    def check_procedure_function_syntax(self, lines):
        """Check procedure/function declarations"""
        for i, line in enumerate(lines, 1):
            stripped = line.strip()

            # Check procedure/function declarations
            if re.match(r'^(procedure|function)\s+\w+', stripped, re.IGNORECASE):
                # Should end with semicolon or begin declaration
                if not (';' in stripped or '=' in stripped):
                    # Check if next few lines have semicolon
                    found_semicolon = False
                    for j in range(i, min(i + 3, len(lines))):
                        if ';' in lines[j]:
                            found_semicolon = True
                            break
                    if not found_semicolon:
                        self.warnings.append({
                            'line': i,
                            'message': "Procedure/function declaration may be missing semicolon"
                        })

    def check_exception_handlers(self, lines):
        """Check try/except/finally blocks"""
        for i, line in enumerate(lines, 1):
            stripped = line.strip().lower()

            # Check for 'try' without matching 'end'
            if stripped.startswith('try'):
                # Look ahead for except or finally
                found_handler = False
                for j in range(i, min(i + 50, len(lines))):
                    next_line = lines[j].strip().lower()
                    if next_line.startswith('except') or next_line.startswith('finally'):
                        found_handler = True
                        break
                if not found_handler:
                    self.warnings.append({
                        'line': i,
                        'message': "try block without except/finally handler"
                    })

def main():
    """Validate all Pascal files in the current directory"""
    pascal_files = list(Path('.').glob('*.pas'))

    if not pascal_files:
        print("No .pas files found in current directory")
        return 1

    validator = PascalValidator()
    all_valid = True

    for filepath in pascal_files:
        is_valid = validator.validate_file(filepath)
        if not is_valid:
            all_valid = False

    print(f"\n{'='*70}")
    print("VALIDATION SUMMARY")
    print(f"{'='*70}")
    print(f"Files checked: {len(pascal_files)}")

    if all_valid:
        print("[OK] All files passed validation")
        return 0
    else:
        print("[ERROR] Some files have syntax errors")
        return 1

if __name__ == "__main__":
    sys.exit(main())
