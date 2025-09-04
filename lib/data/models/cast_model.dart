import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/cast.dart';

part 'cast_model.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class CastModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String character;

  @HiveField(3)
  @JsonKey(name: 'profile_path')
  final String? profilePath;

  @HiveField(4)
  final int order;

  @HiveField(5)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final DateTime cachedAt;

  CastModel({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    required this.order,
    DateTime? cachedAt,
  }) : cachedAt = cachedAt ?? DateTime.now();

  factory CastModel.fromJson(Map<String, dynamic> json) =>
      _$CastModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$CastModelToJson(this);

  // Factory for creating from API response (same as fromJson but with cache metadata)
  factory CastModel.fromApiResponse(Map<String, dynamic> json) {
    return CastModel.fromJson(json).copyWith(cachedAt: DateTime.now());
  }

  Cast toEntity() {
    return Cast(
      id: id,
      name: name,
      character: character,
      profilePath: profilePath,
      order: order,
    );
  }

  CastModel copyWith({
    int? id,
    String? name,
    String? character,
    String? profilePath,
    int? order,
    DateTime? cachedAt,
  }) {
    return CastModel(
      id: id ?? this.id,
      name: name ?? this.name,
      character: character ?? this.character,
      profilePath: profilePath ?? this.profilePath,
      order: order ?? this.order,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }
}