import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/movie_detail_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final String? deepLinkMovieId;

  const SplashScreen({
    super.key,
    this.deepLinkMovieId,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Wait for minimum splash duration
      await Future.delayed(const Duration(milliseconds: 1500));

      // Initialize MovieDetailsProvider (preload any necessary data)
      // This ensures the provider is ready when we navigate to movie details
      if (widget.deepLinkMovieId != null) {
        final movieId = int.tryParse(widget.deepLinkMovieId!);
        if (movieId != null) {
          // Pre-initialize the movie detail provider
          ref.read(movieDetailProvider(movieId));
        }
      }

      // Check auth state
      final authState = ref.read(authProvider);
      
      if (mounted) {
        await _handleNavigation(authState);
      }
    } catch (e) {
      // Handle initialization errors
      if (mounted) {
        _navigateToHome();
      }
    }
  }

  void _navigateToHome() {
    if (mounted) {
      context.go('/home');
    }
  }

  Future<void> _handleNavigation(AuthState authState) async {
    if (!mounted) return;
    
    // If user is not authenticated (not logged in and not guest)
    if (!authState.isAuthenticated) {
      if (mounted) {
        // GoRouter will handle the redirect automatically based on the redirect logic
        if (widget.deepLinkMovieId != null) {
          context.go('/movie/${widget.deepLinkMovieId}');
        } else {
          context.go('/login');
        }
      }
      return;
    }

    // User is authenticated (either logged in or guest)
    if (widget.deepLinkMovieId != null) {
      if (mounted) {
        context.go('/movie/${widget.deepLinkMovieId}');
      }
    } else {
      if (mounted) {
        context.go('/home');
      }
    }
  }



  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo/icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.movie,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // App name
                    Text(
                      'Flick Finder',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Loading indicator
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}