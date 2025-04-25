// 희중님 담당
// 아래는 그냥 써놓은 것. 후에 지우면 됩니다.

import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('로그인 화면입니다.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 로그인 성공 후 프로필 등록 화면으로 이동
                Navigator.pushReplacementNamed(context, '/profile');
              },
              child: const Text('로그인 (임시)'),
            ),
            // 여기에 실제 로그인 UI 요소 (TextField, Button 등) 추가
          ],
        ),
      ),
    );
  }
}