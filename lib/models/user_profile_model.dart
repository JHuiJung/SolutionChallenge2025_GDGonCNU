// lib/models/user_profile_model.dart
import '../firebase/firestoreManager.dart';

class UserProfileModel {
  final String userId;
  final String name;
  final int age;
  final String location; // 예: "Seoul, Korea"
  final String timeZoneInfo; // 예: "13:37 (-7hours)" - 실제로는 TimeZone ID 저장 후 계산
  final String profileImageUrl;
  final String statusMessage;
  final List<UserLanguageInfo> languages;
  final String likes; // 예: "Shopping, Movie"
  final String placesBeen; // 예: "Japan, America, India"
  final String wantsToDo; // 예: "make a happy memory with me"
  // Hosting, Comments는 별도 로직으로 가져옴

  UserProfileModel({
    required this.userId,
    required this.name,
    required this.age,
    required this.location,
    required this.timeZoneInfo, // 실제로는 계산 필요
    required this.profileImageUrl,
    required this.statusMessage,
    required this.languages,
    required this.likes,
    required this.placesBeen,
    required this.wantsToDo,
  });
}

class UserLanguage {
  final String languageCode; // 예: 'ko', 'en'
  final String languageName; // 예: 'Korean', 'English'
  final int proficiency; // 예: 1~5 단계

  UserLanguage({
    required this.languageCode,
    required this.languageName,
    required this.proficiency,
  });
}

// --- 임시 더미 데이터 생성 함수 ---
UserProfileModel getDummyMyProfile() {
  return UserProfileModel(
    userId: 'my_user_id_123', // 현재 로그인한 사용자 ID
    name: 'Amy', // 프로필 등록 시 입력한 이름
    age: 23, // 프로필 등록 시 입력한 나이
    location: 'Gwangju, Korea', // 프로필 등록 시 입력한 거주지
    timeZoneInfo: '14:05 (+9 hours)', // 현재 시간 및 시차 (계산 필요)
    profileImageUrl: 'https://source.unsplash.com/random/200x200/?person,woman&sig=1', // 내 프로필 사진
    statusMessage: "Let's hang out!",
    languages: [
      UserLanguageInfo(languageCode: 'ko', languageName: 'Korean', proficiency: 5),
      UserLanguageInfo(languageCode: 'en', languageName: 'English', proficiency: 3),
    ],
    likes: 'Shopping, Movie, Hiking',
    placesBeen: 'Japan, America, India, France',
    wantsToDo: 'make a happy memory with my travel mates!',
  );
}