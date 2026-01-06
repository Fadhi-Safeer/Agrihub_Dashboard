import json
from pathlib import Path
from typing import Any, Dict

import joblib
import pandas as pd
from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse

router = APIRouter()

# -----------------------------

BASE_DIR = Path(__file__).resolve().parent
DATA_JSON_PATH = BASE_DIR / "Data" / "Data.json"


# Cache model in memory
_PRED_MODEL = None


# -----------------------------
# Helpers: read/write Data.json
# -----------------------------
def _read_data_json() -> Dict[str, Any]:
    if not DATA_JSON_PATH.exists():
        raise HTTPException(
            status_code=404,
            detail=f"Data.json not found at: {DATA_JSON_PATH}",
        )

    try:
        raw = DATA_JSON_PATH.read_text(encoding="utf-8")
        data = json.loads(raw)
        if not isinstance(data, dict):
            raise ValueError("Root JSON must be an object.")
        return data
    except json.JSONDecodeError as e:
        raise HTTPException(status_code=500, detail=f"Data.json invalid JSON: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed reading Data.json: {e}")


def _atomic_write_json(path: Path, data: Dict[str, Any]) -> None:
    tmp = path.with_suffix(".tmp")
    tmp.write_text(json.dumps(data, indent=2), encoding="utf-8")
    tmp.replace(path)


# -----------------------------
# Helpers: model loading
# -----------------------------
def _get_prediction_model_path() -> Path:
    data = _read_data_json()

    model_section = data.get("Model")
    if not isinstance(model_section, dict):
        raise HTTPException(status_code=500, detail="Data.json missing 'Model' object.")

    pred = model_section.get("Prediction")
    if not isinstance(pred, dict):
        raise HTTPException(status_code=500, detail="Data.json missing 'Model.Prediction' object.")

    model_path = pred.get("path")
    if not isinstance(model_path, str) or not model_path.strip():
        raise HTTPException(status_code=500, detail="'Model.Prediction.path' must be a non-empty string.")

    # user said this relative path works from current working directory
    return Path(model_path)


def _load_prediction_model():
    global _PRED_MODEL
    if _PRED_MODEL is not None:
        return _PRED_MODEL

    model_path = _get_prediction_model_path()
    try:
        _PRED_MODEL = joblib.load(model_path)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to load prediction model from '{model_path}': {e}")

    return _PRED_MODEL


# -----------------------------
# Helpers: defaults mapping
# -----------------------------
def _get_default_growth_day(data: Dict[str, Any]) -> int:
    # Optional key: "Growth Day"
    gd = data.get("Growth Day", 0)
    if isinstance(gd, (int, float)):
        return int(round(gd))
    return 0


def _get_default_npk(data: Dict[str, Any]) -> Dict[str, int]:
    npk = data.get("NPK")
    if not isinstance(npk, dict):
        raise HTTPException(status_code=500, detail="Data.json missing 'NPK' object.")

    # Backward-compatible: you previously had typo "Notrogen"
    n_val = npk.get("Nitrogen", npk.get("Notrogen"))
    p_val = npk.get("Phosphorus")
    k_val = npk.get("Potassium")

    if not isinstance(n_val, (int, float)):
        raise HTTPException(status_code=500, detail="NPK.Nitrogen (or Notrogen) must be a number.")
    if not isinstance(p_val, (int, float)):
        raise HTTPException(status_code=500, detail="NPK.Phosphorus must be a number.")
    if not isinstance(k_val, (int, float)):
        raise HTTPException(status_code=500, detail="NPK.Potassium must be a number.")

    return {
        "Nitrogen": int(round(n_val)),
        "Phosphorus": int(round(p_val)),
        "Potassium": int(round(k_val)),
    }


def _validate_payload_numbers(payload: Dict[str, Any]) -> tuple[int, int, int, int]:
    growth_day = payload.get("growth_day")
    npk = payload.get("npk")

    if not isinstance(growth_day, (int, float)):
        raise HTTPException(status_code=400, detail="'growth_day' must be a number.")
    if not isinstance(npk, dict):
        raise HTTPException(status_code=400, detail="'npk' must be an object.")

    n = npk.get("Nitrogen", npk.get("Notrogen"))
    p = npk.get("Phosphorus")
    k = npk.get("Potassium")

    if not isinstance(n, (int, float)) or not isinstance(p, (int, float)) or not isinstance(k, (int, float)):
        raise HTTPException(status_code=400, detail="NPK values must be numbers.")

    return (
        int(round(growth_day)),
        int(round(n)),
        int(round(p)),
        int(round(k)),
    )


# -----------------------------
# API: get/set defaults for page
# -----------------------------
@router.get("/config/prediction-defaults")
async def get_prediction_defaults():
    """
    Returns:
    {
      "growth_day": 10,
      "npk": {"Nitrogen": 140, "Phosphorus": 50, "Potassium": 250}
    }
    """
    data = _read_data_json()
    return {
        "growth_day": _get_default_growth_day(data),
        "npk": _get_default_npk(data),
    }


@router.put("/config/prediction-defaults")
async def update_prediction_defaults(payload: Dict[str, Any]):
    """
    Payload:
    {
      "growth_day": 10,
      "npk": {"Nitrogen": 140, "Phosphorus": 50, "Potassium": 250}
    }

    Writes into Data.json:
    - "Growth Day"
    - "NPK"
    """
    if not isinstance(payload, dict):
        raise HTTPException(status_code=400, detail="Payload must be a JSON object.")

    growth_day, n, p, k = _validate_payload_numbers(payload)

    data = _read_data_json()
    data["Growth Day"] = growth_day
    data["NPK"] = {
        "Nitrogen": n,
        "Phosphorus": p,
        "Potassium": k,
    }

    try:
        _atomic_write_json(DATA_JSON_PATH, data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed writing Data.json: {e}")

    return {"status": "ok"}


# -----------------------------
# API: prediction
# -----------------------------
@router.post("/predict/yield")
async def predict_yield(payload: Dict[str, Any]):
    """
    Payload:
    {
      "growth_day": 10,
      "npk": {"Nitrogen": 140, "Phosphorus": 50, "Potassium": 250}
    }

    Output:
    { "fresh_mass_g": 123.45 }
    """
    if not isinstance(payload, dict):
        raise HTTPException(status_code=400, detail="Payload must be a JSON object.")

    growth_day, n, p, k = _validate_payload_numbers(payload)

    model = _load_prediction_model()

    # MUST match training feature names EXACTLY:
    # ['Growth Day', 'Lifetime Avg [N]', 'Lifetime Avg [P]', 'Lifetime Avg [K]']
    X = pd.DataFrame(
        [
            {
                "Growth Day": float(growth_day),
                "Lifetime Avg [N]": float(n),
                "Lifetime Avg [P]": float(p),
                "Lifetime Avg [K]": float(k),
            }
        ]
    )

    try:
        pred = model.predict(X)
        fresh_mass_g = float(pred[0])
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction failed: {e}")

    return JSONResponse(content={"fresh_mass_g": fresh_mass_g})
