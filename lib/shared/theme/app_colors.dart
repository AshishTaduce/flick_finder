import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors - Netflix Red inspired
  static const Color primaryRed = Color(0xFFE50914);
  static const Color primaryRedDark = Color(0xFFB20710);
  static const Color primaryRedLight = Color(0xFFFF4158);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkSurfaceVariant = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF1A1A1A);
  static const Color darkBottomNav = Color(0xFF0F0F0F);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF8F9FA);
  static const Color lightSurfaceVariant = Color(0xFFF1F3F4);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBottomNav = Color(0xFFFFFFFF);

  // Text Colors - Dark Theme
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkTextTertiary = Color(0xFF666666);
  static const Color darkTextDisabled = Color(0xFF404040);

  // Text Colors - Light Theme
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF5F6368);
  static const Color lightTextTertiary = Color(0xFF9AA0A6);
  static const Color lightTextDisabled = Color(0xFFBDC1C6);

  // Accent Colors
  static const Color accent = Color(0xFF00D4AA);
  static const Color accentBlue = Color(0xFF1976D2);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentPurple = Color(0xFF9C27B0);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE50914);
  static const Color info = Color(0xFF2196F3);

  // Rating Colors
  static const Color ratingGold = Color(0xFFFFD700);
  static const Color ratingBorder = Color(0xFF333333);

  // Overlay Colors
  static const Color overlayDark = Color(0x80000000);
  static const Color overlayLight = Color(0x80FFFFFF);
  static const Color shimmer = Color(0xFF2A2A2A);

  // Border Colors
  static const Color borderDark = Color(0xFF333333);
  static const Color borderLight = Color(0xFFE0E0E0);

  // Gradient Colors
  static const List<Color> redGradient = [
    Color(0xFFE50914),
    Color(0xFFB20710),
  ];

  static const List<Color> darkOverlayGradient = [
    Color(0x00000000),
    Color(0x80000000),
    Color(0xFF000000),
  ];
}