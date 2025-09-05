// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_cast_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedCastModelAdapter extends TypeAdapter<CachedCastModel> {
  @override
  final int typeId = 3;

  @override
  CachedCastModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedCastModel(
      id: fields[0] as int,
      name: fields[1] as String,
      character: fields[2] as String,
      profilePath: fields[3] as String?,
      order: fields[4] as int,
      cachedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CachedCastModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.character)
      ..writeByte(3)
      ..write(obj.profilePath)
      ..writeByte(4)
      ..write(obj.order)
      ..writeByte(5)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedCastModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CachedCastModel _$CachedCastModelFromJson(Map<String, dynamic> json) =>
    CachedCastModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      character: json['character'] as String,
      profilePath: json['profilePath'] as String?,
      order: (json['order'] as num).toInt(),
      cachedAt: DateTime.parse(json['cachedAt'] as String),
    );

Map<String, dynamic> _$CachedCastModelToJson(CachedCastModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'character': instance.character,
      'profilePath': instance.profilePath,
      'order': instance.order,
      'cachedAt': instance.cachedAt.toIso8601String(),
    };
