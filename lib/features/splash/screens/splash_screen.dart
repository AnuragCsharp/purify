import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_colors.dart';
import '../../main/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fireController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _fireController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2));
    _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000),
        lowerBound: 0.95,
        upperBound: 1.05)
      ..repeat(reverse: true);

    _fireController.forward();
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Get.off(() => const MainScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 600));
      }
    });
  }

  @override
  void dispose() {
    _fireController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Color(0xFF1A0A00),
                  AppColors.background,
                ],
              ),
            ),
          ),
          // Glowing circle behind logo
          Center(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.fireOrange.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Fire Lottie animation
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Lottie.network(
                    'https://assets2.lottiefiles.com/packages/lf20_jbbqlzez.json',
                    controller: _fireController,
                    onLoaded: (comp) {
                      _fireController
                        ..duration = comp.duration
                        ..forward();
                    },
                    errorBuilder: (_, __, ___) => _buildFallbackFire(),
                  ),
                ),
                const SizedBox(height: 24),
                // App Name with fire gradient
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.fireGradient.createShader(bounds),
                  child: const Text(
                    'PURGIFY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 800.ms)
                    .slideY(begin: 0.3, end: 0, delay: 600.ms, duration: 600.ms),
                const SizedBox(height: 10),
                const Text(
                  'Burn the junk. Own the speed.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 600.ms),
                const SizedBox(height: 60),
                // Loading dots
                _LoadingDots()
                    .animate()
                    .fadeIn(delay: 1200.ms, duration: 500.ms),
              ],
            ),
          ),
          // Version tag bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: const Text(
              'v1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textHint, fontSize: 12),
            ).animate().fadeIn(delay: 1500.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackFire() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) => Transform.scale(
        scale: _pulseController.value,
        child: ShaderMask(
          shaderCallback: (b) => AppColors.fireGradient.createShader(b),
          child: const Icon(
            Icons.local_fire_department_rounded,
            size: 100,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
              vsync: this, duration: const Duration(milliseconds: 600))
          ..repeat(reverse: true),
    );
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.fireOrange
                  .withValues(alpha: 0.4 + _controllers[i].value * 0.6),
            ),
          ),
        );
      }),
    );
  }
}
