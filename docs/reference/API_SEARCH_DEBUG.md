# API Search Debug Guide

## Problem
The `search_delphiscript_api` tool was hanging indefinitely when called through MCP, but works fine in standalone tests.

## Debugging Changes Made

### 1. Added Comprehensive Logging

**server/tools/api_search_tools.py:**
- Added debug logging at every step of execution
- Logs show:
  - Tool invocation with parameters
  - Database initialization timing
  - Query execution timing
  - Results formatting
  - Completion or timeout/error

**build_vector_db.py:**
- Added logging to ChromaDB initialization
- Tracks PersistentClient creation time
- Tracks collection access time
- Logs query execution with timing

### 2. Added Timeout Protection

- **DB_INIT_TIMEOUT**: 10 seconds for database initialization
- **DB_QUERY_TIMEOUT**: 5 seconds for each query
- Uses `asyncio.wait_for()` with `run_in_executor()` to wrap blocking calls

### 3. How to Debug

**When you restart Claude Code, the logs will show exactly where it's hanging:**

#### Option 1: Check the Log File
```bash
tail -f server/altium_mcp.log
```

#### Option 2: Claude Code's MCP logs
The logs should also appear in Claude Code's MCP server output since we're writing to stderr.

#### What to Look For:

**If it hangs during initialization:**
```
[TOOL] search_delphiscript_api called with query='move component'
[TOOL] Step 1: Initializing database...
[DB] Vector database not initialized, starting initialization...
[DB] Importing AltiumAPIVectorDB...
[DB] Creating ChromaDB PersistentClient...
<--- HANGS HERE --->
```
**Cause:** ChromaDB PersistentClient creation is blocking in MCP async context

**If it hangs during query:**
```
[DB] PersistentClient created in 2.51s
[VectorDB] Collection ready in 0.03s
[TOOL] Step 3: Querying database for 'move component'...
[VectorDB] Query starting: 'move component' (n_results=5, filter=None)
<--- HANGS HERE --->
```
**Cause:** ChromaDB's query method is blocking the event loop

### 4. Possible Root Causes

1. **Event Loop Conflict**
   - ChromaDB is synchronous/blocking
   - MCP tools are async
   - `run_in_executor` might not work properly in MCP's event loop

2. **Threading Issue**
   - ChromaDB uses threading internally
   - May conflict with MCP's async/await model

3. **Lazy Initialization Problem**
   - Global `_vector_db` variable initialized on first call
   - Async context issues with module-level state

### 5. Potential Fixes (After Diagnosis)

**If hanging in PersistentClient creation:**
- Pre-initialize ChromaDB at server startup (not lazily)
- Use a process pool executor instead of thread pool

**If hanging in query:**
- Switch to async wrapper for ChromaDB
- Consider alternative vector DBs with native async support (e.g., qdrant-client async mode)

**Workaround:**
- The timeout will prevent infinite hangs
- Will return error after 10s with diagnostic info

### 6. Test Locally First

Run the test to verify everything still works outside MCP:
```bash
C:/Users/geoff/anaconda3/envs/altium-mcp/python.exe test_api_timeout.py
```

Should complete in < 5 seconds and show:
```
[OK] All tests passed!
```

## Next Steps

1. Restart Claude Code to load the new logging
2. Call `search_delphiscript_api("move component")`
3. Check logs to see exactly where it hangs
4. Report back with the last log message before hang
5. We'll implement the appropriate fix based on diagnosis
