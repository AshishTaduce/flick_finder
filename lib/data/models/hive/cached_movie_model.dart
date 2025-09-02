import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/movie.dart';

part 'cached_movie_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class CachedMovieModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String? posterPath;

  @HiveField(4)
  final String? backdropPath;

  @HiveField(5)
  final String releaseDate;

  @HiveField(6)
  final double rating;

  @HiveField(7)
  final int voteCount;

  @HiveField(8)
  final List<int> genreIds;

  @HiveField(9)
  final DateTime cachedAt;

  @HiveField(10)
  final DateTime? lastUpdated;

  @HiveField(11)
  final String? category; // popular, trending, now_playing, etc.

  CachedMovieModel({
    required this.id,
    required this.title,
    required this.description,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.rating,
    required this.voteCount,
    required this.genreIds,
    required this.cachedAt,
    this.lastUpdated,
    this.category,
  });

  factory CachedMovieModel.fromJson(Map<String, dynamic> json) =>
      _$CachedMovieModelFromJson(json);

  Map<String, dynamic> toJson() => _$CachedMovieModelToJson(this);

  factory CachedMovieModel.fromApiResponse(
    Map<String, dynamic> json, {
    String? category,
  }) {
    return CachedMovieModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String? ?? '',
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      genreIds: (json['genre_ids'] as List<dynamic>?)?.cast<int>() ?? [],
      cachedAt: DateTime.now(),
      category: category,
    );
  }

  Movie toEntity() {
    return Movie(
      id: id,
      title: title,
      description: description,
      posterPath: posterPath,
      backdropPath: backdropPath,
      releaseDate: DateTime.tryParse(releaseDate) ?? DateTime.now(),
      rating: rating,
      voteCount: voteCount,
      genreIds: genreIds,
    );
  }

  CachedMovieModel copyWith({
    int? id,
    String? title,
    String? description,
    String? posterPath,
    String? backdropPath,
    String? releaseDate,
    double? rating,
    int? voteCount,
    List<int>? genreIds,
    DateTime? cachedAt,
    DateTime? lastUpdated,
    String? category,
  }) {
    return CachedMovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      releaseDate: releaseDate ?? this.releaseDate,
      rating: rating ?? this.rating,
      voteCount: voteCount ?? this.voteCount,
      genreIds: genreIds ?? this.genreIds,
      cachedAt: cachedAt ?? this.cachedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      category: category ?? this.category,
    );
  }

  bool get isStale {
    final now = DateTime.now();
    final age = now.difference(lastUpdated ?? cachedAt);
    
    // Consider data stale after 6 hours for popular/trending
    // and 24 hours for other categories
    final staleThreshold = category == 'popular' || category == 'trending'
        ? const Duration(hours: 6)
        : const Duration(hours: 24);
    
    return age > staleThreshold;
  }
}