import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_detail.dart';
import '../../domain/entities/cast.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../core/network/api_result.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../data/datasources/remote/movie_remote_datasource.dart';
import '../../data/datasources/local/movie_local_datasource.dart';

// Provider for movie repository
final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  final remoteDataSource = MovieRemoteDataSource();
  final localDataSource = MovieLocalDataSource();
  return MovieRepositoryImpl(remoteDataSource, localDataSource);
});

// State classes
class MovieDetailState {
  final MovieDetail? movieDetail;
  final List<Cast> cast;
  final List<Movie> similarMovies;
  final bool isLoadingDetail;
  final bool isLoadingCast;
  final bool isLoadingSimilar;
  final String? errorDetail;
  final String? errorCast;
  final String? errorSimilar;

  const MovieDetailState({
    this.movieDetail,
    this.cast = const [],
    this.similarMovies = const [],
    this.isLoadingDetail = false,
    this.isLoadingCast = false,
    this.isLoadingSimilar = false,
    this.errorDetail,
    this.errorCast,
    this.errorSimilar,
  });

  MovieDetailState copyWith({
    MovieDetail? movieDetail,
    List<Cast>? cast,
    List<Movie>? similarMovies,
    bool? isLoadingDetail,
    bool? isLoadingCast,
    bool? isLoadingSimilar,
    String? errorDetail,
    String? errorCast,
    String? errorSimilar,
  }) {
    return MovieDetailState(
      movieDetail: movieDetail ?? this.movieDetail,
      cast: cast ?? this.cast,
      similarMovies: similarMovies ?? this.similarMovies,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isLoadingCast: isLoadingCast ?? this.isLoadingCast,
      isLoadingSimilar: isLoadingSimilar ?? this.isLoadingSimilar,
      errorDetail: errorDetail ?? this.errorDetail,
      errorCast: errorCast ?? this.errorCast,
      errorSimilar: errorSimilar ?? this.errorSimilar,
    );
  }
}

// Movie Detail Provider
class MovieDetailNotifier extends StateNotifier<MovieDetailState> {
  final MovieRepository _repository;
  final int movieId;

  MovieDetailNotifier(this._repository, this.movieId) : super(const MovieDetailState()) {
    loadAllMovieData();
  }

  Future<void> loadMovieDetails() async {
    state = state.copyWith(isLoadingDetail: true, errorDetail: null);

    final result = await _repository.getMovieDetails(movieId);

    switch (result) {
      case Success(data: final movieDetail):
        state = state.copyWith(
          movieDetail: movieDetail,
          cast: movieDetail.cast,
          isLoadingDetail: false,
        );
        break;
      case Failure(message: final message):
        state = state.copyWith(
          isLoadingDetail: false,
          errorDetail: message,
        );
        break;
    }
  }

  Future<void> loadSimilarMovies() async {
    state = state.copyWith(isLoadingSimilar: true, errorSimilar: null);

    final result = await _repository.getSimilarMovies(movieId);

    switch (result) {
      case Success(data: final movies):
        state = state.copyWith(
          similarMovies: movies,
          isLoadingSimilar: false,
        );
        break;
      case Failure(message: final message):
        state = state.copyWith(
          isLoadingSimilar: false,
          errorSimilar: message,
        );
        break;
    }
  }

  Future<void> loadAllMovieData() async {
    await Future.wait([
      loadMovieDetails(),
      loadSimilarMovies(),
    ]);
  }
}

// Family provider for movie detail - each movie gets its own provider instance
final movieDetailProvider = StateNotifierProvider.family<MovieDetailNotifier, MovieDetailState, int>((ref, movieId) {
  final repository = ref.watch(movieRepositoryProvider);
  return MovieDetailNotifier(repository, movieId);
});