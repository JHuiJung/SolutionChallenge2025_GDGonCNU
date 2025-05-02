import 'package:flutter/material.dart';
import '../firebase/firestoreManager.dart' as firestoreManager;

class ProfileRegistrationScreen extends StatelessWidget {
  const ProfileRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 테마 색상 가져오기 (선택 사항, 일관성을 위해)
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color textFieldBackgroundColor = colorScheme.brightness == Brightness.light
        ? Colors.grey.shade200 // 밝은 모드 배경색
        : Colors.grey.shade800; // 어두운 모드 배경색
    final Color fabColor = colorScheme.brightness == Brightness.light
        ? Colors.grey.shade300
        : Colors.grey.shade700;

    return Scaffold(
      // AppBar 설정
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 배경 투명
        elevation: 0, // 그림자 제거
        // 뒤로가기 버튼 (기본 아이콘 사용)
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface), // 테마 색상 사용
          onPressed: () {
            // 로그인 화면으로 돌아가거나, 앱 정책에 따라 다른 동작 추가 가능
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // 예: 로그인 화면으로 강제 이동
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
        ),
        // Skip 버튼
        actions: [
          TextButton(
            onPressed: () {
              // Skip 버튼 클릭 시 바로 선호도 분석 화면으로 이동

              Navigator.pushReplacementNamed(context, '/preference');
            },
            child: Text(
              'skip',
              style: TextStyle(
                color: Colors.grey, // 디자인과 유사한 색상
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16), // 오른쪽 여백
        ],
      ),
      // 메인 컨텐츠
      body: SingleChildScrollView( // 키보드 올라올 때 오버플로우 방지
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // 좌우 여백
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 자식 위젯 왼쪽 정렬
            children: [
              const SizedBox(height: 20), // AppBar 아래 여백

              // "Set up your account" 텍스트
              Center(
                child: Text(
                  'Set up\nyour account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2, // 줄 간격
                    color: colorScheme.onSurface, // 테마 텍스트 색상
                  ),
                ),
              ),
              const SizedBox(height: 40), // 제목과 이미지 사이 여백

              // 프로필 이미지 (임시 Placeholder)
              Center(
                child: CircleAvatar(
                  radius: 60, // 이미지 크기
                  backgroundColor: Colors.amberAccent, // 임시 배경색
                  // 실제 이미지 위젯 추가 (예: Image.asset, Image.network)
                  // child: Image.asset('assets/your_placeholder_image.png'), // 예시
                  child: Icon(Icons.person, size: 70, color: Colors.grey[700]), // 임시 아이콘
                ),
              ),
              const SizedBox(height: 50), // 이미지와 입력 필드 사이 여백

              // 입력 필드들
              _buildTextField(
                label: 'User Name',
                hint: 'Enter your username', // 힌트 텍스트 추가 (선택 사항)
                backgroundColor: textFieldBackgroundColor,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                label: 'Nationality',
                hint: 'Enter your nationality',
                backgroundColor: textFieldBackgroundColor,
                // TODO: 추후 DropdownButtonFormField 등으로 변경 고려
              ),
              const SizedBox(height: 20),

              _buildTextField(
                label: 'Gender',
                hint: 'Select your gender',
                backgroundColor: textFieldBackgroundColor,
                // TODO: 추후 DropdownButtonFormField 등으로 변경 고려
              ),
              const SizedBox(height: 20),

              _buildTextField(
                label: 'Age',
                hint: 'Enter your age',
                keyboardType: TextInputType.number, // 숫자 키보드
                backgroundColor: textFieldBackgroundColor,
              ),
              const SizedBox(height: 80), // 입력 필드와 버튼 사이 여백 (FAB 공간 확보)
            ],
          ),
        ),
      ),
      // 다음 단계로 넘어가는 버튼 (FloatingActionButton 사용)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 프로필 정보 저장 로직 추가 (필요 시)

          // 선호도 분석 화면으로 이동
          Navigator.pushReplacementNamed(context, '/preference');
        },
        backgroundColor: fabColor, // 디자인과 유사한 배경색
        elevation: 2, // 약간의 그림자
        shape: RoundedRectangleBorder( // 모서리 둥글게
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Icon(
          Icons.arrow_forward,
          color: colorScheme.onSurface, // 아이콘 색상
        ),
      ),
    );
  }

  // 텍스트 필드를 생성하는 Helper 위젯 함수
  Widget _buildTextField({
    required String label,
    required String hint,
    required Color backgroundColor,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600], // 라벨 색상
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true, // 배경색 채우기 활성화
            fillColor: backgroundColor, // 배경색 지정
            border: OutlineInputBorder( // 테두리 설정
              borderRadius: BorderRadius.circular(12.0), // 모서리 둥글게
              borderSide: BorderSide.none, // 기본 테두리 선 제거
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0), // 내부 여백
          ),
        ),
      ],
    );
  }
}