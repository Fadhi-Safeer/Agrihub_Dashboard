import asyncio
import websockets
from yolo_processing import handler as yolo_handler

async def second_handler(websocket, path):
    print("Connected to second socket!")
    async for message in websocket:
        print(f"Second socket received: {message}")
        await websocket.send("Second socket response")

async def main():
    server1 = websockets.serve(yolo_handler, "localhost", 8000)
    server2 = websockets.serve(second_handler, "localhost", 8001)

    await asyncio.gather(server1, server2)
    print("Both WebSocket servers running...")

if __name__ == "__main__":
    asyncio.run(main())
