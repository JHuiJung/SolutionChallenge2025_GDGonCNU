import base64
import google.generativeai as genai

# 1) API 키 설정 (main.py에서 이미 configure 하셨다면 생략)
# genai.configure(api_key="YOUR_GOOGLE_API_KEY")

# 2) 멀티모달 모델 선언: 사진 위치 + 주변 추천
vision_model = genai.GenerativeModel(
    "gemini-2.0-flash",
    system_instruction=(
        "당신은 여행 가이드 역할을 하는 AI입니다. "
        "주어진 사진이 찍힌 위치를 알려줄 뿐만 아니라, "
        "그 주변에서 방문할 만한 유명한 관광지나 맛집도 추천해주세요."
    )
)

def ask_photo_location(image_path: str) -> str:
    """
    사진 한 장을 받아서,
    1) 사진이 찍힌 위치
    2) 그 주변의 유명 관광지·맛집 추천
    을 한 문단으로 설명해서 리턴합니다.

    Args:
        image_path: 로컬에 저장된 이미지 파일 경로
    Returns:
        AI가 생성한 위치 설명 및 주변 추천 텍스트
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
    return response.text.strip()


# 단독 실행 테스트
if __name__ == "__main__":
    result = ask_photo_location("test5.jpg")
    print("\n=== AI 추천 결과 ===\n")
    print(result)