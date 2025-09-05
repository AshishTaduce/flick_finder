class ApiConstants {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String apiKey = '997363e638a3ab108c2b55f53bd585fa'; ///TODO: Fetch from .env
  // Endpoints
  static const String popularMovies = '/movie/popular';
  static const String topRatedMovies = '/movie/top_rated';
  static const String nowPlayingMovies = '/movie/now_playing';
  static const String upcomingMovies = '/movie/upcoming';
  static const String trendingMovies = '/trending/movie/day';
  static const String searchMovies = '/search/movie';
  static const String searchMulti = '/search/multi';
  static const String discoverMovies = '/discover/movie';
  static const String discoverTv = '/discover/tv';
  static const String genreMovieList = '/genre/movie/list';
  static const String genreTvList = '/genre/tv/list';
  static const String movieDetails = '/movie'; // /movie/{movie_id}
  static const String movieCredits = '/movie'; // /movie/{movie_id}/credits
  static const String similarMovies = '/movie'; // /movie/{movie_id}/similar
  static const String personDetails = '/person'; // /person/{person_id}
  static const String personMovies = '/person'; // /person/{person_id}/movie_credits

  // Authentication endpoints
  static const String createRequestToken = '/authentication/token/new';
  static const String createSession = '/authentication/session/new';
  static const String validateWithLogin = '/authentication/token/validate_with_login';
  static const String deleteSession = '/authentication/session';
  static const String accountDetails = '/account';
  
  // User-specific endpoints
  static const String accountStates = '/movie'; // /movie/{movie_id}/account_states
  static const String addToWatchlist = '/account/{account_id}/watchlist';
  static const String addToFavorites = '/account/{account_id}/favorite';
  static const String rateMovie = '/movie'; // /movie/{movie_id}/rating
  static const String getWatchlist = '/account/{account_id}/watchlist/movies';
  static const String getFavorites = '/account/{account_id}/favorite/movies';
  static const String getRatedMovies = '/account/{account_id}/rated/movies';
  
  // Watch providers endpoint
  static const String watchProviders = '/movie'; // /movie/{movie_id}/watch/providers
  
  // TMDB Lists endpoints
  static const String createList = '/list';
  static const String getList = '/list'; // /list/{list_id}
  static const String addMovieToList = '/list'; // /list/{list_id}/add_item
  static const String removeMovieFromList = '/list'; // /list/{list_id}/remove_item
  static const String deleteList = '/list'; // /list/{list_id}
  static const String getUserLists = '/account/{account_id}/lists';
  
  // Changes API endpoints
  static const String movieChanges = '/movie/changes';
  static const String personChanges = '/person/changes';
  static const String tvChanges = '/tv/changes';

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