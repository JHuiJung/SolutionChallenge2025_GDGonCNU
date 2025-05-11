import google.generativeai as genai

# 3) 싱글턴 모델 인스턴스 생성
topic_model = genai.GenerativeModel(
    "gemini-2.0-flash",
    system_instruction=(
        "당신은 여행 테마의 채팅 앱을 보조하는 AI 어시스턴트입니다. "
        "사용자에게 흥미롭고 유용한 대화 주제를 추천해주세요. "
        "여행과 관련된 맥락을 고려하여, 한국어로 5개의 주제를 간결한 리스트 형식으로 반환합니다."
    )
)


def recommend_topics(count: int = 5) -> list[str]:
    """
    AI에게 'count'개의 대화 주제를 요청하고,
    첫 번째 설명 문구는 버린 뒤 딱 주제 5가지만 리턴합니다.
    """
    prompt = f"사용자에게 제안할 대화 주제를 {count}개, 한국어로 리스트 형태로 알려주세요. 대화 주제는 상대방에게 바로 전달되니 상대방에게 대화하듯이 말해주세요."
    
    res = topic_model.generate_content(prompt)
    raw = res.text.strip()
        
        # 1) 첫 번째 줄이 리스트가 아니면 버리기
    lines = raw.splitlines()
    if lines and not lines[0].lstrip().startswith(tuple(str(i) for i in range(1,10)) + ("-",)):
        lines = lines[1:]

        # 2) 나머지 줄에서 번호·기호 제거 후 수집
    topics = []
    for line in lines:
        item = line.lstrip("0123456789. \*)- ").strip()
        if item:
            topics.append(item)
            if len(topics) >= count:
                break


    return topics

