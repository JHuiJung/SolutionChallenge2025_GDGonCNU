// lib/screens/mypage_screen.dart
import 'package:flutter/material.dart';
import '../models/user_profile_model.dart'; // 내 프로필 모델
import '../models/meetup_post.dart'; // 호스팅 글 모델
import '../models/comment_model.dart'; // 코멘트 모델
import '../widgets/meetup_post_item.dart'; // 호스팅 글 위젯
import '../widgets/comment_item.dart'; // 코멘트 위젯
import '../widgets/language_indicator.dart'; // 언어 점 위젯
import '../widgets/preference_display_box.dart'; // 선호도 박스 위젯


class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  // --- 데이터 로딩 상태 (실제 구현 시 필요) ---
  bool _isLoading = true;
  late UserProfileModel _userProfile;
  late List<MeetupPost> _hostedPosts;
  late List<CommentModel> _comments;

  @override
  void initState() {
    super.initState();
    _loadMyPageData();
  }

  // 비동기 데이터 로딩 함수 (예시)
  Future<void> _loadMyPageData() async {
    setState(() => _isLoading = true);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // TODO: 실제 API 호출 또는 로컬 DB에서 데이터 가져오기
    _userProfile = getDummyMyProfile();
    // 호스팅 글 필터링 (예시: authorId가 내 ID와 같은 글)
    _hostedPosts = getDummyMeetupPosts()
        .where((post) => post.authorId == _userProfile.userId) // 실제 ID 비교 필요
        .toList();
    if (_hostedPosts.isEmpty && getDummyMeetupPosts().isNotEmpty) {
      // 내 글이 없으면 다른 사람 글이라도 하나 보여주기 (더미 데이터용)
      _hostedPosts.add(getDummyMeetupPosts().first);
    }
    _comments = getDummyComments();

    setState(() => _isLoading = false);
  }


  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // 선호도 박스 스타일 정의
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
          // 1. 상단 AppBar (이름, 나이, 뒤로가기)
          SliverAppBar(
            pinned: true, // 스크롤 시 상단에 고정
            // backgroundColor: colorScheme.surface, // 테마 배경색 사용
            elevation: 1, // 약간의 그림자
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              '${_userProfile.name}, ${_userProfile.age}',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            centerTitle: true, // 제목 중앙 정렬
            actions: [
              IconButton(
                icon: Icon(Icons.edit, color: colorScheme.onSurface), // 연필 아이콘
                onPressed: () {
                  // 프로필 수정 화면으로 이동
                  Navigator.pushNamed(context, '/edit_mypage');
                  print('Navigate to Edit MyPage');
                },
                tooltip: 'Edit Profile', // 툴팁 추가
              ),
              const SizedBox(width: 8), // 오른쪽 여백
            ],
            // --- actions 추가 끝 ---
          ),

          // 2. 헤더 영역 (지도 배경, 프로필 사진, 상태 메시지)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280, // 헤더 영역 높이 조절
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 지도 배경 (실제 지도 SDK 또는 이미지 사용)
                  Positioned.fill(
                    child: Image.network( // 예시 이미지
                      'https://developers.google.com/static/maps/images/landing/hero_geocoding_api.png',
                      fit: BoxFit.cover,
                      color: Colors.black.withValues(alpha: 0.1), // 약간 어둡게 처리 (선택 사항)
                      colorBlendMode: BlendMode.darken,
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade300),
                    ),
                  ),
                  // 프로필 사진 (지도 위에 표시)
                  Positioned(
                    top: 50, // 지도 상단에서부터의 위치
                    child: InkWell(
                      onTap: () {
                        // 프로필 사진 편집 화면으로 이동 (Placeholder)
                        Navigator.pushNamed(context, '/edit_profile_picture');
                        print('Navigate to edit profile picture');
                      },
                      child: CircleAvatar(
                        radius: 65, // 사진 크기
                        backgroundColor: Colors.white, // 테두리 효과
                        child: CircleAvatar(
                          radius: 62,
                          backgroundImage: NetworkImage(_userProfile.profileImageUrl),
                          backgroundColor: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  // 상태 메시지 (프로필 사진 아래)
                  Positioned(
                    top: 185, // 프로필 사진 아래 위치하도록 조정
                    child: Text(
                      _userProfile.statusMessage,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // 배경이 어두우므로 흰색 텍스트
                        shadows: [ // 텍스트 가독성 향상 (선택 사항)
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. 정보 섹션 (Info, Language, Preferences) - 패딩 추가
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // --- Info ---
                _buildSectionTitle(context, 'Info'),
                _buildInfoRow(context, Icons.location_on_outlined, _userProfile.location),
                _buildInfoRow(context, Icons.access_time, _userProfile.timeZoneInfo),
                const SizedBox(height: 24),

                // --- Language ---
                _buildSectionTitle(context, 'Language'),
                ..._userProfile.languages.map((lang) => _buildLanguageRow(context, lang)),
                const SizedBox(height: 24),

                // --- Preferences ---
                PreferenceDisplayBox(
                  title: 'I like',
                  content: _userProfile.likes,
                  backgroundColor: prefBoxBgColor,
                  titleColor: prefBoxTitleColor,
                  contentColor: prefBoxContentColor,
                  borderColor: prefBoxBorderColor,
                ),
                const SizedBox(height: 12),
                PreferenceDisplayBox(
                  title: "I've been",
                  content: _userProfile.placesBeen,
                  backgroundColor: prefBoxBgColor,
                  titleColor: prefBoxTitleColor,
                  contentColor: prefBoxContentColor,
                  borderColor: prefBoxBorderColor,
                ),
                const SizedBox(height: 12),
                PreferenceDisplayBox(
                  title: 'I want you to',
                  content: _userProfile.wantsToDo,
                  backgroundColor: prefBoxBgColor,
                  titleColor: prefBoxTitleColor,
                  contentColor: prefBoxContentColor,
                  borderColor: prefBoxBorderColor,
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),

          // 4. Hosting 섹션
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(child: _buildSectionTitle(context, 'Hosting')),
          ),
          _hostedPosts.isEmpty
              ? SliverPadding( // 호스팅 글 없을 때 메시지
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            sliver: SliverToBoxAdapter(
              child: Center(child: Text('No meet-ups hosted yet.', style: TextStyle(color: Colors.grey))),
            ),
          )
              : SliverPadding( // 호스팅 글 목록
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => MeetupPostItem(post: _hostedPosts[index]),
                childCount: _hostedPosts.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)), // 섹션 간 여백

          // 5. Comments 섹션
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(child: _buildSectionTitle(context, 'Comments')),
          ),
          _comments.isEmpty
              ? SliverPadding( // 코멘트 없을 때 메시지
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            sliver: SliverToBoxAdapter(
              child: Center(child: Text('No comments yet.', style: TextStyle(color: Colors.grey))),
            ),
          )
              : SliverPadding( // 코멘트 목록
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return Column( // 각 코멘트 아래 구분선 추가
                    children: [
                      CommentItem(comment: _comments[index]),
                      if (index < _comments.length - 1)
                        Divider(height: 1, thickness: 1, color: colorScheme.surfaceVariant.withValues(alpha: 0.3)),
                    ],
                  );
                },
                childCount: _comments.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)), // 맨 아래 여백
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  // 섹션 제목 위젯
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  // 정보 행 위젯 (아이콘 + 텍스트)
  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
          const SizedBox(width: 12),
          Expanded( // 긴 텍스트 줄바꿈 처리
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  // 언어 행 위젯 (국기 + 이름 + 능숙도)
  Widget _buildLanguageRow(BuildContext context, UserLanguage language) {
    // TODO: languageCode에 맞는 실제 국기 이미지 에셋 필요
    String flagAssetPath = 'assets/flags/korea.jpg'; // 예시 경로
    //String flagAssetPath = 'assets/flags/usa.jpg'; // 예시 경로

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // 국기 이미지 (에셋 필요)
          Image.asset(
            flagAssetPath,
            width: 24,
            height: 18, // 비율 유지
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => // 에러 시 Placeholder
            Container(width: 24, height: 18, color: Colors.grey.shade300, child: Icon(Icons.flag, size: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              language.languageName,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          LanguageIndicator(proficiency: language.proficiency), // 능숙도 점 표시
        ],
      ),
    );
  }
}

// --- Placeholder Screen for Editing Profile Picture ---
class EditProfilePictureScreen extends StatelessWidget {
  const EditProfilePictureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile Picture')),
      body: const Center(child: Text('Image picker/cropper interface goes here')),
    );
  }
}

