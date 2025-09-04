// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_movie_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedMovieModelAdapter extends TypeAdapter<CachedMovieModel> {
  @override
  final int typeId = 0;

  @override
  CachedMovieModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedMovieModel(
      id: fields[0] as int,
      title: fields[1] as String,
      description: fields[2] as String,
      posterPath: fields[3] as String?,
      backdropPath: fields[4] as String?,
      releaseDate: fields[5] as String,
      rating: fields[6] as double,
      voteCount: fields[7] as int,
      genreIds: (fields[8] as List).cast<int>(),
      cachedAt: fields[9] as DateTime,
      lastUpdated: fields[10] as DateTime?,
      category: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CachedMovieModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.posterPath)
      ..writeByte(4)
      ..write(obj.backdropPath)
      ..writeByte(5)
      ..write(obj.releaseDate)
      ..writeByte(6)
      ..write(obj.rating)
      ..writeByte(7)
      ..write(obj.voteCount)
      ..writeByte(8)
      ..write(obj.genreIds)
      ..writeByte(9)
      ..write(obj.cachedAt)
      ..writeByte(10)
      ..write(obj.lastUpdated)
      ..writeByte(11)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedMovieModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CachedMovieModel _$CachedMovieModelFromJson(Map<String, dynamic> json) =>
    CachedMovieModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      posterPath: json['posterPath'] as String?,
      backdropPath: json['backdropPath'] as String?,
      releaseDate: json['releaseDate'] as String,
      rating: (json['rating'] as num).toDouble(),
      voteCount: (json['voteCount'] as num).toInt(),
      genreIds: (json['genreIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      cachedAt: DateTime.parse(json['cachedAt'] as String),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
      category: json['category'] as String?,
    );

Map<String, dynamic> _$CachedMovieModelToJson(CachedMovieModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'posterPath': instance.posterPath,
      'backdropPath': instance.backdropPath,
      'releaseDate': instance.releaseDate,
      'rating': instance.rating,
      'voteCount': instance.voteCount,
      'genreIds': instance.genreIds,
      'cachedAt': instance.cachedAt.toIso8601String(),
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
      'category': instance.category,
    };
