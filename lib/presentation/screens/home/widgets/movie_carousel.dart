import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../domain/entities/movie.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_insets.dart';
import '../../../../shared/theme/app_typography.dart';

class MovieCarousel extends StatefulWidget {
  final List<Movie> movies;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  const MovieCarousel({
    super.key,
    required this.movies,
    this.isLoading = false,
    this.error,
    this.onRetry,
  });

  @override
  State<MovieCarousel> createState() => _MovieCarouselState();
}

class _MovieCarouselState extends State<MovieCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    if (widget.isLoading && widget.movies.isEmpty) {
      return _buildLoadingCarousel(size);
    }

    if (widget.error != null && widget.movies.isEmpty) {
      return _buildErrorCarousel(theme, size);
    }

    if (widget.movies.isEmpty) {
      return _buildEmptyCarousel(theme, size);
    }

    return SizedBox(
      height: size.height * 0.6, // 60% of screen height
      child: Stack(
        children: [
          // Main carousel
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.movies.length.clamp(0, 5), // Show max 5 movies
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              return _buildCarouselItem(movie, theme, size);
            },
          ),

          // Gradient overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),

          // Movie info overlay
          if (widget.movies.isNotEmpty)
            Positioned(
              bottom: 80,
              left: AppInsets.md,
              right: AppInsets.md,
              child: _buildMovieInfo(widget.movies[_currentIndex], theme),
            ),

          // Page indicators
          if (widget.movies.length > 1)
            Positioned(
              bottom: AppInsets.md,
              left: 0,
              right: 0,
              child: _buildPageIndicators(theme),
            ),

          // Loading overlay
          if (widget.isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCarouselItem(Movie movie, ThemeData theme, Size size) {
    final imageUrl = movie.backdropPath != null
        ? '${ApiConstants.imageBaseUrl}${movie.backdropPath}'
        : movie.posterPath != null
            ? '${ApiConstants.imageBaseUrl}${movie.posterPath}'
            : null;

    return Container(
      width: size.width,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant,
      ),
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
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
                  child: Icon(Icons.error, size: 50),
                ),
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.movie, size: 80),
                  const SizedBox(height: AppInsets.md),
                  Text(
                    movie.title,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMovieInfo(Movie movie, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: AppTypography.bold,
            shadows: [
              const Shadow(
                offset: Offset(0, 2),
                blurRadius: 4,
                color: Colors.black54,
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppInsets.sm),
        Row(
          children: [
            const Icon(
              Icons.star,
              color: AppColors.ratingGold,
              size: 20,
            ),
            const SizedBox(width: AppInsets.xs),
            Text(
              movie.rating.toStringAsFixed(1),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: AppTypography.semiBold,
                shadows: [
                  const Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppInsets.md),
            Text(
              movie.releaseDate.year.toString(),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
                shadows: [
                  const Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppInsets.sm),
        Text(
          movie.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white70,
            shadows: [
              const Shadow(
                offset: Offset(0, 1),
                blurRadius: 2,
                color: Colors.black54,
              ),
            ],
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPageIndicators(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.movies.length.clamp(0, 5),
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == _currentIndex
                ? AppColors.primaryRed
                : Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCarousel(Size size) {
    return Container(
      height: size.height * 0.6,
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorCarousel(ThemeData theme, Size size) {
    return Container(
      height: size.height * 0.6,
      color: theme.brightness == Brightness.dark
          ? AppColors.darkSurfaceVariant
          : AppColors.lightSurfaceVariant,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60),
            const SizedBox(height: AppInsets.md),
            Text(
              'Failed to load movies',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppInsets.sm),
            if (widget.onRetry != null)
              ElevatedButton(
                onPressed: widget.onRetry,
                child: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCarousel(ThemeData theme, Size size) {
    return Container(
      height: size.height * 0.6,
      color: theme.brightness == Brightness.dark
          ? AppColors.darkSurfaceVariant
          : AppColors.lightSurfaceVariant,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie_outlined, size: 60),
            const SizedBox(height: AppInsets.md),
            Text(
              'No movies available',
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}