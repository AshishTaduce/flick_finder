import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  // Font Family
  static const String fontFamily = 'Inter'; // You can change this to your preferred font

  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // Display Styles - Large titles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    height: 1.12,
    fontWeight: bold,
    fontFamily: fontFamily,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    height: 1.16,
    fontWeight: bold,
    fontFamily: fontFamily,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    height: 1.22,
    fontWeight: bold,
    fontFamily: fontFamily,
  );

  // Headline Styles - Section titles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    height: 1.25,
    fontWeight: bold,
    fontFamily: fontFamily,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    height: 1.29,
    fontWeight: semiBold,
    fontFamily: fontFamily,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    height: 1.33,
    fontWeight: semiBold,
    fontFamily: fontFamily,
  );

  // Title Styles - Card titles, important text
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    height: 1.27,
    fontWeight: semiBold,
    fontFamily: fontFamily,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    height: 1.50,
    fontWeight: medium,
    fontFamily: fontFamily,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    height: 1.43,
    fontWeight: medium,
    fontFamily: fontFamily,
  );

  // Body Styles - Main content text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.50,
    fontWeight: regular,
    fontFamily: fontFamily,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    height: 1.43,
    fontWeight: regular,
    fontFamily: fontFamily,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    height: 1.33,
    fontWeight: regular,
    fontFamily: fontFamily,
  );

  // Label Styles - Buttons, form fields
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    height: 1.43,
    fontWeight: medium,
    fontFamily: fontFamily,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    height: 1.33,
    fontWeight: medium,
    fontFamily: fontFamily,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    height: 1.45,
    fontWeight: medium,
    fontFamily: fontFamily,
  );

  // Custom Styles for Movie App
  static const TextStyle movieTitle = TextStyle(
    fontSize: 20,
    height: 1.2,
    fontWeight: bold,
    fontFamily: fontFamily,
  );

  static const TextStyle movieSubtitle = TextStyle(
    fontSize: 14,
    height: 1.3,
    fontWeight: medium,
    fontFamily: fontFamily,
  );

  static const TextStyle movieDescription = TextStyle(
    fontSize: 13,
    height: 1.4,
    fontWeight: regular,
    fontFamily: fontFamily,
  );

  static const TextStyle tabLabel = TextStyle(
    fontSize: 16,
    height: 1.25,
    fontWeight: semiBold,
    fontFamily: fontFamily,
  );

  static const TextStyle chipLabel = TextStyle(
    fontSize: 12,
    height: 1.33,
    fontWeight: medium,
    fontFamily: fontFamily,
  );

  static const TextStyle rating = TextStyle(
    fontSize: 13,
    height: 1.3,
    fontWeight: semiBold,
    fontFamily: fontFamily,
  );
}