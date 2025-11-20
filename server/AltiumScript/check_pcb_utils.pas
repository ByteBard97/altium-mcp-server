program check_pcb_utils;

{$mode delphi}{$H+}

uses
  altium_stubs,
  json_utils;

{$include pcb_utils.pas}

begin
  WriteLn('Syntax check passed for pcb_utils.pas!');
end.
