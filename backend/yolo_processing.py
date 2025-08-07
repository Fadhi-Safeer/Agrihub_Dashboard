import asyncio
import cv2
import json
import base64
import numpy as np
from ultralytics import YOLO
import torch
from storage import save_camera_view_frame, save_frame_locally  
import json
from PIL import Image


# Load YOLO model for detection
DETECTION_MODEL = YOLO('backend\Models\LETTUCE_DETECTION_MODEL-Agrihub_images.pt') 
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

# Load classification models
HEALTH_MODEL = YOLO('backend/Models/HEALTH_CLASSIFICATION_MODEL.pt').to(device)
GROWTH_MODEL = YOLO('backend/Models/GROWTH_CLASSIFICATION_MODEL.pt').to(device)
DISEASE_MODEL = YOLO('backend/Models/DISEASE_CLASSIFICATION_MODEL.pt').to(device)

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

async def get_cam_num(hls_url):
    #print("hls url:", hls_url)
    #print(hls_url.split('/')[-1].split('.')[0] )
    return hls_url.split('/')[-1].split('.')[0] 


# Existing YOLO detection process (Step 1)


# Existing YOLO detection process (Step 1)
async def yolo_detection(hls_url, model):
    # Time Interval
    await asyncio.sleep(3)
    frame = await capture_frame_from_hls(hls_url)
    save_camera_view_frame(frame, await get_cam_num(hls_url))
    #print("captured frame")

    # YOLO prediction with threshold moved to model
    results = model.predict(source=frame, imgsz=640, device=device, verbose=False)

    bounding_boxes = []

    for result in results:
        #print("if statement")
        if result.boxes is None:
            continue  # No detections

        #print("result.boxes.data")
        img_array = result.orig_img.copy()  # numpy array (BGR)
        
        for i, box in enumerate(result.boxes.data):

            #print("result.boxes.data2")
            if len(box) < 5:
                continue  # Ensure the box contains valid values

            x1, y1, x2, y2, conf = box[:5]
            class_id = int(result.boxes.cls[i])
            growth_label = model.names[class_id]


            if None in (x1, y1, x2, y2) or conf < 0.60:
                continue

            # Convert to int for drawing and result
            x1, y1, x2, y2 = int(x1), int(y1), int(x2), int(y2)

            # Draw rectangle on image (BGR: green)
            cv2.rectangle(img_array, (x1, y1), (x2, y2), (0, 255, 0), 2)

            bounding_box = {
                "x1": x1,
                "y1": y1,
                "x2": x2,
                "y2": y2,
                "growth" : growth_label
            }
            bounding_boxes.append(bounding_box)
            #print("Bounding box added:", bounding_box)


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

async def classify_cropped_image(cropped_image, detected_class_id: int):
    if cropped_image is None:
        return {"error": "Invalid cropped image"}

    # Convert BGR to RGB
    cropped_image = cv2.cvtColor(cropped_image, cv2.COLOR_BGR2RGB)

    # Resize and normalize
    resized = cv2.resize(cropped_image, (224, 224))
    tensor = torch.from_numpy(resized).permute(2, 0, 1).float().unsqueeze(0) / 255.0

    # NOTE: Growth classification will come from detection model (not this model)


    # Get class name from DETECTION_MODEL using the provided class ID
    growth_class = DETECTION_MODEL.names[detected_class_id] if detected_class_id in DETECTION_MODEL.names else "Unknown"
    growth_class = growth_class.replace("_", " ")

    classification = {
        "disease": "healthy",                  # Hardcoded
        "growth": detected_class_id,                # From detection model
        "health": "fully nutritional"          # Hardcoded
    }

    return classification

'''
# Function to classify a cropped image using three classification models
async def classify_cropped_image(cropped_image):
    if cropped_image is None:
        return {"error": "Invalid cropped image"}

    # Convert BGR to RGB (YOLO models expect RGB format)
    cropped_image = cv2.cvtColor(cropped_image, cv2.COLOR_BGR2RGB)

    # Resize for YOLO classification models
    resized = cv2.resize(cropped_image, (224, 224))  # Resize to required input size
    tensor = torch.from_numpy(resized).permute(2, 0, 1).float().unsqueeze(0)/255.0  # shape: (1, 3, 224, 224)

    # Run inference on each model
    disease_result = DISEASE_MODEL.predict(source=tensor, imgsz=224, device=device, verbose=False)
    growth_result = GROWTH_MODEL.predict(source=tensor, imgsz=224, device=device, verbose=False)
    health_result = HEALTH_MODEL.predict(source=tensor, imgsz=224, device=device, verbose=False)

    #print("Proocessed results:")
    # Extract predictions from model outputs
    classification = {
        "disease": (DISEASE_MODEL.names[disease_result[0].probs.top1] if disease_result else "Unknown").replace("_", " "),
        "growth": (GROWTH_MODEL.names[growth_result[0].probs.top1] if growth_result else "Unknown").replace("_", " "),
        "health": (HEALTH_MODEL.names[health_result[0].probs.top1] if health_result else "Unknown").replace("_", " "),
    }
    
    #print("Classification results:", classification)
    

    return classification

'''


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
            #print("Received message:", message)
            hls_url = data.get('url')

            # Check if the request is detection-only (Step 1) or includes bounding boxes (Step 2)
            if 'bounding_boxes' not in data:
                # Detection-only request
                bounding_boxes_json = await yolo_detection(hls_url, DETECTION_MODEL)
                print("Detection completed")
                await websoc.send(bounding_boxes_json)

            else:
                #print("Detection and classification request")
                # Cropping & Classification request
                bounding_boxes = data.get('bounding_boxes')
                frame = await capture_frame_from_hls(hls_url)
                results = []

                for box in bounding_boxes:
                    cropped = crop_image(frame, box)
                    if cropped is None:
                        continue  # Skip if crop failed

                    classification = await classify_cropped_image(cropped, box["growth"])

                    print("Classification results:", classification)
                    
                    # If classification contains "error", skip sending that result
                    if "error" in classification:
                        continue
                    
                    #print(hls_url)
                    cam_num = await get_cam_num(hls_url)

                    #print("cam numberrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr:", cam_num)

                    save_frame_locally(
                        cropped, cam_num, classification,
                        base_dir="C:/Users/Fadhi Safeer/OneDrive/Documents/Internship/Agri hub/STORAGE/camera_storage"
                    )
                    #print("Frame Saved")
                    

                    encoded_image = encode_image_to_base64(cropped)

                    result_entry = {
                        "cropped_image": encoded_image,
                        "classification": classification
                    }
                    results.append(result_entry)
                    #print("Result Added")

                # Send empty array if no valid classification results
                response = json.dumps(results if results else [], indent=4)
                await websoc.send(response)


    except json.JSONDecodeError as e:
        error_message = {"error": f"JSON decode error: {str(e)}"}
        await websoc.send(json.dumps(error_message))
    except Exception as e:
        error_message = {"error": str(e)}
        await websoc.send(json.dumps(error_message))
