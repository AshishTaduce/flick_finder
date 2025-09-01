import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/movie.dart';

part 'movie_model.g.dart';

@JsonSerializable()
class MovieModel {
  final int id;
  final String title;
  @JsonKey(name: 'overview')
  final String description;
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;
  @JsonKey(name: 'release_date')
  final String releaseDate;
  @JsonKey(name: 'vote_average')
  final double rating;
  @JsonKey(name: 'vote_count')
  final int voteCount;
  @JsonKey(name: 'genre_ids')
  final List<int> genreIds;

  const MovieModel({
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

  factory MovieModel.fromJson(Map<String, dynamic> json) => _$MovieModelFromJson(json);
  Map<String, dynamic> toJson() => _$MovieModelToJson(this);

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
}
