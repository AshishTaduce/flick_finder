class ApiConstants {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String apiKey = '997363e638a3ab108c2b55f53bd585fa'; // Replace with your actual API key

  // Endpoints
  static const String popularMovies = '/movie/popular';
  static const String topRatedMovies = '/movie/top_rated';
  static const String nowPlayingMovies = '/movie/now_playing';
  static const String upcomingMovies = '/movie/upcoming';
  static const String searchMovies = '/search/movie';
  static const String searchMulti = '/search/multi';
  static const String discoverMovies = '/discover/movie';
  static const String discoverTv = '/discover/tv';
  static const String genreMovieList = '/genre/movie/list';
  static const String genreTvList = '/genre/tv/list';

  // TMDB Genre IDs mapping
  static const Map<String, int> movieGenreIds = {
    'Action': 28,
    'Adventure': 12,
    'Animation': 16,
    'Comedy': 35,
    'Crime': 80,
    'Documentary': 99,
    'Drama': 18,
    'Family': 10751,
    'Fantasy': 14,
    'History': 36,
    'Horror': 27,
    'Music': 10402,
    'Mystery': 9648,
    'Romance': 10749,
    'Science Fiction': 878,
    'TV Movie': 10770,
    'Thriller': 53,
    'War': 10752,
    'Western': 37,
  };

  // Sort options for TMDB API
  static const Map<String, String> sortOptions = {
    'Popularity Descending': 'popularity.desc',
    'Popularity Ascending': 'popularity.asc',
    'Rating Descending': 'vote_average.desc',
    'Rating Ascending': 'vote_average.asc',
    'Release Date Descending': 'release_date.desc',
    'Release Date Ascending': 'release_date.asc',
    'Title A-Z': 'title.asc',
    'Title Z-A': 'title.desc',
  };
}