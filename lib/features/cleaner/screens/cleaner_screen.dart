import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../gamification/controllers/gamification_controller.dart';
import '../controllers/cleaner_controller.dart';
import '../widgets/junk_item_tile.dart';

class CleanerScreen extends StatefulWidget {
  const CleanerScreen({super.key});

  @override
  State<CleanerScreen> createState() => _CleanerScreenState();
}

class _CleanerScreenState extends State<CleanerScreen>
    with AutomaticKeepAliveClientMixin {
  final _cleaner = Get.find<CleanerController>();
  final _gami = Get.find<GamificationController>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Junk Cleaner'),
        leading: Get.previousRoute.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: Get.back,
              )
            : null,
      ),
      body: Obx(() {
        switch (_cleaner.state.value) {
          case CleanState.idle:
            return _buildIdle();
          case CleanState.scanning:
            return _buildScanning();
          case CleanState.results:
            return _buildResults();
          case CleanState.cleaning:
            return _buildCleaning();
          case CleanState.done:
            return _buildDone();
        }
      }),
    );
  }

  Widget _buildIdle() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Lottie.network(
              'https://assets10.lottiefiles.com/packages/lf20_usmfx6bp.json',
              repeat: true,
              errorBuilder: (_, __, ___) => ShaderMask(
                shaderCallback: (b) => AppColors.burnGradient.createShader(b),
                child: const Icon(Icons.search_rounded,
                    color: Colors.white, size: 100),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Find & Burn Junk Files',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Scan your device for cache, temp\nand residual files',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: GradientButton(
              label: '🔍  START SCAN',
              gradient: AppColors.burnGradient,
              onTap: _cleaner.scan,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildScanning() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: Lottie.network(
              'https://assets10.lottiefiles.com/packages/lf20_usmfx6bp.json',
              repeat: true,
              errorBuilder: (_, __, ___) => const CircularProgressIndicator(
                color: AppColors.fireOrange,
                strokeWidth: 4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Scanning for junk...',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Obx(() => Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _cleaner.scanProgress.value,
                        backgroundColor: AppColors.cardBorder,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.fireOrange),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${(_cleaner.scanProgress.value * 100).round()}% — ${_cleaner.foundItems.length} items found',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _cleaner.scanStatus.value,
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      children: [
        // Header
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: AppColors.glassCard(
            gradient: LinearGradient(colors: [
              AppColors.fireOrange.withValues(alpha: 0.15),
              AppColors.fireRed.withValues(alpha: 0.08),
              AppColors.card,
            ]),
            borderColor: AppColors.fireOrange.withValues(alpha: 0.3),
          ),
          child: Row(
            children: [
              ShaderMask(
                shaderCallback: (b) => AppColors.fireGradient.createShader(b),
                child: const Icon(Icons.local_fire_department_rounded,
                    color: Colors.white, size: 48),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Junk Found!',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          '${_cleaner.totalJunkMB.value.toStringAsFixed(0)} MB can be freed',
                          style: const TextStyle(
                              color: AppColors.fireYellow,
                              fontSize: 22,
                              fontWeight: FontWeight.w900),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
        // Item list
        Expanded(
          child: Obx(() => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _cleaner.foundItems.length,
                itemBuilder: (_, i) => JunkItemTile(
                    item: _cleaner.foundItems[i], index: i),
              )),
        ),
        // Burn button
        Padding(
          padding: const EdgeInsets.all(20),
          child: GradientButton(
            label: '🔥  BURN IT ALL',
            gradient: AppColors.burnGradient,
            height: 64,
            onTap: () async {
              await _cleaner.clean();
              await _gami.recordClean(_cleaner.cleanedMB.value.round());
            },
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildCleaning() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: Lottie.network(
              'https://assets2.lottiefiles.com/packages/lf20_jbbqlzez.json',
              repeat: true,
              errorBuilder: (_, __, ___) => ShaderMask(
                shaderCallback: (b) => AppColors.fireGradient.createShader(b),
                child: const Icon(Icons.local_fire_department_rounded,
                    color: Colors.white, size: 140),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Incinerating Junk...',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Obx(() => Text(
                '${_cleaner.cleanedMB.value.toStringAsFixed(0)} MB burned',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  foreground: Paint()
                    ..shader = AppColors.fireGradient.createShader(
                        const Rect.fromLTWH(0, 0, 300, 80)),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDone() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: Lottie.network(
              'https://assets4.lottiefiles.com/packages/lf20_jbrw3hcz.json',
              repeat: false,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.check_circle_rounded,
                color: AppColors.green,
                size: 120,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Done! 🔥',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Obx(() => Text(
                '${_cleaner.cleanedMB.value.toStringAsFixed(0)} MB Freed',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  foreground: Paint()
                    ..shader = AppColors.greenGradient.createShader(
                        const Rect.fromLTWH(0, 0, 300, 80)),
                ),
              )),
          const SizedBox(height: 8),
          const Text('+50 XP Earned',
              style: TextStyle(
                  color: AppColors.fireYellow,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: GradientButton(
              label: 'CLEAN AGAIN',
              gradient: AppColors.burnGradient,
              onTap: _cleaner.reset,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }
}
