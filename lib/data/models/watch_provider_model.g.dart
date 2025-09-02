// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_provider_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WatchProviderModel _$WatchProviderModelFromJson(Map<String, dynamic> json) =>
    WatchProviderModel(
      providerId: (json['provider_id'] as num).toInt(),
      providerName: json['provider_name'] as String,
      logoPath: json['logo_path'] as String,
      displayPriority: (json['display_priority'] as num).toInt(),
    );

Map<String, dynamic> _$WatchProviderModelToJson(WatchProviderModel instance) =>
    <String, dynamic>{
      'provider_id': instance.providerId,
      'provider_name': instance.providerName,
      'logo_path': instance.logoPath,
      'display_priority': instance.displayPriority,
    };

WatchProvidersModel _$WatchProvidersModelFromJson(Map<String, dynamic> json) =>
    WatchProvidersModel(
      link: json['link'] as String?,
      flatrate: (json['flatrate'] as List<dynamic>?)
          ?.map((e) => WatchProviderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      rent: (json['rent'] as List<dynamic>?)
          ?.map((e) => WatchProviderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      buy: (json['buy'] as List<dynamic>?)
          ?.map((e) => WatchProviderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WatchProvidersModelToJson(
        WatchProvidersModel instance) =>
    <String, dynamic>{
      'link': instance.link,
      'flatrate': instance.flatrate,
      'rent': instance.rent,
      'buy': instance.buy,
    };