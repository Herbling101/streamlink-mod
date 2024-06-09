# Ensure the user is running the script with Administrator privileges
if (-not [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator"
    exit 1
}

# Ensure Python and pip are available
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Error "Python is not installed. Please install Python first."
    exit 1
}

if (-not (Get-Command pip -ErrorAction SilentlyContinue)) {
    Write-Error "pip is not installed. Please install pip first."
    exit 1
}

# Install psutil
Write-Output "Installing psutil..."
pip install psutil

# Create the scripts directory if it does not exist
$homePath = [Environment]::GetFolderPath('UserProfile')
$scriptsPath = Join-Path -Path $homePath -ChildPath 'scripts'
if (-not (Test-Path -Path $scriptsPath)) {
    Write-Output "Creating scripts directory..."
    New-Item -ItemType Directory -Path $scriptsPath
}

# Create the monitor_streamlink.py script
$pythonScriptPath = Join-Path -Path $scriptsPath -ChildPath 'monitor_streamlink.py'
Write-Output "Creating monitor_streamlink.py..."
@'
import os
import time
import subprocess
import signal
import sys
import psutil

process = None

def start_streamlink(url, filename):
    global process
    streamlink_cmd = f"streamlink {url} best -o {filename}"
    try:
        print(f"Starting streamlink with command: {streamlink_cmd}")
        process = subprocess.Popen(streamlink_cmd, shell=True)
    except Exception as e:
        print(f"Failed to start streamlink: {e}")

def terminate_process_and_children(pid):
    try:
        parent = psutil.Process(pid)
        print(f"Terminating parent process {pid}")
        for child in parent.children(recursive=True):
            print(f"Terminating child process {child.pid}")
            child.terminate()
        parent.terminate()
        gone, still_alive = psutil.wait_procs([parent], timeout=5)
        for p in still_alive:
            print(f"Killing unresponsive process {p.pid}")
            p.kill()
    except psutil.NoSuchProcess:
        print(f"No such process: {pid}")

def signal_handler(sig, frame):
    print('Signal handler invoked: Stopping the monitor...')
    if process:
        terminate_process_and_children(process.pid)
    sys.exit(0)

def monitor_streamlink(url, filename):
    global process
    signal.signal(signal.SIGINT, signal_handler)

    start_streamlink(url, filename)

    while True:
        time.sleep(1)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python monitor_streamlink.py <URL> <FILENAME>")
        sys.exit(1)

    url = sys.argv[1]
    filename = sys.argv[2]

    print(f"Monitoring stream with URL: {url} and filename: {filename}")
    monitor_streamlink(url, filename)
'@ | Out-File -FilePath $pythonScriptPath -Encoding UTF8

# Verify the Python script was created
if (-not (Test-Path -Path $pythonScriptPath)) {
    Write-Error "Failed to create monitor_streamlink.py."
    exit 1
} else {
    Write-Output "monitor_streamlink.py created successfully."
}

# Append the monitor_streamlink function to the bash.bashrc file
$bashrcPath = 'C:\Program Files\Git\etc\bash.bashrc'
$functionText = @"
function monitor_streamlink() {
    action=\$1
    url=\$2
    filename=\$3
    pidfile="/tmp/monitor_streamlink.pid"

    stop_monitor() {
        if [ -f \$pidfile ]; then
            pid=\$(cat \$pidfile)
            if ps -p \$pid > /dev/null; then
                kill \$pid && rm -f \$pidfile
                echo "Monitor stopped"
            else
                rm -f \$pidfile
            fi
        fi
    }

    case \$action in
        start)
            if [ "\$#" -ne 3 ]; then
                echo "Usage: monitor_streamlink start <URL> <FILENAME>"
                return 1
            fi

            stop_monitor

            python $pythonScriptPath "\$url" "\$filename" &
            echo \$! > \$pidfile
            echo "Monitor started"
            ;;
        stop)
            if [ "\$#" -ne 1 ]; then
                echo "Usage: monitor_streamlink stop"
                return 1
            fi
            stop_monitor
            echo "Monitor stopped"
            ;;
        *)
            echo "Usage: monitor_streamlink start <URL> <FILENAME> | monitor_streamlink stop"
            return 1
            ;;
    esac
}
"@

Write-Output "Adding monitor_streamlink function to bash.bashrc..."
Add-Content -Path $bashrcPath -Value $functionText

# Verify the bash.bashrc file was updated
if (-not (Select-String -Path $bashrcPath -Pattern "function monitor_streamlink")) {
    Write-Error "Failed to update bash.bashrc."
    exit 1
} else {
    Write-Output "bash.bashrc updated successfully."
}

# Inform the user to restart Git Bash
Write-Output
Write-Output "Please restart Git Bash to apply the changes."
Write-Output "Installation complete. You can now use the monitor_streamlink function."

exit 0
