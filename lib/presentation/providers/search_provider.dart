
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_result.dart';
import '../../core/services/connectivity_service.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/filter_options.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../data/datasources/local/movie_local_datasource.dart';
import 'movie_provider.dart';
import 'connectivity_provider.dart';

// Search State
class SearchState {
  final String query;
  final List<Movie> searchResults;
  final List<Movie> filteredResults;
  final List<String> searchHistory;
  final List<String> searchSuggestions;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final FilterOptions filters;
  final int currentPage;
  final bool hasMorePages;
  final bool isOfflineSearch;
  final int totalResults;

  const SearchState({
    this.query = '',
    this.searchResults = const [],
    this.filteredResults = const [],
    this.searchHistory = const [],
    this.searchSuggestions = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.filters = const FilterOptions(),
    this.currentPage = 1,
    this.hasMorePages = true,
    this.isOfflineSearch = false,
    this.totalResults = 0,
  });

  SearchState copyWith({
    String? query,
    List<Movie>? searchResults,
    List<Movie>? filteredResults,
    List<String>? searchHistory,
    List<String>? searchSuggestions,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    FilterOptions? filters,
    int? currentPage,
    bool? hasMorePages,
    bool? isOfflineSearch,
    int? totalResults,
  }) {
    return SearchState(
      query: query ?? this.query,
      searchResults: searchResults ?? this.searchResults,
      filteredResults: filteredResults ?? this.filteredResults,
      searchHistory: searchHistory ?? this.searchHistory,
      searchSuggestions: searchSuggestions ?? this.searchSuggestions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isOfflineSearch: isOfflineSearch ?? this.isOfflineSearch,
      totalResults: totalResults ?? this.totalResults,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final MovieRepository _repository;
  final MovieLocalDataSource _localDatasource;
  final ConnectivityService _connectivityService;

  SearchNotifier(this._repository, this._localDatasource, this._connectivityService) 
      : super(const SearchState());

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

    final isOnline = _connectivityService.isOnline;
    
    // For offline search, use local cache
    if (!isOnline) {
      await _performOfflineSearch(query, isNewSearch: isNewSearch);
      return;
    }

    // Use filtered search if filters are active, otherwise use basic search
    final result = state.filters.hasActiveFilters
        ? await _repository.searchMoviesWithFilters(query, state.filters, page: state.currentPage)
        : await _repository.searchMovies(query, page: state.currentPage);

    switch (result) {
      case Success(data: final paginatedResponse):
        final updatedMovies = isNewSearch 
            ? paginatedResponse.results 
            : [...state.searchResults, ...paginatedResponse.results];
        
        state = state.copyWith(
          searchResults: updatedMovies,
          filteredResults: updatedMovies,
          isLoading: false,
          isLoadingMore: false,
          currentPage: paginatedResponse.page + 1,
          hasMorePages: paginatedResponse.hasNextPage,
          totalResults: paginatedResponse.totalResults,
          isOfflineSearch: false,
        );
      case Failure():
        // If online search fails, try offline fallback
        await _performOfflineSearch(query, isNewSearch: isNewSearch, showOfflineMessage: true);
    }
  }

  Future<void> _performOfflineSearch(String query, {bool isNewSearch = false, bool showOfflineMessage = false}) async {
    try {
      final result = await _localDatasource.searchMovies(query);
      switch (result) {
        case Success(data: final cachedMovies):
          final movies = cachedMovies.map((cached) => cached.toEntity()).toList();
          
          // Apply filters if active
          List<Movie> filteredMovies = movies;
          if (state.filters.hasActiveFilters) {
            filteredMovies = _applyFiltersToMovies(movies, state.filters);
          }
          
          final updatedMovies = isNewSearch 
              ? filteredMovies 
              : [...state.searchResults, ...filteredMovies];
          
          state = state.copyWith(
            searchResults: updatedMovies,
            filteredResults: updatedMovies,
            isLoading: false,
            isLoadingMore: false,
            hasMorePages: false, // No pagination for offline search
            isOfflineSearch: true,
            error: showOfflineMessage ? 'Showing cached results (offline)' : null,
          );
        case Failure():
          throw Exception('Search failed');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: 'No cached results found for "$query"',
        isOfflineSearch: true,
      );
    }
  }

  List<Movie> _applyFiltersToMovies(List<Movie> movies, FilterOptions filters) {
    return movies.where((movie) {
      // Apply genre filter
      if (filters.selectedGenres.isNotEmpty) {
        final hasMatchingGenre = movie.genreIds.any((genreId) {
          // This is a simplified check - in a real app you'd map genre IDs to names
          return filters.selectedGenres.contains(genreId.toString());
        });
        if (!hasMatchingGenre) return false;
      }
      
      // Apply rating filter
      if (filters.minRating > 0 && movie.rating < filters.minRating) {
        return false;
      }
      
      // Apply year filter (simplified - would need release date parsing)
      // This is a basic implementation
      
      return true;
    }).toList();
  }

  Future<void> _discoverMovies({bool isNewSearch = false}) async {
    if (isNewSearch) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    final isOnline = _connectivityService.isOnline;
    
    // For offline discovery, use cached popular movies
    if (!isOnline) {
      await _performOfflineDiscovery(isNewSearch: isNewSearch);
      return;
    }

    final result = await _repository.discoverMovies(state.filters, page: state.currentPage);

    switch (result) {
      case Success(data: final paginatedResponse):
        final updatedMovies = isNewSearch 
            ? paginatedResponse.results 
            : [...state.searchResults, ...paginatedResponse.results];
        
        state = state.copyWith(
          searchResults: updatedMovies,
          filteredResults: updatedMovies,
          isLoading: false,
          isLoadingMore: false,
          currentPage: paginatedResponse.page + 1,
          hasMorePages: paginatedResponse.hasNextPage,
          totalResults: paginatedResponse.totalResults,
          isOfflineSearch: false,
        );
      case Failure():
        // If online discovery fails, try offline fallback
        await _performOfflineDiscovery(isNewSearch: isNewSearch, showOfflineMessage: true);
    }
  }

  Future<void> _performOfflineDiscovery({bool isNewSearch = false, bool showOfflineMessage = false}) async {
    try {
      final result = await _localDatasource.getMoviesByCategory('popular');
      switch (result) {
        case Success(data: final cachedMovies):
          final movies = cachedMovies.map((cached) => cached.toEntity()).toList();
          
          // Apply filters
          final filteredMovies = _applyFiltersToMovies(movies, state.filters);
          
          final updatedMovies = isNewSearch 
              ? filteredMovies 
              : [...state.searchResults, ...filteredMovies];
          
          state = state.copyWith(
            searchResults: updatedMovies,
            filteredResults: updatedMovies,
            isLoading: false,
            isLoadingMore: false,
            hasMorePages: false, // No pagination for offline discovery
            isOfflineSearch: true,
            error: showOfflineMessage ? 'Showing cached results (offline)' : null,
          );
        case Failure():
          throw Exception('Failed to get popular movies');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: 'No cached movies available offline',
        isOfflineSearch: true,
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
  final localDatasource = ref.read(movieLocalDatasourceProvider);
  final connectivityService = ref.read(connectivityServiceProvider);
  return SearchNotifier(repository, localDatasource, connectivityService);
});

// Provider for local datasource
final movieLocalDatasourceProvider = Provider<MovieLocalDataSource>((ref) {
  return MovieLocalDataSource();
});
