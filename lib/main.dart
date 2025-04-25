import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/preference_selection_screen.dart';
import 'screens/profile_registration_screen.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart'; // 테마 파일 임포트
import 'screens/mypage_screen.dart';
import 'screens/create_post_screen.dart';
import 'screens/post_detail_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/chat_room_screen.dart';
import 'screens/ai_chat_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quokka',
      theme: AppTheme.lightTheme, // 밝은 테마 적용
      darkTheme: AppTheme.darkTheme, // 다크 테마 적용
      themeMode: ThemeMode.system, // 시스템 설정에 따라 테마 자동 전환
      // themeMode: ThemeMode.light, // 항상 밝은 모드
      debugShowCheckedModeBanner: false, // 디버그 배너 숨김

      // 앱 시작 시 첫 화면 설정
      initialRoute: '/login',

      // 네비게이션 라우트 정의
      routes: {
        '/login': (context) => const LoginScreen(),
        '/profile': (context) => const ProfileRegistrationScreen(), // 순서 변경됨
        '/preference': (context) => const PreferenceSelectionScreen(), // 순서 변경됨
        '/main': (context) => const MainScreen(),
        '/mypage': (context) => const MyPageScreen(), // MyPage 라우트 추가
        '/create_post': (context) => const CreatePostScreen(), // 게시글 작성 라우트 추가
        '/post_detail': (context) => const PostDetailScreen(), // 게시글 상세 라우트 추가
        '/user_profile': (context) => const UserProfileScreen(), // 사용자 프로필 라우트 추가
        '/chat_room': (context) => const ChatRoomScreen(), // 개별 채팅방 라우트 추가
        '/ai_chat': (context) => const AiChatScreen(),   // AI 채팅방 라우트 추가
      },
    );
  }
}