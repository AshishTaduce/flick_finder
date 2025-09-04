import 'dart:ui';
import 'package:flick_finder/shared/theme/app_theme_extension.dart';
import 'package:flick_finder/shared/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/network_status_indicator.dart';
import '../../providers/home_provider.dart';
import '../home/home_screen.dart';
import '../search/search_screen.dart';
import '../profile/profile_screen.dart';

class MainTabScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainTabScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends ConsumerState<MainTabScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _currentIndex,
    );

    _tabController.addListener(_handleTabChange);

    // Load home data if needed
    _loadHomeDataIfNeeded();
  }

  void _loadHomeDataIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeState = ref.read(homeProvider);
      if (homeState.popularMovies.isEmpty &&
          homeState.nowPlayingMovies.isEmpty &&
          homeState.trendingMovies.isEmpty &&
          !homeState.isLoading) {
        ref.read(homeProvider.notifier).loadAllMovies();
      }
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      final newIndex = _tabController.index;
      if (newIndex != _currentIndex) {
        setState(() {
          _currentIndex = newIndex;
        });
        _updateRoute(newIndex);
      }
    }
  }

  void _updateRoute(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

  @override
  void didUpdateWidget(MainTabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _currentIndex = widget.initialIndex;
      _tabController.animateTo(_currentIndex);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Handle back button - exit app if on home tab, otherwise go to home
          if (_currentIndex == 0) {
            // On home tab, allow system to handle (exit app)
            return;
          } else {
            // On other tabs, go to home tab
            _tabController.animateTo(0);
          }
        }
      },
      child: Scaffold(
        body: NetworkStatusBanner(
          child: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    HomeScreen(
                      onNavigateToSearch: () {
                        _tabController.animateTo(1);
                      },
                    ),
                    const SearchScreen(),
                    const ProfileScreen(),
                  ],
                ),
              ),
              _buildBottomNavigationBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).surfaceVariant.withAlpha(150),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).surfaceVariant.withAlpha(150),
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).primaryColor,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withAlpha(150),
            labelStyle: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w700
            ),
            unselectedLabelStyle:  AppTypography.labelMedium,
            tabs: const [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.search), text: 'Search'),
              Tab(icon: Icon(Icons.person), text: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
