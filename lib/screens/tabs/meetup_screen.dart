// lib/screens/tabs/meetup_screen.dart
import 'package:flutter/material.dart';
import '../../models/meetup_post.dart';
import '../../widgets/meetup_post_item.dart';

class MeetupScreen extends StatefulWidget {
  const MeetupScreen({super.key});

  @override
  State<MeetupScreen> createState() => _MeetupScreenState();
}

class _MeetupScreenState extends State<MeetupScreen> {
  List<MeetupPost> _allPosts = []; // 모든 게시글 원본 저장
  List<MeetupPost> _displayedPosts = []; // 화면에 표시될 게시글 (필터링 결과)
  bool _isLoading = true;
  String? _searchQuery; // 검색어 저장 상태 변수

  @override
  void initState() {
    super.initState();
    _loadMeetupPosts(); // 초기 데이터 로드
  }

  // 모든 게시글 로드 (초기 또는 검색 취소 시)
  Future<void> _loadMeetupPosts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _searchQuery = null; // 검색어 초기화
    });
    await Future.delayed(const Duration(milliseconds: 500));
    _allPosts = getDummyMeetupPosts(); // 모든 더미 데이터 가져오기
    _displayedPosts = List.from(_allPosts); // 처음엔 모든 글 표시
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  // 검색어에 따라 게시글 필터링
  void _filterMeetupPosts() {
    if (!mounted) return;
    setState(() {
      _isLoading = true; // 필터링 중 로딩 표시 (선택 사항)
    });

    if (_searchQuery == null || _searchQuery!.isEmpty) {
      // 검색어가 없으면 모든 글 표시
      _displayedPosts = List.from(_allPosts);
    } else {
      // 검색어가 있으면 제목에 검색어가 포함된 글만 필터링 (대소문자 구분 없이)
      final query = _searchQuery!.toLowerCase();
      _displayedPosts = _allPosts
          .where((post) => post.title.toLowerCase().contains(query))
          .toList();
    }

    setState(() {
      _isLoading = false; // 로딩 완료
    });
  }

  // 검색 상태 초기화 및 전체 글 다시 로드
  void _clearSearch() {
    _loadMeetupPosts(); // 전체 글 다시 로드 (setState 포함됨)
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              // 당겨서 새로고침 시 검색 상태 초기화 및 전체 로드
              onRefresh: _loadMeetupPosts,
              child: CustomScrollView(
                slivers: [
                  // 1. 상단 헤더 영역 수정
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // --- 왼쪽: 제목 또는 검색 결과 ---
                          Expanded( // 오른쪽 아이콘 공간 확보 위해 Expanded 사용
                            child: (_searchQuery == null || _searchQuery!.isEmpty)
                                ? const Text( // 기본 제목
                              "Let's meet up!",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                                : Row( // 검색 결과 표시
                              children: [
                                Flexible( // 긴 검색어 처리
                                  child: Text(
                                    '"$_searchQuery"', // 검색어 표시
                                    style: const TextStyle(
                                      fontSize: 24, // 제목보다 약간 작게
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis, // 넘치면 ...
                                  ),
                                ),
                                IconButton( // 검색 취소 버튼
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: _clearSearch,
                                  tooltip: 'Clear search',
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.only(left: 4.0), // 텍스트와의 간격
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),

                          // --- 오른쪽: 아이콘 그룹 ---
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 검색 버튼
                              IconButton(
                                icon: Icon(Icons.search, color: colorScheme.onSurface, size: 28),
                                onPressed: () async { // async 추가
                                  // 검색 화면으로 이동하고 결과(검색어)를 기다림
                                  final result = await Navigator.pushNamed(context, '/search');
                                  // 결과가 null이 아니고 비어있지 않은 문자열이면
                                  if (result != null && result is String && result.isNotEmpty) {
                                    // 상태 업데이트 및 필터링 실행
                                    setState(() {
                                      _searchQuery = result;
                                    });
                                    _filterMeetupPosts(); // 필터링 함수 호출
                                  } else if (result == null) {
                                    // 사용자가 검색 없이 뒤로가기 한 경우 (아무것도 안 함)
                                    print('Search cancelled');
                                  }
                                },
                                tooltip: 'Search Meet-ups',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 15),
                              // 글쓰기 버튼
                              IconButton(
                                icon: Icon(Icons.edit_outlined, color: colorScheme.onSurface, size: 28),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/write_meetup'); // 기존 write 부분을 write_meetup으로 수정
                                },
                                tooltip: 'Write a Post',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 21),
                              // 프로필 아바타
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/mypage');
                                },
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.grey.shade300,
                                  backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=60'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. 게시글 목록 영역 (표시될 데이터 변경: _posts -> _displayedPosts)
                  _isLoading
                      ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                      : _displayedPosts.isEmpty // 필터링 결과가 없을 때
                      ? SliverFillRemaining(
                    child: Center(
                      child: Text(
                        _searchQuery == null
                            ? 'No meet-ups yet.' // 초기 상태 메시지
                            : 'No results found for "$_searchQuery"', // 검색 결과 없음 메시지
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                      : SliverPadding( // 필터링 결과 표시
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          // *** 중요: _displayedPosts 사용 ***
                          return MeetupPostItem(post: _displayedPosts[index]);
                        },
                        childCount: _displayedPosts.length,
                      ),
                    ),
                  ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}