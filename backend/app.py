import asyncio
import websockets
from yolo_processor import process_frame

async def main():
    async with websockets.serve(process_frame, "127.0.0.1", 8000):
        print("WebSocket server started at ws://127.0.0.1:8000/ws/detect")
        await asyncio.Future()  # Run forever

if __name__ == "__main__":
    asyncio.run(main())