import 'package:flutter/material.dart';

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 이전 화면에서 전달받은 게시글 ID (라우팅 설정 필요)
    final postId = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Post Detail ${postId ?? ''}'),
      ),
      body: Center(
        child: Text('Details for Meet-Up Post ID: ${postId ?? 'Unknown'}'),
      ),
    );
  }
}