// lib/models/chat_message_model.dart
enum MessageSender { me, other, ai } // 메시지 발신자 타입

class ChatMessageModel {
  final String id;
  final String text;
  final String? originalText; // 번역된 경우 원문
  final DateTime timestamp;
  final MessageSender sender;
  final bool isRead; // 내가 보낸 메시지의 읽음 상태
  final bool isTranslatedByAI; // AI 번역 여부

  ChatMessageModel({
    required this.id,
    required this.text,
    this.originalText,
    required this.timestamp,
    required this.sender,
    this.isRead = false,
    this.isTranslatedByAI = false,
  });
}

// --- 임시 더미 데이터 생성 함수 ---
List<ChatMessageModel> getDummyChatMessages(String chatId) {
  // chatId에 따라 다른 대화 내용을 보여줄 수 있음 (지금은 동일)
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
      timestamp: now.subtract(const Duration(minutes: 1, seconds: 5)), // 원문이 조금 더 빠름
      sender: MessageSender.other,
    ),
    ChatMessageModel(
      id: 'msg_3',
      text: 'Have you ever been to Korea?',
      timestamp: now.subtract(const Duration(minutes: 2)),
      sender: MessageSender.me,
      isRead: true, // 읽음 상태
    ),
    ChatMessageModel(
      id: 'msg_2_ko', // ID 구분
      text: '한국에 와 본 적이 있나요?',
      originalText: 'Have you ever been to Korea?', // 원문
      timestamp: now.subtract(const Duration(minutes: 2)),
      sender: MessageSender.me,
      isRead: true,
      isTranslatedByAI: true, // AI 번역됨
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