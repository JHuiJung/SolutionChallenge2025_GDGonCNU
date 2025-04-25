// lib/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import 'package:intl/intl.dart'; // 시간 포맷

class MessageBubble extends StatelessWidget {
  final ChatMessageModel message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.sender == MessageSender.me;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // 말풍선 색상 결정
    final Color bubbleColor = isMe
        ? colorScheme.primary // 내가 보낸 메시지 (파란색 계열)
        : colorScheme.surfaceVariant; // 상대방 메시지 (밝은 회색 계열)

    // 텍스트 색상 결정
    final Color textColor = isMe
        ? colorScheme.onPrimary // 내 메시지 텍스트 (흰색 계열)
        : colorScheme.onSurfaceVariant; // 상대방 메시지 텍스트 (어두운 색 계열)

    // 시간 포맷터
    final timeFormatter = DateFormat('HH:mm'); // 예: 10:43

    // AI 번역 알림 텍스트 스타일
    final aiNoticeStyle = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurface.withOpacity(0.5),
      fontSize: 11,
    );

    // 읽음 상태/시간 텍스트 스타일
    final statusStyle = textTheme.bodySmall?.copyWith(
      color: isMe ? colorScheme.onPrimary.withOpacity(0.7) : colorScheme.onSurfaceVariant.withOpacity(0.7),
      fontSize: 11,
    );

    // 말풍선 모양 설정 (꼬리 효과는 제외하고 둥근 모서리만)
    final BorderRadius borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4), // 내 메시지는 왼쪽 아래 둥글게
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18), // 상대 메시지는 오른쪽 아래 둥글게
    );

    return Align(
      // 메시지 정렬 (좌/우)
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          // 말풍선 최대 너비 제한 (화면 너비의 75%)
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
          mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 차지
          children: [
            // 원문 표시 (번역된 경우)
            if (message.originalText != null && message.isTranslatedByAI)
              Text(
                message.originalText!,
                style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 14), // 원문은 약간 흐리게
              ),
            // 번역/주요 텍스트 표시
            Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 15, height: 1.4), // 기본 텍스트
            ),
            // AI 번역 알림
            if (message.isTranslatedByAI)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text('AI에서 번역된 문장입니다.', style: aiNoticeStyle),
              ),
            // 시간 및 읽음 상태 (내 메시지 또는 상대 메시지 아래)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  if (isMe && message.isRead) // 내 메시지이고 읽었으면
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