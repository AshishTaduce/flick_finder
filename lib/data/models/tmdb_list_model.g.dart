// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbListModel _$TmdbListModelFromJson(Map<String, dynamic> json) =>
    TmdbListModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      favoriteCount: (json['favorite_count'] as num).toInt(),
      itemCount: (json['item_count'] as num).toInt(),
      iso6391: json['iso_639_1'] as String,
      listType: json['list_type'] as String,
      posterPath: json['poster_path'] as String?,
    );

Map<String, dynamic> _$TmdbListModelToJson(TmdbListModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'favorite_count': instance.favoriteCount,
      'item_count': instance.itemCount,
      'iso_639_1': instance.iso6391,
      'list_type': instance.listType,
      'poster_path': instance.posterPath,
    };

TmdbListDetailModel _$TmdbListDetailModelFromJson(Map<String, dynamic> json) =>
    TmdbListDetailModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      favoriteCount: (json['favorite_count'] as num).toInt(),
      itemCount: (json['item_count'] as num).toInt(),
      iso6391: json['iso_639_1'] as String,
      listType: json['list_type'] as String,
      posterPath: json['poster_path'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdBy: json['created_by'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$TmdbListDetailModelToJson(
        TmdbListDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'favorite_count': instance.favoriteCount,
      'item_count': instance.itemCount,
      'iso_639_1': instance.iso6391,
      'list_type': instance.listType,
      'poster_path': instance.posterPath,
      'items': instance.items,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
