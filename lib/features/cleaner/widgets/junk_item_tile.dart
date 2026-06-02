import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../models/junk_item.dart';

class JunkItemTile extends StatelessWidget {
  final JunkItem item;
  final int index;

  const JunkItemTile({super.key, required this.item, required this.index});

  Color _categoryColor() {
    switch (item.category) {
      case 'Cache':
        return AppColors.cyan;
      case 'Temp':
        return AppColors.fireOrange;
      case 'Residual':
        return AppColors.fireMid;
      case 'Media':
        return AppColors.purple;
      case 'Logs':
        return AppColors.textSecondary;
      case 'APK':
        return AppColors.fireYellow;
      case 'Ads':
        return AppColors.fireRed;
      default:
        return AppColors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppColors.glassCard(radius: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: color.withValues(alpha: 0.3), width: 0.8),
            ),
            child:
                Center(child: Text(item.icon, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  item.category,
                  style: TextStyle(color: color, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            item.sizeLabel,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.3, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }
}
