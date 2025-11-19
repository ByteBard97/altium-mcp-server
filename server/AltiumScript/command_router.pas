// command_router.pas
// Main Command Router

unit command_router;

interface

uses
    PCB, Classes, SysUtils, globals, json_utils, command_executors_components, command_executors_library, command_executors_placement, command_executors_board;

function ExecuteCommand(CommandName: String): String;

implementation

function ExecuteCommand(CommandName: String): String;
begin
    Result := '';
    EnsureDocumentFocused(CommandName);

    // Direct command execution based on the command name
    case CommandName of
        'get_component_pins':
            Result := ExecuteGetComponentPins(RequestData);            
        'get_all_nets':
            Result := GetAllNets(ROOT_DIR);            
        'create_net_class':
            Result := ExecuteCreateNetClass(RequestData);            
        'get_all_component_data':
            Result := GetAllComponentData(ROOT_DIR, False);            
        'take_view_screenshot':
            Result := ExecuteTakeViewScreenshot(RequestData);            
        'get_library_symbol_reference':
            Result := GetLibrarySymbolReference(ROOT_DIR);            
        'create_schematic_symbol':
            Result := ExecuteCreateSchematicSymbol(RequestData);            
        'get_schematic_data':
            Result := GetSchematicData(ROOT_DIR);            
        'get_pcb_layers':
            Result := GetPCBLayers(ROOT_DIR);            
        'set_pcb_layer_visibility':
            Result := ExecuteSetPCBLayerVisibility(RequestData);   
        'get_pcb_layer_stackup':
            Result := GetPCBLayerStackup(ROOT_DIR);         
        'get_selected_components_coordinates':
            Result := GetSelectedComponentsCoordinates(ROOT_DIR);            
        'move_components':
            Result := ExecuteMoveComponents(RequestData);            
        'layout_duplicator':
            Result := GetLayoutDuplicatorComponents(True);            
        'layout_duplicator_apply':
            Result := ExecuteLayoutDuplicatorApply(RequestData);            
        'get_pcb_rules':
            Result := GetPCBRules(ROOT_DIR);
        'get_output_job_containers':
            Result := ExecuteGetOutputJobContainers(RequestData);
        'run_output_jobs':
            Result := ExecuteRunOutputJobs(RequestData);
        'place_component':
            Result := ExecutePlaceComponent(RequestData);
        'delete_component':
            Result := ExecuteDeleteComponent(RequestData);
        'place_component_array':
            Result := ExecutePlaceComponentArray(RequestData);
        'align_components':
            Result := ExecuteAlignComponents(RequestData);
        // Phase 2: Project Management
        'create_project':
            Result := ExecuteCreateProject(RequestData);
        'save_project':
            Result := SaveProject;
        'get_project_info':
            Result := GetProjectInfo;
        'close_project':
            Result := CloseProject;
        // Phase 2: Library Search
        'list_component_libraries':
            Result := ListComponentLibraries;
        'search_components':
            Result := ExecuteSearchComponents(RequestData);
        'get_component_from_library':
            Result := ExecuteGetComponentFromLibrary(RequestData);
        'search_footprints':
            Result := ExecuteSearchFootprints(RequestData);
        // Phase 5: Board & Routing
        'set_board_size':
            Result := ExecuteSetBoardSize(RequestData);
        'add_board_outline':
            Result := ExecuteAddBoardOutline(RequestData);
        'add_mounting_hole':
            Result := ExecuteAddMountingHole(RequestData);
        'add_board_text':
            Result := ExecuteAddBoardText(RequestData);
        'route_trace':
            Result := ExecuteRouteTrace(RequestData);
        'add_via':
            Result := ExecuteAddVia(RequestData);
        'add_copper_pour':
            Result := ExecuteAddCopperPour(RequestData);
    else
        ShowMessage('Error: Unknown command: ' + CommandName);
    end;


end.
