from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from pathlib import Path
from classification_mapper import ClassificationMapper
from fastapi.middleware.cors import CORSMiddleware



app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # or whatever your Flutter Web URL is
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Base storage path
BASE_STORAGE = Path(r"C:\Users\Fadhi Safeer\OneDrive\Documents\Internship\Agri hub\STORAGE\camera_storage")

# Mount the static files for serving images
app.mount("/static", StaticFiles(directory=BASE_STORAGE), name="static")

        

@app.get("/images/")
async def get_images(cam_num: str):
    """
    Fetch images from the specified camera's storage directory and generate a dictionary
    containing URLs and health descriptions based on the file name.
    Also includes the first image from the camera_view subdirectory if it exists.
    """
    # Construct the camera storage path
    camera_storage_path = BASE_STORAGE / cam_num

    # Check if the directory exists
    if not camera_storage_path.exists() or not camera_storage_path.is_dir():
        raise HTTPException(status_code=404, detail=f"Camera storage not found for: {cam_num}")

    # Initialize the dictionary
    images_dict = {}

    # First, check for camera_view image and add it if exists
    camera_view_path = camera_storage_path / "camera_view"
    if camera_view_path.exists() and camera_view_path.is_dir():
        # Find the first jpg file in camera_view directory
        camera_view_images = list(camera_view_path.glob("*.jpg"))
        if camera_view_images:
            # Get the first image
            camera_view_image = camera_view_images[0]
            
            # Construct the public URL for the camera view image
            camera_view_url = f"http://localhost:8001/static/{cam_num}/camera_view/{camera_view_image.name}"
            
            # Add as the first entry in the dictionary
            images_dict[0] = {
                "url": camera_view_url,
                "health": "camera_view",
                "growth": "camera_view",
                "disease": "camera_view",
            }

    # Then process regular images
    for i, image_file in enumerate(camera_storage_path.glob("*.jpg"), start=1):
        file_parts = image_file.stem.split("_")  
        
        # Initialize default values
        growth_code = "UNK"  
        health_code = "UNK"  
        disease_code = "UNK"  # 
        
        # {cam_num}_{growth_code}_{health_code}_{disease_code}_{timestamp}_{uuid}.jpg
        if len(file_parts) >= 4: 
            growth_code = file_parts[1]  
            health_code = file_parts[2]  
            disease_code = file_parts[3]  
        elif len(file_parts) == 3:  
            growth_code = file_parts[1]
            health_code = file_parts[2]
        
        # Map health code to a description
        health_description = (ClassificationMapper.get_health_status_key(health_code)).replace("_", " ")
        growth_description = (ClassificationMapper.get_growth_stage_key(growth_code)).replace("_", " ")
        disease_description = (ClassificationMapper.get_disease_type_key(disease_code)).replace("_", " ")

        # Construct the public URL for the image
        image_url = f"http://localhost:8001/static/{cam_num}/{image_file.name}"

        # Add entry to the dictionary
        images_dict[i] = {
            "url": image_url,  
            "health": health_description,
            "growth": growth_description,
            "disease": disease_description,
        }

    # Check if the directory was empty
    if not images_dict:
        raise HTTPException(status_code=404, detail=f"No images found in camera storage for: {cam_num}")

    return images_dict