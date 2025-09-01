import 'package:flick_finder/shared/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/api_constants.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/entities/movie_detail.dart';
import '../../../domain/entities/cast.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_insets.dart';
import '../../../shared/theme/app_typography.dart';
import '../home/widgets/horizontal_movie_list.dart';
import '../../providers/movie_detail_provider.dart';
import '../person_movies/person_movies_screen.dart';

class MovieDetailScreen extends ConsumerStatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  ConsumerState<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends ConsumerState<MovieDetailScreen> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // Load movie details when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(movieDetailProvider.notifier).loadAllMovieData(widget.movie.id);
    });
  }

  @override
  void dispose() {
    // Reset the provider state when leaving the screen
    ref.read(movieDetailProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final movieDetailState = ref.watch(movieDetailProvider);
    final movieDetail = movieDetailState.movieDetail;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildHeroSection(theme, movieDetail),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(theme, movieDetailState, movieDetail),
                _buildOverviewSection(theme, movieDetailState, movieDetail),
                _buildDetailsSection(theme, movieDetail),
                _buildCastSection(theme, movieDetailState),
                _buildSimilarMoviesSection(theme, movieDetailState),
                const SizedBox(height: AppInsets.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(ThemeData theme, MovieDetail? movieDetail) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Backdrop image
            if (widget.movie.backdropPath != null)
              CachedNetworkImage(
                imageUrl:
                    '${ApiConstants.imageBaseUrl}${widget.movie.backdropPath}',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightSurfaceVariant,
                ),
                errorWidget: (context, url, error) => Container(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightSurfaceVariant,
                  child: const Icon(Icons.error, size: 50),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(
    ThemeData theme,
    MovieDetailState movieDetailState,
    MovieDetail? movieDetail,
  ) {
    return Padding(
      padding: AppInsets.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            movieDetail?.title ?? widget.movie.title,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: AppTypography.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppInsets.sm),

          // Subtitle with years and runtime
          Row(
            children: [
              Text(
                (movieDetail?.releaseDate ?? widget.movie.releaseDate).year
                    .toString(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              if (movieDetail?.runtime != null) ...[
                const SizedBox(width: AppInsets.md),
                Text(
                  movieDetail!.formattedRuntime,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ],
          ),

          const SizedBox(height: AppInsets.lg),

          // Action buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppInsets.md),
            decoration: BoxDecoration(
              color: Theme.of(context).surfaceVariant,
              borderRadius: BorderRadius.circular(AppInsets.radiusSm),
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildPrimeActionButton(
                      icon: Icons.play_circle,
                      label: 'Watch',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to watchlist!')),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppInsets.md),
                    child: VerticalDivider(
                      color: Theme.of(context).appBarTheme.foregroundColor,
                      width: 1,
                      radius: BorderRadius.circular(AppInsets.radiusXxl),
                      // height: 20,
                    ),
                  ),
                  Expanded(
                    child: _buildPrimeActionButton(
                      icon: Icons.playlist_add,
                      label: 'Add to List',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Download feature coming soon!'),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppInsets.md),
                    child: VerticalDivider(
                      color: Theme.of(context).appBarTheme.foregroundColor,
                      width: 1,
                      radius: BorderRadius.circular(AppInsets.radiusXxl),
                      // height: 20,
                    ),
                  ),
                  Expanded(
                    child: _buildPrimeActionButton(
                      icon: Icons.offline_share,
                      label: 'Share',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Share feature coming soon!'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimeActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppInsets.md,
          vertical: AppInsets.md,
        ),
        decoration: BoxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppInsets.iconLg),
            const SizedBox(height: AppInsets.xs),
            Text(label, style: AppTypography.labelLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection(
    ThemeData theme,
    MovieDetailState movieDetailState,
    MovieDetail? movieDetail,
  ) {
    return Padding(
      padding: AppInsets.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppTypography.bold,
            ),
          ),
          const SizedBox(height: AppInsets.md),
          if (movieDetailState.isLoadingDetail)
            const CircularProgressIndicator()
          else if (movieDetailState.errorDetail != null)
            Text(
              'Error: ${movieDetailState.errorDetail}',
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red),
            )
          else
            AnimatedCrossFade(
              firstChild: Text(
                movieDetail?.description ?? widget.movie.description,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(
                movieDetail?.description ?? widget.movie.description,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          if ((movieDetail?.description ?? widget.movie.description).length >
              150)
            TextButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(
                _isExpanded ? 'Show Less' : 'Read More',
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(ThemeData theme, MovieDetail? movieDetail) {
    return Padding(
      padding: AppInsets.screenPaddingHorizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppTypography.bold,
            ),
          ),
          const SizedBox(height: AppInsets.md),
          _buildDetailRow(
            'Release Date',
            _formatDate(movieDetail?.releaseDate ?? widget.movie.releaseDate),
            theme,
          ),
          _buildDetailRow(
            'Rating',
            '🌟 ${(movieDetail?.rating ?? widget.movie.rating).toStringAsFixed(1)}/10 (${movieDetail?.voteCount ?? widget.movie.voteCount} votes)',
            theme,
          ),
          if (movieDetail?.genres.isNotEmpty == true)
            _buildDetailRow('Genres', movieDetail!.genres.join(', '), theme),
          if (movieDetail?.status != null)
            _buildDetailRow('Status', movieDetail!.status, theme),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppInsets.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontWeight: AppTypography.medium,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: AppTypography.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCastSection(ThemeData theme, MovieDetailState movieDetailState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppInsets.screenPaddingHorizontal,
          child: Text(
            'Meet The Crew',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppTypography.bold,
            ),
          ),
        ),
        const SizedBox(height: AppInsets.md),
        SizedBox(
          height: 120,
          child: movieDetailState.isLoadingDetail
              ? const Center(child: CircularProgressIndicator())
              : movieDetailState.cast.isEmpty
              ? Center(
                  child: Text(
                    'No cast information available',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.brightness == Brightness.dark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: AppInsets.screenPaddingHorizontal,
                  itemCount: movieDetailState.cast.length > 10
                      ? 10
                      : movieDetailState.cast.length,
                  itemBuilder: (context, index) {
                    final castMember = movieDetailState.cast[index];
                    return _buildCastCard(
                      castMember,
                      theme,
                      index == movieDetailState.cast.length - 1 || index == 9,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCastCard(Cast castMember, ThemeData theme, bool isLast) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonMoviesScreen(person: castMember),
          ),
        );
      },
      child: Container(
        width: 80,
        margin: EdgeInsets.only(right: isLast ? 0 : AppInsets.md),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.brightness == Brightness.dark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
              ),
              child: ClipOval(
                child: castMember.profilePath != null
                    ? CachedNetworkImage(
                        imageUrl: castMember.fullProfileUrl,
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                        placeholder: (context, url) =>
                            const Icon(Icons.person, size: 30),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.person, size: 30),
                      )
                    : const Icon(Icons.person, size: 30),
              ),
            ),
            const SizedBox(height: AppInsets.sm),
            Text(
              castMember.name,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: AppTypography.medium,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarMoviesSection(
    ThemeData theme,
    MovieDetailState movieDetailState,
  ) {
    return Column(
      children: [
        const SizedBox(height: AppInsets.lg),
        HorizontalMovieList(
          title: 'Similar Movies',
          movies: movieDetailState.similarMovies,
          isLoading: movieDetailState.isLoadingSimilar,
          error: movieDetailState.errorSimilar,
          onRetry: () {
            ref
                .read(movieDetailProvider.notifier)
                .loadSimilarMovies(widget.movie.id);
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
