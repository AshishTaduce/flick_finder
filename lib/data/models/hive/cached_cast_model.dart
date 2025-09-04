import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/cast.dart';

part 'cached_cast_model.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class CachedCastModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String character;

  @HiveField(3)
  final String? profilePath;

  @HiveField(4)
  final int order;

  @HiveField(5)
  final DateTime cachedAt;

  CachedCastModel({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    required this.order,
    required this.cachedAt,
  });

  factory CachedCastModel.fromJson(Map<String, dynamic> json) =>
      _$CachedCastModelFromJson(json);

  Map<String, dynamic> toJson() => _$CachedCastModelToJson(this);

  factory CachedCastModel.fromApiResponse(Map<String, dynamic> json) {
    return CachedCastModel(
      id: json['id'] as int,
      name: json['name'] as String,
      character: json['character'] as String? ?? '',
      profilePath: json['profile_path'] as String?,
      order: json['order'] as int? ?? 0,
      cachedAt: DateTime.now(),
    );
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

  CachedCastModel copyWith({
    int? id,
    String? name,
    String? character,
    String? profilePath,
    int? order,
    DateTime? cachedAt,
  }) {
    return CachedCastModel(
      id: id ?? this.id,
      name: name ?? this.name,
      character: character ?? this.character,
      profilePath: profilePath ?? this.profilePath,
      order: order ?? this.order,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }
}