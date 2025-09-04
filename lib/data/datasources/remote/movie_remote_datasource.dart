import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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

      if (response.data == null) {
        return Failure('No data received from server');
      }
      debugPrint("Response Data: ${response.data}");
      final movieDetail = MovieDetailModel.fromJson(response.data as Map<String, dynamic>);
      return Success(movieDetail);
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } on TypeError catch (e) {
      return Failure('Data parsing error: ${e.toString()}');
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

  Future<ApiResult<MovieResponseModel>> getPersonMovies(int personId, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.personMovies}/$personId/movie_credits',
      );

      // Transform the person credits response to match MovieResponseModel
      final credits = response.data['cast'] as List<dynamic>;
      final transformedData = {
        'page': 1,
        'results': credits,
        'total_pages': 1,
        'total_results': credits.length,
      };

      final movieResponse = MovieResponseModel.fromJson(transformedData);
      return Success(movieResponse);
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure('Unexpected error: ${e.toString()}');
    }
  }

  // TMDB Changes API for incremental updates
  Future<ApiResult<Map<String, dynamic>>> getMovieChanges(
    int movieId, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dio.get(
        '${ApiConstants.movieDetails}/$movieId/changes',
        queryParameters: queryParams,
      );

      return Success(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure('Unexpected error: ${e.toString()}');
    }
  }

  // Get latest movie changes for batch updates
  Future<ApiResult<Map<String, dynamic>>> getLatestChanges({
    String? startDate,
    String? endDate,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
      };
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dio.get(
        ApiConstants.movieChanges,
        queryParameters: queryParams,
      );

      return Success(response.data as Map<String, dynamic>);
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
        return 'Connection timeout. Please check your internet connection and try again.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 429) {
          return 'Too many requests. Please wait a moment and try again.';
        } else if (statusCode != null && statusCode >= 500) {
          return 'Server is temporarily unavailable. Please try again later.';
        } else if (statusCode == 401) {
          return 'Authentication failed. Please check your API key.';
        } else if (statusCode == 404) {
          return 'The requested content was not found.';
        }
        return 'Server error: $statusCode';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network and try again.';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}