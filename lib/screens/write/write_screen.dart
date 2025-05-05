// lib/screens/write_screen.dart
import 'package:flutter/material.dart';

class WriteScreen extends StatelessWidget {
  const WriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Meet-Up 글쓰기인지, Map 관련 글쓰기인지 구분할 파라미터 필요 가능성
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write Post'), // 상황에 따라 제목 변경 가능
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Post writing form goes here.\n(Could be for Meet-Up or Map related content)',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      // TODO: 작성 완료 버튼 등 추가
    );
  }
}