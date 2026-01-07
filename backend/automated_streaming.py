import subprocess
import time
import os

def run_command_in_new_terminal(command):
    """Runs a command in a new terminal window."""
    subprocess.Popen(f'start cmd /k "{command}"', shell=True,cwd= "C:\\ffmpeg")

def main():
    # Ensure output directory exists
    os.makedirs(r"C:\ffmpeg\hls", exist_ok=True)

    # FFmpeg commands for 14 cameras (you can replace the IPs later)
    ffmpeg_cmd1 = (
        'ffmpeg -rtsp_transport tcp -i "rtsp://Agrihub_Cam:Agrihub2025@10.130.1.202:554/stream1" '
        '-an -c:v libx264 -preset veryfast -b:v 1000k -maxrate 1000k -bufsize 2000k -g 30 '
        '-hls_time 2 -hls_list_size 3 -hls_flags delete_segments -f hls C:\\\\ffmpeg\\\\hls\\\\camera1.m3u8'
    )
    ffmpeg_cmd2 = (
        'ffmpeg -rtsp_transport tcp -i "rtsp://Agrihub_Cam:Agrihub2025@10.130.1.227:554/stream1" '
        '-an -c:v libx264 -preset veryfast -b:v 1000k -maxrate 1000k -bufsize 2000k -g 30 '
        '-hls_time 2 -hls_list_size 3 -hls_flags delete_segments -f hls C:\\\\ffmpeg\\\\hls\\\\camera2.m3u8'
    )
    ffmpeg_cmd3 = (
        'ffmpeg -rtsp_transport tcp -i "rtsp://Agrihub_Cam:Agrihub2025@10.130.1.235:554/stream1" '
        '-an -c:v libx264 -preset veryfast -b:v 1000k -maxrate 1000k -bufsize 2000k -g 30 '
        '-hls_time 2 -hls_list_size 3 -hls_flags delete_segments -f hls C:\\\\ffmpeg\\\\hls\\\\camera3.m3u8'
    )
    ffmpeg_cmd4 = (
        'ffmpeg -rtsp_transport tcp -i "rtsp://Agrihub_Cam:Agrihub2025@10.130.1.207:554/stream1" '
        '-an -c:v libx264 -preset veryfast -b:v 1000k -maxrate 1000k -bufsize 2000k -g 30 '
        '-hls_time 2 -hls_list_size 3 -hls_flags delete_segments -f hls C:\\\\ffmpeg\\\\hls\\\\camera4.m3u8'
    )
    ffmpeg_cmd5 = (
        'ffmpeg -rtsp_transport tcp -i "rtsp://Agrihub_Cam:Agrihub2025@10.130.1.219:554/stream1" '
        '-an -c:v libx264 -preset veryfast -b:v 1000k -maxrate 1000k -bufsize 2000k -g 30 '
        '-hls_time 2 -hls_list_size 3 -hls_flags delete_segments -f hls C:\\\\ffmpeg\\\\hls\\\\camera5.m3u8'
    )


    # Run all camera commands
    run_command_in_new_terminal(ffmpeg_cmd1)
    run_command_in_new_terminal(ffmpeg_cmd2)
    run_command_in_new_terminal(ffmpeg_cmd3)
    run_command_in_new_terminal(ffmpeg_cmd4)
    run_command_in_new_terminal(ffmpeg_cmd5)


    # Wait before starting Node server
    time.sleep(5)

    node_server_cmd = 'node server.js'
    run_command_in_new_terminal(node_server_cmd)

if __name__ == "__main__":
    main()
