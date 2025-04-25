import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 이전 화면에서 전달받은 사용자 ID (라우팅 설정 필요)
    final userId = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile ${userId ?? ''}'),
      ),
      body: Center(
        child: Text(
          'Profile Information for User ID: ${userId ?? 'Unknown'}\n(Name, Gender, Location, Posts, etc.)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}