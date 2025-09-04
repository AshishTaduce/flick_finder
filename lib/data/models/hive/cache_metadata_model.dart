import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cache_metadata_model.g.dart';

@HiveType(typeId: 4)
@JsonSerializable()
class CacheMetadataModel extends HiveObject {
  @HiveField(0)
  @override
  final String key; // e.g., 'popular_movies_page_1', 'movie_detail_123'

  @HiveField(1)
  final DateTime lastFetched;

  @HiveField(2)
  final DateTime? lastUpdated;

  @HiveField(3)
  final int? totalPages;

  @HiveField(4)
  final int? totalResults;

  @HiveField(5)
  final String? etag; // For HTTP caching

  @HiveField(6)
  final Map<String, dynamic>? additionalData;

  CacheMetadataModel({
    required this.key,
    required this.lastFetched,
    this.lastUpdated,
    this.totalPages,
    this.totalResults,
    this.etag,
    this.additionalData,
  });

  factory CacheMetadataModel.fromJson(Map<String, dynamic> json) =>
      _$CacheMetadataModelFromJson(json);

  Map<String, dynamic> toJson() => _$CacheMetadataModelToJson(this);

  CacheMetadataModel copyWith({
    String? key,
    DateTime? lastFetched,
    DateTime? lastUpdated,
    int? totalPages,
    int? totalResults,
    String? etag,
    Map<String, dynamic>? additionalData,
  }) {
    return CacheMetadataModel(
      key: key ?? this.key,
      lastFetched: lastFetched ?? this.lastFetched,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      totalPages: totalPages ?? this.totalPages,
      totalResults: totalResults ?? this.totalResults,
      etag: etag ?? this.etag,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  bool isStale(Duration maxAge) {
    final now = DateTime.now();
    final age = now.difference(lastUpdated ?? lastFetched);
    return age > maxAge;
  }
}