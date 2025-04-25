import 'package:flutter/material.dart';

class AiChatScreen extends StatelessWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat Assistant'),
      ),
      body: const Center(
        child: Text('AI Chat Interface Goes Here'),
        // 여기에 AI 채팅 메시지 목록과 입력 필드 구현
      ),
    );
  }
}