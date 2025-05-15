import google.generativeai as genai

cultural_model = genai.GenerativeModel(
    "gemini-2.0-flash",
    system_instruction=(
        "You are an AI assistant that informs travelers about cultural differences in paragraph form. "
        "Given the user's home country and the destination country, please provide a brief paragraph explaining "
        "the key etiquette and cultural differences between the two countries."
    )
)

def get_cultural_differences(home_country: str, dest_country: str) -> str:
   
    prompt = (
        f"Home country: {home_country}\n"
        f"Destination country: {dest_country}\n"
        "Please provide a brief paragraph in English describing the main etiquette and cultural differences between these two countries."
    )
    res = cultural_model.generate_content(prompt)
    return res.text.strip()