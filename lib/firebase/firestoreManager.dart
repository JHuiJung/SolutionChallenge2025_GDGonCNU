import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';


class UserState {
  static final UserState _instance = UserState._internal();
  factory UserState() => _instance;

  UserState._internal();

  //기본정보
  String? email = "";
  String? name = "";
  String? region = "";
  String? gender = "";
  int? birthYear = 0;

  //프로필 추가 정보
  List<UserLanguageInfo> Languages = []; // 가능 언어
  List<String> visitedCountries = []; //다녀온 나라
  String profileURL = "";
  String statusMessage = "";
  String wantsToDo = "";
  String iLike = "";
  List<String> postIds = []; // 게시글 id
  List<String> comments = []; // 코멘트 id
  List<String> friendsEmail = []; // 친구 이메일
  String travelGoal = "";

  //선호 조사
  List<String> preferTravlePurpose = [];
  List<String> preferDestination = [];
  List<String> preferPeople = [];
  List<String> preferPlanningStyle = [];
}

class UserChat{
  String chatId = "";
  String adminEmail = "";
  String otherUserEmail = "";
  String LastChatTime = "";
  List<(DateTime, String)> chatMessages = [];
}

class UserMeetUpPost{

  List<String> meetUpPostCategory = [];
  String meetUpPostLocation = "";
  String meetUpPostDate = "";

  String meetUpPostId = "";
  String meetUpPostTitle = "";
  String meetUpPostContent = "";
  String meetUpPostPhoto = "";
  String meetUpRegion = "";
  num totalCnt = 10;
  num currentCnt = 1;

}

class UserRecommandPost{
  String recommandPostId = "";
  String recommandPostTitle = "";
  String recommandPostSubHead = "";
  String recommandPostContent = "";
  String recommandPostPhoto = "";
  String recommandPostLocation = "";

  String adminEmail = "";
  
}

class Comment{
  String commentId = "";
  String userEmail = "";
  String userName = "";
  String userPhoto = "";
  String commentContent = "";

}

// 언어 정보
class UserLanguageInfo {
  final String languageCode;   // 예: 'ko'
  final String languageName;   // 예: 'Korean'
  final int proficiency;       // 예: 1~5

  UserLanguageInfo({
    required this.languageCode,
    required this.languageName,
    required this.proficiency,
  });

  factory UserLanguageInfo.fromMap(Map<String, dynamic> map) {
    return UserLanguageInfo(
      languageCode: map['languageCode'] ?? '',
      languageName: map['languageName'] ?? '',
      proficiency: map['proficiency'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'languageCode': languageCode,
      'languageName': languageName,
      'proficiency': proficiency,
    };
  }
}


void addUser() {
  final user = UserState();

  FirebaseFirestore.instance.collection('users').add({
    'email': user.email,
    'name': user.name,
    'region': user.region,
    'gender': user.gender,
    'birthYear': user.birthYear,

    // 언어 리스트를 Map 리스트로 변환
    'languages': user.Languages
        .map((lang) => {
      'languageName': lang.languageName,
      'languageCode': lang.languageCode,
      'proficiency': lang.proficiency,
    }).toList(),

    'visitedCountries': user.visitedCountries,
    'profileURL': user.profileURL,
    'statusMessage': user.statusMessage,
    'wantsToDo': user.wantsToDo,
    'iLike': user.iLike,
    'postIds': user.postIds,
    'comments': user.comments,
    'friendsEmail': user.friendsEmail,
    'travelGoal': user.travelGoal,

    'timestamp': FieldValue.serverTimestamp(),

    'preferTravlePurpose': user.preferTravlePurpose,
    'preferDestination': user.preferDestination,
    'preferPeople': user.preferPeople,
    'preferPlanningStyle': user.preferPlanningStyle,
  }).then((DocumentReference doc) {
    print('Document added with ID: ${doc.id}');
  }).catchError((error) {
    print('Error adding user: $error');
  });
}


// 로그인시 유저 정보 업데이트
void setUpUserInfo()
{
  final userinfo = UserState();


}

Future<bool> getUserInfoByEmail(String email) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      print("(firestoreManager) 해당 이메일의 유저가 없습니다.");
      return false;
    }

    final data = snapshot.docs.first.data();
    final user = UserState();

    user.email = data['email'] ?? '';
    user.name = data['name'] ?? '';
    user.region = data['region'] ?? '';
    user.gender = data['gender'] ?? '';
    user.birthYear = data['birthYear'] ?? 0;

    // 언어 리스트 역직렬화
    final languagesData = List<Map<String, dynamic>>.from(data['languages'] ?? []);
    user.Languages = languagesData
        .map((langMap) => UserLanguageInfo.fromMap(langMap))
        .toList();

    user.visitedCountries = List<String>.from(data['visitedCountries'] ?? []);
    user.profileURL = data['profileURL'] ?? '';
    user.statusMessage = data['statusMessage'] ?? '';
    user.wantsToDo = data['wantsToDo'] ?? '';
    user.iLike = data['iLike'] ?? '';
    user.postIds = List<String>.from(data['postIds'] ?? []);
    user.comments = List<String>.from(data['comments'] ?? []);
    user.friendsEmail = List<String>.from(data['friendsEmail'] ?? []);
    user.travelGoal = data['travelGoal'] ?? '';

    user.preferTravlePurpose = List<String>.from(data['preferTravlePurpose'] ?? []);
    user.preferDestination = List<String>.from(data['preferDestination'] ?? []);
    user.preferPeople = List<String>.from(data['preferPeople'] ?? []);
    user.preferPlanningStyle = List<String>.from(data['preferPlanningStyle'] ?? []);

    print("유저 정보 로드 성공: ${user.name}");
    return true;
  } catch (e) {
    print("유저 정보 가져오기 오류: $e");
    return false;
  }
}

