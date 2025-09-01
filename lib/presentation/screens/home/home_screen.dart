import 'package:flick_finder/presentation/screens/home/widgets/error_widget.dart';
import 'package:flick_finder/presentation/screens/home/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/movie_grid.dart';
import '../../providers/movie_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch movies when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(movieProvider.notifier).getPopularMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final movieState = ref.watch(movieProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular Movies'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(movieProvider.notifier).getPopularMovies(),
        child: _buildBody(movieState),
      ),
    );
  }

  Widget _buildBody(MovieState state) {
    if (state.isLoading && state.movies.isEmpty) {
      return const LoadingWidget();
    }

    if (state.error != null && state.movies.isEmpty) {
      return CustomErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(movieProvider.notifier).getPopularMovies(),
      );
    }

    return Column(
      children: [
        if (state.isLoading)
          const LinearProgressIndicator(),
        Expanded(
          child: MovieGrid(movies: state.movies),
        ),
      ],
    );
  }
}