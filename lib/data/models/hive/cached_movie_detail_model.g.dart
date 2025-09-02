// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_movie_detail_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedGenreModelAdapter extends TypeAdapter<CachedGenreModel> {
  @override
  final int typeId = 1;

  @override
  CachedGenreModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedGenreModel(
      id: fields[0] as int,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CachedGenreModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedGenreModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CachedMovieDetailModelAdapter
    extends TypeAdapter<CachedMovieDetailModel> {
  @override
  final int typeId = 2;

  @override
  CachedMovieDetailModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedMovieDetailModel(
      id: fields[0] as int,
      title: fields[1] as String,
      overview: fields[2] as String,
      posterPath: fields[3] as String?,
      backdropPath: fields[4] as String?,
      releaseDate: fields[5] as String,
      voteAverage: fields[6] as double,
      voteCount: fields[7] as int,
      genres: (fields[8] as List).cast<CachedGenreModel>(),
      runtime: fields[9] as int,
      status: fields[10] as String,
      budget: fields[11] as int,
      revenue: fields[12] as int,
      homepage: fields[13] as String?,
      imdbId: fields[14] as String?,
      cast: (fields[15] as List).cast<CachedCastModel>(),
      cachedAt: fields[16] as DateTime,
      lastUpdated: fields[17] as DateTime?,
      lastChangeId: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CachedMovieDetailModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.overview)
      ..writeByte(3)
      ..write(obj.posterPath)
      ..writeByte(4)
      ..write(obj.backdropPath)
      ..writeByte(5)
      ..write(obj.releaseDate)
      ..writeByte(6)
      ..write(obj.voteAverage)
      ..writeByte(7)
      ..write(obj.voteCount)
      ..writeByte(8)
      ..write(obj.genres)
      ..writeByte(9)
      ..write(obj.runtime)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.budget)
      ..writeByte(12)
      ..write(obj.revenue)
      ..writeByte(13)
      ..write(obj.homepage)
      ..writeByte(14)
      ..write(obj.imdbId)
      ..writeByte(15)
      ..write(obj.cast)
      ..writeByte(16)
      ..write(obj.cachedAt)
      ..writeByte(17)
      ..write(obj.lastUpdated)
      ..writeByte(18)
      ..write(obj.lastChangeId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedMovieDetailModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CachedGenreModel _$CachedGenreModelFromJson(Map<String, dynamic> json) =>
    CachedGenreModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$CachedGenreModelToJson(CachedGenreModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

CachedMovieDetailModel _$CachedMovieDetailModelFromJson(
        Map<String, dynamic> json) =>
    CachedMovieDetailModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      overview: json['overview'] as String,
      posterPath: json['posterPath'] as String?,
      backdropPath: json['backdropPath'] as String?,
      releaseDate: json['releaseDate'] as String,
      voteAverage: (json['voteAverage'] as num).toDouble(),
      voteCount: (json['voteCount'] as num).toInt(),
      genres: (json['genres'] as List<dynamic>)
          .map((e) => CachedGenreModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      runtime: (json['runtime'] as num).toInt(),
      status: json['status'] as String,
      budget: (json['budget'] as num).toInt(),
      revenue: (json['revenue'] as num).toInt(),
      homepage: json['homepage'] as String?,
      imdbId: json['imdbId'] as String?,
      cast: (json['cast'] as List<dynamic>)
          .map((e) => CachedCastModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      cachedAt: DateTime.parse(json['cachedAt'] as String),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
      lastChangeId: json['lastChangeId'] as String?,
    );

Map<String, dynamic> _$CachedMovieDetailModelToJson(
        CachedMovieDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'overview': instance.overview,
      'posterPath': instance.posterPath,
      'backdropPath': instance.backdropPath,
      'releaseDate': instance.releaseDate,
      'voteAverage': instance.voteAverage,
      'voteCount': instance.voteCount,
      'genres': instance.genres,
      'runtime': instance.runtime,
      'status': instance.status,
      'budget': instance.budget,
      'revenue': instance.revenue,
      'homepage': instance.homepage,
      'imdbId': instance.imdbId,
      'cast': instance.cast,
      'cachedAt': instance.cachedAt.toIso8601String(),
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
      'lastChangeId': instance.lastChangeId,
    };
