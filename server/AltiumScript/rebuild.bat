@echo off
REM Rebuild Altium Script
REM This script rebuilds the Altium_API.pas file and reminds you to compile in Altium

echo.
echo ============================================
echo Rebuilding Altium Script
echo ============================================
echo.

python build_script.py

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Build failed!
    pause
    exit /b 1
)

echo.
echo ============================================
echo Build Complete!
echo ============================================
echo.
echo NEXT STEP: Compile in Altium Designer
echo.
echo   1. Switch to Altium Designer
echo   2. Press F9 (or click Compile)
echo   3. Verify "Compile successful"
echo.
echo ============================================
echo.

REM Optional: Try to bring Altium to foreground (if it's running)
powershell -command "$wshell = New-Object -ComObject wscript.shell; try { $wshell.AppActivate('Altium Designer') } catch {}"

pause
