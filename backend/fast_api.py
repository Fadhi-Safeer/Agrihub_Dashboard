from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
import os
from pathlib import Path
from typing import List
import uvicorn

app = FastAPI()

# Allow frontend access (e.g., Flutter)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # You can restrict this to your Flutter app's IP
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Base storage path
BASE_STORAGE_PATH = r"C:\Users\Fadhi Safeer\OneDrive\Documents\Internship\Agri hub\STORAGE\camera_storage"

@app.get("/images/{cam_num}", response_model=List[dict])
def get_images(cam_num: str):
    
    cam_folder = os.path.join(BASE_STORAGE_PATH, cam_num)
    if not os.path.exists(cam_folder):
        raise HTTPException(status_code=404, detail="Camera folder not found")

    # Get image files sorted by modified time (newest first)
    files = sorted(
        [f for f in Path(cam_folder).glob("*.jpg")],
        key=lambda x: x.stat().st_mtime,
        reverse=True
    )[:14]  # limit to 14

    image_data = []
    for file in files:
        image_data.append({
            "filename": file.name,
            "url": f"http://localhost:8001/image/{cam_num}/{file.name}"
        })
    return image_data

# Endpoint to serve images
@app.get("/image/{cam_num}/{filename}")
def serve_image(cam_num: str, filename: str):
    image_path = os.path.join(BASE_STORAGE_PATH, cam_num, filename)
    if not os.path.isfile(image_path):
        raise HTTPException(status_code=404, detail="Image not found")
    return FileResponse(image_path)


