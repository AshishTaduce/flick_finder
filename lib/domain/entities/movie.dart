class Movie {
  final int id;
  final String title;
  final String description;
  final String? posterPath;
  final String? backdropPath;
  final DateTime releaseDate;
  final double rating;
  final int voteCount;
  final List<int> genreIds;

  const Movie({
    required this.id,
    required this.title,
    required this.description,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.rating,
    required this.voteCount,
    required this.genreIds,
  });

  String get fullPosterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : '';

  String get fullBackdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w500$backdropPath'
      : '';
}