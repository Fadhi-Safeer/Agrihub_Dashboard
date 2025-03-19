import asyncio
import websockets

from yolo_processor import process_video_stream

async def handle_client(websocket):
    try:
        # Receive video URL from client
        video_url = await websocket.recv()
        print(f"Received video URL: {video_url}")

        # Start processing the video stream
        await process_video_stream(websocket, video_url)

    except Exception as e:
        print(f"Error handling client: {e}")

async def main():
    async with websockets.serve(handle_client, "127.0.0.1", 8000):
        print(f"WebSocket server started at ws://127.0.0.1:8000")
        await asyncio.Future()  # Keeps server running

if __name__ == "__main__":
    asyncio.run(main())
