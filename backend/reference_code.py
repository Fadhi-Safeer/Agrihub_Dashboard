import cv2
import json
import asyncio
import websockets
from ultralytics import YOLO

# Function to capture a frame from the HLS stream
async def capture_frame_from_hls(hls_url):
    cap = cv2.VideoCapture(hls_url)
    if not cap.isOpened():
        raise Exception(f"Failed to open HLS stream from {hls_url}")
    ret, frame = cap.read()
    cap.release()
    if not ret:
        raise Exception("Failed to capture frame from HLS stream")
    return frame

# Function to perform prediction on the frame and save the result
async def yolo_process(hls_url, model):
    frame = await capture_frame_from_hls(hls_url)
    results = model.predict(source=frame, imgsz=640, device='cpu', verbose=False)
  
    bounding_boxes = []
    for result in results:
        for box in result.boxes.data:
            x1, y1, x2, y2, conf = box[:5]  # Extract coordinates and confidence score

            # Ensure coordinates are valid and confidence score is above 80%
            if None in (x1, y1, x2, y2) or conf < 0.80:
                continue

            bounding_box = {
                "x1": int(x1),
                "y1": int(y1),
                "x2": int(x2),
                "y2": int(y2)
            }
            bounding_boxes.append(bounding_box)
    
    bounding_boxes_json = json.dumps(bounding_boxes, indent=4)
    print(bounding_boxes_json)
    return bounding_boxes_json

# WebSocket server handler
async def handler(websoc):
    try:
        
        async for message in websoc:
            data = json.loads(message)
            print(message)
            hls_url = data.get('url')
            bounding_boxes_json = await yolo_process(hls_url, model)
            await websoc.send(bounding_boxes_json)
    except json.JSONDecodeError as e:
        error_message = {"error": f"JSON decode error: {str(e)}"}
        await websoc.send(json.dumps(error_message))
    except Exception as e:
        error_message = {"error": str(e)}
        await websoc.send(json.dumps(error_message))

# Main function to start the WebSocket server
async def main():
    async with websockets.serve(handler, "localhost", 8000):
        print("WebSocket server started on ws://localhost:8000")
        await asyncio.Future()  # Run forever

if __name__ == "__main__":
    model = YOLO('yolov8n.pt')
    asyncio.run(main())