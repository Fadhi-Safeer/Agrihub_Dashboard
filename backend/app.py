import asyncio
import websockets
from yolo_processing import handler as yolo_handler


async def main():
    try:
        async with websockets.serve(yolo_handler, "localhost", 8000):
            print("WebSocket server started on ws://localhost:8000")
            await asyncio.Future()  # Run forever
    except Exception as e:
        print(f"[ERROR] WebSocket server crashed: {e}")

if __name__ == "__main__":
    asyncio.run(main())
