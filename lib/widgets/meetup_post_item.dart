// lib/widgets/meetup_post_item.dart
import 'package:flutter/material.dart';
import '../models/meetup_post.dart';
// import 'overlapping_avatars.dart'; // 참여자 아바타는 새 디자인에 없음

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
          print('Navigate to post detail: ${post.id}');
        },
        child: Container(
          padding: const EdgeInsets.all(12.0),
          height: 150, // 높이는 일단 유지 (오버플로우가 되면, 이 값을 늘려)
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 왼쪽 이미지
              _buildImage(),
              const SizedBox(width: 12),

              // 2. 오른쪽 텍스트 정보 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 카테고리 칩
                    _buildCategoryChips(context, colorScheme),
                    // *** 간격 조정 ***
                    const SizedBox(height: 4), // 기존 6에서 줄임

                    // 제목
                    Text(
                      post.title,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // *** 간격 조정 ***
                    const SizedBox(height: 3), // 기존 4에서 줄임

                    // 위치 정보
                    _buildInfoRow(context, Icons.location_on_outlined, post.eventLocation, textTheme),
                    // *** 간격 조정 ***
                    const SizedBox(height: 3), // 기존 4에서 줄임

                    // 시간 정보
                    _buildInfoRow(context, Icons.access_time_outlined, post.eventDateTimeString, textTheme),

                    // Spacer는 그대로 두어 하단 정보를 밑으로 밀어냄
                    const Spacer(),

                    // 작성자 및 참여 정보
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

  // 왼쪽 이미지 빌더
  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.network(
        post.imageUrl,
        width: 100,
        height: double.infinity, // Container 높이(140) - 패딩(24) = 116
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

  // 카테고리 칩 빌더
  Widget _buildCategoryChips(BuildContext context, ColorScheme colorScheme) {
    return Wrap(
      spacing: 6.0,
      runSpacing: 4.0,
      children: post.categories.take(2).map((category) => Chip(
        label: Text(category),
        labelStyle: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant.withOpacity(0.8)),
        backgroundColor: colorScheme.surfaceVariant.withOpacity(0.5),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 0),
        visualDensity: VisualDensity.compact,
        side: BorderSide.none,
      )).toList(),
    );
  }

  // 정보 행 빌더 (아이콘 + 텍스트)
  Widget _buildInfoRow(BuildContext context, IconData icon, String text, TextTheme textTheme) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // 하단 행 빌더 (작성자 + 참여 정보)
  Widget _buildBottomRow(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 작성자 정보
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

        // 참여 정보 (RichText 사용)
        RichText(
          text: TextSpan(
            // 기본 스타일은 bodySmall 정도로 약간 작게 설정
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.8)),
            children: [
              TextSpan(
                text: '${post.totalPeople}',
                // 숫자는 조금 더 강조 (굵게, 약간 더 진하게)
                style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface.withOpacity(0.9)),
              ),
              const TextSpan(text: ' people · '), // 점으로 구분
              TextSpan(
                text: '${post.spotsLeft}',
                style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface.withOpacity(0.9)),
              ),
              const TextSpan(text: ' left'),
            ],
          ),
        ),
      ],
    );
  }
}