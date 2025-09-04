import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/watch_provider.dart';

part 'watch_provider_model.g.dart';

@JsonSerializable()
class WatchProviderModel {
  @JsonKey(name: 'provider_id')
  final int providerId;
  @JsonKey(name: 'provider_name')
  final String providerName;
  @JsonKey(name: 'logo_path')
  final String logoPath;
  @JsonKey(name: 'display_priority')
  final int displayPriority;

  const WatchProviderModel({
    required this.providerId,
    required this.providerName,
    required this.logoPath,
    required this.displayPriority,
  });

  factory WatchProviderModel.fromJson(Map<String, dynamic> json) =>
      _$WatchProviderModelFromJson(json);

  Map<String, dynamic> toJson() => _$WatchProviderModelToJson(this);

  WatchProvider toEntity() {
    return WatchProvider(
      providerId: providerId,
      providerName: providerName,
      logoPath: logoPath,
      displayPriority: displayPriority,
    );
  }
}

@JsonSerializable()
class WatchProvidersModel {
  final String? link;
  final List<WatchProviderModel>? flatrate;
  final List<WatchProviderModel>? rent;
  final List<WatchProviderModel>? buy;

  const WatchProvidersModel({
    this.link,
    this.flatrate,
    this.rent,
    this.buy,
  });

  factory WatchProvidersModel.fromJson(Map<String, dynamic> json) =>
      _$WatchProvidersModelFromJson(json);

  Map<String, dynamic> toJson() => _$WatchProvidersModelToJson(this);

  WatchProviders toEntity() {
    return WatchProviders(
      link: link,
      flatrate: flatrate?.map((e) => e.toEntity()).toList() ?? [],
      rent: rent?.map((e) => e.toEntity()).toList() ?? [],
      buy: buy?.map((e) => e.toEntity()).toList() ?? [],
    );
  }
}