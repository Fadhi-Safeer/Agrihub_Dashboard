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
    """
    # Construct the camera storage path
    camera_storage_path = BASE_STORAGE / cam_num

    # Check if the directory exists
    if not camera_storage_path.exists() or not camera_storage_path.is_dir():
        raise HTTPException(status_code=404, detail=f"Camera storage not found for: {cam_num}")

    # Initialize the dictionary
    images_dict = {}

    # Iterate through all image files in the directory
    for i, image_file in enumerate(camera_storage_path.glob("*.jpg"), start=1):
        # Extract health code from the file name
        file_parts = image_file.stem.split("_")  # Split the file name without extension
        if len(file_parts) < 3:
            health_code = "UNK"  # Default to unknown if the format is incorrect
        else:
            health_code = file_parts[2]  # Extract the third part as health code

        # Map health code to a description
        description = (ClassificationMapper.get_health_status_key(health_code)).replace("_", " ")

        # Construct the public URL for the image
        image_url = f"http://localhost:8001/static/{cam_num}/{image_file.name}"

        # Add entry to the dictionary
        images_dict[i] = {
            "url": image_url,  # Public URL for the image
            "description": description,
        }

    # Check if the directory was empty
    if not images_dict:
        raise HTTPException(status_code=404, detail=f"No images found in camera storage for: {cam_num}")

    return images_dict

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="localhost", port=8001)