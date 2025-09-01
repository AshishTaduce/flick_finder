import 'package:flutter_test/flutter_test.dart';
import 'package:flick_finder/core/constants/api_constants.dart';
import 'package:flick_finder/domain/entities/filter_options.dart';
import 'package:flutter/material.dart';

void main() {
  group('TMDB API Integration Tests', () {
    test('FilterOptions should generate correct query parameters', () {
      const filters = FilterOptions(
        selectedGenres: ['Action', 'Comedy'],
        yearRange: RangeValues(2020, 2023),
        minRating: 7.0,
        sortBy: 'vote_average.desc',
        includeAdult: false,
        region: 'US',
      );

      final queryParams = filters.toQueryParameters();

      expect(queryParams['with_genres'], '28,35'); // Action=28, Comedy=35
      expect(queryParams['primary_release_date.gte'], '2020-01-01');
      expect(queryParams['primary_release_date.lte'], '2023-12-31');
      expect(queryParams['vote_average.gte'], 7.0);
      expect(queryParams['sort_by'], 'vote_average.desc');
      expect(queryParams['include_adult'], false);
      expect(queryParams['region'], 'US');
    });

    test('FilterOptions should handle empty filters correctly', () {
      const filters = FilterOptions();
      final queryParams = filters.toQueryParameters();

      expect(queryParams['sort_by'], 'popularity.desc');
      expect(queryParams['include_adult'], false);
      expect(queryParams.containsKey('with_genres'), false);
      expect(queryParams.containsKey('primary_release_date.gte'), false);
      expect(queryParams.containsKey('primary_release_date.lte'), false);
      expect(queryParams.containsKey('vote_average.gte'), false);
      expect(queryParams.containsKey('region'), false);
    });

    test('Genre mapping should work correctly', () {
      expect(ApiConstants.movieGenreIds['Action'], 28);
      expect(ApiConstants.movieGenreIds['Comedy'], 35);
      expect(ApiConstants.movieGenreIds['Science Fiction'], 878);
      expect(ApiConstants.movieGenreIds['Horror'], 27);
    });

    test('Sort options mapping should work correctly', () {
      expect(ApiConstants.sortOptions['Popularity Descending'], 'popularity.desc');
      expect(ApiConstants.sortOptions['Rating Descending'], 'vote_average.desc');
      expect(ApiConstants.sortOptions['Release Date Descending'], 'release_date.desc');
    });

    test('FilterOptions should detect active filters correctly', () {
      const emptyFilters = FilterOptions();
      expect(emptyFilters.hasActiveFilters, false);
      expect(emptyFilters.activeFilterCount, 0);

      const filtersWithGenres = FilterOptions(selectedGenres: ['Action']);
      expect(filtersWithGenres.hasActiveFilters, true);
      expect(filtersWithGenres.activeFilterCount, 1);

      const filtersWithMultiple = FilterOptions(
        selectedGenres: ['Action'],
        minRating: 7.0,
        yearRange: RangeValues(2020, 2023),
      );
      expect(filtersWithMultiple.hasActiveFilters, true);
      expect(filtersWithMultiple.activeFilterCount, 3);
    });

    test('FilterOptions copyWith should work for individual filter removal', () {
      const originalFilters = FilterOptions(
        selectedGenres: ['Action', 'Comedy', 'Horror'],
        selectedCategories: ['Movies', 'TV Shows'],
        minRating: 7.0,
        includeAdult: true,
        region: 'US',
      );

      // Remove one genre
      final withoutAction = originalFilters.copyWith(
        selectedGenres: ['Comedy', 'Horror'],
      );
      expect(withoutAction.selectedGenres, ['Comedy', 'Horror']);
      expect(withoutAction.selectedCategories, ['Movies', 'TV Shows']); // Should remain unchanged
      expect(withoutAction.minRating, 7.0); // Should remain unchanged

      // Remove category
      final withoutCategory = originalFilters.copyWith(
        selectedCategories: ['Movies'],
      );
      expect(withoutCategory.selectedCategories, ['Movies']);
      expect(withoutCategory.selectedGenres, ['Action', 'Comedy', 'Horror']); // Should remain unchanged

      // Clear rating
      final withoutRating = originalFilters.copyWith(minRating: 0.0);
      expect(withoutRating.minRating, 0.0);
      expect(withoutRating.selectedGenres, ['Action', 'Comedy', 'Horror']); // Should remain unchanged

      // Clear adult content
      final withoutAdult = originalFilters.copyWith(includeAdult: false);
      expect(withoutAdult.includeAdult, false);
      expect(withoutAdult.region, 'US'); // Should remain unchanged

      // Clear region
      final withoutRegion = originalFilters.copyWith(region: '');
      expect(withoutRegion.region, '');
      expect(withoutRegion.includeAdult, true); // Should remain unchanged
    });
  });
}