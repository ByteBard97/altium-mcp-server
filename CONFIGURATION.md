# Configuration Guide

This guide explains how to configure the Altium MCP Server for different use cases.

## For End Users (Recommended)

**Use the DXT Extension**

1. Download the `.dxt` file from releases
2. Install via Claude Desktop: `File > Settings > Extensions > Advanced > Install Extension...`
3. No additional configuration needed!

See [README.md](README.md#installing-the-mcp-server) for details.

---

## For Developers (Standalone MCP Server)

### Option 1: Local Development/Testing

**Use Case**: Testing the server locally from the project directory.

1. **Copy the example file**:
   ```bash
   cp .mcp.json.example .mcp.json
   ```

2. **Edit `.mcp.json`**:
   - Replace `YOUR_USERNAME` with your Windows username
   - Update paths if your project is in a different location

3. **Setup environment**:
   ```bash
   setup_conda_env.bat
   ```

4. **Test**:
   ```bash
   cd server
   python quick_test.py
   ```

**Note**: `.mcp.json` is git-ignored and should NOT be committed.

---

### Option 2: Claude Desktop (Standalone Server)

**Use Case**: Running the server via Claude Desktop config (not as DXT extension).

1. **Copy the example file**:
   ```bash
   cp claude_desktop_config.example.json %APPDATA%\Claude\claude_desktop_config.json
   ```

2. **Edit the config**:
   - Replace `YOUR_USERNAME` with your Windows username
   - Update the absolute path to your project location

3. **Setup environment**:
   ```bash
   setup_conda_env.bat
   ```

4. **Restart Claude Desktop**

See [QUICK_START.md](QUICK_START.md) for detailed instructions.

---

## Configuration Files Explained

| File | Purpose | Should Commit? |
|------|---------|----------------|
| `.mcp.json.example` | Template for local development | ✅ Yes |
| `claude_desktop_config.example.json` | Template for Claude Desktop | ✅ Yes |
| `.mcp.json` | Your local config (user-specific) | ❌ No (git-ignored) |
| `%APPDATA%\Claude\claude_desktop_config.json` | Claude Desktop config | ❌ No (system file) |

---

## Example: .mcp.json (Local Development)

```json
{
  "mcpServers": {
    "altium": {
      "command": "C:\\Users\\YOUR_USERNAME\\anaconda3\\envs\\altium-mcp-v2\\python.exe",
      "args": ["server/main.py"],
      "description": "Altium Designer MCP Server - AI-assisted PCB design with FastMCP 2.0",
      "env": {
        "PYTHONUNBUFFERED": "1"
      }
    }
  }
}
```

**Key Points**:
- Uses relative path for `args` (relative to project root)
- Good for development/testing from project directory

---

## Example: claude_desktop_config.json (Production)

```json
{
  "mcpServers": {
    "altium": {
      "command": "C:\\Users\\YOUR_USERNAME\\anaconda3\\envs\\altium-mcp-v2\\python.exe",
      "args": [
        "C:\\Users\\YOUR_USERNAME\\Desktop\\projects\\altium-mcp\\server\\main.py"
      ],
      "env": {
        "PYTHONUNBUFFERED": "1"
      }
    }
  }
}
```

**Key Points**:
- Uses absolute path for `args`
- Required for Claude Desktop to find the server
- Located at: `%APPDATA%\Claude\claude_desktop_config.json`

---

## Environment Variables

All configurations support these environment variables:

| Variable | Purpose | Default |
|----------|---------|---------|
| `PYTHONUNBUFFERED` | Disable Python output buffering | `"1"` |

---

## Troubleshooting

### Claude Desktop can't find the server

**Check**:
1. Verify Python path: `where python` in conda environment
2. Verify paths use double backslashes: `\\` not `\`
3. Check config JSON is valid (use a JSON validator)

### Server starts but can't connect to Altium

**Check**:
1. Altium Designer is running
2. A PCB project (`.PrjPcb`) is open
3. Review `server/altium_mcp.log` for errors

### Tests fail

**Check**:
1. Conda environment is activated: `conda activate altium-mcp-v2`
2. Dependencies installed: `pip list | findstr mcp`
3. Altium is open with a project loaded

---

## Next Steps

- **First time setup**: See [QUICK_START.md](QUICK_START.md)
- **Migration from v1.x**: See [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)
- **Creating a DXT package**: See [README.md](README.md#creating-a-new-dxt-for-developers)
