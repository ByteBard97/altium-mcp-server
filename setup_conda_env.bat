@echo off
echo ============================================================================
echo Creating Altium MCP v2.0 Conda Environment
echo ============================================================================

echo.
echo Step 1: Creating conda environment 'altium-mcp-v2' with Python 3.11...
call conda create -n altium-mcp-v2 python=3.11 -y

if errorlevel 1 (
    echo ERROR: Failed to create conda environment
    pause
    exit /b 1
)

echo.
echo Step 2: Activating environment...
call conda activate altium-mcp-v2

if errorlevel 1 (
    echo ERROR: Failed to activate conda environment
    pause
    exit /b 1
)

echo.
echo Step 3: Installing dependencies...
pip install mcp>=1.21.0
pip install pywin32>=310
pip install pillow>=11.1.0
pip install pytest>=7.4.0
pip install pytest-asyncio>=0.21.0
pip install black>=23.0.0

if errorlevel 1 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)

echo.
echo ============================================================================
echo Environment setup complete!
echo ============================================================================
echo.
echo To use this environment:
echo   1. Run: conda activate altium-mcp-v2
echo   2. Test: cd server ^&^& python test_server.py
echo   3. Start server: cd server ^&^& python main.py
echo.
pause
