# Main function to start the WebSocket server
import asyncio
import websockets
from yolo_processing import handler


async def main():
    async with websockets.serve(handler , "localhost", 8000):
        print("WebSocket server started on ws://localhost:8000")
        await asyncio.Future()  # Run forever

if __name__ == "__main__":
    asyncio.run(main())