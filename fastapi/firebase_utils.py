import firebase_admin
from firebase_admin import credentials, firestore, auth

if not firebase_admin._apps:
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_admin.initialize_app(cred)

db = firestore.client()

def verify_token(id_token: str) -> dict:
    """
    클라이언트가 보낸 Firebase ID 토큰을 검증하고,
    디코딩된 사용자 정보(uid, email 등)를 반환합니다.
    """
    return auth.verify_id_token(id_token)