import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/mission.dart';

class MissionCard extends StatelessWidget {
  final Mission mission;

  const MissionCard({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppColors.glassCard(
        borderColor: mission.isCompleted
            ? AppColors.green.withValues(alpha: 0.4)
            : null,
        radius: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: mission.isCompleted
                  ? AppColors.greenGradient
                  : AppColors.burnGradient,
            ),
            child: Center(
              child: Text(mission.icon, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      mission.title,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.fireYellow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '+${mission.xpReward} XP',
                        style: const TextStyle(
                            color: AppColors.fireYellow,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: mission.progressPercent,
                    backgroundColor: AppColors.cardBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      mission.isCompleted
                          ? AppColors.green
                          : AppColors.fireOrange,
                    ),
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mission.isCompleted
                      ? '✅ Completed!'
                      : mission.description,
                  style: TextStyle(
                    color: mission.isCompleted
                        ? AppColors.green
                        : AppColors.textSecondary,
                    fontSize: 11,
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
