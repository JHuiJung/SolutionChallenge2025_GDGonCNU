import google.generativeai as genai
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel ,Field
from typing import List, Literal, Optional
from translate import translate
from topic_recommeder import recommend_topics
from firebase_utils import db
from roleplaying_order import simulate_order

app = FastAPI()


GOOGLE_API_KEY = ""

genai.configure(api_key=GOOGLE_API_KEY)

@app.get("/firebase-health")
async def firebase_health():
    """
    Firestore에 연결이 되는지 확인하는 엔드포인트.
    - 컬렉션 목록을 가져오는데, 비어 있더라도 연결 성공으로 간주합니다.
    """
    try:
        # Firestore Python SDK 에서는 collections() 가 CollectionReference 제너레이터를 반환
        col_refs = db.collections()  
        # id만 뽑아서 리스트로 변환
        col_ids = [col.id for col in col_refs]
        return {
            "status": "connected",
            "collections": col_ids  # 비어 있으면 [] 가 반환됩니다
        }
    except Exception as e:
        # 예외가 난다면 연결에 문제가 있는 것
        raise HTTPException(
            status_code=500,
            detail=f"Firebase 연결 실패: {e}"
        )
        
# 루트 라우트
@app.get("/")
def printHello():
    return "Solution Challenge 크크크"


# 텍스트 입력 모델 정의
class InputText(BaseModel):
    text: str

# POST 요청으로 텍스트를 받아 ai 함수에 전달하는 라우트
@app.post("/translate")
async def get_translate(input: InputText):
    translated = translate(input.text)
    # 이제 "message" 하나만 반환합니다.
    return {"message": translated}


@app.get("/topics")
async def get_topics(count: int = 5):
    topics = recommend_topics(count)
    if not topics:
        raise HTTPException(status_code=500, detail="주제 추천 중 오류가 발생했습니다.")
    return {"topics": topics}


# --- 롤플레잉 엔드포인트 (컨텍스트 유지) ---
class RoleplayRequest(BaseModel):
    text: str
    history: Optional[List[str]] = Field(
        None,
        description="이전 대화 기록 목록 (['사용자: ...', '점원: ...', ...])"
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
        raise HTTPException(status_code=500, detail="롤플레잉 오류 발생")
