import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/circular_gauge.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../device/controllers/device_controller.dart';
import '../../gamification/controllers/gamification_controller.dart';
import '../../gamification/widgets/flame_badge.dart';
import '../../gamification/widgets/mission_card.dart';
import '../../cleaner/screens/cleaner_screen.dart';
import '../../ram/screens/ram_screen.dart';
import '../../storage/screens/storage_screen.dart';
import '../controllers/home_controller.dart';
import '../widgets/quick_action_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final _device = Get.find<DeviceController>();
  final _gami = Get.find<GamificationController>();
  final _home = Get.find<HomeController>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _device.refreshAll,
          color: AppColors.fireOrange,
          backgroundColor: AppColors.card,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildFlameSection()),
              SliverToBoxAdapter(child: _buildMetrics()),
              SliverToBoxAdapter(child: _buildQuickClean()),
              SliverToBoxAdapter(child: _buildMissions()),
              SliverToBoxAdapter(child: _buildQuickActions()),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (b) => AppColors.fireGradient.createShader(b),
                child: const Text('PURGIFY',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3)),
              ),
              Obx(() => Text(
                    _device.deviceModel.value.isEmpty
                        ? 'Your Device'
                        : _device.deviceModel.value,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  )),
            ],
          ),
          Row(
            children: [
              Obx(() => _buildBatteryChip()),
              const SizedBox(width: 10),
              Container(
                width: 38,
                height: 38,
                decoration: AppColors.glassCard(radius: 12),
                child: const Icon(Icons.settings_outlined,
                    color: AppColors.textSecondary, size: 20),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildBatteryChip() {
    final level = _device.batteryLevel.value;
    final charging = _device.isCharging.value;
    final color = level > 50
        ? AppColors.green
        : level > 20
            ? AppColors.fireYellow
            : AppColors.fireRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: AppColors.glassCard(borderColor: color.withValues(alpha: 0.3), radius: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(charging ? Icons.bolt_rounded : Icons.battery_std_rounded,
              color: color, size: 14),
          const SizedBox(width: 4),
          Text('$level%',
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildFlameSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      padding: const EdgeInsets.all(20),
      decoration: AppColors.glassCard(
        gradient: LinearGradient(
          colors: [
            AppColors.fireOrange.withValues(alpha: 0.12),
            AppColors.fireRed.withValues(alpha: 0.06),
            AppColors.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: AppColors.fireOrange.withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            height: 90,
            child: Lottie.network(
              'https://assets2.lottiefiles.com/packages/lf20_jbbqlzez.json',
              repeat: true,
              errorBuilder: (_, __, ___) => ShaderMask(
                shaderCallback: (b) => AppColors.fireGradient.createShader(b),
                child: const Icon(Icons.local_fire_department_rounded,
                    color: Colors.white, size: 70),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                      '${_home.performanceScore.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        foreground: Paint()
                          ..shader =
                              AppColors.fireGradient.createShader(
                                  const Rect.fromLTWH(0, 0, 200, 80)),
                      ),
                    )),
                Obx(() => Text(
                      _home.performanceLabel,
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    )),
                const SizedBox(height: 10),
                Obx(() => FlameBadge(flameCount: _gami.flameCount)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildMetrics() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppColors.glassCard(),
        child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircularGauge(
                  percent: _device.ramUsedPercent,
                  label: 'RAM',
                  value: '${(_device.ramUsedPercent * 100).round()}%',
                  color: AppColors.purple,
                ),
                Container(
                    width: 0.5, height: 80, color: AppColors.cardBorder),
                CircularGauge(
                  percent: _device.storageUsedPercent,
                  label: 'Storage',
                  value: '${(_device.storageUsedPercent * 100).round()}%',
                  color: AppColors.cyan,
                ),
                Container(
                    width: 0.5, height: 80, color: AppColors.cardBorder),
                CircularGauge(
                  percent: _device.batteryLevel.value / 100,
                  label: 'Battery',
                  value: '${_device.batteryLevel.value}%',
                  color: _device.batteryLevel.value > 50
                      ? AppColors.green
                      : AppColors.fireYellow,
                ),
              ],
            )),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms);
  }

  Widget _buildQuickClean() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Obx(() => GradientButton(
            label: _home.isQuickCleaning.value ? 'Purging...' : '⚡  QUICK PURGE',
            gradient: AppColors.burnGradient,
            height: 64,
            isLoading: _home.isQuickCleaning.value,
            onTap: _home.isQuickCleaning.value ? null : _home.quickClean,
          )),
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildMissions() {
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
                const Text('Daily Missions',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                Obx(() {
                  final completed =
                      _gami.dailyMissions.where((m) => m.isCompleted).length;
                  return Text('$completed/${_gami.dailyMissions.length}',
                      style: const TextStyle(
                          color: AppColors.fireOrange,
                          fontSize: 13,
                          fontWeight: FontWeight.w600));
                }),
              ],
            ),
          ),
          Obx(() => Column(
                children: _gami.dailyMissions
                    .map((m) => MissionCard(mission: m))
                    .toList(),
              )),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms, duration: 500.ms);
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('Quick Actions',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              QuickActionCard(
                label: 'Junk Clean',
                sublabel: 'Remove cache & temp',
                icon: Icons.whatshot_rounded,
                gradient: AppColors.burnGradient,
                onTap: () => Get.to(() => const CleanerScreen()),
                index: 0,
              ),
              QuickActionCard(
                label: 'RAM Boost',
                sublabel: 'Free up memory',
                icon: Icons.bolt_rounded,
                gradient: AppColors.boostGradient,
                onTap: () => Get.to(() => const RamScreen()),
                index: 1,
              ),
              QuickActionCard(
                label: 'Storage',
                sublabel: 'Analyze space usage',
                icon: Icons.pie_chart_rounded,
                gradient: AppColors.cyanGradient,
                onTap: () => Get.to(() => const StorageScreen()),
                index: 2,
              ),
              QuickActionCard(
                label: 'Deep Clean',
                sublabel: 'Full system scan',
                icon: Icons.manage_search_rounded,
                gradient: AppColors.greenGradient,
                onTap: () => Get.to(() => const CleanerScreen()),
                index: 3,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
