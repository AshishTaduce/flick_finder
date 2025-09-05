import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/movie_detail.dart';
import 'cached_cast_model.dart';

part 'cached_movie_detail_model.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class CachedGenreModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  CachedGenreModel({
    required this.id,
    required this.name,
  });

  factory CachedGenreModel.fromJson(Map<String, dynamic> json) =>
      _$CachedGenreModelFromJson(json);

  Map<String, dynamic> toJson() => _$CachedGenreModelToJson(this);
}

@HiveType(typeId: 2)
@JsonSerializable()
class CachedMovieDetailModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String overview;

  @HiveField(3)
  final String? posterPath;

  @HiveField(4)
  final String? backdropPath;

  @HiveField(5)
  final String releaseDate;

  @HiveField(6)
  final double voteAverage;

  @HiveField(7)
  final int voteCount;

  @HiveField(8)
  final List<CachedGenreModel> genres;

  @HiveField(9)
  final int runtime;

  @HiveField(10)
  final String status;

  @HiveField(11)
  final int budget;

  @HiveField(12)
  final int revenue;

  @HiveField(13)
  final String? homepage;

  @HiveField(14)
  final String? imdbId;

  @HiveField(15)
  final List<CachedCastModel> cast;

  @HiveField(16)
  final DateTime cachedAt;

  @HiveField(17)
  final DateTime? lastUpdated;

  @HiveField(18)
  final String? lastChangeId; // For TMDB changes API

  CachedMovieDetailModel({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.genres,
    required this.runtime,
    required this.status,
    required this.budget,
    required this.revenue,
    this.homepage,
    this.imdbId,
    required this.cast,
    required this.cachedAt,
    this.lastUpdated,
    this.lastChangeId,
  });

  factory CachedMovieDetailModel.fromJson(Map<String, dynamic> json) =>
      _$CachedMovieDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$CachedMovieDetailModelToJson(this);

  factory CachedMovieDetailModel.fromApiResponse(
    Map<String, dynamic> detailJson,
    List<Map<String, dynamic>> castJson,
  ) {
    return CachedMovieDetailModel(
      id: detailJson['id'] as int,
      title: detailJson['title'] as String,
      overview: detailJson['overview'] as String? ?? '',
      posterPath: detailJson['poster_path'] as String?,
      backdropPath: detailJson['backdrop_path'] as String?,
      releaseDate: detailJson['release_date'] as String? ?? '',
      voteAverage: (detailJson['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: detailJson['vote_count'] as int? ?? 0,
      genres: (detailJson['genres'] as List<dynamic>?)
              ?.map((g) => CachedGenreModel(
                    id: g['id'] as int,
                    name: g['name'] as String,
                  ))
              .toList() ??
          [],
      runtime: detailJson['runtime'] as int? ?? 0,
      status: detailJson['status'] as String? ?? '',
      budget: detailJson['budget'] as int? ?? 0,
      revenue: detailJson['revenue'] as int? ?? 0,
      homepage: detailJson['homepage'] as String?,
      imdbId: detailJson['imdb_id'] as String?,
      cast: castJson
          .map((c) => CachedCastModel.fromApiResponse(c))
          .toList(),
      cachedAt: DateTime.now(),
    );
  }

  MovieDetail toEntity() {
    return MovieDetail(
      id: id,
      title: title,
      description: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      releaseDate: DateTime.tryParse(releaseDate) ?? DateTime.now(),
      rating: voteAverage,
      voteCount: voteCount,
      genreIds: genres.map((g) => g.id).toList(),
      runtime: runtime,
      status: status,
      budget: budget,
      revenue: revenue,
      homepage: homepage,
      imdbId: imdbId,
      genres: genres.map((g) => g.name).toList(),
      cast: cast.map((c) => c.toEntity()).toList(),
    );
  }

  CachedMovieDetailModel copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    String? releaseDate,
    double? voteAverage,
    int? voteCount,
    List<CachedGenreModel>? genres,
    int? runtime,
    String? status,
    int? budget,
    int? revenue,
    String? homepage,
    String? imdbId,
    List<CachedCastModel>? cast,
    DateTime? cachedAt,
    DateTime? lastUpdated,
    String? lastChangeId,
  }) {
    return CachedMovieDetailModel(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      releaseDate: releaseDate ?? this.releaseDate,
      voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount,
      genres: genres ?? this.genres,
      runtime: runtime ?? this.runtime,
      status: status ?? this.status,
      budget: budget ?? this.budget,
      revenue: revenue ?? this.revenue,
      homepage: homepage ?? this.homepage,
      imdbId: imdbId ?? this.imdbId,
      cast: cast ?? this.cast,
      cachedAt: cachedAt ?? this.cachedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastChangeId: lastChangeId ?? this.lastChangeId,
    );
  }

  bool get isStale {
    final now = DateTime.now();
    final age = now.difference(lastUpdated ?? cachedAt);
    
    // Movie details are considered stale after 7 days
    return age > const Duration(days: 7);
  }

  bool get needsRefresh {
    final now = DateTime.now();
    final age = now.difference(lastUpdated ?? cachedAt);
    
    // Check for updates every 24 hours
    return age > const Duration(hours: 24);
  }
}