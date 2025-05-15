// lib/widgets/tourist_spot_card.dart
import 'package:flutter/material.dart';
import '../models/tourist_spot_model.dart';

class TouristSpotCard extends StatelessWidget {
  final TouristSpotModel spot;

  const TouristSpotCard({super.key, required this.spot});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      width: MediaQuery.of(context).size.width * 0.65, // 카드 너비 조절
      height: 200, // 카드 높이 조절 (패널 내부 SizedBox 높이랑 일치)
      margin: const EdgeInsets.only(right: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        // Card 대신 Container 사용 시 그림자 직접 추가 가능
        // boxShadow: [ BoxShadow(...) ],
      ),
      clipBehavior: Clip.antiAlias, // 내부 컨텐츠가 경계를 넘지 않도록
      child: InkWell( // 카드 클릭 가능하도록
        onTap: () {
          Navigator.pushNamed(context, '/spot_detail', arguments: spot.id);
          print('Navigate to spot detail: ${spot.id}');
          // print('Tapped on spot: ${spot.name}');
        },
        child: Stack(
          fit: StackFit.expand, // Stack이 Container 크기에 맞춰 확장
          children: [
            // 배경 이미지
            Image.network(
              spot.imageUrl,
              fit: BoxFit.cover,
              // 로딩/에러 처리
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              errorBuilder: (context, error, stack) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
            // 어두운 Gradient 오버레이 (텍스트 가독성 향상)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),
            // 텍스트 및 아이콘 정보 (하단 정렬)
            Positioned(
              bottom: 12.0,
              left: 12.0,
              right: 12.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 위치 정보 (아이콘 + 텍스트)
                  // Row(
                  //   children: [
                  //     const Icon(Icons.location_on, color: Colors.white, size: 16),
                  //     const SizedBox(width: 4),
                  //     Text(
                  //       spot.location,
                  //       style: textTheme.bodySmall?.copyWith(color: Colors.white),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 4),
                  // 관광지 이름
                  Text(
                    spot.name,
                    style: textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // 오른쪽 하단 화살표 버튼
            Positioned(
              bottom: 12.0,
              right: 12.0,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: colorScheme.onSurface,
                  size: 20,
                ),
              ),
            ),

            // 사진 작가 태그 (디자인 참고 - 분홍색) (추가 사항)
            // Positioned(
            //   top: 12.0,
            //   right: 12.0,
            //   child: Container(
            //     padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            //     decoration: BoxDecoration(
            //       color: Colors.pinkAccent.withOpacity(0.8),
            //       borderRadius: BorderRadius.circular(8.0),
            //     ),
            //     child: Text(
            //       spot.photographerName,
            //       style: textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            //     ),
            //   ),
            // ),

            // TODO: 분홍색 화살표 포인터, 보라색 아이콘 등 추가 구현 필요 (CustomPaint 등 사용 고려)

          ],
        ),
      ),
    );
  }
}