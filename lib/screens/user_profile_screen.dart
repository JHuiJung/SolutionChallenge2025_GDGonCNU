// lib/screens/user_profile_screen.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // Timer 등 비동기 작업에 필요할 수 있음

// --- 모델 임포트 (경로 확인 필요) ---
import '../models/user_profile_model.dart';
import '../models/meetup_post.dart';
import '../models/comment_model.dart';

// --- 위젯 임포트 (경로 확인 필요) ---
import '../widgets/meetup_post_item.dart';
import '../widgets/comment_item.dart';
import '../widgets/language_indicator.dart';
import '../widgets/preference_display_box.dart';
import '../firebase/firestoreManager.dart';

// --- 더미 데이터 함수 (실제로는 별도 파일 또는 API 호출로 대체) ---
// UserProfileModel에 userId를 받는 생성자 또는 함수가 있다고 가정
/*UserProfileModel getDummyUserProfile(String userId) {
  // userId에 따라 다른 더미 데이터 반환 (예시)
  bool isJohn = userId == 'user_john'; // 예시 ID
  return UserProfileModel(
    userId: userId,
    name: isJohn ? 'John' : 'Another User',
    age: isJohn ? 27 : 25,
    location: isJohn ? 'Seoul, Korea' : 'Busan, Korea',
    timeZoneInfo: isJohn ? '13:37 (-7hours)' : '14:00 (+9 hours)', // 실제로는 계산 필요
    profileImageUrl: isJohn
        ? 'https://img.freepik.com/free-psd/3d-illustration-person-with-sunglasses_23-2149436188.jpg?size=626&ext=jpg' // John 이미지
        : 'https://source.unsplash.com/random/200x200/?person&sig=${userId.hashCode}', // 다른 사용자 랜덤 이미지
    statusMessage: isJohn ? "Let's hang out!" : "Exploring the world!",
    languages: [
      UserLanguage(languageCode: 'ko', languageName: 'Korean', proficiency: isJohn ? 4 : 5),
      UserLanguage(languageCode: 'en', languageName: 'English', proficiency: isJohn ? 5 : 3),
    ],
    likes: isJohn ? 'Shopping, Movie, Coding' : 'Hiking, Photography, Reading',
    placesBeen: isJohn ? 'Japan, America, India, Germany' : 'Thailand, Vietnam, Spain',
    wantsToDo: isJohn ? 'make a happy memory with me' : 'find hidden gems',
  );
}*/

UserProfileModel getUserProfile(UserState userInfo) {
  // userId에 따라 다른 더미 데이터 반환 (예시)

  return UserProfileModel(
    userId: userInfo.email ?? 'noneEmail',
    name: userInfo.name ?? 'noneName',
    age: userInfo.birthYear ?? 0,
    location: userInfo.region ?? 'Seoul, Korea',
    timeZoneInfo: DateTime.now().toString().split('.').first, // 실제로는 계산 필요
    profileImageUrl: userInfo.profileURL, // 다른 사용자 랜덤 이미지
    statusMessage: userInfo.statusMessage,
    languages: userInfo.languages,
    likes: userInfo.iLike,
    placesBeen: userInfo.visitedCountries.join(', '),
    wantsToDo: userInfo.wantsToDo,
  );
}

List<MeetupPost> getDummyHostedPosts(String userId) {
  // userId가 작성한 글만 필터링 (예시)
  return getDummyMeetupPosts()
      .where((post) => post.authorId == userId)
      .toList();
}

List<CommentModel> getDummyCommentsAboutUser(String userId) {
  // userId에 대한 코멘트만 필터링 (예시 - 실제로는 대상이 userId인 코멘트 조회)
  return getDummyComments()
      .where((comment) => userId == 'user_john') // John 프로필에만 코멘트 보이도록 (임시)
      .toList();
}
// --- 더미 데이터 함수 끝 ---


class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = true;
  late UserProfileModel _userProfile;
  late List<MeetupPost> _hostedPosts;
  late List<CommentModel> _comments;
  String? _userId;
  bool _isFollowing = false; // 현재 내가 이 사용자를 팔로우하는지 여부 (DB 연동 필요)
  bool _isProcessingFollow = false; // 팔로우/언팔로우 처리 중 플래그

  late UserState? userInfo;

  @override
  void initState() {
    super.initState();



    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        _userId = ModalRoute.of(context)?.settings.arguments as String;
        _loadUserProfileData(_userId!);

      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        print("Error: User ID not provided for profile screen.");
        // Navigator.pop(context); // ID 없으면 이전 화면으로
      }
    });
  }

  Future<void> _loadUserProfileData(String userId) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400)); // Simulate loading

    userInfo = await getAnotherUserInfoByEmail(_userId ?? '');

    // TODO: 실제 API 또는 DB에서 userId 기반으로 데이터 로드
    // _userProfile = getDummyUserProfile(userId);
    _userProfile = getUserProfile(userInfo ?? mainUserInfo);
    // _hostedPosts = getDummyHostedPosts(userId);
    _hostedPosts = [];

    //print("🚒 가능한 언어 개수 : ${_userProfile.languages.length}");

    List<String> userHostIds = userInfo?.postIds ?? [];

    for(int i = 0 ; i < userHostIds.length;++i)
      {
        MeetupPost? _post = await getMeetUpPostById(userHostIds[i]);

        if(_post != null)
          {
            _hostedPosts.add(_post);
          }
      }

    _comments = getDummyCommentsAboutUser(userId);
    // TODO: 현재 로그인한 사용자가 이 userId를 팔로우하는지 DB에서 확인하여 _isFollowing 설정

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  // 팔로우/언팔로우 처리 함수
  Future<void> _handleFollowToggle() async {
    if (_isProcessingFollow) return; // 처리 중이면 중복 방지

    setState(() => _isProcessingFollow = true);

    // TODO: 실제 서버/DB에 팔로우 또는 언팔로우 요청 보내기
    // 요청 성공 시 _isFollowing 상태 업데이트
    await Future.delayed(const Duration(milliseconds: 500)); // 시뮬레이션

    if (mounted) {
      setState(() {
        _isFollowing = !_isFollowing; // 상태 토글
        _isProcessingFollow = false;
      });
      print('Follow status toggled for user: $_userId. Now following: $_isFollowing');
    }
  }



  // 전화 걸기 함수 (Placeholder)
  void _handleCall() {
    // TODO: url_launcher 패키지 등을 사용하여 전화 걸기 기능 구현
    // final Uri telLaunchUri = Uri(scheme: 'tel', path: _userProfile.phoneNumber); // 전화번호 필드 필요
    // await launchUrl(telLaunchUri);
    print('Call button pressed for user: ${_userProfile.name} (Not implemented)');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calling feature is not implemented yet.')),
    );
  }

  // 메시지 보내기 함수
  void _handleMessage() {
    // TODO: 채팅방 ID를 생성하거나 기존 ID를 찾는 로직 필요
    // 임시로 userId를 chatId처럼 사용
    Navigator.pushNamed(context, '/chat_room', arguments: _userProfile.userId);
    print('Message button pressed for user: ${_userProfile.name}');
  }


  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // 선호도 박스 스타일 (MyPageScreen과 동일)
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
          // 1. 상단 AppBar (사용자 이름, 나이, 뒤로가기)
          SliverAppBar(
            pinned: true,
            elevation: 1,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              '${_userProfile.name}, ${_userProfile.age}', // 다른 사용자 정보 표시
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),

          // 2. 헤더 영역 (지도 배경, 프로필 사진, 상태 메시지, 액션 버튼)
          SliverToBoxAdapter(
            child: SizedBox(
              // 액션 버튼 포함 위해 높이 조절 필요 시 조정
              height: 350, // 예: 280(기존) + 70(버튼 영역)
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 지도 배경 (MyPageScreen과 동일)
                  Positioned.fill(
                    bottom: 70, // 액션 버튼 영역만큼 제외
                    child: Image.network(
                      'https://developers.google.com/static/maps/images/landing/hero_geocoding_api.png',
                      fit: BoxFit.cover,
                      color: Colors.black.withValues(alpha: 0.1),
                      colorBlendMode: BlendMode.darken,
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade300),
                    ),
                  ),
                  // 프로필 사진 (MyPageScreen과 동일, onTap 제거)
                  Positioned(
                    top: 70,
                    child: CircleAvatar( // InkWell 제거
                      radius: 65,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 62,
                        backgroundImage: NetworkImage(_userProfile.profileImageUrl),
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                  ),
                  // 상태 메시지 (MyPageScreen과 동일)
                  Positioned(
                    top: 185,
                    child: Text(
                      _userProfile.statusMessage,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // --- 새로운 액션 버튼 영역 ---
                  Positioned(
                    top: 235, // 상태 메시지 아래 위치 조정
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      // 배경색 추가 가능 (선택 사항)
                      // color: colorScheme.surface.withValues(alpha: 0.8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 버튼 간격 균등하게
                        children: [
                          _buildActionButton(
                            context,
                            icon: Icons.call,
                            label: 'Call',
                            onPressed: _handleCall,
                          ),
                          _buildActionButton(
                            context,
                            icon: Icons.chat_bubble_outline,
                            label: 'Message',
                            onPressed: _handleMessage,
                          ),
                          _buildActionButton(
                            context,
                            // 팔로우 상태에 따라 아이콘 변경
                            icon: _isFollowing ? Icons.person_remove_alt_1_outlined : Icons.person_add_alt_1_outlined,
                            label: _isFollowing ? 'Following' : 'Follow',
                            onPressed: _handleFollowToggle,
                            // 팔로우 처리 중일 때 로딩 표시 (선택 사항)
                            isLoading: _isProcessingFollow,
                            // 팔로우 상태일 때 다른 색상 (선택 사항)
                            // backgroundColor: _isFollowing ? colorScheme.primaryContainer : null,
                            // iconColor: _isFollowing ? colorScheme.primary : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. 정보 섹션 (Info, Language, Preferences) - MyPageScreen과 동일한 위젯 사용
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle(context, 'Info'),
                _buildInfoRow(context, Icons.location_on_outlined, _userProfile.location),
                _buildInfoRow(context, Icons.access_time, _userProfile.timeZoneInfo),
                const SizedBox(height: 20),

                _buildSectionTitle(context, 'Language'),
                ..._userProfile.languages.map((lang) => _buildLanguageRow(context, lang)),
                const SizedBox(height: 24),

                PreferenceDisplayBox(
                  title: 'I like', content: _userProfile.likes,
                  backgroundColor: prefBoxBgColor, titleColor: prefBoxTitleColor,
                  contentColor: prefBoxContentColor, borderColor: prefBoxBorderColor,
                ),
                const SizedBox(height: 12),
                PreferenceDisplayBox(
                  title: "I've been", content: _userProfile.placesBeen,
                  backgroundColor: prefBoxBgColor, titleColor: prefBoxTitleColor,
                  contentColor: prefBoxContentColor, borderColor: prefBoxBorderColor,
                ),
                const SizedBox(height: 12),
                PreferenceDisplayBox(
                  title: 'I want you to', content: _userProfile.wantsToDo,
                  backgroundColor: prefBoxBgColor, titleColor: prefBoxTitleColor,
                  contentColor: prefBoxContentColor, borderColor: prefBoxBorderColor,
                ),
                const SizedBox(height: 15),
              ]),
            ),
          ),

          // 4. Hosting 섹션 - MyPageScreen과 동일한 위젯 사용
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(child: _buildSectionTitle(context, 'Hosting')),
          ),
          _hostedPosts.isEmpty
              ? SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            sliver: SliverToBoxAdapter(
              child: Center(child: Text('No meet-ups hosted yet.', style: TextStyle(color: Colors.grey))),
            ),
          )
              : SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => MeetupPostItem(post: _hostedPosts[index]),
                childCount: _hostedPosts.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),

          // 5. Comments 섹션 수정
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Comments',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: colorScheme.onSurface.withOpacity(0.7)),
                        onPressed: () async { // async 추가
                          // 사용자 코멘트 작성 화면으로 이동하고 결과(작성된 텍스트)를 기다림
                          final newCommentText = await Navigator.pushNamed(
                            context,
                            '/write_user_comment',
                            arguments: _userId,
                          );

                          // 결과가 null이 아니고 비어있지 않으면 UI 업데이트
                          if (newCommentText != null && newCommentText is String && newCommentText.isNotEmpty) {
                            // --- 새 코멘트 객체 생성 (임시) ---
                            // TODO: 실제로는 현재 로그인한 사용자 정보로 채워야 함
                            final newComment = CommentModel(
                              commentId: 'temp_${DateTime.now().millisecondsSinceEpoch}', // 임시 ID
                              commenterId: 'current_user_id', // 현재 사용자 ID 필요
                              commenterName: 'Me', // 현재 사용자 이름 필요
                              commenterInfo: 'My Location, My Age', // 현재 사용자 정보 필요
                              commenterImageUrl: 'https://i.pravatar.cc/150?img=60', // 현재 사용자 이미지 URL 필요
                              commentText: newCommentText,
                              timestamp: DateTime.now(),
                            );
                            // --- 새 코멘트 객체 생성 끝 ---

                            // 상태 업데이트하여 목록에 추가 (맨 앞에 추가)
                            setState(() {
                              _comments.insert(0, newComment);
                            });
                          }
                        },
                        tooltip: 'Write a comment',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  Divider(height: 16, thickness: 1, color: colorScheme.surfaceVariant.withOpacity(0.5)),
                ],
              ),
            ),
          ),
          _comments.isEmpty
              ? SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            sliver: SliverToBoxAdapter(
              child: Center(child: Text('No comments yet.', style: TextStyle(color: Colors.grey))),
            ),
          )
              : SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return Column(
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
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  // --- Helper Widgets (MyPageScreen에서 가져오거나 유사하게 구현) ---

  // 액션 버튼 빌더 (새로 추가)
  Widget _buildActionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false, // 로딩 상태 추가
    Color? backgroundColor,
    Color? iconColor,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color defaultBackgroundColor = colorScheme.brightness == Brightness.light
        ? Colors.purple.shade50.withValues(alpha: 0.8)
        : Colors.purple.shade900.withValues(alpha: 0.6);
    final Color defaultIconColor = colorScheme.onSurface.withValues(alpha: 0.8);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: isLoading ? null : onPressed, // 로딩 중이면 탭 비활성화
          borderRadius: BorderRadius.circular(30), // 잉크 효과 범위
          child: CircleAvatar(
            radius: 30,
            backgroundColor: backgroundColor ?? defaultBackgroundColor,
            child: isLoading
                ? const SizedBox( // 로딩 인디케이터
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Icon(
              icon,
              color: iconColor ?? defaultIconColor,
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

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
          Expanded(
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
  Widget _buildLanguageRow(BuildContext context, UserLanguageInfo language) {
    String flagAssetPath = 'assets/flags/${language.languageCode}.jpg'; // 에셋 경로 확인 필요

    print("✈️ Language Row: $flagAssetPath");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Image.asset(
            flagAssetPath,
            width: 24, height: 18, fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(width: 24, height: 18, color: Colors.grey.shade300, child: Icon(Icons.flag, size: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              language.languageName,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          LanguageIndicator(proficiency: language.proficiency),
        ],
      ),
    );
  }
}