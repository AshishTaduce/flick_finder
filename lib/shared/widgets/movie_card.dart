import 'package:flick_finder/shared/theme/app_typography.dart';
import 'package:flutter/material.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/movie.dart';
import '../../presentation/screens/movie_detail/movie_detail_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = widget.movie.posterPath != null
        ? '${ApiConstants.imageBaseUrl}${widget.movie.posterPath}'
        : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: widget.movie),
          ),
        );
      },
      child: Hero(
        tag: 'id_${widget.movie.id}',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}