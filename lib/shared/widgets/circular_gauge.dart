import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/constants/app_colors.dart';

class CircularGauge extends StatelessWidget {
  final double percent;
  final String label;
  final String value;
  final Color color;
  final double radius;

  const CircularGauge({
    super.key,
    required this.percent,
    required this.label,
    required this.value,
    required this.color,
    this.radius = 45,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularPercentIndicator(
          radius: radius,
          lineWidth: 7,
          percent: percent.clamp(0.0, 1.0),
          center: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          progressColor: color,
          backgroundColor: color.withValues(alpha: 0.15),
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animationDuration: 1200,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
