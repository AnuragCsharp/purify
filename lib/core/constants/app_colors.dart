import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF08090F);
  static const Color surface = Color(0xFF10121E);
  static const Color card = Color(0xFF161926);
  static const Color navBar = Color(0xFF0D0F1A);
  static const Color cardBorder = Color(0xFF252840);

  static const Color fireRed = Color(0xFFFF1744);
  static const Color fireOrange = Color(0xFFFF4500);
  static const Color fireMid = Color(0xFFFF6B35);
  static const Color fireYellow = Color(0xFFFFD700);
  static const Color fireGold = Color(0xFFFFA500);

  static const Color cyan = Color(0xFF00D2FF);
  static const Color purple = Color(0xFF7B2FFF);
  static const Color green = Color(0xFF00E676);
  static const Color blue = Color(0xFF0072FF);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9DB2CE);
  static const Color textHint = Color(0xFF4A5568);

  static const LinearGradient fireGradient = LinearGradient(
    colors: [fireRed, fireOrange, fireYellow],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static const LinearGradient burnGradient = LinearGradient(
    colors: [fireRed, fireMid],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static const LinearGradient boostGradient = LinearGradient(
    colors: [Color(0xFF7B2FFF), Color(0xFFB24BF3)],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF0072FF), Color(0xFF00D2FF)],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF00B09B), Color(0xFF00E676)],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1D2E), Color(0xFF141727)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration glassCard({
    Gradient? gradient,
    Color? borderColor,
    double radius = 20,
  }) =>
      BoxDecoration(
        gradient: gradient ?? cardGradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? cardBorder,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      );
}
