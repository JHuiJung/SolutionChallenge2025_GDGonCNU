import google.generativeai as genai
from firebase_utils import db

try:
    comment_model = genai.GenerativeModel(
        "gemini-2.0-flash",
        system_instruction=(
            "You are an AI assistant who, based on user profiles and event information, "
            "explains in a single paragraph how the user would feel about this travel event, "
            "what they would like, and any suggestions for improvement."
        )
    )
except Exception as e:
    print(f"Error initializing Gemini model: {e}")
    comment_model = None


def generate_comment(event_id: str, user_id: str) -> str:
    
    if comment_model is None:
        raise RuntimeError("AI comment generation model is not initialized.")

    event_doc_ref = db.collection("meetupPosts").document(event_id)
    event_doc = event_doc_ref.get()
    if not event_doc.exists:
        raise ValueError(f"Event {event_id} not found.")
    event = event_doc.to_dict()
    if not isinstance(event, dict):
        raise ValueError(f"Event {event_id} data format is invalid (current type: {type(event)}).")

    user_doc_ref = db.collection("users").document(user_id)
    user_doc = user_doc_ref.get()
    if not user_doc.exists:
        raise ValueError(f"User {user_id} not found.")
    user_data_raw = user_doc.to_dict()
    if isinstance(user_data_raw, dict):
        user = user_data_raw
    elif isinstance(user_data_raw, list) and user_data_raw:
        if isinstance(user_data_raw[0], dict):
            user = user_data_raw[0]
            print(f"Warning: User data for {user_id} was a list; using the first element.")
        else:
            raise ValueError(f"User {user_id} profile data list element type is invalid (type: {type(user_data_raw[0])}).")
    else:
        raise ValueError(f"User {user_id} profile data format is invalid (expected dict, got: {type(user_data_raw)}).")


    title = event.get("title", "")
    description = event.get("description", "")
    location = event.get("eventLocation", event.get("authorLocation", "Unknown location"))
    date_time = event.get("eventDateTimeString", "")
    categories_raw = event.get("categories", [])
    categories_str = ", ".join(categories_raw) if isinstance(categories_raw, list) and categories_raw else ""


    user_name = "User"
    languages_data = user.get("languages", {})
    if isinstance(languages_data, dict):
        user_name = languages_data.get("name", user.get("name", "User"))
    else:
        user_name = user.get("name", "User")
    gender = user.get("gender", "")

    def format_preference(pref_key: str) -> str:
        pref_value = user.get(pref_key, [])
        return ", ".join(pref_value) if isinstance(pref_value, list) and pref_value else ""

    travel_purpose_str = format_preference("preferTravelPurpose")
    prefer_destination_str = format_preference("preferDestination")
    prefer_people_str = format_preference("preferPeople")
    prefer_style_str = format_preference("preferPlanningStyle")

    
    prompt = (
        f"Event Information:\n"
        f"- Title: {title}\n"
        f"- Description: {description}\n"
        f"- Categories: {categories_str}\n"
        f"- Location: {location}\n"
        f"- Date & Time: {date_time}\n\n"
        f"User Information:\n"
        f"- Name: {user_name}\n"
        f"- Gender: {gender}\n"
        f"- Travel Purpose: {travel_purpose_str}\n"
        f"- Preferred Destination Types: {prefer_destination_str}\n"
        f"- Preferred Companions: {prefer_people_str}\n"
        f"- Planning Style: {prefer_style_str}\n\n"
        "Based on this information, please write a single paragraph in English explaining how this user might feel about this travel event, "
        "highlight what they would like and suggest areas for improvement."
    )

    try:
        print(f"Sending prompt to Gemini for event {event_id}, user {user_id}:\n{prompt[:500]}...")
        res = comment_model.generate_content(prompt)
        generated_text = res.text if hasattr(res, 'text') else None
        if generated_text:
            return generated_text.strip()
        else:
            print(
                f"Warning: Gemini did not return text for event {event_id}, user {user_id}. "
                f"Response parts: {res.parts if hasattr(res, 'parts') else 'N/A'}"
            )
            return (
                "The AI could not generate a suitable comment. "
                "The event or user information might be insufficient."
            )
    except Exception as e:
        print(f"Error calling Gemini API (event: {event_id}, user: {user_id}): {e}")
        raise ValueError(f"API call error during AI comment generation: {e}")
