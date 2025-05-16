import base64
import re
import google.generativeai as genai

vision_model = genai.GenerativeModel(
    "gemini-2.0-flash",
    system_instruction=(
        "You are a travel guide AI. Given a photo, identify exactly the location where it was taken. "
        "Your response must start with the location name only on the first line (e.g., 'Eiffel Tower'). "
        "On subsequent lines, provide a description and recommend 5 nearby attractions or restaurants."
    )
)

def ask_photo_location(image_path: str) -> tuple[str, str]:
    with open(image_path, "rb") as f:
        img_bytes = f.read()
    b64_data = base64.b64encode(img_bytes).decode("utf-8")

    content = [
        {"text": (
            "Please identify, in English, the exact location name of this photo. "
            "On the first line, output ONLY the location name. "
            "Then, add a paragraph recommending 5 famous nearby attractions or restaurants."
        )},
        {"inline_data": {"mime_type": "image/jpeg", "data": b64_data}}
    ]


    response = vision_model.generate_content(content)
    raw_text = response.text.strip()

    raw_lines = raw_text.splitlines()
    if raw_lines:
        location_only = re.sub(r"[\.\,\!\?].*$", "", raw_lines[0].strip())
    else:
        location_only = ""

    remainder = "".join(raw_lines[1:]).strip() if len(raw_lines) > 1 else raw_text[len(raw_lines[0]):].strip()
    full_response = f"{location_only}\n{remainder}" if remainder else location_only

    return location_only, full_response
