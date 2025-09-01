import 'package:flutter/material.dart';
import '../../../../domain/entities/movie.dart';
import '../../../../shared/theme/app_insets.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/movie_card.dart';

class HorizontalMovieList extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  const HorizontalMovieList({
    super.key,
    required this.title,
    required this.movies,
    this.isLoading = false,
    this.error,
    this.onRetry,
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
            ],
          ),
        ),

        const SizedBox(height: AppInsets.md),

        // Movie list
        SizedBox(
          height: 180, // Reduced height since we removed text
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
        return Container(
          margin: EdgeInsets.only(
            right: index == movies.length - 1 ? 0 : AppInsets.md,
          ),
          child: MovieCard(movie: movie, width: 120, height: 180),
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: AppInsets.screenPaddingHorizontal,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          width: 120,
          height: 180,
          margin: EdgeInsets.only(right: index == 4 ? 0 : AppInsets.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppInsets.radiusMd),
            color: Colors.grey[300],
          ),
          child: const Center(child: CircularProgressIndicator()),
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
          Text('Failed to load $title', style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppInsets.sm),
          if (onRetry != null)
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
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
          Text('No $title available', style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
