// lib/screens/tabs/chat_screen.dart
import 'package:flutter/material.dart';
import '../../models/chat_list_item_model.dart'; // 채팅 모델 임포트
import '../../widgets/chat_list_item.dart'; // 채팅 아이템 위젯 임포트
import '../../firebase/firestoreManager.dart'; // Firestore 매니저 임포트

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatListItemModel> _chatList = []; // 화면에 표시될 전체 채팅 목록
  bool _isLoading = true; // 데이터 로딩 상태
  // late UserState userinfo; // 현재 사용자 정보 (mainUserInfo를 직접 사용하거나, 필요시 상태로 관리)

  @override
  void initState() {
    super.initState();
    _loadAndProcessChatList(); // 채팅 목록 로드 및 처리 함수 호출
  }

  // 채팅 목록 로드 및 AI Tutor 고정 처리 함수
  Future<void> _loadAndProcessChatList() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    // UserState userinfo = mainUserInfo; // 전역 변수 사용 (또는 Provider 등으로 주입)
    List<ChatListItemModel> fetchedUserChats = [];

    // 1. 현재 사용자의 채팅 ID 목록을 기반으로 각 채팅방 정보 가져오기
    //    (mainUserInfo.chatIds가 Firestore에서 가져온 채팅방 ID 리스트라고 가정)
    if (mainUserInfo.chatIds.isNotEmpty) {
      for (String chatId in mainUserInfo.chatIds) {
        // 'chat_ai_tutor'는 별도로 처리하므로 여기서는 스킵
        if (chatId == 'chat_ai_tutor') continue;

        ChatListItemModel? chatItem = await getChat(
            chatId); // Firestore에서 채팅방 정보 가져오기
        if (chatItem != null) {
          fetchedUserChats.add(chatItem);
        }
      }
    }

    // 2. 사용자 채팅 목록을 시간 순으로 정렬 (최신 메시지가 위로)
    fetchedUserChats.sort((a, b) {
      // TimeOfDay를 비교 가능한 형태로 변환 (오늘 날짜 기준)
      final now = DateTime.now();
      final aDateTime = DateTime(
          now.year, now.month, now.day, a.timestamp.hour, a.timestamp.minute);
      final bDateTime = DateTime(
          now.year, now.month, now.day, b.timestamp.hour, b.timestamp.minute);
      return bDateTime.compareTo(aDateTime); // 내림차순 정렬
    });

    // 3. AI Tutor 채팅방 정보 생성 또는 로드
    //    (AI Tutor는 항상 존재한다고 가정하고, 필요시 Firestore에서 로드)
    ChatListItemModel aiTutorChat = ChatListItemModel(
      chatId: 'chat_ai_tutor',
      userId: 'ai_tutor_bot',
      // AI 튜터의 고유 ID
      name: 'Hatchy',
      imageUrl: 'assets/images/egg.png',
      // AI Tutor 프로필 이미지 경로
      lastMessage: 'Hi! How can I help you?',
      // 초기 메시지 또는 마지막 메시지
      timestamp: TimeOfDay.now(),
      // 항상 최신으로 보이도록 (또는 실제 마지막 대화 시간)
      isRead: true, // 기본값
    );
    // 만약 AI Tutor 채팅방 정보도 Firestore에서 관리한다면 여기서 getChat('chat_ai_tutor') 호출

    // 4. 최종 채팅 목록 구성: AI Tutor를 맨 앞에 추가
    List<ChatListItemModel> finalChatList = [aiTutorChat, ...fetchedUserChats];

    if (mounted) {
      setState(() {
        _chatList = finalChatList;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme
        .of(context)
        .colorScheme;
    // UserState userinfo = mainUserInfo; // 빌드 메서드 내에서 필요시 다시 참조

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator( // 당겨서 새로고침 기능 추가
              onRefresh: _loadAndProcessChatList,
              child: CustomScrollView(
                slivers: [
                  // 1. 상단 헤더 (Chat 타이틀, MyPage 아이콘)
                  _buildHeader(context, colorScheme, mainUserInfo),
                  // mainUserInfo 전달

                  // 2. 채팅 목록
                  _buildChatList(colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI 빌더 함수들 ---

  // 상단 헤더 빌드 함수
  Widget _buildHeader(BuildContext context, ColorScheme colorScheme,
      UserState currentUserInfo) {
    return SliverPadding(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Chat",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () => Navigator.pushNamed(context, '/mypage'),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade300,
                // 현재 사용자 프로필 이미지 표시
                backgroundImage: (currentUserInfo.profileURL.isNotEmpty)
                    ? NetworkImage(currentUserInfo.profileURL)
                    : const AssetImage(
                    'assets/images/user_profile.jpg') as ImageProvider, // 기본 이미지 에셋
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 채팅 목록 빌드 함수
  Widget _buildChatList(ColorScheme colorScheme) {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_chatList.isEmpty) {
      // AI Tutor도 없으면 이 메시지 표시 (실제로는 AI Tutor는 항상 있으므로 이 경우는 드묾)
      return const SliverFillRemaining(
        child: Center(
          child: Text('No chats yet!',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return Column(
            children: [
              ChatListItem(chat: _chatList[index]),
              if (index < _chatList.length - 1) // 마지막 아이템 제외하고 구분선 추가
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 88, // 프로필 사진 너비 + 여백
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                ),
            ],
          );
        },
        childCount: _chatList.length,
      ),
    );
  }
}