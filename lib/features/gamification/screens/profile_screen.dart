import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/gamification_controller.dart';
import '../widgets/achievement_card.dart';
import '../widgets/flame_badge.dart';
import '../widgets/mission_card.dart';
import '../widgets/xp_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gami = Get.find<GamificationController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.background,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildProfileHeader(gami),
                ),
                title: const Text('Profile'),
                titleTextStyle: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
              SliverToBoxAdapter(
                  child: _buildStats(gami)),
              SliverToBoxAdapter(
                  child: _buildAchievements(gami)),
              SliverToBoxAdapter(
                  child: _buildMissions(gami)),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
          // Level up overlay
          _buildLevelUpOverlay(gami),
          // Achievement unlocked overlay
          _buildAchievementOverlay(gami),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(GamificationController gami) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A0800), AppColors.background],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Avatar with fire glow
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.burnGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.fireOrange.withValues(alpha: 0.5),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🔥', style: TextStyle(fontSize: 48)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() => Text(
                  gami.levelTitle,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
                )),
            const SizedBox(height: 6),
            Obx(() => FlameBadge(flameCount: gami.flameCount, size: 22)),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Obx(() => XPBar(
                    currentXP: gami.xp.value,
                    nextLevelXP: gami.xpForNext,
                    progress: gami.levelProgress,
                    levelTitle: gami.levelTitle,
                    level: gami.level.value,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(GamificationController gami) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          _statTile('🔥', 'Streak', Obx(() => Text('${gami.streak.value}d',
              style: const TextStyle(
                  color: AppColors.fireOrange,
                  fontSize: 20,
                  fontWeight: FontWeight.w900)))),
          const SizedBox(width: 12),
          _statTile('🗑️', 'Cleaned',
              Obx(() => Text('${(gami.totalCleanedMB.value / 1024).toStringAsFixed(1)} GB',
                  style: const TextStyle(
                      color: AppColors.cyan,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)))),
          const SizedBox(width: 12),
          _statTile('⚡', 'Boosts',
              Obx(() => Text('${gami.totalBoosted.value}x',
                  style: const TextStyle(
                      color: AppColors.purple,
                      fontSize: 20,
                      fontWeight: FontWeight.w900)))),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _statTile(String icon, String label, Widget value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppColors.glassCard(radius: 16),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            value,
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements(GamificationController gami) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Achievements',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                Obx(() {
                  final unlocked =
                      gami.achievements.where((a) => a.isUnlocked).length;
                  return Text('$unlocked/${gami.achievements.length}',
                      style: const TextStyle(
                          color: AppColors.fireYellow,
                          fontSize: 13,
                          fontWeight: FontWeight.w600));
                }),
              ],
            ),
          ),
          Obx(() => GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
                children: gami.achievements
                    .map((a) => AchievementCard(achievement: a))
                    .toList(),
              )),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildMissions(GamificationController gami) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('Daily Missions',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ),
          Obx(() => Column(
                children: gami.dailyMissions
                    .map((m) => MissionCard(mission: m))
                    .toList(),
              )),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildLevelUpOverlay(GamificationController gami) {
    return Obx(() {
      if (!gami.showLevelUp.value) return const SizedBox.shrink();
      return Positioned.fill(
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(40),
              padding: const EdgeInsets.all(32),
              decoration: AppColors.glassCard(
                gradient: LinearGradient(colors: [
                  AppColors.fireOrange.withValues(alpha: 0.3),
                  AppColors.card,
                ]),
                borderColor: AppColors.fireOrange.withValues(alpha: 0.5),
                radius: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Lottie.network(
                      'https://assets8.lottiefiles.com/packages/lf20_afwjhfyy.json',
                      repeat: false,
                      errorBuilder: (_, __, ___) =>
                          const Text('🏆', style: TextStyle(fontSize: 80)),
                    ),
                  ),
                  const Text('LEVEL UP! 🎉',
                      style: TextStyle(
                          color: AppColors.fireYellow,
                          fontSize: 28,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                        'You are now ${gami.levelTitle}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 16),
                        textAlign: TextAlign.center,
                      )),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).scale(),
        ),
      );
    });
  }

  Widget _buildAchievementOverlay(GamificationController gami) {
    return Obx(() {
      final a = gami.unlockedAchievement.value;
      if (a == null) return const SizedBox.shrink();
      return Positioned(
        top: 100,
        left: 20,
        right: 20,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppColors.glassCard(
            gradient: LinearGradient(colors: [
              AppColors.fireOrange.withValues(alpha: 0.2),
              AppColors.card,
            ]),
            borderColor: AppColors.fireYellow.withValues(alpha: 0.5),
          ),
          child: Row(
            children: [
              Text(a.icon, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Achievement Unlocked! 🔥',
                        style: TextStyle(
                            color: AppColors.fireYellow,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    Text(a.title,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                    Text('+${a.xpReward} XP',
                        style: const TextStyle(
                            color: AppColors.green, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: -0.3, end: 0)
            .then(delay: const Duration(seconds: 3))
            .fadeOut(),
      );
    });
  }
}
