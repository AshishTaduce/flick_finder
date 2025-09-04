import 'package:flutter_test/flutter_test.dart';
import 'package:flick_finder/domain/entities/paginated_response.dart';
import 'package:flick_finder/domain/entities/movie.dart';

void main() {
  group('Pagination Fix Tests', () {
    test('PaginatedResponse should correctly identify pagination state', () {
      final movie = Movie(
        id: 1,
        title: 'Test Movie',
        description: 'Test Description',
        releaseDate: DateTime(2023, 1, 1),
        rating: 8.0,
        voteCount: 100,
        genreIds: [28],
      );

      // Test first page
      const firstPage = PaginatedResponse<Movie>(
        results: [],
        page: 1,
        totalPages: 5,
        totalResults: 100,
      );

      expect(firstPage.hasNextPage, true);
      expect(firstPage.hasPreviousPage, false);
      expect(firstPage.isFirstPage, true);
      expect(firstPage.isLastPage, false);

      // Test middle page
      const middlePage = PaginatedResponse<Movie>(
        results: [],
        page: 3,
        totalPages: 5,
        totalResults: 100,
      );

      expect(middlePage.hasNextPage, true);
      expect(middlePage.hasPreviousPage, true);
      expect(middlePage.isFirstPage, false);
      expect(middlePage.isLastPage, false);

      // Test last page
      const lastPage = PaginatedResponse<Movie>(
        results: [],
        page: 5,
        totalPages: 5,
        totalResults: 100,
      );

      expect(lastPage.hasNextPage, false);
      expect(lastPage.hasPreviousPage, true);
      expect(lastPage.isFirstPage, false);
      expect(lastPage.isLastPage, true);

      // Test single page
      const singlePage = PaginatedResponse<Movie>(
        results: [],
        page: 1,
        totalPages: 1,
        totalResults: 10,
      );

      expect(singlePage.hasNextPage, false);
      expect(singlePage.hasPreviousPage, false);
      expect(singlePage.isFirstPage, true);
      expect(singlePage.isLastPage, true);
    });

    test('PaginatedResponse should handle edge cases', () {
      // Test empty results
      const emptyPage = PaginatedResponse<Movie>(
        results: [],
        page: 1,
        totalPages: 0,
        totalResults: 0,
      );

      expect(emptyPage.hasNextPage, false);
      expect(emptyPage.isLastPage, true);

      // Test page beyond total pages (shouldn't happen but handle gracefully)
      const beyondPage = PaginatedResponse<Movie>(
        results: [],
        page: 10,
        totalPages: 5,
        totalResults: 100,
      );

      expect(beyondPage.hasNextPage, false);
      expect(beyondPage.isLastPage, true);
    });
  });
}