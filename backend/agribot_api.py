"""
Agribot AI Assistant

Everything in one file:
 - Reads Gemini API key from backend/keys/gemini_key.json
 - Calls your real backend tools
 - Exposes FastAPI routes:

    GET  /agribot/health
    POST /agribot/message
    DELETE /agribot/history
"""

import json
from pathlib import Path
from datetime import datetime, timezone
from typing import Dict, Any

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from google import genai
from google.genai import types

# --- Your backend tools ---
from mcp_tools.vision_tools import (
    get_overall_status,
    get_disease_overview,
)
from mcp_tools.iot_tools import (
    get_environment_trends,
)


# =========================================================
#  LOAD GEMINI API KEY
# =========================================================
KEY_FILE = Path(__file__).resolve().parent / "keys" / "gemini_key.json"

if not KEY_FILE.exists():
    raise RuntimeError(f"❌ Gemini key file missing: {KEY_FILE}")

with open(KEY_FILE, "r") as f:
    api_data = json.load(f)

API_KEY = api_data.get("key")

if not API_KEY:
    raise RuntimeError("❌ No API key found in gemini_key.json")

client = genai.Client(api_key=API_KEY)


# =========================================================
#  INTERNAL: Build farm context JSON
# =========================================================
def _build_context(days: int = 14) -> Dict[str, Any]:
    return {
        "window_days": days,
        "overall_status": get_overall_status(days),
        "disease_overview": get_disease_overview(days),
        "environment_trends": get_environment_trends(days),
    }


# =========================================================
#  MAIN AI FUNCTION
# =========================================================
def ask_agribot(question: str, days: int = 14) -> str:
    context = _build_context(days)
    ctx_json = json.dumps(context, indent=2)

    prompt = (
        "You are Agribot — a friendly assistant for a smart agriculture dashboard.\n"
        "Use ONLY the JSON data given. Do not invent numbers.\n"
        "Explain clearly and simply. Avoid technical jargon.\n"
        "Focus on overall farm trends, not plant IDs.\n\n"
        f"=== FARM CONTEXT JSON (last {days} days) ===\n"
        f"{ctx_json}\n\n"
        f"=== USER QUESTION ===\n"
        f"{question}\n\n"
        "If information is missing, say so instead of guessing."
    )

    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=[types.Content(
            role="user",
            parts=[types.Part.from_text(prompt)]
        )],
    )

    return response.text or "Sorry, I couldn’t generate a response."


# =========================================================
#  FASTAPI ROUTER — PUBLIC API
# =========================================================
router = APIRouter(
    prefix="/agribot",
    tags=["Agribot"],
)


class AgribotMessageRequest(BaseModel):
    message: str
    days: int | None = 14


class AgribotMessageResponse(BaseModel):
    response: str
    timestamp: str


@router.get("/health")
async def agribot_health():
    return {"status": "ok"}


@router.post("/message", response_model=AgribotMessageResponse)
async def agribot_message(payload: AgribotMessageRequest):
    msg = (payload.message or "").strip()
    if not msg:
        raise HTTPException(status_code=400, detail="Message cannot be empty.")

    days = payload.days or 14
    if days <= 0:
        raise HTTPException(status_code=400, detail="'days' must be positive.")

    try:
        answer = ask_agribot(msg, days)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Agribot error: {e}")

    ts = datetime.now(timezone.utc).isoformat()

    return AgribotMessageResponse(
        response=answer,
        timestamp=ts
    )


@router.delete("/history")
async def agribot_clear_history():
    return {"status": "cleared"}
