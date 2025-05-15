// lib/screens/post_detail_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/meetup_post.dart'; // MeetupPost 모델 임포트 (경로 확인)
import '../widgets/overlapping_avatars.dart'; // 참여자 아바타 위젯 임포트 (경로 확인)
import 'dart:async'; // Timer 사용 위해 추가
import 'dart:ui'; // ImageFilter 사용 위해 추가 (하단 버튼 블러 효과용)
import '../firebase/firestoreManager.dart';
import '../models/comment_model.dart';
import '../widgets/comment_item.dart';
import '../services/api_service.dart'; // *** ApiService 임포트 ***

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool _isLoading = true;
  late MeetupPost _postDetail;
  String? _postId;
  bool _isJoined = false; // 참여 상태를 저장할 변수 추가
  bool _isProcessing = false; // 버튼 클릭 처리 중인지 확인하는 플래그
  List<CommentModel> _comments = [];
  // --- AI 코멘트 상태 변수 추가 ---
  String? _aiComment;
  bool _isLoadingAiComment = false; // AI 코멘트 로딩 상태

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        _postId = ModalRoute.of(context)?.settings.arguments as String;
        print("🚑 (포스트 디테일) 포스트 아이디 : $_postId");
        _loadPostDetailsAndAiComment(_postId!); // AI 코멘트 로딩 함수 호출
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        print("Error: Post ID not provided.");
        // Navigator.pop(context);
      }
    });
  }

  // 게시글 상세 정보 및 AI 코멘트 로드
  Future<void> _loadPostDetailsAndAiComment(String postIdFromRoute) async { // 파라미터 이름 변경
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _isLoadingAiComment = true;
    });

    // 게시글 상세 정보 로드
    await Future.delayed(const Duration(milliseconds: 300));
    // postIdFromRoute를 사용하여 _postDetail 로드
    //_postDetail = getDummyPostDetail(postIdFromRoute);
    MeetupPost _dummy = getDummyPostDetail(postIdFromRoute);
    _postDetail = await getMeetUpPostById(_postId!)??_dummy;
    _comments = getDummyComments();

    // AI 코멘트 로드
    try {
      // --- 1. 현재 로그인한 사용자 ID 가져오기 ---
      final User? currentUser = FirebaseAuth.instance.currentUser;
      String? currentUserIdForApi;

      if (currentUser != null) {
        currentUserIdForApi = currentUser.uid;
      } else {
        // 사용자가 로그인되어 있지 않은 경우 처리
        print("Error: User not logged in. Cannot fetch AI comment.");
        if (mounted) {
          setState(() {
            _aiComment = "Please log in to see AI comments.";
            _isLoadingAiComment = false;
            _isLoading = false; // 전체 로딩도 완료 처리
          });
        }
        return; // 함수 종료
      }

      // --- 2. eventId는 전달받은 postIdFromRoute 사용 ---
      final String eventIdForApi = postIdFromRoute;

      // --- API 호출 전 ID 값 확인 (디버깅용) ---
      if (currentUserIdForApi.isEmpty || eventIdForApi.isEmpty) {
        print("Error: Invalid IDs for AI comment. UserID: '$currentUserIdForApi', EventID: '$eventIdForApi'");
        if(mounted) {
          setState(() {
            _aiComment = "Error: Could not fetch AI comment due to invalid IDs.";
            _isLoadingAiComment = false;
            _isLoading = false;
          });
        }
        return;
      }
      print('Fetching AI comment for eventId: $eventIdForApi, userId: $currentUserIdForApi');


      final fetchedAiComment = await ApiService.fetchComment(
        eventId: eventIdForApi,
        userId: currentUserIdForApi,
      );

      if (mounted) {
        setState(() {
          _aiComment = fetchedAiComment;
        });
      }
    } catch (e) {
      print("Error fetching AI comment: $e");
      if (mounted) {
        setState(() {
          _aiComment = "Failed to load AI comment: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAiComment = false;
          // _isLoading은 게시글 상세 정보 로딩과 AI 코멘트 로딩이 모두 끝나야 false로 설정
          // 여기서는 AI 코멘트 로딩만 완료되었으므로, _isLoading은 그대로 두거나
          // 게시글 상세 로딩과 AI 코멘트 로딩을 분리하여 관리해야 함.
          // 현재 구조에서는 _loadPostDetailsAndAiComment 시작 시 _isLoading = true,
          // finally에서 _isLoading = false로 설정하는 것이 적절해 보임.
          if (!_isLoadingAiComment && !_isLoading) { // 만약 다른 비동기 작업도 있다면 그 완료 시점도 고려
            // 이미 게시글 로드가 끝났다고 가정하면 여기서 false
          }
          _isLoading = false; // AI 코멘트 로딩이 마지막 작업이라고 가정하고 전체 로딩 완료
        });
      }
    }
  }

  // 참여 버튼 클릭 처리 함수
  Future<void> _handleJoin() async {
    if (_isProcessing || _isJoined) return; // 처리 중이거나 이미 참여했으면 중복 실행 방지

    if (mounted) {
      setState(() => _isProcessing = true); // 처리 시작
    }

    // TODO: 실제 서버에 참여 요청 보내는 로직 추가
    await Future.delayed(const Duration(milliseconds: 500)); // 서버 요청 시뮬레이션

    // 메인 유저의 챗 정보에 해당 chatId 있는지 확인

    List<String> userChats = mainUserInfo.chatIds;
    bool isChatOn = false;


    for (String chatId in userChats) {
      if (chatId == _postDetail.meetupChatid) {
        isChatOn = true;
        break;
      }
    }

    if(!isChatOn)
    {
      mainUserInfo.chatIds.add(_postDetail.meetupChatid);
      updateUser();
    }

    // 없으면 추가 후 정보 업데이트

    if (mounted) {
      // 성공적으로 처리되었다고 가정
      _showSuccessDialog(); // 성공 팝업 표시
      setState(() {
        _isJoined = true; // 참여 상태로 변경
        // _isProcessing = false; // 팝업 닫힐 때 false로 변경
      });
    }
  }

  // 취소 버튼 클릭 처리 함수
  Future<void> _handleCancel() async {
    if (_isProcessing || !_isJoined) return; // 처리 중이거나 참여 상태가 아니면 중복 실행 방지

    if (mounted) {
      setState(() => _isProcessing = true); // 처리 시작
    }

    // TODO: 실제 서버에 참여 취소 요청 보내는 로직 추가
    await Future.delayed(const Duration(milliseconds: 300)); // 서버 요청 시뮬레이션

    if (mounted) {
      // 성공적으로 처리되었다고 가정
      setState(() {
        _isJoined = false; // 참여 취소 상태로 변경
        _isProcessing = false; // 처리 완료
      });
      print('Event participation cancelled.');
    }
  }


  // 성공 팝업 표시 함수
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 배경 탭으로 닫기 비활성화
      barrierColor: Colors.black.withValues(alpha: 0.7), // 배경 약간 어둡게
      builder: (BuildContext context) {
        // 1초 후에 자동으로 팝업 닫기
        Timer(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pop(); // 팝업 닫기
            setState(() => _isProcessing = false); // 팝업 닫히면 처리 완료
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent, // 기본 배경 투명하게
          elevation: 0, // 그림자 제거
          child: Column(
            mainAxisSize: MainAxisSize.min, // 내용 크기만큼만 차지
            children: [
              Image.asset(
                'assets/images/egg.png', // 추가한 이미지 경로
                height: 200, // 이미지 크기 조절
              ),
              const SizedBox(height: 24),
              const Text(
                'Successfully Joined!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent, // 디자인 참고 색상
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color surfaceVariantWithOpacity = colorScheme.surfaceVariant.withOpacity(0.7);
    final Color onSurfaceWithOpacity = colorScheme.onSurface.withOpacity(0.7);
    final Color surfaceWithOpacity = colorScheme.surface.withOpacity(0.9);
    final Color blackWithOpacityLow = Colors.black.withOpacity(0.1);
    final Color blackWithOpacityMid = Colors.black.withOpacity(0.3);
    final Color primaryWithOpacity = colorScheme.primary.withOpacity(0.5);
    final Color grey600WithOpacity = Colors.grey.shade600.withOpacity(0.5);
    // --- AI 코멘트 박스 배경색 (디자인 참고) ---
    final Color aiCommentBoxColor = colorScheme.brightness == Brightness.light
        ? Colors.grey.shade200.withOpacity(0.7) // 밝은 모드
        : Colors.grey.shade800.withOpacity(0.7); // 어두운 모드

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          CustomScrollView(
            slivers: <Widget>[
              _buildSliverAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 카테고리, 제목, 인원 등 기존 내용...
                    _buildCategoryChips(context, colorScheme),
                    const SizedBox(height: 12), // 카테고리와 제목 사이 간격
                    Text(
                      _postDetail.title,
                      style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6), // 제목과 인원 사이 간격
                    Text(
                      '${_postDetail.totalPeople} people · ${_postDetail.spotsLeft} left',
                      style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 12), // 인원과 유저 프로필 사이 간격
                    _buildAuthorSection(context, textTheme),
                    // 구분짓는 가로 선
                    const SizedBox(height: 6), // 유저와 정보 사이 간격
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(thickness: 1.5, height: 1.5),
                    ),
                    const SizedBox(height: 3),
                    _buildInfoRow(context, Icons.location_on_outlined, _postDetail.eventLocation),
                    const SizedBox(height: 8), // 위치와 시간 사이 간격
                    _buildInfoRow(context, Icons.access_time_outlined, _postDetail.eventDateTimeString),
                    const SizedBox(height: 3),
                    // 구분짓는 가로 선
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(thickness: 1.5, height: 1.5),
                    ),
                    // 하단 버튼 공간 확보 (버튼 높이 + 패딩 고려)
                    const SizedBox(height: 10),
                    Text(
                      _postDetail.description,
                      style: textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),

                    // --- "Comments by AI" 섹션 추가 ---
                    _buildAiCommentSection(context, textTheme, aiCommentBoxColor),
                    const SizedBox(height: 40), // 사용자 코멘트 섹션 전 여백
                    // --- "Comments by AI" 섹션 끝 ---

                    const SizedBox(height: 90),
                  ]),
                ),
              ),
            ],
          ),
          // 하단 고정 버튼 (상태에 따라 다른 버튼 표시)
          _buildBottomButton(context, colorScheme, textTheme),
        ],
      ),
    );
  }

  // --- 기존 빌더 함수들 (_buildSliverAppBar, _buildCategoryChips, _buildAuthorSection, _buildInfoRow) ---
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280.0,
      stretch: true,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 1,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Image.network(
          _postDetail.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : Container(color: Colors.grey.shade300),
          errorBuilder: (context, error, stack) => Container(
            color: Colors.grey.shade400,
            child: const Icon(Icons.broken_image, color: Colors.white54, size: 50), // 나중에 사진 불러올 곳
            // child: Image.asset(
            //               'assets/images/spring.jpg', // 추가한 이미지 경로
            //             )
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, ColorScheme colorScheme) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _postDetail.categories.map((category) => Chip(
        label: Text(category),
        labelStyle: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        backgroundColor: colorScheme.surfaceVariant.withValues(alpha: 0.7),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        side: BorderSide.none,
      )).toList(),
    );
  }

  Widget _buildAuthorSection(BuildContext context, TextTheme textTheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/user_profile', arguments: _postDetail.authorId);
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(_postDetail.authorImageUrl),
                backgroundColor: Colors.grey.shade300,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _postDetail.authorName,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _postDetail.authorLocation,
                    style: textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        if (_postDetail.participantImageUrls.isNotEmpty)
          OverlappingAvatars(
            imageUrls: _postDetail.participantImageUrls,
            avatarRadius: 18,
          ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
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
    );
  }

  // 하단 버튼 빌더 (상태에 따라 Join 또는 Cancel 버튼 반환)
  Widget _buildBottomButton(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 5,
            )
          ],
        ),
        child: SafeArea(
          top: false,
          child: _isJoined
              ? _buildCancelButton(context, colorScheme, textTheme) // 참여 상태면 Cancel 버튼
              : _buildJoinButton(context, colorScheme, textTheme), // 아니면 Join 버튼
        ),
      ),
    );
  }

  // Join 버튼 위젯
  Widget _buildJoinButton(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return ElevatedButton(
        onPressed: _isProcessing ? null : _handleJoin, // 처리 중이면 비활성화
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          // 처리 중일 때 비활성화 스타일 (선택 사항)
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.5),
        ),
        child: _isProcessing
            ? const SizedBox( // 로딩 인디케이터 표시
          height: 15,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : const Text('Join this event', style: TextStyle(fontSize: 18.0))
    );
  }

  // Cancel 버튼 위젯
  Widget _buildCancelButton(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return ElevatedButton(
      onPressed: _isProcessing ? null : _handleCancel, // 처리 중이면 비활성화
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        backgroundColor: Colors.grey.shade600, // 회색 배경 (디자인 참고)
        foregroundColor: Colors.white, // 흰색 텍스트
        textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // 약간 덜 둥글게 (디자인 참고)
        ),
        disabledBackgroundColor: Colors.grey.shade600.withValues(alpha: 0.5),
      ),
      child: _isProcessing
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      )
          : const Text('Cancel', style: TextStyle(fontSize: 18.0)),
    );
  }


  // --- "Comments by AI" 섹션 빌더 ---
  Widget _buildAiCommentSection(BuildContext context, TextTheme textTheme, Color boxBackgroundColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20), // 본문과 ai comment 부분 사이 간격
        Text(
          ' Comments by Gemini',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5), // 'Comments by AI과 내용 부분 사이 간격
        Container(
          width: double.infinity, // 가로 꽉 채우기
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: boxBackgroundColor, // 디자인 참고 배경색
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: _isLoadingAiComment
              ? const Center( // 로딩 중 표시
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          )
              : Text(
            _aiComment ?? 'No AI comment available.', // AI 코멘트 또는 기본 메시지
            style: textTheme.bodyLarge?.copyWith(
              height: 1.5, // 줄 간격
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), // 약간 흐린 텍스트
            ),
          ),
        ),
      ],
    );
  }
// --- "Comments by AI" 섹션 빌더 끝 ---
}