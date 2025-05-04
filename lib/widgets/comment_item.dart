// lib/widgets/comment_item.dart
import 'package:flutter/material.dart';
import '../models/comment_model.dart'; // 코멘트 모델 임포트

class CommentItem extends StatelessWidget {
  final CommentModel comment;

  const CommentItem({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      // Card 대신 Container와 Divider 사용 가능
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              // 코멘트 작성자 프로필로 이동
              Navigator.pushNamed(context, '/user_profile', arguments: comment.commenterId);
              print('Navigate to commenter profile: ${comment.commenterId}');
            },
            child: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(comment.commenterImageUrl),
              backgroundColor: Colors.grey.shade300,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row( // 이름과 정보(지역, 나이)를 한 줄에 표시
                  children: [
                    Text(
                      comment.commenterName,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.commenterInfo, // 예: "America, 20"
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.commentText,
                  style: textTheme.bodyMedium?.copyWith(height: 1.4), // 줄 간격
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}