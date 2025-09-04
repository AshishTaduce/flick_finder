import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/movie_detail.dart';
import 'cast_model.dart';

part 'movie_detail_model.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class GenreModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  GenreModel({
    required this.id,
    required this.name,
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) =>
      _$GenreModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$GenreModelToJson(this);
}

@HiveType(typeId: 2)
@JsonSerializable()
class MovieDetailModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String overview;

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
  final double voteAverage;

  @HiveField(7)
  @JsonKey(name: 'vote_count')
  final int voteCount;

  @HiveField(8)
  final List<GenreModel> genres;

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
  @JsonKey(name: 'imdb_id')
  final String? imdbId;

  @HiveField(15)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<CastModel> cast;

  @HiveField(16)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final DateTime cachedAt;

  @HiveField(17)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final DateTime? lastUpdated;

  @HiveField(18)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? lastChangeId; // For TMDB changes API

  MovieDetailModel({
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
    List<CastModel>? cast,
    DateTime? cachedAt,
    this.lastUpdated,
    this.lastChangeId,
  }) : cast = cast ?? [],
       cachedAt = cachedAt ?? DateTime.now();

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) =>
      _$MovieDetailModelFromJson(json);
  
  Map<String, dynamic> toJson() {
    final json = _$MovieDetailModelToJson(this);
    // Ensure genres are properly serialized to JSON
    json['genres'] = genres.map((e) => e.toJson()).toList();
    return json;
  }

  // Factory for creating from API response with cast data
  factory MovieDetailModel.fromApiResponse(
    Map<String, dynamic> detailJson,
    List<Map<String, dynamic>> castJson,
  ) {
    return MovieDetailModel.fromJson(detailJson).copyWith(
      cast: castJson.map((c) => CastModel.fromApiResponse(c)).toList(),
      cachedAt: DateTime.now(),
    );
  }

  MovieDetail toEntity({List<CastModel>? castOverride}) {
    final castToUse = castOverride ?? cast;
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
      cast: castToUse.map((c) => c.toEntity()).toList(),
    );
  }

  MovieDetailModel copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    String? releaseDate,
    double? voteAverage,
    int? voteCount,
    List<GenreModel>? genres,
    int? runtime,
    String? status,
    int? budget,
    int? revenue,
    String? homepage,
    String? imdbId,
    List<CastModel>? cast,
    DateTime? cachedAt,
    DateTime? lastUpdated,
    String? lastChangeId,
  }) {
    return MovieDetailModel(
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