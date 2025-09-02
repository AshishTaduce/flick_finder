// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_metadata_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CacheMetadataModelAdapter extends TypeAdapter<CacheMetadataModel> {
  @override
  final int typeId = 4;

  @override
  CacheMetadataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheMetadataModel(
      key: fields[0] as String,
      lastFetched: fields[1] as DateTime,
      lastUpdated: fields[2] as DateTime?,
      totalPages: fields[3] as int?,
      totalResults: fields[4] as int?,
      etag: fields[5] as String?,
      additionalData: (fields[6] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, CacheMetadataModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.lastFetched)
      ..writeByte(2)
      ..write(obj.lastUpdated)
      ..writeByte(3)
      ..write(obj.totalPages)
      ..writeByte(4)
      ..write(obj.totalResults)
      ..writeByte(5)
      ..write(obj.etag)
      ..writeByte(6)
      ..write(obj.additionalData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheMetadataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CacheMetadataModel _$CacheMetadataModelFromJson(Map<String, dynamic> json) =>
    CacheMetadataModel(
      key: json['key'] as String,
      lastFetched: DateTime.parse(json['lastFetched'] as String),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
      totalPages: (json['totalPages'] as num?)?.toInt(),
      totalResults: (json['totalResults'] as num?)?.toInt(),
      etag: json['etag'] as String?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CacheMetadataModelToJson(CacheMetadataModel instance) =>
    <String, dynamic>{
      'key': instance.key,
      'lastFetched': instance.lastFetched.toIso8601String(),
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
      'totalPages': instance.totalPages,
      'totalResults': instance.totalResults,
      'etag': instance.etag,
      'additionalData': instance.additionalData,
    };
