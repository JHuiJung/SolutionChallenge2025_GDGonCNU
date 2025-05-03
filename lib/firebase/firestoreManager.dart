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
  (String, num) firstLanguage = ("",0); // 제 1국어
  (String, num) secondLanguage = ("",0); // 제 2국어
  List<String> visitedCountries = []; //다녀온 나라
  String bio = "";
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


void addUser() {
  final user = UserState(); // 싱글턴 인스턴스 호출

  FirebaseFirestore.instance.collection('users').add({
    'email': user.email,

    //기존 정보
    'name': user.name,
    'region': user.region,
    'gender': user.gender,
    'birthYear': user.birthYear,

    //프로필 추가 정보
    'visitedCountries': user.visitedCountries,
    'bio': user.bio,
    'postIds': user.postIds,
    'comments': user.comments,
    'travelGoal': user.travelGoal,

    'timestamp': FieldValue.serverTimestamp(),

    //선호 조사
    'preferTravlePurpose' : user.preferTravlePurpose,
    'preferDestination' : user.preferDestination,
    'preferPeople' : user.preferPeople,
    'preferPlanningStyle' : user.preferPlanningStyle,

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
    user.visitedCountries = List<String>.from(data['visitedCountries'] ?? []);
    user.bio = data['bio'] ?? '';
    user.postIds = List<String>.from(data['postIds'] ?? []);
    user.comments = List<String>.from(data['comments'] ?? []);
    user.travelGoal = data['travelGoal'] ?? '';


    // 선호도
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
