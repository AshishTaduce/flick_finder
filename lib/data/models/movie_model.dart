import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/movie.dart';

part 'movie_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class MovieModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  @JsonKey(name: 'overview')
  final String description;

  @HiveField(3)
  @JsonKey(name: 'poster_path')
  final String? posterPath;

  @HiveField(4)
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;

  @HiveField(5)
  @JsonKey(name: 'release_date')
  final String releaseDate;

  @HiveField(6)
  @JsonKey(name: 'vote_average')
  final double rating;

  @HiveField(7)
  @JsonKey(name: 'vote_count')
  final int voteCount;

  @HiveField(8)
  @JsonKey(name: 'genre_ids')
  final List<int> genreIds;

  @HiveField(9)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final DateTime cachedAt;

  @HiveField(10)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final DateTime? lastUpdated;

  @HiveField(11)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? category; // popular, trending, now_playing, etc.

  MovieModel({
    required this.id,
    required this.title,
    required this.description,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.rating,
    required this.voteCount,
    required this.genreIds,
    DateTime? cachedAt,
    this.lastUpdated,
    this.category,
  }) : cachedAt = cachedAt ?? DateTime.now();

  factory MovieModel.fromJson(Map<String, dynamic> json) =>
      _$MovieModelFromJson(json);

  Map<String, dynamic> toJson() => _$MovieModelToJson(this);

  // Factory for creating from API response (same as fromJson but with cache metadata)
  factory MovieModel.fromApiResponse(
    Map<String, dynamic> json, {
    String? category,
  }) {
    return MovieModel.fromJson(json).copyWith(
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

  MovieModel copyWith({
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
    return MovieModel(
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