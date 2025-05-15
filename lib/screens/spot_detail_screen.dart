// lib/screens/spot_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/spot_detail_model.dart';
import '../widgets/preference_display_box.dart'; // 재사용
import '../widgets/spot_comment_card.dart';
import '../firebase/firestoreManager.dart';
import '../models/spot_comment_model.dart';

class SpotDetailScreen extends StatefulWidget {
  const SpotDetailScreen({super.key});

  @override
  State<SpotDetailScreen> createState() => _SpotDetailScreenState();
}

class _SpotDetailScreenState extends State<SpotDetailScreen> {
  bool _isLoading = true;
  late SpotDetailModel _spotDetail;
  String? _spotId;

  List<SpotCommentModel> spotComments = [];

  get outlineColorWithOpacity => null;

  @override
  void initState() {
    super.initState();
    // 빌드 후 spotId를 가져와 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        _spotId = ModalRoute.of(context)?.settings.arguments as String;
        _loadSpotDetails(_spotId!);
      } else {
        // ID가 없을 경우 처리
        setState(() => _isLoading = false);
        print("Error: Spot ID not provided.");
        // Navigator.pop(context); // 또는 에러 메시지 표시
      }
    });



  }

  Future<void> _loadSpotDetails(String spotId) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400)); // Simulate loading
    // TODO: 실제 API 호출 또는 DB 조회로 spotId에 맞는 데이터 가져오기
    //_spotDetail = getDummySpotDetail(spotId);
    SpotDetailModel _spotdummy = getDummySpotDetail(spotId);
    _spotDetail = await getSpotPostById(spotId) ?? _spotdummy;
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // 선호도 박스 스타일 (MyPage와 유사하게)
    final Color prefBoxBgColor = colorScheme.brightness == Brightness.light
        ? Colors.purple.shade50.withValues(alpha: 0.7)
        : Colors.purple.shade900.withValues(alpha: 0.5);
    final Color prefBoxTitleColor = colorScheme.onSurface.withValues(alpha: 0.6);
    final Color prefBoxContentColor = colorScheme.onSurface;
    final Color prefBoxBorderColor = Colors.purple.shade300;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: <Widget>[
          // 1. 상단 이미지 및 정보 영역 (SliverAppBar)
          _buildSliverAppBar(context, colorScheme, textTheme),

          // 2. 본문 내용 영역 (SliverList)
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 여행지 설명
                Text(
                  _spotDetail.description,
                  style: textTheme.bodyLarge?.copyWith(height: 1.5), // 줄 간격
                ),
                const SizedBox(height: 24),

                // 추천 대상
                PreferenceDisplayBox(
                  title: 'Recommend to',
                  content: _spotDetail.recommendTo,
                  backgroundColor: prefBoxBgColor,
                  titleColor: prefBoxTitleColor,
                  contentColor: prefBoxContentColor,
                  borderColor: prefBoxBorderColor,
                ),
                const SizedBox(height: 12),

                // 즐길 거리
                PreferenceDisplayBox(
                  title: 'You can enjoy',
                  content: _spotDetail.canEnjoy,
                  backgroundColor: prefBoxBgColor,
                  titleColor: prefBoxTitleColor,
                  contentColor: prefBoxContentColor,
                  borderColor: prefBoxBorderColor,
                ),
                const SizedBox(height: 24),

                // --- Comments 섹션 제목 수정 ---
                Row( // 제목과 버튼을 위한 Row
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Comments',
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    // 코멘트 작성 버튼 추가
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: colorScheme.onSurface.withOpacity(0.7)),
                      onPressed: () {
                        // 스팟 코멘트 작성 화면으로 이동 (spotId 전달)
                        Navigator.pushNamed(context, '/write_spot_comment', arguments: _spotId);
                      },
                      tooltip: 'Write a comment',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                Divider(thickness: 1, height: 20, color: outlineColorWithOpacity), // 구분선
                // --- Comments 섹션 제목 수정 끝 ---
              ]),
            ),
          ),

          // 3. 댓글 목록 (가로 스크롤)
          _buildCommentsSection(context),

          // 하단 여백 추가
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  // SliverAppBar 빌더
  Widget _buildSliverAppBar(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return SliverAppBar(
      expandedHeight: 350.0, // 이미지 영역 높이
      stretch: true, // 오버스크롤 시 이미지 늘어나도록
      pinned: true, // 스크롤 시 상단에 AppBar 고정
      backgroundColor: colorScheme.surface, // 고정될 때 AppBar 배경색
      iconTheme: const IconThemeData(color: Colors.white), // 뒤로가기 버튼 색상 (초기)
      // 고정될 때 아이콘 색상 변경 (선택 사항)
      // surfaceTintColor: colorScheme.onSurface,

      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
        // 제목은 사용하지 않음 (직접 배치)
        // title: Text('Details'),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 배경 이미지
            Image.network(
              _spotDetail.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : Container(color: Colors.grey.shade300), // 로딩 중 회색 배경
              errorBuilder: (context, error, stack) => Container(
                color: Colors.grey.shade400,
                child: const Icon(Icons.broken_image, color: Colors.white54, size: 50),
              ),
            ),
            // 어두운 Gradient 오버레이
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.0, 0.5, 1.0], // 그라데이션 범위 조절
                ),
              ),
            ),
            // 이미지 위 텍스트 및 프로필 정보 (하단 정렬)
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 위치
                  // Row(
                  //   children: [
                  //     const Icon(Icons.location_on, color: Colors.white, size: 16),
                  //     const SizedBox(width: 4),
                  //     Text(
                  //       _spotDetail.location,
                  //       style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 8),
                  // 장소 이름
                  Text(
                    _spotDetail.name,
                    style: textTheme.displaySmall?.copyWith( // 더 큰 제목 스타일
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black.withValues(alpha: 0.5))],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 한 줄 소개 (Quote)
                  Text(
                    _spotDetail.quote,
                    style: textTheme.titleMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 12),
                  // 작성자 정보
                  InkWell( // 클릭 가능하도록
                    onTap: () {
                      // 작성자 프로필 화면으로 이동
                      Navigator.pushNamed(context, '/user_profile', arguments: _spotDetail.authorId);
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(_spotDetail.authorImageUrl),
                          backgroundColor: Colors.grey.shade300,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _spotDetail.authorName,
                          style: textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 댓글 섹션 빌더 (가로 스크롤)
  Widget _buildCommentsSection(BuildContext context) {
    // SliverToBoxAdapter를 사용하여 CustomScrollView 내부에 가로 ListView 배치
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 150, // 댓글 카드 높이 + 여백 고려
        //child: _spotDetail.comments.isEmpty
        child: spotComments.isEmpty
            ? Center( // 댓글 없을 때 메시지
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('No comments yet.', style: TextStyle(color: Colors.grey)),
          ),
        )
            : ListView.builder(
          scrollDirection: Axis.horizontal, // 가로 스크롤
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //itemCount: _spotDetail.comments.length,
          itemCount: spotComments.length,
          itemBuilder: (context, index) {
            //return SpotCommentCard(comment: _spotDetail.comments[index]);
            return SpotCommentCard(comment: spotComments[index]);
          },
        ),
      ),
    );
  }
}