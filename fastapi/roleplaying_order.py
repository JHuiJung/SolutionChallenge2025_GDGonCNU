import google.generativeai as genai


genai.configure(api_key="")

# 롤플레잉 주문 봇: 해외 식당 주문 상황 역할극 진행
roleplay_model = genai.GenerativeModel(
    "gemini-2.0-flash",
    system_instruction=(
        "당신은 해외 식당에서 주문하는 상황을 역할극으로 진행하는 파트너입니다. "
        "사용자는 손님 역할을 맡아 주문을 시작하며, 당신은 점원 역할을 자연스럽게 시뮬레이션하여 응답해주세요. "
        "대화는 '사용자:' 와 '점원:' 형식으로 이어가야 합니다."
    )
)

def simulate_order(user_text: str, history: list[str] | None = None) -> tuple[str, list[str]]:
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
    history.append(f"사용자: {user_text}")
    # 전체 대화 컨텍스트 생성
    prompt = "\n".join(history + ["점원:"])
    # 모델 호출
    response = roleplay_model.generate_content(prompt)
    reply = response.text.strip()
    # 점원 응답 추가
    history.append(f"점원: {reply}")
    return reply, history

if __name__ == "__main__":
    print("🍽️ 해외 식당 주문 역할극을 시작합니다. 그만하려면 'exit' 또는 'quit' 입력하세요.\n")
    
    while True:
        user_input = input("사용자: ").strip()
        if user_input.lower() in ("exit", "quit"):
            print("종료합니다. 안녕히 가세요! 👋")
            break
        reply, history = simulate_order(user_input)
        print(f"점원: {reply}\n")