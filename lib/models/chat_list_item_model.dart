// lib/models/chat_list_item_model.dart
import 'package:flutter/material.dart'; // Added for TimeOfDay usage

class ChatListItemModel {
  final String chatId; // Chat room unique ID
  final String userId; // Other user ID
  final String name; // Other user's name or chat room name
  final String? imageUrl; // Other user's profile image URL (nullable)
  final String lastMessage; // Last message
  final TimeOfDay timestamp; // Last message time
  final bool isRead; // Read status (not in design, but usually needed)
  List<String>? memberIds = [];

  ChatListItemModel({
    required this.chatId,
    required this.userId,
    required this.name,
    this.imageUrl,
    required this.lastMessage,
    required this.timestamp,
    this.isRead = true,
    List<String>? memberIds,
  }) : memberIds = memberIds ?? [] {
    // Add userId to the list in the constructor body
    this.memberIds?.add(this.userId ?? 'noneEmail');
  }
}

// --- Temporary Dummy Data Creation Function ---
List<ChatListItemModel> getDummyChatListItems() {
  return [
    ChatListItemModel(
      chatId: 'chat_ai_tutor',
      userId: 'ai_tutor_bot', // AI tutor ID
      name: 'Hatchy',
      // AI tutor image (Needs to be replaced with actual image URL)
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/8943/8943371.png',
      lastMessage: 'A short sentence that takes up the first and the second line.',
      timestamp: const TimeOfDay(hour: 12, minute: 00),
      isRead: false,
    ),
    ChatListItemModel(
      chatId: 'chat_user_1',
      userId: 'user_1',
      name: 'Brian', // Example user name
      imageUrl: 'https://i.pravatar.cc/150?img=50', // Example user image
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
      userId: 'group_1', // Group chat ID
      name: 'Tokyo Trip Planning', // Group chat name
      imageUrl: null, // Group chats may not have a specific user image
      lastMessage: 'Charlie: Don\'t forget to book the tickets!',
      timestamp: const TimeOfDay(hour: 9, minute: 05),
      isRead: false,
    ),
  ];
}