// lib/screens/chat_room_screen.dart
import 'package:flutter/material.dart';
import 'package:naviya/firebase/firestoreManager.dart'; // Import Firestore manager
import '../../models/chat_message_model.dart';
import '../../models/chat_list_item_model.dart'; // Import ChatListItemModel
import '../../services/api_service.dart';
import '../../widgets/message_bubble.dart';
import 'dart:async'; // Using Timer
// import 'package:cloud_firestore/cloud_firestore.dart'; // Uncomment when using Firestore

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessageModel> _messages = []; // List of messages to display on screen
  String _chatPartnerName = 'Loading...'; // Chat partner's name
  String? _chatId; // Current chat room ID
  // late ChatListItemModel chatListItemModel; // Used when loading chat room info from Firestore
  // late ChatMessageInfoDB messageInfoDB; // Used when loading message info from Firestore (commented out part)
  bool _isLoading = true; // Initial data loading state
  bool _isSending = false; // State while processing message sending

  // Getter to check if the current chat room is AI Tutor chat room
  bool get _isAiTutorChat => _chatId == 'chat_ai_tutor';

  // List of recommended messages (Loaded from API or fixed values)
  List<String> _recommendedMessages = [];
  // State variable for saving AI conversation context (history)
  List<String> _aiChatHistory = [];
  // Current AI conversation mode (roleplaying, free talk, etc.)
  String? _currentAiMode; // e.g.: 'roleplay_ordering', 'free_talk'
  String _currentLanguage = 'English'; // Current conversation language (default English)

  // AI Tutor fixed recommended messages (mode identifier)
  final Map<String, String> _aiTutorFixedRecommendations = {
    'Free-talking with Hatchy': 'free_talk',
    'Study essential travel phrases': 'study_scenario_phrases',
    'Role-play ordering with Hatchy': 'roleplay_ordering',
    'Cultural do’s and don’ts': 'culture_info',
  };

  // Flag for travel phrase request status
  bool _isWaitingForPhraseRequestDetail = false;

  @override
  void initState() {
    super.initState();
    // Run after widget build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is String) {
        _chatId = arguments;
        _loadChatDataAndRecommendations(_chatId!);
      } else {
        // Error handling for missing chat ID
        if (mounted) setState(() => _isLoading = false);
        print("Error: Chat ID is not provided or format is incorrect.");
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
      // 1. Load chat partner info (Temporary logic)
      // TODO: Load chat partner info from Firestore or actual data source
      if (chatId == 'chat_ai_tutor') {
        _chatPartnerName = 'Hatchy';
      } else if (chatId == 'chat_user_1') {
        _chatPartnerName = 'Brian';
      } else if (chatId == 'chat_user_2') {
        _chatPartnerName = 'Alice';
      } else {
        _chatPartnerName = 'Unknown User';
      }

      // 2. Load message list (Temporary logic)
      // TODO: Load message list from Firestore or actual data source
      _messages = _getDummyMessagesForChat(chatId);

      // 3. Load recommended messages
      await _loadRecommendedMessages();

    } catch (e) {
      print("Error loading chat data: $e");
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
          text: 'Hello!',
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
        topics = await ApiService.fetchTopics(5); // Recommended topics for normal chat
      }
    } catch (e) {
      print("Error loading recommended messages: $e");
      // Optionally, set topics to an empty list or default error messages
    }
    if (mounted) {
      setState(() {
        _recommendedMessages = topics;
      });
    }
  }

  // Message sending function
  Future<void> _sendMessage({String? predefinedText, String? aiMode}) async {
    if (_isSending && predefinedText == null) return;

    final originalText = predefinedText ?? _textController.text.trim();
    if (originalText.isEmpty) return;

    if (mounted) setState(() => _isSending = true);

    final messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    final sentTime = DateTime.now();
    String? translatedText;

    // Add the message sent by the user to the UI first
    final newMessage = ChatMessageModel(
      id: messageId,
      text: (_isAiTutorChat || translatedText == null) ? originalText : translatedText, // AI Tutor uses original, otherwise translated first
      originalText: (!_isAiTutorChat && translatedText != null) ? originalText : null,
      timestamp: sentTime,
      sender: MessageSender.me,
      isRead: false,
      isTranslatedByAI: !_isAiTutorChat && translatedText != null,
    );

    if (mounted) {
      setState(() { _messages.insert(0, newMessage); });
      if (predefinedText == null) _textController.clear();
      _scrollToBottom();
    }

    // Translation (Only if not AI Tutor)
    if (!_isAiTutorChat) {
      try {
        translatedText = await ApiService.translate(originalText);
        // Update message on successful translation (optional UI update)
        final messageIndex = _messages.indexWhere((msg) => msg.id == messageId);
        if (messageIndex != -1 && mounted) {
          final updatedMessage = ChatMessageModel(
            id: _messages[messageIndex].id, text: translatedText!, originalText: originalText,
            timestamp: _messages[messageIndex].timestamp, sender: _messages[messageIndex].sender,
            isRead: _messages[messageIndex].isRead, isTranslatedByAI: true,
          );
          // setState(() { _messages[messageIndex] = updatedMessage; }); // Uncomment to update UI
        }
      } catch (e) {
        print("Translation API error: $e");
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to translate message.')));
      }
    }

    // --- AI Tutor Response Handling ---
    if (_isAiTutorChat) {
      // 1. Handle travel phrase request status
      if (_isWaitingForPhraseRequestDetail) {
        // The content entered by the user (originalText) is the detail of the phrase request
        _handleActualScenarioPhrasesRequest(originalText);
        _isWaitingForPhraseRequestDetail = false; // Initialize status
        if (mounted) setState(() => _isSending = false);
        return; // Skip other AI logic
      }

      // 2. Handle based on recommended topic click or existing mode
      String? modeForApiCall;
      if (aiMode != null) { // When recommended topic is clicked
        _currentAiMode = aiMode;
        _aiChatHistory.clear(); // Initialize history when starting a new mode
        modeForApiCall = _currentAiMode;

        if (modeForApiCall == 'study_scenario_phrases') {
          // Display Hatchy's question when "Study essential travel phrases" is clicked
          final aiQuestion = ChatMessageModel(
            id: 'ai_phrase_q_${DateTime.now().millisecondsSinceEpoch}',
            text: "AI Hatchy: What kind of Travel Phrases do you want to know? (e.g., Ordering food at a restaurant in Japanese)",
            timestamp: DateTime.now(),
            sender: MessageSender.other,
          );
          if (mounted) setState(() { _messages.insert(0, aiQuestion); });
          _scrollToBottom();
          _isWaitingForPhraseRequestDetail = true; // Set to wait state for the next user input
          if (mounted) setState(() => _isSending = false);
          return; // Skip API call logic
        } else if (modeForApiCall == 'culture_info') {
          _handleCulturalInfoRequest(originalText); // Cultural information request is handled separately
          // _isSending is managed inside _handleCulturalInfoRequest
          return;
        }
        //  else if (modeForApiCall == 'study_phrases' /* || modeForApiCall == 'study_vocabulary' */) {
        //   _simulateStudyResponse(originalText, modeForApiCall); // Other temporary study responses
        //   if (mounted) setState(() => _isSending = false);
        //   return;
        // }
      } else if (_currentAiMode != null) {
        // User entered directly, and AI mode was previously active
        modeForApiCall = _currentAiMode;
      }

      // 3. Roleplaying or Free Talk API call
      if (modeForApiCall != null && (modeForApiCall.startsWith('roleplay') || modeForApiCall == 'free_talk')) {
        _aiChatHistory.add("user: $originalText");
        Map<String, dynamic> aiApiResponse;
        try {
          if (modeForApiCall.startsWith('roleplay')) {
            aiApiResponse = await ApiService.roleplay(text: originalText, history: _aiChatHistory, language: _currentLanguage);
          } else { // free_talk
            aiApiResponse = await ApiService.freeTalk(text: originalText, history: _aiChatHistory, language: _currentLanguage);
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
          print("AI API error ($modeForApiCall): $e");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Failed to get AI response: ${e.toString()}')));
          }
          if (_aiChatHistory.isNotEmpty && _aiChatHistory.last == "user: $originalText") {
            _aiChatHistory.removeLast(); // Rollback history addition on failure
          }
        }
      } else {
        // User entered directly, and AI mode is not yet selected.
        // Or when an unhandled recommended topic is clicked (this case is guided to be handled in the 'else' block above)
        final aiPromptMessage = ChatMessageModel(
            id: 'ai_prompt_${DateTime.now().millisecondsSinceEpoch}',
            text: 'AI Hatchy: To start the conversation, choose one of the recommended topics below! If you want to have a free conversation, choose Free-talking with Hatchy!',
            timestamp: DateTime.now(),
            sender: MessageSender.other);
        if (mounted) setState(() => _messages.insert(0, aiPromptMessage));
        _scrollToBottom();
      }
    }
    // Release _isSending after all message processing (including AI response) is complete
    if (mounted) setState(() => _isSending = false);
  }

  Future<void> _handleCulturalInfoRequest(String topicText) async {
    // _isSending was set to true in _sendMessage, so only manage API call state here
    if (!mounted) return;
    // setState(() => _isSending = true); // Already set by _sendMessage

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
        print("Cultural info API error: $e");
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
    if (mounted) setState(() => _isSending = false); // Task of this handler completed, release sending status
  }

  // --- Actual Travel Phrase Request Handling Function ---
  Future<void> _handleActualScenarioPhrasesRequest(String userScenarioRequest) async {
    if (!mounted) return;
    // _isSending is already set to true in _sendMessage

    final thinkingMessage = ChatMessageModel(
      id: 'ai_thinking_phrases_${DateTime.now().millisecondsSinceEpoch}',
      text: "AI Hatchy: Got it! Generating travel phrases for \"$userScenarioRequest\"...",
      timestamp: DateTime.now(),
      sender: MessageSender.other,
    );
    if (mounted) setState(() { _messages.insert(0, thinkingMessage); });
    _scrollToBottom();

    try {
      final phrasesBlock = await ApiService.fetchScenarioPhrases(userRequest: userScenarioRequest);
      final aiResponseMessage = ChatMessageModel(
        id: 'ai_phrases_resp_${DateTime.now().millisecondsSinceEpoch}',
        text: "AI Hatchy: Here are some phrases for \"$userScenarioRequest\":\n\n$phrasesBlock",
        timestamp: DateTime.now(),
        sender: MessageSender.other,
      );
      if (mounted) setState(() { _messages.insert(0, aiResponseMessage); });
    } catch (e) {
      print("Travel phrase API error: $e");
      final errorMessage = ChatMessageModel(
        id: 'ai_phrases_err_${DateTime.now().millisecondsSinceEpoch}',
        text: "AI Hatchy: Sorry, I couldn't generate travel phrases at the moment. Please try again.",
        timestamp: DateTime.now(),
        sender: MessageSender.other,
      );
      if (mounted) setState(() { _messages.insert(0, errorMessage); });
    }
    _scrollToBottom();
    // _isSending status is released in the finally block of _sendMessage function
  }
  // --- End of Actual Travel Phrase Request Handling Function ---

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
          child: CircleAvatar( // Temporary online status display
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
    if (_messages.isEmpty && !_isAiTutorChat) { // AI Tutor may have initial messages
      return Expanded(
        child: Center(
          child: Text(
            'Start a conversation!',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ),
      );
    }
    // For AI Tutor, keep Expanded even if _messages is empty so the initial recommended messages UI can appear
    // Or ensure _getDummyMessagesForChat always provides initial messages
    return Expanded(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Hide keyboard
        child: ListView.builder(
          controller: _scrollController,
          reverse: true, // Display latest messages at the bottom
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
              onPressed: _isSending ? null : () { /* TODO: Attachment file feature */ },
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
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0), // Adjust TextField inner padding
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 5, // Multiple lines input possible
                  onSubmitted: _isSending ? null : (_) => _sendMessage(),
                  enabled: !_isSending,
                ),
              ),
            ),
            const SizedBox(width: 4),
            _isSending
                ? const Padding(
                padding: EdgeInsets.all(12.0), // Maintain similar size to IconButton
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
        ? Colors.deepPurple.shade50 // Adjust color for light theme
        : Colors.deepPurple.shade800;
    final Color chipTextColor = colorScheme.brightness == Brightness.light
        ? Colors.deepPurple.shade900
        : Colors.deepPurple.shade50;
    final String sectionTitle = _isAiTutorChat ? 'Recommended Topics with Hatchy' : 'Recommended Topics By Gemini';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3), // Slightly adjust transparency
        border: Border(top: BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 6.0, top:2.0), // Minor padding adjustment
            child: Text(
              sectionTitle,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.9), // Improve readability
                fontWeight: FontWeight.w600, // Slightly more emphasis
              ),
            ),
          ),
          SizedBox(
            height: 38, // Adjust to Chip height
            child: _recommendedMessages.isEmpty
                ? Center(child: Text('Loading recommendations...', style: TextStyle(color: Colors.grey.shade500)))
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0), // Add horizontal padding
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
                        borderRadius: BorderRadius.circular(18.0), // Make it rounder
                        side: BorderSide(color: chipTextColor.withOpacity(0.2)) // Subtle border
                    ),
                    elevation: 0.5, // Subtle shadow
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0), // Inner padding
                    onPressed: _isSending
                        ? null // Disabled while sending message
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