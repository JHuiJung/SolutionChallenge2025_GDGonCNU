// lib/models/meetup_post.dart
class MeetupPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorImageUrl;
  final String imageUrl;
  final String title;
  final int totalPeople;
  final int spotsLeft;
  final List<String> participantImageUrls; // 참여자 이미지 URL 리스트

  MeetupPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorImageUrl,
    required this.imageUrl,
    required this.title,
    required this.totalPeople,
    required this.spotsLeft,
    required this.participantImageUrls,
  });
}

// --- 임시 더미 데이터 생성 함수 ---
List<MeetupPost> getDummyMeetupPosts() {
  return List.generate(5, (index) {
    // 참여자 이미지 URL 생성 (임시)
    List<String> participants = List.generate(
      (index % 4) + 3, // 3~6명의 참여자
          (pIndex) => 'https://i.pravatar.cc/150?img=${index * 10 + pIndex + 1}', // 고유 이미지
    );

    return MeetupPost(
      id: 'post_$index',
      authorId: 'user_${index % 3}', // 3명의 작성자 번갈아
      authorName: ['Brian', 'Alice', 'Charlie'][index % 3],
      authorImageUrl: 'https://i.pravatar.cc/150?img=${50 + index % 3}', // 작성자 이미지
      // Unsplash의 자연 관련 랜덤 이미지 사용 (실제로는 업로드된 이미지 URL 사용)
      imageUrl: 'https://source.unsplash.com/random/800x600/?nature,landscape&sig=$index',
      title: 'Amazing Trip Plan #${index + 1}',
      totalPeople: participants.length + (index % 3) + 1, // 총 인원 (참여자 + 남은 자리)
      spotsLeft: (index % 3) + 1, // 남은 자리 (1~3)
      participantImageUrls: participants,
    );
  });
}