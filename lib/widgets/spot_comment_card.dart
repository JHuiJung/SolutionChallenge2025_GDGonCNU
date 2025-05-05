// lib/widgets/spot_comment_card.dart
import 'package:flutter/material.dart';
import '../models/spot_comment_model.dart';

class SpotCommentCard extends StatelessWidget {
  final SpotCommentModel comment;

  const SpotCommentCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      width: MediaQuery.of(context).size.width * 0.7, // 카드 너비
      margin: const EdgeInsets.only(right: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withValues(alpha: 0.5), // 반투명 배경
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 댓글 작성자 프로필 사진
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade400,
                backgroundImage: comment.commenterImageUrl != null
                    ? NetworkImage(comment.commenterImageUrl!)
                    : null,
                child: comment.commenterImageUrl == null
                    ? const Icon(Icons.person, size: 20, color: Colors.white70)
                    : null,
              ),
              const SizedBox(width: 8),
              // 댓글 작성자 이름
              Expanded(
                child: Text(
                  comment.commenterName,
                  style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 별점 표시
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < comment.rating.floor() // 채워진 별
                    ? Icons.star_rounded
                    : index < comment.rating // 반쪽 별 (필요시 구현)
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded, // 빈 별
                color: Colors.amber,
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 8),
          // 댓글 내용 (최대 2줄)
          Expanded( // 남은 공간 채우도록 Expanded 추가
            child: Text(
              comment.text,
              style: textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}