# test_firebase.py

import firebase_admin
from firebase_admin import credentials, firestore

# 1) 서비스 계정 키 파일 경로를 정확히 지정하세요
KEY_PATH = "serviceAccountKey.json"

# 2) Firebase 앱 초기화 (한 번만)
if not firebase_admin._apps:
    cred = credentials.Certificate(KEY_PATH)
    firebase_admin.initialize_app(cred)

# 3) Firestore 클라이언트
db = firestore.client()

def list_collections():
    print("🔍 Firestore Top-Level Collections:")
    for col in db.collections():
        print("  •", col.id)

def print_user(user_id: str):
    print(f"\n🧑‍💻 Fetching user document: users/{user_id}")
    doc = db.collection("users").document(user_id).get()
    if doc.exists:
        print("  ▶", doc.to_dict())
    else:
        print("  ⚠️ Document not found")

def print_event(event_id: str):
    print(f"\n📍 Fetching event document: meetupPosts/{event_id}")
    doc = db.collection("meetupPosts").document(event_id).get()
    if doc.exists:
        print("  ▶", doc.to_dict())
    else:
        print("  ⚠️ Document not found")

if __name__ == "__main__":
    # 4) 테스트 실행
    list_collections()
    # 아래 ID들은 실제 있는 문서 ID로 바꿔주세요
    TEST_USER_ID = "kc06j1D3QsE1UqkCORU4"
    TEST_EVENT_ID = "1746956554711"

    print_user(TEST_USER_ID)
    print_event(TEST_EVENT_ID)