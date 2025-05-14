// lib/screens/chat_room_screen.dart
import 'package:flutter/material.dart';
import 'package:naviya/firebase/firestoreManager.dart'; // Firestore 매니저 임포트
import '../../models/chat_message_model.dart';
import '../../models/chat_list_item_model.dart'; // ChatListItemModel 임포트
import '../../services/api_service.dart';
import '../../widgets/message_bubble.dart';
import 'dart:async'; // Timer 사용
// import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 사용 시 주석 해제

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessageModel> _messages = []; // 화면에 표시될 메시지 목록
  String _chatPartnerName = 'Loading...'; // 채팅 상대방 이름
  String? _chatId; // 현재 채팅방 ID
  // late ChatListItemModel chatListItemModel; // Firestore에서 채팅방 정보 로드 시 사용
  // late ChatMessageInfoDB messageInfoDB; // Firestore에서 메시지 정보 로드 시 사용 (주석 처리된 부분)
  bool _isLoading = true; // 초기 데이터 로딩 상태
  bool _isSending = false; // 메시지 전송 처리 중 상태

  // 현재 채팅방이 AI Tutor 채팅방인지 확인하는 getter
  bool get _isAiTutorChat => _chatId == 'chat_ai_tutor';

  // 추천 메시지 목록 (API 또는 고정값으로 로드)
  List<String> _recommendedMessages = [];

  late ChatListItemModel chatRoomInfo;
  List<UserState> userinfos = [];

  @override
  void initState() {
    super.initState();
    // 위젯 빌드 완료 후 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        _chatId = ModalRoute.of(context)?.settings.arguments as String;
        _loadChatDataAndRecommendations(_chatId!); // 데이터 및 추천 메시지 로드
      } else {
        // 채팅 ID가 없는 경우 에러 처리
        if (mounted) setState(() => _isLoading = false);
        print("오류: 채팅 ID가 제공되지 않았습니다.");
        // Navigator.pop(context); // 이전 화면으로 돌아가기 (선택 사항)
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 채팅 데이터 및 추천 메시지 로드 함수
  Future<void> _loadChatDataAndRecommendations(String chatId) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    // 1. 채팅 상대방 정보 로드 (Firestore 또는 더미)
    try {
      // ChatListItemModel dummy = getDummyChatListItems().firstWhere((item) => item.chatId == chatId, orElse: () => getDummyChatListItems()[0]); // 더미 데이터 사용
      // chatListItemModel = await getChat(chatId) ?? dummy; // Firestore에서 가져오기
      // _chatPartnerName = chatListItemModel.name;
      // --- 임시: 파트너 이름 설정 (실제 로직으로 대체 필요) ---
      if (chatId == 'chat_ai_tutor') _chatPartnerName = 'Hatchy';
      else if (chatId == 'chat_user_1') _chatPartnerName = 'Brian';
      else if (chatId == 'chat_user_2') _chatPartnerName = 'Alice';
      else _chatPartnerName = 'Unknown User';
      // --- 임시 끝 ---

    } catch (e) {
      print("채팅 상대방 정보 로드 오류: $e");
      _chatPartnerName = "Error";
    }

    // 채팅방 정보 가져오기
    ChatListItemModel dummyChatlistItem =  getDummyChatListItems()[0];
    chatRoomInfo = await getChat(_chatId ?? 'noneIds') ?? dummyChatlistItem;

    // 유저 정보 업데이트

    for(int i = 0 ; i < chatRoomInfo.memberIds!.length ; i++)
    {
      UserState? _userinfo = await getAnotherUserInfoByEmail(chatRoomInfo.memberIds![i]);

      if(_userinfo != null)
        {
          userinfos.add(_userinfo);
        }
    }



    // 채팅방 유저 정보 가져오기


    // 2. 메시지 목록 로드 (Firestore 또는 더미)
    // TODO: Firestore 연동 시 StreamBuilder 사용 또는 여기서 초기 메시지 로드
    // _messages = getDummyChatMessages(chatId); // 더미 메시지 사용
    // --- 임시: 더미 메시지 로드 ---
    _messages = _getDummyMessagesForChat(chatId);
    // --- 임시 끝 ---


    // 3. 추천 메시지 로드
    await _loadRecommendedMessages();

    if (mounted) {
      setState(() => _isLoading = false);
      // 메시지 로드 후 맨 아래로 스크롤
      Timer(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  // 임시 더미 메시지 생성 함수 (실제 로직으로 대체 필요)
  List<ChatMessageModel> _getDummyMessagesForChat(String chatId) {
    final now = DateTime.now();
    if (chatId == 'chat_ai_tutor') {
      return [
        ChatMessageModel(id: 'ai_intro', text: '안녕하세요! 무엇을 도와드릴까요, 해치?', timestamp: now.subtract(const Duration(minutes:1)), sender: MessageSender.other),
      ];
    } else {
      return [
        ChatMessageModel(id: 'user_greeting', text: '안녕하세요!', timestamp: now.subtract(const Duration(minutes:1)), sender: MessageSender.other),
      ];
    }
  }

  // 추천 메시지 로드 함수
  Future<void> _loadRecommendedMessages() async {
    if (!mounted) return;
    List<String> topics = [];
    try {
      if (_isAiTutorChat) {
        topics = [ /* ... AI Tutor 고정 추천 메시지 ... */
          'Study essential travel phrases', 'Study essential travel vocabulary',
          'Role-play ordering with Hatchy', 'Role-play meet up with Hatchy',
          'Free-talking with Hatchy',
        ];
      } else {
        topics = await ApiService.fetchTopics(5); // 다른 사용자와의 채팅 시 토픽 추천
      }
    } catch (e) {
      print("추천 메시지 로드 오류: $e");
      // 사용자에게 오류 알림 (선택 사항)
    }
    if (mounted) {
      setState(() {
        _recommendedMessages = topics;
      });
    }
  }

  // 메시지 전송 함수 (번역 기능 조건부 실행)
  Future<void> _sendMessage({String? predefinedText}) async {
    if (_isSending) return; // 중복 전송 방지

    final originalText = predefinedText ?? _textController.text.trim();
    if (originalText.isEmpty) return;

    if (mounted) setState(() => _isSending = true);

    final messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    final sentTime = DateTime.now();
    String? translatedText; // 번역된 텍스트를 저장할 변수

    // --- AI Tutor 채팅이 아닐 때만 번역 실행 ---
    if (!_isAiTutorChat) {
      try {
        translatedText = await ApiService.translate(originalText);
      } catch (e) {
        print("번역 API 오류: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('메시지 번역에 실패했습니다.')),
          );
        }
        // 번역 실패 시 원본 메시지만 전송 (또는 에러 처리 후 전송 안 함)
      }
    }
    // --- 번역 로직 끝 ---

    // 메시지 객체 생성
    final newMessage = ChatMessageModel(
      id: messageId,
      text: translatedText ?? originalText, // 번역본이 있으면 번역본, 없으면 원본을 주 텍스트로
      originalText: (_isAiTutorChat || translatedText == null) ? null : originalText, // AI 채팅이 아니면서 번역 성공 시에만 원본 저장
      timestamp: sentTime,
      sender: MessageSender.me,
      isRead: false,
      isTranslatedByAI: !_isAiTutorChat && translatedText != null, // AI 채팅 아니고 번역 성공 시 true
    );

    // Firestore에 메시지 저장 (실제 구현 필요)
    // await addMessageToChat(_chatId!, newMessage.toMap());

    if (mounted) {
      setState(() {
        _messages.insert(0, newMessage); // UI에 메시지 추가
        if (predefinedText == null) _textController.clear(); // 직접 입력한 경우 입력창 비우기
        _isSending = false; // 전송 완료
      });
      _scrollToBottom(); // 스크롤 맨 아래로
    }

    // AI Tutor 채팅방이면 AI 응답 시뮬레이션
    if (_isAiTutorChat) {
      _simulateAiResponse(originalText); // AI는 원본 메시지에 대해 응답
    }
  }

  // AI 응답 시뮬레이션 함수 (번역 로직 없음)
  Future<void> _simulateAiResponse(String userMessage) async {
    await Future.delayed(const Duration(seconds: 1)); // 응답 지연 시뮬레이션
    // TODO: 실제 Gemini API 호출하여 응답 받기
    final aiResponseText = "AI Hatchy: \"$userMessage\"라고 하셨군요! 더 도와드릴 것이 있나요?";
    final aiResponseMessage = ChatMessageModel(
      id: 'ai_resp_${DateTime.now().millisecondsSinceEpoch}',
      text: aiResponseText,
      timestamp: DateTime.now(),
      sender: MessageSender.other, // 또는 MessageSender.ai (enum에 추가 필요)
    );

    // Firestore에 AI 응답 저장 (선택 사항)
    // await addMessageToChat(_chatId!, aiResponseMessage.toMap());

    if (mounted) {
      setState(() {
        _messages.insert(0, aiResponseMessage);
      });
      _scrollToBottom();
    }
  }

  // 스크롤 맨 아래로 이동
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // --- UI 빌드 함수들 ---
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: _buildAppBar(colorScheme),
      body: Column(
        children: [
          _buildMessageList(), // 메시지 목록
          // 추천 메시지 블록 (AI Tutor 또는 다른 유저 채팅 시 조건부 표시)
          if (_isAiTutorChat || (!_isAiTutorChat && _recommendedMessages.isNotEmpty))
            _buildRecommendedMessages(context, colorScheme),
          _buildInputArea(colorScheme), // 메시지 입력 영역
        ],
      ),
    );
  }

  // AppBar 빌드 함수
  AppBar _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        _chatPartnerName,
        style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey.shade300,
            child: CircleAvatar(
              radius: 5,
              backgroundColor: Colors.greenAccent.shade400, // 온라인 상태 표시 (임시)
            ),
          ),
        ),
      ],
      backgroundColor: colorScheme.surface,
      elevation: 1,
      centerTitle: false,
    );
  }

  // 메시지 목록 빌드 함수
  Widget _buildMessageList() {
    return Expanded(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _messages.isEmpty
          ? Center(
        child: Text('대화를 시작해보세요!', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
      )
          : GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            final message = _messages[index];
            // 마지막 메시지이고 AI Tutor 채팅방일 때만 AI 로봇 이미지 표시 (선택 사항)
            // bool isLastMessage = index == 0; // reverse: true이므로 첫 번째 아이템이 마지막 메시지
            // bool showAiRobot = isLastMessage && _isAiTutorChat;
            return Column(
              children: [
                MessageBubble(message: message),
                // if (showAiRobot) _buildAiRobotWidget(),
              ],
            );
          },
        ),
      ),
    );
  }

  // AI 로봇 위젯 (필요시 구현)
  // Widget _buildAiRobotWidget() { ... }

  // 메시지 입력 영역 빌드 함수
  Widget _buildInputArea(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [BoxShadow(offset: const Offset(0, -1), blurRadius: 4, color: Colors.black.withOpacity(0.05))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(icon: Icon(Icons.add_circle, color: Colors.green.shade600, size: 30), onPressed: () {/* 첨부 기능 */}),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                decoration: BoxDecoration(color: colorScheme.surfaceVariant.withOpacity(0.6), borderRadius: BorderRadius.circular(20.0)),
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(hintText: 'Enter a message...', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 10.0)),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 5,
                  onSubmitted: (_) => _sendMessage(),
                  enabled: !_isSending,
                ),
              ),
            ),
            const SizedBox(width: 4),
            _isSending
                ? const Padding(padding: EdgeInsets.all(12.0), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)))
                : IconButton(icon: Icon(Icons.arrow_upward, color: colorScheme.primary, size: 28), onPressed: _sendMessage),
          ],
        ),
      ),
    );
  }

  // 추천 메시지 블록 빌드 함수
  Widget _buildRecommendedMessages(BuildContext context, ColorScheme colorScheme) {
    final Color chipBackgroundColor = colorScheme.brightness == Brightness.light ? Colors.deepPurple.shade100 : Colors.deepPurple.shade800;
    final Color chipTextColor = colorScheme.brightness == Brightness.light ? Colors.deepPurple.shade900 : Colors.deepPurple.shade50;
    final String sectionTitle = _isAiTutorChat ? 'Recommended Topics' : 'Recommended Topics By Gemini';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        border: Border(top: BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Text(sectionTitle, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.8), fontWeight: FontWeight.w500)),
          ),
          SizedBox(
            height: 30, // 높이 조절
            child: _recommendedMessages.isEmpty
                ? const Center(child: Text('Loading recommened messages...', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: _recommendedMessages.length,
              itemBuilder: (context, index) {
                final message = _recommendedMessages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ActionChip(
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1.0), // 텍스트 수직 패딩 조절
                      child: Text(message, textAlign: TextAlign.center, style: TextStyle(color: chipTextColor, fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                    backgroundColor: chipBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0), side: BorderSide.none),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    onPressed: () {
                      _sendMessage(predefinedText: message); // 추천 메시지 클릭 시 전송
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}