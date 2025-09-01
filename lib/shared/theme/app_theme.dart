import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_insets.dart';

class AppTheme {
  AppTheme._();

  // Dark Theme
  static ThemeData get darkTheme {
    const ColorScheme darkColorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.primaryRed,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryRedDark,
      onPrimaryContainer: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.black,
      secondaryContainer: AppColors.darkSurfaceVariant,
      onSecondaryContainer: AppColors.darkTextSecondary,
      tertiary: AppColors.accentBlue,
      onTertiary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerHighest: AppColors.darkSurfaceVariant,
      onSurfaceVariant: AppColors.darkTextSecondary,
      outline: AppColors.borderDark,
      outlineVariant: AppColors.darkTextTertiary,
      shadow: Colors.black,
      scrim: AppColors.overlayDark,
      inverseSurface: AppColors.lightSurface,
      onInverseSurface: AppColors.lightTextPrimary,
      inversePrimary: AppColors.primaryRedLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      fontFamily: AppTypography.fontFamily,

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.darkTextPrimary),
        displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.darkTextPrimary),
        displaySmall: AppTypography.displaySmall.copyWith(color: AppColors.darkTextPrimary),
        headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.darkTextPrimary),
        headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.darkTextPrimary),
        headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.darkTextPrimary),
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.darkTextPrimary),
        titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.darkTextPrimary),
        titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.darkTextPrimary),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.darkTextSecondary),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.darkTextTertiary),
        labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.darkTextPrimary),
        labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.darkTextSecondary),
        labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.darkTextTertiary),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: AppInsets.elevationSm,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: AppInsets.movieCardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: AppInsets.borderRadiusMd,
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkBottomNav,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: AppColors.darkTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: AppInsets.elevationLg,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(
          fontWeight: AppTypography.semiBold,
        ),
        unselectedLabelStyle: AppTypography.labelSmall,
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.darkTextPrimary,
        unselectedLabelColor: AppColors.darkTextSecondary,
        labelStyle: AppTypography.tabLabel,
        unselectedLabelStyle: AppTypography.tabLabel.copyWith(
          fontWeight: AppTypography.medium,
        ),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.primaryRed,
            width: 3,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          elevation: AppInsets.elevationSm,
          padding: AppInsets.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppInsets.borderRadiusSm,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTextPrimary,
          side: const BorderSide(color: AppColors.borderDark),
          padding: AppInsets.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppInsets.borderRadiusSm,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryRed,
          padding: AppInsets.buttonPaddingSmall,
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        selectedColor: AppColors.primaryRed,
        labelStyle: AppTypography.chipLabel.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        padding: AppInsets.chipPadding,
        shape: RoundedRectangleBorder(
          borderRadius: AppInsets.borderRadiusXxl,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: AppInsets.borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppInsets.borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppInsets.borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkTextTertiary,
        ),
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.darkBackground,

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 0.5,
      ),
    );
  }

  // Light Theme
  static ThemeData get lightTheme {
    const ColorScheme lightColorScheme = ColorScheme.light(
      brightness: Brightness.light,
      primary: AppColors.primaryRed,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryRedLight,
      onPrimaryContainer: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.lightSurfaceVariant,
      onSecondaryContainer: AppColors.lightTextSecondary,
      tertiary: AppColors.accentBlue,
      onTertiary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),
      surface: AppColors.lightBackground,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerHighest: AppColors.lightSurfaceVariant,
      onSurfaceVariant: AppColors.lightTextSecondary,
      outline: AppColors.borderLight,
      outlineVariant: AppColors.lightTextTertiary,
      shadow: Colors.black26,
      scrim: AppColors.overlayLight,
      inverseSurface: AppColors.darkSurface,
      onInverseSurface: AppColors.darkTextPrimary,
      inversePrimary: AppColors.primaryRedDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      fontFamily: AppTypography.fontFamily,

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.lightTextPrimary),
        displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.lightTextPrimary),
        displaySmall: AppTypography.displaySmall.copyWith(color: AppColors.lightTextPrimary),
        headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.lightTextPrimary),
        headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.lightTextPrimary),
        headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.lightTextPrimary),
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.lightTextPrimary),
        titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.lightTextPrimary),
        titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.lightTextPrimary),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.lightTextSecondary),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.lightTextSecondary),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.lightTextTertiary),
        labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.lightTextPrimary),
        labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.lightTextSecondary),
        labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.lightTextTertiary),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: AppInsets.elevationSm,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: AppInsets.movieCardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: AppInsets.borderRadiusMd,
        ),
        clipBehavior: Clip.antiAlias,
        shadowColor: Colors.black26,
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightBottomNav,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: AppColors.lightTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: AppInsets.elevationLg,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(
          fontWeight: AppTypography.semiBold,
        ),
        unselectedLabelStyle: AppTypography.labelSmall,
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.lightTextPrimary,
        unselectedLabelColor: AppColors.lightTextSecondary,
        labelStyle: AppTypography.tabLabel,
        unselectedLabelStyle: AppTypography.tabLabel.copyWith(
          fontWeight: AppTypography.medium,
        ),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.primaryRed,
            width: 3,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          elevation: AppInsets.elevationSm,
          padding: AppInsets.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppInsets.borderRadiusSm,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightTextPrimary,
          side: const BorderSide(color: AppColors.borderLight),
          padding: AppInsets.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppInsets.borderRadiusSm,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryRed,
          padding: AppInsets.buttonPaddingSmall,
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurfaceVariant,
        selectedColor: AppColors.primaryRed,
        labelStyle: AppTypography.chipLabel.copyWith(
          color: AppColors.lightTextSecondary,
        ),
        padding: AppInsets.chipPadding,
        shape: RoundedRectangleBorder(
          borderRadius: AppInsets.borderRadiusXxl,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: AppInsets.borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppInsets.borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppInsets.borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.lightTextSecondary,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.lightTextTertiary,
        ),
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.lightBackground,

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 0.5,
      ),
    );
  }
}