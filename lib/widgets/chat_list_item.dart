// lib/widgets/chat_list_item.dart
import 'package:flutter/material.dart';
import '../models/chat_list_item_model.dart';
import 'package:intl/intl.dart'; // Added for time formatting (needs intl added to pubspec.yaml)

class ChatListItem extends StatelessWidget {
  final ChatListItemModel chat;

  const ChatListItem({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    // Time formatter (e.g.: 12:00 PM)
    final timeFormatter = DateFormat('h:mm a');
    // Convert TimeOfDay to DateTime (based on today's date)
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, chat.timestamp.hour, chat.timestamp.minute);

    return InkWell( // Entire row clickable
      onTap: () {
        // Navigate to individual chat room (pass chat.chatId)
        Navigator.pushNamed(context, '/chat_room', arguments: chat.chatId);
        print('Navigate to chat room: ${chat.chatId}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // 1. Profile Picture
            InkWell(
              onTap: () {
                // Navigate to user profile if not AI tutor
                if (chat.userId != 'ai_tutor_bot' && chat.userId != 'group_1') { // Exclude group ID as well
                  Navigator.pushNamed(context, '/user_profile', arguments: chat.userId);
                  print('Navigate to user profile: ${chat.userId}');
                }
                // No action defined for AI tutor or group chat profile click (or add different action)
              },
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey.shade300, // Default background color
                backgroundImage: chat.imageUrl != null
                    ? NetworkImage(chat.imageUrl!) // URL image
                    : AssetImage('assets/images/egg.png') as ImageProvider, // Only background color if no URL
                child: chat.imageUrl == null
                    ? null
                    : Icon( // Default icon when no image (e.g.: group icon)
                  chat.userId == 'group_1' ? Icons.group : Icons.person,
                  size: 30,
                  color: Colors.grey.shade600,
                ), // Don't display icon if image exists
              ),
            ),
            const SizedBox(width: 16),

            // 2. Name, Last Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: textTheme.titleMedium?.copyWith(
                      // fontWeight: chat.isRead ? FontWeight.normal : FontWeight.bold, // Bold if unread
                      fontWeight: FontWeight.bold, // Always display bold
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6), // Slightly faded color
                      //fontWeight: chat.isRead ? FontWeight.normal : FontWeight.bold, // Bold if unread
                      fontWeight: FontWeight.bold, // Always display bold
                    ),
                    maxLines: 2, // Maximum 2 lines
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // 3. Time, Navigation Icon
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center, // Vertical center alignment
              children: [
                Text(
                  timeFormatter.format(dateTime), // Display formatted time
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4), // Space between time and icon
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