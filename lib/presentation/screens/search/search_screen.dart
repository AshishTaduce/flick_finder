import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/debouncer.dart';
import '../../../domain/entities/filter_options.dart';
import '../../../shared/widgets/movie_grid.dart';
import '../../providers/search_provider.dart';
import '../home/widgets/error_widget.dart';
import '../home/widgets/loading_widget.dart';
import 'widgets/search_app_bar.dart';
import 'widgets/filter_bottom_sheet.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_insets.dart';
import '../../../shared/theme/app_typography.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 700));
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search App Bar
            SearchAppBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (query) {
                _debouncer.call(() {
                  ref.read(searchProvider.notifier).updateQuery(query);
                });
              },
              onFilterTap: _showFilterBottomSheet,
              hasActiveFilters: searchState.filters.hasActiveFilters,
              activeFilterCount: searchState.filters.activeFilterCount,
            ),

            // Content
            Expanded(
              child: _buildContent(searchState, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(SearchState state, ThemeData theme) {
    if (state.query.isEmpty && !state.filters.hasActiveFilters) {
      return _buildEmptyState();
    }

    if (state.isLoading && state.searchResults.isEmpty) {
      return const LoadingWidget();
    }

    if (state.error != null && state.searchResults.isEmpty) {
      return CustomErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(searchProvider.notifier).updateQuery(state.query),
      );
    }

    final results = state.filteredResults.isNotEmpty
        ? state.filteredResults
        : state.searchResults;

    if (results.isEmpty && state.query.isNotEmpty) {
      return _buildNoResultsState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results header
        Padding(
          padding: AppInsets.screenPaddingHorizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search results for "${state.query}"',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppInsets.xs),
              Text(
                '${results.length} ${results.length == 1 ? 'result' : 'results'} found',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              if (state.filters.hasActiveFilters) ...[
                const SizedBox(height: AppInsets.sm),
                _buildActiveFiltersChips(state.filters, theme),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppInsets.md),

        // Loading indicator if searching
        if (state.isLoading)
          const LinearProgressIndicator(),

        // Results grid
        Expanded(
          child: MovieGrid(movies: results),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: theme.brightness == Brightness.dark
                ? AppColors.darkTextTertiary
                : AppColors.lightTextTertiary,
          ),
          const SizedBox(height: AppInsets.md),
          Text(
            'Discover movies you\'ll love',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppInsets.sm),
          Text(
            'Search for your favorite movies and shows',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.brightness == Brightness.dark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: theme.brightness == Brightness.dark
                ? AppColors.darkTextTertiary
                : AppColors.lightTextTertiary,
          ),
          const SizedBox(height: AppInsets.md),
          Text(
            'No results found',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppInsets.sm),
          Text(
            'Try adjusting your search or filters',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.brightness == Brightness.dark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppInsets.md),
          TextButton(
            onPressed: () {
              ref.read(searchProvider.notifier).clearFilters();
            },
            child: const Text('Clear filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersChips(FilterOptions filters, ThemeData theme) {
    final chips = <Widget>[];

    // Category chips
    for (final category in filters.selectedCategories) {
      chips.add(_buildFilterChip(
        category, 
        theme,
        onRemove: () => ref.read(searchProvider.notifier).removeCategory(category),
      ));
    }

    // Genre chips
    for (final genre in filters.selectedGenres) {
      chips.add(_buildFilterChip(
        genre, 
        theme,
        onRemove: () => ref.read(searchProvider.notifier).removeGenre(genre),
      ));
    }

    // Year range chip
    if (filters.yearRange.start > 2000 || filters.yearRange.end < 2025) {
      chips.add(_buildFilterChip(
        '${filters.yearRange.start.round()}-${filters.yearRange.end.round()}',
        theme,
        onRemove: () => ref.read(searchProvider.notifier).clearYearRange(),
      ));
    }

    // Rating chip
    if (filters.minRating > 0) {
      chips.add(_buildFilterChip(
        '${filters.minRating}+ ⭐', 
        theme,
        onRemove: () => ref.read(searchProvider.notifier).clearRating(),
      ));
    }

    // Sort chip (only if not default)
    if (filters.sortBy != 'popularity.desc') {
      final sortName = _getSortDisplayName(filters.sortBy);
      chips.add(_buildFilterChip(
        'Sort: $sortName', 
        theme,
        onRemove: () => ref.read(searchProvider.notifier).resetSort(),
      ));
    }

    // Adult content chip
    if (filters.includeAdult) {
      chips.add(_buildFilterChip(
        'Adult Content', 
        theme,
        onRemove: () => ref.read(searchProvider.notifier).clearAdultContent(),
      ));
    }

    // Region chip
    if (filters.region.isNotEmpty) {
      chips.add(_buildFilterChip(
        'Region: ${filters.region}', 
        theme,
        onRemove: () => ref.read(searchProvider.notifier).clearRegion(),
      ));
    }

    return Wrap(
      spacing: AppInsets.sm,
      runSpacing: AppInsets.xs,
      children: chips,
    );
  }

  String _getSortDisplayName(String apiValue) {
    const sortApiValues = {
      'popularity.desc': 'Popularity ↓',
      'popularity.asc': 'Popularity ↑',
      'vote_average.desc': 'Rating ↓',
      'vote_average.asc': 'Rating ↑',
      'release_date.desc': 'Release Date ↓',
      'release_date.asc': 'Release Date ↑',
      'title.asc': 'Title A-Z',
      'title.desc': 'Title Z-A',
    };
    return sortApiValues[apiValue] ?? 'Custom';
  }

  Widget _buildFilterChip(String label, ThemeData theme, {required VoidCallback onRemove}) {
    return Chip(
      label: Text(label),
      backgroundColor: AppColors.primaryRed.withValues(alpha: 0.1),
      labelStyle: AppTypography.chipLabel.copyWith(
        color: AppColors.primaryRed,
      ),
      deleteIcon: const Icon(
        Icons.close,
        size: 16,
        color: AppColors.primaryRed,
      ),
      onDeleted: onRemove,
    );
  }
}