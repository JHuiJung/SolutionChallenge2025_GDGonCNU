import 'package:flutter/material.dart';

class MeetupScreen extends StatelessWidget {
  const MeetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold 없이 바로 컨텐츠 위젯 반환 (MainScreen의 Scaffold 사용)
    return const Center(
      child: Text(
        'Meet-Up 화면 내용이 여기에 표시됩니다.',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}