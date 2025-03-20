import cv2
from ultralytics import YOLO

# Function to capture frames from the HLS stream
def capture_frame_from_hls(hls_url):
    cap = cv2.VideoCapture(hls_url)
    if not cap.isOpened():
        raise Exception(f"Failed to open HLS stream from {hls_url}")
    return cap

# Function to perform prediction on the frame and draw bounding boxes
def yolo_process(frame, model):
    results = model.predict(source=frame, imgsz=640, device='cpu', verbose=False)
  
    for result in results:
        for box in result.boxes.data:
            x1, y1, x2, y2 = box[:4]  # Extract coordinates

            # Ensure coordinates are valid
            if None in (x1, y1, x2, y2):
                continue

            # Convert coordinates to integers
            x1, y1, x2, y2 = int(x1), int(y1), int(x2), int(y2)

            # Draw bounding box on the frame
            cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)  # Green box

            # Draw center point
            center_x = int((x1 + x2) / 2)
            center_y = int((y1 + y2) / 2)
            cv2.circle(frame, (center_x, center_y), 5, (0, 0, 255), -1)  # Red dot

    return frame

# Main function to process and display video feeds
def main():
    # Load YOLO model
    model = YOLO('backend/Models/LETTUCE_DETECTION_MODEL.pt')

    # HLS stream URLs
    hls_urls = [
        "http://localhost:8080/camera1.m3u8",
        "http://localhost:8080/camera2.m3u8"
    ]

    # Open video capture for each stream
    caps = [capture_frame_from_hls(url) for url in hls_urls]

    while True:
        frames = []
        for i, cap in enumerate(caps):
            ret, frame = cap.read()
            if not ret:
                print(f"Failed to read frame from camera {i + 1}")
                break

            # Perform YOLO detection and draw bounding boxes
            processed_frame = yolo_process(frame, model)
            frames.append(processed_frame)

        # Break if any stream fails
        if len(frames) != len(caps):
            break

        # Display frames in separate windows
        for i, frame in enumerate(frames):
            cv2.imshow(f"Camera {i + 1}", frame)

        # Exit on 'q' key press
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    # Release video captures and close windows
    for cap in caps:
        cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()