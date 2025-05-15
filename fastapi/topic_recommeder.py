import google.generativeai as genai


topic_model = genai.GenerativeModel(
    "gemini-2.0-flash",
    system_instruction=(
        "You are an AI assistant supporting a travel-themed chat app. "
        "Recommend interesting and useful conversation topics to the user in a friendly, conversational tone. "
        "Considering the travel context, return a list of topics in English, each phrased as a suggestion (e.g., 'How about we discuss...')."
    )
)

def recommend_topics(count: int = 5) -> list[str]:


    prompt = (
        f"Please suggest {count} conversational topics for a travel scenario, "
        "phrased as friendly suggestions to the user (e.g., 'How about we talk about...')."
    )
    res = topic_model.generate_content(prompt)
    raw = res.text.strip()


    lines = raw.splitlines()
    if lines and not lines[0].lstrip().startswith(tuple(str(i) for i in range(1, 10)) + ("-",)):
        lines = lines[1:]

    topics: list[str] = []
    for line in lines:
        
        item = line.lstrip("0123456789. *)- ").strip()
        if item:
            topics.append(item)
            if len(topics) >= count:
                break

    return topics
