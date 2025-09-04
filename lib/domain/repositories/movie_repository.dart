import '../entities/movie.dart';
import '../entities/movie_detail.dart';
import '../entities/cast.dart';
import '../entities/filter_options.dart';
import '../entities/paginated_response.dart';
import '../../core/network/api_result.dart';

abstract class MovieRepository {
  Future<ApiResult<PaginatedResponse<Movie>>> getPopularMovies({int page = 1});
  Future<ApiResult<PaginatedResponse<Movie>>> getTopRatedMovies({int page = 1});
  Future<ApiResult<PaginatedResponse<Movie>>> getNowPlayingMovies({int page = 1});
  Future<ApiResult<PaginatedResponse<Movie>>> getTrendingMovies({int page = 1});
  Future<ApiResult<PaginatedResponse<Movie>>> searchMovies(String query, {int page = 1});
  Future<ApiResult<PaginatedResponse<Movie>>> searchMoviesWithFilters(
    String query, 
    FilterOptions filters, {
    int page = 1,
  });
  Future<ApiResult<PaginatedResponse<Movie>>> discoverMovies(
    FilterOptions filters, {
    int page = 1,
  });
  Future<ApiResult<MovieDetail>> getMovieDetails(int movieId);
  Future<ApiResult<List<Cast>>> getMovieCredits(int movieId);
  Future<ApiResult<List<Movie>>> getSimilarMovies(int movieId, {int page = 1});
  Future<ApiResult<List<Movie>>> getPersonMovies(int personId, {int page = 1});
}