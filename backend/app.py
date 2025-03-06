import asyncio
import websockets
from ultralytics import YOLO
import cv2
import numpy as np

# Load YOLO model
model = YOLO('backend/LETTUCE_DETECTION_MODEL.pt')  # Ensure you have the correct path to your YOLOv8 model

async def process_frame(websocket):
    async for message in websocket:
        try:
            # Decode the image
            nparr = np.frombuffer(message, np.uint8)
            image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

            # Perform YOLO object detection
            results = model.predict(
                source=image,
                imgsz=640,
                device='cpu',  # Use 'cuda' for GPU
                verbose=False
            )

            # Process the detection results
            bounding_boxes = []
            for result in results:
                if result.boxes is not None:
                    for box in result.boxes:
                        x1, y1, x2, y2 = box.xyxy[0]
                        x1, y1, x2, y2 = int(x1.item()), int(y1.item()), int(x2.item()), int(y2.item())
                        class_id = int(box.cls.item())
                        if class_id == 0:  # Class 0 is 'person' in COCO dataset
                            bounding_boxes.append([x1, y1, x2, y2])

            # Send back the bounding box data
            await websocket.send(str(bounding_boxes))
        except Exception as e:
            print(f"Error processing frame: {e}")

async def main():
    async with websockets.serve(process_frame, "127.0.0.1", 8000):
        print("WebSocket server started at ws://127.0.0.1:8000/ws/detect")
        await asyncio.Future()  # Run forever

if __name__ == "__main__":
    asyncio.run(main())