// lib/models/user_profile_model.dart
import '../firebase/firestoreManager.dart';

class UserProfileModel {
  final String userId;
  final String name;
  final int age;
  final String location; // e.g.: "Seoul, Korea"
  final String timeZoneInfo; // e.g.: "13:37 (-7hours)" - Actually store TimeZone ID and calculate
  final String profileImageUrl;
  final String statusMessage;
  final List<UserLanguageInfo> languages;
  final String likes; // e.g.: "Shopping, Movie"
  final String placesBeen; // e.g.: "Japan, America, India"
  final String wantsToDo; // e.g.: "make a happy memory with me"
  // Hosting, Comments are fetched by separate logic

  UserProfileModel({
    required this.userId,
    required this.name,
    required this.age,
    required this.location,
    required this.timeZoneInfo, // Calculation needed in reality
    required this.profileImageUrl,
    required this.statusMessage,
    required this.languages,
    required this.likes,
    required this.placesBeen,
    required this.wantsToDo,
  });
}

class UserLanguage {
  final String languageCode; // e.g.: 'ko', 'en'
  final String languageName; // e.g.: 'Korean', 'English'
  final int proficiency; // e.g.: 1~5 levels

  UserLanguage({
    required this.languageCode,
    required this.languageName,
    required this.proficiency,
  });
}

// --- Temporary Dummy Data Creation Function ---
UserProfileModel getDummyMyProfile() {
  return UserProfileModel(
    userId: 'my_user_id_123', // Current logged-in user ID
    name: 'Amy', // Name entered during profile registration
    age: 23, // Age entered during profile registration
    location: 'Gwangju, Korea', // Residence entered during profile registration
    timeZoneInfo: '14:05 (+9 hours)', // Current time and time difference (Calculation needed)
    profileImageUrl: 'https://source.unsplash.com/random/200x200/?person,woman&sig=1', // My profile picture
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