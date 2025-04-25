// lib/widgets/meetup_post_item.dart
import 'package:flutter/material.dart';
import '../models/meetup_post.dart';
import 'overlapping_avatars.dart'; // 겹치는 아바타 위젯 임포트

class MeetupPostItem extends StatelessWidget {
  final MeetupPost post;

  const MeetupPostItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color detailBackgroundColor = colorScheme.brightness == Brightness.light
        ? Colors.grey.shade200 // 밝은 모드 배경
        : Colors.grey.shade800; // 어두운 모드 배경

    return Card( // Card 위젯으로 감싸 그림자와 경계 표현 (선택 사항)
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      elevation: 2, // 약간의 그림자
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias, // Card 내부 컨텐츠가 경계를 넘지 않도록 함
      child: InkWell( // 게시글 전체 클릭 가능하도록
        onTap: () {
          // 게시글 상세 화면으로 이동 (post.id 전달)
          Navigator.pushNamed(context, '/post_detail', arguments: post.id);
          print('Navigate to post detail: ${post.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 작성자 정보
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: InkWell( // 작성자 정보 영역만 클릭 가능하도록
                onTap: () {
                  // 작성자 프로필 화면으로 이동 (post.authorId 전달)
                  Navigator.pushNamed(context, '/user_profile', arguments: post.authorId);
                  print('Navigate to user profile: ${post.authorId}');
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(post.authorImageUrl),
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      post.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. 게시글 이미지
            // AspectRatio를 사용하여 이미지 비율 유지 (선택 사항)
            AspectRatio(
              aspectRatio: 16 / 10, // 이미지 비율 조절
              child: Image.network(
                post.imageUrl,
                fit: BoxFit.cover, // 이미지가 영역을 꽉 채우도록
                // 로딩 중 Placeholder 표시
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                // 에러 발생 시 표시할 위젯
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                    ),
                  );
                },
              ),
            ),

            // 3. 게시글 상세 정보 (제목, 인원, 참여자 아바타)
            Container(
              color: detailBackgroundColor, // 디자인에 맞는 배경색
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center, // 세로 중앙 정렬
                children: [
                  // 왼쪽 텍스트 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2, // 제목 최대 2줄
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${post.totalPeople} people · ${post.spotsLeft} left',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16), // 텍스트와 아바타 사이 간격

                  // 오른쪽 참여자 아바타
                  if (post.participantImageUrls.isNotEmpty)
                    OverlappingAvatars(imageUrls: post.participantImageUrls),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}