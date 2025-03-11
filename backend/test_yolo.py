#WEBSOCKET APPROACH

import cv2
import numpy as np
from ultralytics import YOLO

# Load YOLO model
model = YOLO('backend/LETTUCE_DETECTION_MODEL.pt') 
growth_model = YOLO('backend/Models/GROWTH_CLASSIFICATION_MODEL.pt')
disease_model = YOLO('backend/Models/DISEASE_CLASSIFICATION_MODEL.pt')
health_model = YOLO('backend/Models/HEALTH_CLASSIFICATION_MODEL.pt')

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
            classifications = []
            for result in results:
                if result.boxes is not None:
                    for box in result.boxes:
                        x1, y1, x2, y2 = box.xyxy[0]
                        x1, y1, x2, y2 = int(x1.item()), int(y1.item()), int(x2.item()), int(y2.item())
                        class_id = int(box.cls.item())
                        if class_id == 0:  # Class 0 is 'person' in COCO dataset
                            bounding_boxes.append([x1, y1, x2, y2])
                            cropped_image = image[y1:y2, x1:x2]
                            classification_data = classify_cropped_image(cropped_image)
                            classifications.append(classification_data)

            # Send back the bounding box data and classification data
            response = {
                "bounding_boxes": bounding_boxes,
                "classifications": classifications
            }
            await websocket.send(str(response))
        except Exception as e:
            print(f"Error processing frame: {e}")

def classify_cropped_image(cropped_image):
    # Perform classification for growth stage
    growth_results = growth_model.predict(
        source=cropped_image,
        imgsz=640,
        device='cpu',  # Use 'cuda' for GPU
        verbose=False
    )
    growth_stage = growth_results[0].names[growth_results[0].cls[0]]

    # Perform classification for disease
    disease_results = disease_model.predict(
        source=cropped_image,
        imgsz=640,
        device='cpu',  # Use 'cuda' for GPU
        verbose=False
    )
    disease_stage = disease_results[0].names[disease_results[0].cls[0]]

    # Perform classification for health
    health_results = health_model.predict(
        source=cropped_image,
        imgsz=640,
        device='cpu',  # Use 'cuda' for GPU
        verbose=False
    )
    health_stage = health_results[0].names[health_results[0].cls[0]]

    return {
        "growth_stage": growth_stage,
        "disease_stage": disease_stage,
        "health_stage": health_stage
}