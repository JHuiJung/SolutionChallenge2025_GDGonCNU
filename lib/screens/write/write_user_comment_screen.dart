// lib/screens/write_user_comment_screen.dart
import 'package:flutter/material.dart';

class WriteUserCommentScreen extends StatefulWidget {
  const WriteUserCommentScreen({super.key});

  @override
  State<WriteUserCommentScreen> createState() => _WriteUserCommentScreenState();
}

class _WriteUserCommentScreenState extends State<WriteUserCommentScreen> {
  String? _targetUserId;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false; // 제출 처리 중 플래그

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        _targetUserId = ModalRoute.of(context)?.settings.arguments as String;
        setState(() {}); // AppBar 제목 업데이트 위해
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // 코멘트 제출 함수
  void _submitComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty || _isSubmitting) {
      // 내용이 없거나 이미 제출 중이면 아무것도 안 함
      return;
    }

    setState(() => _isSubmitting = true); // 제출 시작

    // TODO: 실제 DB에 코멘트 저장 로직 (targetUserId 사용)
    print('Submitting comment for user $_targetUserId: $commentText');
    await Future.delayed(const Duration(milliseconds: 500)); // DB 저장 시뮬레이션

    // DB 저장 성공 시, 작성된 코멘트 텍스트를 이전 화면으로 반환
    if (mounted) {
      Navigator.pop(context, commentText);
    }
    // _isSubmitting = false; // pop 후에 실행 안될 수 있음
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color textFieldBackgroundColor = colorScheme.brightness == Brightness.light
        ? Colors.grey.shade200 // 밝은 모드 배경
        : Colors.grey.shade700; // 어두운 모드 배경

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comment'), // 고정 제목
        backgroundColor: colorScheme.surface, // 배경색
        foregroundColor: colorScheme.onSurface, // 아이콘/텍스트 색상
        elevation: 0.5, // 약간의 구분선 효과
        // 완료 버튼 추가
        actions: [
          TextButton(
            onPressed: _submitComment, // 제출 함수 연결
            child: _isSubmitting
                ? const SizedBox( // 로딩 인디케이터
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Text(
              'Done',
              style: TextStyle(
                color: colorScheme.primary, // 완료 버튼 색상
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8), // 오른쪽 여백
        ],
      ),
      body: GestureDetector( // 화면 다른 곳 탭 시 키보드 숨기기
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView( // 키보드 올라올 때 스크롤 가능하도록
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _commentController,
            autofocus: true, // 화면 진입 시 자동 포커스
            maxLines: null, // 여러 줄 입력 가능
            minLines: 8, // 초기 높이 확보 (조절 가능)
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline, // 엔터키로 줄바꿈
            decoration: InputDecoration(
              hintText: 'Write your comment here...',
              filled: true,
              fillColor: textFieldBackgroundColor, // 배경색 적용
              border: OutlineInputBorder( // 테두리 설정
                borderRadius: BorderRadius.circular(12.0), // 둥근 모서리
                borderSide: BorderSide.none, // 테두리 선 없음
              ),
              contentPadding: const EdgeInsets.all(16.0), // 내부 패딩
            ),
          ),
        ),
      ),
    );
  }
}