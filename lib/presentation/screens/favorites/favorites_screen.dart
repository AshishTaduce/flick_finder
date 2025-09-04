import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/user_features_service.dart';
import '../../../domain/entities/movie.dart';
import '../../../data/models/movie_model.dart';
import '../../../shared/theme/app_insets.dart';
import '../../../shared/widgets/movie_card.dart';
import '../../providers/auth_provider.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  List<Movie> _movies = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _movies.clear();
        _currentPage = 1;
        _hasMorePages = true;
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final results = await UserFeaturesService.instance.getFavorites(
        page: _currentPage,
      );

      if (mounted) {
        setState(() {
          if (refresh) {
            _movies = results.map((json) => MovieModel.fromJson(json).toEntity()).toList();
          } else {
            _movies.addAll(results.map((json) => MovieModel.fromJson(json).toEntity()).toList());
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

    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
        actions: [
          if (!_isLoading)
            IconButton(
              onPressed: () => _loadFavorites(refresh: true),
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
              Icons.favorite_border,
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
              'Please login with your TMDB account to view your favorites.',
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
                'Error Loading Favorites',
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
                onPressed: () => _loadFavorites(refresh: true),
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
                Icons.favorite_border,
                size: 80,
                color: Theme.of(context).disabledColor,
              ),
              const SizedBox(height: AppInsets.lg),
              Text(
                'No Favorites Yet',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppInsets.md),
              Text(
                'Mark movies as favorites to see them here.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
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

          return MovieCard(movie: _movies[index]);
        },
      ),
    );
  }
}