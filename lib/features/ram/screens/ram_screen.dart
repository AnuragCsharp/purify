import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../gamification/controllers/gamification_controller.dart';
import '../controllers/ram_controller.dart';
import '../widgets/process_tile.dart';

class RamScreen extends StatefulWidget {
  const RamScreen({super.key});

  @override
  State<RamScreen> createState() => _RamScreenState();
}

class _RamScreenState extends State<RamScreen>
    with AutomaticKeepAliveClientMixin {
  final _ram = Get.find<RamController>();
  final _gami = Get.find<GamificationController>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('RAM Booster'),
        leading: Get.previousRoute.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: Get.back)
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildRamGauge(),
            const SizedBox(height: 20),
            _buildRamStats(),
            const SizedBox(height: 20),
            _buildBoostResult(),
            const SizedBox(height: 20),
            _buildBoostButton(),
            const SizedBox(height: 24),
            _buildProcessList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRamGauge() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppColors.glassCard(
        gradient: LinearGradient(colors: [
          AppColors.purple.withValues(alpha: 0.15),
          AppColors.card,
        ]),
        borderColor: AppColors.purple.withValues(alpha: 0.3),
      ),
      child: Column(
        children: [
          Obx(() => CircularPercentIndicator(
                radius: 90,
                lineWidth: 14,
                percent: _ram.usedPercent.clamp(0.0, 1.0),
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() => Text(
                          '${(_ram.usedPercent * 100).round()}%',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        )),
                    const Text('Used',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                progressColor: AppColors.purple,
                backgroundColor: AppColors.purple.withValues(alpha: 0.15),
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 1200,
              )),
          const SizedBox(height: 8),
          Obx(() => _ram.isBoosting.value
              ? SizedBox(
                  width: 160,
                  height: 80,
                  child: Lottie.network(
                    'https://assets3.lottiefiles.com/packages/lf20_xlmz9zaz.json',
                    repeat: true,
                    errorBuilder: (_, __, ___) =>
                        const CircularProgressIndicator(
                      color: AppColors.purple,
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildRamStats() {
    return Obx(() => Row(
          children: [
            Expanded(
                child: _statCard('Total RAM',
                    '${_ram.totalRamMB.value ~/ 1024} GB', AppColors.cyan)),
            const SizedBox(width: 12),
            Expanded(
                child: _statCard('Used',
                    '${_ram.usedRamMB.value} MB', AppColors.purple)),
            const SizedBox(width: 12),
            Expanded(
                child: _statCard(
                    'Free', '${_ram.freeRamMB} MB', AppColors.green)),
          ],
        )).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppColors.glassCard(radius: 14),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildBoostResult() {
    return Obx(() {
      if (_ram.boostedMB.value == 0) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: AppColors.glassCard(
          borderColor: AppColors.green.withValues(alpha: 0.4),
          gradient: LinearGradient(colors: [
            AppColors.green.withValues(alpha: 0.1),
            AppColors.card,
          ]),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.green, size: 24),
            const SizedBox(width: 10),
            Text(
              '${_ram.boostedMB.value} MB RAM Freed!',
              style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).scale();
    });
  }

  Widget _buildBoostButton() {
    return Obx(() => GradientButton(
          label: _ram.isBoosting.value ? '⚡ Boosting...' : '⚡  IGNITE BOOST',
          gradient: AppColors.boostGradient,
          height: 64,
          isLoading: _ram.isBoosting.value,
          onTap: _ram.isBoosting.value
              ? null
              : () async {
                  await _ram.boost();
                  _gami.recordBoost();
                },
        )).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildProcessList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Background Processes',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            Obx(() => _ram.isLoadingProcesses.value
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                        color: AppColors.purple, strokeWidth: 2))
                : GestureDetector(
                    onTap: _ram.loadProcesses,
                    child: const Icon(Icons.refresh_rounded,
                        color: AppColors.textSecondary, size: 18))),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (_ram.isLoadingProcesses.value && _ram.processes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: AppColors.purple),
              ),
            );
          }
          if (_ram.processes.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: AppColors.glassCard(radius: 14),
              child: const Center(
                child: Text('No background processes found',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ),
            );
          }
          return Column(
            children: _ram.processes
                .map((p) => ProcessTile(
                    process: p, totalRamMB: _ram.totalRamMB.value))
                .toList(),
          );
        }),
      ],
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }
}
