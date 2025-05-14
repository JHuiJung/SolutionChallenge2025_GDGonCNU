import google.generativeai as genai
from firebase_utils import db # Firestore DB 유틸리티 (가정)

# API 키 설정 (main.py에서 이미 설정했다면 중복될 수 있음)
# 실제 운영 환경에서는 환경 변수 등을 통해 안전하게 관리하는 것이 좋습니다.
# genai.configure(api_key="YOUR_ACTUAL_GOOGLE_API_KEY") # 키를 직접 하드코딩하는 것은 피하세요.

# AI 코멘트 모델 인스턴스
try:
    comment_model = genai.GenerativeModel(
        "gemini-2.0-flash", # 또는 "gemini-pro" 등 사용 가능한 모델
        system_instruction=(
            "당신은 여행 이벤트에 대해 사용자 프로필과 이벤트 정보를 바탕으로 "
            "이 사용자가 이 여행 장소에 대해 어떻게 느낄지, 무엇을 좋아할지, "
            "그리고 비추천할 점이 있다면 무엇인지 한 문단으로 설명하는 AI 어시스턴트입니다."
        )
    )
except Exception as e:
    print(f"Error initializing Gemini Model: {e}")
    # 모델 초기화 실패 시 기본 동작 또는 에러 처리를 할 수 있습니다.
    # 예를 들어, comment_model = None 으로 설정 후 generate_comment 함수에서 이를 확인
    comment_model = None


def generate_comment(event_id: str, user_id: str) -> str:
    """
    Firestore 'meetupPosts' 컬렉션의 이벤트(event_id)와 'users' 컬렉션의 사용자(user_id) 정보를
    가져와, 해당 사용자 관점의 코멘트를 AI로 생성해 반환합니다.
    """
    if comment_model is None:
        raise RuntimeError("AI 코멘트 생성 모델이 초기화되지 않았습니다.")

    # 이벤트 정보 조회
    event_doc_ref = db.collection("meetupPosts").document(event_id)
    event_doc = event_doc_ref.get()
    if not event_doc.exists:
        raise ValueError(f"이벤트 {event_id}을(를) 찾을 수 없습니다.")
    
    event = event_doc.to_dict()
    if not isinstance(event, dict):
        # event 데이터가 예상치 못한 형태일 경우 (예: None 또는 다른 타입)
        raise ValueError(f"이벤트 {event_id}의 데이터 형식이 올바르지 않습니다. (현재: {type(event)})")

    # 사용자 프로필 조회
    user_doc_ref = db.collection("users").document(user_id)
    user_doc = user_doc_ref.get()
    if not user_doc.exists:
        raise ValueError(f"사용자 {user_id}을(를) 찾을 수 없습니다.")
    
    user_data_raw = user_doc.to_dict()

    # --- user_data_raw가 딕셔너리인지 확인하고 처리 (중요!) ---
    if isinstance(user_data_raw, dict):
        user = user_data_raw
    elif isinstance(user_data_raw, list) and user_data_raw: # 리스트이고 비어있지 않다면
        # 리스트의 첫 번째 요소가 실제 프로필 딕셔너리라고 가정
        # 이 가정은 Firestore 데이터 구조에 따라 달라질 수 있습니다.
        if isinstance(user_data_raw[0], dict):
            user = user_data_raw[0]
            print(f"Warning: User data for {user_id} was a list, using the first element.")
        else:
            raise ValueError(f"사용자 {user_id}의 프로필 데이터(리스트 내 요소) 형식이 올바르지 않습니다. (타입: {type(user_data_raw[0])})")
    else:
        # 딕셔너리도 아니고, 데이터가 있는 리스트도 아닌 경우
        raise ValueError(f"사용자 {user_id}의 프로필 데이터 형식이 올바르지 않습니다. 딕셔너리여야 합니다. (현재 타입: {type(user_data_raw)})")
    # --- 확인 및 처리 끝 ---

    # 이벤트 필드 매핑 (get의 기본값을 사용하여 None 방지 및 타입 안정성 강화)
    title = event.get("title", "")
    description = event.get("description", "")
    # location 우선순위: eventLocation -> authorLocation -> "알 수 없는 장소"
    location = event.get("eventLocation", event.get("authorLocation", "알 수 없는 장소"))
    date_time = event.get("eventDateTimeString", "")
    categories_raw = event.get("categories", []) # 기본값을 빈 리스트로
    categories_str = ", ".join(categories_raw) if isinstance(categories_raw, list) and categories_raw else ""


    # 사용자 필드 매핑 (user 딕셔너리에서 안전하게 값 가져오기)
    user_name = "사용자" # 기본값
    languages_data = user.get("languages", {}) # languages 필드가 없으면 빈 딕셔너리
    if isinstance(languages_data, dict):
        user_name = languages_data.get("name", user.get("name", "사용자"))
    else: # languages 필드가 딕셔너리가 아닌 경우 (예: 문자열이나 다른 타입)
        user_name = user.get("name", "사용자") # 루트 레벨의 name 시도

    gender = user.get("gender", "")
    
    def format_preference(pref_key: str) -> str:
        pref_value = user.get(pref_key, [])
        return ", ".join(pref_value) if isinstance(pref_value, list) and pref_value else ""

    travel_purpose_str = format_preference("preferTravelPurpose")
    prefer_destination_str = format_preference("preferDestination")
    prefer_people_str = format_preference("preferPeople")
    prefer_style_str = format_preference("preferPlanningStyle")


    # 프롬프트 구성 (기존과 동일)
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
    try:
        print(f"Sending prompt to Gemini for event {event_id}, user {user_id}:\n{prompt[:500]}...") # 프롬프트 일부 로그 (디버깅용)
        res = comment_model.generate_content(prompt)
        # 응답 텍스트가 있는지 확인 후 반환
        generated_text = res.text if hasattr(res, 'text') else None
        if generated_text:
            return generated_text.strip()
        else:
            # Gemini가 텍스트를 반환하지 않은 경우 (예: 안전 필터링 등)
            print(f"Warning: Gemini did not return text for event {event_id}, user {user_id}. Response parts: {res.parts if hasattr(res, 'parts') else 'N/A'}")
            return "AI가 적절한 코멘트를 생성하지 못했습니다. 이벤트나 사용자 정보가 부족할 수 있습니다."
    except Exception as e:
        print(f"Error calling Gemini API (event: {event_id}, user: {user_id}): {e}")
        # 실제 오류를 포함하여 클라이언트에 전달하거나, 일반적인 메시지로 대체
        raise ValueError(f"AI 코멘트 생성 중 API 호출 오류 발생: {e}")


if __name__ == "__main__":
    # 테스트용 ID 설정 - Firestore에 실제 존재하는 유효한 ID로 변경해야 합니다.
    TEST_EVENT_ID = "1746956554711"
    TEST_USER_ID = "52s2pEJSCSvWLwd6T6vj"

    # API 키 설정 (환경 변수에서 가져오는 것을 권장)
    # import os
    # from dotenv import load_dotenv
    # load_dotenv()
    # GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
    # if GOOGLE_API_KEY:
    #     genai.configure(api_key=GOOGLE_API_KEY)
    # else:
    #     print("Warning: GOOGLE_API_KEY environment variable not set. Using hardcoded key (NOT RECOMMENDED FOR PRODUCTION).")
    #     genai.configure(api_key="AIzaSyCqb3HHXZ3qgtPXsRA2tx2FYKQAZZ-oeHM") # 테스트용 임시 키

    if comment_model is None:
        print("AI Model could not be initialized. Exiting test.")
    else:
        try:
            print(f"\n--- Testing AI Comment Generation ---")
            print(f"Event ID: {TEST_EVENT_ID}")
            print(f"User ID: {TEST_USER_ID}")
            comment = generate_comment(TEST_EVENT_ID, TEST_USER_ID)
            print("\nGenerated Comment:\n--------------------\n", comment, "\n--------------------")
        except ValueError as ve:
            print(f"ValueError during test: {ve}")
        except RuntimeError as re:
            print(f"RuntimeError during test: {re}")
        except Exception as e:
            print(f"An unexpected error occurred during test: {e}")