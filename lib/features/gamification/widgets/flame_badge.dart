import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

class FlameBadge extends StatelessWidget {
  final int flameCount;
  final double size;

  const FlameBadge({super.key, required this.flameCount, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final active = i < flameCount;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: ShaderMask(
            shaderCallback: (bounds) => (active
                    ? AppColors.fireGradient
                    : const LinearGradient(
                        colors: [Color(0xFF2A2A3A), Color(0xFF1E1E2E)]))
                .createShader(bounds),
            child: Icon(
              Icons.local_fire_department_rounded,
              size: size,
              color: Colors.white,
            ),
          )
              .animate(delay: Duration(milliseconds: i * 80))
              .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 400.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 300.ms),
        );
      }),
    );
  }
}
