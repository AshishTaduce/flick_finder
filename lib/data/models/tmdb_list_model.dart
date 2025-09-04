import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/tmdb_list.dart';
import '../../domain/entities/tmdb_list_detail.dart';
import 'movie_model.dart';

part 'tmdb_list_model.g.dart';

@JsonSerializable()
class TmdbListModel {
  final int id;
  final String name;
  final String description;
  @JsonKey(name: 'favorite_count')
  final int favoriteCount;
  @JsonKey(name: 'item_count')
  final int itemCount;
  @JsonKey(name: 'iso_639_1')
  final String iso6391;
  @JsonKey(name: 'list_type')
  final String listType;
  @JsonKey(name: 'poster_path')
  final String? posterPath;

  const TmdbListModel({
    required this.id,
    required this.name,
    required this.description,
    required this.favoriteCount,
    required this.itemCount,
    required this.iso6391,
    required this.listType,
    this.posterPath,
  });

  factory TmdbListModel.fromJson(Map<String, dynamic> json) =>
      _$TmdbListModelFromJson(json);

  Map<String, dynamic> toJson() => _$TmdbListModelToJson(this);

  TmdbList toEntity() {
    return TmdbList(
      id: id,
      name: name,
      description: description,
      itemCount: itemCount,
      posterPath: posterPath,
      public: listType == 'movie', // Assuming movie lists are public
      iso639_1: iso6391,
    );
  }
}

@JsonSerializable()
class TmdbListDetailModel extends TmdbListModel {
  final List<MovieModel> items;
  @JsonKey(name: 'created_by')
  final String createdBy;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  const TmdbListDetailModel({
    required super.id,
    required super.name,
    required super.description,
    required super.favoriteCount,
    required super.itemCount,
    required super.iso6391,
    required super.listType,
    super.posterPath,
    required this.items,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TmdbListDetailModel.fromJson(Map<String, dynamic> json) =>
      _$TmdbListDetailModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TmdbListDetailModelToJson(this);

  TmdbListDetail toDetailEntity() {
    return TmdbListDetail(
      id: id,
      name: name,
      description: description,
      itemCount: itemCount,
      posterPath: posterPath,
      public: listType == 'movie',
      iso639_1: iso6391,
      items: items.map((item) => item.toEntity()).toList(),
      createdBy: createdBy,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
    );
  }
}