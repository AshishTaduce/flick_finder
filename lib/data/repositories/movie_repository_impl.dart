import '../../core/network/api_result.dart';
import '../../domain/entities/filter_options.dart';
import '../../domain/entities/movie.dart';
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
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<List<Movie>>> getUpcomingMovies({int page = 1}) async {
    // TODO: Implement
    throw UnimplementedError();
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
}