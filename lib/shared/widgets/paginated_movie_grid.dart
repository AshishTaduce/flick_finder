import 'package:flutter/material.dart';
import '../../domain/entities/movie.dart';
import '../theme/app_insets.dart';
import 'movie_card.dart';

class PaginatedMovieGrid extends StatefulWidget {
  final List<Movie> movies;
  final int crossAxisCount;
  final bool isLoadingMore;
  final bool hasMorePages;
  final VoidCallback? onLoadMore;

  const PaginatedMovieGrid({
    super.key,
    required this.movies,
    this.crossAxisCount = 2,
    this.isLoadingMore = false,
    this.hasMorePages = true,
    this.onLoadMore,
  });

  @override
  State<PaginatedMovieGrid> createState() => _PaginatedMovieGridState();
}

class _PaginatedMovieGridState extends State<PaginatedMovieGrid> {
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
      if (widget.hasMorePages && !widget.isLoadingMore && widget.onLoadMore != null) {
        widget.onLoadMore!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return const Center(
        child: Text('No movies found'),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: AppInsets.screenPadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        childAspectRatio: widget.crossAxisCount == 3 ? 0.6 : 0.7,
        crossAxisSpacing: widget.crossAxisCount == 3 ? AppInsets.sm : AppInsets.md,
        mainAxisSpacing: widget.crossAxisCount == 3 ? AppInsets.sm : AppInsets.md,
      ),
      itemCount: widget.movies.length + (widget.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.movies.length) {
          // Loading indicator at the end
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppInsets.md),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return MovieCard(movie: widget.movies[index]);
      },
    );
  }
}