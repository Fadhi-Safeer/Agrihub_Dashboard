import json
import shutil
from pathlib import Path
from typing import Any, Dict

from fastapi import APIRouter, HTTPException, UploadFile, File, Query
from fastapi.responses import JSONResponse

router = APIRouter()

# =========================================================
# 1) MODEL UPLOAD CONFIG
# =========================================================
MODELS_DIR = Path(
    r"C:\Users\Fadhi Safeer\OneDrive\Documents\Internship\Agri hub\backend\Models"
)
MODELS_DIR.mkdir(parents=True, exist_ok=True)

TYPE_TO_FILENAME = {
    "Detection": "LETTUCE_DETECTION_MODEL.pt",
    "Growth": "GROWTH_CLASSIFICATION_MODEL.pt",
    "Health": "HEALTH_CLASSIFICATION_MODEL.pt",
    "Disease": "DISEASE_CLASSIFICATION_MODEL.pt",
    "Prediction": "lettuce_model.joblib",
}

@router.post("/upload-model")
async def get_model(
    type: str = Query(...),
    file: UploadFile = File(...),
):
    """
    Upload a model file and overwrite the correct fixed file in MODELS_DIR.
    Returns the saved backend path as a string for Flutter to store.
    """
    if type not in TYPE_TO_FILENAME:
        return JSONResponse({"error": "Invalid type"}, status_code=400)

    save_name = TYPE_TO_FILENAME[type]
    save_path = MODELS_DIR / save_name

    with open(save_path, "wb") as f:
        shutil.copyfileobj(file.file, f)

    return {"path": str(save_path)}


# =========================================================
# 2) DATA.JSON READ/WRITE HELPERS
# =========================================================
# backend\Data.json (same folder as this file)
DATA_JSON_PATH = Path(__file__).resolve().parent / "Data.json"

def _read_data_json() -> Dict[str, Any]:
    if not DATA_JSON_PATH.exists():
        raise HTTPException(
            status_code=404,
            detail=f"Data.json not found at: {DATA_JSON_PATH}",
        )

    try:
        text = DATA_JSON_PATH.read_text(encoding="utf-8")
        data = json.loads(text)
        if not isinstance(data, dict):
            raise ValueError("Root must be a JSON object.")
        return data
    except json.JSONDecodeError as e:
        raise HTTPException(status_code=500, detail=f"Data.json invalid JSON: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed reading Data.json: {e}")

def _atomic_write_json(path: Path, data: Dict[str, Any]) -> None:
    tmp_path = path.with_suffix(".tmp")
    tmp_path.write_text(json.dumps(data, indent=2), encoding="utf-8")
    tmp_path.replace(path)


# =========================================================
# 3) MODEL CONFIG ENDPOINTS (Data.json -> "Model")
# =========================================================
@router.get("/config/models")
async def get_model_config():
    """
    Returns ONLY the Model section from Data.json.
    """
    data = _read_data_json()

    model_section = data.get("Model")
    if not isinstance(model_section, dict):
        raise HTTPException(status_code=500, detail="Data.json missing 'Model' object.")

    return JSONResponse(content=model_section)


@router.put("/config/models")
async def update_model_config(payload: Dict[str, Any]):
    """
    Expects payload like:
    {
      "Detection": {"path": "...", "confidence": 0.65},
      "Growth": {"path": "...", "confidence": 0.80},
      ...
    }
    Writes into Data.json under the 'Model' key.
    """
    if not isinstance(payload, dict):
        raise HTTPException(status_code=400, detail="Payload must be a JSON object.")

    required_models = ["Detection", "Growth", "Health", "Disease", "Prediction"]
    for key in required_models:
        if key not in payload or not isinstance(payload[key], dict):
            raise HTTPException(status_code=400, detail=f"Missing or invalid model key: {key}")

        m = payload[key]
        if "path" not in m or not isinstance(m["path"], str) or not m["path"].strip():
            raise HTTPException(status_code=400, detail=f"{key}.path must be a non-empty string")
        if "confidence" not in m or not isinstance(m["confidence"], (int, float)):
            raise HTTPException(status_code=400, detail=f"{key}.confidence must be a number")

    data = _read_data_json()
    data["Model"] = payload

    try:
        _atomic_write_json(DATA_JSON_PATH, data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed writing Data.json: {e}")

    return {"status": "ok"}


# =========================================================
# 4) IMAGE FOLDER ENDPOINTS (Data.json -> "Image Folder")
# =========================================================
@router.get("/config/image-folder")
async def get_image_folder():
    data = _read_data_json()

    # supports old key name too
    folder = data.get("Image Folder") or data.get("Images Folder")
    if not isinstance(folder, dict):
        raise HTTPException(status_code=500, detail="Data.json missing 'Image Folder' object.")

    path = folder.get("path")
    if not isinstance(path, str):
        raise HTTPException(status_code=500, detail="'Image Folder.path' must be a string.")

    return {"path": path}


@router.put("/config/image-folder")
async def update_image_folder(payload: Dict[str, Any]):
    if not isinstance(payload, dict):
        raise HTTPException(status_code=400, detail="Payload must be a JSON object.")

    path = payload.get("path")
    if not isinstance(path, str) or not path.strip():
        raise HTTPException(status_code=400, detail="Field 'path' must be a non-empty string.")

    data = _read_data_json()

    data["Image Folder"] = {"path": path}

    # remove old key if present
    if "Images Folder" in data:
        del data["Images Folder"]

    try:
        _atomic_write_json(DATA_JSON_PATH, data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed writing Data.json: {e}")

    return {"status": "ok"}
