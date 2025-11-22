# Altium-MCP Tests

This directory contains test scripts for the Altium MCP server functionality.

## Test Scripts

### Connection & Integration Tests
- **`test_altium_connection.py`** - Test connection to Altium Designer
- **`test_mcp_integration.py`** - Test MCP server integration
- **`test_async_context.py`** - Test async context handling
- **`test_logging.py`** - Test logging functionality

### API Tests
- **`test_api_search.py`** - Test API documentation search
- **`test_api_timeout.py`** - Test API timeout handling
- **`test_api_tool_direct.py`** - Direct API tool testing
- **`test_search_performance.py`** - API search performance testing

### Schematic DSL Tests
- **`test_schematic_dsl_live.py`** - Live test of schematic DSL extraction
- **`test_simple_schematic.py`** - Simple schematic extraction test

### NSG (Net/Stackup/Geometry) Tests
- **`test_nsg_detailed.py`** - Detailed NSG extraction testing
- **`test_nsg_search.py`** - NSG search functionality

### Component/Library Tests
- **`test_distributor.py`** - Test distributor API integration (Nexar/Octopart)
- **`test_distributor_integration.py`** - Distributor integration tests

### Utility Tests
- **`test_impedance_calcs.py`** - Test impedance calculations
- **`test_kicad_stackup.py`** - Test KiCAD stackup parsing
- **`test_uliengineering.py`** - Test UliEngineering library integration
- **`test_tools_mock.py`** - Mock tool testing

## Test Outputs

Test output files are stored in `tests/outputs/` and are ignored by git.

## Running Tests

```bash
# Test Altium connection (requires Altium Designer running)
python tests/test_altium_connection.py

# Test schematic DSL extraction
python tests/test_schematic_dsl_live.py

# Test API search
python tests/test_api_search.py

# Test impedance calculations
python tests/test_impedance_calcs.py
```

## Requirements

- **Altium Designer** must be running for connection tests
- **MCP server** must be running for integration tests
- Test projects should be located in standard paths

## Notes

Some tests require:
- Active Altium Designer instance
- Specific PCB/schematic files loaded
- Environment variables configured in `.env`
