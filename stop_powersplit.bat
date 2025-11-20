@echo off
echo ================================================
echo Stopping PowerSplit Development Environment
echo ================================================
echo.

echo [1/2] Stopping Altium HTTP Bridge (port 8001)...
REM Find and kill Python process running on port 8001
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8001"') do (
    echo     Killing process %%a
    taskkill /F /PID %%a >nul 2>&1
)
echo     HTTP Bridge stopped
echo.

echo [2/2] Stopping PowerSplit Frontend (port 5173)...
REM Find and kill Node process running on port 5173
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":5173"') do (
    echo     Killing process %%a
    taskkill /F /PID %%a >nul 2>&1
)
echo     Frontend stopped
echo.

echo ================================================
echo PowerSplit Development Environment Stopped!
echo ================================================
echo.
pause
