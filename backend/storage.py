import os
import re
import shutil
import uuid
from datetime import datetime
import cv2
import numpy as np
from classification_mapper import ClassificationMapper

def save_frame_locally(
    frame: np.ndarray,
    cam_num: str,
    classification_results: dict,
    base_dir: str = "C:/Users/Fadhi Safeer/OneDrive/Documents/Internship/Agri hub/STORAGE/camera_storage"
) -> None:
    """
    Saves classified crop frame directly in camera folder with structured naming
    """
# Extract the filename part of the URL
    
    print("cam number:", cam_num)
    

    cam_dir = os.path.join(base_dir,str(cam_num))
    os.makedirs(cam_dir, exist_ok=True)

    print("cam number got successfully")
    # Extract and normalize classification info
    growth_stage = str(classification_results.get("growth", "unknown")).lower().strip()
    health_status = str(classification_results.get("health", "unknown")).lower().strip()
    disease_type = str(classification_results.get("disease", "")).lower().strip()
    
    # Get classification codes
    growth_code = ClassificationMapper.get_growth_code(growth_stage)
    health_code = ClassificationMapper.get_health_code(health_status)
    disease_code = ClassificationMapper.get_disease_code(disease_type)
    print("disease code:", disease_code)

    # Generate filename (without subfolders)
    filename = f"{cam_num}_{growth_code}_{health_code}_{disease_code}_{datetime.now().strftime('%Y%m%d_%H%M%S')}_{uuid.uuid4().hex[:6]}.jpg"
    
    # Save directly in camera folder
    cv2.imwrite(os.path.join(cam_dir, filename), frame)
    
    return



def save_camera_view_frame(
    frame: np.ndarray,
    cam_num: str,
    base_path: str = "C:/Users/Fadhi Safeer/OneDrive/Documents/Internship/Agri hub/STORAGE/camera_storage"
) -> None:
    """
    Saves the camera frame in the base path with structured naming.
    Naming format: {base_path}/{cam_num}/camera_view/{cam_num}_{timestamp}.jpg
    """
    
     

    # Create the camera view directory path
    camera_view_dir = os.path.join(base_path, str(cam_num), "camera_view")
    os.makedirs(camera_view_dir, exist_ok=True)  # Ensure the directory exists
    clear_directory(camera_view_dir) 

    # Generate the filename with timestamp
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    filename = f"{cam_num}_{timestamp}.jpg"

    print("filename:", filename)
    # Save the frame to the generated file path
    cv2.imwrite(os.path.join(camera_view_dir, filename), frame)

    print(f"Frame saved successfully: {os.path.join(camera_view_dir, filename)}")
    
    


def clear_directory(directory_path):
    
    # Check if directory exists
    if not os.path.exists(directory_path):
        print(f"Error: Directory '{directory_path}' does not exist.")
        return 0
    
    if not os.path.isdir(directory_path):
        print(f"Error: '{directory_path}' is not a directory.")
        return 0
    
    deleted_count = 0
    
    try:
        # Get all items in the directory
        items = os.listdir(directory_path)
        
        # Delete each item
        for item in items:
            item_path = os.path.join(directory_path, item)
            
            if os.path.isfile(item_path):
                os.remove(item_path)
                print(f"Deleted file: {item_path}")
                deleted_count += 1
            elif os.path.isdir(item_path):
                shutil.rmtree(item_path)
                print(f"Deleted directory: {item_path}")
                deleted_count += 1
        
        print(f"Successfully deleted {deleted_count} items from {directory_path}")
        return deleted_count
        
    except Exception as e:
        print(f"Error while clearing directory: {e}")
        return deleted_count

