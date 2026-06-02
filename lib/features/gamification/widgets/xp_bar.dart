import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class XPBar extends StatelessWidget {
  final int currentXP;
  final int nextLevelXP;
  final double progress;
  final String levelTitle;
  final int level;

  const XPBar({
    super.key,
    required this.currentXP,
    required this.nextLevelXP,
    required this.progress,
    required this.levelTitle,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppColors.burnGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'LVL $level',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  levelTitle,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Text(
              '$currentXP / $nextLevelXP XP',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: AppColors.burnGradient,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.fireOrange.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
