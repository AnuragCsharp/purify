import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final color = process.killed
        ? AppColors.green
        : pct > 0.08
            ? AppColors.fireRed
            : pct > 0.04
                ? AppColors.fireOrange
                : AppColors.cyan;

    return AnimatedOpacity(
      opacity: process.killed ? 0.45 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: AppColors.glassCard(
          radius: 12,
          borderColor: process.killed
              ? AppColors.green.withValues(alpha: 0.3)
              : null,
        ),
        child: Row(
          children: [
            Text(process.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          process.displayName,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          if (process.killed)
                            const Text('Killed  ',
                                style: TextStyle(
                                    color: AppColors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                          Text(
                            '${process.ramMB} MB',
                            style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: process.killed ? 0.0 : pct.clamp(0.0, 1.0),
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
      ),
    ).animate().fadeIn(duration: 250.ms).slideX(begin: 0.1, end: 0);
  }
}
