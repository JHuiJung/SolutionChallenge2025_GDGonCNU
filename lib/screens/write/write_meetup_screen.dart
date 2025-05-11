// lib/screens/write_meetup_screen.dart
import 'dart:io'; // File 사용 위해 추가
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
// 모델 임포트 (경로 확인 필요)
import '../../models/meetup_post.dart';

class WriteMeetupScreen extends StatefulWidget {
  const WriteMeetupScreen({super.key});

  @override
  State<WriteMeetupScreen> createState() => _WriteMeetupScreenState();
}

class _WriteMeetupScreenState extends State<WriteMeetupScreen> {
  // 입력 값 저장을 위한 상태 변수
  String? _selectedCategory1;
  String? _selectedCategory2;
  String? _selectedPlace; // TODO: 추후 지도 연동 시 LatLng 등으로 변경
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  String? _selectedPeopleCount;
  XFile? _selectedImage; // 선택된 이미지 파일
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _placeController = TextEditingController(); // 임시 장소 입력용

  bool _isSubmitting = false; // 제출 처리 중 플래그

  // 드롭다운 옵션
  final List<String> _category1Options = ['Activities', 'Food Discovery', 'Photography', 'Relaxation', 'Cultural Exploration', 'Etc'];
  final List<String> _category2Options = ['Nature', 'Cities', 'Both'];
  final List<String> _peopleOptions = [...List.generate(19, (i) => (i + 2).toString()), 'Unlimited']; // 2~20, Unlimited

  final ImagePicker _picker = ImagePicker(); // 이미지 피커 인스턴스

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  // --- Helper Functions for Pickers ---

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(), // 오늘부터 선택 가능
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)), // 향후 2년까지
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTimeRange() async {
    TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? TimeOfDay.now(),
      helpText: 'Select Start Time', // 도움말 텍스트
    );
    if (startTime == null) return; // 시작 시간 선택 취소

    TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? startTime.replacing(hour: startTime.hour + 1), // 시작 시간 + 1시간 기본값
      helpText: 'Select End Time',
    );
    if (endTime != null) {
      // TODO: 종료 시간이 시작 시간보다 빠른 경우 유효성 검사 추가 가능
      setState(() {
        _selectedStartTime = startTime;
        _selectedEndTime = endTime;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } catch (e) {
      print("Image picker error: $e");
      // 사용자에게 오류 메시지 표시 (선택 사항)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image.')),
      );
    }
  }

  // TODO: 장소 선택 기능 구현 (지도 연동)
  void _selectPlace() {
    print('Select Place button tapped (Not implemented)');
    // 임시로 TextField에 포커스 주기
    FocusScope.of(context).requestFocus(FocusNode()); // 다른 포커스 해제 후
    // TextField를 직접 참조할 수 없으므로, 여기서는 간단히 로그만 남김
    // 실제 구현 시에는 Navigator.push로 지도 화면 이동 후 결과 받기
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Map place selection is not implemented yet.')),
    );
  }

  // --- 게시글 제출 함수 ---
  void _submitPost() async {
    // 유효성 검사 (필수 필드 확인 등)
    if (_selectedCategory1 == null ||
        //_placeController.text.trim().isEmpty || // 임시 장소 입력 확인
        _selectedDate == null ||
        _selectedStartTime == null ||
        _selectedEndTime == null ||
        _selectedPeopleCount == null ||
        // _selectedImage == null || // 이미지 필수 여부 확인
        _titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields and select an image.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO: 실제 DB 저장 로직
    // 1. 이미지 업로드 (Firebase Storage 등) -> 업로드된 URL 받기
    // 2. 나머지 데이터와 이미지 URL을 포함하여 DB에 저장 (Firestore 등)

    // 임시 데이터 생성 (DB 저장 시뮬레이션)
    await Future.delayed(const Duration(milliseconds: 800));

    // MeetupPost 객체 생성 (모델 필드 확인 및 조정 필요)
    final newPost = MeetupPost(
      id: 'new_post_${DateTime.now().millisecondsSinceEpoch}', // 임시 ID
      authorId: 'current_user_id', // TODO: 실제 로그인 사용자 ID 가져오기
      authorName: 'Me', // TODO: 실제 로그인 사용자 이름 가져오기
      authorImageUrl: 'https://i.pravatar.cc/150?img=60', // TODO: 실제 사용자 이미지 URL
      // imageUrl: _selectedImage!.path, // 로컬 경로 대신 업로드된 URL 사용해야 함
      imageUrl: 'https://source.unsplash.com/random/800x600/?meetup,event&sig=${DateTime.now().millisecondsSinceEpoch}', // 임시 이미지 URL
      title: _titleController.text.trim(),
      // totalPeople, spotsLeft 계산 로직 필요
      totalPeople: _selectedPeopleCount == 'Unlimited' ? 999 : int.parse(_selectedPeopleCount!),
      spotsLeft: _selectedPeopleCount == 'Unlimited' ? 999 : int.parse(_selectedPeopleCount!), // 초기엔 남은 자리 = 총 인원
      participantImageUrls: [], // 처음엔 참여자 없음
      // --- PostDetailScreen에서 필요한 추가 필드 ---
      categories: [_selectedCategory1!, if (_selectedCategory2 != null) _selectedCategory2!],
      description: _descriptionController.text.trim(),
      eventLocation: _placeController.text.trim(), // 임시 장소
      eventDateTimeString: DateFormat('MMM d, yyyy ・ ').format(_selectedDate!) +
          '${_selectedStartTime!.format(context)} ~ ${_selectedEndTime!.format(context)}',
      authorLocation: 'My City, My Country', // TODO: 실제 사용자 위치
    );

    if (mounted) {
      // 생성된 Post 객체를 이전 화면(MeetupScreen)으로 전달
      Navigator.pop(context, newPost);
    }
    // setState(() => _isSubmitting = false); // pop 후에 실행 안될 수 있음
  }


  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color inputBackgroundColor = colorScheme.brightness == Brightness.light
        ? Colors.grey.shade200.withOpacity(0.8)
        : Colors.grey.shade700.withOpacity(0.8);
    final Color iconColor = colorScheme.onSurface.withOpacity(0.6);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meet up'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0.5,
        actions: [
          // Done 버튼
          TextButton(
            onPressed: _isSubmitting ? null : _submitPost, // 처리 중 비활성화
            child: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
              'Done',
              style: TextStyle(
                color: _isSubmitting ? Colors.grey : colorScheme.primary, // 비활성화 색상
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GestureDetector( // 키보드 숨기기
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 입력 필드들 ---
              _buildInputRow(
                context: context,
                icon: Icons.filter_list,
                label: 'Category1',
                value: _selectedCategory1,
                hint: 'Select Category 1',
                backgroundColor: inputBackgroundColor,
                iconColor: iconColor,
                onTap: () => _showDropdownMenu(context, _category1Options, (val) => setState(() => _selectedCategory1 = val)),
              ),
              _buildInputRow(
                context: context,
                icon: Icons.filter_list,
                label: 'Category2',
                value: _selectedCategory2,
                hint: 'Select Category 2',
                backgroundColor: inputBackgroundColor,
                iconColor: iconColor,
                onTap: () => _showDropdownMenu(context, _category2Options, (val) => setState(() => _selectedCategory2 = val)),
              ),
              // 장소 입력 (임시 TextField)
              _buildInputRowWithTextField(
                context: context,
                icon: Icons.place_outlined,
                label: 'Place',
                controller: _placeController, // 컨트롤러 사용
                hint: 'Enter place name or address',
                backgroundColor: inputBackgroundColor,
                iconColor: iconColor,
                onTapHint: _selectPlace, // 힌트 탭 시 지도 선택 함수 호출
              ),
              _buildInputRow(
                context: context,
                icon: Icons.calendar_today_outlined,
                label: 'Day',
                value: _selectedDate != null ? DateFormat('MMM d, yyyy').format(_selectedDate!) : null,
                hint: 'Select Date',
                backgroundColor: inputBackgroundColor,
                iconColor: iconColor,
                onTap: _pickDate,
              ),
              _buildInputRow(
                context: context,
                icon: Icons.access_time_outlined,
                label: 'Time',
                value: _selectedStartTime != null && _selectedEndTime != null
                    ? '${_selectedStartTime!.format(context)} ~ ${_selectedEndTime!.format(context)}'
                    : null,
                hint: 'Select Time Range',
                backgroundColor: inputBackgroundColor,
                iconColor: iconColor,
                onTap: _pickTimeRange,
              ),
              _buildInputRow(
                context: context,
                icon: Icons.people_outline,
                label: 'People',
                value: _selectedPeopleCount,
                hint: 'Select Headcount',
                backgroundColor: inputBackgroundColor,
                iconColor: iconColor,
                onTap: () => _showDropdownMenu(context, _peopleOptions, (val) => setState(() => _selectedPeopleCount = val)),
              ),
              const SizedBox(height: 20),

              // --- 이미지 선택 영역 ---
              _buildImagePickerSection(context, inputBackgroundColor, iconColor),
              const SizedBox(height: 20),

              // --- 제목 입력 ---
              _buildTitleInput(context, inputBackgroundColor),
              const SizedBox(height: 12),

              // --- 설명 입력 ---
              _buildDescriptionInput(context, inputBackgroundColor),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widget Builders ---

  // 일반적인 입력 행 (드롭다운, 날짜, 시간 등)
  Widget _buildInputRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String? value,
    required String hint,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          SizedBox(
            width: 80, // 라벨 너비 고정 (조절 가능)
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  value ?? hint,
                  style: TextStyle(
                    color: value != null ? Theme.of(context).colorScheme.onSurface : Colors.grey.shade600,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 장소 입력을 위한 행 (TextField 포함)
  Widget _buildInputRowWithTextField({
    required BuildContext context,
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String hint,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTapHint, // 힌트 탭 시 동작
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 1.0), // 내부 패딩 최소화
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
                  hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                ),
                style: const TextStyle(fontSize: 15),
                // 힌트 텍스트 자체를 탭했을 때 동작 추가 (선택 사항)
                onTap: () {
                  if (controller.text.isEmpty) {
                    onTapHint();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }


  // 드롭다운 메뉴 표시 (간단 버전 - BottomSheet 사용)
  void _showDropdownMenu(BuildContext context, List<String> options, ValueChanged<String?> onSelected) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(options[index]),
              onTap: () {
                onSelected(options[index]);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  // 이미지 선택 섹션
  Widget _buildImagePickerSection(BuildContext context, Color backgroundColor, Color iconColor) {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        height: 200, // 높이 지정
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.0),
          // 선택된 이미지가 있으면 이미지 표시, 없으면 플레이스홀더
          image: _selectedImage != null
              ? DecorationImage(
            image: FileImage(File(_selectedImage!.path)),
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: _selectedImage == null
            ? Center( // 이미지 없을 때 플레이스홀더 아이콘/텍스트
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 50, color: iconColor),
              const SizedBox(height: 8),
              Text('Add Cover Photo', style: TextStyle(color: iconColor)),
            ],
          ),
        )
            : Align( // 이미지 있을 때 우측 하단 Edit 버튼
          alignment: Alignment.bottomRight,
          child: Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.edit, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text('edit', style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 제목 입력 필드
  Widget _buildTitleInput(BuildContext context, Color backgroundColor) {
    return Row(
      children: [
        SizedBox(
          width: 80, // 라벨 너비 (조절 가능)
          child: Text('Title', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter title',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
                hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
        ),
      ],
    );
  }

  // 설명 입력 필드
  Widget _buildDescriptionInput(BuildContext context, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TextField(
        controller: _descriptionController,
        decoration: InputDecoration.collapsed( // 기본 장식 제거
          hintText: 'Explain out the event',
          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15),
        ),
        style: const TextStyle(fontSize: 15, height: 1.5),
        maxLines: 8, // 여러 줄 입력, 높이 자동 조절
        minLines: 5, // 최소 높이
        textCapitalization: TextCapitalization.sentences,
        keyboardType: TextInputType.multiline,
      ),
    );
  }
}