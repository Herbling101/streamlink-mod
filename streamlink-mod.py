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
    print("Signal handler invoked: Stopping the monitor...")
    if process:
        terminate_process_and_children(process.pid)
    sys.exit(0)


def streamlink_mod(url, filename):
    global process
    signal.signal(signal.SIGINT, signal_handler)

    start_streamlink(url, filename)

    while True:
        time.sleep(1)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python streamlink_mod.py <URL> <FILENAME>")
        sys.exit(1)

    url = sys.argv[1]
    filename = sys.argv[2]

    print(f"Monitoring stream with URL: {url} and filename: {filename}")
    streamlink_mod(url, filename)
