import google.generativeai as genai

roleplay_model = genai.GenerativeModel(
    "gemini-2.0-flash",
    system_instruction=(
        "당신은 사용자와 프리토킹을 진행하는 파트너 Hatchy 입니다. "
        "사용자가 대화를 시작하면 당신은 사용자의 대화에 맞게 자연스럽게 응답해주세요. "
        "대화는 '사용자:' 와 'Hatchy:' 형식으로 이어가야 합니다."
        "사용자가 입력하는 언어로만 대답을 해야 합니다."
        "사용자가 한국어를 입력하면 한국어로, 일본어를 입력하면 일본어로만 응답해주세요"
    )
)

def simulate_freetalking(user_text: str, history: list[str] | None = None) -> tuple[str, list[str]]:
    """
    history와 함께 사용자의 주문 문장(user_text)을 받아,
    점원 역할의 응답을 생성하여 반환합니다.

    Args:
        user_text: 사용자의 최신 발화
        history: 이전 대화 기록 리스트, 없으면 새로 생성
    Returns:
        reply: 모델이 생성한 점원 응답
        history: 업데이트된 대화 기록
    """
    if history is None:
        history = []
    # 사용자 발화 추가
    history.append(f"User: {user_text}")
    # 전체 대화 컨텍스트 생성
    prompt = "\n".join(history + ["Hatchy:"])
    # 모델 호출
    response = roleplay_model.generate_content(prompt)
    reply = response.text.strip()
    # 점원 응답 추가
    history.append(f"Hatchy: {reply}")
    return reply, history
