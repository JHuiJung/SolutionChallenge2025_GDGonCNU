import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class UserState {
  static final UserState _instance = UserState._internal();
  factory UserState() => _instance;

  UserState._internal();

  String email = "";
  String name = "";
  String region = "";
  String gender = "";
  int age = 0;
  List<String> preferredLanguage = [];
  List<String> visitedCountries = [];
  String bio = "";
  List<String> postIds = [];
  List<String> comments = [];
  List<String> friendsEmail = [];
  String travelGoal = "";
  List<String> preferredTravelRegions = [];
  List<String> preferredActivities = [];
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

  String userEmail = "";
  String userName = "";
  String userPhoto = "";
  String commentContent = "";

}


void addUser() {
  final user = UserState(); // 싱글턴 인스턴스 호출

  FirebaseFirestore.instance.collection('users').add({
    'email': user.email,
    'name': user.name,
    'region': user.region,
    'gender': user.gender,
    'age': user.age,
    'preferredLanguage': user.preferredLanguage,
    'visitedCountries': user.visitedCountries,
    'bio': user.bio,
    'postIds': user.postIds,
    'comments': user.comments,
    'travelGoal': user.travelGoal,
    'preferredTravelRegions': user.preferredTravelRegions,
    'preferredActivities': user.preferredActivities,
    'timestamp': FieldValue.serverTimestamp(),
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
      print("해당 이메일의 유저가 없습니다.");
      return false;
    }

    final data = snapshot.docs.first.data();
    final user = UserState();

    user.email = data['email'] ?? '';
    user.name = data['name'] ?? '';
    user.region = data['region'] ?? '';
    user.gender = data['gender'] ?? '';
    user.age = data['age'] ?? 0;
    user.preferredLanguage = List<String>.from(data['preferredLanguage'] ?? []);
    user.visitedCountries = List<String>.from(data['visitedCountries'] ?? []);
    user.bio = data['bio'] ?? '';
    user.postIds = List<String>.from(data['postIds'] ?? []);
    user.comments = List<String>.from(data['comments'] ?? []);
    user.travelGoal = data['travelGoal'] ?? '';
    user.preferredTravelRegions = List<String>.from(data['preferredTravelRegions'] ?? []);
    user.preferredActivities = List<String>.from(data['preferredActivities'] ?? []);

    print("유저 정보 로드 성공: ${user.name}");
    return true;
  } catch (e) {
    print("유저 정보 가져오기 오류: $e");
    return false;
  }
}
