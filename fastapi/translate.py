import google.generativeai as genai


translate_model = genai.GenerativeModel(
    'gemini-2.0-flash',
    system_instruction=(
        "당신은 번역가입니다. 영어를 입력받으면 한글로, 한글을 입력받으면 영어로 번역해주시면 됩니다."
    )
)

def translate(input_text):
    
    response = translate_model.generate_content(input_text)

    return response.text