import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_result.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import 'movie_provider.dart';

// Home State
class HomeState {
  final List<Movie> popularMovies;
  final List<Movie> nowPlayingMovies;
  final List<Movie> trendingMovies;
  final bool isLoadingPopular;
  final bool isLoadingNowPlaying;
  final bool isLoadingTrending;
  final String? popularError;
  final String? nowPlayingError;
  final String? trendingError;

  const HomeState({
    this.popularMovies = const [],
    this.nowPlayingMovies = const [],
    this.trendingMovies = const [],
    this.isLoadingPopular = false,
    this.isLoadingNowPlaying = false,
    this.isLoadingTrending = false,
    this.popularError,
    this.nowPlayingError,
    this.trendingError,
  });

  HomeState copyWith({
    List<Movie>? popularMovies,
    List<Movie>? nowPlayingMovies,
    List<Movie>? trendingMovies,
    bool? isLoadingPopular,
    bool? isLoadingNowPlaying,
    bool? isLoadingTrending,
    String? popularError,
    String? nowPlayingError,
    String? trendingError,
  }) {
    return HomeState(
      popularMovies: popularMovies ?? this.popularMovies,
      nowPlayingMovies: nowPlayingMovies ?? this.nowPlayingMovies,
      trendingMovies: trendingMovies ?? this.trendingMovies,
      isLoadingPopular: isLoadingPopular ?? this.isLoadingPopular,
      isLoadingNowPlaying: isLoadingNowPlaying ?? this.isLoadingNowPlaying,
      isLoadingTrending: isLoadingTrending ?? this.isLoadingTrending,
      popularError: popularError,
      nowPlayingError: nowPlayingError,
      trendingError: trendingError,
    );
  }

  bool get isLoading => isLoadingPopular || isLoadingNowPlaying || isLoadingTrending;
  
  bool get hasAnyError => popularError != null || nowPlayingError != null || trendingError != null;
}

// Home Notifier
class HomeNotifier extends StateNotifier<HomeState> {
  final MovieRepository _repository;

  HomeNotifier(this._repository) : super(const HomeState());

  Future<void> loadAllMovies() async {
    await Future.wait([
      getPopularMovies(),
      getNowPlayingMovies(),
      getTrendingMovies(),
    ]);
  }

  Future<void> getPopularMovies() async {
    state = state.copyWith(isLoadingPopular: true, popularError: null);

    final result = await _repository.getPopularMovies();

    switch (result) {
      case Success(data: final movies):
        state = state.copyWith(
          popularMovies: movies,
          isLoadingPopular: false,
        );
      case Failure(message: final message):
        state = state.copyWith(
          isLoadingPopular: false,
          popularError: message,
        );
    }
  }

  Future<void> getNowPlayingMovies() async {
    state = state.copyWith(isLoadingNowPlaying: true, nowPlayingError: null);

    final result = await _repository.getNowPlayingMovies();

    switch (result) {
      case Success(data: final movies):
        state = state.copyWith(
          nowPlayingMovies: movies,
          isLoadingNowPlaying: false,
        );
      case Failure(message: final message):
        state = state.copyWith(
          isLoadingNowPlaying: false,
          nowPlayingError: message,
        );
    }
  }

  Future<void> getTrendingMovies() async {
    state = state.copyWith(isLoadingTrending: true, trendingError: null);

    final result = await _repository.getTrendingMovies();

    switch (result) {
      case Success(data: final movies):
        state = state.copyWith(
          trendingMovies: movies,
          isLoadingTrending: false,
        );
      case Failure(message: final message):
        state = state.copyWith(
          isLoadingTrending: false,
          trendingError: message,
        );
    }
  }

  Future<void> refresh() async {
    await loadAllMovies();
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final repository = ref.read(movieRepositoryProvider);
  return HomeNotifier(repository);
});