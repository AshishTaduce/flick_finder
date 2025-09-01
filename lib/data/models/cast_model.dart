import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/cast.dart';

part 'cast_model.g.dart';

@JsonSerializable()
class CastModel {
  final int id;
  final String name;
  final String character;
  @JsonKey(name: 'profile_path')
  final String? profilePath;
  final int order;

  const CastModel({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    required this.order,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) =>
      _$CastModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$CastModelToJson(this);

  Cast toEntity() {
    return Cast(
      id: id,
      name: name,
      character: character,
      profilePath: profilePath,
      order: order,
    );
  }
}