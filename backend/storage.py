import os
import cv2
from datetime import datetime

# Directory to save images
IMAGE_SAVE_DIR = "C:/Users/Fadhi Safeer/OneDrive/Documents/Internship/Agri hub/camera_storage"

# Ensure the save directory exists
if not os.path.exists(IMAGE_SAVE_DIR):
    os.makedirs(IMAGE_SAVE_DIR)

def extract_camera_id(hls_url):

    # Split the URL by '/' and take the last part, then remove the file extension
    return os.path.basename(hls_url).split('.')[0]

def save_frame_locally(frame, hls_url):
    """
    Saves the given frame to the specified directory with a unique name.

    :param frame: The captured frame (numpy array).
    :param camera_id: A unique identifier for the camera (e.g., camera URL or ID).
    :return: The file path where the image was saved.
    """
    camera_id =  extract_camera_id(hls_url)
    # Generate a unique filename using the camera ID and current timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
    filename = f"{camera_id}_{timestamp}.jpg"

    # Create a subdirectory for the camera if it doesn't exist
    camera_dir = os.path.join(IMAGE_SAVE_DIR, camera_id)
    if not os.path.exists(camera_dir):
        os.makedirs(camera_dir)

    # Save the frame to the camera's subdirectory
    file_path = os.path.join(camera_dir, filename)
    cv2.imwrite(file_path, frame)
    print(f"Saved frame to {file_path}")
    return file_path