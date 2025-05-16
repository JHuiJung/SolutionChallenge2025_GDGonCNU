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
      width: MediaQuery.of(context).size.width * 0.7, // Card width
      margin: const EdgeInsets.only(right: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withValues(alpha: 0.5), // Translucent background
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Comment author's profile picture
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
              // Comment author's name
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
          // Display rating
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < comment.rating.floor() // Filled star
                    ? Icons.star_rounded
                    : index < comment.rating // Half star (implement if needed)
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded, // Empty star
                color: Colors.amber,
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 8),
          // Comment text (max 2 lines)
          Expanded( // Add Expanded to fill remaining space
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