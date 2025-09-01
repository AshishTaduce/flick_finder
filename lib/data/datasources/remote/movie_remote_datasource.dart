import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/constants/api_constants.dart';
import '../../models/movie_response_model.dart';
import '../../models/movie_detail_model.dart';
import '../../models/credits_response_model.dart';

class MovieRemoteDataSource {
  final Dio _dio = DioClient.instance;

  Future<ApiResult<MovieResponseModel>> getPopularMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.popularMovies,
        queryParameters: {'page': page},
      );

      final movieResponse = MovieResponseModel.fromJson(response.data);
      return Success(movieResponse);
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure('Unexpected error: ${e.toString()}');
    }
  }

  Future<ApiResult<MovieResponseModel>> getTopRatedMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.topRatedMovies,
        queryParameters: {'page': page},
      );

      final movieResponse = MovieResponseModel.fromJson(response.data);
      return Success(movieResponse);
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure('Unexpected error: ${e.toString()}');
    }
  }

  Future<ApiResult<MovieResponseModel>> searchMovies(String query, {int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.searchMovies,
        queryParameters: {
          'query': query,
          'page': page,
          'include_adult': false,
        },
      );

      final movieResponse = MovieResponseModel.fromJson(response.data);
      return Success(movieResponse);
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure('Unexpected error: ${e.toString()}');
    }
  }

  Future<ApiResult<MovieResponseModel>> searchMoviesWithFilters(
    String query,
    Map<String, dynamic> filters, {
    int page = 1,
  }) async {
    try {
      final queryParameters = {
        'query': query,
        'page': page,
        ...filters,
      };

      final response = await _dio.get(
        ApiConstants.searchMovies,
        queryParameters: queryParameters,
      );

      final movieResponse = MovieResponseModel.fromJson(response.data);
      return Success(movieResponse);
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure('Unexpected error: ${e.toString()}');
    }
  }

  Future<ApiResult<MovieResponseModel>> discoverMovies(
    Map<String, dynamic> filters, {
    int page = 1,
  }) async {
    try {
      final queryParameters = {
        'page': page,
        ...filters,
      };

      final response = await _dio.get(
        ApiConstants.discoverMovies,
        queryParameters: queryParameters,
      );

      final movieResponse = MovieResponseModel.fromJson(response.data);
      return Success(movieResponse);
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure('Unexpected error: ${e.toString()}');
    }
  }

  Future<ApiResult<MovieResponseModel>> getNowPlayingMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.nowPlayingMovies,
        queryParameters: {'page': page},
      );

      final movieResponse = MovieResponseModel.fromJson(response.data);
      return Success(movieResponse);
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure('Unexpected error: ${e.toString()}');
    }
  }

  Future<ApiResult<MovieResponseModel>> getTrendingMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.trendingMovies,
        queryParameters: {'page': page},
      );

      final movieResponse = MovieResponseModel.fromJson(response.data);
      return Success(movieResponse);
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure('Unexpected error: ${e.toString()}');
    }
  }

  Future<ApiResult<MovieDetailModel>> getMovieDetails(int movieId) async {
    try {
      final response = await _dio.get('${ApiConstants.movieDetails}/$movieId');

      final movieDetail = MovieDetailModel.fromJson(response.data);
      return Success(movieDetail);
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure('Unexpected error: ${e.toString()}');
    }
  }

  Future<ApiResult<CreditsResponseModel>> getMovieCredits(int movieId) async {
    try {
      final response = await _dio.get('${ApiConstants.movieCredits}/$movieId/credits');

      final credits = CreditsResponseModel.fromJson(response.data);
      return Success(credits);
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure('Unexpected error: ${e.toString()}');
    }
  }

  Future<ApiResult<MovieResponseModel>> getSimilarMovies(int movieId, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.similarMovies}/$movieId/similar',
        queryParameters: {'page': page},
      );

      final movieResponse = MovieResponseModel.fromJson(response.data);
      return Success(movieResponse);
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure('Unexpected error: ${e.toString()}');
    }
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout';
      case DioExceptionType.badResponse:
        return 'Server error: ${error.response?.statusCode}';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return 'Something went wrong';
    }
  }
}