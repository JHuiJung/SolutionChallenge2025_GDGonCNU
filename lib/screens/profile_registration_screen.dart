// lib/screens/profile_registration_screen.dart
import 'package:flutter/material.dart';
import '../firebase/firestoreManager.dart' as firestoreManager;
import 'package:firebase_auth/firebase_auth.dart';

// StatefulWidget으로 변경
class ProfileRegistrationScreen extends StatefulWidget {
  const ProfileRegistrationScreen({super.key});

  @override
  State<ProfileRegistrationScreen> createState() => _ProfileRegistrationScreenState();
}

class _ProfileRegistrationScreenState extends State<ProfileRegistrationScreen> {
  // 선택된 값을 저장할 상태 변수
  // Username을 위한 TextEditingController 추가
  final TextEditingController _usernameController = TextEditingController();
  String? _selectedNationality;
  String? _selectedGender;
  int? _selectedBirthYear;

  // 드롭다운 옵션 데이터
  // TODO: 실제 앱에서는 이 목록을 더 확장하거나 외부 소스(JSON 등)에서 가져와야 함
  final List<String> _nationalities = [
    'South Korea', 'United States', 'Japan', 'China', 'United Kingdom',
    'Germany', 'France', 'Canada', 'Australia', 'India', 'Vietnam',
    'Thailand', 'Philippines', 'Russia', 'Brazil', 'Mexico', 'Other'
  ];
  final List<String> _genders = ['남', '여', '기타'];
  // 생년월일 (1900 ~ 2025) - 최근 연도가 위로 오도록 reversed 사용
  final List<int> _birthYears = List<int>.generate(
      DateTime.now().year - 1900 + 1, (index) => 1900 + index)
      .reversed
      .toList();

  // --- Controller Dispose 추가 ---
  @override
  void dispose() {
    _usernameController.dispose(); // 컨트롤러 메모리 해제
    super.dispose();
  }

  // 입력 필드 스타일을 위한 Helper 함수 (재사용)
  InputDecoration _buildInputDecoration({String? labelText, String? hintText, required Color backgroundColor}) {
    return InputDecoration(
      labelText: labelText, // 라벨 텍스트 추가
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[500]),
      filled: true,
      fillColor: backgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color textFieldBackgroundColor = colorScheme.brightness == Brightness.light
        ? Colors.grey.shade200
        : Colors.grey.shade800;
    final Color fabColor = colorScheme.brightness == Brightness.light
        ? Colors.grey.shade300
        : Colors.grey.shade700;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Skip 버튼 클릭 시 바로 선호도 분석 화면으로 이동

              Navigator.pushReplacementNamed(context, '/preference');
            },
            child: const Text(
              'skip',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Set up\nyour account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.amberAccent,
                  child: Icon(Icons.person, size: 70, color: Colors.grey[700]),
                ),
              ),
              const SizedBox(height: 50),

              // --- User Name TextField 수정 ---
              _buildSectionTitle('user name'),
              TextField(
                controller: _usernameController, // 컨트롤러 연결
                decoration: _buildInputDecoration(
                  hintText: 'Enter your username',
                  backgroundColor: textFieldBackgroundColor,
                ),
                // 추가 설정 (선택 사항)
                textCapitalization: TextCapitalization.words, // 이름처럼 첫 글자 대문자
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 20),

              // --- Nationality (DropdownButtonFormField) ---
              _buildSectionTitle('Nationality'),
              DropdownButtonFormField<String>(
                value: _selectedNationality, // 현재 선택된 값
                hint: const Text('Select Nationality'), // Placeholder 텍스트
                items: _nationalities.map((String nationality) {
                  return DropdownMenuItem<String>(
                    value: nationality,
                    child: Text(nationality),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedNationality = newValue; // 선택 시 상태 업데이트
                  });
                },
                decoration: _buildInputDecoration( // 스타일 적용
                  backgroundColor: textFieldBackgroundColor,
                  // labelText: 'Nationality', // 라벨이 필요하면 추가
                ),
                // 드롭다운 펼쳐졌을 때 스타일 (선택 사항)
                dropdownColor: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12.0),
                isExpanded: true, // 너비 채우기
              ),
              const SizedBox(height: 20),

              // --- Gender (DropdownButtonFormField) ---
              _buildSectionTitle('Gender'),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                hint: const Text('Select Gender'),
                items: _genders.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                decoration: _buildInputDecoration(
                  backgroundColor: textFieldBackgroundColor,
                ),
                dropdownColor: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12.0),
                isExpanded: true,
              ),
              const SizedBox(height: 20),

              // --- Age (Year of Birth - DropdownButtonFormField) ---
              _buildSectionTitle('Age (Year of Birth)'),
              DropdownButtonFormField<int>(
                value: _selectedBirthYear,
                hint: const Text('Select Year'),
                items: _birthYears.map((int year) {
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(year.toString()),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedBirthYear = newValue;
                  });
                },
                decoration: _buildInputDecoration(
                  backgroundColor: textFieldBackgroundColor,
                ),
                dropdownColor: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12.0),
                isExpanded: true,
                // 스크롤 가능하도록 (항목 많을 시)
                menuMaxHeight: 300.0,
              ),
              const SizedBox(height: 80), // FAB 공간 확보
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // --- 입력된 Username 값 가져오기 ---
          final String username = _usernameController.text.trim(); // trim()으로 앞뒤 공백 제거

          // TODO: 입력값 유효성 검사 추가 (예: username이 비어있는지 확인)
          if (username.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter your username.')),
            );
            return; // 진행 중단
          }
          // 다른 필드도 필요시 유효성 검사 추가

          // --- 모든 데이터 출력 (확인용) ---
          // TODO: 선택된 값들(_selectedNationality, _selectedGender, _selectedBirthYear) 저장 로직 추가
          print('Username: $username'); // 가져온 username 출력
          print('Nationality: $_selectedNationality');
          print('Gender: $_selectedGender');
          print('Birth Year: $_selectedBirthYear');

          //firestore에 저장
          User? userinfo = FirebaseAuth.instance.currentUser;

          if(userinfo != null)
            {
              firestoreManager.mainUserInfo.email = userinfo.email;
            }
          firestoreManager.mainUserInfo.name = username;
          firestoreManager.mainUserInfo.gender = _selectedGender;
          firestoreManager.mainUserInfo.region = _selectedNationality;
          firestoreManager.mainUserInfo.birthYear = _selectedBirthYear!;

          Navigator.pushReplacementNamed(context, '/preference');
        },
        backgroundColor: fabColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Icon(
          Icons.arrow_forward,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  // 입력 필드 제목을 위한 Helper 위젯
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
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
            filled: true,
            // 배경색 채우기 활성화
            fillColor: backgroundColor,
            // 배경색 지정
            border: OutlineInputBorder( // 테두리 설정
              borderRadius: BorderRadius.circular(12.0), // 모서리 둥글게
              borderSide: BorderSide.none, // 기본 테두리 선 제거
            ),
            contentPadding: const EdgeInsets.symmetric(
                vertical: 16.0, horizontal: 16.0), // 내부 여백
          ),
        ),
      ],
    );
  }
}