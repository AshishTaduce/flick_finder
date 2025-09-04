class Cast {
  final int id;
  final String name;
  final String character;
  final String? profilePath;
  final int order;

  const Cast({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    required this.order,
  });

  String get fullProfileUrl => profilePath != null
      ? 'https://image.tmdb.org/t/p/w500$profilePath'
      : '';
}