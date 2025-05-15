import google.generativeai as genai


topic_model = genai.GenerativeModel(
    "gemini-2.0-flash",
    system_instruction=(
        "You are a translator. When given English input, translate it to Korean; "
        "when given Korean input, translate it to English."
    )
)

def translate(input_text: str) -> str:
    response = topic_model.generate_content(input_text)
    return response.text.strip()
