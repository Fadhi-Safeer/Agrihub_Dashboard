import asyncio
from zoneinfo import ZoneInfo
import cv2
import json
import base64
from ultralytics import YOLO
import torch
from backend.email_alerts import send_disease_alert_email
from storage import save_camera_view_frame, save_frame_locally, append_agrivision_row
from classification_mapper import ClassificationMapper
from datetime import datetime
from pathlib import Path

DATA_JSON_PATH = Path("backend/Data/Data.json")

now = datetime.now(ZoneInfo("Asia/Kuala_Lumpur"))


def _is_alert_time(now: datetime) -> bool:
    try:
        data = _read_data_json()
        hours_raw = data.get("Data_saving_time", {}).get("hours", [])
        alert_hours = {int(h) for h in hours_raw}  
    except Exception:
        alert_hours = {9, 12, 15, 18}  # fallback if json missing/broken

    return now.hour in alert_hours and now.minute < 10


def _read_data_json() -> dict:
    data = json.loads(DATA_JSON_PATH.read_text(encoding="utf-8"))
    return data


def _get_model_path_conf(data: dict, key: str):
    cfg = data["Model"][key]
    return cfg["path"], float(cfg["confidence"])


def _get_image_folder(data: dict) -> str:
    return data["Image Folder"]["path"]


device = torch.device("cuda" if torch.cuda.is_available() else "cpu")


class ModelManager:
    def __init__(self):
        self._last_mtime = None
        self.detection_model = None
        self.health_model = None
        self.growth_model = None
        self.disease_model = None
        self.det_conf = 0.6
        self.health_conf = 0.85
        self.growth_conf = 0.8
        self.disease_conf = 0.85
        self.image_folder = "backend/Images/"

    def ensure_loaded(self):
        mtime = DATA_JSON_PATH.stat().st_mtime
        if self._last_mtime == mtime and self.detection_model is not None:
            return

        data = _read_data_json()

        det_path, self.det_conf = _get_model_path_conf(data, "Detection")
        gro_path, self.growth_conf = _get_model_path_conf(data, "Growth")
        hea_path, self.health_conf = _get_model_path_conf(data, "Health")
        dis_path, self.disease_conf = _get_model_path_conf(data, "Disease")

        self.image_folder = _get_image_folder(data)

        self.detection_model = YOLO(det_path)
        self.growth_model = YOLO(gro_path).to(device)
        self.health_model = YOLO(hea_path).to(device)
        self.disease_model = YOLO(dis_path).to(device)

        self._last_mtime = mtime


MODELS = ModelManager()


# Function to capture a frame from the HLS stream
async def capture_frame_from_hls(hls_url):
    cap = cv2.VideoCapture(hls_url)

    if not cap.isOpened():
        raise Exception(f"Failed to open HLS stream from {hls_url}")
    ret, frame = cap.read()
    cap.release()
    if not ret:
        raise Exception("Failed to capture frame from HLS stream")

    return frame


async def get_cam_num(hls_url):
    return hls_url.split("/")[-1].split(".")[0]


# Existing YOLO detection process (Step 1)
async def yolo_detection(hls_url):
    # Time Interval
    await asyncio.sleep(3)
    frame = await capture_frame_from_hls(hls_url)
    save_camera_view_frame(frame, await get_cam_num(hls_url))

    # YOLO prediction with threshold moved to model
    MODELS.ensure_loaded()
    model = MODELS.detection_model

    results = model.predict(
        source=frame,
        imgsz=640,
        device=device,
        conf=MODELS.det_conf,
        verbose=False,
    )

    bounding_boxes = []

    for result in results:
        if result.boxes is None:
            continue  # No detections

        img_array = result.orig_img.copy()  # numpy array (BGR)

        for i, box in enumerate(result.boxes.data):
            if len(box) < 5:
                continue  # Ensure the box contains valid values

            x1, y1, x2, y2, conf = box[:5]
            class_id = int(result.boxes.cls[i])
            growth_label = model.names.get(class_id, "Unknown")

            if None in (x1, y1, x2, y2):
                continue

            # Convert to int for drawing and result
            x1, y1, x2, y2 = int(x1), int(y1), int(x2), int(y2)

            # Draw rectangle on image (BGR: green)
            cv2.rectangle(img_array, (x1, y1), (x2, y2), (0, 255, 0), 2)

            bounding_box = {
                "x1": x1,
                "y1": y1,
                "x2": x2,
                "y2": y2,
                "growth": growth_label,
            }
            bounding_boxes.append(bounding_box)

    return json.dumps(bounding_boxes, indent=4)


# Function to crop an image based on bounding box coordinates
def crop_image(frame, bounding_box):
    """
    bounding_box: Dictionary with keys 'x1', 'y1', 'x2', 'y2'
    """
    h, w, _ = frame.shape
    x1, y1, x2, y2 = (
        max(0, int(bounding_box["x1"])),
        max(0, int(bounding_box["y1"])),
        min(w, int(bounding_box["x2"])),
        min(h, int(bounding_box["y2"])),
    )

    cropped = frame[y1:y2, x1:x2]
    return cropped if cropped.size > 0 else None


async def classify_cropped_image(cropped_image):
    if cropped_image is None:
        return {"error": "Invalid cropped image"}

    cropped_image = cv2.cvtColor(cropped_image, cv2.COLOR_BGR2RGB)

    resized = cv2.resize(cropped_image, (224, 224))
    tensor = (
        torch.from_numpy(resized).permute(2, 0, 1).float().unsqueeze(0) / 255.0
    )

    MODELS.ensure_loaded()

    disease_result = MODELS.disease_model.predict(
        source=tensor,
        imgsz=224,
        device=device,
        conf=MODELS.disease_conf,
        verbose=False,
    )
    growth_result = MODELS.growth_model.predict(
        source=tensor,
        imgsz=224,
        device=device,
        conf=MODELS.growth_conf,
        verbose=False,
    )
    health_result = MODELS.health_model.predict(
        source=tensor,
        imgsz=224,
        device=device,
        conf=MODELS.health_conf,
        verbose=False,
    )

    classification = {
        "disease": (
            MODELS.disease_model.names[disease_result[0].probs.top1]
            if disease_result
            else "Unknown"
        ).replace("_", " "),
        "growth": (
            MODELS.growth_model.names[growth_result[0].probs.top1]
            if growth_result
            else "Unknown"
        ).replace("_", " "),
        "health": (
            MODELS.health_model.names[health_result[0].probs.top1]
            if health_result
            else "Unknown"
        ).replace("_", " "),
    }

    return classification


# Function to encode an image to Base64 string for transmission
def encode_image_to_base64(image):
    _, buffer = cv2.imencode(".jpg", image)
    jpg_as_text = base64.b64encode(buffer).decode("utf-8")
    return jpg_as_text


# Updated WebSocket server handler
async def handler(websoc):
    try:
        async for message in websoc:
            data = json.loads(message)
            hls_url = data.get("url")

            # Check if the request is detection-only (Step 1) or includes bounding boxes (Step 2)
            if "bounding_boxes" not in data:
                # Detection-only request
                bounding_boxes_json = await yolo_detection(hls_url)
                print("Detection completed")
                await websoc.send(bounding_boxes_json)

            else:
                # Cropping & Classification request
                bounding_boxes = data.get("bounding_boxes")
                frame = await capture_frame_from_hls(hls_url)
                results = []

                # ✅ Improvement: compute cam_num once
                cam_num = await get_cam_num(hls_url)

                for box in bounding_boxes:
                    cropped = crop_image(frame, box)
                    if cropped is None:
                        continue  # Skip if crop failed

                    classification = await classify_cropped_image(cropped)

                    print("Classification results:", classification)

                    # If classification contains "error", skip sending that result
                    if "error" in classification:
                        continue

                    plant_id = f"{cam_num}-{len(results)+1}"

                    # ✅ Improvement: protect Excel logging (won't break websocket if it fails)
                    try:
                        disease_label = str(classification.get("disease", "unknown"))
                        health_label  = str(classification.get("health", "unknown"))
                        disease_status = ClassificationMapper.get_disease_status(disease_label)        # 0/1/None
                        health_status  = ClassificationMapper.get_health_status_binary(health_label)   # 1/0/None
                        if _is_alert_time(now):

                            append_agrivision_row(
                                camera_number=str(cam_num),
                                plant_id=plant_id,
                                growth=str(classification.get("growth", "Unknown")),
                                health=health_label,
                                disease=disease_label,
                                disease_status = disease_status,          
                                health_status = health_status,     
                            )
                            
                            if disease_status == 1:
                                try:
                                    # run blocking smtp in a worker thread so websocket doesn't lag
                                    await asyncio.to_thread(
                                        send_disease_alert_email,
                                        camera_number=str(cam_num),
                                        plant_id=plant_id,
                                        classification=classification,
                                        image_bgr=cropped,  # cropped is BGR already
                                    )
                                except Exception as e:
                                    print(f"[ALERT] Failed to send email: {e}")


                    except Exception as e:
                        print(f"Excel logging failed: {e}")

                    MODELS.ensure_loaded()

                    if _is_alert_time(now):
                        save_frame_locally(
                            cropped,
                            cam_num,
                            classification,
                            base_dir=MODELS.image_folder,
                        )

                    encoded_image = encode_image_to_base64(cropped)

                    result_entry = {
                        "cropped_image": encoded_image,
                        "classification": classification,
                    }
                    results.append(result_entry)

                # Send empty array if no valid classification results
                response = json.dumps(results if results else [], indent=4)
                await websoc.send(response)

    except json.JSONDecodeError as e:
        error_message = {"error": f"JSON decode error: {str(e)}"}
        await websoc.send(json.dumps(error_message))
    except Exception as e:
        error_message = {"error": str(e)}
        await websoc.send(json.dumps(error_message))
