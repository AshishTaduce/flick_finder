import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/cast.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../core/network/api_result.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../data/datasources/remote/movie_remote_datasource.dart';

// Provider for movie repository (reuse existing one)
final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return MovieRepositoryImpl(MovieRemoteDataSource());
});

// State class for person movies
class PersonMoviesState {
  final List<Movie> movies;
  final bool isLoading;
  final String? error;
  final Cast? person;

  const PersonMoviesState({
    this.movies = const [],
    this.isLoading = false,
    this.error,
    this.person,
  });

  PersonMoviesState copyWith({
    List<Movie>? movies,
    bool? isLoading,
    String? error,
    Cast? person,
  }) {
    return PersonMoviesState(
      movies: movies ?? this.movies,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      person: person ?? this.person,
    );
  }
}

// Person Movies Provider
class PersonMoviesNotifier extends StateNotifier<PersonMoviesState> {
  final MovieRepository _repository;

  PersonMoviesNotifier(this._repository) : super(const PersonMoviesState());

  Future<void> loadPersonMovies(Cast person) async {
    state = state.copyWith(
      isLoading: true, 
      error: null, 
      person: person,
    );

    final result = await _repository.getPersonMovies(person.id);

    switch (result) {
      case Success(data: final movies):
        state = state.copyWith(
          movies: movies,
          isLoading: false,
        );
        break;
      case Failure(message: final message):
        state = state.copyWith(
          isLoading: false,
          error: message,
        );
        break;
    }
  }

  void reset() {
    state = const PersonMoviesState();
  }
}

// Provider for person movies
final personMoviesProvider = StateNotifierProvider<PersonMoviesNotifier, PersonMoviesState>((ref) {
  final repository = ref.watch(movieRepositoryProvider);
  return PersonMoviesNotifier(repository);
});