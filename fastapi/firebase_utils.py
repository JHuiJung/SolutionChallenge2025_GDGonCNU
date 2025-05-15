import firebase_admin
from firebase_admin import credentials, firestore, auth

if not firebase_admin._apps:
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_admin.initialize_app(cred)

db = firestore.client()

def verify_token(id_token: str) -> dict:
   
    return auth.verify_id_token(id_token)