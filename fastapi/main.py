import os
import uuid
import google.generativeai as genai
from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, HTTPException, File, UploadFile
from pydantic import BaseModel ,Field
from typing import List, Literal, Optional
from translate import translate
from topic_recommeder import recommend_topics
from firebase_utils import db
from roleplaying_order import simulate_order
from search_locate import ask_photo_location
from meetup_comments import generate_comment
from culture import get_cultural_differences

app = FastAPI()

# CORS 허용 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],            # 혹은 ["http://localhost:3000", "http://192.168.0.2:8000"] 같이 특정 origin만
    allow_credentials=True,
    allow_methods=["*"],            # GET, POST, PUT 등
    allow_headers=["*"],            # Content-Type, Authorization 등
)

GOOGLE_API_KEY = "AIzaSyCqb3HHXZ3qgtPXsRA2tx2FYKQAZZ-oeHM"
genai.configure(api_key=GOOGLE_API_KEY)

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


@app.post("/locate")
async def locate_endpoint(file: UploadFile = File(...)):
    """
    클라이언트가 올린 이미지를 임시 저장한 뒤,
    ask_photo_location()에 파일 경로를 넘겨 결과를 반환합니다.
    """
    # 1) 확장자 보존해서 임시 파일명 생성
    ext = os.path.splitext(file.filename)[1]
    tmp_fname = f"/tmp/{uuid.uuid4()}{ext}"

    try:
        # 2) 업로드된 이미지 쓰기
        contents = await file.read()
        with open(tmp_fname, "wb") as f:
            f.write(contents)

        # 3) AI 호출
        location = ask_photo_location(tmp_fname)
        return {"location": location}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        # 4) 임시 파일 삭제
        if os.path.exists(tmp_fname):
            os.remove(tmp_fname)
            
            
# Meetup 이벤트 AI 코멘트 엔드포인트
class CommentRequest(BaseModel):
    event_id: str = Field(..., description="Meetup 포스트 문서 ID")
    user_id:  str = Field(..., description="사용자 문서 ID")

@app.post("/comments")
async def comments_endpoint(req: CommentRequest):
    """
    meetup_posts 컬렉션의 event_id와 users 컬렉션의 user_id를
    받아, AI가 사용자 관점의 코멘트를 생성해 반환합니다.
    """
    try:
        ai_comment = generate_comment(req.event_id, req.user_id)
        return {"comment": ai_comment}
    except ValueError as e:
        # 잘못된 ID를 보냈을 때 404로 응답
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        # 그 외 AI 호출 중 에러
        raise HTTPException(status_code=500, detail=f"코멘트 생성 실패: {e}")
    
    
@app.get("/culture")
async def culture(home: str, dest: str):
    """
    홈 국가(home)와 여행 국가(dest)를 입력 받아,
    두 나라 간 주요 예절·문화 차이점을 문단 형식으로 반환합니다.
    호출 예: GET /culture?home=한국&dest=일본
    """
    try:
        description = get_cultural_differences(home, dest)
        return {"description": description}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"문화 차이 안내 실패: {e}")