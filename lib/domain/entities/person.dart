class Person {
  final int id;
  final String name;
  final String? biography;
  final String? profilePath;
  final String? birthday;
  final String? deathday;
  final String? placeOfBirth;
  final String knownForDepartment;
  final double popularity;

  const Person({
    required this.id,
    required this.name,
    this.biography,
    this.profilePath,
    this.birthday,
    this.deathday,
    this.placeOfBirth,
    required this.knownForDepartment,
    required this.popularity,
  });

  String get fullProfileUrl => profilePath != null
      ? 'https://image.tmdb.org/t/p/w500$profilePath'
      : '';
}