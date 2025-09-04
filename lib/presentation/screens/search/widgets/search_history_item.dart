import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_insets.dart';

class SearchHistoryItem extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SearchHistoryItem({
    super.key,
    required this.query,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppInsets.xs,
        vertical: AppInsets.xs,
      ),
      leading: Icon(
        Icons.history,
        color: theme.brightness == Brightness.dark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary,
        size: 20,
      ),
      title: Text(
        query,
        style: theme.textTheme.bodyMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.close,
          color: theme.brightness == Brightness.dark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          size: 18,
        ),
        onPressed: onDelete,
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
        padding: EdgeInsets.zero,
        tooltip: 'Remove from history',
      ),
      onTap: onTap,
    );
  }
}