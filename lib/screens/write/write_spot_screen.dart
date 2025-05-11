// lib/screens/write_spot_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/spot_detail_model.dart';
import '../../models/comment_model.dart'; // CommentModel 임포트

class WriteSpotScreen extends StatefulWidget {
  const WriteSpotScreen({super.key});

  @override
  State<WriteSpotScreen> createState() => _WriteSpotScreenState();
}

class _WriteSpotScreenState extends State<WriteSpotScreen> {
  // 입력 값 저장을 위한 상태 변수 및 컨트롤러
  String? _selectedPlaceName; // 장소 이름 (지도 검색 결과)
  String? _selectedPlaceLocation; // 장소 주소/위치 텍스트 (지도 검색 결과)
  // LatLng? _selectedCoordinates; // TODO: 지도 검색 결과 좌표
  XFile? _selectedImage;
  final TextEditingController _quoteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _recommendToController = TextEditingController();
  final TextEditingController _canEnjoyController = TextEditingController();
  // 임시 장소 검색 컨트롤러 (지도 연동 전)
  final TextEditingController _placeSearchController = TextEditingController();


  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _quoteController.dispose();
    _descriptionController.dispose();
    _recommendToController.dispose();
    _canEnjoyController.dispose();
    _placeSearchController.dispose();
    super.dispose();
  }

  // --- 이미지 선택 ---
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() { _selectedImage = pickedFile; });
      }
    } catch (e) {
      print("Image picker error: $e");
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Failed to pick image.')));
      }
    }
  }

  // --- 장소 선택 (Placeholder) ---
  Future<void> _selectPlaceFromMap() async {
    print('Select Place from Map tapped (Not implemented)');
    // TODO: Navigator.push로 지도 검색/선택 화면으로 이동하고 결과(이름, 위치, 좌표) 받아오기
    // 임시로 사용자 입력 사용
    await showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("Select Place (Temporary)"),
      content: TextField(
        controller: _placeSearchController,
        decoration: InputDecoration(hintText: "Enter Place Name, Location"),
      ),
      actions: [
        TextButton(onPressed: (){
          // 임시로 입력값을 이름과 위치로 사용
          List<String> parts = _placeSearchController.text.split(',');
          if (parts.isNotEmpty) {
            setState(() {
              _selectedPlaceName = parts[0].trim();
              _selectedPlaceLocation = parts.length > 1 ? parts.sublist(1).join(',').trim() : parts[0].trim();
            });
          }
          _placeSearchController.clear();
          Navigator.pop(context);
        }, child: Text("OK"))
      ],
    ));
    FocusScope.of(context).unfocus(); // 다이얼로그 닫힐 때 키보드 숨기기
  }

  // --- 글 제출 ---
  void _submitSpot() async {
    // 유효성 검사
    if (_selectedPlaceName == null || _selectedPlaceLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a place.')));
      return;
    }
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add an image.')));
      return;
    }
    if (_quoteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please write a one-sentence description.')));
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please explain about the place.')));
      return;
    }
    if (_recommendToController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please write down recommendations.')));
      return;
    }
    if (_canEnjoyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please write down what can be enjoyed.')));
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO: 이미지 업로드 및 DB 저장 로직
    await Future.delayed(const Duration(milliseconds: 800)); // 시뮬레이션

    // SpotDetailModel 객체 생성
    final newSpot = SpotDetailModel(
      id: 'spot_${DateTime.now().millisecondsSinceEpoch}', // 임시 ID
      name: _selectedPlaceName!,
      location: _selectedPlaceLocation!,
      // imageUrl: _selectedImage!.path, // 로컬 경로 대신 업로드 URL 사용
      imageUrl: 'https://source.unsplash.com/random/800x600/?travel,landmark&sig=${DateTime.now().millisecondsSinceEpoch}', // 임시 URL
      quote: _quoteController.text.trim(),
      authorId: 'current_user_id', // TODO: 실제 사용자 ID
      authorName: 'Me', // TODO: 실제 사용자 이름
      authorImageUrl: 'https://i.pravatar.cc/150?img=60', // TODO: 실제 사용자 이미지
      description: _descriptionController.text.trim(),
      recommendTo: _recommendToController.text.trim(),
      canEnjoy: _canEnjoyController.text.trim(),
      comments: [], // 처음엔 코멘트 없음
    );

    if (mounted) {
      Navigator.pop(context, newSpot); // 생성된 객체 반환
    }
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
        title: const Text('Explore'), // 고정 제목
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0.5,
        actions: [
          // Done 버튼
          TextButton(
            onPressed: _isSubmitting ? null : _submitSpot,
            child: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
              'Done',
              style: TextStyle(
                color: _isSubmitting ? Colors.grey : colorScheme.primary,
                fontWeight: FontWeight.bold, fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Place 입력 ---
              _buildPlaceInput(context, inputBackgroundColor, iconColor),
              const SizedBox(height: 16),

              // --- 이미지 선택 ---
              _buildImagePickerSection(context, inputBackgroundColor, iconColor),
              const SizedBox(height: 20),

              // --- Introduction 입력 ---
              Text('Introduction', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              _buildTextFieldInput(
                context: context,
                controller: _quoteController,
                hint: 'Describe with one sentence.',
                backgroundColor: inputBackgroundColor,
                maxLines: 1, // 한 줄 입력
              ),
              const SizedBox(height: 12),
              _buildTextFieldInput(
                context: context,
                controller: _descriptionController,
                hint: 'Explain about the place.',
                backgroundColor: inputBackgroundColor,
                minLines: 4, // 여러 줄 입력
                maxLines: null,
              ),
              const SizedBox(height: 24),

              // --- Recommend to 입력 ---
              Text('Recommend to', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              _buildTextFieldInput(
                context: context,
                controller: _recommendToController,
                hint: 'Write down whom do you recommend.',
                backgroundColor: inputBackgroundColor,
                maxLines: 1,
              ),
              const SizedBox(height: 20),

              // --- You can enjoy 입력 ---
              Text('You can enjoy', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              _buildTextFieldInput(
                context: context,
                controller: _canEnjoyController,
                hint: 'Write down what you can do in this place.',
                backgroundColor: inputBackgroundColor,
                minLines: 2, // 여러 줄 입력 가능
                maxLines: null,
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widget Builders ---

  // 장소 입력 행
  Widget _buildPlaceInput(BuildContext context, Color backgroundColor, Color iconColor) {
    final placeText = _selectedPlaceName ?? 'search on the google map';
    final isHint = _selectedPlaceName == null;

    return Row(
      children: [
        Text('Place', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: _selectPlaceFromMap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(25.0), // 둥근 모서리
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      placeText,
                      style: TextStyle(
                        color: isHint ? Colors.grey.shade600 : Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.search, color: iconColor, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 이미지 선택 섹션 (기존과 유사)
  Widget _buildImagePickerSection(BuildContext context, Color backgroundColor, Color iconColor) {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.0),
          image: _selectedImage != null
              ? DecorationImage(image: FileImage(File(_selectedImage!.path)), fit: BoxFit.cover)
              : null,
        ),
        child: _selectedImage == null
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_photo_alternate_outlined, size: 50, color: iconColor), const SizedBox(height: 8), Text('Add Cover Photo', style: TextStyle(color: iconColor))]))
            : Align(alignment: Alignment.bottomRight, child: Container(margin: const EdgeInsets.all(8.0), padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0), decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(10.0)), child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.edit, color: Colors.white, size: 14), SizedBox(width: 4), Text('edit', style: TextStyle(color: Colors.white, fontSize: 12))]))),
      ),
    );
  }

  // 일반적인 텍스트 입력 필드
  Widget _buildTextFieldInput({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required Color backgroundColor,
    int? minLines = 1,
    int? maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 1.0), // 최소화
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
        style: const TextStyle(fontSize: 15, height: 1.4), // 줄간격 추가
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: maxLines == 1 ? keyboardType : TextInputType.multiline, // 여러 줄 입력 시 타입 변경
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }
}