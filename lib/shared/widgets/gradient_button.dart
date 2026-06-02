import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GradientButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Gradient gradient;
  final VoidCallback? onTap;
  final double height;
  final bool isLoading;
  final double fontSize;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.gradient = AppColors.burnGradient,
    this.onTap,
    this.height = 60,
    this.isLoading = false,
    this.fontSize = 16,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.onTap != null ? widget.gradient : null,
            color: widget.onTap == null ? AppColors.card : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.onTap != null
                ? [
                    BoxShadow(
                      color: widget.gradient.colors.first.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widget.fontSize,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
