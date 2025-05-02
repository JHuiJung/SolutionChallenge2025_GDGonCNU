// lib/models/spot_comment_model.dart
class SpotCommentModel {
  final String id;
  final String commenterId;
  final String commenterName;
  final String? commenterImageUrl; // null 가능
  final double rating; // 별점 (0.0 ~ 5.0)
  final String text;

  SpotCommentModel({
    required this.id,
    required this.commenterId,
    required this.commenterName,
    this.commenterImageUrl,
    required this.rating,
    required this.text,
  });
}

// --- 임시 더미 데이터 생성 함수 ---
List<SpotCommentModel> getDummySpotComments() {
  return List.generate(5, (index) => SpotCommentModel(
    id: 'comment_$index',
    commenterId: 'user_${index + 10}',
    commenterName: ['Explorer99', 'WanderlustGirl', 'LocalGuide', 'PhotoFanatic', 'HistoryBuff'][index % 5],
    commenterImageUrl: index % 3 == 0 ? null : 'https://i.pravatar.cc/150?img=${index + 10}', // 일부는 이미지 없음
    rating: (index % 5) + 0.5, // 0.5 ~ 4.5 별점
    text: [
      'Had a great time meeting locals and enjoying the view!',
      'Exploring hidden gems like this is why I travel. Beautiful!',
      'A must-visit, especially during the lantern festival.',
      'Took some amazing photos here. The light was perfect.',
      'Learned a lot about the history. Very informative guides.'
    ][index % 5],
  ));
}