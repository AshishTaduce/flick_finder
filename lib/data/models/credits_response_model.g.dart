// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credits_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreditsResponseModel _$CreditsResponseModelFromJson(
        Map<String, dynamic> json) =>
    CreditsResponseModel(
      id: (json['id'] as num).toInt(),
      cast: (json['cast'] as List<dynamic>)
          .map((e) => CastModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CreditsResponseModelToJson(
        CreditsResponseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cast': instance.cast,
    };
