import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../models/achievement.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;
    return Container(
      decoration: AppColors.glassCard(
        gradient: unlocked
            ? LinearGradient(
                colors: [
                  AppColors.fireOrange.withValues(alpha: 0.2),
                  AppColors.fireRed.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderColor: unlocked ? AppColors.fireOrange.withValues(alpha: 0.4) : null,
        radius: 16,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: unlocked
                      ? AppColors.burnGradient
                      : const LinearGradient(
                          colors: [Color(0xFF1E1E2E), Color(0xFF2A2A3A)]),
                ),
                child: Center(
                  child: Text(achievement.icon,
                      style: TextStyle(fontSize: unlocked ? 24 : 20)),
                ),
              ),
              if (!unlocked)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                  child: const Icon(Icons.lock_rounded,
                      color: AppColors.textHint, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            style: TextStyle(
              color: unlocked ? AppColors.textPrimary : AppColors.textHint,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (unlocked) ...[
            const SizedBox(height: 4),
            Text(
              '+${achievement.xpReward} XP',
              style: const TextStyle(
                  color: AppColors.fireYellow,
                  fontSize: 10,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    ).animate(target: unlocked ? 1 : 0).shimmer(
          duration: 1500.ms,
          color: AppColors.fireOrange.withValues(alpha: 0.3),
        );
  }
}
