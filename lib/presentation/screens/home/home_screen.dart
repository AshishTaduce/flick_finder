import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_insets.dart';
import '../../providers/home_provider.dart';
import 'widgets/movie_carousel.dart';
import 'widgets/horizontal_movie_list.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier).loadAllMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(homeProvider.notifier).refresh(),
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                HorizontalMovieList(
                  title: 'Now Playing',
                  movies: homeState.nowPlayingMovies,
                  isLoading: homeState.isLoadingNowPlaying,
                  error: homeState.nowPlayingError,
                  onRetry: () =>
                      ref.read(homeProvider.notifier).getNowPlayingMovies(),
                  onSeeAll: () {
                    // TODO: Navigate to now playing list
                  },
                ),

                const SizedBox(height: AppInsets.xl),

                // Trending Movies
                HorizontalMovieList(
                  title: 'Trending Today',
                  movies: homeState.trendingMovies,
                  isLoading: homeState.isLoadingTrending,
                  error: homeState.trendingError,
                  onRetry: () =>
                      ref.read(homeProvider.notifier).getTrendingMovies(),
                  onSeeAll: () {
                    // TODO: Navigate to trending list
                  },
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
