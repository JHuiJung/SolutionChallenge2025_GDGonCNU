// lib/widgets/language_indicator.dart
import 'package:flutter/material.dart';

class LanguageIndicator extends StatelessWidget {
  final int proficiency; // 1 ~ 5
  final int maxProficiency;
  final double dotSize;
  final Color activeColor;
  final Color inactiveColor;

  const LanguageIndicator({
    super.key,
    required this.proficiency,
    this.maxProficiency = 5,
    this.dotSize = 8.0,
    this.activeColor = Colors.black,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // 필요한 만큼만 너비 차지
      children: List.generate(maxProficiency, (index) {
        return Container(
          width: dotSize,
          height: dotSize,
          margin: EdgeInsets.only(left: index == 0 ? 0 : dotSize / 2), // 점 사이 간격
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < proficiency ? activeColor : inactiveColor,
          ),
        );
      }),
    );
  }
}