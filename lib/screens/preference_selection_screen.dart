import 'package:flutter/material.dart';
import '../firebase/firestoreManager.dart' as firestoreManager;

class PreferenceSelectionScreen extends StatefulWidget { // 상태 관리를 위해 StatefulWidget으로 변경
  const PreferenceSelectionScreen({super.key});

  @override
  State<PreferenceSelectionScreen> createState() => _PreferenceSelectionScreenState();
}

class _PreferenceSelectionScreenState extends State<PreferenceSelectionScreen> {
  // 각 섹션별 선택된 항목을 추적하기 위한 상태 변수 (예시)
  // 실제 앱에서는 더 구조화된 데이터 모델과 상태 관리 필요
  final Map<String, Set<String>> _selectedPreferences = {
    'section1': {},
    'section2': {},
    'section3': {},
    'section4': {},
  };

  // 각 섹션의 선택지 데이터
  final Map<String, List<String>> _preferenceOptions = {
    'section1': ['Activities', 'Food Discovery', 'Photography', 'Relaxtion', 'Cultural Exploration', 'etc'],
    'section2': ['Nature', 'Cities', 'Both'],
    'section3': ['Alone', 'Friends', 'Family', 'Partners'],
    'section4': ['Detailed and Structured Itinerary', 'Spontaneous and Flexible'],
  };

  // 각 섹션의 질문 (실제 질문으로 교체 필요)
  final Map<String, String> _preferenceQuestions = {
    'section1': 'What is your main purpose for traveling?',
    'section2': 'What type of destination do you prefer?',
    'section3': 'Who do you usually travel with?',
    'section4': 'What is your travel planning style?',
  };


  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color chipBackgroundColor = colorScheme.brightness == Brightness.light
        ? Colors.purple.shade100.withOpacity(0.7) // 밝은 모드 칩 배경색 (연보라)
        : Colors.purple.shade800.withOpacity(0.7); // 어두운 모드 칩 배경색
    final Color selectedChipColor = colorScheme.brightness == Brightness.light
        ? Colors.purple.shade200 // 밝은 모드 선택된 칩 색상 (선호도 블록 선택/미선택 확인하기 위한 색 차이)
        : Colors.purple.shade600; // 어두운 모드 선택된 칩 색상
    final Color chipTextColor = colorScheme.onSurface; // 칩 텍스트 색상

    return Scaffold(
      // AppBar 설정
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () {
            // 프로필 등록 화면으로 돌아가기
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // 예: 프로필 화면으로 강제 이동 (순서 변경됨)
              Navigator.pushReplacementNamed(context, '/profile');
            }
          },
        ),

        actions: [
          TextButton(
            onPressed: () {
              // Skip 버튼 클릭 시 바로 메인 화면으로 이동
              Navigator.pushReplacementNamed(context, '/main');
            },
            child: Text(
              'skip',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      // 메인 컨텐츠
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // "Let me know more about you" 텍스트
              Center(
                child: Text(
                  'Let me know\nmore about you',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30, // 크기 살짝 조절
                    fontWeight: FontWeight.bold,
                    height: 1.3, // 줄 간격
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 40), // 제목과 첫 질문 사이 여백

              // --- 선호도 섹션 생성 (데이터 기반으로 동적 생성) ---
              ..._preferenceOptions.keys.map((sectionKey) {
                return _buildPreferenceSection(
                  context: context,
                  sectionKey: sectionKey,
                  question: _preferenceQuestions[sectionKey] ?? 'Which one do you like?', // 기본 질문
                  options: _preferenceOptions[sectionKey]!,
                  selectedOptions: _selectedPreferences[sectionKey]!,
                  chipBackgroundColor: chipBackgroundColor,
                  selectedChipColor: selectedChipColor,
                  chipTextColor: chipTextColor,
                );
              }).toList(),
              // --- 섹션 생성 끝 ---

              const SizedBox(height: 40), // 마지막 섹션과 버튼 사이 여백

              // 완료 버튼
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // 선택된 선호도 저장 로직 추가 (필요 시)
                    print('Selected Preferences: $_selectedPreferences');

                    firestoreManager.UserState().preferredActivities = _selectedPreferences['section1']!.toList();
                    firestoreManager.UserState().preferredLanguage = _selectedPreferences['section2']!.toList();
                    firestoreManager.UserState().preferredTravelRegions = _selectedPreferences['section3']!.toList();


                    firestoreManager.addUser();

                    // 메인 화면으로 이동
                    Navigator.pushReplacementNamed(context, '/main');
                  },
                  style: ElevatedButton.styleFrom(
                    // 테마의 버튼 스타일을 사용하거나 직접 지정
                    // backgroundColor: colorScheme.primary,
                    // foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // 둥근 버튼
                    ),
                  ),
                  child: const Text('완료'),
                ),
              ),
              const SizedBox(height: 40), // 하단 여백
            ],
          ),
        ),
      ),
    );
  }

  // 선호도 섹션(질문 + 칩 그룹)을 생성하는 Helper 위젯 함수
  Widget _buildPreferenceSection({
    required BuildContext context,
    required String sectionKey,
    required String question,
    required List<String> options,
    required Set<String> selectedOptions,
    required Color chipBackgroundColor,
    required Color selectedChipColor,
    required Color chipTextColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600, // 약간 굵게
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), // 약간 연하게
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10.0, // 칩 사이 가로 간격
          runSpacing: 10.0, // 칩 줄 사이 세로 간격
          children: options.map((option) {
            final bool isSelected = selectedOptions.contains(option);
            return ChoiceChip(
              label: Text(option),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : chipTextColor, // 선택 시 텍스트 색상 변경 (선택 사항)
                fontWeight: FontWeight.w500,
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  // 여러 개 선택 가능하도록 로직 수정 (Set 사용)
                  if (selected) {
                    selectedOptions.add(option);
                  } else {
                    selectedOptions.remove(option);
                  }
                  // 만약 단일 선택만 허용해야 한다면:
                  // if (selected) {
                  //   selectedOptions.clear();
                  //   selectedOptions.add(option);
                  // }
                });
              },
              backgroundColor: chipBackgroundColor, // 기본 배경색
              selectedColor: selectedChipColor, // 선택 시 배경색
              shape: RoundedRectangleBorder( // 둥근 모서리 모양
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(
                  color: isSelected ? selectedChipColor : Colors.transparent, // 선택 시 테두리 강조 (선택 사항)
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0), // 내부 여백
              showCheckmark: false, // 체크 표시 숨김 (디자인에 따라)
            );
          }).toList(),
        ),
        const SizedBox(height: 30), // 섹션 간 여백
      ],
    );
  }
}