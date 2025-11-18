# Quick Start - Altium MCP v2.0

## 1. Setup Environment (5 minutes)

### Option A: Automated Setup (Recommended)
```bash
# Run the setup script from project root
setup_conda_env.bat
```

### Option B: Manual Setup
```bash
# Create environment
conda create -n altium-mcp-v2 python=3.11 -y

# Activate environment
conda activate altium-mcp-v2

# Install dependencies
pip install -r requirements.txt
```

## 2. Verify Installation (1 minute)

```bash
# Navigate to server directory
cd server

# Run tests
python test_server.py
```

**Expected Result**: ✅ All tests passed!

## 3. Update Claude Desktop Config (2 minutes)

**File Location**: `%APPDATA%\Claude\claude_desktop_config.json`

**Update this**:
```json
{
  "mcpServers": {
    "altium": {
      "command": "C:\\Users\\YOUR_USERNAME\\anaconda3\\envs\\altium-mcp-v2\\python.exe",
      "args": [
        "C:\\Users\\YOUR_USERNAME\\Desktop\\projects\\altium-mcp\\server\\main.py"
      ]
    }
  }
}
```

**Replace**:
- `YOUR_USERNAME` with your Windows username
- Path to match your project location

## 4. Restart Claude Desktop (30 seconds)

Close and reopen Claude Desktop to load the new server.

## 5. Test with Claude (2 minutes)

### Test 1: Check Resources
**You**: "What resources do you have available for Altium?"

**Claude should see**: 8 resources including:
- altium://project/current/components
- altium://project/current/nets
- altium://board/preview.png

### Test 2: Use a Resource
**You**: "Read the components resource"

**Claude should**: Access `altium://project/current/components` and show component data

### Test 3: Call a Tool
**You**: "Get all designators from my board"

**Claude should**: Call `get_all_designators()` tool

## 6. Try a Workflow Prompt (2 minutes)

**You**: "Help me create a schematic symbol"

**Claude should**: Execute the `create_symbol_workflow` prompt and guide you step-by-step

---

## Troubleshooting

### Tests Fail
```bash
# Make sure environment is activated
conda activate altium-mcp-v2

# Verify dependencies
pip list | findstr mcp
# Should show: mcp 1.5.0 or higher
```

### Claude Can't Connect
1. Check config file syntax (valid JSON)
2. Verify paths use double backslashes (`\\`)
3. Confirm Python executable path:
   ```bash
   conda activate altium-mcp-v2
   where python
   # Use this path in config
   ```

### Server Starts But Tools Don't Work
1. Open Altium Designer
2. Load a project (`.PrjPcb`)
3. Check `server/config.json` has valid paths
4. Review `altium_mcp.log` for errors

---

## What's New in v2.0

### Resources (8 total)
Claude can now proactively read project state:
- Project info, components, nets, layers, stackup, rules
- Board preview images

### Prompts (3 total)
Guided workflows for common tasks:
- Symbol creation
- Layout duplication
- Net organization

### All Tools Preserved (23 total)
Every existing tool still works the same way.

---

## Quick Reference

### Project Structure
```
server/
├── main.py              # Entry point
├── altium_bridge.py     # Bridge to Altium
├── resources/           # 8 resources
├── tools/               # 23 tools
└── prompts/             # 3 workflows
```

### Log Files
- `altium_mcp.log` - Server logs
- `request.json` - Last command sent to Altium
- `response.json` - Last response from Altium

### Configuration
- `config.json` - Altium paths
- `claude_desktop_config.json` - Claude Desktop config

---

## Next Steps

1. ✅ Complete the 6 steps above
2. 📖 Read `MIGRATION_GUIDE.md` for full details
3. 🧪 Try asking Claude to organize your nets
4. 🎨 Use a workflow prompt to create a symbol
5. 🚀 Build your own tools/resources/prompts

---

## Need Help?

- **Migration issues**: See `MIGRATION_GUIDE.md`
- **Architecture questions**: See `ARCHITECTURE_MODERNIZATION.md`
- **Test failures**: Run `python test_server.py` and check logs
- **Rollback**: `copy main.py.backup main.py`

**Estimated setup time**: 10-15 minutes

Good luck! 🎉
