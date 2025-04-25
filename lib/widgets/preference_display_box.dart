// lib/widgets/preference_display_box.dart
import 'package:flutter/material.dart';

class PreferenceDisplayBox extends StatelessWidget {
  final String title;
  final String content;
  final Color backgroundColor;
  final Color titleColor;
  final Color contentColor;
  final Color borderColor;

  const PreferenceDisplayBox({
    super.key,
    required this.title,
    required this.content,
    required this.backgroundColor,
    required this.titleColor,
    required this.contentColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // 부모 너비 채우기
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: titleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: contentColor,
              fontWeight: FontWeight.w500, // 내용 텍스트도 약간 굵게
              height: 1.4, // 줄 간격
            ),
          ),
          const SizedBox(height: 8),
          // 하단 보라색 선
          Container(
            height: 2,
            color: borderColor,
          ),
        ],
      ),
    );
  }
}