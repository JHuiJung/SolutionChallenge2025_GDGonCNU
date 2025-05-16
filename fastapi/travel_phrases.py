import google.generativeai as genai

phrase_model = genai.GenerativeModel(
    "gemini-2.0-flash",
    system_instruction=(
        "You are a language learning guide for travelers. "
        "When given a user's one-sentence request, detect the target language for the phrase. "
        "If the request specifies Korean phrases (e.g., '한국어로 인사할 때'), produce each phrase with: "
        "1) the original Korean phrase, 2) its romanized pronunciation in English letters, "
        "3) its English translation. "
        "If the request specifies English phrases, produce each phrase with: "
        "1) the original English phrase, 2) an English pronunciation guide (in brackets), "
        "3) a Korean translation. "
        "Return exactly 5 phrases in this three-line format for each."
    )
)

def generate_scenario_phrases(request: str) -> str:
    prompt = (
        f"User request: {request}\n"
        "Generate 5 essential travel phrases matching the above request. "
        "For Korean phrases, format each as:\n"
        "  Phrase in Korean\n"
        "  [Romanization]\n"
        "  English translation\n\n"
        "For English phrases, format each as:\n"
        "  Phrase in English\n"
        "  [Pronunciation guide]\n"
        "  Korean translation\n\n"
        "Example Korean phrase:\n"
        "안녕하세요\n"
        "[annyeonghaseyo]\n"
        "Hello\n\n"
        "Example English phrase:\n"
        "How are you?\n"
        "[how ar yoo]\n"
        "어떻게 지내세요?"
    )
    res = phrase_model.generate_content(prompt)
    return res.text.strip()
