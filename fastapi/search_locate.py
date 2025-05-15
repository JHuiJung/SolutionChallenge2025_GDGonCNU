import base64
import re
import google.generativeai as genai

# 1) API 키 설정 (main.py에서 이미 configure 하셨다면 생략 가능)
# genai.configure(api_key="YOUR_GOOGLE_API_KEY")
GOOGLE_API_KEY = "AIzaSyCqb3HHXZ3qgtPXsRA2tx2FYKQAZZ-oeHM"
genai.configure(api_key=GOOGLE_API_KEY)

# 2) 멀티모달 모델 선언: 사진 위치 + 주변 추천
vision_model = genai.GenerativeModel(
    "gemini-2.0-flash",
    system_instruction=(
        "당신은 여행 가이드 역할을 하는 AI입니다. "
        "주어진 사진이 찍힌 위치를 알려줄 뿐만 아니라, "
        "그 주변에서 방문할 만한 유명한 관광지나 맛집도 추천해주세요."
        "대답을 출력할 때 첫 번째 문장에는 사진 속 위치의 명사만 담기게 해주세요"
        "그 이후에 위치에 대한 설명을 해주세요."
    )
)

def ask_photo_location(image_path: str) -> tuple[str, str]:
    """
    사진 한 장을 받아서,
    1) 사진이 찍힌 위치 및 주변 추천 전체 텍스트
    2) 사진이 찍힌 장소 이름만 뽑아서 반환합니다.

    Args:
        image_path: 로컬에 저장된 이미지 파일 경로
    Returns:
        full_text: AI가 생성한 위치 설명 및 주변 추천 문단
        location_only: 사진이 찍힌 장소 이름(단어 또는 명칭)
    """
    # 1) 이미지 읽어서 Base64 인코딩
    with open(image_path, "rb") as f:
        img_bytes = f.read()
    b64_data = base64.b64encode(img_bytes).decode("utf-8")

    # 2) 프롬프트와 이미지 데이터를 리스트로 함께 전달
    content = [
        {"text": "이 사진이 찍힌 위치와, 그 주변의 유명 관광지나 맛집을 5개 정도 영어로 설명해주세요."},
        {
            "inline_data": {
                "mime_type": "image/jpeg",
                "data": b64_data
            }
        }
    ]

    # 3) AI 호출
    response = vision_model.generate_content(content)
    full_text = response.text.strip()

    # 4) 사진 위치만 추출: 첫 번째 문장에서 ' at ' 또는 ' in ' 이후 텍스트
    first_sentence = re.split(r'(?<=[.?!])\s+', full_text, maxsplit=1)[0].strip()
    # 위치 키워드 뒤의 장소명 추출
    match = re.search(r"\b(?:at|in)\s+([^.,?!]+)", first_sentence, re.IGNORECASE)
    if match:
        location_only = match.group(1).strip()
    else:
        # 추출 실패 시 첫 문장을 그대로 사용하되 마침표 제거
        location_only = first_sentence.rstrip('.?!)')

    return  location_only, full_text # location_only은 지역 이름만. 이거 받아서 지역 이동 버튼 누르면 지역 이동하게

# 단독 실행 테스트
if __name__ == "__main__":
    ft, loc = ask_photo_location("test5.jpg")
    print("\n=== Full Recommendation ===\n", ft)
    print("\n=== Location Only ===\n", loc)
