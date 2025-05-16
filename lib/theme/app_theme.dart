import 'package:flutter/material.dart';

class AppTheme {
  // 밝은 테마 정의
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true, // Material 3 디자인 사용
    brightness: Brightness.light,
    primaryColor: Colors.purple.shade200, // 밝고 활기찬 주 색상
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.purple.shade200, // 씨앗 색상으로 전체 색상 스킴 생성
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.grey[100], // 밝은 배경색
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.purple.shade100, // 밝은 앱바 배경
      foregroundColor: Colors.black87, // 앱바 텍스트/아이콘 색상
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple.shade200, // 버튼 배경색
        foregroundColor: Colors.white, // 버튼 텍스트색
      ),
    ),
    // 다른 위젯 테마들도 필요에 따라 커스터마이징 가능
  );

  // 다크 테마 정의
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: Colors.purple.shade100, // 다크 모드에서의 주 색상
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.purple.shade200, // 씨앗 색상
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850],
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple.shade100, // 버튼 배경색
        foregroundColor: Colors.purple.shade200, // 버튼 텍스트색
      ),
    ),
    // 다른 위젯 테마들도 필요에 따라 커스터마이징 가능
  );
}