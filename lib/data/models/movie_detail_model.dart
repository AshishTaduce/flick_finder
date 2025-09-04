import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/movie_detail.dart';
import 'cast_model.dart';

part 'movie_detail_model.g.dart';

@JsonSerializable()
class GenreModel {
  final int id;
  final String name;

  const GenreModel({
    required this.id,
    required this.name,
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) =>
      _$GenreModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$GenreModelToJson(this);
}

@JsonSerializable()
class MovieDetailModel {
  final int id;
  final String title;
  final String overview;
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;
  @JsonKey(name: 'release_date')
  final String releaseDate;
  @JsonKey(name: 'vote_average')
  final double voteAverage;
  @JsonKey(name: 'vote_count')
  final int voteCount;
  final List<GenreModel> genres;
  final int runtime;
  final String status;
  final int budget;
  final int revenue;
  final String? homepage;
  @JsonKey(name: 'imdb_id')
  final String? imdbId;

  const MovieDetailModel({
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
  });

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) =>
      _$MovieDetailModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$MovieDetailModelToJson(this);

  MovieDetail toEntity({List<CastModel> cast = const []}) {
    return MovieDetail(
      id: id,
      title: title,
      description: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      releaseDate: DateTime.parse(releaseDate),
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
}