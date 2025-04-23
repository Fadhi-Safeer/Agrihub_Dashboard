import os
import re
import uuid
from datetime import datetime
import cv2
import numpy as np
from classification_mapper import ClassificationMapper

def save_frame_locally(
    frame: np.ndarray,
    cam_url: str,
    classification_results: dict,
    base_dir: str = "C:/Users/Fadhi Safeer/OneDrive/Documents/Internship/Agri hub/STORAGE/camera_storage"
) -> None:
    """
    Saves classified crop frame directly in camera folder with structured naming
    """
    # Ensure camera folder exists
# Extract the filename part of the URL

    filename = cam_url.split('/')[-1]
    name = filename.split('.')[0] 
    cam_num = int(name.replace('camera', ''))  

    cam_dir = os.path.join(base_dir, cam_num)
    os.makedirs(cam_dir, exist_ok=True)

    # Extract and normalize classification info
    growth_stage = str(classification_results.get("growth", "unknown")).lower().strip()
    health_status = str(classification_results.get("health", "unknown")).lower().strip()
    disease_type = str(classification_results.get("disease", "")).lower().strip()

    # Get classification codes
    growth_code = ClassificationMapper.get_growth_code(growth_stage)
    health_code = ClassificationMapper.get_health_code(health_status, disease_type)

    # Generate filename (without subfolders)
    filename = f"{cam_num}_{growth_code}_{health_code}_{datetime.now().strftime('%Y%m%d_%H%M%S')}_{uuid.uuid4().hex[:6]}.jpg"
    
    # Save directly in camera folder
    cv2.imwrite(os.path.join(cam_dir, filename), frame)
    
    return