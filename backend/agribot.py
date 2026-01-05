# main.py
from fastapi import FastAPI
from pydantic import BaseModel
import requests
import uvicorn
# -------------------------
# 🔹 CHANGE THESE VALUES
# -------------------------
BOT_ID = "328c19c1-72f5-4cf0-8c36-48b8eb394c8a"   # Your Botpress Bot ID
API_KEY = "bp_bak_DAzgPBexKuVYEPyB3GRTwNisEMzNDG5FtP-E"            # Your Botpress API Key
BOTPRESS_URL = "https://api.botpress.cloud/v1/chat/messages"
# -------------------------

app = FastAPI(title="Botpress Chatbot API")

# Request body model
class ChatRequest(BaseModel):
    user_id: str   # Unique ID for user conversation
    message: str   # Message sent by user

# Chat endpoint
@app.post("/chat")
def chat(req: ChatRequest):
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }

    payload = {
        "botId": BOT_ID,
        "conversationId": req.user_id,
        "type": "text",
        "text": req.message
    }

    try:
        response = requests.post(BOTPRESS_URL, headers=headers, json=payload)
        response.raise_for_status()  # Raise error if request failed
        data = response.json()

        # Extract Bot reply (may vary depending on Botpress response format)
        if "responses" in data and len(data["responses"]) > 0:
            bot_reply = data["responses"][0]["payload"].get("text", "")
        else:
            bot_reply = "Bot did not reply."

        return {"bot_reply": bot_reply}

    except requests.exceptions.RequestException as e:
        return {"error": str(e)}

#
