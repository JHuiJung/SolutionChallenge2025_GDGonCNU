// lib/widgets/overlapping_avatars.dart
import 'package:flutter/material.dart';

class OverlappingAvatars extends StatelessWidget {
  final List<String> imageUrls;
  final double avatarRadius;
  final double overlap; // 겹치는 정도 (0.0 ~ 1.0)
  final int maxAvatarsToShow;

  const OverlappingAvatars({
    super.key,
    required this.imageUrls,
    this.avatarRadius = 15.0, // 기본 아바타 반지름
    this.overlap = 0.4, // 기본 겹침 정도 (40%)
    this.maxAvatarsToShow = 4, // 최대 보여줄 아바타 수
  });

  @override
  Widget build(BuildContext context) {
    List<String> urlsToShow = imageUrls.take(maxAvatarsToShow).toList();
    double itemWidth = avatarRadius * 2 * (1 - overlap); // 각 아이템이 차지하는 너비

    return SizedBox(
      // 전체 위젯의 높이는 아바타 지름과 동일하게 설정
      height: avatarRadius * 2,
      // 전체 위젯의 너비 계산
      width: itemWidth * (urlsToShow.length -1) + (avatarRadius * 2),
      child: Stack(
        children: List.generate(urlsToShow.length, (index) {
          return Positioned(
            // 왼쪽에서부터 겹치도록 위치 계산
            left: itemWidth * index,
            // Stack 내에서 위아래 중앙 정렬 효과
            top: 0,
            bottom: 0,
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Colors.grey.shade300, // 이미지 로딩 전 배경
              // 테두리를 주어 겹치는 부분을 명확히 함 (선택 사항)
              child: CircleAvatar(
                radius: avatarRadius - 1, // 테두리 두께만큼 빼줌
                backgroundImage: NetworkImage(urlsToShow[index]),
                onBackgroundImageError: (exception, stackTrace) {
                  // 이미지 로드 실패 시 기본 아이콘 표시 (선택 사항)
                  // print('Error loading avatar: $exception');
                },
                child: Builder( // 에러 처리 시 child가 필요할 수 있음
                    builder: (context) {
                      // NetworkImage가 로드되면 이 child는 보이지 않음
                      // 에러 발생 시 여기에 아이콘 등을 표시할 수 있음
                      // 예: Icon(Icons.person, size: avatarRadius);
                      return const SizedBox.shrink();
                    }
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}