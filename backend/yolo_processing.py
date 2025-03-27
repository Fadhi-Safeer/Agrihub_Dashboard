import cv2
import json
import base64
import numpy as np
from ultralytics import YOLO
import torch

# Load YOLO model for detection
DETECTION_MODEL = YOLO('yolov8n.pt')

# Load classification models
DISEASE_MODEL = torch.load('backend/Models/DISEASE_CLASSIFICATION_MODEL.pt', map_location=torch.device('cuda'))
GROWTH_MODEL = torch.load('backend/Models/GROWTH_CLASSIFICATION_MODEL.pt', map_location=torch.device('cuda'))
HEALTH_MODEL = torch.load('backend/Models/HEALTH_CLASSIFICATION_MODEL.pt', map_location=torch.device('cuda'))

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
    results = model.predict(source=frame, imgsz=640, device='cuda', verbose=False)
  
    bounding_boxes = []
    for result in results:
        for box in result.boxes.data:
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
    
    bounding_boxes_json = json.dumps(bounding_boxes, indent=4)
    print(bounding_boxes_json)
    return bounding_boxes_json

# New function: Crop the image based on bounding box coordinates
def crop_image(frame, bounding_box):
    """
    bounding_box: Dictionary with keys 'x1', 'y1', 'x2', 'y2'
    """
    x1, y1, x2, y2 = bounding_box['x1'], bounding_box['y1'], bounding_box['x2'], bounding_box['y2']
    cropped = frame[y1:y2, x1:x2]
    return cropped

# New function: Classify the cropped image using three classification models
def classify_cropped_image(cropped_image):
    """
    Processes the cropped image with the three classification models.
    Returns a dictionary with classification results.
    """
    # Preprocess cropped image as needed (e.g., resize, normalize)
    # Here, we assume a dummy preprocessing that converts image to tensor
    # You may need to adjust based on your model requirements
    resized = cv2.resize(cropped_image, (224, 224))  # example resize
    tensor = torch.from_numpy(resized).permute(2, 0, 1).float().unsqueeze(0)  # shape: (1, 3, 224, 224)
    
    # Run inference on each model
    disease_result = DISEASE_MODEL(tensor)
    growth_result = GROWTH_MODEL(tensor)
    health_result = HEALTH_MODEL(tensor)
    
    # For demonstration, assume models return a class label as string (or adjust to your outputs)
    # You might need to extract predictions from the model outputs properly.
    classification = {
        "disease": str(disease_result),
        "growth": str(growth_result),
        "health": str(health_result)
    }
    
    return classification

# New function: Encode an image to Base64 string for transmission
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
                    classification = classify_cropped_image(cropped)
                    # Optionally, encode the cropped image as Base64 to send over the WebSocket
                    encoded_image = encode_image_to_base64(cropped)
                    result_entry = {
                        "bounding_box": box,
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
