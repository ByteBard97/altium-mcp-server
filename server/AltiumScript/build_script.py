#!/usr/bin/env python3
"""
Altium Script Builder

Combines multiple Pascal unit files into a single Altium-compatible script.
This allows us to maintain modular code structure while producing the correct
format that Altium expects (no units, top-level declarations).

Usage:
    python build_script.py
"""

import re
import os
from pathlib import Path
from typing import List, Dict, Tuple

class AltiumScriptBuilder:
    def __init__(self, script_dir: str, output_file: str):
        self.script_dir = Path(script_dir)
        self.output_file = Path(output_file)
        self.source_files = []
        self.forward_declarations = []
        self.global_vars = []
        self.global_consts = []
        self.implementations = []

    def find_source_files(self, pattern: str = "*.pas") -> List[Path]:
        """Find all Pascal source files, excluding the output and backup files."""
        exclude_patterns = [
            'Altium_API.pas',  # Don't include the output file
            'altium_stubs.pas',  # Don't include stubs
            'syntax_check.pas',  # Don't include test files
            'compile_test.pas',  # Don't include FPC compilation test file
            '*.backup',
            '*.before_*',
            '*_broken.pas',
        ]

        files = []
        for file in self.script_dir.glob(pattern):
            # Check if file matches any exclude pattern
            should_exclude = False
            for exclude in exclude_patterns:
                if file.match(exclude):
                    should_exclude = True
                    break

            if not should_exclude:
                files.append(file)

        return sorted(files)

    def extract_function_signature(self, line: str) -> Tuple[str, str]:
        """Extract function/procedure signature for forward declaration."""
        # Remove implementation section noise
        line = line.strip()

        # Match function/procedure declarations
        func_match = re.match(r'(function|procedure)\s+(\w+)', line, re.IGNORECASE)
        if func_match:
            return func_match.group(2), line

        return None, None

    def parse_unit_file(self, filepath: Path) -> Dict:
        """Parse a Pascal unit file and extract its components."""
        content = filepath.read_text(encoding='utf-8')
        lines = content.split('\n')

        result = {
            'name': filepath.stem,
            'functions': [],
            'procedures': [],
            'implementation_code': [],
            'uses': set(),
        }

        in_interface = False
        in_implementation = False
        current_function = []

        i = 0
        while i < len(lines):
            line = lines[i]
            stripped = line.strip()

            # Skip unit/interface/implementation keywords
            if re.match(r'^\s*unit\s+\w+\s*;', stripped, re.IGNORECASE):
                i += 1
                continue

            if re.match(r'^\s*interface\s*$', stripped, re.IGNORECASE):
                in_interface = True
                in_implementation = False
                i += 1
                continue

            if re.match(r'^\s*implementation\s*$', stripped, re.IGNORECASE):
                in_interface = False
                in_implementation = True
                i += 1
                continue

            # Track uses clauses (we'll need to know dependencies)
            if stripped.startswith('uses') and in_interface:
                # Extract unit names from uses clause
                uses_line = stripped
                while i < len(lines) - 1 and ';' not in uses_line:
                    i += 1
                    uses_line += ' ' + lines[i].strip()

                # Extract unit names
                match = re.search(r'uses\s+(.*?);', uses_line, re.IGNORECASE)
                if match:
                    units = [u.strip() for u in match.group(1).split(',')]
                    result['uses'].update(units)
                i += 1
                continue

            # In implementation, collect the actual code
            if in_implementation:
                # Skip "end." which terminates unit files
                if stripped == 'end.':
                    i += 1
                    continue

                # Check if this is a function/procedure declaration
                func_match = re.match(r'^\s*(function|procedure)\s+(\w+)', stripped, re.IGNORECASE)

                if func_match:
                    # Start collecting a new function
                    if current_function:
                        result['implementation_code'].extend(current_function)
                        result['implementation_code'].append('')  # Blank line between functions

                    current_function = [line]
                    func_name = func_match.group(2)

                    # Collect full function signature (might span multiple lines)
                    # Look for the ending semicolon (line ends with ; and has balanced parens)
                    signature_lines = [line]
                    paren_count = line.count('(') - line.count(')')
                    current_line_stripped = stripped

                    while i < len(lines) - 1:
                        # Check if current line completes the signature
                        # (ends with ; and parentheses are balanced)
                        if current_line_stripped.endswith(';') and paren_count == 0:
                            break

                        i += 1
                        current_line_stripped = lines[i].strip()
                        signature_lines.append(lines[i])
                        current_function.append(lines[i])
                        paren_count += lines[i].count('(') - lines[i].count(')')

                    # Create forward declaration
                    signature = ' '.join(s.strip() for s in signature_lines)
                    result['functions'].append(signature + ' forward;')
                else:
                    # Continue collecting current function
                    if current_function or stripped:  # Don't add leading blank lines
                        current_function.append(line)

            i += 1

        # Add the last function
        if current_function:
            result['implementation_code'].extend(current_function)

        return result

    def determine_file_order(self, parsed_files: List[Dict]) -> List[Dict]:
        """Order files based on dependencies."""
        # Simple topological sort based on 'uses' clauses
        # For now, use a predefined order based on dependencies

        priority_order = {
            'globals': 0,
            'json_utils': 1,
            'helpers': 2,
            'pcb_utils': 3,
            'board_init': 3,
            'routing': 3,
            'component_placement': 3,
            'library_utils': 3,
            'schematic_utils': 3,
            'other_utils': 3,
            'pcb_layout_duplicator': 3,
            'project_utils': 3,
            'command_executors_board': 4,
            'command_executors_components': 4,
            'command_executors_library': 4,
            'command_executors_placement': 4,
            'command_router': 5,
        }

        return sorted(parsed_files, key=lambda x: priority_order.get(x['name'], 999))

    def build(self):
        """Build the combined Altium script."""
        print("[*] Building Altium script...")

        # Find all source files
        source_files = self.find_source_files()
        print(f"[*] Found {len(source_files)} source files")

        # Parse all files
        parsed_files = []
        for file in source_files:
            print(f"    - Parsing {file.name}...")
            parsed = self.parse_unit_file(file)
            parsed_files.append(parsed)

        # Order files by dependencies
        ordered_files = self.determine_file_order(parsed_files)

        # Build the output
        output_lines = []

        # Header
        output_lines.append("// Altium_API.pas")
        output_lines.append("// Auto-generated combined script - DO NOT EDIT DIRECTLY")
        output_lines.append("// Edit source files and run build_script.py instead")
        output_lines.append("//")
        output_lines.append(f"// Generated from {len(ordered_files)} source files:")
        for parsed in ordered_files:
            output_lines.append(f"//   - {parsed['name']}.pas")
        output_lines.append("")

        # Uses clause (only PCB and standard units)
        output_lines.append("uses")
        output_lines.append("    PCB, SCH, Workspace, Classes, SysUtils;")
        output_lines.append("")

        # Global variables section
        output_lines.append("// ============================================================================")
        output_lines.append("// GLOBAL VARIABLES")
        output_lines.append("// ============================================================================")
        output_lines.append("")
        output_lines.append("var")
        output_lines.append("    // Request/Response handling")
        output_lines.append("    RequestData : TStringList;")
        output_lines.append("    ResponseData : TStringList;")
        output_lines.append("    Params : TStringList;")
        output_lines.append("    REQUEST_FILE : String;")
        output_lines.append("    RESPONSE_FILE : String;")
        output_lines.append("    ROOT_DIR: String;")
        output_lines.append("")

        # Global constants
        output_lines.append("// ============================================================================")
        output_lines.append("// GLOBAL CONSTANTS")
        output_lines.append("// ============================================================================")
        output_lines.append("")
        output_lines.append("const")
        output_lines.append("    constScriptProjectName = 'Altium_API';")
        output_lines.append("    REPLACEALL = 1;  // Flag for StringReplace to replace all occurrences")
        output_lines.append("")

        # Forward declarations
        output_lines.append("// ============================================================================")
        output_lines.append("// FORWARD DECLARATIONS")
        output_lines.append("// ============================================================================")
        output_lines.append("")

        for parsed in ordered_files:
            if parsed['functions']:
                output_lines.append(f"// From {parsed['name']}.pas")
                output_lines.extend(parsed['functions'])
                output_lines.append("")

        # Implementations
        output_lines.append("// ============================================================================")
        output_lines.append("// IMPLEMENTATIONS")
        output_lines.append("// ============================================================================")
        output_lines.append("")

        for parsed in ordered_files:
            if parsed['implementation_code']:
                output_lines.append(f"// ============================================================================")
                output_lines.append(f"// {parsed['name'].upper()}.PAS")
                output_lines.append(f"// ============================================================================")
                output_lines.append("")
                output_lines.extend(parsed['implementation_code'])
                output_lines.append("")
                output_lines.append("")

        # Close the last implementation section properly
        output_lines.append("end;")
        output_lines.append("")
        output_lines.append("")

        # Helper procedure for debugging
        output_lines.append("// ============================================================================")
        output_lines.append("// DEBUG HELPER")
        output_lines.append("// ============================================================================")
        output_lines.append("")
        output_lines.append("procedure DebugLog(const Msg: String);")
        output_lines.append("var")
        output_lines.append("    DebugFile: TextFile;")
        output_lines.append("    DebugPath: String;")
        output_lines.append("begin")
        output_lines.append("    try")
        output_lines.append("        DebugPath := 'C:\\\\Users\\\\geoff\\\\Desktop\\\\projects\\\\altium-mcp\\\\server\\\\debug.log';")
        output_lines.append("        AssignFile(DebugFile, DebugPath);")
        output_lines.append("        if FileExists(DebugPath) then")
        output_lines.append("            Append(DebugFile)")
        output_lines.append("        else")
        output_lines.append("            Rewrite(DebugFile);")
        output_lines.append("        try")
        output_lines.append("            WriteLn(DebugFile, Msg);")
        output_lines.append("        finally")
        output_lines.append("            CloseFile(DebugFile);")
        output_lines.append("        end;")
        output_lines.append("    except")
        output_lines.append("        // Silently ignore any errors in debug logging")
        output_lines.append("    end;")
        output_lines.append("end;")
        output_lines.append("")
        output_lines.append("")

        # Main procedure
        output_lines.append("// ============================================================================")
        output_lines.append("// MAIN ENTRY POINT")
        output_lines.append("// ============================================================================")
        output_lines.append("")
        output_lines.append("// Main procedure to run the bridge")
        output_lines.append("procedure Run;")
        output_lines.append("var")
        output_lines.append("    CommandType: String;")
        output_lines.append("    Result: String;")
        output_lines.append("    i: Integer;")
        output_lines.append("    Line: String;")
        output_lines.append("    ValueStart: Integer;")
        output_lines.append("    Workspace: IWorkspace;")
        output_lines.append("    Project: IProject;")
        output_lines.append("    ProjectCount: Integer;")
        output_lines.append("    ScriptPath: String;")
        output_lines.append("    RootDir: String;")
        output_lines.append("    ProjectIdx: Integer;")
        output_lines.append("    LastSlashPos: Integer;")
        output_lines.append("begin")
        output_lines.append("    DebugLog('=== Script Started ===');")
        output_lines.append("    ")
        output_lines.append("    // Calculate root directory from script location")
        output_lines.append("    Workspace := GetWorkspace;")
        output_lines.append("    if (Workspace <> nil) then")
        output_lines.append("    begin")
        output_lines.append("        ProjectCount := Workspace.DM_ProjectCount();")
        output_lines.append("        DebugLog('Project count: ' + IntToStr(ProjectCount));")
        output_lines.append("        for ProjectIdx := 0 to ProjectCount - 1 do")
        output_lines.append("        begin")
        output_lines.append("            Project := Workspace.DM_Projects(ProjectIdx);")
        output_lines.append("            DebugLog('Project ' + IntToStr(ProjectIdx) + ': ' + Project.DM_ProjectFileName);")
        output_lines.append("            if (Project.DM_ProjectFileName = 'Altium_API.PrjScr') then")
        output_lines.append("            begin")
        output_lines.append("                ScriptPath := Project.DM_ProjectFullPath;")
        output_lines.append("                // ScriptPath is like: C:\\\\...\\\\server\\\\AltiumScript\\\\Altium_API.PrjScr")
        output_lines.append("                // We need to go up to the server directory")
        output_lines.append("                RootDir := ExtractFilePath(ScriptPath);  // Gets C:\\\\...\\\\server\\\\AltiumScript\\\\")
        output_lines.append("                // ShowMessage('Step 1 - After ExtractFilePath: ' + RootDir);")
        output_lines.append("                // Remove ALL trailing backslashes")
        output_lines.append("                while (Length(RootDir) > 0) and (RootDir[Length(RootDir)] = #92) do")
        output_lines.append("                    RootDir := Copy(RootDir, 1, Length(RootDir) - 1);")
        output_lines.append("                // ShowMessage('Step 2 - After removing backslashes: ' + RootDir);")
        output_lines.append("                // Now RootDir = C:\\\\...\\\\server\\\\AltiumScript")
        output_lines.append("                // Find the last backslash to go up one directory")
        output_lines.append("                LastSlashPos := Length(RootDir);")
        output_lines.append("                while (LastSlashPos > 0) and (RootDir[LastSlashPos] <> #92) do")
        output_lines.append("                    LastSlashPos := LastSlashPos - 1;")
        output_lines.append("                // ShowMessage('Step 3 - LastSlashPos: ' + IntToStr(LastSlashPos));")
        output_lines.append("                // Extract up to (and including) the last backslash")
        output_lines.append("                if LastSlashPos > 0 then")
        output_lines.append("                    RootDir := Copy(RootDir, 1, LastSlashPos);")
        output_lines.append("                // ShowMessage('Step 4 - Final RootDir: ' + RootDir);")
        output_lines.append("                // Now RootDir = C:\\\\...\\\\server\\\\")
        output_lines.append("                Break;")
        output_lines.append("            end;")
        output_lines.append("        end;")
        output_lines.append("    end;")
        output_lines.append("")
        output_lines.append("    // Initialize file paths based on script location")
        output_lines.append("    InitializeFilePaths(RootDir);")
        output_lines.append("")
        output_lines.append("    // DEBUG: Show all path calculations")
        output_lines.append("    // ShowMessage('DEBUG Path Info:' + #13#10 + ")
        output_lines.append("    //             'ScriptPath: ' + ScriptPath + #13#10 + ")
        output_lines.append("    //             'RootDir: ' + RootDir + #13#10 + ")
        output_lines.append("    //             'ROOT_DIR (global): ' + ROOT_DIR + #13#10 + ")
        output_lines.append("    //             'REQUEST_FILE: ' + REQUEST_FILE);")
        output_lines.append("")
        output_lines.append("    // Check if request file exists")
        output_lines.append("    if not FileExists(REQUEST_FILE) then")
        output_lines.append("    begin")
        output_lines.append("        ShowMessage('Error: No request file found.' + #13#10 + 'ROOT_DIR: ' + ROOT_DIR + #13#10 + 'Full path: ' + REQUEST_FILE);")
        output_lines.append("        Exit;")
        output_lines.append("    end;")
        output_lines.append("")
        output_lines.append("    try")
        output_lines.append("        // Initialize parameters list")
        output_lines.append("        Params := TStringList.Create;")
        output_lines.append("        Params.Delimiter := '=';")
        output_lines.append("")
        output_lines.append("        // Read the request file")
        output_lines.append("        RequestData := TStringList.Create;")
        output_lines.append("        try")
        output_lines.append("            RequestData.LoadFromFile(REQUEST_FILE);")
        output_lines.append("")
        output_lines.append("            // Default command type")
        output_lines.append("            CommandType := '';")
        output_lines.append("")
        output_lines.append("            // Parse command and parameters")
        output_lines.append("            for i := 0 to RequestData.Count - 1 do")
        output_lines.append("            begin")
        output_lines.append("                Line := RequestData[i];")
        output_lines.append("")
        output_lines.append("                // Extract command")
        output_lines.append("                if Pos('\"command\":', Line) > 0 then")
        output_lines.append("                begin")
        output_lines.append("                    ValueStart := Pos(':', Line) + 1;")
        output_lines.append("                    CommandType := Copy(Line, ValueStart, Length(Line) - ValueStart + 1);")
        output_lines.append("                    CommandType := TrimJSON(CommandType);")
        output_lines.append("                end")
        output_lines.append("                else")
        output_lines.append("                begin")
        output_lines.append("                    // Extract all other parameters")
        output_lines.append("                    ExtractParameter(Line);")
        output_lines.append("                end;")
        output_lines.append("            end;")
        output_lines.append("")
        output_lines.append("            // Execute the command if valid")
        output_lines.append("            if CommandType <> '' then")
        output_lines.append("            begin")
        output_lines.append("                Result := ExecuteCommand(CommandType);")
        output_lines.append("")
        output_lines.append("                if Result <> '' then")
        output_lines.append("                begin")
        output_lines.append("                    WriteResponse(True, Result, '');")
        output_lines.append("                end")
        output_lines.append("                else")
        output_lines.append("                begin")
        output_lines.append("                    WriteResponse(False, '', 'Command execution failed');")
        output_lines.append("                    ShowMessage('Error: Command execution failed');")
        output_lines.append("                end;")
        output_lines.append("            end")
        output_lines.append("            else")
        output_lines.append("            begin")
        output_lines.append("                WriteResponse(False, '', 'No command specified');")
        output_lines.append("                ShowMessage('Error: No command specified');")
        output_lines.append("            end;")
        output_lines.append("        finally")
        output_lines.append("            RequestData.Free;")
        output_lines.append("            Params.Free;")
        output_lines.append("        end;")
        output_lines.append("    except")
        output_lines.append("        // Simple exception handling without the specific exception type")
        output_lines.append("        WriteResponse(False, '', 'Exception occurred during script execution');")
        output_lines.append("        ShowMessage('Error: Exception occurred during script execution');")
        output_lines.append("    end;")
        output_lines.append("end;")
        output_lines.append("")

        # Write output
        output_text = '\n'.join(output_lines)
        self.output_file.write_text(output_text, encoding='utf-8')

        print(f"[+] Built {self.output_file}")
        print(f"    - {len(output_lines)} lines")
        print(f"    - {sum(len(p['functions']) for p in ordered_files)} functions/procedures")


def compile_check(script_dir, output_file):
    """Run FPC to check for syntax errors"""
    import subprocess
    import tempfile
    import re

    print("\n[*] Running syntax check with Free Pascal Compiler...")

    # Read the generated script
    script_content = output_file.read_text(encoding='utf-8')

    # Remove Altium-specific uses clause and replace with FPC-compatible one
    script_content = re.sub(
        r'uses\s+PCB,\s*SCH,\s*Workspace,\s*Classes,\s*SysUtils;',
        '',
        script_content,
        flags=re.MULTILINE
    )

    # Create a wrapper program that uses both stubs and the modified script
    wrapper_content = """program compile_test;
{$mode delphi}{$H+}

uses
  altium_stubs, Classes, SysUtils;

"""

    # Add the modified script content
    wrapper_content += script_content

    # Add program begin/end block (required for FPC but not used)
    wrapper_content += "\n\nbegin\n  // Empty program - just syntax checking\nend.\n"

    # Write wrapper to temp file
    wrapper_file = script_dir / "compile_test.pas"
    wrapper_file.write_text(wrapper_content, encoding='utf-8')

    try:
        # Run FPC with syntax-only check
        result = subprocess.run(
            [r"C:\FPC\3.2.2\bin\i386-win32\fpc.exe",
             "-Sd",  # Delphi mode
             "-vw",  # Show warnings
             "-vi",  # Show info
             "-vn",  # Show notes
             str(wrapper_file)],
            cwd=str(script_dir),
            capture_output=True,
            text=True
        )

        # Clean up generated files
        for ext in ['.o', '.ppu']:
            cleanup_file = wrapper_file.with_suffix(ext)
            if cleanup_file.exists():
                cleanup_file.unlink()

        # Also clean up compiled executable
        exe_file = wrapper_file.with_suffix('.exe')
        if exe_file.exists():
            exe_file.unlink()

        # Clean up stub files
        stub_file = script_dir / "altium_stubs"
        for ext in ['.o', '.ppu']:
            cleanup_file = stub_file.with_suffix(ext)
            if cleanup_file.exists():
                cleanup_file.unlink()

        if result.returncode != 0:
            print("\n[!] FPC syntax check found issues (expected - Altium DelphiScript differs from FPC):")
            # Only show actual errors, not the full output
            for line in result.stdout.split('\n'):
                if 'Error:' in line or 'Fatal:' in line:
                    print(f"    {line}")
            return False
        else:
            print("[+] FPC syntax check passed!")
            # Show warnings if any
            if "Warning:" in result.stdout:
                print("\n[!] Warnings:")
                for line in result.stdout.split('\n'):
                    if 'Warning:' in line or 'Note:' in line:
                        print(f"    {line}")
            return True

    finally:
        # Keep wrapper file for debugging if compilation failed
        if result.returncode == 0 and wrapper_file.exists():
            wrapper_file.unlink()


def main():
    script_dir = Path(__file__).parent
    output_file = script_dir / "Altium_API.pas"

    builder = AltiumScriptBuilder(script_dir, output_file)
    builder.build()

    # Run compilation check (non-blocking - Altium script syntax differs from FPC)
    print("\n[SUCCESS] Build complete!")
    compile_check(script_dir, output_file)


if __name__ == "__main__":
    main()
