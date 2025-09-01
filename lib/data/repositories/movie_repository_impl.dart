import '../../core/network/api_result.dart';
import '../../domain/entities/filter_options.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_detail.dart';
import '../../domain/entities/cast.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/remote/movie_remote_datasource.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource _remoteDataSource;

  MovieRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<List<Movie>>> getPopularMovies({int page = 1}) async {
    final result = await _remoteDataSource.getPopularMovies(page: page);

    return switch (result) {
      Success(data: final response) => Success(
        response.results.map((model) => model.toEntity()).toList(),
      ),
      Failure(message: final message, code: final code) => Failure(message, code: code),
    };
  }

  @override
  Future<ApiResult<List<Movie>>> getTopRatedMovies({int page = 1}) async {
    final result = await _remoteDataSource.getTopRatedMovies(page: page);

    return switch (result) {
      Success(data: final response) => Success(
        response.results.map((model) => model.toEntity()).toList(),
      ),
      Failure(message: final message, code: final code) => Failure(message, code: code),
    };
  }

  @override
  Future<ApiResult<List<Movie>>> getNowPlayingMovies({int page = 1}) async {
    final result = await _remoteDataSource.getNowPlayingMovies(page: page);

    return switch (result) {
      Success(data: final response) => Success(
        response.results.map((model) => model.toEntity()).toList(),
      ),
      Failure(message: final message, code: final code) => Failure(message, code: code),
    };
  }

  @override
  Future<ApiResult<List<Movie>>> getUpcomingMovies({int page = 1}) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<List<Movie>>> getTrendingMovies({int page = 1}) async {
    final result = await _remoteDataSource.getTrendingMovies(page: page);

    return switch (result) {
      Success(data: final response) => Success(
        response.results.map((model) => model.toEntity()).toList(),
      ),
      Failure(message: final message, code: final code) => Failure(message, code: code),
    };
  }

  @override
  Future<ApiResult<List<Movie>>> searchMovies(String query, {int page = 1}) async {
    try {
      final response = await _remoteDataSource.searchMovies(query, page: page);

      return switch (response) {
        Success(data: final movieResponse) => Success(
          movieResponse.results.map((model) => model.toEntity()).toList(),
        ),
        Failure(message: final message, code: final code) => Failure(message, code: code),
      };
    } catch (e) {
      return Failure('Search failed: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<List<Movie>>> searchMoviesWithFilters(
    String query,
    FilterOptions filters, {
    int page = 1,
  }) async {
    try {
      final filterParams = filters.toQueryParameters();
      final response = await _remoteDataSource.searchMoviesWithFilters(
        query,
        filterParams,
        page: page,
      );

      return switch (response) {
        Success(data: final movieResponse) => Success(
          movieResponse.results.map((model) => model.toEntity()).toList(),
        ),
        Failure(message: final message, code: final code) => Failure(message, code: code),
      };
    } catch (e) {
      return Failure('Filtered search failed: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<List<Movie>>> discoverMovies(
    FilterOptions filters, {
    int page = 1,
  }) async {
    try {
      final filterParams = filters.toQueryParameters();
      final response = await _remoteDataSource.discoverMovies(
        filterParams,
        page: page,
      );

      return switch (response) {
        Success(data: final movieResponse) => Success(
          movieResponse.results.map((model) => model.toEntity()).toList(),
        ),
        Failure(message: final message, code: final code) => Failure(message, code: code),
      };
    } catch (e) {
      return Failure('Discovery failed: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<MovieDetail>> getMovieDetails(int movieId) async {
    try {
      final detailResult = await _remoteDataSource.getMovieDetails(movieId);
      final creditsResult = await _remoteDataSource.getMovieCredits(movieId);

      return switch (detailResult) {
        Success(data: final detailModel) => switch (creditsResult) {
          Success(data: final creditsModel) => Success(
            detailModel.toEntity(cast: creditsModel.cast),
          ),
          Failure(message: final _, code: final _) => Success(
            detailModel.toEntity(), // Return without cast if credits fail
          ),
        },
        Failure(message: final message, code: final code) => Failure(message, code: code),
      };
    } catch (e) {
      return Failure('Failed to get movie details: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<List<Cast>>> getMovieCredits(int movieId) async {
    try {
      final result = await _remoteDataSource.getMovieCredits(movieId);

      return switch (result) {
        Success(data: final creditsModel) => Success(
          creditsModel.cast.map((model) => model.toEntity()).toList(),
        ),
        Failure(message: final message, code: final code) => Failure(message, code: code),
      };
    } catch (e) {
      return Failure('Failed to get movie credits: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<List<Movie>>> getSimilarMovies(int movieId, {int page = 1}) async {
    try {
      final result = await _remoteDataSource.getSimilarMovies(movieId, page: page);

      return switch (result) {
        Success(data: final response) => Success(
          response.results.map((model) => model.toEntity()).toList(),
        ),
        Failure(message: final message, code: final code) => Failure(message, code: code),
      };
    } catch (e) {
      return Failure('Failed to get similar movies: ${e.toString()}');
    }
  }
}