// lib/screens/chat_room_screen.dart
import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../widgets/message_bubble.dart';
import 'dart:async'; // Timer 사용

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

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 위젯이 빌드된 후 argument를 안전하게 읽어오기 위해 addPostFrameCallback 사용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        _chatId = ModalRoute.of(context)?.settings.arguments as String;
        _loadChatData(_chatId!);
      } else {
        // chatId가 없는 경우 처리 (예: 에러 표시 또는 뒤로가기)
        setState(() => _isLoading = false);
        print("Error: Chat ID not provided.");
        // Navigator.pop(context); // 또는 에러 메시지 표시
      }
    });
  }

  // 데이터 로딩 함수
  Future<void> _loadChatData(String chatId) async {
    setState(() => _isLoading = true);
    // Simulate loading chat partner name and messages
    await Future.delayed(const Duration(milliseconds: 300));

    // TODO: 실제로는 chatId를 기반으로 상대방 정보와 메시지 목록을 가져와야 함
    // 예시: 더미 데이터 사용
    _chatPartnerName = _getChatPartnerName(chatId); // chatId 기반 이름 가져오기 (임시)
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

      setState(() {
        // 새 메시지를 리스트 맨 앞에 추가 (ListView가 reverse 상태이므로)
        _messages.insert(0, newMessage);
      });

      _textController.clear(); // 입력 필드 비우기
      _scrollToBottom(); // 메시지 보낸 후 맨 아래로 스크롤

      // TODO: 실제로는 서버로 메시지 전송 로직 필요
      // TODO: AI 번역 기능이 필요하면 여기서 처리 또는 서버에서 처리
      // 예시: AI 튜터에게 보내면 잠시 후 답장 오는 시뮬레이션
      if (_chatId == 'chat_ai_tutor') {
        _simulateAiResponse(text);
      }
    }
  }

  // AI 응답 시뮬레이션 (예시)
  void _simulateAiResponse(String userMessage) {
    Timer(const Duration(seconds: 1), () {
      final aiResponse = ChatMessageModel(
        id: 'ai_resp_${DateTime.now().millisecondsSinceEpoch}',
        text: "Okay, I received your message: \"$userMessage\". How can I help you further?",
        timestamp: DateTime.now(),
        sender: MessageSender.other, // AI 튜터는 other로 간주
      );
      final aiResponseKo = ChatMessageModel( // 번역된 메시지 예시
        id: 'ai_resp_ko_${DateTime.now().millisecondsSinceEpoch}',
        text: "네, \"$userMessage\" 메시지를 받았습니다. 무엇을 더 도와드릴까요?",
        originalText: "Okay, I received your message: \"$userMessage\". How can I help you further?",
        timestamp: DateTime.now(),
        sender: MessageSender.other,
        isTranslatedByAI: true,
      );
      setState(() {
        _messages.insert(0, aiResponseKo); // 번역본 먼저 추가
        _messages.insert(0, aiResponse);   // 원본 추가
      });
      _scrollToBottom();
    });
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
                      if (showRobot) _buildAiRobotWidget(), // 로봇 위젯 추가
                    ],
                  );
                },
              ),
            ),
          ),
          // 입력 영역
          _buildInputArea(context),
        ],
      ),
    );
  }

  // AI 로봇 위젯 빌더
  Widget _buildAiRobotWidget() {
    // TODO: 실제 이미지 에셋 경로 사용
    String robotImagePath = 'assets/images/robot_thinking_chat.png'; // 채팅방용 로봇 이미지

    return Padding(
      padding: const EdgeInsets.only(right: 16.0, bottom: 10.0, top: 20.0),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Image.asset(
          robotImagePath,
          height: 100, // 크기 조절
          errorBuilder: (context, error, stackTrace) => const SizedBox(height: 100), // 에러 시 빈 공간
        ),
      ),
    );
  }


  // 하단 입력 영역 위젯 빌더
  Widget _buildInputArea(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.surface, // 배경색
        boxShadow: [ // 상단에 약간의 그림자
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: SafeArea( // 하단 시스템 영역 침범 방지
        child: Row(
          children: [
            // 첨부 버튼 (+)
            IconButton(
              icon: Icon(Icons.add_circle, color: Colors.green.shade600, size: 30),
              onPressed: () {
                // TODO: 첨부 파일 선택 기능 구현
                print('Attachment button pressed');
              },
            ),
            // 텍스트 입력 필드
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.6), // 입력 필드 배경색
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none, // 테두리 없음
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0), // 내부 수직 패딩 조절
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 5, // 여러 줄 입력 가능
                  onSubmitted: (_) => _sendMessage(), // 엔터키로 전송 (선택 사항)
                ),
              ),
            ),
            const SizedBox(width: 4),
            // 전송 버튼
            IconButton(
              icon: Icon(Icons.arrow_upward, color: colorScheme.primary, size: 28),
              onPressed: _sendMessage, // 메시지 전송 함수 호출
            ),
          ],
        ),
      ),
    );
  }
}