import 'movie.dart';
import 'tmdb_list.dart';

class TmdbListDetail extends TmdbList {
  @override
  final List<Movie> items;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TmdbListDetail({
    required super.id,
    required super.name,
    required super.description,
    required super.itemCount,
    super.posterPath,
    super.backdropPath,
    required super.public,
    required super.iso639_1,
    required this.items,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  }) : super(items: items);

  @override
  TmdbListDetail copyWith({
    int? id,
    String? name,
    String? description,
    int? itemCount,
    String? posterPath,
    String? backdropPath,
    bool? public,
    String? iso639_1,
    List<Movie>? items,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TmdbListDetail(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      itemCount: itemCount ?? this.itemCount,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      public: public ?? this.public,
      iso639_1: iso639_1 ?? this.iso639_1,
      items: items ?? this.items,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TmdbListDetail(id: $id, name: $name, itemCount: $itemCount, items: ${items.length})';
  }
}