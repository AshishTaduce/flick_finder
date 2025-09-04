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
  final bool isLoadingMorePopular;
  final bool isLoadingMoreNowPlaying;
  final bool isLoadingMoreTrending;
  final String? popularError;
  final String? nowPlayingError;
  final String? trendingError;
  final int popularPage;
  final int nowPlayingPage;
  final int trendingPage;
  final bool hasMorePopular;
  final bool hasMoreNowPlaying;
  final bool hasMoreTrending;

  const HomeState({
    this.popularMovies = const [],
    this.nowPlayingMovies = const [],
    this.trendingMovies = const [],
    this.isLoadingPopular = false,
    this.isLoadingNowPlaying = false,
    this.isLoadingTrending = false,
    this.isLoadingMorePopular = false,
    this.isLoadingMoreNowPlaying = false,
    this.isLoadingMoreTrending = false,
    this.popularError,
    this.nowPlayingError,
    this.trendingError,
    this.popularPage = 1,
    this.nowPlayingPage = 1,
    this.trendingPage = 1,
    this.hasMorePopular = true,
    this.hasMoreNowPlaying = true,
    this.hasMoreTrending = true,
  });

  HomeState copyWith({
    List<Movie>? popularMovies,
    List<Movie>? nowPlayingMovies,
    List<Movie>? trendingMovies,
    bool? isLoadingPopular,
    bool? isLoadingNowPlaying,
    bool? isLoadingTrending,
    bool? isLoadingMorePopular,
    bool? isLoadingMoreNowPlaying,
    bool? isLoadingMoreTrending,
    String? popularError,
    String? nowPlayingError,
    String? trendingError,
    int? popularPage,
    int? nowPlayingPage,
    int? trendingPage,
    bool? hasMorePopular,
    bool? hasMoreNowPlaying,
    bool? hasMoreTrending,
  }) {
    return HomeState(
      popularMovies: popularMovies ?? this.popularMovies,
      nowPlayingMovies: nowPlayingMovies ?? this.nowPlayingMovies,
      trendingMovies: trendingMovies ?? this.trendingMovies,
      isLoadingPopular: isLoadingPopular ?? this.isLoadingPopular,
      isLoadingNowPlaying: isLoadingNowPlaying ?? this.isLoadingNowPlaying,
      isLoadingTrending: isLoadingTrending ?? this.isLoadingTrending,
      isLoadingMorePopular: isLoadingMorePopular ?? this.isLoadingMorePopular,
      isLoadingMoreNowPlaying: isLoadingMoreNowPlaying ?? this.isLoadingMoreNowPlaying,
      isLoadingMoreTrending: isLoadingMoreTrending ?? this.isLoadingMoreTrending,
      popularError: popularError,
      nowPlayingError: nowPlayingError,
      trendingError: trendingError,
      popularPage: popularPage ?? this.popularPage,
      nowPlayingPage: nowPlayingPage ?? this.nowPlayingPage,
      trendingPage: trendingPage ?? this.trendingPage,
      hasMorePopular: hasMorePopular ?? this.hasMorePopular,
      hasMoreNowPlaying: hasMoreNowPlaying ?? this.hasMoreNowPlaying,
      hasMoreTrending: hasMoreTrending ?? this.hasMoreTrending,
    );
  }

  bool get isLoading => isLoadingPopular || isLoadingNowPlaying || isLoadingTrending;
  
  bool get hasAnyError => popularError != null || nowPlayingError != null || trendingError != null;
}

// Home Notifier
class HomeNotifier extends StateNotifier<HomeState> {
  final MovieRepository _repository;

  HomeNotifier(this._repository) : super(const HomeState()) {
    // Auto-load movies when the notifier is created
    loadAllMovies();
  }

  Future<void> loadAllMovies() async {
    await Future.wait([
      getPopularMovies(),
      getNowPlayingMovies(),
      getTrendingMovies(),
    ]);
  }

  Future<void> getPopularMovies({bool loadMore = false}) async {
    if (loadMore) {
      if (state.isLoadingMorePopular || !state.hasMorePopular || state.popularMovies.length >= 60) return;
      state = state.copyWith(isLoadingMorePopular: true, popularError: null);
    } else {
      state = state.copyWith(isLoadingPopular: true, popularError: null, popularPage: 1);
    }

    final result = await _repository.getPopularMovies(page: loadMore ? state.popularPage : 1);

    switch (result) {
      case Success(data: final paginatedResponse):
        final updatedMovies = loadMore 
            ? [...state.popularMovies, ...paginatedResponse.results].take(60).toList()
            : paginatedResponse.results;
        
        state = state.copyWith(
          popularMovies: updatedMovies,
          isLoadingPopular: false,
          isLoadingMorePopular: false,
          popularPage: paginatedResponse.page + 1,
          hasMorePopular: paginatedResponse.hasNextPage && updatedMovies.length < 60,
        );
      case Failure(message: final message):
        state = state.copyWith(
          isLoadingPopular: false,
          isLoadingMorePopular: false,
          popularError: message,
        );
    }
  }

  Future<void> getNowPlayingMovies({bool loadMore = false}) async {
    if (loadMore) {
      if (state.isLoadingMoreNowPlaying || !state.hasMoreNowPlaying || state.nowPlayingMovies.length >= 60) return;
      state = state.copyWith(isLoadingMoreNowPlaying: true, nowPlayingError: null);
    } else {
      state = state.copyWith(isLoadingNowPlaying: true, nowPlayingError: null, nowPlayingPage: 1);
    }

    final result = await _repository.getNowPlayingMovies(page: loadMore ? state.nowPlayingPage : 1);

    switch (result) {
      case Success(data: final paginatedResponse):
        final updatedMovies = loadMore 
            ? [...state.nowPlayingMovies, ...paginatedResponse.results].take(60).toList()
            : paginatedResponse.results;
        
        state = state.copyWith(
          nowPlayingMovies: updatedMovies,
          isLoadingNowPlaying: false,
          isLoadingMoreNowPlaying: false,
          nowPlayingPage: paginatedResponse.page + 1,
          hasMoreNowPlaying: paginatedResponse.hasNextPage && updatedMovies.length < 60,
        );
      case Failure(message: final message):
        state = state.copyWith(
          isLoadingNowPlaying: false,
          isLoadingMoreNowPlaying: false,
          nowPlayingError: message,
        );
    }
  }

  Future<void> getTrendingMovies({bool loadMore = false}) async {
    if (loadMore) {
      if (state.isLoadingMoreTrending || !state.hasMoreTrending || state.trendingMovies.length >= 60) return;
      state = state.copyWith(isLoadingMoreTrending: true, trendingError: null);
    } else {
      state = state.copyWith(isLoadingTrending: true, trendingError: null, trendingPage: 1);
    }

    final result = await _repository.getTrendingMovies(page: loadMore ? state.trendingPage : 1);

    switch (result) {
      case Success(data: final paginatedResponse):
        final updatedMovies = loadMore 
            ? [...state.trendingMovies, ...paginatedResponse.results].take(60).toList()
            : paginatedResponse.results;
        
        state = state.copyWith(
          trendingMovies: updatedMovies,
          isLoadingTrending: false,
          isLoadingMoreTrending: false,
          trendingPage: paginatedResponse.page + 1,
          hasMoreTrending: paginatedResponse.hasNextPage && updatedMovies.length < 60,
        );
      case Failure(message: final message):
        state = state.copyWith(
          isLoadingTrending: false,
          isLoadingMoreTrending: false,
          trendingError: message,
        );
    }
  }

  Future<void> refresh() async {
    await loadAllMovies();
  }

  void reset() {
    state = const HomeState();
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final repository = ref.read(movieRepositoryProvider);
  return HomeNotifier(repository);
});