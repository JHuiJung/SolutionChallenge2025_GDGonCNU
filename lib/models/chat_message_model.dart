// lib/models/chat_message_model.dart
enum MessageSender { me, other, ai } // Message sender type

class ChatMessageModel {
  final String id;
  final String text;
  final String? originalText;
  final DateTime timestamp;
  final MessageSender sender;
  final bool isRead;
  final bool isTranslatedByAI;

  ChatMessageModel({
    required this.id,
    required this.text,
    this.originalText,
    required this.timestamp,
    required this.sender,
    this.isRead = false,
    this.isTranslatedByAI = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'originalText': originalText,
      'timestamp': timestamp.toIso8601String(),
      'sender': sender.name,
      'isRead': isRead,
      'isTranslatedByAI': isTranslatedByAI,
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'],
      text: map['text'],
      originalText: map['originalText'],
      timestamp: DateTime.parse(map['timestamp']),
      sender: MessageSender.values.firstWhere((e) => e.name == map['sender']),
      isRead: map['isRead'] ?? false,
      isTranslatedByAI: map['isTranslatedByAI'] ?? false,
    );
  }
}

class ChatMessageInfoDB {
  final String chatId;
  final List<ChatMessageModel> messages;

  ChatMessageInfoDB({
    required this.chatId,
    required this.messages,
  });

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'messages': messages.map((m) => m.toMap()).toList(),
    };
  }

  factory ChatMessageInfoDB.fromMap(Map<String, dynamic> map) {
    return ChatMessageInfoDB(
      chatId: map['chatId'],
      messages: (map['messages'] as List)
          .map((m) => ChatMessageModel.fromMap(m))
          .toList(),
    );
  }
}



// --- Temporary Dummy Data Creation Function ---
List<ChatMessageModel> getDummyChatMessages(String chatId) {
  // Can show different conversation based on chatId (currently same)
  final now = DateTime.now();
  return [
    ChatMessageModel(
      id: 'msg_5',
      text: '아니, 처음이야.',
      originalText: "no, It's my first time.",
      timestamp: now.subtract(const Duration(minutes: 1)),
      sender: MessageSender.other,
      isTranslatedByAI: true,
    ),
    ChatMessageModel(
      id: 'msg_4',
      text: "no, It's my first time.",
      timestamp: now.subtract(const Duration(minutes: 1, seconds: 5)), // Original is slightly earlier
      sender: MessageSender.other,
    ),
    ChatMessageModel(
      id: 'msg_3',
      text: 'Have you ever been to Korea?',
      timestamp: now.subtract(const Duration(minutes: 2)),
      sender: MessageSender.me,
      isRead: true, // Read status
    ),
    ChatMessageModel(
      id: 'msg_2_ko', // ID differentiation
      text: '한국에 와 본 적이 있나요?',
      originalText: 'Have you ever been to Korea?', // Original text
      timestamp: now.subtract(const Duration(minutes: 2)),
      sender: MessageSender.me,
      isRead: true,
      isTranslatedByAI: true, // Translated by AI
    ),
    ChatMessageModel(
      id: 'msg_1_ko',
      text: '안녕! 나는 다음 달에 한국에 방문 할 예정이야. 만나서 같이 놀고 맥주 한 잔 하고 싶어!',
      originalText: 'Hi! I\'m gonna visit Korea next month. Hope we can hang out and grab some beer together!',
      timestamp: now.subtract(const Duration(minutes: 5)),
      sender: MessageSender.other,
      isTranslatedByAI: true,
    ),
    ChatMessageModel(
      id: 'msg_1_en',
      text: 'Hi! I\'m gonna visit Korea next month. Hope we can hang out and grab some beer together!',
      timestamp: now.subtract(const Duration(minutes: 5, seconds: 5)),
      sender: MessageSender.other,
    ),
  ];
}