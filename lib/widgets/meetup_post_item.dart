// lib/widgets/meetup_post_item.dart
import 'package:flutter/material.dart';
import '../models/meetup_post.dart';
// import 'overlapping_avatars.dart'; // Participant avatars are not in the new design

class MeetupPostItem extends StatelessWidget {
  final MeetupPost post;

  const MeetupPostItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isLightMode = colorScheme.brightness == Brightness.light;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/post_detail', arguments: post.id);
          //Navigator.pushNamed(context, '/post_detail', arguments: post);
          print('Navigate to post detail: ${post.id}');
        },
        child: Container(
          padding: const EdgeInsets.all(12.0),
          height: 150, // Maintain height for now (Increase this value if overflow occurs)
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Left image
              _buildImage(),
              const SizedBox(width: 12),

              // 2. Right text info area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category chips
                    _buildCategoryChips(context, colorScheme),
                    // *** Adjust spacing ***
                    const SizedBox(height: 4), // Reduced from original 6

                    // Title
                    Text(
                      post.title,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // *** Adjust spacing ***
                    const SizedBox(height: 3), // Reduced from original 4

                    // Location info
                    _buildInfoRow(context, Icons.location_on_outlined, post.eventLocation, textTheme),
                    // *** Adjust spacing ***
                    const SizedBox(height: 3), // Reduced from original 4

                    // Time info
                    _buildInfoRow(context, Icons.access_time_outlined, post.eventDateTimeString, textTheme),

                    // Keep Spacer to push bottom info down
                    const Spacer(),

                    // Author and participation info
                    _buildBottomRow(context, textTheme, colorScheme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Left image builder
  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.network(
        post.imageUrl,
        width: 100,
        height: double.infinity, // Container height (140) - padding (24) = 116
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : Container(width: 100, color: Colors.grey.shade300, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
        errorBuilder: (context, error, stack) => Container(
          width: 100,
          color: Colors.grey.shade400,
          child: const Icon(Icons.broken_image, color: Colors.white54),
        ),
      ),
    );
  }

  // Category chips builder
  Widget _buildCategoryChips(BuildContext context, ColorScheme colorScheme) {
    return Wrap(
      spacing: 6.0,
      runSpacing: 4.0,
      children: post.categories.take(2).map((category) => Chip(
        label: Text(category),
        labelStyle: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8)),
        backgroundColor: colorScheme.surfaceVariant.withValues(alpha: 0.5),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 0),
        visualDensity: VisualDensity.compact,
        side: BorderSide.none,
      )).toList(),
    );
  }

  // Info row builder (icon + text)
  Widget _buildInfoRow(BuildContext context, IconData icon, String text, TextTheme textTheme) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Bottom row builder (author + participation info)
  Widget _buildBottomRow(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Author info
        CircleAvatar(
          radius: 12,
          backgroundImage: NetworkImage(post.authorImageUrl),
          backgroundColor: Colors.grey.shade300,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            post.authorName,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),

        // Participation info (using RichText)
        RichText(
          text: TextSpan(
            // Set base style slightly smaller like bodySmall
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.8)),
            children: [
              TextSpan(
                text: '${post.totalPeople}',
                // Numbers slightly emphasized (bold, slightly darker)
                style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface.withValues(alpha: 0.9)),
              ),
              const TextSpan(text: ' people · '), // Separated by dot
              TextSpan(
                text: '${post.spotsLeft}',
                style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface.withValues(alpha: 0.9)),
              ),
              const TextSpan(text: ' left'),
            ],
          ),
        ),
      ],
    );
  }
}