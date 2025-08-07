from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import openai
import os
from typing import Optional, List
import asyncio
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="AgriBot Backend API",
    description="Backend service for AgriBot chatbot with ChatGPT integration",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your Flutter app's domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Set up OpenAI API key
openai.api_key = ""

if not openai.api_key:
    logger.warning("OpenAI API key not found. Please set OPENAI_API_KEY environment variable.")

# Pydantic models
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

# In-memory storage for conversation history (in production, use a database)
conversation_history = {}

# AgriBot system prompt
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

@app.get("/", response_model=HealthCheck)
async def health_check():
    """Health check endpoint"""
    return HealthCheck(
        status="healthy",
        timestamp=datetime.now(),
        version="1.0.0"
    )

@app.post("/chat", response_model=ChatResponse)
async def chat_with_agribot(message: ChatMessage):
    """
    Main chat endpoint that processes user messages and returns AgriBot responses
    """
    try:
        if not openai.api_key:
            raise HTTPException(
                status_code=500,
                detail="OpenAI API key not configured"
            )

        # Get or create conversation history for this session
        session_id = message.session_id or "default"
        if session_id not in conversation_history:
            conversation_history[session_id] = [
                {"role": "system", "content": AGRIBOT_SYSTEM_PROMPT}
            ]

        # Add user message to conversation history
        conversation_history[session_id].append({
            "role": "user",
            "content": message.message
        })

        # Keep only last 10 messages to manage token usage
        if len(conversation_history[session_id]) > 21:  # 1 system + 20 messages
            conversation_history[session_id] = [
                conversation_history[session_id][0]  # Keep system prompt
            ] + conversation_history[session_id][-20:]  # Keep last 20 messages

        # Call OpenAI API
        response = await get_chatgpt_response(conversation_history[session_id])

        # Add assistant response to conversation history
        conversation_history[session_id].append({
            "role": "assistant",
            "content": response
        })

        return ChatResponse(
            response=response,
            timestamp=datetime.now(),
            success=True
        )

    except Exception as e:
        logger.error(f"Error in chat endpoint: {str(e)}")
        return ChatResponse(
            response="I apologize, but I'm experiencing technical difficulties. Please try again later.",
            timestamp=datetime.now(),
            success=False,
            error=str(e)
        )

async def get_chatgpt_response(messages: List[dict]) -> str:
    try:
        loop = asyncio.get_event_loop()
        response = await loop.run_in_executor(
            None,
            lambda: openai.ChatCompletion.create(
                model="gpt-3.5-turbo",
                messages=messages,
                max_tokens=500,
                temperature=0.7,
                top_p=0.9,
                frequency_penalty=0.0,
                presence_penalty=0.0
            )
        )
        return response.choices[0].message.content.strip()

    except openai.RateLimitError:
        return "I'm currently experiencing high traffic. Please try again in a moment."

    except openai.APIError as e:
        logger.error(f"OpenAI API error: {str(e)}")
        return "I'm having trouble connecting to my knowledge base. Please try again."

    except Exception as e:
        logger.error(f"Unexpected error in ChatGPT call: {str(e)}")
        return "I encountered an unexpected error. Please try again later."


@app.post("/chat/clear")
async def clear_conversation(session_id: str = "default"):
    """
    Clear conversation history for a specific session
    """
    try:
        if session_id in conversation_history:
            conversation_history[session_id] = [
                {"role": "system", "content": AGRIBOT_SYSTEM_PROMPT}
            ]
        
        return {"message": "Conversation history cleared", "success": True}
    
    except Exception as e:
        logger.error(f"Error clearing conversation: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to clear conversation")

@app.get("/chat/history/{session_id}")
async def get_conversation_history(session_id: str):
    """
    Get conversation history for a specific session (excluding system prompt)
    """
    try:
        if session_id not in conversation_history:
            return {"messages": [], "success": True}
        
        # Return messages excluding the system prompt
        messages = conversation_history[session_id][1:]  # Skip system prompt
        return {"messages": messages, "success": True}
    
    except Exception as e:
        logger.error(f"Error retrieving conversation history: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to retrieve conversation history")

@app.get("/status")
async def get_status():
    """
    Get API status and configuration
    """
    return {
        "status": "running",
        "openai_configured": bool(openai.api_key),
        "active_sessions": len(conversation_history),
        "timestamp": datetime.now()
    }

# Run the server
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "agribot:app",
        host="0.0.0.0",
        port=8075,
        reload=True,
        log_level="info"
    )