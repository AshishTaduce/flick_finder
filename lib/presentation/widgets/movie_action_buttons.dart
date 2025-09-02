import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/user_features_service.dart';
import '../../core/utils/snackbar_utils.dart';
import '../providers/auth_provider.dart';

class MovieActionButtons extends ConsumerStatefulWidget {
  final int movieId;
  final String movieTitle;

  const MovieActionButtons({
    super.key,
    required this.movieId,
    required this.movieTitle,
  });

  @override
  ConsumerState<MovieActionButtons> createState() => _MovieActionButtonsState();
}

class _MovieActionButtonsState extends ConsumerState<MovieActionButtons> {
  bool _isInWatchlist = false;
  bool _isFavorite = false;
  double? _userRating;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMovieStates();
  }

  Future<void> _loadMovieStates() async {
    final authState = ref.read(authProvider);
    if (authState.isGuest || !authState.isAuthenticated) return;

    setState(() => _isLoading = true);

    try {
      final states = await UserFeaturesService.instance.getMovieAccountStates(widget.movieId);
      if (states != null && mounted) {
        setState(() {
          _isInWatchlist = states['watchlist'] ?? false;
          _isFavorite = states['favorite'] ?? false;
          _userRating = states['rated'] != false ? states['rated']['value']?.toDouble() : null;
        });
      }
    } catch (e) {
      // Silently handle errors
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleWatchlist() async {
    try {
      final success = await UserFeaturesService.instance.toggleWatchlist(
        widget.movieId,
        !_isInWatchlist,
      );
      
      if (success && mounted) {
        setState(() {
          _isInWatchlist = !_isInWatchlist;
        });
        
        SnackbarUtils.showSuccess(
          context,
          _isInWatchlist 
              ? 'Added to watchlist' 
              : 'Removed from watchlist',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final success = await UserFeaturesService.instance.toggleFavorite(
        widget.movieId,
        !_isFavorite,
      );
      
      if (success && mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        
        SnackbarUtils.showSuccess(
          context,
          _isFavorite 
              ? 'Added to favorites' 
              : 'Removed from favorites',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  Future<void> _showRatingDialog() async {
    double currentRating = _userRating ?? 5.0;
    
    final rating = await showDialog<double>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Rate "${widget.movieTitle}"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Rating: ${currentRating.toStringAsFixed(1)}/10'),
              const SizedBox(height: 16),
              Slider(
                value: currentRating,
                min: 0.5,
                max: 10.0,
                divisions: 19,
                label: currentRating.toStringAsFixed(1),
                onChanged: (value) {
                  setDialogState(() {
                    currentRating = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(currentRating),
              child: const Text('Rate'),
            ),
          ],
        ),
      ),
    );

    if (rating != null) {
      try {
        final success = await UserFeaturesService.instance.rateMovie(
          widget.movieId,
          rating,
        );
        
        if (success && mounted) {
          setState(() {
            _userRating = rating;
          });
          
          SnackbarUtils.showSuccess(
            context,
            'Rated ${rating.toStringAsFixed(1)}/10',
          );
        }
      } catch (e) {
        if (mounted) {
          SnackbarUtils.showError(
            context,
            e.toString().replaceAll('Exception: ', ''),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    // Don't show buttons for guests
    if (authState.isGuest || !authState.isAuthenticated) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Watchlist button
        IconButton(
          onPressed: _toggleWatchlist,
          icon: Icon(
            _isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
            color: _isInWatchlist ? Colors.blue : null,
          ),
          tooltip: _isInWatchlist ? 'Remove from watchlist' : 'Add to watchlist',
        ),
        
        // Favorite button
        IconButton(
          onPressed: _toggleFavorite,
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : null,
          ),
          tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
        ),
        
        // Rating button
        IconButton(
          onPressed: _showRatingDialog,
          icon: Icon(
            _userRating != null ? Icons.star : Icons.star_border,
            color: _userRating != null ? Colors.amber : null,
          ),
          tooltip: _userRating != null 
              ? 'Your rating: ${_userRating!.toStringAsFixed(1)}/10'
              : 'Rate this movie',
        ),
      ],
    );
  }
}