import '../entities/movie.dart';
import '../entities/filter_options.dart';
import '../../core/network/api_result.dart';

abstract class MovieRepository {
  Future<ApiResult<List<Movie>>> getPopularMovies({int page = 1});
  Future<ApiResult<List<Movie>>> getTopRatedMovies({int page = 1});
  Future<ApiResult<List<Movie>>> getNowPlayingMovies({int page = 1});
  Future<ApiResult<List<Movie>>> getUpcomingMovies({int page = 1});
  Future<ApiResult<List<Movie>>> getTrendingMovies({int page = 1});
  Future<ApiResult<List<Movie>>> searchMovies(String query, {int page = 1});
  Future<ApiResult<List<Movie>>> searchMoviesWithFilters(
    String query, 
    FilterOptions filters, {
    int page = 1,
  });
  Future<ApiResult<List<Movie>>> discoverMovies(
    FilterOptions filters, {
    int page = 1,
  });
}