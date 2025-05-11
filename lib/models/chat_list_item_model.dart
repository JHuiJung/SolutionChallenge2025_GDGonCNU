// lib/models/chat_list_item_model.dart
import 'package:flutter/material.dart'; // TimeOfDay 사용 위해 추가

class ChatListItemModel {
  final String chatId; // 채팅방 고유 ID
  final String userId; // 상대방 사용자 ID
  final String name; // 상대방 이름 또는 채팅방 이름
  final String? imageUrl; // 상대방 프로필 이미지 URL (null 가능)
  final String lastMessage; // 마지막 메시지
  final TimeOfDay timestamp; // 마지막 메시지 시간
  final bool isRead; // 읽음 여부 (디자인엔 없지만 보통 필요)

  ChatListItemModel({
    required this.chatId,
    required this.userId,
    required this.name,
    this.imageUrl,
    required this.lastMessage,
    required this.timestamp,
    this.isRead = true,
  });
}

// --- 임시 더미 데이터 생성 함수 ---
List<ChatListItemModel> getDummyChatListItems() {
  return [
    ChatListItemModel(
      chatId: 'chat_ai_tutor',
      userId: 'ai_tutor_bot', // AI 튜터 ID
      name: 'Hatchy',
      // AI 튜터 이미지 (실제 이미지 URL로 교체 필요)
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/8943/8943371.png',
      lastMessage: 'A short sentence that takes up the first and the second line.',
      timestamp: const TimeOfDay(hour: 12, minute: 00),
      isRead: false,
    ),
    ChatListItemModel(
      chatId: 'chat_user_1',
      userId: 'user_1',
      name: 'Brian', // 예시 사용자 이름
      imageUrl: 'https://i.pravatar.cc/150?img=50', // 예시 사용자 이미지
      lastMessage: 'Okay, sounds good! Let me know when you arrive.',
      timestamp: const TimeOfDay(hour: 11, minute: 35),
    ),
    ChatListItemModel(
      chatId: 'chat_user_2',
      userId: 'user_2',
      name: 'Alice',
      imageUrl: 'https://i.pravatar.cc/150?img=51',
      lastMessage: 'Did you see the photos from the trip? They look amazing!',
      timestamp: const TimeOfDay(hour: 10, minute: 12),
    ),
    ChatListItemModel(
      chatId: 'chat_group_1',
      userId: 'group_1', // 그룹 채팅 ID
      name: 'Tokyo Trip Planning', // 그룹 채팅 이름
      imageUrl: null, // 그룹 채팅은 특정 사용자 이미지가 없을 수 있음
      lastMessage: 'Charlie: Don\'t forget to book the tickets!',
      timestamp: const TimeOfDay(hour: 9, minute: 05),
      isRead: false,
    ),
  ];
}