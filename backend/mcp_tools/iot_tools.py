# backend/mcp_tools/iot_tools.py

"""
IoT Environment Trends Tool (Firestore-backed)

Reads Firestore data from:
  artifacts / APP_ID / devices / <device_id> / device_history

Summarises last N days of:
  - Temperature
  - Humidity
  - Soil Moisture

You can test this later once Firestore quota is available again.
"""

from datetime import datetime, timedelta
from typing import Optional, List
from pathlib import Path
import sys

# ✅ Make sure the backend folder is on sys.path so we can import keys.app_config
BACKEND_ROOT = Path(__file__).resolve().parents[1]
if str(BACKEND_ROOT) not in sys.path:
    sys.path.insert(0, str(BACKEND_ROOT))

from google.cloud import firestore
from keys.app_config import APP_ID # now we import from 'keys', not 'backend.keys'



# =========================================================
#  Firestore Client (using your service account key)
# =========================================================

# Resolve the backend/ directory from this file's location
ROOT_DIR = Path(__file__).resolve().parents[1]
print("ROOT_DIR:", ROOT_DIR)
# Path to your service account key (DO NOT COMMIT THE JSON ITSELF)
SERVICE_ACCOUNT_PATH = ROOT_DIR / "keys" / "firestore_key.json"

# Create Firestore client from the service account JSON
db = firestore.Client.from_service_account_json(str(SERVICE_ACCOUNT_PATH))


# =========================================================
#  Helper
# =========================================================

def _summary(values: List[float]) -> Optional[dict]:
    """Return avg/min/max for a list of floats, or None if empty."""
    if not values:
        return None
    return {
        "avg": sum(values) / len(values),
        "min": min(values),
        "max": max(values),
    }


# =========================================================
#  MAIN TOOL
# =========================================================

def get_environment_trends(days: int = 14) -> dict:
    """
    Summarize environment readings for the last `days` days across ALL devices.

    Firestore path:
      artifacts / APP_ID / devices / <device_id> / device_history

    For each device_history document we look under "readings" for:
      - Temperature: "Temperature", "environment_temperature", "temp", "temperature"
      - Humidity:    "Humidity", "environment_humidity", "hum", "humidity"
      - Soil:        "Soil Moisture", "Soil_Moisture", "soil_moisture",
                     "soilMoisture", "moisture"

    Returns a dict like:
      {
        "days": 14,
        "temperature": {"avg": 23.5, "min": 21.0, "max": 26.0} or None,
        "humidity":    {"avg": 58.0, "min": 50.0, "max": 65.0} or None,
        "soil_moisture": {...} or None
      }
    """

    cutoff = datetime.now() - timedelta(days=days)

    temps: List[float] = []
    hums: List[float] = []
    soils: List[float] = []

    # artifacts / APP_ID / devices
    devices_ref = (
        db.collection("artifacts")
        .document(APP_ID)
        .collection("devices")
    )

    # Limit to a reasonable number of devices so we don't read too much at once
    devices = devices_ref.limit(20).stream()

    for device in devices:
        device_id = device.id

        history_ref = (
            devices_ref
            .document(device_id)
            .collection("device_history")
            .where("timestamp", ">=", cutoff)
            .limit(500)  # safety limit per device
        )

        # Note: when quota is exceeded, this call may hang until quota resets.
        docs = history_ref.stream()

        for doc in docs:
            data = doc.to_dict() or {}
            readings = data.get("readings") or {}

            # Temperature
            temp = (
                readings.get("Temperature")
                or readings.get("environment_temperature")
                or readings.get("temp")
                or readings.get("temperature")
            )

            # Humidity
            hum = (
                readings.get("Humidity")
                or readings.get("environment_humidity")
                or readings.get("hum")
                or readings.get("humidity")
            )

            # Soil moisture
            soil = (
                readings.get("Soil Moisture")
                or readings.get("Soil_Moisture")
                or readings.get("soil_moisture")
                or readings.get("soilMoisture")
                or readings.get("moisture")
            )

            if isinstance(temp, (int, float)):
                temps.append(float(temp))
            if isinstance(hum, (int, float)):
                hums.append(float(hum))
            if isinstance(soil, (int, float)):
                soils.append(float(soil))

    return {
        "days": days,
        "temperature": _summary(temps),
        "humidity": _summary(hums),
        "soil_moisture": _summary(soils),
    }

