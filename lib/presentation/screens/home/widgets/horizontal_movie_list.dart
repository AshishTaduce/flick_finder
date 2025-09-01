import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../domain/entities/movie.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_insets.dart';
import '../../../../shared/theme/app_typography.dart';

class HorizontalMovieList extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  final VoidCallback? onSeeAll;

  const HorizontalMovieList({
    super.key,
    required this.title,
    required this.movies,
    this.isLoading = false,
    this.error,
    this.onRetry,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: AppInsets.screenPaddingHorizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: AppTypography.bold,
                ),
              ),
              if (onSeeAll != null && movies.isNotEmpty)
                TextButton(
                  onPressed: onSeeAll,
                  child: Text(
                    'See All',
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: AppTypography.semiBold,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: AppInsets.md),

        // Movie list
        SizedBox(
          height: 280, // Fixed height for horizontal list
          child: _buildContent(theme),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (isLoading && movies.isEmpty) {
      return _buildLoadingList();
    }

    if (error != null && movies.isEmpty) {
      return _buildErrorState(theme);
    }

    if (movies.isEmpty) {
      return _buildEmptyState(theme);
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: AppInsets.screenPaddingHorizontal,
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return _buildMovieCard(movie, theme, index == movies.length - 1);
      },
    );
  }

  Widget _buildMovieCard(Movie movie, ThemeData theme, bool isLast) {
    final imageUrl = movie.posterPath != null
        ? '${ApiConstants.imageBaseUrl}${movie.posterPath}'
        : null;

    return Container(
      width: 140,
      margin: EdgeInsets.only(right: isLast ? 0 : AppInsets.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Movie poster
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppInsets.radiusMd),
                color: theme.brightness == Brightness.dark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppInsets.radiusMd),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: theme.brightness == Brightness.dark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSurfaceVariant,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: theme.brightness == Brightness.dark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSurfaceVariant,
                          child: const Center(
                            child: Icon(Icons.error, size: 30),
                          ),
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.movie, size: 40),
                            const SizedBox(height: AppInsets.sm),
                            Text(
                              movie.title,
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: AppInsets.sm),

          // Movie title
          Text(
            movie.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: AppTypography.semiBold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppInsets.xs),

          // Rating and year
          Row(
            children: [
              const Icon(
                Icons.star,
                color: AppColors.ratingGold,
                size: 16,
              ),
              const SizedBox(width: AppInsets.xs),
              Text(
                movie.rating.toStringAsFixed(1),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const Spacer(),
              Text(
                movie.releaseDate.year.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: AppInsets.screenPaddingHorizontal,
      itemCount: 5, // Show 5 loading placeholders
      itemBuilder: (context, index) {
        return Container(
          width: 140,
          margin: EdgeInsets.only(right: index == 4 ? 0 : AppInsets.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppInsets.radiusMd),
                    color: Colors.grey[300],
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              const SizedBox(height: AppInsets.sm),
              Container(
                height: 16,
                width: double.infinity,
                color: Colors.grey[300],
              ),
              const SizedBox(height: AppInsets.xs),
              Container(
                height: 12,
                width: 80,
                color: Colors.grey[300],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 40),
          const SizedBox(height: AppInsets.md),
          Text(
            'Failed to load $title',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: AppInsets.sm),
          if (onRetry != null)
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.movie_outlined, size: 40),
          const SizedBox(height: AppInsets.md),
          Text(
            'No $title available',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}