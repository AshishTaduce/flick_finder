import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_insets.dart';
import '../../providers/home_provider.dart';
import '../../widgets/auth_status_widget.dart';
import 'widgets/movie_carousel.dart';
import 'widgets/paginated_horizontal_movie_list.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToSearch;

  const HomeScreen({super.key, this.onNavigateToSearch});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch all movies when screen loads
    _loadMoviesIfNeeded();
  }

  void _loadMoviesIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeState = ref.read(homeProvider);
      // Only load if we don't have any movies and aren't already loading
      if (homeState.popularMovies.isEmpty && 
          homeState.nowPlayingMovies.isEmpty && 
          homeState.trendingMovies.isEmpty && 
          !homeState.isLoading) {
        ref.read(homeProvider.notifier).loadAllMovies();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    
    // Ensure data is loaded when the widget builds
    ref.listen(homeProvider, (previous, next) {
      // If we just cleared the state (like after auth change), reload data
      if (previous != null && 
          previous.popularMovies.isNotEmpty && 
          next.popularMovies.isEmpty && 
          !next.isLoading) {
        Future.microtask(() => ref.read(homeProvider.notifier).loadAllMovies());
      }
    });

    return RefreshIndicator(
      onRefresh: () => ref.read(homeProvider.notifier).refresh(),
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Auth Status
                Padding(
                  padding: const EdgeInsets.all(AppInsets.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Flick Finder',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const AuthStatusWidget(),
                    ],
                  ),
                ),
                
                // Popular Movies Carousel
                MovieCarousel(
                  movies: homeState.popularMovies,
                  isLoading: homeState.isLoadingPopular,
                  error: homeState.popularError,
                  onRetry: () =>
                      ref.read(homeProvider.notifier).getPopularMovies(),
                ),

                const SizedBox(height: AppInsets.xl),

                // Now Playing Movies
                PaginatedHorizontalMovieList(
                  title: 'Now Playing',
                  movies: homeState.nowPlayingMovies,
                  isLoading: homeState.isLoadingNowPlaying,
                  isLoadingMore: homeState.isLoadingMoreNowPlaying,
                  hasMore: homeState.hasMoreNowPlaying,
                  error: homeState.nowPlayingError,
                  onRetry: () =>
                      ref.read(homeProvider.notifier).getNowPlayingMovies(),
                  onLoadMore: () =>
                      ref.read(homeProvider.notifier).getNowPlayingMovies(loadMore: true),
                ),

                const SizedBox(height: AppInsets.xl),

                // Trending Movies
                PaginatedHorizontalMovieList(
                  title: 'Trending Today',
                  movies: homeState.trendingMovies,
                  isLoading: homeState.isLoadingTrending,
                  isLoadingMore: homeState.isLoadingMoreTrending,
                  hasMore: homeState.hasMoreTrending,
                  error: homeState.trendingError,
                  onRetry: () =>
                      ref.read(homeProvider.notifier).getTrendingMovies(),
                  onLoadMore: () =>
                      ref.read(homeProvider.notifier).getTrendingMovies(loadMore: true),
                ),

                const SizedBox(height: AppInsets.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
