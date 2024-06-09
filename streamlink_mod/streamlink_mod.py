import os
import time
import subprocess
import sys
import psutil

process = None
file_counter = 1


def start_streamlink(url, filename):
    global process
    global file_counter
    current_filename = (
        f"{os.path.splitext(filename)[0]}_{file_counter}{os.path.splitext(filename)[1]}"
    )
    streamlink_cmd = f"streamlink {url} best -o {current_filename}"
    try:
        print(f"Starting streamlink with command: {streamlink_cmd}")
        process = subprocess.Popen(streamlink_cmd, shell=True)
        file_counter += 1
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


def monitor_streamlink(url, filename):
    global process
    try:
        start_streamlink(url, filename)
        while True:
            time.sleep(10)  # Check every 10 seconds
            if process.poll() is not None:  # If the process has terminated
                print("Streamlink process has stopped. Restarting...")
                start_streamlink(url, filename)
    except KeyboardInterrupt:
        if process:
            print("Interrupted! Stopping the streamlink process...")
            terminate_process_and_children(process.pid)
        sys.exit(0)


def main():
    if len(sys.argv) != 3:
        print("Usage: streamlink_mod <URL> <FILENAME>")
        sys.exit(1)
    url = sys.argv[1]
    filename = sys.argv[2]
    print(f"Monitoring stream with URL: {url} and filename: {filename}")
    monitor_streamlink(url, filename)


if __name__ == "__main__":
    main()
