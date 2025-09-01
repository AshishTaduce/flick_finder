import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_insets.dart';
import '../../../../shared/theme/app_typography.dart';

class SearchAppBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final VoidCallback onFilterTap;
  final bool hasActiveFilters;
  final int activeFilterCount;

  const SearchAppBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onFilterTap,
    this.hasActiveFilters = false,
    this.activeFilterCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppInsets.md),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Find your movies',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: AppInsets.md),

          // Search bar with filter button
          Row(
            children: [
              // Search field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant,
                    borderRadius: AppInsets.borderRadiusSm,
                  ),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: onChanged,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Search movies, shows...',
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      suffixIcon: controller.text.isNotEmpty
                          ? IconButton(
                        onPressed: () {
                          controller.clear();
                          onChanged('');
                        },
                        icon: Icon(
                          Icons.clear,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppInsets.md,
                        vertical: AppInsets.sm,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppInsets.sm),

              // Filter button
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: hasActiveFilters
                          ? AppColors.primaryRed
                          : (isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.lightSurfaceVariant),
                      borderRadius: AppInsets.borderRadiusSm,
                    ),
                    child: IconButton(
                      onPressed: onFilterTap,
                      icon: Icon(
                        Icons.tune,
                        color: hasActiveFilters
                            ? Colors.white
                            : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                      ),
                    ),
                  ),

                  // Active filter count badge
                  if (hasActiveFilters && activeFilterCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          activeFilterCount.toString(),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primaryRed,
                            fontWeight: AppTypography.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}