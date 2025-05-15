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
  // --- AI 대화 컨텍스트(history) 저장을 위한 상태 변수 ---
  List<String> _aiChatHistory = [];
  // 현재 AI 대화 모드 (롤플레잉, 자유대화 등) - 선택 사항
  String? _currentAiMode; // 예: 'roleplay_ordering', 'roleplay_meetup', 'free_talk'

  // AI Tutor 고정 추천 메시지 (구분자 추가하여 모드 식별 용이하게)
  final Map<String, String> _aiTutorFixedRecommendations = {
    'Free-talking with Hatchy': 'free_talk',
    'Study essential travel phrases': 'study_phrases',
    'Study essential travel vocabulary': 'study_vocabulary',
    'Role-play ordering with Hatchy': 'roleplay_ordering',
    'Role-play meet up with Hatchy': 'roleplay_meetup',
    // 'Tell me about popular spots in [City Name]': 'info_spots',
    // 'How do I get to [Place] from [Place]?': 'info_directions',
    // 'What\'s the weather like in [City Name]?': 'info_weather',
    // 'Translate this for me: [Your Text]': 'tool_translate', // 번역은 메시지 전송 시 자동
  };


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
        ChatMessageModel(id: 'ai_intro', text: 'Hi! I am Hatchy. Choose any topic you want!', timestamp: now.subtract(const Duration(minutes:1)), sender: MessageSender.other),
      ];
    } else {
      return [
        ChatMessageModel(id: 'user_greeting', text: 'Hello!', timestamp: now.subtract(const Duration(minutes:1)), sender: MessageSender.other),
      ];
    }
  }

  Future<void> _loadRecommendedMessages() async {
    if (!mounted) return;
    List<String> topics = [];
    try {
      if (_isAiTutorChat) {
        topics = _aiTutorFixedRecommendations.keys.toList(); // Map의 key들을 리스트로 사용
      } else {
        topics = await ApiService.fetchTopics(5);
      }
    } catch (e) {
      print("추천 메시지 로드 오류: $e");
    }
    if (mounted) {
      setState(() { _recommendedMessages = topics; });
    }
  }

  // 메시지 전송 함수
  Future<void> _sendMessage({String? predefinedText, String? aiMode}) async {
    if (_isSending && predefinedText == null) return; // 직접 입력 시에만 중복 전송 방지

    final originalText = predefinedText ?? _textController.text.trim();
    if (originalText.isEmpty) return;

    if (mounted) setState(() => _isSending = true);

    final messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    final sentTime = DateTime.now();
    String? translatedText;

    // AI Tutor 채팅이 아닐 때만 번역 실행
    if (!_isAiTutorChat) {
      try {
        translatedText = await ApiService.translate(originalText);
      } catch (e) {
        print("번역 API 오류: $e");
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('메시지 번역에 실패했습니다.')));
      }
    }

    final newMessage = ChatMessageModel(
      id: messageId,
      text: translatedText ?? originalText,
      originalText: (!_isAiTutorChat && translatedText != null) ? originalText : null,
      timestamp: sentTime,
      sender: MessageSender.me,
      isRead: false,
      isTranslatedByAI: !_isAiTutorChat && translatedText != null,
    );

    if (mounted) {
      setState(() {
        _messages.insert(0, newMessage);
        if (predefinedText == null) _textController.clear(); // 직접 입력 시에만 클리어
        _isSending = false; // UI 업데이트 후 전송 상태 해제
      });
      _scrollToBottom();
    }

    // --- AI Tutor 응답 처리 수정 ---
    if (_isAiTutorChat) {
      // 사용자가 추천 토픽을 클릭하여 aiMode가 전달된 경우, 또는 이미 모드가 설정된 경우
      if (aiMode != null || _currentAiMode != null) {
        String currentModeToUse = aiMode ?? _currentAiMode!; // 전달된 모드 우선 사용

        if (aiMode != null) { // 추천 토픽 클릭 시
          _currentAiMode = aiMode; // 현재 모드 업데이트
          _aiChatHistory.clear();   // 새 모드 시작 시 히스토리 초기화
          // 만약 "Study..." 항목이면 바로 임시 응답 후 종료
          if (!currentModeToUse.startsWith('roleplay') && currentModeToUse != 'free_talk') {
            _simulateStudyResponse(originalText, currentModeToUse); // 스터디 항목은 다른 처리
            if (mounted) setState(() => _isSending = false);
            return;
          }
        }
        // else: 사용자가 직접 입력했고, 이전에 모드가 설정된 상태

        _aiChatHistory.add("user: $originalText");
        Map<String, dynamic> aiApiResponse;

        try {
          if (currentModeToUse.startsWith('roleplay')) {
            aiApiResponse = await ApiService.roleplay(text: originalText, history: _aiChatHistory);
          } else { // free_talk
            aiApiResponse = await ApiService.freeTalk(text: originalText, history: _aiChatHistory);
          }

          final aiResponseText = aiApiResponse['message'] as String;
          final List<String> updatedHistory = List<String>.from(aiApiResponse['history'] as List);
          _aiChatHistory = updatedHistory;

          final aiResponseMessage = ChatMessageModel(
            id: 'ai_resp_${DateTime.now().millisecondsSinceEpoch}',
            text: aiResponseText,
            timestamp: DateTime.now(),
            sender: MessageSender.other,
          );

          if (mounted) setState(() { _messages.insert(0, aiResponseMessage); });
          _scrollToBottom();

        } catch (e) {
          print("AI API 오류 ($currentModeToUse): $e");
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('AI 응답을 가져오는데 실패했습니다: ${e.toString()}')));
          if (_aiChatHistory.isNotEmpty && _aiChatHistory.last == "user: $originalText") {
            _aiChatHistory.removeLast();
          }
        }
      } else {
        // --- 사용자가 직접 입력했고, 아직 AI 모드가 선택되지 않은 경우 ---
        final aiResponseMessage = ChatMessageModel(
          id: 'ai_prompt_${DateTime.now().millisecondsSinceEpoch}',
          text: 'To start the conversation, choose one of the recommended topics below! If you want to have a free conversation, choose Free-talking with Hatchy!', // 안내 메시지 수정
          timestamp: DateTime.now(),
          sender: MessageSender.other,
        );
        if (mounted) setState(() { _messages.insert(0, aiResponseMessage); });
        _scrollToBottom();
      }
    }
    // --- AI Tutor 응답 처리 수정 끝 ---

    if (mounted) setState(() => _isSending = false); // 모든 처리 후 전송 상태 해제
  }

  // 스터디 관련 추천 메시지 클릭 시 임시 응답
  void _simulateStudyResponse(String topicClicked, String studyMode) {
    // studyMode에 따라 다른 응답 생성 가능
    final aiResponseText = "AI Hatchy: \"$topicClicked\" 학습을 시작합니다! (이 기능은 현재 데모 버전입니다.)";
    final aiResponseMessage = ChatMessageModel(
      id: 'ai_study_${DateTime.now().millisecondsSinceEpoch}',
      text: aiResponseText,
      timestamp: DateTime.now(),
      sender: MessageSender.other,
    );
    if (mounted) {
      setState(() { _messages.insert(0, aiResponseMessage); });
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
        child: Text('Start a conversation!', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
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
      decoration: BoxDecoration( color: colorScheme.surfaceVariant.withOpacity(0.5), border: Border(top: BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Text(sectionTitle, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.8), fontWeight: FontWeight.w500)),
          ),
          SizedBox(
            height: 30,
            child: _recommendedMessages.isEmpty
                ? const Center(child: Text('추천 내용을 불러오는 중...', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              itemCount: _recommendedMessages.length,
              itemBuilder: (context, index) {
                final messageText = _recommendedMessages[index];
                // AI Tutor 채팅방일 경우, Map에서 모드 식별자 가져오기
                final String? aiMode = _isAiTutorChat ? _aiTutorFixedRecommendations[messageText] : null;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ActionChip(
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                      child: Text(messageText, textAlign: TextAlign.center, style: TextStyle(color: chipTextColor, fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                    backgroundColor: chipBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0), side: BorderSide.none),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    onPressed: () {
                      // 추천 메시지 클릭 시 전송 (AI 모드 정보 전달)
                      _sendMessage(predefinedText: messageText, aiMode: aiMode);
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