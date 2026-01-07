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
    ffmpeg_cmd6 = (
        'ffmpeg -rtsp_transport tcp -i "rtsp://Agrihub_Cam:Agrihub2025@10.130.1.232:554/stream1" '
        '-an -c:v libx264 -preset veryfast -b:v 1000k -maxrate 1000k -bufsize 2000k -g 30 '
        '-hls_time 2 -hls_list_size 3 -hls_flags delete_segments -f hls C:\\\\ffmpeg\\\\hls\\\\camera6.m3u8'
    )
    ffmpeg_cmd7 = (
        'ffmpeg -rtsp_transport tcp -i "rtsp://Agrihub_Cam:Agrihub2025@10.130.1.233:554/stream1" '
        '-an -c:v libx264 -preset veryfast -b:v 1000k -maxrate 1000k -bufsize 2000k -g 30 '
        '-hls_time 2 -hls_list_size 3 -hls_flags delete_segments -f hls C:\\\\ffmpeg\\\\hls\\\\camera7.m3u8'
    )
    ffmpeg_cmd8 = (
        'ffmpeg -rtsp_transport tcp -i "rtsp://Agrihub_Cam:Agrihub2025@10.130.1.229:554/stream1" '
        '-an -c:v libx264 -preset veryfast -b:v 1000k -maxrate 1000k -bufsize 2000k -g 30 '
        '-hls_time 2 -hls_list_size 3 -hls_flags delete_segments -f hls C:\\\\ffmpeg\\\\hls\\\\camera8.m3u8'
    )
    ffmpeg_cmd9 = (
        'ffmpeg -rtsp_transport tcp -i "rtsp://Agrihub_Cam:Agrihub2025@10.130.1.206:554/stream1" '
        '-an -c:v libx264 -preset veryfast -b:v 1000k -maxrate 1000k -bufsize 2000k -g 30 '
        '-hls_time 2 -hls_list_size 3 -hls_flags delete_segments -f hls C:\\\\ffmpeg\\\\hls\\\\camera9.m3u8'
    )
    ffmpeg_cmd10 = (
        'ffmpeg -rtsp_transport tcp -i "rtsp://Agrihub_Cam:Agrihub2025@10.130.1.205:554/stream1" '
        '-an -c:v libx264 -preset veryfast -b:v 1000k -maxrate 1000k -bufsize 2000k -g 30 '
        '-hls_time 2 -hls_list_size 3 -hls_flags delete_segments -f hls C:\\\\ffmpeg\\\\hls\\\\camera10.m3u8'
    )
    ffmpeg_cmd11 = (
        'ffmpeg -rtsp_transport tcp -i "rtsp://Agrihub_Cam:Agrihub2025@10.130.1.225:554/stream1" '
        '-an -c:v libx264 -preset veryfast -b:v 1000k -maxrate 1000k -bufsize 2000k -g 30 '
        '-hls_time 2 -hls_list_size 3 -hls_flags delete_segments -f hls C:\\\\ffmpeg\\\\hls\\\\camera11.m3u8'
    )
    ffmpeg_cmd12 = (
        'ffmpeg -rtsp_transport tcp -i "rtsp://Agrihub_Cam:Agrihub2025@10.130.1.239:554/stream1" '
        '-an -c:v libx264 -preset veryfast -b:v 1000k -maxrate 1000k -bufsize 2000k -g 30 '
        '-hls_time 2 -hls_list_size 3 -hls_flags delete_segments -f hls C:\\\\ffmpeg\\\\hls\\\\camera12.m3u8'
    )
    ffmpeg_cmd13 = (
        'ffmpeg -rtsp_transport tcp -i "rtsp://Agrihub_Cam:Agrihub2025@10.130.1.234:554/stream1" '
        '-an -c:v libx264 -preset veryfast -b:v 1000k -maxrate 1000k -bufsize 2000k -g 30 '
        '-hls_time 2 -hls_list_size 3 -hls_flags delete_segments -f hls C:\\\\ffmpeg\\\\hls\\\\camera13.m3u8'
    )
    ffmpeg_cmd14 = (
        'ffmpeg -rtsp_transport tcp -i "rtsp://Agrihub_Cam:Agrihub2025@10.130.1.226:554/stream1" '
        '-an -c:v libx264 -preset veryfast -b:v 1000k -maxrate 1000k -bufsize 2000k -g 30 '
        '-hls_time 2 -hls_list_size 3 -hls_flags delete_segments -f hls C:\\\\ffmpeg\\\\hls\\\\camera14.m3u8'
    )

    # Run all camera commands
    run_command_in_new_terminal(ffmpeg_cmd1)
    run_command_in_new_terminal(ffmpeg_cmd2)
    run_command_in_new_terminal(ffmpeg_cmd3)
    run_command_in_new_terminal(ffmpeg_cmd4)
    run_command_in_new_terminal(ffmpeg_cmd5)
    run_command_in_new_terminal(ffmpeg_cmd6)
    run_command_in_new_terminal(ffmpeg_cmd7)
    run_command_in_new_terminal(ffmpeg_cmd8)
    run_command_in_new_terminal(ffmpeg_cmd9)
    run_command_in_new_terminal(ffmpeg_cmd10)
    run_command_in_new_terminal(ffmpeg_cmd11)
    run_command_in_new_terminal(ffmpeg_cmd12)
    run_command_in_new_terminal(ffmpeg_cmd13)
    run_command_in_new_terminal(ffmpeg_cmd14)

    # Wait before starting Node server
    time.sleep(5)

    node_server_cmd = 'node server.js'
    run_command_in_new_terminal(node_server_cmd)

if __name__ == "__main__":
    main()
