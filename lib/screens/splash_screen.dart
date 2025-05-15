// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  // 일정 시간 후 로그인 화면으로 이동하는 함수
  Future<void> _navigateToLogin() async {
    // 2초 동안 스플래시 화면을 보여줍니다.
    // 실제 앱에서는 여기서 초기 데이터 로딩, 설정 확인 등의 작업을 수행할 수 있습니다.
    await Future.delayed(const Duration(seconds: 2));

    // 위젯이 여전히 마운트되어 있는지 확인 후 네비게이션
    if (mounted) {
      // '/login' 라우트로 이동하고, 현재 스플래시 화면은 스택에서 제거
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color backgroundColor = colorScheme.brightness == Brightness.light
        ? Colors.grey.shade100 // 밝은 모드 배경색 (또는 디자인에 맞는 색상)
        : Colors.grey.shade900; // 어두운 모드 배경색 (또는 디자인에 맞는 색상)

    return Scaffold(
      backgroundColor: backgroundColor, // 배경색 설정
      body: Center( // 모든 컨텐츠를 화면 중앙에 정렬
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 수직 중앙 정렬
          children: <Widget>[
            // 1. 달걀 이미지
            Image.asset(
              'assets/images/egg.png', // 에셋 경로
              width: 200, // 이미지 너비 조절 (원하는 크기로)
              height: 200, // 이미지 높이 조절
              // fit: BoxFit.contain, // 이미지 비율 유지하며 채우기 (선택 사항)
            ),
            const SizedBox(height: 30), // 이미지와 텍스트 사이 간격

            // 2. 문구 "Travel local,"
            Text(
              'Travel Local',
              textAlign: TextAlign.center, // 텍스트 중앙 정렬
              style: textTheme.headlineMedium?.copyWith( // headlineSmall 또는 titleLarge 등 조절 가능
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground.withOpacity(0.8), // 테마에 맞는 텍스트 색상
              ),
            ),
            const SizedBox(height: 8), // 문구 사이 간격

            // 3. 문구 "Connect Deeper."
            Text(
              'Connect Deeper',
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}