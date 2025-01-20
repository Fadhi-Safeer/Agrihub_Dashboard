from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import cv2
from PIL import Image
from io import BytesIO
from ultralytics import YOLO
import numpy as np

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins, change this to specific origins if needed
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load YOLOv8 model
model = YOLO('yolov8s.pt')  # Replace with your YOLO model path

@app.post("/predict/")
async def predict(file: UploadFile = File(...)):
    contents = await file.read()
    image = Image.open(BytesIO(contents))

    # Convert image to numpy array
    image_np = np.array(image)

    # Perform prediction
    results = model(image_np)

    # Convert results to JSON
    predictions = results.pandas().xyxy[0].to_json(orient="records")

    return predictions

@app.get("/stream/")
async def stream():
    cap = cv2.VideoCapture(0)  # Open the default camera

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        # Convert frame to JPEG
        _, jpeg = cv2.imencode('.jpg', frame)
        frame_bytes = jpeg.tobytes()

        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')

    cap.release()

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)