import cv2
import json
import base64
import numpy as np
from ultralytics import YOLO
import torch
from storage import save_frame_locally  


# Load YOLO model for detection
DETECTION_MODEL = YOLO('yolov8m.pt')

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

# Load classification models
HEALTH_MODEL = YOLO('yolov8m-cls.pt').to(device)
GROWTH_MODEL = YOLO('yolov8m-cls.pt').to(device)
DISEASE_MODEL = YOLO('yolov8m-cls.pt').to(device)

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

# Existing YOLO detection process (Step 1)
async def yolo_process(hls_url, model):
    frame = await capture_frame_from_hls(hls_url)
    results = model.predict(source=frame, imgsz=640, device=device, verbose=False)
  
    bounding_boxes = []
    for result in results:
        if result.boxes is None:
            continue  # No detections

        for box in result.boxes.data:
            if len(box) < 5:
                continue  # Ensure the box contains valid values
            
            x1, y1, x2, y2, conf = box[:5]  # Extract coordinates and confidence score

            # Ensure coordinates are valid and confidence score is above threshold (80%)
            if None in (x1, y1, x2, y2) or conf < 0.80:
                continue

            bounding_box = {
                "x1": int(x1),
                "y1": int(y1),
                "x2": int(x2),
                "y2": int(y2)
            }
            bounding_boxes.append(bounding_box)
    
    return json.dumps(bounding_boxes, indent=4)

# Function to crop an image based on bounding box coordinates
def crop_image(frame, bounding_box):
    """
    bounding_box: Dictionary with keys 'x1', 'y1', 'x2', 'y2'
    """
    h, w, _ = frame.shape
    x1, y1, x2, y2 = (
        max(0, bounding_box['x1']),
        max(0, bounding_box['y1']),
        min(w, bounding_box['x2']),
        min(h, bounding_box['y2']),
    )

    cropped = frame[y1:y2, x1:x2]
    return cropped if cropped.size > 0 else None

# Function to classify a cropped image using three classification models
def classify_cropped_image(cropped_image):
    if cropped_image is None:
        return {"error": "Invalid cropped image"}

    # Convert BGR to RGB (YOLO models expect RGB format)
    cropped_image = cv2.cvtColor(cropped_image, cv2.COLOR_BGR2RGB)

    # Resize for YOLO classification models
    resized = cv2.resize(cropped_image, (224, 224))  # Resize to required input size
    tensor = torch.from_numpy(resized).permute(2, 0, 1).float().unsqueeze(0)  # shape: (1, 3, 224, 224)

    # Run inference on each model
    disease_result = DISEASE_MODEL.predict(source=tensor, imgsz=224, device=device, verbose=False)
    growth_result = GROWTH_MODEL.predict(source=tensor, imgsz=224, device=device, verbose=False)
    health_result = HEALTH_MODEL.predict(source=tensor, imgsz=224, device=device, verbose=False)

    # Extract predictions from model outputs
    classification = {
        "disease": disease_result[0].probs.top1 if disease_result else "Unknown",
        "growth": growth_result[0].probs.top1 if growth_result else "Unknown",
        "health": health_result[0].probs.top1 if health_result else "Unknown",
    }
    

    return classification

# Function to encode an image to Base64 string for transmission
def encode_image_to_base64(image):
    _, buffer = cv2.imencode('.jpg', image)
    jpg_as_text = base64.b64encode(buffer).decode('utf-8')
    return jpg_as_text

# Updated WebSocket server handler
async def handler(websoc):
    try:
        async for message in websoc:
            data = json.loads(message)
            print("Received message:", message)
            hls_url = data.get('url')

            # Check if the request is detection-only (Step 1) or includes bounding boxes (Step 2)
            if 'bounding_boxes' not in data:
                # Detection-only request
                bounding_boxes_json = await yolo_process(hls_url, DETECTION_MODEL)
                await websoc.send(bounding_boxes_json)
            else:
                # Cropping & Classification request
                bounding_boxes = data.get('bounding_boxes')
                frame = await capture_frame_from_hls(hls_url)
                results = []
                
                for box in bounding_boxes:
                    cropped = crop_image(frame, box)
                    if cropped is None:
                        continue  # Skip if crop failed

                    classification = classify_cropped_image(cropped)
                    save_frame_locally(
                        frame=cropped,
                        cam_num=data.get('cam_num', 'cam01'),  # Get from your input data
                        classification_results=classification
                    )
                    encoded_image = encode_image_to_base64(cropped)  # Convert cropped image to Base64

                    result_entry = {
                        "cropped_image": encoded_image,
                        "classification": classification
                    }
                    results.append(result_entry)
                
                response = json.dumps(results, indent=4)
                await websoc.send(response)

    except json.JSONDecodeError as e:
        error_message = {"error": f"JSON decode error: {str(e)}"}
        await websoc.send(json.dumps(error_message))
    except Exception as e:
        error_message = {"error": str(e)}
        await websoc.send(json.dumps(error_message))
