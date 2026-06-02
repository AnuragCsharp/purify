import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/ram_controller.dart';

class ProcessTile extends StatelessWidget {
  final ProcessInfo process;
  final int totalRamMB;

  const ProcessTile(
      {super.key, required this.process, required this.totalRamMB});

  @override
  Widget build(BuildContext context) {
    final pct = totalRamMB > 0 ? process.ramMB / totalRamMB : 0.0;
    final color = pct > 0.1
        ? AppColors.fireRed
        : pct > 0.05
            ? AppColors.fireOrange
            : AppColors.cyan;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: AppColors.glassCard(radius: 12),
      child: Row(
        children: [
          Text(process.icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      process.name,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${process.ramMB} MB',
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct.clamp(0.0, 1.0),
                    backgroundColor: color.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
