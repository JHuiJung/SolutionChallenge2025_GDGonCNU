// lib/screens/tabs/meetup_screen.dart
import 'package:flutter/material.dart';
import '../../models/meetup_post.dart'; // 데이터 모델 임포트
import '../../widgets/meetup_post_item.dart'; // 게시글 아이템 위젯 임포트

class MeetupScreen extends StatefulWidget {
  const MeetupScreen({super.key});

  @override
  State<MeetupScreen> createState() => _MeetupScreenState();
}

class _MeetupScreenState extends State<MeetupScreen> {
  // 실제 앱에서는 API 호출 등을 통해 데이터를 가져옵니다.
  late List<MeetupPost> _posts;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMeetupPosts();
  }

  // 데이터를 비동기적으로 로드하는 함수 (예시)
  Future<void> _loadMeetupPosts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _posts = getDummyMeetupPosts(); // 더미 데이터 사용
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold( // MeetupScreen 자체 Scaffold 사용 (AppBar가 없으므로)
      body: SafeArea( // 상태바 영역 침범 방지
        child: Stack( // FAB를 내용 위에 띄우기 위해 Stack 사용
          children: [
            // 스크롤 가능한 컨텐츠 영역
            RefreshIndicator( // 당겨서 새로고침 기능 추가
              onRefresh: _loadMeetupPosts,
              child: CustomScrollView( // 헤더와 리스트를 함께 스크롤하기 위해 사용
                slivers: [
                  // 1. 상단 헤더 영역 (Let's meet up!, MyPage 아이콘)
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Let's meet up!",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              // MyPage 화면으로 이동
                              Navigator.pushNamed(context, '/mypage');
                              print('Navigate to MyPage');
                            },
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.grey.shade300,
                              // TODO: 실제 사용자 프로필 이미지로 교체
                              backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=60'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. 게시글 목록 영역
                  _isLoading
                      ? const SliverFillRemaining( // 로딩 중 인디케이터 표시
                    child: Center(child: CircularProgressIndicator()),
                  )
                      : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          return MeetupPostItem(post: _posts[index]);
                        },
                        childCount: _posts.length,
                      ),
                    ),
                  ),
                  // 하단 여백 추가 (FAB에 가려지지 않도록)
                  const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                ],
              ),
            ),

            // 3. Floating Action Button (+)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center( // FAB를 중앙 하단에 위치시키기 위해 Center 사용
                child: FloatingActionButton(
                  onPressed: () {
                    // 게시글 작성 화면으로 이동
                    Navigator.pushNamed(context, '/create_post');
                    print('Navigate to create post screen');
                  },
                  shape: RoundedRectangleBorder( // 디자인에 맞게 사각형 모양으로
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: colorScheme.brightness == Brightness.light
                      ? Colors.grey.shade300 // 밝은 모드 FAB 배경
                      : Colors.grey.shade700, // 어두운 모드 FAB 배경
                  foregroundColor: colorScheme.onSurface, // 아이콘 색상
                  child: const Icon(Icons.add, size: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}