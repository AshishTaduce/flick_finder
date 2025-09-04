import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/user_features_service.dart';
import '../../../domain/entities/movie.dart';
import '../../../data/models/movie_model.dart';
import '../../../shared/theme/app_insets.dart';
import '../../../shared/widgets/movie_card.dart';
import '../../providers/auth_provider.dart';

class RatedMoviesScreen extends ConsumerStatefulWidget {
  const RatedMoviesScreen({super.key});

  @override
  ConsumerState<RatedMoviesScreen> createState() => _RatedMoviesScreenState();
}

class _RatedMoviesScreenState extends ConsumerState<RatedMoviesScreen> {
  List<Movie> _movies = [];
  List<double> _ratings = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;

  @override
  void initState() {
    super.initState();
    _loadRatedMovies();
  }

  Future<void> _loadRatedMovies({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _movies.clear();
        _ratings.clear();
        _currentPage = 1;
        _hasMorePages = true;
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final results = await UserFeaturesService.instance.getRatedMovies(
        page: _currentPage,
      );

      if (mounted) {
        setState(() {
          if (refresh) {
            _movies = results.map((json) => MovieModel.fromJson(json).toEntity()).toList();
            _ratings = results.map((json) => (json['rating'] as num?)?.toDouble() ?? 0.0).toList();
          } else {
            _movies.addAll(results.map((json) => MovieModel.fromJson(json).toEntity()).toList());
            _ratings.addAll(results.map((json) => (json['rating'] as num?)?.toDouble() ?? 0.0).toList());
          }
          _hasMorePages = results.length == 20; // TMDB returns 20 items per page
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreMovies() async {
    if (_isLoading || !_hasMorePages) return;

    setState(() {
      _currentPage++;
    });

    await _loadRatedMovies();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rated Movies'),
        centerTitle: true,
        actions: [
          if (!_isLoading)
            IconButton(
              onPressed: () => _loadRatedMovies(refresh: true),
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: authState.isGuest || !authState.isAuthenticated
          ? _buildGuestMessage()
          : _buildContent(),
    );
  }

  Widget _buildGuestMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppInsets.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_border,
              size: 80,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: AppInsets.lg),
            Text(
              'Login Required',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppInsets.md),
            Text(
              'Please login with your TMDB account to view your rated movies.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppInsets.lg),
            ElevatedButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
              },
              child: const Text('Login with TMDB'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _movies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _movies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppInsets.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: AppInsets.lg),
              Text(
                'Error Loading Rated Movies',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppInsets.md),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppInsets.lg),
              ElevatedButton(
                onPressed: () => _loadRatedMovies(refresh: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_movies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppInsets.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_border,
                size: 80,
                color: Theme.of(context).disabledColor,
              ),
              const SizedBox(height: AppInsets.lg),
              Text(
                'No Rated Movies Yet',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppInsets.md),
              Text(
                'Rate movies to see them here with your ratings.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Summary header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppInsets.md),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Rated Movies',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppInsets.xs),
              Text(
                '${_movies.length} ${_movies.length == 1 ? 'movie' : 'movies'} rated',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              if (_movies.isNotEmpty) ...[
                const SizedBox(height: AppInsets.xs),
                Text(
                  'Average rating: ${_calculateAverageRating().toStringAsFixed(1)}/10',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Movies grid
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                  _hasMorePages &&
                  !_isLoading) {
                _loadMoreMovies();
              }
              return false;
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(AppInsets.md),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: AppInsets.md,
                mainAxisSpacing: AppInsets.md,
              ),
              itemCount: _movies.length + (_hasMorePages ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _movies.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppInsets.md),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final movie = _movies[index];
                final rating = _ratings[index];
                
                return Stack(
                  children: [
                    MovieCard(
                      movie: movie,
                      showAddToListButton: false,
                    ),
                    
                    // User rating overlay
                    Positioned(
                      top: AppInsets.xs,
                      right: AppInsets.xs,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppInsets.sm,
                          vertical: AppInsets.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(AppInsets.radiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  double _calculateAverageRating() {
    if (_ratings.isEmpty) return 0.0;
    final sum = _ratings.reduce((a, b) => a + b);
    return sum / _ratings.length;
  }
}