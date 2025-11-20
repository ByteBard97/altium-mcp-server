program syntax_check;

{$mode objfpc}{$H+}

uses
  altium_stubs,
  json_utils,
  pcb_utils,
  board_init,
  routing,
  component_placement,
  project_utils,
  library_utils,
  other_utils,
  pcb_layout_duplicator,
  schematic_utils;

begin
  WriteLn('Syntax check passed!');
end.
