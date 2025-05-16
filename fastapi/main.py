import os
import uuid
import google.generativeai as genai
from dotenv import load_dotenv
load_dotenv()
from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, HTTPException, File, UploadFile
from pydantic import BaseModel, Field
from typing import List, Optional
from translate import translate
from topic_recommeder import recommend_topics
from firebase_utils import db
from roleplaying_order import simulate_order
from search_locate import ask_photo_location
from meetup_comments import generate_comment
from culture import get_cultural_differences
from freetalking import simulate_freetalking
from travel_phrases import generate_scenario_phrases

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],           
    allow_credentials=True,
    allow_methods=["*"],            
    allow_headers=["*"],            
)

GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
genai.configure(api_key=GOOGLE_API_KEY)


@app.get("/")
def print_hello():
    return "Solution Challenge"


class InputText(BaseModel):
    text: str

@app.post("/translate")
async def get_translate(input: InputText):
    translated = translate(input.text)
    return {"message": translated}


@app.get("/topics")
async def get_topics(count: int = 5):
    topics = recommend_topics(count)
    if not topics:
        raise HTTPException(status_code=500, detail="An error occurred while recommending topics.")
    return {"topics": topics}


class RoleplayRequest(BaseModel):
    text: str
    history: Optional[List[str]] = Field(
        None,
        description="List of previous dialogue history (e.g., ['User: ...', 'Clerk: ...', ...])"
    )

class RoleplayResponse(BaseModel):
    message: str
    history: List[str]

@app.post("/roleplay", response_model=RoleplayResponse)
async def roleplay_endpoint(req: RoleplayRequest):
    try:
        reply, updated_history = simulate_order(req.text, req.history)
        return {"message": reply, "history": updated_history}
    except Exception:
        raise HTTPException(status_code=500, detail="Roleplay error occurred.")


@app.post("/locate")
async def locate_endpoint(file: UploadFile = File(...)):
    ext = os.path.splitext(file.filename)[1]
    temp_file = f"/tmp/{uuid.uuid4()}{ext}"
    try:
        contents = await file.read()
        with open(temp_file, "wb") as f:
            f.write(contents)

        location_only, full_text = ask_photo_location(temp_file)
        return {
            "location": location_only,
            "recommendation": full_text
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if os.path.exists(temp_file):
            os.remove(temp_file)
            

class CommentRequest(BaseModel):
    event_id: str = Field(..., description="Meetup post document ID")
    user_id:  str = Field(..., description="User document ID")

@app.post("/comments")
async def comments_endpoint(req: CommentRequest):
    try:
        ai_comment = generate_comment(req.event_id, req.user_id)
        return {"comment": ai_comment}
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate comment: {e}")
    
@app.get("/culture")
async def culture_endpoint(home: str, dest: str):
    try:
        description = get_cultural_differences(home, dest)
        return {"description": description}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve cultural differences: {e}")
    

class FreeTalkRequest(BaseModel):
    text: str = Field(..., description="Latest user utterance")
    history: Optional[List[str]] = Field(
        None,
        description="Previous conversation history (e.g., ['User: ...', 'Hatchy: ...', ...])"
    )

class FreeTalkResponse(BaseModel):
    message: str
    history: List[str]

@app.post("/free-talk", response_model=FreeTalkResponse)
async def free_talk_endpoint(req: FreeTalkRequest):
    try:
        reply, updated_history = simulate_freetalking(req.text, req.history)
        return {"message": reply, "history": updated_history}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Free-talking error occurred: {e}")
    

class ScenarioPhrasesRequest(BaseModel):
    request: str = Field(..., description="e.g.: 'Expressions used when checking baggage at the airport in Korean'")

class ScenarioPhrasesResponse(BaseModel):
    phrases: str = Field(..., description="Block of essential travel phrases composed in three-line format")

@app.post("/phrases", response_model=ScenarioPhrasesResponse)
async def scenario_phrases_endpoint(req: ScenarioPhrasesRequest):
    try:
        text_block = generate_scenario_phrases(req.request)
        return {"phrases": text_block}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating phrases: {e}")
