// lib/screens/chat_room_screen.dart
import 'package:flutter/material.dart';
// import 'package:naviya/firebase/firestoreManager.dart'; // Firestore 매니저 임포트 (주석 유지)
import '../../models/chat_message_model.dart';
// import '../../models/chat_list_item_model.dart'; // ChatListItemModel 임포트 (주석 유지)
import '../../services/api_service.dart';
import '../../widgets/message_bubble.dart';
import '../../firebase/firestoreManager.dart';
import '../../models/chat_list_item_model.dart';
import 'dart:async'; // Timer 사용

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
  bool _isLoading = true; // 초기 데이터 로딩 상태
  bool _isSending = false; // 메시지 전송 처리 중 상태

  // 현재 채팅방이 AI Tutor 채팅방인지 확인하는 getter
  bool get _isAiTutorChat => _chatId == 'chat_ai_tutor';

  // 추천 메시지 목록 (API 또는 고정값으로 로드)
  List<String> _recommendedMessages = [];
  // AI 대화 컨텍스트(history) 저장을 위한 상태 변수
  List<String> _aiChatHistory = [];
  // 현재 AI 대화 모드 (롤플레잉, 자유대화 등)
  String? _currentAiMode; // 예: 'roleplay_ordering', 'free_talk'
  String _currentLanguage = 'English'; // 현재 대화 언어 (기본값 영어)

  // AI Tutor 고정 추천 메시지 (모드 식별자)
  final Map<String, String> _aiTutorFixedRecommendations = {
    'Free-talking with Hatchy': 'free_talk',
    'Study essential travel phrases': 'study_scenario_phrases',
    'Role-play ordering with Hatchy': 'roleplay_ordering',
    'Cultural do’s and don’ts': 'culture_info',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is String) {
        _chatId = arguments;
        _loadChatDataAndRecommendations(_chatId!);
      } else {
        if (mounted) setState(() => _isLoading = false);
        print("오류: 채팅 ID가 제공되지 않았거나 형식이 올바르지 않습니다.");
        // Optionally, navigate back or show an error message
        // if (Navigator.canPop(context)) Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatDataAndRecommendations(String chatId) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // 1. 채팅 상대방 정보 로드 (임시 로직)
      // TODO: Firestore 또는 실제 데이터 소스에서 채팅 상대방 정보 로드
      if (chatId == 'chat_ai_tutor') {
        _chatPartnerName = 'Hatchy';
      } else {
        ChatListItemModel? userChatListItem = await getChat(_chatId!);
        _chatPartnerName = userChatListItem!.name;
      }

      // 2. 메시지 목록 로드 (임시 로직)
      // TODO: Firestore 또는 실제 데이터 소스에서 메시지 목록 로드
      _messages = _getDummyMessagesForChat(chatId);

      // 3. 추천 메시지 로드
      await _loadRecommendedMessages();

    } catch (e) {
      print("채팅 데이터 로드 중 오류 발생: $e");
      if (mounted) {
        _chatPartnerName = "Error Loading";
        // Consider showing an error message to the user
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        Timer(const Duration(milliseconds: 100), _scrollToBottom);
      }
    }
  }

  List<ChatMessageModel> _getDummyMessagesForChat(String chatId) {
    final now = DateTime.now();
    if (chatId == 'chat_ai_tutor') {
      return [
        ChatMessageModel(
            id: 'ai_intro',
            text: 'Hi! I am Hatchy. Choose any topic you want!',
            timestamp: now.subtract(const Duration(minutes: 1)),
            sender: MessageSender.other),
      ];
    }
    return [
      ChatMessageModel(
          id: 'user_greeting',
          text: '안녕! 만나서 반가워!',
          timestamp: now.subtract(const Duration(minutes: 1)),
          sender: MessageSender.other),


    ];
  }

  Future<void> _loadRecommendedMessages() async {
    if (!mounted) return;
    List<String> topics = [];
    try {
      if (_isAiTutorChat) {
        topics = _aiTutorFixedRecommendations.keys.toList();
      } else {
        topics = await ApiService.fetchTopics(5); // 일반 채팅용 추천 토픽
      }
    } catch (e) {
      print("추천 메시지 로드 오류: $e");
      // Optionally, set topics to an empty list or default error messages
    }
    if (mounted) {
      setState(() {
        _recommendedMessages = topics;
      });
    }
  }

  void _addDummyMessage() {
    final now = DateTime.now();
    ChatMessageModel newMessage = ChatMessageModel(
        id: 'user_greeting',
        text: '안녕! 만나서 반가워!',
        timestamp: now.subtract(const Duration(minutes: 1)),
        sender: MessageSender.other);
    _messages.insert(0,newMessage);

  }

  Future<void> _sendMessage({String? predefinedText, String? aiMode}) async {
    // 빠른 연속 전송 방지 (사용자 직접 입력 시에만)
    if (_isSending && predefinedText == null) return;

    final String originalText = predefinedText ?? _textController.text.trim();
    if (originalText.isEmpty) return;

    if (mounted) setState(() => _isSending = true);

    // AI Tutor 특정 기능 우선 처리 (문화 정보, 여행 회화)
    if (_isAiTutorChat) {
      if (aiMode == 'culture_info') {
        final userPromptMessage = ChatMessageModel(
            id: 'msg_prompt_culture_${DateTime.now().millisecondsSinceEpoch}',
            text: originalText, // Topic text, e.g., "Cultural do's and don'ts"
            timestamp: DateTime.now(),
            sender: MessageSender.me);
        if (mounted) setState(() => _messages.insert(0, userPromptMessage));
        _scrollToBottom();
        await _handleCulturalInfoRequest(originalText); // This function now handles _isSending
        // No need to set _isSending = false here, as _handleCulturalInfoRequest does it.
        return; // Important: Return early
      } else if (aiMode == 'study_scenario_phrases') {
        final userPromptMessage = ChatMessageModel(
            id: 'msg_prompt_phrases_${DateTime.now().millisecondsSinceEpoch}',
            text: originalText, // Topic text, e.g., "Study essential travel phrases"
            timestamp: DateTime.now(),
            sender: MessageSender.me);
        if (mounted) setState(() => _messages.insert(0, userPromptMessage));
        if (mounted) setState(() => _addDummyMessage());
        _scrollToBottom();
        await _handleScenarioPhrasesRequest(); // This function now handles _isSending


        return; // Important: Return early
      }
    }

    final messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    final sentTime = DateTime.now();
    String? translatedText;

    // AI Tutor 채팅이 아닐 때만 번역 실행
    if (!_isAiTutorChat) {
      try {
        translatedText = await ApiService.translate(originalText);
      } catch (e) {
        print("번역 API 오류: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('메시지 번역에 실패했습니다.')));
        }
      }
    }

    final newMessage = ChatMessageModel(
      id: messageId,
      text: translatedText ?? originalText,
      originalText: (!_isAiTutorChat && translatedText != null) ? originalText : null,
      timestamp: sentTime,
      sender: MessageSender.me,
      isRead: false, // TODO: 읽음 처리 로직 필요
      isTranslatedByAI: !_isAiTutorChat && translatedText != null,
    );

    if (mounted) {
      setState(() {
        _messages.insert(0, newMessage);
        if (predefinedText == null) _textController.clear();
      });
      _scrollToBottom();
    }

    // AI Tutor 일반 응답 처리 (롤플레잉, 자유대화)
    if (_isAiTutorChat) {
      String? modeForApiCall;

      if (aiMode != null) {
        // 'culture_info'와 'study_scenario_phrases'는 이미 위에서 처리 후 return 되었음.
        // 따라서 여기서 aiMode는 'roleplay_...' 또는 'free_talk' 등으로 예상됨.
        _currentAiMode = aiMode;
        _aiChatHistory.clear(); // 새 토픽/모드 시작 시 히스토리 초기화
        modeForApiCall = _currentAiMode;
      } else if (_currentAiMode != null) {
        // 사용자가 직접 입력했고, 이미 AI 모드가 활성화된 상태 (예: 롤플레잉 중)
        modeForApiCall = _currentAiMode;
      }

      if (modeForApiCall != null) {
        _aiChatHistory.add("user: $originalText");
        Map<String, dynamic> aiApiResponse;

        try {
          if (modeForApiCall.startsWith('roleplay')) {
            print('Calling roleplay API with text: $originalText, history: $_aiChatHistory, language: $_currentLanguage, mode: $modeForApiCall');
            aiApiResponse = await ApiService.roleplay(
              text: originalText,
              history: _aiChatHistory,
              language: _currentLanguage,
            );
          } else if (modeForApiCall == 'free_talk') {
            print('Calling freeTalk API with text: $originalText, history: $_aiChatHistory, language: $_currentLanguage');
            aiApiResponse = await ApiService.freeTalk(
              text: originalText,
              history: _aiChatHistory,
              language: _currentLanguage,
            );
          } else {
            // 예상치 못한 모드 또는 API 호출이 필요 없는 모드.
            // (예: 새로운 추천 토픽이 추가되었지만, 해당 모드에 대한 API 호출 로직이 없는 경우)
            print('Error: AI Tutor - Unhandled API mode: $modeForApiCall. Message not sent to AI.');
            if (_aiChatHistory.isNotEmpty && _aiChatHistory.last == "user: $originalText") {
              _aiChatHistory.removeLast(); // 히스토리 추가 롤백
            }
            // 여기서 사용자에게 오류 메시지를 표시할 수 있음
            // final errorMessage = ChatMessageModel(id: 'ai_err_unhandled_mode', text: "Sorry, I encountered an issue with the selected topic.", timestamp: DateTime.now(), sender: MessageSender.other);
            // if (mounted) setState(() { _messages.insert(0, errorMessage); });
            // _scrollToBottom();
            if (mounted) setState(() => _isSending = false);
            return;
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
          if (mounted) setState(() => _messages.insert(0, aiResponseMessage));
          _scrollToBottom();

        } catch (e) {
          print("AI API 오류 ($modeForApiCall): $e");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('AI 응답을 가져오는데 실패했습니다: ${e.toString()}')));
          }
          if (_aiChatHistory.isNotEmpty && _aiChatHistory.last == "user: $originalText") {
            _aiChatHistory.removeLast(); // 실패 시 히스토리 추가 롤백
          }
        }
      } else {
        // 사용자가 직접 입력했고, 아직 AI 모드가 선택되지 않은 경우.
        // 또는 처리되지 않은 추천 토픽 클릭 시 (이 경우는 위 `else` 블록에서 처리되도록 유도)
        final aiPromptMessage = ChatMessageModel(
            id: 'ai_prompt_${DateTime.now().millisecondsSinceEpoch}',
            text: 'AI Hatchy: To start the conversation, choose one of the recommended topics below! If you want to have a free conversation, choose Free-talking with Hatchy!',
            timestamp: DateTime.now(),
            sender: MessageSender.other);
        if (mounted) setState(() => _messages.insert(0, aiPromptMessage));
        _scrollToBottom();
      }
    }
    // 모든 메시지 처리(AI 응답 포함) 완료 후 _isSending 해제
    if (mounted) setState(() => _isSending = false);
  }

  Future<void> _handleCulturalInfoRequest(String topicText) async {
    // _sendMessage에서 _isSending = true로 설정했으므로, 여기서는 API 호출 상태만 관리
    if (!mounted) return;
    // setState(() => _isSending = true); // 이미 _sendMessage에서 설정됨

    String? homeCountry;
    String? destCountry;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final homeController = TextEditingController();
        final destController = TextEditingController();
        return AlertDialog(
          title: const Text('Enter Country Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: homeController, decoration: const InputDecoration(labelText: 'Your Home Country (e.g., Korea)')),
              TextField(controller: destController, decoration: const InputDecoration(labelText: 'Destination Country (e.g., Japan)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                homeCountry = homeController.text.trim();
                destCountry = destController.text.trim();
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (homeCountry != null && homeCountry!.isNotEmpty && destCountry != null && destCountry!.isNotEmpty) {
      final thinkingMessage = ChatMessageModel(
        id: 'ai_thinking_culture_${DateTime.now().millisecondsSinceEpoch}',
        text: "AI Hatchy: Comparing cultural differences between $homeCountry and $destCountry...",
        timestamp: DateTime.now(),
        sender: MessageSender.other,
      );
      if (mounted) setState(() { _messages.insert(0, thinkingMessage); });
      _scrollToBottom();

      try {
        final culturalInfo = await ApiService.fetchCulturalDifferences(
          homeCountry: homeCountry!,
          destinationCountry: destCountry!,
        );
        final aiResponseMessage = ChatMessageModel(
          id: 'ai_culture_resp_${DateTime.now().millisecondsSinceEpoch}',
          text: "AI Hatchy: Here are some cultural notes for traveling from $homeCountry to $destCountry:\n\n$culturalInfo",
          timestamp: DateTime.now(),
          sender: MessageSender.other,
        );
        if (mounted) setState(() { _messages.insert(0, aiResponseMessage); });
      } catch (e) {
        print("문화 정보 API 오류: $e");
        final errorMessage = ChatMessageModel(
          id: 'ai_culture_err_${DateTime.now().millisecondsSinceEpoch}',
          text: "AI Hatchy: Sorry, I couldn't fetch the cultural information at the moment. Please try again later.",
          timestamp: DateTime.now(),
          sender: MessageSender.other,
        );
        if (mounted) setState(() { _messages.insert(0, errorMessage); });
      }
    } else {
      final promptMessage = ChatMessageModel(
        id: 'ai_culture_prompt_again_${DateTime.now().millisecondsSinceEpoch}',
        text: "AI Hatchy: To provide cultural information, I need both your home country and destination. Please select '$topicText' again and enter the details.",
        timestamp: DateTime.now(),
        sender: MessageSender.other,
      );
      if (mounted) setState(() { _messages.insert(0, promptMessage); });
    }

    _scrollToBottom();
    if (mounted) setState(() => _isSending = false); // 이 핸들러의 작업 완료, 전송 상태 해제
  }

  Future<void> _handleScenarioPhrasesRequest() async {
    if (!mounted) return;
    // setState(() => _isSending = true); // 이미 _sendMessage에서 설정됨

    String? userScenarioRequest;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final scenarioController = TextEditingController();
        return AlertDialog(
          title: const Text('Travel Phrases Request'),
          content: TextField(
            controller: scenarioController,
            decoration: const InputDecoration(hintText: 'e.g., Ordering food in Japanese'),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                userScenarioRequest = scenarioController.text.trim();
                Navigator.pop(context);
              },
              child: const Text('Request'),
            ),
          ],
        );
      },
    );

    if (userScenarioRequest != null && userScenarioRequest!.isNotEmpty) {
      final thinkingMessage = ChatMessageModel(
        id: 'ai_thinking_phrases_${DateTime.now().millisecondsSinceEpoch}',
        text: "AI Hatchy: Generating travel phrases for \"$userScenarioRequest\"...",
        timestamp: DateTime.now(),
        sender: MessageSender.other,
      );
      if (mounted) setState(() { _messages.insert(0, thinkingMessage); });
      _scrollToBottom();

      try {
        final phrasesBlock = await ApiService.fetchScenarioPhrases(userRequest: userScenarioRequest!);
        final aiResponseMessage = ChatMessageModel(
          id: 'ai_phrases_resp_${DateTime.now().millisecondsSinceEpoch}',
          text: "AI Hatchy: Here are some phrases for \"$userScenarioRequest\":\n\n$phrasesBlock",
          timestamp: DateTime.now(),
          sender: MessageSender.other,
        );
        if (mounted) setState(() { _messages.insert(0, aiResponseMessage); });
      } catch (e) {
        print("여행 회화문 API 오류: $e");
        final errorMessage = ChatMessageModel(
          id: 'ai_phrases_err_${DateTime.now().millisecondsSinceEpoch}',
          text: "AI Hatchy: Sorry, I couldn't generate travel phrases at the moment. Please try again with a different request.",
          timestamp: DateTime.now(),
          sender: MessageSender.other,
        );
        if (mounted) setState(() { _messages.insert(0, errorMessage); });
      }
    } else {
      final promptMessage = ChatMessageModel(
        id: 'ai_phrases_prompt_again_${DateTime.now().millisecondsSinceEpoch}',
        text: "AI Hatchy: To generate travel phrases, I need to know the situation. Please select the topic again and enter details.",
        timestamp: DateTime.now(),
        sender: MessageSender.other,
      );
      if (mounted) setState(() { _messages.insert(0, promptMessage); });
    }
    _scrollToBottom();
    if (mounted) setState(() => _isSending = false); // 이 핸들러의 작업 완료, 전송 상태 해제
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0, // Scroll to the top as list is reversed
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: _buildAppBar(colorScheme),
      body: Column(
        children: [
          _buildMessageListArea(),
          if (_recommendedMessages.isNotEmpty)
            _buildRecommendedMessages(context, colorScheme),
          _buildInputArea(colorScheme),
        ],
      ),
    );
  }

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
          child: CircleAvatar( // 임시 온라인 상태 표시
            radius: 12,
            backgroundColor: Colors.grey.shade300,
            child: CircleAvatar(
              radius: 5,
              backgroundColor: Colors.greenAccent.shade400,
            ),
          ),
        ),
      ],
      backgroundColor: colorScheme.surface,
      elevation: 1,
      centerTitle: false,
    );
  }

  Widget _buildMessageListArea() {
    if (_isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }
    if (_messages.isEmpty && !_isAiTutorChat) { // AI Tutor는 초기 메시지가 있을 수 있음
      return Expanded(
        child: Center(
          child: Text(
            'Start a conversation!',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ),
      );
    }
    // AI Tutor의 경우 _messages가 비어있어도 초기 추천 메시지 UI가 나올 수 있도록 Expanded를 유지
    // 또는 _getDummyMessagesForChat에서 항상 초기 메시지를 제공하도록 보장
    return Expanded(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // 키보드 숨기기
        child: ListView.builder(
          controller: _scrollController,
          reverse: true, // 최신 메시지가 하단에 표시
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            final message = _messages[index];
            return MessageBubble(message: message);
          },
        ),
      ),
    );
  }

  Widget _buildInputArea(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.05),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.add_circle, color: Colors.green.shade600, size: 30),
              onPressed: _isSending ? null : () { /* TODO: 첨부 파일 기능 */ },
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Enter a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0), // TextField 내부 패딩 조정
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 5, // 여러 줄 입력 가능
                  onSubmitted: _isSending ? null : (_) => _sendMessage(),
                  enabled: !_isSending,
                ),
              ),
            ),
            const SizedBox(width: 4),
            _isSending
                ? const Padding(
                padding: EdgeInsets.all(12.0), // IconButton과 유사한 크기 유지
                child: SizedBox(
                    width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)))
                : IconButton(
              icon: Icon(Icons.arrow_upward, color: colorScheme.primary, size: 28),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedMessages(BuildContext context, ColorScheme colorScheme) {
    final Color chipBackgroundColor = colorScheme.brightness == Brightness.light
        ? Colors.deepPurple.shade50 // 밝은 테마에 대한 색상 조정
        : Colors.deepPurple.shade800;
    final Color chipTextColor = colorScheme.brightness == Brightness.light
        ? Colors.deepPurple.shade900
        : Colors.deepPurple.shade50;
    final String sectionTitle = _isAiTutorChat ? 'Recommended Topics with Hatchy' : 'Recommended Topics By Gemini';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3), // 투명도 약간 조정
        border: Border(top: BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 6.0, top:2.0), // 패딩 미세 조정
            child: Text(
              sectionTitle,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.9), // 가독성 개선
                fontWeight: FontWeight.w600, // 약간 더 강조
              ),
            ),
          ),
          SizedBox(
            height: 38, // Chip 높이에 맞게 조정
            child: _recommendedMessages.isEmpty
                ? Center(child: Text('Loading recommendations...', style: TextStyle(color: Colors.grey.shade500)))
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0), // 좌우 패딩 추가
              itemCount: _recommendedMessages.length,
              itemBuilder: (context, index) {
                final messageText = _recommendedMessages[index];
                final String? aiMode = _isAiTutorChat ? _aiTutorFixedRecommendations[messageText] : null;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ActionChip(
                    label: Text(
                      messageText,
                      style: TextStyle(color: chipTextColor, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    backgroundColor: chipBackgroundColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0), // 좀 더 둥글게
                        side: BorderSide(color: chipTextColor.withOpacity(0.2)) // 은은한 테두리
                    ),
                    elevation: 0.5, // 미세한 그림자
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0), // 내부 패딩
                    onPressed: _isSending
                        ? null // 메시지 전송 중에는 비활성화
                        : () => _sendMessage(predefinedText: messageText, aiMode: aiMode),
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