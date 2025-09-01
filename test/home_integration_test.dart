import 'package:flutter_test/flutter_test.dart';
import 'package:flick_finder/presentation/providers/home_provider.dart';
import 'package:flick_finder/domain/entities/movie.dart';

void main() {
  group('Home Integration Tests', () {
    test('HomeState should handle multiple movie categories', () {
      final popularMovies = [
        Movie(
          id: 1,
          title: 'Popular Movie 1',
          description: 'Description 1',
          releaseDate: DateTime(2023, 1, 1),
          rating: 8.5,
          voteCount: 1000,
          genreIds: [28, 35],
        ),
      ];

      final nowPlayingMovies = [
        Movie(
          id: 2,
          title: 'Now Playing Movie 1',
          description: 'Description 2',
          releaseDate: DateTime(2024, 1, 1),
          rating: 7.8,
          voteCount: 800,
          genreIds: [18],
        ),
      ];

      final trendingMovies = [
        Movie(
          id: 3,
          title: 'Trending Movie 1',
          description: 'Description 3',
          releaseDate: DateTime(2024, 6, 1),
          rating: 9.2,
          voteCount: 1500,
          genreIds: [878, 28],
        ),
      ];

      const initialState = HomeState();
      expect(initialState.popularMovies, isEmpty);
      expect(initialState.nowPlayingMovies, isEmpty);
      expect(initialState.trendingMovies, isEmpty);
      expect(initialState.isLoading, false);
      expect(initialState.hasAnyError, false);

      final stateWithPopular = initialState.copyWith(
        popularMovies: popularMovies,
        isLoadingPopular: false,
      );
      expect(stateWithPopular.popularMovies, popularMovies);
      expect(stateWithPopular.nowPlayingMovies, isEmpty);
      expect(stateWithPopular.trendingMovies, isEmpty);

      final stateWithAll = stateWithPopular.copyWith(
        nowPlayingMovies: nowPlayingMovies,
        trendingMovies: trendingMovies,
      );
      expect(stateWithAll.popularMovies, popularMovies);
      expect(stateWithAll.nowPlayingMovies, nowPlayingMovies);
      expect(stateWithAll.trendingMovies, trendingMovies);
    });

    test('HomeState should handle loading states correctly', () {
      const state = HomeState(
        isLoadingPopular: true,
        isLoadingNowPlaying: false,
        isLoadingTrending: true,
      );

      expect(state.isLoading, true); // Should be true if any category is loading
      expect(state.isLoadingPopular, true);
      expect(state.isLoadingNowPlaying, false);
      expect(state.isLoadingTrending, true);
    });

    test('HomeState should handle error states correctly', () {
      const state = HomeState(
        popularError: 'Popular movies failed',
        nowPlayingError: null,
        trendingError: 'Trending movies failed',
      );

      expect(state.hasAnyError, true);
      expect(state.popularError, 'Popular movies failed');
      expect(state.nowPlayingError, null);
      expect(state.trendingError, 'Trending movies failed');

      const stateWithoutErrors = HomeState();
      expect(stateWithoutErrors.hasAnyError, false);
    });

    test('HomeState copyWith should work correctly', () {
      const originalState = HomeState(
        isLoadingPopular: true,
        popularError: 'Some error',
      );

      final updatedState = originalState.copyWith(
        isLoadingPopular: false,
        popularError: null,
        popularMovies: [
          Movie(
            id: 1,
            title: 'Test Movie',
            description: 'Test Description',
            releaseDate: DateTime(2023, 1, 1),
            rating: 8.0,
            voteCount: 100,
            genreIds: [28],
          ),
        ],
      );

      expect(updatedState.isLoadingPopular, false);
      expect(updatedState.popularError, null);
      expect(updatedState.popularMovies.length, 1);
      expect(updatedState.popularMovies.first.title, 'Test Movie');

      // Other properties should remain unchanged
      expect(updatedState.isLoadingNowPlaying, originalState.isLoadingNowPlaying);
      expect(updatedState.isLoadingTrending, originalState.isLoadingTrending);
    });
  });
}