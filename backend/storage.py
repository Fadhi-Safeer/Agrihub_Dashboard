import os
import shutil
import uuid
from datetime import datetime, timedelta
import cv2
import numpy as np
from classification_mapper import ClassificationMapper

# Track last save time per camera
_last_saved_at: dict[str, datetime] = {}
SAVE_INTERVAL = timedelta(minutes=30)  # Set frequency here (30 minutes)

def _should_save(cam_num: str, now: datetime) -> bool:
    last = _last_saved_at.get(cam_num)
    if not last or now - last >= SAVE_INTERVAL:
        return True
    return False



def get_timestamp_paths(base_dir):
    now = datetime.now()
    month_folder = now.strftime("%B_%Y")       # e.g., July_2025
    date_folder = now.strftime("%Y_%m_%d")     # e.g., 2025_07_09
    time_folder = now.strftime("%H_%M")  # e.g., 14_04 for 2:04 PM
    full_path = os.path.join(base_dir, month_folder, date_folder, time_folder)
    return full_path, now


def save_frame_locally(
    frame: np.ndarray,
    cam_num: str,
    classification_results: dict,
    base_dir: str = "C:/Users/Fadhi Safeer/OneDrive/Documents/Internship/Agri hub/STORAGE/camera_storage"
) -> None:
    """
    Saves classified crop frame in a timestamped camera folder with structured naming.
    """

    # Check time restriction
    now = datetime.now()
    if not _should_save(cam_num, now):
        #print(f"[SKIPPED] Classified image save throttled for {cam_num}")
        return

    # Get time-based directory structure
    save_path, _ = get_timestamp_paths(base_dir)

    # Create camera-specific directory
    cam_dir = os.path.join(save_path, str(cam_num))
    os.makedirs(cam_dir, exist_ok=True)

    # Normalize classification fields
    growth_stage = str(classification_results.get("growth", "unknown")).lower().strip().replace(" ", "_")
    health_status = str(classification_results.get("health", "unknown")).lower().strip().replace(" ", "_")
    disease_type = str(classification_results.get("disease", "")).lower().strip().replace(" ", "_")

    # Convert to short codes
    growth_code = ClassificationMapper.get_growth_code(growth_stage)
    health_code = ClassificationMapper.get_health_code(health_status)
    disease_code = ClassificationMapper.get_disease_code(disease_type)

    # Filename format
    filename = f"{cam_num}_{growth_code}_{health_code}_{disease_code}_{now.strftime('%Y%m%d_%H%M%S')}_{uuid.uuid4().hex[:6]}.jpg"

    # Save
    cv2.imwrite(os.path.join(cam_dir, filename), frame)

    #print(f"[SAVED] Classified image: {filename}")


def save_camera_view_frame(
    frame: np.ndarray,
    cam_num: str,
    base_dir: str = "C:/Users/Fadhi Safeer/OneDrive/Documents/Internship/Agri hub/STORAGE/camera_storage"
) -> None:
    """
    Saves the latest camera snapshot in a timestamped camera folder.
    """

    # Check time restriction
    now = datetime.now()
    if not _should_save(cam_num, now):
        #print(f"[SKIPPED] Camera view snapshot throttled for {cam_num}")
        return

    # Get time-based directory structure
    save_path, _ = get_timestamp_paths(base_dir)

    # Camera view folder
    cam_view_dir = os.path.join(save_path, str(cam_num), "camera_view")
    os.makedirs(cam_view_dir, exist_ok=True)

    # Clean old snapshot(s)
    clear_directory(cam_view_dir)

    # Filename
    filename = f"{cam_num}_{now.strftime('%Y%m%d_%H%M%S')}.jpg"

    # Save
    cv2.imwrite(os.path.join(cam_view_dir, filename), frame)
    #print(f"[SAVED] Snapshot: {os.path.join(cam_view_dir, filename)}")


def clear_directory(directory_path):
    """
    Clears all files and subdirectories from the given path.
    """
    if not os.path.exists(directory_path):
        #print(f"[WARN] Directory '{directory_path}' does not exist.")
        return 0

    if not os.path.isdir(directory_path):
        #print(f"[ERROR] '{directory_path}' is not a directory.")
        return 0

    deleted_count = 0
    try:
        for item in os.listdir(directory_path):
            item_path = os.path.join(directory_path, item)
            if os.path.isfile(item_path):
                os.remove(item_path)
                deleted_count += 1
            elif os.path.isdir(item_path):
                shutil.rmtree(item_path)
                deleted_count += 1
        return deleted_count
    except Exception as e:
        #print(f"[ERROR] Failed to clear directory: {e}")
        return deleted_count