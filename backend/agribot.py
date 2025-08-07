from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import google.generativeai as genai
import asyncio
from datetime import datetime
from typing import Optional, List
import logging
import os

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("agribot")

# Configure Gemini API
GENAI_API_KEY = "AIzaSyBFV-AVjv_T4SFlHpSaaDH5w6co_emZfLs"  # Replace if not using env
genai.configure(api_key=GENAI_API_KEY)
model = genai.GenerativeModel(model_name="gemini-pro")

# Initialize FastAPI app
app = FastAPI(
    title="AgriBot Backend API",
    description="Backend service for AgriBot chatbot with Gemini integration",
    version="1.0.0"
)

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic Models
class ChatMessage(BaseModel):
    message: str
    user_id: Optional[str] = None
    session_id: Optional[str] = None

class ChatResponse(BaseModel):
    response: str
    timestamp: datetime
    success: bool
    error: Optional[str] = None

class HealthCheck(BaseModel):
    status: str
    timestamp: datetime
    version: str

# In-memory conversation history
conversation_history = {}

# System prompt
AGRIBOT_SYSTEM_PROMPT = """
You are AgriBot, a helpful and knowledgeable agricultural assistant. You specialize in:

1. Crop management and farming techniques
2. Soil health and fertilization
3. Pest and disease control
4. Weather and climate considerations
5. Sustainable farming practices
6. Agricultural technology and equipment
7. Market prices and agricultural economics
8. Irrigation and water management

Guidelines:
- Always provide accurate, practical agricultural advice
- Be friendly and approachable
- If you're unsure about something, recommend consulting with local agricultural experts
- Focus on sustainable and environmentally friendly practices
- Adapt advice to different farming scales (small-scale to commercial)
- Consider regional differences in climate and soil conditions
- Always prioritize farmer safety and environmental protection

Keep responses concise but informative, and ask follow-up questions when needed to provide better assistance.
"""

# Root health check
@app.get("/", response_model=HealthCheck)
async def health_check():
    return HealthCheck(
        status="healthy",
        timestamp=datetime.now(),
        version="1.0.0"
    )

# Chat endpoint
@app.post("/chat", response_model=ChatResponse)
async def chat_with_agribot(message: ChatMessage):
    try:
        session_id = message.session_id or "default"
        if session_id not in conversation_history:
            conversation_history[session_id] = [
                {"role": "system", "content": AGRIBOT_SYSTEM_PROMPT}
            ]

        # Append user message
        conversation_history[session_id].append({
            "role": "user",
            "content": message.message
        })

        # Trim history to max 20 messages (plus system)
        if len(conversation_history[session_id]) > 21:
            conversation_history[session_id] = [
                conversation_history[session_id][0]
            ] + conversation_history[session_id][-20:]

        # Get response
        response_text = await get_gemini_response(conversation_history[session_id])

        # Append bot response
        conversation_history[session_id].append({
            "role": "assistant",
            "content": response_text
        })

        return ChatResponse(
            response=response_text,
            timestamp=datetime.now(),
            success=True
        )

    except Exception as e:
        logger.error(f"Chat error: {str(e)}")
        return ChatResponse(
            response="I encountered a technical issue. Please try again later.",
            timestamp=datetime.now(),
            success=False,
            error=str(e)
        )

# Gemini response logic
async def get_gemini_response(messages: List[dict]) -> str:
    try:
        # Gemini expects plain prompt parts, not role-prefix strings
        formatted = []
        for m in messages:
            formatted.append({"role": m["role"], "parts": [m["content"]]})

        # Call Gemini in separate thread to avoid blocking FastAPI event loop
        loop = asyncio.get_event_loop()
        response = await loop.run_in_executor(
            None, lambda: model.generate_content(formatted)
        )
        return response.text.strip()

    except Exception as e:
        logger.error(f"Gemini API error: {str(e)}")
        return "There was a problem processing your request."

# Clear chat history
@app.post("/chat/clear")
async def clear_conversation(session_id: str = "default"):
    try:
        conversation_history[session_id] = [
            {"role": "system", "content": AGRIBOT_SYSTEM_PROMPT}
        ]
        return {"message": "Conversation history cleared.", "success": True}
    except Exception as e:
        logger.error(f"Clear error: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to clear conversation")

# Retrieve chat history
@app.get("/chat/history/{session_id}")
async def get_conversation_history(session_id: str):
    try:
        if session_id not in conversation_history:
            return {"messages": [], "success": True}
        return {
            "messages": conversation_history[session_id][1:],  # Skip system
            "success": True
        }
    except Exception as e:
        logger.error(f"History error: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to retrieve history")

# Status endpoint
@app.get("/status")
async def get_status():
    return {
        "status": "running",
        "gemini_configured": bool(GENAI_API_KEY),
        "active_sessions": len(conversation_history),
        "timestamp": datetime.now()
    }

# For direct run
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="127.0.0.1", port=8075, reload=True)
