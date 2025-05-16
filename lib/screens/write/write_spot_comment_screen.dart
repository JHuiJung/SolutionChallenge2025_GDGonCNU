// lib/screens/write_spot_comment_screen.dart
import 'package:flutter/material.dart';

class WriteSpotCommentScreen extends StatefulWidget {
  const WriteSpotCommentScreen({super.key});

  @override
  State<WriteSpotCommentScreen> createState() => _WriteSpotCommentScreenState();
}

class _WriteSpotCommentScreenState extends State<WriteSpotCommentScreen> {
  String? _targetPostId; // 대상 게시글 ID
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        _targetPostId = ModalRoute.of(context)?.settings.arguments as String;
        setState(() {});
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
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO: 실제 DB에 코멘트 저장 로직 (targetPostId 사용)
    print('Submitting comment for post $_targetPostId: $commentText');
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pop(context, commentText); // 작성된 코멘트 텍스트 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color textFieldBackgroundColor = colorScheme.brightness == Brightness.light
        ? Colors.grey.shade200
        : Colors.grey.shade700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comment'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0.5,
        actions: [
          TextButton(
            onPressed: _submitComment,
            child: _isSubmitting
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Text(
              'Done',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
          child: TextField(
            controller: _commentController,
            autofocus: true,
            maxLines: null,
            minLines: 8,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: 'Write your comment here...',
              filled: true,
              fillColor: textFieldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16.0),
            ),
          ),
        ),
      ),
    );
  }
}