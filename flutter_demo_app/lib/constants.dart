import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color accentBlue =
      Color(0xFF2F80ED); // used by location_screen.dart
  static const Color lightBlueBg = Color(0xFFDCEBFB);
  static const Color paleBlueBg = Color(0xFFEFF6FC);

  static const Color safeGreen = Color(0xFF22A559);
  static const Color safeGreenLight = Color(0xFFE3F6EA);

  static const Color actionBlueBg = Color(0xFFE3EEFC);
  static const Color actionGreenBg = Color(0xFFE3F6EA);
  static const Color actionPurpleBg = Color(0xFFF1E9FB);
  static const Color actionPurple = Color(0xFF9B7FD4);

  static const Color textDark = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF6B7280);

  static const Color cardWhite = Colors.white;
  static const Color dangerRed = Colors.redAccent;
  static const Color dangerRedBg = Color(0xFFFDECEC);

  // Landing screen accents
  static const Color accentOrange = Color(0xFFF2643B);
  static const Color accentOrangeBg = Color(0xFFFDEBE3);
  static const Color ctaNavy = Color(0xFF0F1B2E);
}

class AppStrings {
  static const String appName = 'PET ZONE';
  static const String deviceName = 'Pet Tracker Collar';
}

// Shared card shadow used across screens (location_screen.dart, etc.)
final List<BoxShadow> cardShadowList = [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    blurRadius: 12,
    offset: const Offset(0, 4),
  ),
];

class AppGradients {
  static const LinearGradient loginBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE3F6EA), Color(0xFFFFFDE7)],
  );

  static const LinearGradient loginButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF22A559), Color(0xFFB7C94A)],
  );

  static const LinearGradient logoBadge = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22A559), Color(0xFF1E3A8A)],
  );
}
