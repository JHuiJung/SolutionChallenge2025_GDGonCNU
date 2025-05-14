import google.generativeai as genai
from firebase_utils import db

# 단독 실행용 API 키 설정 (main.py 에서 이미 configure 했다면 생략 가능)
genai.configure(api_key="")

# AI 코멘트 모델 인스턴스
comment_model = genai.GenerativeModel(
    "gemini-2.0-flash",
    system_instruction=(
        "당신은 여행 이벤트에 대해 사용자 프로필과 이벤트 정보를 바탕으로 "
        "이 사용자가 이 여행 장소에 대해 어떻게 느낄지, 무엇을 좋아할지, "
        "그리고 비추천할 점이 있다면 무엇인지 한 문단으로 설명하는 AI 어시스턴트입니다."
    )
)

def generate_comment(event_id: str, user_id: str) -> str:
    """
    Firestore 'meetupPosts' 컬렉션의 이벤트(event_id)와 'users' 컬렉션의 사용자(user_id) 정보를
    가져와, 해당 사용자 관점의 코멘트를 AI로 생성해 반환합니다.

    Args:
        event_id: Meetup 포스트 문서 ID
        user_id:  사용자 문서 ID
    Returns:
        코멘트 한 문단 문자열
    """
    # 이벤트 정보 조회
    event_doc = db.collection("meetupPosts").document(event_id).get()
    if not event_doc.exists:
        raise ValueError(f"이벤트 {event_id}을(를) 찾을 수 없습니다.")
    event = event_doc.to_dict()

    # 사용자 프로필 조회
    user_doc = db.collection("users").document(user_id).get()
    if not user_doc.exists:
        raise ValueError(f"사용자 {user_id}을(를) 찾을 수 없습니다.")
    user = user_doc.to_dict()

    # 이벤트 필드 매핑
    title = event.get("title", "")
    description = event.get("description", "")
    location = event.get("eventLocation","") 
    date_time = event.get("eventDateTimeString", "")
    categories = event.get("categories", [])
    categories_str = ", ".join(categories) if isinstance(categories, list) else str(categories)

    # 사용자 필드 매핑
    user_name = user.get("name") or "사용자"
    gender = user.get("gender", "")
    # 선호 여행 목적
    travel_purpose = user.get("preferTravelPurpose", [])
    travel_purpose_str = ", ".join(travel_purpose) if isinstance(travel_purpose, list) else str(travel_purpose)
    # 선호 목적지 유형
    prefer_destination = user.get("preferDestination", [])
    prefer_destination_str = ", ".join(prefer_destination) if isinstance(prefer_destination, list) else str(prefer_destination)
    # 선호 동행
    prefer_people = user.get("preferPeople", [])
    prefer_people_str = ", ".join(prefer_people) if isinstance(prefer_people, list) else str(prefer_people)
    # 선호 여행 계획 스타일
    prefer_style = user.get("preferPlanningStyle", [])
    prefer_style_str = ", ".join(prefer_style) if isinstance(prefer_style, list) else str(prefer_style)

    # 프롬프트 구성
    prompt = (
        f"이벤트 정보:\n"
        f"- 제목: {title}\n"
        f"- 설명: {description}\n"
        f"- 카테고리: {categories_str}\n"
        f"- 장소: {location}\n"
        f"- 일시: {date_time}\n\n"
        f"사용자 정보:\n"
        f"- 이름: {user_name}\n"
        f"- 성별: {gender}\n"
        f"- 여행 목적: {travel_purpose_str}\n"
        f"- 선호 목적지 유형: {prefer_destination_str}\n"
        f"- 선호 동행: {prefer_people_str}\n"
        f"- 여행 계획 스타일: {prefer_style_str}\n\n"
        "위 정보를 바탕으로, 이 사용자가 이 여행 이벤트에 대해 어떻게 생각할지, "
        "특히 마음에 들어할 부분과 개선되면 좋을 부분을 한 문단으로 설명해 주세요."
    )

    # AI 호출
    res = comment_model.generate_content(prompt)
    return res.text.strip()

if __name__ == "__main__":
    # 테스트용 ID 설정
    TEST_EVENT_ID = "1746956554711"
    TEST_USER_ID = "kc06j1D3QsE1UqkCORU4"
    try:
        comment = generate_comment(TEST_EVENT_ID, TEST_USER_ID)
        print("Generated Comment:\n", comment)
    except Exception as e:
        print("Error generating comment:", e)
