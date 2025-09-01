import 'package:flick_finder/shared/theme/app_typography.dart';
import 'package:flutter/material.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/movie.dart';
import '../../presentation/screens/movie_detail/movie_detail_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_insets.dart';
import 'custom_image_widget.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final double? width;
  final double? height;

  const MovieCard({
    super.key,
    required this.movie,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = movie.posterPath != null
        ? '${ApiConstants.imageBaseUrl}${movie.posterPath}'
        : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: movie),
          ),
        );
      },
      child: Hero(
        tag: 'movie_poster_${movie.id}',
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppInsets.radiusMd),
            color: theme.brightness == Brightness.dark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightSurfaceVariant,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppInsets.radiusMd),
            child: imageUrl != null
                ? CustomImageWidget(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.movie, size: 40),
                        const SizedBox(height: AppInsets.sm),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppInsets.sm),
                          child: Text(
                            movie.title,
                            style: AppTypography.headlineSmall,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}