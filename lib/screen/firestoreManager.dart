import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void addUser() {
  FirebaseFirestore.instance.collection('users').add({
    'name': '홍길동',
    'age': 25,
    'timestamp': FieldValue.serverTimestamp(),
  }).then((DocumentReference doc) {
    print('Document added with ID: ${doc.id}');
  });
}

/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void addUser({
  required String name,
  required String region,
  required String gender,
  required int age,
  required String preferredLanguage,
  required List<String> visitedCountries,
  required String bio,
  required List<String> postIds,
  required List<String> comments,
  required String travelGoal,
  required List<String> preferredTravelRegions,
  required List<String> preferredActivities,
}) {
  print("add 버튼 눌림");

  FirebaseFirestore.instance.collection('users').add({
    'name': name,
    'region': region,
    'gender': gender,
    'age': age,
    'preferredLanguage': preferredLanguage,
    'visitedCountries': visitedCountries, // 갔다온 지역(나라)
    'bio': bio, // 하고싶은말
    'postIds': postIds, // 올린 글 id 리스트
    'comments': comments, // 코멘트
    'travelGoal': travelGoal, // 선호 여행 목표
    'preferredTravelRegions': preferredTravelRegions, // 자연, 도시 등
    'preferredActivities': preferredActivities, // 맛집 탐방 등
    'timestamp': FieldValue.serverTimestamp(),
  }).then((DocumentReference doc) {
    print('Document added with ID: ${doc.id}');
  });

  print("addUser 함수 끝");
}

 */