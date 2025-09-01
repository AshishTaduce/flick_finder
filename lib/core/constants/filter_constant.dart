class FilterConstants {
  static const List<String> categories = [
    'All',
    'Movies',
    'TV Shows',
    'Documentaries',
    'Animation',
  ];

  static const List<String> genres = [
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Mystery',
    'Romance',
    'Science Fiction',
    'Thriller',
    'War',
    'Western',
  ];

  static const double minYear = 1950;
  static const double maxYear = 2025;
  static const double defaultMinYear = 2000;
  static const double defaultMaxYear = 2025;

  static const List<double> ratingOptions = [0.0, 5.0, 6.0, 7.0, 8.0, 9.0];

  static const List<String> sortOptions = [
    'Popularity Descending',
    'Popularity Ascending',
    'Rating Descending',
    'Rating Ascending',
    'Release Date Descending',
    'Release Date Ascending',
    'Title A-Z',
    'Title Z-A',
  ];

  static const Map<String, String> sortApiValues = {
    'Popularity Descending': 'popularity.desc',
    'Popularity Ascending': 'popularity.asc',
    'Rating Descending': 'vote_average.desc',
    'Rating Ascending': 'vote_average.asc',
    'Release Date Descending': 'release_date.desc',
    'Release Date Ascending': 'release_date.asc',
    'Title A-Z': 'title.asc',
    'Title Z-A': 'title.desc',
  };

  static const List<String> regions = [
    'US', 'GB', 'CA', 'AU', 'DE', 'FR', 'IT', 'ES', 'JP', 'KR', 'IN', 'BR'
  ];
}