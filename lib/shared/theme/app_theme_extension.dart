import 'package:flutter/material.dart';
import 'app_colors.dart';

@immutable
class MovieThemeExtension extends ThemeExtension<MovieThemeExtension> {
  const MovieThemeExtension({
    required this.movieCardGradient,
    required this.ratingStarColor,
    required this.genreChipColor,
    required this.watchButtonGradient,
    required this.heroImageOverlay,
  });

  final Gradient movieCardGradient;
  final Color ratingStarColor;
  final Color genreChipColor;
  final Gradient watchButtonGradient;
  final Gradient heroImageOverlay;

  @override
  MovieThemeExtension copyWith({
    Gradient? movieCardGradient,
    Color? ratingStarColor,
    Color? genreChipColor,
    Gradient? watchButtonGradient,
    Gradient? heroImageOverlay,
  }) {
    return MovieThemeExtension(
      movieCardGradient: movieCardGradient ?? this.movieCardGradient,
      ratingStarColor: ratingStarColor ?? this.ratingStarColor,
      genreChipColor: genreChipColor ?? this.genreChipColor,
      watchButtonGradient: watchButtonGradient ?? this.watchButtonGradient,
      heroImageOverlay: heroImageOverlay ?? this.heroImageOverlay,
    );
  }

  @override
  MovieThemeExtension lerp(ThemeExtension<MovieThemeExtension>? other, double t) {
    if (other is! MovieThemeExtension) {
      return this;
    }
    return MovieThemeExtension(
      movieCardGradient: Gradient.lerp(movieCardGradient, other.movieCardGradient, t) ?? movieCardGradient,
      ratingStarColor: Color.lerp(ratingStarColor, other.ratingStarColor, t) ?? ratingStarColor,
      genreChipColor: Color.lerp(genreChipColor, other.genreChipColor, t) ?? genreChipColor,
      watchButtonGradient: Gradient.lerp(watchButtonGradient, other.watchButtonGradient, t) ?? watchButtonGradient,
      heroImageOverlay: Gradient.lerp(heroImageOverlay, other.heroImageOverlay, t) ?? heroImageOverlay,
    );
  }

  static const MovieThemeExtension dark = MovieThemeExtension(
    movieCardGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.transparent, AppColors.overlayDark],
    ),
    ratingStarColor: AppColors.ratingGold,
    genreChipColor: AppColors.darkSurfaceVariant,
    watchButtonGradient: LinearGradient(
      colors: AppColors.redGradient,
    ),
    heroImageOverlay: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: AppColors.darkOverlayGradient,
    ),
  );

  static const MovieThemeExtension light = MovieThemeExtension(
    movieCardGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.transparent, AppColors.overlayLight],
    ),
    ratingStarColor: AppColors.ratingGold,
    genreChipColor: AppColors.lightSurfaceVariant,
    watchButtonGradient: LinearGradient(
      colors: AppColors.redGradient,
    ),
    heroImageOverlay: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.transparent, Color(0x80FFFFFF), AppColors.lightBackground],
    ),
  );
}

extension ThemeDataExtensions on ThemeData {
  MovieThemeExtension get movieTheme => extension<MovieThemeExtension>() ?? MovieThemeExtension.dark;

  Color get primaryRed => AppColors.primaryRed;
  Color get textPrimary => brightness == Brightness.dark
      ? AppColors.darkTextPrimary
      : AppColors.lightTextPrimary;
  Color get textSecondary => brightness == Brightness.dark
      ? AppColors.darkTextSecondary
      : AppColors.lightTextSecondary;
  Color get cardBackground => brightness == Brightness.dark
      ? AppColors.darkCard
      : AppColors.lightCard;
  Color get surfaceVariant => brightness == Brightness.dark
      ? AppColors.darkSurfaceVariant
      : AppColors.lightSurfaceVariant;
}