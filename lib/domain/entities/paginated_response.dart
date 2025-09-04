class PaginatedResponse<T> {
  final List<T> results;
  final int page;
  final int totalPages;
  final int totalResults;

  const PaginatedResponse({
    required this.results,
    required this.page,
    required this.totalPages,
    required this.totalResults,
  });

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
  bool get isFirstPage => page == 1;
  bool get isLastPage => page >= totalPages;
}