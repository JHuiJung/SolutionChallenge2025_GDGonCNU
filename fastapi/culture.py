import google.generativeai as genai

# 문화 차이 안내 봇: 사용자 국가와 여행 국가 간 예절·문화 차이를 문단 형식으로 안내
cultural_model = genai.GenerativeModel(
    "gemini-2.0-flash",
    system_instruction=(
        "당신은 여행자들에게 문화 차이점을 문단 형식으로 알려주는 AI 어시스턴트입니다. "
        "사용자의 홈 국가와 여행할 국가를 받아, 두 나라 간 주요 예절과 문화 차이를 간단한 문단으로 설명해주세요."
    )
)

GOOGLE_API_KEY = "AIzaSyCqb3HHXZ3qgtPXsRA2tx2FYKQAZZ-oeHM"
genai.configure(api_key=GOOGLE_API_KEY)

def get_cultural_differences(home_country: str, dest_country: str) -> str:
    """
    홈 국가(home_country)와 여행할 국가(dest_country)의 문화 차이점을
    문단 형식으로 간결하게 설명한 텍스트를 반환합니다.

    Args:
        home_country: 사용자의 홈 국가 이름
        dest_country: 여행할 국가 이름
    Returns:
        한 문장 이상의 문단 형태로 된 문화 차이 설명
    """
    prompt = (
        f"홈 국가: {home_country}\n"
        f"여행 국가: {dest_country}\n"
        "위 두 국가 간 주요 예절 및 문화 차이점을 문단 형식으로 간단히 설명해주세요."
    )
    res = cultural_model.generate_content(prompt)
    return res.text.strip()

# 단독 실행 테스트
if __name__ == "__main__":
    home = "한국"
    dest = "일본"
    print(get_cultural_differences(home, dest))