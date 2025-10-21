import subprocess
import time
import os

def run_command_in_new_terminal(command):
    """Runs a command in a new terminal window."""
    subprocess.Popen(f'start cmd /k "{command}"', shell=True)

def main():
    # Ensure output directory exists
    os.makedirs(r"C:\ffmpeg\hls", exist_ok=True)

    # FFmpeg command for a single camera
    ffmpeg_cmd = (
        'ffmpeg -rtsp_transport tcp -i '
        '"rtsp://Agrihub_Cam:Agrihub2025@10.112.56.49:554/stream1" '
        '-an -c:v libx264 -preset veryfast -b:v 1000k -maxrate 1000k '
        '-bufsize 2000k -g 30 -hls_time 2 -hls_list_size 3 '
        '-hls_flags delete_segments -f hls C:\\\\ffmpeg\\\\hls\\\\camera1.m3u8'
    )

    # Run the FFmpeg command in a new terminal
    run_command_in_new_terminal(ffmpeg_cmd)

    # Optional: Wait before starting Node.js server
    time.sleep(5)
    node_server_cmd = 'cd C:\\ffmpeg && node server.js'
    run_command_in_new_terminal(node_server_cmd)

if __name__ == "__main__":
    main()
