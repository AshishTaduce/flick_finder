import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_result.dart';
import '../../data/datasources/remote/movie_remote_datasource.dart';
import '../../data/datasources/local/movie_local_datasource.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';

// Providers
final movieRemoteDataSourceProvider = Provider<MovieRemoteDataSource>((ref) {
  return MovieRemoteDataSource();
});

final movieLocalDataSourceProvider = Provider<MovieLocalDataSource>((ref) {
  return MovieLocalDataSource();
});

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  final remoteDataSource = ref.read(movieRemoteDataSourceProvider);
  final localDataSource = ref.read(movieLocalDataSourceProvider);
  return MovieRepositoryImpl(remoteDataSource, localDataSource);
});

// State classes
class MovieState {
  final List<Movie> movies;
  final bool isLoading;
  final String? error;

  const MovieState({
    this.movies = const [],
    this.isLoading = false,
    this.error,
  });

  MovieState copyWith({
    List<Movie>? movies,
    bool? isLoading,
    String? error,
  }) {
    return MovieState(
      movies: movies ?? this.movies,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Movie provider
class MovieNotifier extends StateNotifier<MovieState> {
  final MovieRepository _repository;

  MovieNotifier(this._repository) : super(const MovieState());

  Future<void> getPopularMovies() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getPopularMovies();

    switch (result) {
      case Success(data: final movies):
        state = state.copyWith(
          movies: movies.results,
          isLoading: false,
        );
      case Failure(message: final message):
        state = state.copyWith(
          isLoading: false,
          error: message,
        );
    }
  }
}

final movieProvider = StateNotifierProvider<MovieNotifier, MovieState>((ref) {
  final repository = ref.read(movieRepositoryProvider);
  return MovieNotifier(repository);
});