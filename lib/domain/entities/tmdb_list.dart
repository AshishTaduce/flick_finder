import 'movie.dart';

class TmdbList {
  final int id;
  final String name;
  final String description;
  final int itemCount;
  final String? posterPath;
  final String? backdropPath;
  final bool public;
  final String iso639_1;
  final List<Movie> items;

  const TmdbList({
    required this.id,
    required this.name,
    required this.description,
    required this.itemCount,
    this.posterPath,
    this.backdropPath,
    required this.public,
    required this.iso639_1,
    this.items = const [],
  });

  TmdbList copyWith({
    int? id,
    String? name,
    String? description,
    int? itemCount,
    String? posterPath,
    String? backdropPath,
    bool? public,
    String? iso639_1,
    List<Movie>? items,
  }) {
    return TmdbList(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      itemCount: itemCount ?? this.itemCount,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      public: public ?? this.public,
      iso639_1: iso639_1 ?? this.iso639_1,
      items: items ?? this.items,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TmdbList &&
      other.id == id &&
      other.name == name &&
      other.description == description &&
      other.itemCount == itemCount &&
      other.posterPath == posterPath &&
      other.backdropPath == backdropPath &&
      other.public == public &&
      other.iso639_1 == iso639_1;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      itemCount.hashCode ^
      posterPath.hashCode ^
      backdropPath.hashCode ^
      public.hashCode ^
      iso639_1.hashCode;
  }

  @override
  String toString() {
    return 'TmdbList(id: $id, name: $name, description: $description, itemCount: $itemCount, public: $public)';
  }
}