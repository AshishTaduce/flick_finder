import 'package:flutter/material.dart';
import '../../domain/entities/movie.dart';
import '../theme/app_insets.dart';
import 'movie_card.dart';

class MovieGrid extends StatelessWidget {
  final List<Movie> movies;
  final int crossAxisCount;

  const MovieGrid({
    super.key,
    required this.movies,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Center(
        child: Text('No movies found'),
      );
    }

    return GridView.builder(
      padding: AppInsets.screenPadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: crossAxisCount == 3 ? 0.6 : 0.7,
        crossAxisSpacing: crossAxisCount == 3 ? AppInsets.sm : AppInsets.md,
        mainAxisSpacing: crossAxisCount == 3 ? AppInsets.sm : AppInsets.md,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        return MovieCard(movie: movies[index]);
      },
    );
  }
}