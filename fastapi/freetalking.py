import google.generativeai as genai

roleplay_model = genai.GenerativeModel(
    "gemini-2.0-flash",
    system_instruction=(
        "You are Hatchy, a partner for free talking with the user. "
        "When the user starts the conversation, please respond naturally in line with their dialogue. "
        "The conversation should follow the format 'User:' and 'Hatchy:'. "
        "You must reply only in the language the user inputs. "
        "If the user writes in Korean, respond in Korean; if they write in Japanese, respond in Japanese."
    )
)

def simulate_freetalking(user_text: str, history: list[str] | None = None) -> tuple[str, list[str]]:
    if history is None:
        history = []

    
    history.append(f"User: {user_text}")

    prompt = "\n".join(history + ["Hatchy:"])

    response = roleplay_model.generate_content(prompt)
    reply = response.text.strip()

    history.append(f"Hatchy: {reply}")
    return reply, history
