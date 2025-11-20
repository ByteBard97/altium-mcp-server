@echo off
echo ================================================
echo Starting PowerSplit Development Environment
echo ================================================
echo.

REM Store original directory
set "ORIGINAL_DIR=%cd%"

REM Set paths
set "ALTIUM_MCP_DIR=C:\Users\geoff\Desktop\projects\altium-mcp\server"
set "FRONTEND_DIR=C:\Users\geoff\Desktop\projects\PCBTools\frontend"
set "PYTHON_EXE=C:\Users\geoff\anaconda3\envs\altium-mcp-v2\python.exe"

REM Check if Python exists
if not exist "%PYTHON_EXE%" (
    echo ERROR: Python executable not found at %PYTHON_EXE%
    pause
    exit /b 1
)

REM Check if directories exist
if not exist "%ALTIUM_MCP_DIR%" (
    echo ERROR: Altium MCP directory not found at %ALTIUM_MCP_DIR%
    pause
    exit /b 1
)

if not exist "%FRONTEND_DIR%" (
    echo ERROR: Frontend directory not found at %FRONTEND_DIR%
    pause
    exit /b 1
)

echo [1/2] Starting Altium HTTP Bridge on port 8001...
cd /d "%ALTIUM_MCP_DIR%"
start "Altium HTTP Bridge" "%PYTHON_EXE%" http_bridge_fixed.py
echo     HTTP Bridge started in new window
echo.

REM Wait a moment for the bridge to start
timeout /t 3 /nobreak >nul

echo [2/2] Starting PowerSplit Frontend on port 5173...
cd /d "%FRONTEND_DIR%"
start "PowerSplit Frontend" cmd /k "npm run dev"
echo     Frontend started in new window
echo.

echo ================================================
echo PowerSplit Development Environment Started!
echo ================================================
echo.
echo Services running:
echo   - Altium HTTP Bridge: http://localhost:8001
echo   - PowerSplit Frontend: http://localhost:5173
echo.
echo To stop services, close the respective windows
echo or press Ctrl+C in each window.
echo.

REM Return to original directory
cd /d "%ORIGINAL_DIR%"

echo Press any key to exit this launcher...
pause >nul
