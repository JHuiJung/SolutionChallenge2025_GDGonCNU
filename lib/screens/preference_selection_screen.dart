// lib/screens/preference_selection_screen.dart
import 'package:flutter/material.dart';
import '../firebase/firestoreManager.dart' as firestoreManager;

// --- 데이터 구조 정의 --- (다른 파일에 해도 된다)
class PreferenceSection {
  final String key;
  final String question;
  final List<String> options;
  final bool allowMultipleSelection;

  PreferenceSection({
    required this.key,
    required this.question,
    required this.options,
    required this.allowMultipleSelection,
  });
}

final List<PreferenceSection> preferenceSectionsData = [
  PreferenceSection(
    key: 'purpose',
    question: 'What is your main purpose for traveling?',
    options: ['Activities', 'Food Discovery', 'Photography', 'Relaxation', 'Cultural Exploration', 'etc'],
    allowMultipleSelection: true,
  ),
  PreferenceSection(
    key: 'destination',
    question: 'What type of destination do you prefer?',
    options: ['Nature', 'Cities', 'Both'],
    allowMultipleSelection: false,
  ),
  PreferenceSection(
    key: 'companion',
    question: 'Who do you usually travel with?',
    options: ['Alone', 'Friends', 'Family', 'Partners'],
    allowMultipleSelection: true, // 이미지상 여러 개 선택 가능해 보임
  ),
  PreferenceSection(
    key: 'planningStyle',
    question: 'What is your travel planning style?',
    options: ['Detailed and Structured Itinerary', 'Spontaneous and Flexible'],
    allowMultipleSelection: false,
  ),
];
// --- 데이터 구조 정의 끝 ---


class PreferenceSelectionScreen extends StatefulWidget {
  const PreferenceSelectionScreen({super.key});

  @override
  State<PreferenceSelectionScreen> createState() => _PreferenceSelectionScreenState();
}

class _PreferenceSelectionScreenState extends State<PreferenceSelectionScreen> {
  // 선택된 항목들을 저장하는 상태 변수 (모든 섹션을 Set으로 관리)
  final Map<String, Set<String>> _selectedPreferences = {};

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // 칩 스타일 정의 (이미지 참고)
    final Color chipBackgroundColor = colorScheme.brightness == Brightness.light
        ? Colors.purple.shade100.withValues(alpha: 0.7)
        : Colors.purple.shade800.withValues(alpha: 0.7);
    final Color selectedChipColor = colorScheme.brightness == Brightness.light
        ? Colors.deepPurple.shade300 // 선택 시 더 진한 보라색
        : Colors.deepPurple.shade500;
    final Color chipTextColor = colorScheme.onSurface.withValues(alpha: 0.8);
    final Color selectedChipTextColor = Colors.white; // 선택 시 흰색 텍스트

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
              Navigator.pushReplacementNamed(context, '/profile');
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/main');
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
          // 좌우 패딩은 유지, 상하 패딩 조절
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            // Column 자식들을 중앙 정렬 (텍스트 등)
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 메인 제목
              Text(
                'Let me know\nmore about you',
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 50),

              // --- 선호도 섹션 동적 생성 ---
              ...preferenceSectionsData.map((section) {
                return _buildPreferenceSection(
                  context: context,
                  section: section, // 섹션 데이터 전달
                  selectedOptions: _selectedPreferences[section.key] ?? {}, // 현재 선택값 전달
                  chipBackgroundColor: chipBackgroundColor,
                  selectedChipColor: selectedChipColor,
                  chipTextColor: chipTextColor,
                  selectedChipTextColor: selectedChipTextColor,
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

                    // Firestore에 저장
                    firestoreManager.UserState().preferTravlePurpose = _selectedPreferences['purpose']!.toList();
                    firestoreManager.UserState().preferDestination = _selectedPreferences['destination']!.toList();
                    firestoreManager.UserState().preferPeople = _selectedPreferences['companion']!.toList();
                    firestoreManager.UserState().preferPlanningStyle = _selectedPreferences['planningStyle']!.toList();



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
      // 하단 완료 버튼 (FloatingActionButton 사용)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 선택된 선호도 저장 로직 추가
          print('Selected Preferences: $_selectedPreferences');
          Navigator.pushReplacementNamed(context, '/main');
        },
        backgroundColor: chipBackgroundColor, // 버튼 색상 (선택되지 않은 칩 색상과 유사하게)
        elevation: 2,
        child: Icon(
          Icons.arrow_forward,
          color: chipTextColor, // 아이콘 색상
        ),
      ),
    );
  }

  // 선호도 섹션 빌더 함수
  Widget _buildPreferenceSection({
    required BuildContext context,
    required PreferenceSection section, // 섹션 데이터 받기
    required Set<String> selectedOptions,
    required Color chipBackgroundColor,
    required Color selectedChipColor,
    required Color chipTextColor,
    required Color selectedChipTextColor,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      // 각 섹션을 명확히 구분하기 위해 약간의 마진 추가 (선택 사항)
      margin: const EdgeInsets.only(bottom: 30.0),
      child: Column(
        // 섹션 내부 요소들을 중앙 정렬 (질문, 칩 그룹)
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 질문 텍스트
          Text(
            section.question,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center, // 질문 텍스트도 중앙 정렬
          ),
          const SizedBox(height: 15),
          // 선택지 칩 그룹 (Wrap 사용)
          Wrap(
            spacing: 10.0, // 가로 간격
            runSpacing: 10.0, // 세로 간격
            alignment: WrapAlignment.center, // *** 칩들을 중앙 정렬 ***
            children: section.options.map((option) {
              final bool isSelected = selectedOptions.contains(option);
              return ChoiceChip(
                label: Text(option),
                labelStyle: TextStyle(
                  color: isSelected ? selectedChipTextColor : chipTextColor,
                  fontWeight: FontWeight.w500,
                ),
                selected: isSelected,
                onSelected: (selected) {
                  // --- 선택 로직 수정 ---
                  setState(() {
                    final currentSelection = _selectedPreferences[section.key] ?? {};
                    if (section.allowMultipleSelection) {
                      // 다중 선택 허용 섹션
                      if (selected) {
                        currentSelection.add(option);
                      }
                      else {
                        currentSelection.remove(option);
                      }
                    }
                    else {
                      // 단일 선택 섹션
                      currentSelection.clear(); // 기존 선택 모두 해제
                      if (selected) {
                        currentSelection.add(option); // 새로 선택한 것만 추가
                      }
                      // 선택 해제 시 아무것도 선택 안 된 상태 유지
                    }
                    _selectedPreferences[section.key] = currentSelection; // 업데이트된 Set 저장
                  });
                  // --- 선택 로직 수정 끝 ---
                },
                backgroundColor: chipBackgroundColor,
                selectedColor: selectedChipColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide.none, // 테두리 제거
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0), // 패딩 조절
                showCheckmark: false, // 체크마크 숨김
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}