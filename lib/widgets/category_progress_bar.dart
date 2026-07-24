import 'package:flutter/material.dart';

/// Bir kategorinin öğrenilme yüzdesini gösteren ince ilerleme çubuğu.
class CategoryProgressBar extends StatelessWidget {
  const CategoryProgressBar({
    super.key,
    required this.category,
    required this.progress,
  });

  final String category;

  /// 0.0 - 1.0 arası tamamlanma oranı.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(category),
            Text('%$percentage'),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
