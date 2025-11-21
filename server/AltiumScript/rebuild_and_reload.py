"""
Quick script to rebuild Altium_API.pas and automatically reload it in Altium
"""
import subprocess
import sys
from pathlib import Path

def main():
    script_dir = Path(__file__).parent
    build_script = script_dir / "build_script.py"

    # Step 1: Build the script
    print("\n" + "="*60)
    print("REBUILDING ALTIUM SCRIPT")
    print("="*60)

    result = subprocess.run(
        [sys.executable, str(build_script)],
        cwd=str(script_dir),
        capture_output=False  # Show output directly
    )

    if result.returncode != 0:
        print("\n[ERROR] Build failed!")
        return 1

    # Step 2: Send F9 to Altium
    print("\n" + "="*60)
    print("AUTO-RELOADING IN ALTIUM")
    print("="*60)

    ps_script = '''
    Add-Type -AssemblyName System.Windows.Forms
    $wshell = New-Object -ComObject wscript.shell
    if ($wshell.AppActivate('Altium Designer')) {
        Start-Sleep -Milliseconds 500
        [System.Windows.Forms.SendKeys]::SendWait('{F9}')
        Write-Output '[OK] Sent F9 to Altium Designer - script should recompile automatically'
    } else {
        Write-Output '[WARNING] Could not activate Altium Designer window'
        Write-Output 'Please manually press F9 in Altium to reload the script'
    }
    '''

    subprocess.run(["powershell", "-Command", ps_script])

    print("\n" + "="*60)
    print("DONE!")
    print("="*60)
    print()

    return 0

if __name__ == "__main__":
    sys.exit(main())
