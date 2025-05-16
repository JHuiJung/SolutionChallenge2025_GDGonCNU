// lib/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import 'package:intl/intl.dart'; // Time format

class MessageBubble extends StatelessWidget {
  final ChatMessageModel message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.sender == MessageSender.me;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Determine bubble color
    final Color bubbleColor = isMe
        ? colorScheme.primary // Message sent by me (blue tone)
        : colorScheme.surfaceVariant; // Message from other (light grey tone)

    // Determine text color
    final Color textColor = isMe
        ? colorScheme.onPrimary // Text in my message (white tone)
        : colorScheme.onSurfaceVariant; // Text in other's message (dark tone)

    // Time formatter
    final timeFormatter = DateFormat('HH:mm'); // e.g.: 10:43

    // AI translation notice text style
    final aiNoticeStyle = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurface.withValues(alpha: 0.5),
      fontSize: 11,
    );

    // Read status/time text style
    final statusStyle = textTheme.bodySmall?.copyWith(
      color: isMe ? colorScheme.onPrimary.withValues(alpha: 0.7) : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      fontSize: 11,
    );

    // Set bubble shape (rounded corners only, excluding tail effect)
    final BorderRadius borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4), // Rounded bottom-left for my message
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18), // Rounded bottom-right for other's message
    );

    return Align(
      // Message alignment (left/right)
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          // Limit maximum width of the bubble (75% of screen width)
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: borderRadius,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Take up only the size of content
          children: [
            // Display original text (if translated)
            if (message.originalText != null && message.isTranslatedByAI)
              Text(
                message.originalText!,
                style: TextStyle(color: textColor.withValues(alpha: 0.8), fontSize: 14), // Original text slightly faded
              ),
            // Display translated/main text
            Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 15, height: 1.4), // Main text
            ),
            // AI translation notice
            if (message.isTranslatedByAI)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text('Translated by Gemini', style: aiNoticeStyle),
              ),
            // Time and read status (below my message or other's message)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  if (isMe && message.isRead) // If it's my message and read
                    Text('Read ', style: statusStyle),
                  Text(timeFormatter.format(message.timestamp), style: statusStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}