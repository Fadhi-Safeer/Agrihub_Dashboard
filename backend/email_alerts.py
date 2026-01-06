# alert_emails.py
import os
import json
import ssl
import smtplib
import threading
from pathlib import Path
from datetime import datetime, timedelta
from email.message import EmailMessage
from typing import Optional, List, Dict

import cv2
import numpy as np

# ✅ Correct path (as you confirmed)
DATA_JSON_PATH = Path("backend/Data/Data.json")

# 1 email per camera per 1 hour
_ALERT_INTERVAL = timedelta(hours=1)
_LAST_ALERT_SENT: Dict[str, datetime] = {}
_ALERT_LOCK = threading.Lock()


def _get_alert_recipients() -> List[str]:
    """
    Reads recipient emails from:
      Data.json -> "Alert Emails" -> "emails"
    """
    try:
        if not DATA_JSON_PATH.exists():
            print(f"[ALERT] Data.json not found: {DATA_JSON_PATH}")
            return []

        data = json.loads(DATA_JSON_PATH.read_text(encoding="utf-8"))
        emails = (data.get("Alert Emails") or {}).get("emails", [])

        if not isinstance(emails, list):
            return []

        cleaned = [e.strip() for e in emails if isinstance(e, str) and e.strip()]
        return cleaned
    except Exception as e:
        print(f"[ALERT] Failed to load alert recipients: {e}")
        return []


def _should_send_alert(camera_number: str) -> bool:
    """
    Throttle: max 1 email per camera per _ALERT_INTERVAL.
    """
    now = datetime.now()
    with _ALERT_LOCK:
        last = _LAST_ALERT_SENT.get(camera_number)
        if last and (now - last) < _ALERT_INTERVAL:
            return False
        _LAST_ALERT_SENT[camera_number] = now
        return True


def send_disease_alert_email(
    *,
    camera_number: str,
    plant_id: str,
    classification: dict,
    image_bgr: np.ndarray,
) -> bool:
    """
    Sends disease alert email (max 1 per camera per 1 hour).
    Attaches the cropped image directly.

    Uses SMTP creds from env vars:
      AGRIVISION_SMTP_USER
      AGRIVISION_SMTP_PASS
    Optional:
      AGRIVISION_SMTP_HOST (default: smtp.gmail.com)
      AGRIVISION_SMTP_PORT (default: 587)
    """
    recipients = _get_alert_recipients()
    if not recipients:
        print("[ALERT] No recipients found in Data.json -> Alert Emails -> emails")
        return False

    smtp_user = os.getenv("AGRIVISION_SMTP_USER")
    smtp_pass = os.getenv("AGRIVISION_SMTP_PASS")
    if not smtp_user or not smtp_pass:
        print("[ALERT] Missing env vars AGRIVISION_SMTP_USER / AGRIVISION_SMTP_PASS")
        return False

    if not _should_send_alert(str(camera_number)):
        # Throttled
        return False

    # Pull details from classification
    now = datetime.now()
    disease = str(classification.get("disease", "Unknown"))
    growth = str(classification.get("growth", "Unknown"))
    health = str(classification.get("health", "Unknown"))

    # Encode image to jpg bytes
    ok, buffer = cv2.imencode(".jpg", image_bgr)
    if not ok:
        print("[ALERT] Failed to encode image for email")
        return False

    msg = EmailMessage()
    msg["Subject"] = f"[AgriVision Alert] Disease detected - Camera {camera_number}"
    msg["From"] = smtp_user
    msg["To"] = ", ".join(recipients)

    msg.set_content(
        "Disease detected!\n\n"
        f"Time: {now.strftime('%Y-%m-%d %H:%M:%S')}\n"
        f"Camera: {camera_number}\n"
        f"Plant ID: {plant_id}\n"
        f"Disease: {disease}\n"
        f"Growth: {growth}\n"
        f"Health: {health}\n"
    )

    msg.add_attachment(
        buffer.tobytes(),
        maintype="image",
        subtype="jpeg",
        filename=f"{plant_id}.jpg",
    )

    host = os.getenv("AGRIVISION_SMTP_HOST", "smtp.gmail.com")
    port = int(os.getenv("AGRIVISION_SMTP_PORT", "587"))

    try:
        context = ssl.create_default_context()
        with smtplib.SMTP(host, port) as server:
            server.starttls(context=context)
            server.login(smtp_user, smtp_pass)
            server.send_message(msg)

        print(f"[ALERT] Email sent for camera {camera_number} ({plant_id})")
        return True

    except Exception as e:
        print(f"[ALERT] Email failed: {e}")
        return False
