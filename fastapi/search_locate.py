import base64
import google.generativeai as genai
GOOGLE_API_KEY = "AIzaSyCqb3HHXZ3qgtPXsRA2tx2FYKQAZZ-oeHM"
# (한 번만) API 키 설정
genai.configure(api_key=GOOGLE_API_KEY)

# 모델 선언
vision_model = genai.GenerativeModel(
    "gemini-2.0-flash",
    system_instruction="이제부터 당신은 사진이 찍힌 장소를 알려주는 역할입니다."
)

def ask_photo_location(image_path: str) -> str:
    # 1) 이미지 파일 읽고 Base64로 인코딩
    with open(image_path, "rb") as f:
        img_bytes = f.read()
    b64_data = base64.b64encode(img_bytes).decode("utf-8")

    # 2) inline_data 파트에 mime_type과 data(=Base64) 전달
    response = vision_model.generate_content([
        {"text": "이 사진이 찍힌 위치를 알려주세요."},
        {
            "inline_data": {
                "mime_type": "image/jpeg",
                "data": b64_data
            }
        }
    ])
    return response.text.strip()

# 테스트
location = ask_photo_location("test5.jpg")
print(location)