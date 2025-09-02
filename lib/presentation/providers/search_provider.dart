
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_result.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/filter_options.dart';
import '../../domain/repositories/movie_repository.dart';
import 'movie_provider.dart';

// Search State
class SearchState {
  final String query;
  final List<Movie> searchResults;
  final List<Movie> filteredResults;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final FilterOptions filters;
  final int currentPage;
  final bool hasMorePages;

  const SearchState({
    this.query = '',
    this.searchResults = const [],
    this.filteredResults = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.filters = const FilterOptions(),
    this.currentPage = 1,
    this.hasMorePages = true,
  });

  SearchState copyWith({
    String? query,
    List<Movie>? searchResults,
    List<Movie>? filteredResults,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    FilterOptions? filters,
    int? currentPage,
    bool? hasMorePages,
  }) {
    return SearchState(
      query: query ?? this.query,
      searchResults: searchResults ?? this.searchResults,
      filteredResults: filteredResults ?? this.filteredResults,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final MovieRepository _repository;

  SearchNotifier(this._repository) : super(const SearchState());

  void updateQuery(String query) {
    state = state.copyWith(
      query: query,
      currentPage: 1,
      hasMorePages: true,
    );
    if (query.isNotEmpty) {
      _searchMovies(query, isNewSearch: true);
    } else {
      // If no query, use discover API with current filters if any filters are active
      if (state.filters.hasActiveFilters) {
        _discoverMovies(isNewSearch: true);
      } else {
        state = state.copyWith(
          searchResults: [],
          filteredResults: [],
          currentPage: 1,
          hasMorePages: true,
        );
      }
    }
  }

  Future<void> _searchMovies(String query, {bool isNewSearch = false}) async {
    if (isNewSearch) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    // Use filtered search if filters are active, otherwise use basic search
    final result = state.filters.hasActiveFilters
        ? await _repository.searchMoviesWithFilters(query, state.filters, page: state.currentPage)
        : await _repository.searchMovies(query, page: state.currentPage);

    switch (result) {
      case Success(data: final movies):
        final updatedMovies = isNewSearch 
            ? movies 
            : [...state.searchResults, ...movies];
        
        state = state.copyWith(
          searchResults: updatedMovies,
          filteredResults: updatedMovies,
          isLoading: false,
          isLoadingMore: false,
          currentPage: state.currentPage + 1,
          hasMorePages: movies.length >= 30, // Updated page size
        );
      case Failure(message: final message):
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: message,
        );
    }
  }

  Future<void> _discoverMovies({bool isNewSearch = false}) async {
    if (isNewSearch) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    final result = await _repository.discoverMovies(state.filters, page: state.currentPage);

    switch (result) {
      case Success(data: final movies):
        final updatedMovies = isNewSearch 
            ? movies 
            : [...state.searchResults, ...movies];
        
        state = state.copyWith(
          searchResults: updatedMovies,
          filteredResults: updatedMovies,
          isLoading: false,
          isLoadingMore: false,
          currentPage: state.currentPage + 1,
          hasMorePages: movies.length >= 30, // Updated page size
        );
      case Failure(message: final message):
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: message,
        );
    }
  }

  void updateFilters(FilterOptions newFilters) {
    state = state.copyWith(
      filters: newFilters,
      currentPage: 1,
      hasMorePages: true,
    );
    
    // Re-search with new filters
    if (state.query.isNotEmpty) {
      _searchMovies(state.query, isNewSearch: true);
    } else if (newFilters.hasActiveFilters) {
      _discoverMovies(isNewSearch: true);
    } else {
      state = state.copyWith(
        searchResults: [],
        filteredResults: [],
        currentPage: 1,
        hasMorePages: true,
      );
    }
  }

  void clearFilters() {
    const emptyFilters = FilterOptions();
    state = state.copyWith(
      filters: emptyFilters,
      currentPage: 1,
      hasMorePages: true,
    );
    
    // Re-search without filters
    if (state.query.isNotEmpty) {
      _searchMovies(state.query, isNewSearch: true);
    } else {
      state = state.copyWith(
        searchResults: [],
        filteredResults: [],
        currentPage: 1,
        hasMorePages: true,
      );
    }
  }

  Future<void> loadMoreResults() async {
    if (state.isLoadingMore || !state.hasMorePages) return;

    if (state.query.isNotEmpty) {
      await _searchMovies(state.query);
    } else if (state.filters.hasActiveFilters) {
      await _discoverMovies();
    }
  }

  void removeCategory(String category) {
    final newCategories = List<String>.from(state.filters.selectedCategories);
    newCategories.remove(category);
    final newFilters = state.filters.copyWith(selectedCategories: newCategories);
    updateFilters(newFilters);
  }

  void removeGenre(String genre) {
    final newGenres = List<String>.from(state.filters.selectedGenres);
    newGenres.remove(genre);
    final newFilters = state.filters.copyWith(selectedGenres: newGenres);
    updateFilters(newFilters);
  }

  void clearYearRange() {
    const defaultRange = RangeValues(2000, 2025);
    final newFilters = state.filters.copyWith(yearRange: defaultRange);
    updateFilters(newFilters);
  }

  void clearRating() {
    final newFilters = state.filters.copyWith(minRating: 0.0);
    updateFilters(newFilters);
  }

  void resetSort() {
    final newFilters = state.filters.copyWith(sortBy: 'popularity.desc');
    updateFilters(newFilters);
  }

  void clearAdultContent() {
    final newFilters = state.filters.copyWith(includeAdult: false);
    updateFilters(newFilters);
  }

  void clearRegion() {
    final newFilters = state.filters.copyWith(region: '');
    updateFilters(newFilters);
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final repository = ref.read(movieRepositoryProvider);
  return SearchNotifier(repository);
});
