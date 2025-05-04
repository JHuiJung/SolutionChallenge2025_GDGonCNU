// lib/widgets/chat_list_item.dart
import 'package:flutter/material.dart';
import '../models/chat_list_item_model.dart';
import 'package:intl/intl.dart'; // 시간 포맷팅 위해 추가 (pubspec.yaml에 intl 추가 필요)

class ChatListItem extends StatelessWidget {
  final ChatListItemModel chat;

  const ChatListItem({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    // 시간 포맷터 (예: 12:00 PM)
    final timeFormatter = DateFormat('h:mm a');
    // TimeOfDay를 DateTime으로 변환 (오늘 날짜 기준)
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, chat.timestamp.hour, chat.timestamp.minute);

    return InkWell( // 전체 행 클릭 가능
      onTap: () {
        // 개별 채팅방으로 이동 (chat.chatId 전달)
        Navigator.pushNamed(context, '/chat_room', arguments: chat.chatId);
        print('Navigate to chat room: ${chat.chatId}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // 1. 프로필 사진
            InkWell(
              onTap: () {
                // AI 튜터가 아닌 경우 사용자 프로필로 이동
                if (chat.userId != 'ai_tutor_bot' && chat.userId != 'group_1') { // 그룹 ID도 제외
                  Navigator.pushNamed(context, '/user_profile', arguments: chat.userId);
                  print('Navigate to user profile: ${chat.userId}');
                }
                // AI 튜터나 그룹 채팅 프로필 클릭 시 동작은 정의하지 않음 (또는 다른 동작 추가)
              },
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey.shade300, // 기본 배경색
                backgroundImage: chat.imageUrl != null
                    ? NetworkImage(chat.imageUrl!) // URL 이미지
                    : null, // URL 없으면 배경색만
                child: chat.imageUrl == null
                    ? Icon( // 이미지 없을 때 기본 아이콘 (예: 그룹 아이콘)
                  chat.userId == 'group_1' ? Icons.group : Icons.person,
                  size: 30,
                  color: Colors.grey.shade600,
                )
                    : null, // 이미지 있으면 아이콘 표시 안 함
              ),
            ),
            const SizedBox(width: 16),

            // 2. 이름, 마지막 메시지
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: chat.isRead ? FontWeight.normal : FontWeight.bold, // 안 읽으면 굵게
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6), // 약간 흐린 색
                      fontWeight: chat.isRead ? FontWeight.normal : FontWeight.bold, // 안 읽으면 굵게
                    ),
                    maxLines: 2, // 최대 2줄
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // 3. 시간, 이동 아이콘
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
              children: [
                Text(
                  timeFormatter.format(dateTime), // 포맷된 시간 표시
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4), // 시간과 아이콘 사이 간격
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}