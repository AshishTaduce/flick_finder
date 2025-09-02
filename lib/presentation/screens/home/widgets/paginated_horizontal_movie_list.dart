import 'package:flutter/material.dart';
import '../../../../domain/entities/movie.dart';
import '../../../../shared/theme/app_insets.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/movie_card.dart';

class PaginatedHorizontalMovieList extends StatefulWidget {
  final String title;
  final List<Movie> movies;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final VoidCallback? onRetry;
  final VoidCallback? onLoadMore;

  const PaginatedHorizontalMovieList({
    super.key,
    required this.title,
    required this.movies,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.onRetry,
    this.onLoadMore,
  });

  @override
  State<PaginatedHorizontalMovieList> createState() => _PaginatedHorizontalMovieListState();
}

class _PaginatedHorizontalMovieListState extends State<PaginatedHorizontalMovieList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      if (widget.hasMore && !widget.isLoadingMore && widget.onLoadMore != null) {
        widget.onLoadMore!();
      }
    }
  }

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
                widget.title,
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
          height: 180,
          child: _buildContent(theme),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (widget.isLoading && widget.movies.isEmpty) {
      return _buildLoadingList();
    }

    if (widget.error != null && widget.movies.isEmpty) {
      return _buildErrorState(theme);
    }

    if (widget.movies.isEmpty) {
      return _buildEmptyState(theme);
    }

    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: AppInsets.screenPaddingHorizontal,
      itemCount: widget.movies.length + (widget.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.movies.length) {
          // Loading indicator at the end
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: AppInsets.md),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final movie = widget.movies[index];
        return Container(
          margin: EdgeInsets.only(
            right: index == widget.movies.length - 1 && !widget.isLoadingMore ? 0 : AppInsets.md,
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
          Text('Failed to load ${widget.title}', style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppInsets.sm),
          if (widget.onRetry != null)
            ElevatedButton(onPressed: widget.onRetry, child: const Text('Retry')),
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
          Text('No ${widget.title} available', style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}