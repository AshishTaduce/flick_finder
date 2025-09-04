import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/cast.dart';
import '../../../shared/widgets/movie_grid.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_insets.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../providers/person_movies_provider.dart';
import '../home/widgets/error_widget.dart';

class PersonMoviesScreen extends ConsumerStatefulWidget {
  final Cast person;

  const PersonMoviesScreen({
    super.key,
    required this.person,
  });

  @override
  ConsumerState<PersonMoviesScreen> createState() => _PersonMoviesScreenState();
}

class _PersonMoviesScreenState extends ConsumerState<PersonMoviesScreen> {
  @override
  void initState() {
    super.initState();
    // Load person movies when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(personMoviesProvider.notifier).loadPersonMovies(widget.person);
    });
  }

  @override
  void dispose() {
    // Reset the provider state when leaving the screen
    ref.read(personMoviesProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final personMoviesState = ref.watch(personMoviesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.person.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: AppTypography.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: _buildContent(personMoviesState, theme),
      ),
    );
  }

  Widget _buildContent(PersonMoviesState state, ThemeData theme) {
    if (state.isLoading && state.movies.isEmpty) {
      return const MovieGridSkeleton();
    }

    if (state.error != null && state.movies.isEmpty) {
      return CustomErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(personMoviesProvider.notifier).loadPersonMovies(widget.person),
      );
    }

    if (state.movies.isEmpty) {
      return _buildNoMoviesState(theme);
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
                'Movies featuring ${widget.person.name}',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppInsets.xs),
              Text(
                '${state.movies.length} ${state.movies.length == 1 ? 'movie' : 'movies'} found',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppInsets.md),

        // Loading indicator if searching
        if (state.isLoading)
          const LinearProgressIndicator(),

        // Results grid with 3 columns
        Expanded(
          child: MovieGrid(
            movies: state.movies,
            crossAxisCount: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildNoMoviesState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: theme.brightness == Brightness.dark
                ? AppColors.darkTextTertiary
                : AppColors.lightTextTertiary,
          ),
          const SizedBox(height: AppInsets.md),
          Text(
            'No movies found',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppInsets.sm),
          Text(
            'We couldn\'t find any movies for ${widget.person.name}',
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
}