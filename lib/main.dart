import 'theme/app_theme.dart'; // 테마 파일 임포트
import 'dart:ui'; // import 추가

import 'package:flutter/material.dart';
import 'package:naviya/screens/spot_detail_screen.dart';
import 'package:naviya/screens/write/write_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'firebase/firebase_test_screen.dart';
import 'firebase/firestoreManager.dart' as firestoreManager;

// import 'screens/create_post_screen.dart'; (삭제함)
import 'screens/login_screen.dart';
import 'screens/preference_selection_screen.dart';
import 'screens/profile_registration_screen.dart';
import 'screens/main_screen.dart';
import 'screens/mypage_screen.dart';
import 'screens/post_detail_screen.dart';
import 'screens/user_profile_screen.dart'; 
import 'screens/chat/chat_room_screen.dart';
import 'screens/chat/ai_chat_screen.dart';
import 'screens/search_screen.dart'; // 검색 화면 임포트
import 'screens/spot_detail_screen.dart'; // 관광지 상세 화면 임포트
import 'screens/write/write_user_comment_screen.dart';
import 'screens/write/write_spot_comment_screen.dart';
import 'screens/edit_mypage_screen.dart'; // 프로필 수정 화면 임포트

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 테스트용 끝나고 지우기
  //firestoreManager.getUserInfoByEmail("wjdgmlwnd12@gmail.com");

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
      // themeMode: ThemeMode.system, // 시스템 설정에 따라 테마 자동 전환
      themeMode: ThemeMode.light, // 항상 밝은 모드
      debugShowCheckedModeBanner: false, // 디버그 배너 숨김
      scrollBehavior: MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
      ),

      // 앱 시작 시 첫 화면 설정
      initialRoute: '/login',

      // 네비게이션 라우트 정의
      routes: {
        '/login': (context) => const FirebaseTestScreen(),
        //'/login': (context) => const LoginScreen(),
        '/profile': (context) => const ProfileRegistrationScreen(),
        '/preference': (context) => const PreferenceSelectionScreen(),
        '/main': (context) => const MainScreen(),
        '/mypage': (context) => const MyPageScreen(), // MyPage 라우트 추가
        //'/create_post': (context) => const CreatePostScreen(), // 게시글 작성 라우트 (삭제함)
        '/post_detail': (context) => const PostDetailScreen(), // 게시글 상세 라우트 추가
        '/user_profile': (context) => const UserProfileScreen(), // 사용자 프로필 라우트 추가
        '/chat_room': (context) => const ChatRoomScreen(), // 개별 채팅방 라우트 추가
        '/ai_chat': (context) => const AiChatScreen(),   // AI 채팅방 라우트 추가
        '/write': (context) => const WriteScreen(), // 글쓰기 화면 라우트 추가
        '/spot_detail': (context) => const SpotDetailScreen(),
        '/search': (context) => const SearchScreen(), // 검색 화면 라우트 추가
        '/write_user_comment': (context) => const WriteUserCommentScreen(), // 사용자 코멘트 작성 라우트 추가
        '/write_spot_comment': (context) => const WriteSpotCommentScreen(), // 관광지 코멘트 작성 라우트 추가
        '/edit_mypage': (context) => const EditMyPageScreen(), // 프로필 수정 라우트 추가
      },
    );
  }
}