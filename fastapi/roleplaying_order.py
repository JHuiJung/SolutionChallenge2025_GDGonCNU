import google.generativeai as genai

roleplay_model = genai.GenerativeModel(
    "gemini-2.0-flash",
    system_instruction=(
        "You are a partner for role-playing an ordering scenario at an international restaurant. "
        "The user plays the customer and begins placing an order, while you act as the staff and respond naturally. "
        "The conversation should follow the format 'User:' and 'Staff:'. "
        "You must reply only in the language the user inputs. "
        "If the user writes in Korean, respond in Korean; if they write in Japanese, respond in Japanese."
    )
)

def simulate_order(user_text: str, history: list[str] | None = None) -> tuple[str, list[str]]:
    if history is None:
        history = []

    history.append(f"User: {user_text}")

    prompt = "\n".join(history + ["Staff:"])

    response = roleplay_model.generate_content(prompt)
    reply = response.text.strip()

    history.append(f"Staff: {reply}")
    return reply, history
