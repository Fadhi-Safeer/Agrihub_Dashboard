import subprocess
import time

def run_command_in_new_terminal(command):
    """Runs a command in a new terminal window."""
    subprocess.Popen(f'start cmd /k "{command}"', shell=True)

def main():
    ffmpeg_cmd1 = (
    'ffmpeg -rtsp_transport tcp -i "rtsp://admin_agrihub:Agrihub123@192.168.145.129:554/stream1" '
    '-an -c:v libx264 -preset veryfast -b:v 1000k -maxrate 1000k -bufsize 2000k -g 30 '
    '-hls_time 2 -hls_list_size 3 -hls_flags delete_segments -f hls C:\\\\ffmpeg\\\\hls\\\\camera1.m3u8'
)


    
    ffmpeg_cmd2 = (
        'ffmpeg -rtsp_transport tcp -i "rtsp://admin_agrihub:Agrihub123@192.168.145.72:554/stream1" '
        '-an -c:v libx264 -preset veryfast -b:v 1000k -maxrate 1000k -bufsize 2000k -g 30 '
        '-hls_time 2 -hls_list_size 3 -hls_flags delete_segments -f hls C:\\ffmpeg\\hls\\camera2.m3u8'
    )

    # Start FFmpeg processes in separate command windows
    run_command_in_new_terminal(ffmpeg_cmd1)
    run_command_in_new_terminal(ffmpeg_cmd2)
    
    # Wait for a few seconds to let the streams initialize
    time.sleep(5)

    # Start the Node.js server in a new command window
    node_server_cmd = 'cd C:\\ffmpeg && node server.js'
    run_command_in_new_terminal(node_server_cmd)

if __name__ == "__main__":
    main()
