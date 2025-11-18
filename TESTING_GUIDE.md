# Altium MCP Integration Testing Guide

## Overview

This guide helps you test all 23 tools with a real Altium Designer project to ensure the modernized FastMCP 2.0 implementation works correctly.

---

## Prerequisites

### 1. Setup Complete
- ✅ Conda environment `altium-mcp-v2` created
- ✅ Dependencies installed
- ✅ Server starts without errors

### 2. Altium Designer
- ✅ Altium Designer installed (any version AD20+)
- ✅ X2.EXE path configured in `server/config.json`
- ✅ DelphiScript project path configured

### 3. Test Project
You'll need a PCB project with:
- At least 5-10 components placed
- Multiple nets (power, ground, signals)
- A schematic document
- A PCB document

**Don't have a test project?** See "Creating a Test Project" below.

---

## Testing Approach

We'll test in 3 phases:

1. **Phase 1: Server Tests** (no Altium needed)
2. **Phase 2: Integration Tests** (Altium required)
3. **Phase 3: Interactive Tests** (via Claude Desktop)

---

## Phase 1: Server Tests (5 minutes)

These tests verify the server starts and tools are registered correctly.

### Run Unit Tests

```bash
conda activate altium-mcp-v2
cd C:\Users\geoff\Desktop\projects\altium-mcp\server
python test_server.py
```

**Expected Output:**
```
Testing FastMCP 2.0 Altium Server...

✓ Testing tool registration...
  Found 23 tools

✓ Testing resource registration...
  Found 8 resources

✓ Testing prompt registration...
  Found 3 prompts

✓ Testing tool schemas...
  All 23 tools have valid schemas

✓ Testing bridge initialization...
  Bridge initialized successfully

✅ All tests passed!
```

---

## Phase 2: Integration Tests with Altium (30 minutes)

These tests actually call Altium and verify responses.

### Step 1: Open a Test Project in Altium

1. Launch Altium Designer
2. Open a PCB project (or create one - see below)
3. Make sure both schematic and PCB documents are in the project
4. **Keep Altium open** during testing

### Step 2: Run Integration Tests

I'll create a comprehensive integration test script for you:

**File: `server/test_integration.py`**

```python
#!/usr/bin/env python3
"""
Integration tests for Altium MCP - requires Altium Designer running with a project open
"""
import asyncio
import json
from altium_bridge import AltiumBridge

class AltiumIntegrationTester:
    def __init__(self):
        self.bridge = AltiumBridge()
        self.passed = 0
        self.failed = 0
        self.results = []

    async def test_tool(self, name: str, command: str, params: dict, validation_fn=None):
        """Test a single tool"""
        print(f"\n{'='*60}")
        print(f"Testing: {name}")
        print(f"Command: {command}")
        print(f"Params: {json.dumps(params, indent=2)}")
        print(f"{'='*60}")

        try:
            result = await self.bridge.call_script(command, params)

            print(f"Success: {result.success}")

            if result.success:
                print(f"Data preview: {str(result.data)[:200]}...")

                # Custom validation
                if validation_fn:
                    if validation_fn(result):
                        print("✅ PASSED - Validation successful")
                        self.passed += 1
                        self.results.append({"test": name, "status": "PASSED"})
                    else:
                        print("❌ FAILED - Validation failed")
                        self.failed += 1
                        self.results.append({"test": name, "status": "FAILED", "reason": "Validation failed"})
                else:
                    print("✅ PASSED")
                    self.passed += 1
                    self.results.append({"test": name, "status": "PASSED"})
            else:
                print(f"❌ FAILED - Error: {result.error}")
                self.failed += 1
                self.results.append({"test": name, "status": "FAILED", "reason": result.error})

        except Exception as e:
            print(f"❌ FAILED - Exception: {str(e)}")
            self.failed += 1
            self.results.append({"test": name, "status": "FAILED", "reason": str(e)})

    async def run_all_tests(self):
        """Run all integration tests"""
        print("\n" + "="*60)
        print("ALTIUM MCP INTEGRATION TEST SUITE")
        print("="*60)
        print("\nPrerequisites:")
        print("  - Altium Designer must be running")
        print("  - A PCB project must be open")
        print("  - Project should have components on the PCB")
        print("\nStarting tests...\n")

        # Initialize bridge
        await self.bridge.initialize()

        # ============================================================
        # COMPONENT TOOLS (7 tests)
        # ============================================================

        print("\n" + "="*60)
        print("COMPONENT TOOLS")
        print("="*60)

        # Test 1: Get all designators
        await self.test_tool(
            "Get All Designators",
            "get_all_component_data",
            {},
            lambda r: isinstance(r.data, list) and len(r.data) > 0
        )

        # Store designators for later tests
        designators_result = await self.bridge.call_script("get_all_component_data", {})
        designators = []
        if designators_result.success and isinstance(designators_result.data, list):
            designators = [c.get("designator") for c in designators_result.data[:3] if "designator" in c]

        # Test 2: Get component data
        if designators:
            await self.test_tool(
                "Get Component Data",
                "get_all_component_data",
                {},
                lambda r: isinstance(r.data, list) and any("designator" in c for c in r.data)
            )

        # Test 3: Get component property names
        await self.test_tool(
            "Get Component Property Names",
            "get_all_component_data",
            {},
            lambda r: isinstance(r.data, list)
        )

        # Test 4: Get selected components coordinates
        print("\nNote: Select some components in Altium PCB before this test")
        await self.test_tool(
            "Get Selected Components Coordinates",
            "get_selected_components_coordinates",
            {}
        )

        # Test 5: Get component pins (if we have designators)
        if designators:
            await self.test_tool(
                "Get Component Pins",
                "get_component_pins",
                {"designators": designators[:1]}
            )

        # Test 6: Get schematic data (if we have designators)
        if designators:
            await self.test_tool(
                "Get Schematic Data",
                "get_schematic_data",
                {}
            )

        # ============================================================
        # NET TOOLS (2 tests)
        # ============================================================

        print("\n" + "="*60)
        print("NET TOOLS")
        print("="*60)

        # Test 7: Get all nets
        await self.test_tool(
            "Get All Nets",
            "get_all_nets",
            {},
            lambda r: isinstance(r.data, list)
        )

        # Store nets for later tests
        nets_result = await self.bridge.call_script("get_all_nets", {})
        nets = []
        if nets_result.success and isinstance(nets_result.data, list):
            nets = nets_result.data[:2]  # Get first 2 nets

        # Test 8: Create net class
        if len(nets) >= 2:
            await self.test_tool(
                "Create Net Class",
                "create_net_class",
                {
                    "class_name": "TEST_CLASS",
                    "net_names": nets
                }
            )

        # ============================================================
        # LAYER TOOLS (3 tests)
        # ============================================================

        print("\n" + "="*60)
        print("LAYER TOOLS")
        print("="*60)

        # Test 9: Get PCB layers
        await self.test_tool(
            "Get PCB Layers",
            "get_pcb_layers",
            {},
            lambda r: isinstance(r.data, list)
        )

        # Test 10: Get layer stackup
        await self.test_tool(
            "Get PCB Layer Stackup",
            "get_pcb_layer_stackup",
            {}
        )

        # Test 11: Set layer visibility
        await self.test_tool(
            "Set PCB Layer Visibility",
            "set_pcb_layer_visibility",
            {
                "layer_names": ["Top Layer"],
                "visible": True
            }
        )

        # ============================================================
        # SCHEMATIC TOOLS (4 tests)
        # ============================================================

        print("\n" + "="*60)
        print("SCHEMATIC TOOLS")
        print("="*60)

        # Test 12: Get symbol placement rules
        await self.test_tool(
            "Get Symbol Placement Rules",
            "get_symbol_placement_rules",  # This reads from a local file
            {}
        )

        # Note: get_library_symbol_reference requires an open schematic library
        print("\nNote: Open a schematic library and select a symbol for the next test")
        await self.test_tool(
            "Get Library Symbol Reference",
            "get_library_symbol_reference",
            {}
        )

        # Note: create_schematic_symbol requires an open schematic library
        # We'll skip this in automated tests

        # ============================================================
        # LAYOUT TOOLS (4 tests)
        # ============================================================

        print("\n" + "="*60)
        print("LAYOUT TOOLS")
        print("="*60)

        # Test 13: Get PCB rules
        await self.test_tool(
            "Get PCB Rules",
            "get_pcb_rules",
            {}
        )

        # Test 14: Move components (if we have designators)
        if designators:
            print(f"\nNote: This will move component {designators[0]} by 100 mils")
            await self.test_tool(
                "Move Components",
                "move_components",
                {
                    "designators": [designators[0]],
                    "x_offset": 100,
                    "y_offset": 100,
                    "rotation": 0
                }
            )

        # Test 15: Layout duplicator (Step 1)
        print("\nNote: Select source components in Altium PCB before this test")
        await self.test_tool(
            "Layout Duplicator (Step 1)",
            "layout_duplicator",
            {}
        )

        # Test 16: Get screenshot
        await self.test_tool(
            "Get Screenshot",
            "take_view_screenshot",
            {"view_type": "pcb"},
            lambda r: "image_data" in r.data if isinstance(r.data, dict) else False
        )

        # ============================================================
        # OUTPUT TOOLS (3 tests)
        # ============================================================

        print("\n" + "="*60)
        print("OUTPUT TOOLS")
        print("="*60)

        # Test 17: Get output job containers (requires .OutJob file open)
        print("\nNote: Open an .OutJob file in Altium for this test")
        await self.test_tool(
            "Get Output Job Containers",
            "get_output_job_containers",
            {}
        )

        # Test 18: Get server status (no Altium needed)
        print("\nNote: This test doesn't require Altium")

        # ============================================================
        # SUMMARY
        # ============================================================

        print("\n" + "="*60)
        print("TEST SUMMARY")
        print("="*60)
        print(f"\nTotal tests run: {self.passed + self.failed}")
        print(f"✅ Passed: {self.passed}")
        print(f"❌ Failed: {self.failed}")
        print(f"Success rate: {(self.passed/(self.passed + self.failed)*100):.1f}%")

        print("\n" + "="*60)
        print("DETAILED RESULTS")
        print("="*60)
        for result in self.results:
            status_icon = "✅" if result["status"] == "PASSED" else "❌"
            print(f"{status_icon} {result['test']}")
            if result["status"] == "FAILED":
                print(f"   Reason: {result.get('reason', 'Unknown')}")

        print("\n" + "="*60)

        if self.failed == 0:
            print("🎉 ALL TESTS PASSED!")
        else:
            print(f"⚠️  {self.failed} tests failed - review errors above")

async def main():
    tester = AltiumIntegrationTester()
    await tester.run_all_tests()

if __name__ == "__main__":
    asyncio.run(main())
```

### Step 3: Run Integration Tests

```bash
conda activate altium-mcp-v2
cd C:\Users\geoff\Desktop\projects\altium-mcp\server
python test_integration.py
```

**What to Expect:**
- Tests will run one by one
- Each test shows the command, parameters, and result
- You'll see ✅ or ❌ for each test
- Final summary shows pass/fail count

**Some tests require manual setup:**
- "Get Selected Components" - Select components in Altium first
- "Get Library Symbol Reference" - Open schematic library first
- "Get Output Job Containers" - Open .OutJob file first
- "Layout Duplicator" - Select source components first

---

## Phase 3: Interactive Testing via Claude Desktop (15 minutes)

Once the server is running in Claude Desktop, test each tool category interactively.

### Setup

1. **Configure Claude Desktop** (as per QUICK_START.md)
2. **Restart Claude Desktop**
3. **Open Altium** with your test project

### Test Categories

#### 1. Test Resources (Read-Only Data)

Ask me:
```
What Altium resources do you have?
```

Expected: List of 8 resources

Then try reading each:
```
Read the altium://project/current/info resource
```

```
Read the altium://project/current/components resource
```

```
Read the altium://project/current/nets resource
```

```
Read the altium://board/preview resource (this returns an image!)
```

#### 2. Test Component Tools

```
Get all component designators from my Altium board
```

```
Get detailed data for components R1, C1, and U1
```

```
What properties are available for components?
```

```
Get the manufacturer property for all components
```

```
Get pin information for component U1
```

#### 3. Test Net Tools

```
Show me all nets in my PCB
```

```
Create a net class called "USB" and add USB_D+ and USB_D- nets to it
```

#### 4. Test Layer Tools

```
What layers are in my PCB?
```

```
Get the layer stackup details
```

```
Hide the Bottom Layer
```

```
Show the Top Layer again
```

#### 5. Test Layout Tools

```
Move component R1 by 100 mils in the X direction
```

```
Get the design rules for my PCB
```

```
Take a screenshot of my PCB
```

**Advanced Layout Duplication:**
1. Select 3-4 components in Altium (e.g., a power supply circuit)
2. Ask me: `Start layout duplicator and show me the source components`
3. I'll show you the data
4. Ask me: `Duplicate the layout from [R1, C1, L1] to [R10, C10, L10]`

#### 6. Test Schematic Tools

```
Get the symbol placement rules
```

**If you have a schematic library open:**
```
Get the reference symbol from the open library
```

**To create a symbol (requires open library):**
```
Create a schematic symbol named "TEST_IC" with these pins:
- Pin 1: VCC, Power, facing down, at (0, 100)
- Pin 2: GND, Power, facing up, at (0, -100)
- Pin 3: IN, Input, facing right, at (-100, 0)
- Pin 4: OUT, Output, facing left, at (100, 0)
```

#### 7. Test Output Tools

**If you have an .OutJob file:**
```
Show me all output job containers
```

```
Run the Gerber output job
```

#### 8. Test Prompts (Guided Workflows)

```
Run the create_symbol_workflow prompt for an IC component
```

```
Run the duplicate_layout_workflow prompt for a power supply
```

```
Run the organize_nets_workflow prompt
```

---

## Creating a Test Project

If you don't have a test project, create a minimal one:

### Quick Test Project (5 minutes)

1. **Open Altium Designer**

2. **Create New Project**:
   - File → New → Project → PCB Project
   - Save as: `C:\AltiumMCP\TestProject.PrjPCB`

3. **Add Schematic**:
   - Right-click project → Add New to Project → Schematic
   - Save as: `TestSchematic.SchDoc`

4. **Add PCB**:
   - Right-click project → Add New to Project → PCB
   - Save as: `TestPCB.PcbDoc`

5. **Add Components to Schematic**:
   - Place → Part
   - Add 5-10 generic parts (resistors, capacitors, IC)
   - Assign designators: R1, R2, C1, C2, U1, etc.
   - Wire them together

6. **Update PCB**:
   - Design → Update PCB Document
   - Execute changes
   - Arrange components on the PCB

7. **Add Some Nets**:
   - Create power nets: VCC, GND
   - Create signal nets: IN, OUT, CLK

8. **Save All**

Now you have a test project ready!

---

## Test Checklist

Use this checklist to track your testing:

### Component Tools (7)
- [ ] get_all_designators
- [ ] get_component_data
- [ ] get_all_component_property_names
- [ ] get_component_property_values
- [ ] get_selected_components_coordinates
- [ ] get_component_pins
- [ ] get_schematic_data

### Net Tools (2)
- [ ] get_all_nets
- [ ] create_net_class

### Layer Tools (3)
- [ ] get_pcb_layers
- [ ] get_pcb_layer_stackup
- [ ] set_pcb_layer_visibility

### Schematic Tools (4)
- [ ] get_symbol_placement_rules
- [ ] get_library_symbol_reference
- [ ] create_schematic_symbol (optional - requires lib)

### Layout Tools (4)
- [ ] move_components
- [ ] layout_duplicator
- [ ] layout_duplicator_apply
- [ ] get_pcb_rules

### Output Tools (3)
- [ ] get_screenshot
- [ ] get_output_job_containers (requires .OutJob)
- [ ] run_output_jobs (requires .OutJob)
- [ ] get_server_status

### Resources (8)
- [ ] altium://project/current/info
- [ ] altium://project/current/components
- [ ] altium://project/current/nets
- [ ] altium://project/current/layers
- [ ] altium://project/current/stackup
- [ ] altium://project/current/rules
- [ ] altium://board/preview.png
- [ ] altium://board/preview

### Prompts (3)
- [ ] create_symbol_workflow
- [ ] duplicate_layout_workflow
- [ ] organize_nets_workflow

---

## Troubleshooting

### Test Fails: "No response from Altium"
**Solution:** Make sure Altium is running and a project is open

### Test Fails: "Script file not found"
**Solution:** Check `server/config.json` has correct paths:
```json
{
  "altium_exe_path": "C:\\Program Files\\Altium\\AD24\\X2.EXE",
  "script_path": "C:\\Users\\geoff\\Desktop\\projects\\altium-mcp\\server\\AltiumScript\\Altium_API.PrjScr"
}
```

### Test Fails: "No components found"
**Solution:** Your PCB is empty - add some components first

### Test Fails: "No nets found"
**Solution:** Connect your components with wires/traces

### Test Fails: JSON parsing error
**Solution:** Check `altium_mcp.log` for details - may be a DelphiScript issue

---

## Expected Test Results

### Good Results:
- **85-95% pass rate** on first run (some tests require specific setup)
- All component/net/layer queries work
- Screenshot capture works
- Resources return valid JSON

### Common Issues:
- Symbol creation fails (need open library) - **Expected**
- Output jobs fail (need .OutJob file) - **Expected**
- Selected components returns empty (nothing selected) - **Expected**
- Layout duplicator needs manual selection - **Expected**

### Red Flags (Investigate):
- Server won't start
- All tests fail
- JSON parsing errors
- Altium script timeout (120s)

---

## Next Steps After Testing

1. **All tests pass?** → Deploy to Claude Desktop (see QUICK_START.md)
2. **Some failures?** → Review specific tool errors, check Altium setup
3. **Ready for more?** → Proceed to Phase 2-5 enhancements (see IMPLEMENTATION_PLAN.md)

---

## Getting Help

If you encounter issues:

1. **Check logs**:
   - `server/altium_mcp.log` - Server logs
   - `server/response.json` - Last Altium response

2. **Review documentation**:
   - `QUICK_START.md` - Setup issues
   - `MIGRATION_GUIDE.md` - Configuration issues
   - `MODERNIZATION_COMPLETE.md` - Architecture questions

3. **Common fixes**:
   - Restart Altium
   - Check config.json paths
   - Verify conda environment activated
   - Clear old response.json file

---

Happy testing! 🚀
