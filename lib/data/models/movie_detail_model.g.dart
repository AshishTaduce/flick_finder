// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_detail_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GenreModelAdapter extends TypeAdapter<GenreModel> {
  @override
  final int typeId = 1;

  @override
  GenreModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GenreModel(
      id: fields[0] as int,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GenreModel obj) {
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
      other is GenreModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MovieDetailModelAdapter extends TypeAdapter<MovieDetailModel> {
  @override
  final int typeId = 2;

  @override
  MovieDetailModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MovieDetailModel(
      id: fields[0] as int,
      title: fields[1] as String,
      overview: fields[2] as String,
      posterPath: fields[3] as String?,
      backdropPath: fields[4] as String?,
      releaseDate: fields[5] as String,
      voteAverage: fields[6] as double,
      voteCount: fields[7] as int,
      genres: (fields[8] as List).cast<GenreModel>(),
      runtime: fields[9] as int,
      status: fields[10] as String,
      budget: fields[11] as int,
      revenue: fields[12] as int,
      homepage: fields[13] as String?,
      imdbId: fields[14] as String?,
      cast: (fields[15] as List?)?.cast<CastModel>(),
      cachedAt: fields[16] as DateTime?,
      lastUpdated: fields[17] as DateTime?,
      lastChangeId: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MovieDetailModel obj) {
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
      other is MovieDetailModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenreModel _$GenreModelFromJson(Map<String, dynamic> json) => GenreModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$GenreModelToJson(GenreModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

MovieDetailModel _$MovieDetailModelFromJson(Map<String, dynamic> json) =>
    MovieDetailModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      overview: json['overview'] as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String,
      voteAverage: (json['vote_average'] as num).toDouble(),
      voteCount: (json['vote_count'] as num).toInt(),
      genres: (json['genres'] as List<dynamic>)
          .map((e) => GenreModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      runtime: (json['runtime'] as num).toInt(),
      status: json['status'] as String,
      budget: (json['budget'] as num).toInt(),
      revenue: (json['revenue'] as num).toInt(),
      homepage: json['homepage'] as String?,
      imdbId: json['imdb_id'] as String?,
    );

Map<String, dynamic> _$MovieDetailModelToJson(MovieDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'overview': instance.overview,
      'poster_path': instance.posterPath,
      'backdrop_path': instance.backdropPath,
      'release_date': instance.releaseDate,
      'vote_average': instance.voteAverage,
      'vote_count': instance.voteCount,
      'genres': instance.genres,
      'runtime': instance.runtime,
      'status': instance.status,
      'budget': instance.budget,
      'revenue': instance.revenue,
      'homepage': instance.homepage,
      'imdb_id': instance.imdbId,
    };
