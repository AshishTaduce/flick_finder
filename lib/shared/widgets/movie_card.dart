import 'package:flick_finder/shared/theme/app_typography.dart';
import 'package:flutter/material.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/movie.dart';
import '../../presentation/screens/movie_detail/movie_detail_screen.dart';
import '../../presentation/widgets/add_to_list_dialog.dart';
import '../theme/app_colors.dart';
import '../theme/app_insets.dart';
import 'custom_image_widget.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;
  final double? width;
  final double? height;
  final bool showAddToListButton;

  const MovieCard({
    super.key,
    required this.movie,
    this.width,
    this.height,
    this.showAddToListButton = true,
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = widget.movie.posterPath != null
        ? '${ApiConstants.imageBaseUrl}${widget.movie.posterPath}'
        : null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen(movie: widget.movie),
            ),
          );
        },
        child: Hero(
          tag: 'movie_poster_${widget.movie.id}',
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppInsets.radiusMd),
              color: theme.brightness == Brightness.dark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightSurfaceVariant,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppInsets.radiusMd),
              child: Stack(
                children: [
                  // Movie poster or placeholder
                  imageUrl != null
                      ? CustomImageWidget(
                          imageUrl: imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.movie, size: 40),
                              const SizedBox(height: AppInsets.sm),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppInsets.sm),
                                child: Text(
                                  widget.movie.title,
                                  style: AppTypography.headlineSmall,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                  
                  // Add to List button overlay
                  if (widget.showAddToListButton)
                    Positioned(
                      top: AppInsets.sm,
                      right: AppInsets.sm,
                      child: AnimatedOpacity(
                        opacity: _isHovered ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(AppInsets.radiusSm),
                          ),
                          child: IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AddToListDialog(
                                  movieId: widget.movie.id,
                                  movieTitle: widget.movie.title,
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.playlist_add,
                              color: Colors.white,
                              size: 20,
                            ),
                            tooltip: 'Add to List',
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: const EdgeInsets.all(4),
                          ),
                        ),
                      ),
                    ),
                  
                  // Rating overlay
                  if (widget.movie.rating > 0)
                    Positioned(
                      bottom: AppInsets.sm,
                      left: AppInsets.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppInsets.sm,
                          vertical: AppInsets.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(AppInsets.radiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              widget.movie.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}