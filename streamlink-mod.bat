@echo off
setlocal

REM Ensure we are running in the user's home directory
cd %HOMEPATH%

REM Ensure Python and pip are available
where python >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Python is not installed. Please install Python first.
    exit /b 1
)

where pip >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo pip is not installed. Please install pip first.
    exit /b 1
)

REM Install psutil
echo Installing psutil...
pip install psutil

REM Create the scripts directory if it does not exist
if not exist "%HOMEPATH%\scripts" (
    echo Creating scripts directory...
    mkdir "%HOMEPATH%\scripts"
)

REM Create the streamlink-mod.py script
echo Creating streamlink-mod.py...
(
    echo import os
    echo import time
    echo import subprocess
    echo import signal
    echo import sys
    echo import psutil
    echo.
    echo process = None
    echo.
    echo def start_streamlink(url, filename):
    echo.    global process
    echo.    streamlink_cmd = f"streamlink ^{url^} best -o ^{filename^}"
    echo.    try:
    echo.        print(f"Starting streamlink with command: ^{streamlink_cmd^}")
    echo.        process = subprocess.Popen(streamlink_cmd, shell=True)
    echo.    except Exception as e:
    echo.        print(f"Failed to start streamlink: ^{e^}")
    echo.
    echo def terminate_process_and_children(pid):
    echo.    try:
    echo.        parent = psutil.Process(pid)
    echo.        print(f"Terminating parent process ^{pid^}")
    echo.        for child in parent.children(recursive=True):
    echo.            print(f"Terminating child process ^{child.pid^}")
    echo.            child.terminate()
    echo.        parent.terminate()
    echo.        gone, still_alive = psutil.wait_procs([parent], timeout=5)
    echo.        for p in still_alive:
    echo.            print(f"Killing unresponsive process ^{p.pid^}")
    echo.            p.kill()
    echo.    except psutil.NoSuchProcess:
    echo.        print(f"No such process: ^{pid^}")
    echo.
    echo def signal_handler(sig, frame):
    echo.    print('Signal handler invoked: Stopping the monitor...')
    echo.    if process:
    echo.        terminate_process_and_children(process.pid)
    echo.    sys.exit(0)
    echo.
    echo def streamlink-mod(url, filename):
    echo.    global process
    echo.    signal.signal(signal.SIGINT, signal_handler)
    echo.
    echo.    start_streamlink(url, filename)
    echo.
    echo.    while True:
    echo.        time.sleep(1)
    echo.
    echo if __name__ == "__main__":
    echo.    if len(sys.argv) != 3:
    echo.        print("Usage: python streamlink-mod.py <URL> <FILENAME>")
    echo.        sys.exit(1)
    echo.
    echo.    url = sys.argv[1]
    echo.    filename = sys.argv[2]
    echo.
    echo.    print(f"Monitoring stream with URL: ^{url^} and filename: ^{filename^}")
    echo.    streamlink-mod(url, filename)
) > "%HOMEPATH%\scripts\streamlink-mod.py"

REM Check if the Python script was created
if exist "%HOMEPATH%\scripts\streamlink-mod.py" (
    echo streamlink-mod.py created successfully.
) else (
    echo Failed to create streamlink-mod.py.
    exit /b 1
)

REM Append the streamlink-mod function to the bash.bashrc file
echo Adding streamlink-mod function to bash.bashrc...
(
    echo.
    echo function streamlink-mod() {
    echo.    action=$1
    echo.    url=$2
    echo.    filename=$3
    echo.    pidfile="/tmp/streamlink-mod.pid"
    echo.
    echo.    stop_monitor() {
    echo.        if [ -f $pidfile ]; then
    echo.            pid=$(cat $pidfile)
    echo.            if ps -p $pid > /dev/null; then
    echo.                kill $pid && rm -f $pidfile
    echo.                echo "Monitor stopped"
    echo.            else
    echo.                rm -f $pidfile
    echo.            fi
    echo.        fi
    echo.    }
    echo.
    echo.    case $action in
    echo.        start)
    echo.            if [ "$#" -ne 3 ]; then
    echo.                echo "Usage: streamlink-mod start <URL> <FILENAME>"
    echo.                return 1
    echo.            fi
    echo.
    echo.            stop_monitor
    echo.
    echo.            python %HOMEPATH%/scripts/streamlink-mod.py "$url" "$filename" &
    echo.            echo $! > $pidfile
    echo.            echo "Monitor started"
    echo.            ;;
    echo.        stop)
    echo.            if [ "$#" -ne 1 ]; then
    echo.                echo "Usage: streamlink-mod stop"
    echo.                return 1
    echo.            fi
    echo.            stop_monitor
    echo.            echo "Monitor stopped"
    echo.            ;;
    echo.        *)
    echo.            echo "Usage: streamlink-mod start <URL> <FILENAME> | streamlink-mod stop"
    echo.            return 1
    echo.            ;;
    echo.    esac
    echo }
) >> "C:\Program Files\Git\etc\bash.bashrc"

REM Check if the bash.bashrc file was updated
findstr /c:"function streamlink-mod" "C:\Program Files\Git\etc\bash.bashrc" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Failed to update bash.bashrc.
    exit /b 1
) else (
    echo bash.bashrc updated successfully.
)

REM Inform the user to restart Git Bash
echo.
echo Please restart Git Bash to apply the changes.
echo Installation complete. You can now use the streamlink-mod function.

endlocal
