import 'package:flutter/material.dart';

class FilterOptions {
  final List<String> selectedCategories;
  final List<String> selectedGenres;
  final RangeValues yearRange;
  final double minRating;
  final String sortBy;
  final bool includeAdult;
  final String region;

  const FilterOptions({
    this.selectedCategories = const [],
    this.selectedGenres = const [],
    this.yearRange = const RangeValues(2000, 2025),
    this.minRating = 0.0,
    this.sortBy = 'popularity.desc',
    this.includeAdult = false,
    this.region = '',
  });

  FilterOptions copyWith({
    List<String>? selectedCategories,
    List<String>? selectedGenres,
    RangeValues? yearRange,
    double? minRating,
    String? sortBy,
    bool? includeAdult,
    String? region,
  }) {
    return FilterOptions(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedGenres: selectedGenres ?? this.selectedGenres,
      yearRange: yearRange ?? this.yearRange,
      minRating: minRating ?? this.minRating,
      sortBy: sortBy ?? this.sortBy,
      includeAdult: includeAdult ?? this.includeAdult,
      region: region ?? this.region,
    );
  }

  bool get hasActiveFilters {
    return selectedCategories.isNotEmpty ||
        selectedGenres.isNotEmpty ||
        yearRange.start > 2000 ||
        yearRange.end < 2025 ||
        minRating > 0.0 ||
        sortBy != 'popularity.desc' ||
        includeAdult ||
        region.isNotEmpty;
  }

  int get activeFilterCount {
    int count = 0;
    if (selectedCategories.isNotEmpty) count++;
    if (selectedGenres.isNotEmpty) count++;
    if (yearRange.start > 2000 || yearRange.end < 2025) count++;
    if (minRating > 0.0) count++;
    if (sortBy != 'popularity.desc') count++;
    if (includeAdult) count++;
    if (region.isNotEmpty) count++;
    return count;
  }

  // Convert to TMDB API query parameters
  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};

    // Genre IDs
    if (selectedGenres.isNotEmpty) {
      final genreIds = selectedGenres
          .map((genre) => _getGenreId(genre))
          .where((id) => id != null)
          .join(',');
      if (genreIds.isNotEmpty) {
        params['with_genres'] = genreIds;
      }
    }

    // Year range
    if (yearRange.start > 2000) {
      params['primary_release_date.gte'] = '${yearRange.start.round()}-01-01';
    }
    if (yearRange.end < 2025) {
      params['primary_release_date.lte'] = '${yearRange.end.round()}-12-31';
    }

    // Rating
    if (minRating > 0) {
      params['vote_average.gte'] = minRating;
    }

    // Sort
    params['sort_by'] = sortBy;

    // Adult content
    params['include_adult'] = includeAdult;

    // Region
    if (region.isNotEmpty) {
      params['region'] = region;
    }

    return params;
  }

  int? _getGenreId(String genreName) {
    // This would typically come from ApiConstants.movieGenreIds
    const genreMap = {
      'Action': 28,
      'Adventure': 12,
      'Animation': 16,
      'Comedy': 35,
      'Crime': 80,
      'Documentary': 99,
      'Drama': 18,
      'Family': 10751,
      'Fantasy': 14,
      'History': 36,
      'Horror': 27,
      'Music': 10402,
      'Mystery': 9648,
      'Romance': 10749,
      'Science Fiction': 878,
      'Thriller': 53,
      'War': 10752,
      'Western': 37,
    };
    return genreMap[genreName];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilterOptions &&
        other.selectedCategories.toString() == selectedCategories.toString() &&
        other.selectedGenres.toString() == selectedGenres.toString() &&
        other.yearRange == yearRange &&
        other.minRating == minRating &&
        other.sortBy == sortBy &&
        other.includeAdult == includeAdult &&
        other.region == region;
  }

  @override
  int get hashCode {
    return selectedCategories.hashCode ^
    selectedGenres.hashCode ^
    yearRange.hashCode ^
    minRating.hashCode ^
    sortBy.hashCode ^
    includeAdult.hashCode ^
    region.hashCode;
  }
}