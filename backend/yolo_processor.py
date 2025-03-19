import cv2
import numpy as np
import asyncio
import websockets
import time
from ultralytics import YOLO
import requests
from io import BytesIO

# Load YOLO model
model = YOLO('backend/Models/LETTUCE_DETECTION_MODEL.pt')  # Update with correct path

# Function to fetch frame from HTTPS stream
def fetch_frame(video_url):
    try:
        response = requests.get(video_url, stream=True)
        if response.status_code == 200:
            bytes_stream = BytesIO(response.content)
            image = np.asarray(bytearray(bytes_stream.read()), dtype=np.uint8)
            return cv2.imdecode(image, cv2.IMREAD_COLOR)
        else:
            print("Failed to fetch frame, status code:", response.status_code)
            return None
    except Exception as e:
        print("Error fetching frame:", e)
        return None

async def process_video_stream(websocket, video_url):
    while True:
        try:
            print("Fetching frame...")
            image = fetch_frame(video_url)
            if image is None:
                print("Skipping frame due to fetch error.")
                await asyncio.sleep(5)
                continue
            print("Frame fetched successfully")

            # Perform YOLO object detection
            results = model.predict(
                source=image,
                imgsz=640,
                device='cpu',  # Use 'cuda' for GPU
                verbose=False
            )
            print("YOLO detection performed")

            # Process the detection results
            bounding_boxes = []
            for result in results:
                if result.boxes is not None:
                    for box in result.boxes:
                        x1, y1, x2, y2 = box.xyxy[0]
                        x1, y1, x2, y2 = int(x1.item()), int(y1.item()), int(x2.item()), int(y2.item())
                        class_id = int(box.cls.item())
                        confidence = box.conf.item()
                        print(f"Box: {x1}, {y1}, {x2, y2}, Class ID: {class_id}, Confidence: {confidence}")
                        bounding_boxes.append([x1, y1, x2, y2, class_id, confidence])
            print("Bounding boxes processed: ", bounding_boxes)

            # Send bounding box data back to the client
            await websocket.send(str(bounding_boxes))
            print("Bounding boxes sent to client")

        except Exception as e:
            print(f"Error processing video stream: {e}")

        await asyncio.sleep(5)  # Capture a frame every 5 seconds