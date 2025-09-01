import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/filter_constant.dart';
import '../../../../domain/entities/filter_options.dart';
import '../../../providers/search_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_insets.dart';
import '../../../../shared/theme/app_typography.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late FilterOptions _currentFilters;

  @override
  void initState() {
    super.initState();
    _currentFilters = ref.read(searchProvider).filters;
  }

  void _updateFilters(FilterOptions newFilters) {
    setState(() {
      _currentFilters = newFilters;
    });
  }

  void _applyFilters() {
    ref.read(searchProvider.notifier).updateFilters(_currentFilters);
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _currentFilters = const FilterOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppInsets.radiusXl),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: AppInsets.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: AppInsets.screenPaddingHorizontal,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Filter Movies',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text('Clear all'),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Filter content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: AppInsets.screenPaddingHorizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categories
                      _buildCategorySection(),
                      const SizedBox(height: AppInsets.xl),

                      // Genres
                      _buildGenreSection(),
                      const SizedBox(height: AppInsets.xl),

                      // Year Range
                      _buildYearRangeSection(),
                      const SizedBox(height: AppInsets.xl),

                      // Rating
                      _buildRatingSection(),
                      const SizedBox(height: AppInsets.xl),

                      // Sort By
                      _buildSortSection(),
                      const SizedBox(height: AppInsets.xl),

                      // Additional Options
                      _buildAdditionalOptionsSection(),
                      const SizedBox(height: AppInsets.xxl),
                    ],
                  ),
                ),
              ),

              // Apply button
              Container(
                padding: AppInsets.screenPadding,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 0.5,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('Apply Filters'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategorySection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppInsets.md),
        Wrap(
          spacing: AppInsets.sm,
          runSpacing: AppInsets.sm,
          children: FilterConstants.categories.map((category) {
            final isSelected = _currentFilters.selectedCategories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                final newCategories = List<String>.from(_currentFilters.selectedCategories);
                if (selected) {
                  if (category == 'All') {
                    newCategories.clear();
                    newCategories.add('All');
                  } else {
                    newCategories.remove('All');
                    newCategories.add(category);
                  }
                } else {
                  newCategories.remove(category);
                }
                _updateFilters(_currentFilters.copyWith(selectedCategories: newCategories));
              },
              backgroundColor: theme.brightness == Brightness.dark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightSurfaceVariant,
              selectedColor: AppColors.primaryRed,
              checkmarkColor: Colors.white,
              labelStyle: AppTypography.chipLabel.copyWith(
                color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenreSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genre',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppInsets.md),
        Wrap(
          spacing: AppInsets.sm,
          runSpacing: AppInsets.sm,
          children: FilterConstants.genres.map((genre) {
            final isSelected = _currentFilters.selectedGenres.contains(genre);
            return FilterChip(
              label: Text(genre),
              selected: isSelected,
              onSelected: (selected) {
                final newGenres = List<String>.from(_currentFilters.selectedGenres);
                if (selected) {
                  newGenres.add(genre);
                } else {
                  newGenres.remove(genre);
                }
                _updateFilters(_currentFilters.copyWith(selectedGenres: newGenres));
              },
              backgroundColor: theme.brightness == Brightness.dark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightSurfaceVariant,
              selectedColor: AppColors.primaryRed,
              checkmarkColor: Colors.white,
              labelStyle: AppTypography.chipLabel.copyWith(
                color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildYearRangeSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Year',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppInsets.sm),
        Text(
          '${_currentFilters.yearRange.start.round()} - ${_currentFilters.yearRange.end.round()}',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.primaryRed,
            fontWeight: AppTypography.semiBold,
          ),
        ),
        const SizedBox(height: AppInsets.md),
        RangeSlider(
          values: _currentFilters.yearRange,
          min: FilterConstants.minYear,
          max: FilterConstants.maxYear,
          divisions: (FilterConstants.maxYear - FilterConstants.minYear).round(),
          labels: RangeLabels(
            _currentFilters.yearRange.start.round().toString(),
            _currentFilters.yearRange.end.round().toString(),
          ),
          activeColor: AppColors.primaryRed,
          inactiveColor: theme.brightness == Brightness.dark
              ? AppColors.darkTextTertiary
              : AppColors.lightTextTertiary,
          onChanged: (RangeValues values) {
            _updateFilters(_currentFilters.copyWith(yearRange: values));
          },
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Rating',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(width: AppInsets.sm),
            const Icon(
              Icons.star,
              color: AppColors.ratingGold,
              size: AppInsets.iconSm,
            ),
          ],
        ),
        const SizedBox(height: AppInsets.md),
        Wrap(
          spacing: AppInsets.sm,
          runSpacing: AppInsets.sm,
          children: FilterConstants.ratingOptions.map((rating) {
            final isSelected = _currentFilters.minRating == rating;
            return FilterChip(
              label: Text(rating == 0.0 ? 'Any' : '${rating.toInt()}+'),
              selected: isSelected,
              onSelected: (selected) {
                _updateFilters(_currentFilters.copyWith(
                  minRating: selected ? rating : 0.0,
                ));
              },
              backgroundColor: theme.brightness == Brightness.dark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightSurfaceVariant,
              selectedColor: AppColors.primaryRed,
              checkmarkColor: Colors.white,
              labelStyle: AppTypography.chipLabel.copyWith(
                color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSortSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppInsets.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppInsets.md),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
            ),
            borderRadius: BorderRadius.circular(AppInsets.radiusMd),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _getSortDisplayName(_currentFilters.sortBy),
              isExpanded: true,
              items: FilterConstants.sortOptions.map((String sortOption) {
                return DropdownMenuItem<String>(
                  value: sortOption,
                  child: Text(sortOption),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  final apiValue = FilterConstants.sortApiValues[newValue] ?? 'popularity.desc';
                  _updateFilters(_currentFilters.copyWith(sortBy: apiValue));
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalOptionsSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Options',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppInsets.md),
        
        // Include Adult Content
        Row(
          children: [
            Expanded(
              child: Text(
                'Include Adult Content',
                style: theme.textTheme.bodyLarge,
              ),
            ),
            Switch(
              value: _currentFilters.includeAdult,
              onChanged: (value) {
                _updateFilters(_currentFilters.copyWith(includeAdult: value));
              },
              activeThumbColor: AppColors.primaryRed,
            ),
          ],
        ),
        
        const SizedBox(height: AppInsets.md),
        
        // Region
        Text(
          'Region',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: AppInsets.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppInsets.md),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
            ),
            borderRadius: BorderRadius.circular(AppInsets.radiusMd),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currentFilters.region.isEmpty ? 'Any' : _currentFilters.region,
              isExpanded: true,
              items: ['Any', ...FilterConstants.regions].map((String region) {
                return DropdownMenuItem<String>(
                  value: region,
                  child: Text(region == 'Any' ? 'Any Region' : region),
                );
              }).toList(),
              onChanged: (String? newValue) {
                final regionValue = newValue == 'Any' ? '' : newValue ?? '';
                _updateFilters(_currentFilters.copyWith(region: regionValue));
              },
            ),
          ),
        ),
      ],
    );
  }

  String _getSortDisplayName(String apiValue) {
    return FilterConstants.sortApiValues.entries
        .firstWhere(
          (entry) => entry.value == apiValue,
          orElse: () => const MapEntry('Popularity Descending', 'popularity.desc'),
        )
        .key;
  }
}