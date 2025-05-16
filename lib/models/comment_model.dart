// lib/models/comment_model.dart
class CommentModel {
  final String commentId;
  final String commenterId;
  final String commenterName;
  final String commenterInfo; // e.g., "America, 20"
  final String commenterImageUrl;
  final String commentText;
  final DateTime timestamp; // Comment creation time

  CommentModel({
    required this.commentId,
    required this.commenterId,
    required this.commenterName,
    required this.commenterInfo,
    required this.commenterImageUrl,
    required this.commentText,
    required this.timestamp,
  });
}

// --- Temporary Dummy Data Creation Function ---
List<CommentModel> getDummyComments() {
  return [
    CommentModel(
      commentId: 'comment_1',
      commenterId: 'user_brian',
      commenterName: 'Brian',
      commenterInfo: 'America, 20',
      commenterImageUrl: 'https://i.pravatar.cc/150?img=50',
      commentText: 'Amy is such a nice person! Strongly recommend to hang out with her!!',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    CommentModel(
      commentId: 'comment_2',
      commenterId: 'user_charlie',
      commenterName: 'Charlie',
      commenterInfo: 'UK, 25',
      commenterImageUrl: 'https://i.pravatar.cc/150?img=52',
      commentText: 'Had a great time exploring the city together. Very knowledgeable and friendly.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];
}