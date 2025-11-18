#!/usr/bin/env python3
"""
Smart heuristic fixer for Pascal/DelphiScript syntax errors
Focuses on fixing unbalanced begin/end pairs by removing extra ends
"""
import re
import sys
from pathlib import Path
from typing import List, Tuple
import shutil

class PascalFixer:
    def __init__(self, filepath: Path):
        self.filepath = filepath
        self.lines = []
        self.original_content = ""
        self.changes_made = []

    def load_file(self):
        """Load Pascal file"""
        with open(self.filepath, 'r', encoding='utf-8') as f:
            self.original_content = f.read()
            self.lines = self.original_content.split('\n')
        print(f"Loaded {self.filepath.name}: {len(self.lines)} lines")

    def create_backup(self):
        """Create backup of original file"""
        backup_path = self.filepath.with_suffix('.pas.backup')
        shutil.copy2(self.filepath, backup_path)
        print(f"Created backup: {backup_path.name}")

    def remove_comments(self, line: str) -> str:
        """Remove comments from a line for analysis"""
        # Remove // comments
        if '//' in line:
            line = line[:line.index('//')]
        # Remove { } comments (simple version, doesn't handle multi-line)
        line = re.sub(r'\{[^}]*\}', '', line)
        return line

    def is_significant_begin(self, line: str) -> bool:
        """Check if line contains a significant 'begin'"""
        cleaned = self.remove_comments(line).strip().lower()
        # Check for 'begin' as a standalone keyword
        return bool(re.search(r'\bbegin\b', cleaned))

    def is_significant_end(self, line: str) -> Tuple[bool, str]:
        """Check if line contains a significant 'end' and return the type"""
        cleaned = self.remove_comments(line).strip().lower()

        # Check for unit terminator 'end.'
        if re.search(r'\bend\s*\.\s*$', cleaned):
            return True, 'unit_end'

        # Check for regular 'end;' or 'end'
        if re.search(r'\bend\b', cleaned):
            # Check if it's exception handler end
            if re.search(r'\bexcept\b.*\bend\b', cleaned):
                return True, 'except_end'
            # Check if it's a regular end
            return True, 'block_end'

        return False, ''

    def analyze_structure(self) -> List[dict]:
        """Analyze begin/end structure and identify issues"""
        depth = 0
        structure = []

        for i, line in enumerate(self.lines, 1):
            line_info = {
                'line_num': i,
                'original': line,
                'depth_before': depth,
                'action': None,
                'depth_after': depth
            }

            # Check for begin
            if self.is_significant_begin(line):
                depth += 1
                line_info['action'] = 'begin'
                line_info['depth_after'] = depth

            # Check for end
            is_end, end_type = self.is_significant_end(line)
            if is_end:
                if end_type == 'unit_end':
                    line_info['action'] = 'unit_end'
                    # Don't change depth for unit end
                elif depth > 0:
                    depth -= 1
                    line_info['action'] = f'end ({end_type})'
                    line_info['depth_after'] = depth
                else:
                    # This is an extra end!
                    line_info['action'] = f'EXTRA_END ({end_type})'
                    line_info['depth_after'] = depth
                    line_info['should_remove'] = True

            structure.append(line_info)

        return structure

    def fix_extra_ends(self) -> int:
        """Remove extra end statements based on structure analysis"""
        structure = self.analyze_structure()
        fixed_lines = []
        removed_count = 0

        for info in structure:
            line = info['original']

            if info.get('should_remove'):
                # Remove this extra end
                stripped = line.strip()
                indent = len(line) - len(line.lstrip())
                comment = ' ' * indent + f"// REMOVED EXTRA END: {stripped}"
                fixed_lines.append(comment)
                removed_count += 1
                self.changes_made.append(
                    f"Line {info['line_num']}: Removed extra '{stripped}' (depth was {info['depth_before']})"
                )
            else:
                fixed_lines.append(line)

        self.lines = fixed_lines
        return removed_count

    def fix_duplicate_ends(self) -> int:
        """Remove duplicate consecutive end statements"""
        fixed_lines = []
        removed_count = 0
        prev_was_end = False

        for i, line in enumerate(self.lines, 1):
            cleaned = self.remove_comments(line).strip().lower()
            is_end = bool(re.search(r'^\s*end\s*;?\s*$', cleaned))

            if is_end and prev_was_end:
                # This is a duplicate end
                stripped = line.strip()
                indent = len(line) - len(line.lstrip())
                comment = ' ' * indent + f"// REMOVED DUPLICATE END: {stripped}"
                fixed_lines.append(comment)
                removed_count += 1
                self.changes_made.append(
                    f"Line {i}: Removed duplicate consecutive '{stripped}'"
                )
            else:
                fixed_lines.append(line)
                prev_was_end = is_end

        self.lines = fixed_lines
        return removed_count

    def fix_exception_handler_ends(self) -> int:
        """Fix common exception handler pattern with extra ends"""
        fixed_lines = []
        removed_count = 0

        i = 0
        while i < len(self.lines):
            line = self.lines[i]
            cleaned = self.remove_comments(line).strip().lower()

            # Look for pattern: except...end; followed by end;
            if 'except' in cleaned and i + 2 < len(self.lines):
                # Check if except line contains Result assignment
                if 'result' in cleaned and ':=' in cleaned:
                    next_line = self.remove_comments(self.lines[i + 1]).strip().lower()
                    next_next_line = self.remove_comments(self.lines[i + 2]).strip().lower()

                    # If next line is 'end;' and line after is also 'end;'
                    if re.match(r'^\s*end\s*;?\s*$', next_line) and re.match(r'^\s*end\s*;?\s*$', next_next_line):
                        # Keep first end, remove second
                        fixed_lines.append(self.lines[i])  # except line
                        fixed_lines.append(self.lines[i + 1])  # first end

                        stripped = self.lines[i + 2].strip()
                        indent = len(self.lines[i + 2]) - len(self.lines[i + 2].lstrip())
                        comment = ' ' * indent + f"// REMOVED EXTRA END AFTER EXCEPT: {stripped}"
                        fixed_lines.append(comment)

                        removed_count += 1
                        self.changes_made.append(
                            f"Line {i + 3}: Removed extra end after exception handler"
                        )
                        i += 3
                        continue

            fixed_lines.append(line)
            i += 1

        self.lines = fixed_lines
        return removed_count

    def get_begin_end_count(self) -> Tuple[int, int]:
        """Count total begin and end statements"""
        begins = 0
        ends = 0

        for line in self.lines:
            cleaned = self.remove_comments(line)
            if self.is_significant_begin(cleaned):
                begins += 1
            is_end, end_type = self.is_significant_end(cleaned)
            if is_end and end_type != 'unit_end':
                ends += 1

        return begins, ends

    def save_fixed_file(self):
        """Save the fixed file"""
        content = '\n'.join(self.lines)
        with open(self.filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Saved fixed file: {self.filepath.name}")

    def fix(self) -> bool:
        """Run all fix operations"""
        print(f"\n{'='*70}")
        print(f"Fixing: {self.filepath.name}")
        print(f"{'='*70}")

        # Get initial counts
        begins_before, ends_before = self.get_begin_end_count()
        print(f"Initial: {begins_before} begin(s), {ends_before} end(s) [diff: {ends_before - begins_before}]")

        if begins_before == ends_before:
            print("[OK] File is already balanced!")
            return False

        # Create backup
        self.create_backup()

        # Apply fixes
        print("\nApplying fixes...")

        # Fix 1: Remove duplicate consecutive ends
        dup_removed = self.fix_duplicate_ends()
        if dup_removed > 0:
            print(f"  - Removed {dup_removed} duplicate consecutive end(s)")

        # Fix 2: Fix exception handler patterns
        except_removed = self.fix_exception_handler_ends()
        if except_removed > 0:
            print(f"  - Removed {except_removed} extra end(s) after exception handlers")

        # Fix 3: Remove structurally extra ends
        extra_removed = self.fix_extra_ends()
        if extra_removed > 0:
            print(f"  - Removed {extra_removed} structurally extra end(s)")

        # Get final counts
        begins_after, ends_after = self.get_begin_end_count()
        print(f"\nFinal: {begins_after} begin(s), {ends_after} end(s) [diff: {ends_after - begins_after}]")

        # Report
        if begins_after == ends_after:
            print("[SUCCESS] File is now balanced!")
            self.save_fixed_file()
            return True
        else:
            print(f"[PARTIAL] Improved but still unbalanced by {ends_after - begins_after}")
            print("Manual review recommended.")
            self.save_fixed_file()
            return False

    def print_changes(self):
        """Print summary of changes made"""
        if self.changes_made:
            print(f"\nChanges made ({len(self.changes_made)}):")
            for change in self.changes_made[:10]:  # Show first 10
                print(f"  - {change}")
            if len(self.changes_made) > 10:
                print(f"  ... and {len(self.changes_made) - 10} more")

def main():
    """Fix all Pascal files in current directory"""
    print("="*70)
    print("PASCAL SYNTAX FIXER")
    print("="*70)
    print("\nThis will attempt to fix unbalanced begin/end pairs")
    print("Backups will be created with .pas.backup extension\n")

    # Find all Pascal files
    pascal_files = list(Path('.').glob('*.pas'))

    if not pascal_files:
        print("No .pas files found in current directory")
        return 1

    print(f"Found {len(pascal_files)} Pascal file(s) to check\n")

    # Fix each file
    fixed_count = 0
    improved_count = 0

    for filepath in pascal_files:
        fixer = PascalFixer(filepath)
        fixer.load_file()

        if fixer.fix():
            fixed_count += 1
        elif fixer.changes_made:
            improved_count += 1

        fixer.print_changes()

    # Summary
    print(f"\n{'='*70}")
    print("SUMMARY")
    print(f"{'='*70}")
    print(f"Files checked: {len(pascal_files)}")
    print(f"Fully fixed: {fixed_count}")
    print(f"Partially fixed: {improved_count}")
    print(f"No changes: {len(pascal_files) - fixed_count - improved_count}")

    if fixed_count == len(pascal_files):
        print("\n[SUCCESS] All files are now balanced!")
        return 0
    else:
        print("\n[PARTIAL] Some files may still need manual review")
        print("Check files with .pas.backup to see original versions")
        return 1

if __name__ == "__main__":
    sys.exit(main())
