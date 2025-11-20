# PowerSplit QuickStart Guide

## Starting the Development Environment

Simply double-click **`start_powersplit.bat`** to launch both services:

1. **Altium HTTP Bridge** - Runs on `http://localhost:8001`
2. **PowerSplit Frontend** - Runs on `http://localhost:5173`

Each service opens in its own terminal window.

## Stopping the Development Environment

Double-click **`stop_powersplit.bat`** to cleanly shut down both services.

## Testing the Integration

1. **Start PowerSplit**: Double-click `start_powersplit.bat`
2. **Open your browser**: Navigate to `http://localhost:5173`
3. **Open Altium Designer**: Make sure your PCB project is open
4. **Import from Altium**:
   - Click "Connect" in the PowerSplit panel
   - Click "Import from Altium" button
5. **Test zoom/pan**:
   - The layer bands should now respond to mouse wheel zoom
   - Drag the canvas to pan - bands should move with the view

## Architecture

```
┌─────────────────────────────────────────────┐
│         Browser (localhost:5173)            │
│         PowerSplit Vue.js Frontend          │
│                                             │
│  ┌────────────────────────────────────┐    │
│  │  PixiJS Canvas (WorldContainer)    │    │
│  │  ├─ VoronoiRenderer (layer bands)  │    │
│  │  ├─ Board outline                  │    │
│  │  └─ Component markers              │    │
│  └────────────────────────────────────┘    │
└──────────────┬──────────────────────────────┘
               │ HTTP POST
               │ /api/extract-board
               ↓
┌──────────────────────────────────────────────┐
│    Python HTTP Bridge (localhost:8001)       │
│    FastAPI + CORS                            │
└──────────────┬───────────────────────────────┘
               │ AltiumBridge
               │ TCP/JSON-RPC
               ↓
┌──────────────────────────────────────────────┐
│    Altium Designer (localhost:3000)          │
│    Pascal Script Server                      │
│    - Get nets, components, layers            │
│    - Get board outline                       │
└──────────────────────────────────────────────┘
```

## Troubleshooting

### Bridge won't start
- Check that Python environment exists: `C:\Users\geoff\anaconda3\envs\altium-mcp-v2\python.exe`
- Verify port 8001 is available: `netstat -ano | findstr ":8001"`

### Frontend won't start
- Check that Node.js is installed: `node --version`
- Verify port 5173 is available: `netstat -ano | findstr ":5173"`
- Run `npm install` in the frontend directory if dependencies are missing

### Layer bands don't respond to zoom
- This should be fixed now! LayerManager now adds layers to worldContainer
- Check browser console for errors (F12)
- Verify data was imported successfully (check console logs)

### Import fails
- Ensure Altium Designer is running with a PCB document open
- Check that Altium MCP server is running (should auto-start with Altium)
- Verify HTTP bridge can reach Altium: Open `http://localhost:8001/` in browser

## Recent Fixes

### 2024-11-20: Fixed Coordinate Space Issue
**Problem**: Layer bands were rendered in screen-space and didn't respond to zoom/pan.

**Solution**: Modified `LayerManager` to accept `worldContainer` as parent instead of `app.stage`. This ensures PowerSplit layers inherit all viewport transforms.

**Files Changed**:
- `PCBTools/frontend/src/cad/layers/LayerManager.ts` - Added `parentContainer` parameter
- `PCBTools/frontend/src/views/CADEditorView.vue` - Pass `worldContainer` to LayerManager
