import 'cast.dart';

class MovieDetail {
  final int id;
  final String title;
  final String description;
  final String? posterPath;
  final String? backdropPath;
  final DateTime releaseDate;
  final double rating;
  final int voteCount;
  final List<int> genreIds;
  final int runtime;
  final String status;
  final int budget;
  final int revenue;
  final String? homepage;
  final String? imdbId;
  final List<String> genres;
  final List<Cast> cast;

  const MovieDetail({
    required this.id,
    required this.title,
    required this.description,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.rating,
    required this.voteCount,
    required this.genreIds,
    required this.runtime,
    required this.status,
    required this.budget,
    required this.revenue,
    this.homepage,
    this.imdbId,
    required this.genres,
    required this.cast,
  });

  String get fullPosterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : '';

  String get fullBackdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w500$backdropPath'
      : '';

  String get formattedRuntime {
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}