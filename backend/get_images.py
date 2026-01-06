from fastapi import APIRouter, HTTPException
from pathlib import Path
from backend.classification_mapper import ClassificationMapper

router = APIRouter()

# IMPORTANT:
# Must match BASE_STORAGE in fast_api.py
BASE_STORAGE = Path(
    r"C:\Users\Fadhi Safeer\OneDrive\Documents\Internship\Agri hub\STORAGE\camera_storage"
)

def find_latest_camera_folder(cam_num: str) -> Path:
    """
    Traverse BASE_STORAGE to find the latest directory containing the given cam_num.
    Folder structure: <Month_Year>/<YYYY_MM_DD>/<HH_MM>/<cam_num>
    Returns the Path to the latest <cam_num> folder or raises an exception.
    """
    potential_dirs = []

    for month_dir in BASE_STORAGE.iterdir():
        if not month_dir.is_dir():
            continue

        for date_dir in month_dir.iterdir():
            if not date_dir.is_dir():
                continue

            for time_dir in date_dir.iterdir():
                if not time_dir.is_dir():
                    continue

                cam_dir = time_dir / cam_num
                if cam_dir.exists() and cam_dir.is_dir():
                    timestamp = f"{month_dir.name}_{date_dir.name}_{time_dir.name}"
                    potential_dirs.append((timestamp, cam_dir))

    if not potential_dirs:
        raise HTTPException(status_code=404, detail=f"No images found for camera: {cam_num}")

    latest_folder = sorted(potential_dirs, key=lambda x: x[0])[-1][1]
    return latest_folder


@router.get("/images/")
async def get_images(cam_num: str):
    """
    Fetch images from the specified camera's storage directory and generate a dictionary
    containing URLs and health descriptions based on the file name.
    Also includes the first image from the camera_view subdirectory if it exists.
    """
    camera_storage_path = find_latest_camera_folder(cam_num)

    if not camera_storage_path.exists() or not camera_storage_path.is_dir():
        raise HTTPException(status_code=404, detail=f"Camera storage not found for: {cam_num}")

    images_dict = {}

    # camera_view logic
    camera_view_path = camera_storage_path / "camera_view"
    if camera_view_path.exists() and camera_view_path.is_dir():
        camera_view_images = list(camera_view_path.glob("*.jpg"))
        if camera_view_images:
            camera_view_image = camera_view_images[0]
            rel_path = camera_view_image.relative_to(BASE_STORAGE)

            # static is mounted by fast_api.py at /static
            camera_view_url = f"http://localhost:8001/static/{rel_path.as_posix()}"
            print(f"[DEBUG] Camera View Image URL: {camera_view_url}")

            images_dict[0] = {
                "url": camera_view_url,
                "health": "camera_view",
                "growth": "camera_view",
                "disease": "camera_view",
            }

    # normal images
    for i, image_file in enumerate(camera_storage_path.glob("*.jpg"), start=1):
        file_parts = image_file.stem.split("_")

        growth_code = "UNK"
        health_code = "UNK"
        disease_code = "UNK"

        # {cam_num}_{growth_code}_{health_code}_{disease_code}_{timestamp}_{uuid}.jpg
        if len(file_parts) >= 4:
            growth_code = file_parts[1]
            health_code = file_parts[2]
            disease_code = file_parts[3]
        elif len(file_parts) == 3:
            growth_code = file_parts[1]
            health_code = file_parts[2]

        health_description = (ClassificationMapper.get_health_status_key(health_code)).replace("_", " ")
        growth_description = (ClassificationMapper.get_growth_stage_key(growth_code)).replace("_", " ")
        disease_description = (ClassificationMapper.get_disease_type_key(disease_code)).replace("_", " ")

        rel_path = image_file.relative_to(BASE_STORAGE)
        image_url = f"http://localhost:8001/static/{rel_path.as_posix()}"
        print(f"[DEBUG] Image URL: {image_url}")

        images_dict[i] = {
            "url": image_url,
            "health": health_description,
            "growth": growth_description,
            "disease": disease_description,
        }

    if not images_dict:
        raise HTTPException(status_code=404, detail=f"No images found in camera storage for: {cam_num}")

    return images_dict
