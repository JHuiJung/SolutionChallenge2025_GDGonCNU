// lib/screens/edit_mypage_screen.dart
import 'package:flutter/material.dart';

class EditMyPageScreen extends StatefulWidget {
  const EditMyPageScreen({super.key});

  @override
  State<EditMyPageScreen> createState() => _EditMyPageScreenState();
}

class _EditMyPageScreenState extends State<EditMyPageScreen> {
  // TODO: 기존 프로필 데이터를 로드하고 수정할 컨트롤러/변수 선언

  @override
  void initState() {
    super.initState();
    // TODO: 이전 화면(MyPage)에서 전달받거나 DB에서 기존 프로필 데이터 로드
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          // 저장 버튼 (기능은 추후 구현)
          TextButton(
            onPressed: () {
              // TODO: 수정된 프로필 정보 저장 로직 구현
              print('Save profile changes');
              Navigator.pop(context); // 저장 후 이전 화면으로 돌아가기
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Profile editing form goes here.\n(Name, Status Message, Preferences, etc.)',
            textAlign: TextAlign.center,
          ),
        ),
        // TODO: 실제 프로필 수정 UI 구현 (TextField, Dropdown 등)
      ),
    );
  }
}