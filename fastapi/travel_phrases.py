import google.generativeai as genai
import logging

GOOGLE_API_KEY = "AIzaSyCqb3HHXZ3qgtPXsRA2tx2FYKQAZZ-oeHM"
genai.configure(api_key=GOOGLE_API_KEY)

# 모델 인스턴스: 시나리오 기반 필수 여행 회화문 생성 (단일 요청)
essential_model = genai.GenerativeModel(
    "gemini-2.0-flash",
    system_instruction=(
        "당신은 여행자를 위한 언어 학습 가이드입니다. "
        "사용자의 한 문장 요청을 받아, 그 요청에 맞는 필수 여행 회화문 5개를 추천하세요. "
        "각 문장은 세 줄 형식으로 출력되어야 합니다: 1) 원어, 2) 영어 발음, 3) 영어 번역"
    )
)

# 로거 설정
logging.basicConfig(level=logging.INFO)

def generate_scenario_phrases(request: str) -> str:
    """
    사용자의 한 문장 요청(request)에 맞춰,
    필수 여행 회화문 5개를 세 줄(원어, 발음, 번역) 형식으로 생성하여
    하나의 텍스트 블록으로 반환합니다.

    Args:
        request: 예) "영어로 공항에서 짐 부칠 때 쓰는 표현"
    Returns:
        여러 문장이 세 줄씩 구성된 하나의 문자열
    """
    prompt = (
        f"사용자 요청: {request}\n"
        "위 요청에 맞춰 필수 여행 회화문 5개를 생성하세요. "
        "각 문장은 다음 예시처럼 세 줄 형식으로 출력합니다:\n\n"
        "예시:\n"
        "Hello\n헬로우\n안녕하세요\n\n"
        "How are you?\n하우 아 유?\n어떻게 지내세요?"
    )
    res = essential_model.generate_content(prompt)
    raw = res.text.strip()
    # logging.info(f"[generate_scenario_phrases] raw response:\n{raw}")
    return raw

# 단독 실행 테스트
if __name__ == "__main__":
    # 한 문장 입력 예시
    test = generate_scenario_phrases("한국어로 공항에서 짐 부칠 때 쓰는 표현")
    print(test)