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
      width: double.infinity, // Fill parent width
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
              fontWeight: FontWeight.w500, // Content text also slightly bold
              height: 1.4, // Line spacing
            ),
          ),
          const SizedBox(height: 8),
          // Bottom purple line
          Container(
            height: 2,
            color: borderColor,
          ),
        ],
      ),
    );
  }
}