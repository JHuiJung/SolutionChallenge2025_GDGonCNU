// lib/screens/chat_room_screen.dart
import 'package:flutter/material.dart';
import 'package:naviya/firebase/firestoreManager.dart';
import '../../models/chat_message_model.dart';
import '../../models/chat_list_item_model.dart';
import '../../services/api_service.dart';
import '../../widgets/message_bubble.dart';
import 'dart:async'; // Timer 사용
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // 스크롤 제어
  List<ChatMessageModel> _messages = [];
  String _chatPartnerName = 'Loading...'; // 채팅 상대방 이름
  String? _chatId; // 채팅방 ID

  late ChatListItemModel chatListItemModel;
  late ChatMessageInfoDB messageInfoDB;
  bool _isLoading = true;
  bool _isSending = false; // 메시지 전송 및 번역 중 상태
  bool get _isAiTutorChat => _chatId == 'chat_ai_tutor'; // AI Tutor 채팅방인지 확인하는 getter

  // --- 다른 유저와 대화 추천 메시지 목록 ---
  List<String> _recommendedMessages = []; // 초기에는 비어있음

  // --- AI Tutor 추천 메시지 목록 ---
  final List<String> _aiRecommendedMessages = [
    'Study essential travel phrases',
    'Study essential travel vocabulary',
    'Role-play ordering with Hatchy', // 'Hatchy'는 AI 이름으로 가정
    'Role-play meet up with Hatchy',
    'Free-talking with Hatchy',
    // 'Tell me about popular spots in [City Name]', // 예시: 사용자가 도시 이름 입력 가능
    // 'How do I get to [Place] from [Place]?',
    // 'What\'s the weather like in [City Name]?',
    // 'Translate this for me: [Your Text]',
  ];
  // --- AI Tutor 추천 메시지 목록 끝 ---

  // --- 추천 메시지 로드 함수 ---
  Future<void> _loadRecommendedMessages() async {
    if (!mounted) return;
    List<String> topics = [];
    try {
      if (_isAiTutorChat) {
        // AI Tutor 채팅방의 고정 추천 메시지 (기존 방식)
        topics = [
          'Study essential travel phrases',
          'Study essential travel vocabulary',
          'Role-play ordering with Hatchy',
          'Role-play meet up with Hatchy',
          'Free-talking with Hatchy',
          'Tell me about popular spots in [City Name]',
          'How do I get to [Place] from [Place]?',
          'What\'s the weather like in [City Name]?',
          'Translate this for me: [Your Text]',
        ];
      } else {
        // 다른 사용자 채팅방: API에서 토픽 추천 (5개)
        topics = await ApiService.fetchTopics(5);
      }
    } catch (e) {
      print("Error fetching recommended messages: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load recommended topics.')),
        );
      }
    }
    if (mounted) {
      setState(() {
        _recommendedMessages = topics;
      });
    }
  }
  // --- 추천 메시지 로드 함수 끝 ---

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        _chatId = ModalRoute.of(context)?.settings.arguments as String;
        _loadChatData(_chatId!);
        _loadRecommendedMessages(); // 추천 메시지 로드
      } else {
        if (mounted) setState(() => _isLoading = false);
        print("Error: Chat ID not provided.");
      }
    });


  }


  // 데이터 로딩 함수
  Future<void> _loadChatData(String chatId) async {
    setState(() => _isLoading = true);
    // Simulate loading chat partner name and messages
    await Future.delayed(const Duration(milliseconds: 300));


    //
    ChatMessageInfoDB dummyDB = ChatMessageInfoDB(
      chatId: 'none',
      messages: [],
    );

    /*messageInfoDB = await getChatMessageInfo(chatId) ?? dummyDB;

    if(messageInfoDB.chatId == 'none')
      {
        ChatMessageInfoDB newDB = ChatMessageInfoDB(
          chatId: chatId,
          messages: [],
        );
        await addChatMessageInfo(newDB);
        messageInfoDB = newDB;
      }*/


    ChatListItemModel dummy = getDummyChatListItems()[0];
    chatListItemModel = await getChat(_chatId ?? 'noneChatId') ?? dummy;

    // TODO: 실제로는 chatId를 기반으로 상대방 정보와 메시지 목록을 가져와야 함
    // 예시: 더미 데이터 사용
    //_chatPartnerName = _getChatPartnerName(chatId); // chatId 기반 이름 가져오기 (임시)
    _chatPartnerName = chatListItemModel.name; // chatId 기반 이름 가져오기 (임시)
    _messages = getDummyChatMessages(chatId);

    setState(() => _isLoading = false);

    // 메시지 로드 후 맨 아래로 스크롤 (잠시 딜레이 후 실행해야 정확함)
    Timer(const Duration(milliseconds: 100), _scrollToBottom);
  }

  // 임시 함수: chatId로 상대방 이름 반환
  String _getChatPartnerName(String chatId) {
    if (chatId == 'chat_ai_tutor') return 'AI Tutor';
    if (chatId == 'chat_user_1') return 'Brian';
    if (chatId == 'chat_user_2') return 'Alice';
    if (chatId == 'chat_group_1') return 'Tokyo Trip Planning';
    return 'Unknown Chat';
  }


  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 메시지 전송 함수
/*
  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      final newMessage = ChatMessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        timestamp: DateTime.now(),
        sender: MessageSender.me,
        isRead: false,
      );

    final originalText = predefinedText ?? _textController.text.trim();
    if (originalText.isEmpty) return;

    if (mounted) {
      setState(() => _isSending = true); // 전송 시작
    }

    final messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    final sentTime = DateTime.now();

    // 1. 원본 메시지를 UI에 먼저 추가
    final originalMessage = ChatMessageModel(
      id: messageId,
      text: originalText,
      timestamp: sentTime,
      sender: MessageSender.me,
      isRead: false,
    );

    if (mounted) {
      setState(() {
        _messages.insert(0, originalMessage);
        if (predefinedText == null) _textController.clear();
      });
      _scrollToBottom();
    }

    // --- 번역 로직 수정: AI Tutor 채팅이 아닐 때만 번역 ---
    if (!_isAiTutorChat) { // AI Tutor 채팅이 아니면 번역 실행
      String? translatedText;
      try {
        translatedText = await ApiService.translate(originalText);
      } catch (e) {
        print("Translation API error: $e");
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to translate message.')));
      }

      if (translatedText != null && mounted) {
        final messageIndex = _messages.indexWhere((msg) => msg.id == messageId);
        if (messageIndex != -1) {
          final updatedMessage = ChatMessageModel(
            id: _messages[messageIndex].id, text: translatedText, originalText: originalText,
            timestamp: _messages[messageIndex].timestamp, sender: _messages[messageIndex].sender,
            isRead: _messages[messageIndex].isRead, isTranslatedByAI: true,
          );
          setState(() { _messages[messageIndex] = updatedMessage; });
        }
      }
    }
    // --- 번역 로직 수정 끝 ---

    if (mounted) setState(() => _isSending = false);

    // AI Tutor에게 보내면 응답 시뮬레이션
    if (_isAiTutorChat) {
      _simulateAiResponse(originalText); // AI 응답은 번역하지 않음
    }
  }
*/

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      final newMessage = ChatMessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}', // 임시 고유 ID
        text: text,
        timestamp: DateTime.now(),
        sender: MessageSender.me,
        isRead: false, // 처음엔 안 읽음 상태
      );

      /*setState(() {
        // 새 메시지를 리스트 맨 앞에 추가 (ListView가 reverse 상태이므로)
        _messages.insert(0, newMessage);
      });*/

      _textController.clear(); // 입력 필드 비우기
      _scrollToBottom(); // 메시지 보낸 후 맨 아래로 스크롤

      /*// TODO: 실제로는 서버로 메시지 전송 로직 필요
      // TODO: AI 번역 기능이 필요하면 여기서 처리 또는 서버에서 처리
      // 예시: AI 튜터에게 보내면 잠시 후 답장 오는 시뮬레이션
      if (_chatId == 'chat_ai_tutor') {
        _simulateAiResponse(text);
      }*/

      addMessage(_chatId ??'noneChatId', newMessage);
    }
  }


  // AI 응답 시뮬레이션 (번역 로직 제거)
  Future<void> _simulateAiResponse(String userMessage) async {
    await Future.delayed(const Duration(seconds: 1));
    final aiOriginalResponse = "Okay, I understood: \"$userMessage\". How can I assist you further?";
    final aiResponseId = 'ai_resp_${DateTime.now().millisecondsSinceEpoch}';
    final aiResponseTime = DateTime.now();

    final aiResponseMessage = ChatMessageModel(
      id: aiResponseId,
      text: aiOriginalResponse,
      timestamp: aiResponseTime,
      sender: MessageSender.other, // 또는 MessageSender.ai
      // AI 응답은 isTranslatedByAI = false, originalText = null
    );
    if (mounted) {
      setState(() {
        _messages.insert(0, aiResponseMessage);
      });
      _scrollToBottom();
    }
  }


  // 스크롤을 맨 아래로 이동시키는 함수
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0, // reverse: true 이므로 0이 맨 아래
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Stream<List<ChatMessageModel>> getMessagesRealtime(String chatId) {
    return FirebaseFirestore.instance
        .collection('chatMessages')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp') // 시간 순으로 정렬
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessageModel.fromMap(doc.data()))
          .toList();
    });
  }


  @override
  /*Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isAiTutorChat = _chatId == 'chat_ai_tutor';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _chatPartnerName, // 로드된 상대방 이름 표시
          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        actions: [
          // 온라인 상태 표시기 (디자인 참고 - 녹색 점)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 12, // 크기 조절
              backgroundColor: Colors.grey.shade300, // 기본 배경
              child: CircleAvatar(
                radius: 5, // 내부 점 크기
                backgroundColor: Colors.greenAccent.shade400, // 온라인 상태 색상 (임시)
              ),
            ),
          ),
        ],
        backgroundColor: colorScheme.surface, // AppBar 배경색
        elevation: 1, // 약간의 그림자
        centerTitle: false, // 제목 왼쪽 정렬
      ),
      body: Column(
        children: [
          // 메시지 목록 영역
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? Center( // 메시지 없을 때 표시
              child: Text(
                'Start chatting!',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            )
                : GestureDetector( // 키보드 숨기기 위해 추가
              onTap: () => FocusScope.of(context).unfocus(),
              child: ListView.builder(
                controller: _scrollController,
                reverse: true, // 메시지가 아래부터 쌓이도록
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  // AI 로봇 이미지 삽입 (스크롤 가능하게 리스트 아이템으로)
                  // 마지막 메시지(index == _messages.length - 1) 이고 AI 채팅방일때
                  bool isLastMessage = index == _messages.length - 1;
                  bool showRobot = isLastMessage && _chatId == 'chat_ai_tutor';

                  return Column(
                    children: [
                      MessageBubble(message: _messages[index]),
                      // if (showRobot) _buildAiRobotWidget(), // 로봇 위젯 추가
                    ],
                  );
                },
              ),
            ),
          ),
          // --- AI Tutor 추천 메시지 블록 (조건부 표시) ---
          // AI Tutor 채팅방이거나, 다른 유저 채팅방이면서 추천 메시지가 있을 때 표시
          if (_isAiTutorChat || (!_isAiTutorChat && _recommendedMessages.isNotEmpty))
            _buildRecommendedMessages(context, colorScheme),
          // 입력 영역
          _buildInputArea(context, colorScheme),
        ],
      ),
    );
  }
*/
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _chatPartnerName, // 로드된 상대방 이름 표시
          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        actions: [
          // 온라인 상태 표시기 (디자인 참고 - 녹색 점)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 12, // 크기 조절
              backgroundColor: Colors.grey.shade300, // 기본 배경
              child: CircleAvatar(
                radius: 5, // 내부 점 크기
                backgroundColor: Colors.greenAccent.shade400, // 온라인 상태 색상 (임시)
              ),
            ),
          ),
        ],
        backgroundColor: colorScheme.surface, // AppBar 배경색
        elevation: 1, // 약간의 그림자
        centerTitle: false, // 제목 왼쪽 정렬
      ),
      body: Column(
        children: [
          // 메시지 목록 영역
          Expanded(
            child: StreamBuilder<List<ChatMessageModel>>(
              stream: getMessagesRealtime(_chatId ?? ''), // 실시간 메시지 스트림
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center( // 메시지 없을 때 표시
                    child: Text(
                      'Start chatting!',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    ),
                  );
                }

                final messages = snapshot.data!;

                return GestureDetector( // 키보드 숨기기 위해 추가
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true, // 메시지가 아래부터 쌓이도록
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      bool isLastMessage = index == messages.length - 1;
                      bool showRobot = isLastMessage && _chatId == 'chat_ai_tutor';

                      return Column(
                        children: [
                          MessageBubble(message: messages[index]),
                          if (showRobot) _buildAiRobotWidget(), // 로봇 위젯 추가
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
          // 입력 영역
          _buildInputArea(context),
        ],
      ),
    );
  }


  // AI 로봇 위젯 빌더
  // Widget _buildAiRobotWidget() {
  //   // TODO: 실제 이미지 에셋 경로 사용
  //   String robotImagePath = 'assets/images/robot_thinking_chat.png'; // 채팅방용 로봇 이미지
  //
  //   return Padding(
  //     padding: const EdgeInsets.only(right: 16.0, bottom: 10.0, top: 20.0),
  //     child: Align(
  //       alignment: Alignment.bottomRight,
  //       child: Image.asset(
  //         robotImagePath,
  //         height: 100, // 크기 조절
  //         errorBuilder: (context, error, stackTrace) => const SizedBox(height: 100), // 에러 시 빈 공간
  //       ),
  //     ),
  //   );
  // }


  // 입력 영역 위젯 빌더 (전송 버튼에 _sendMessageAndTranslate 연결)
  Widget _buildInputArea(BuildContext context, ColorScheme colorScheme) { // colorScheme 파라미터 추가
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [BoxShadow(offset: const Offset(0, -1), blurRadius: 4, color: Colors.black.withOpacity(0.05))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(icon: Icon(Icons.add_circle, color: Colors.green.shade600, size: 30), onPressed: () { print('Attachment button pressed'); }),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                decoration: BoxDecoration(color: colorScheme.surfaceVariant.withOpacity(0.6), borderRadius: BorderRadius.circular(20.0)),
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(hintText: 'Placeholder', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 10.0)),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1, maxLines: 5,
                  onSubmitted: (_) => _sendMessageAndTranslate(), // 엔터키로 전송
                  enabled: !_isSending, // 전송 중 비활성화
                ),
              ),
            ),
            const SizedBox(width: 4),
            // 전송 버튼 (상태에 따라 로딩 인디케이터 표시)
            _isSending
                ? const Padding(
              padding: EdgeInsets.all(12.0), // IconButton과 유사한 크기
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
            )
                : IconButton(
              icon: Icon(Icons.arrow_upward, color: colorScheme.primary, size: 28),
              onPressed: _sendMessageAndTranslate, // 직접 입력한 메시지 전송
            ),
          ],
        ),
      ),
    );
  }

  // 추천 메시지 블록 빌더
  Widget _buildRecommendedMessages(BuildContext context, ColorScheme colorScheme) {
    final Color chipBackgroundColor = colorScheme.brightness == Brightness.light
        ? Colors.deepPurple.shade100
        : Colors.deepPurple.shade800;
    final Color chipTextColor = colorScheme.brightness == Brightness.light
        ? Colors.deepPurple.shade900
        : Colors.deepPurple.shade50;

    final String sectionTitle = _isAiTutorChat ? 'Tools recommended by AI' : 'Recommended Topics';

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
            child: Text(
              sectionTitle, // 동적 제목
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            height: 30,
            child: _recommendedMessages.isEmpty // 추천 메시지가 없을 때 로딩 또는 빈 메시지 표시
                ? Center(child: Text('Loading topics...', style: TextStyle(color: Colors.grey)))
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
                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                      child: Text(message, textAlign: TextAlign.center, style: TextStyle(color: chipTextColor, fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                    backgroundColor: chipBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0), side: BorderSide.none),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    onPressed: () {
                      // AI Tutor 채팅이 아닐 때는 번역 없이 바로 메시지 전송
                      _sendMessageAndTranslate(predefinedText: message);
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