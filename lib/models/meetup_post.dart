// lib/models/meetup_post.dart
import 'package:flutter/material.dart'; // LatLng 사용 위해 추가
import 'package:google_maps_flutter/google_maps_flutter.dart'; // 실제 지도 연동 시

class MeetupPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorImageUrl;
  final String authorLocation; // 작성자 거주지 추가
  final String imageUrl; // 게시글 대표 이미지
  final String title;
  final int totalPeople;
  final int spotsLeft;
  final List<String> participantImageUrls; // 참여자 이미지 URL 리스트
  final List<String> categories; // 예: ['Sightseeing', 'Culture']
  final String description;
  final String eventLocation; // 예: "Seoul, Korea" (만나는 장소)
  // final LatLng eventCoordinates; // 실제 지도 연동 시 만나는 장소 좌표
  final String eventDateTimeString; // 예: "25th, April, 15:00~18:00"

  MeetupPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorImageUrl,
    required this.authorLocation, // 추가
    required this.imageUrl,
    required this.title,
    required this.totalPeople,
    required this.spotsLeft,
    required this.participantImageUrls,
    required this.categories,
    required this.description,
    required this.eventLocation,
    // this.eventCoordinates,
    required this.eventDateTimeString,
  });
}

// --- 임시 더미 데이터 생성 함수 수정 ---
List<MeetupPost> getDummyMeetupPosts() {
  return List.generate(5, (index) {
    List<String> participants = List.generate(
      (index % 4) + 3,
          (pIndex) => 'https://i.pravatar.cc/150?img=${index * 10 + pIndex + 1}',
    );
    int spots = (index % 3) + 1;
    int total = participants.length + spots;

    return MeetupPost(
      id: 'post_$index',
      authorId: 'user_${index % 3}',
      authorName: ['Amy', 'Brian', 'Charlie'][index % 3], // Amy 추가
      authorImageUrl: 'https://source.unsplash.com/random/100x100/?person&sig=${50 + index % 3}', // 작성자 이미지 변경
      authorLocation: ['Seoul, Korea', 'Busan, Korea', 'New York, USA'][index % 3], // 작성자 위치 추가
      imageUrl: 'https://source.unsplash.com/random/800x600/?food,picnic,nature&sig=$index', // 이미지 주제 변경
      title: ['Let\' have a picnic near mountain Fuji', 'Explore Gangnam Food Scene', 'Han River Sunset Walk', 'Visit Gyeongbok Palace Together', 'Hiking at Bukhansan'][index % 5], // 제목 변경
      totalPeople: total,
      spotsLeft: spots,
      participantImageUrls: participants,
      // --- 상세 정보 추가 ---
      categories: index % 2 == 0 ? ['Sightseeing', 'Culture'] : ['Food', 'Activity'], // 카테고리 예시
      description: "If you're looking to explore a peaceful and culturally rich spot off the typical tourist trail, I highly recommend visiting Yongbongsa Temple. As a local, I've been there many times, and each visit offers something new — a sense of calm, history, and beauty that's hard to find elsewhere. Let's enjoy the spring together!", // 설명 예시
      eventLocation: ['Near Mt. Fuji Station', 'Gangnam Station Exit 10', 'Yeouinaru Station Exit 2', 'Gyeongbok Palace Entrance', 'Bukhansan National Park Entrance'][index % 5], // 만남 장소 예시
      // eventCoordinates: LatLng(...), // 실제 좌표
      eventDateTimeString: '25th, April, 15:00~18:00', // 날짜/시간 예시
    );
  });
}

// 특정 ID의 더미 데이터 가져오는 함수 (상세 화면용)
MeetupPost getDummyPostDetail(String postId) {
  // 실제 앱에서는 postId로 API 호출 또는 DB 조회
  // 여기서는 더미 리스트에서 해당 ID를 찾거나, 없으면 첫 번째 항목 반환 (예시)
  return getDummyMeetupPosts().firstWhere((post) => post.id == postId, orElse: () => getDummyMeetupPosts().first);
}