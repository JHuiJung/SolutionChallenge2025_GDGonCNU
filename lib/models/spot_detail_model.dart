// lib/models/spot_detail_model.dart
import 'spot_comment_model.dart'; // 댓글 모델 임포트

class SpotDetailModel {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final String quote; // 예: "You must go here in Spring."
  final String authorId;
  final String authorName;
  final String authorImageUrl;
  final String description;
  final String recommendTo; // 예: "People who like nature"
  final String canEnjoy; // 예: "The beauty of Korea"
  final List<SpotCommentModel> comments;

  SpotDetailModel({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.quote,
    required this.authorId,
    required this.authorName,
    required this.authorImageUrl,
    required this.description,
    required this.recommendTo,
    required this.canEnjoy,
    required this.comments,
  });
}

// --- 임시 더미 데이터 생성 함수 ---
SpotDetailModel getDummySpotDetail(String spotId) {
  // spotId에 따라 다른 데이터를 반환하도록 구현 가능
  return SpotDetailModel(
    id: spotId,
    name: 'Sensoji Temple', // 예시 이름
    location: 'Seoul, Korea',
    imageUrl: 'https://source.unsplash.com/random/800x1200/?temple,spring,korea&sig=${spotId.hashCode}', // 고유 이미지
    quote: '"You must go here in Spring."',
    authorId: 'user_amy', // 글 작성자 ID
    authorName: 'Amy',
    authorImageUrl: 'https://source.unsplash.com/random/100x100/?person,woman&sig=1', // 글 작성자 이미지
    description: "If you're looking to explore a peaceful and culturally rich spot off the typical tourist trail, I highly recommend visiting Yongbongsa Temple. As a local, I've been there many times, and each visit offers something new — a sense of calm, history, and beauty that's hard to find elsewhere.",
    recommendTo: 'People who like nature and quiet places',
    canEnjoy: 'The beauty of Korean traditional architecture and spring blossoms',
    comments: getDummySpotComments(), // 댓글 더미 데이터
  );
}