import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_insets.dart';

class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration? period;
  final bool enabled;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
    this.period,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final container = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor ?? (isDark ? Colors.grey[800]! : Colors.grey[300]!),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );

    if (!enabled) return container;
    
    return Shimmer.fromColors(
      baseColor: baseColor ?? (isDark ? Colors.grey[800]! : Colors.grey[300]!),
      highlightColor: highlightColor ?? (isDark ? Colors.grey[600]! : Colors.grey[100]!),
      period: period ?? const Duration(milliseconds: 1500),
      child: container,
    );
  }
}

class MovieCardSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final bool showTitle;
  final bool showRating;

  const MovieCardSkeleton({
    super.key,
    this.width,
    this.height,
    this.showTitle = false,
    this.showRating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 150,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster skeleton
          SkeletonLoader(
            width: width ?? 150,
            height: height ?? 225,
            borderRadius: BorderRadius.circular(12),
          ),
          if (showTitle || showRating) ...[
            const SizedBox(height: 8),
            if (showTitle)
              SkeletonLoader(
                width: (width ?? 150) * 0.8,
                height: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            if (showTitle && showRating) const SizedBox(height: 4),
            if (showRating)
              SkeletonLoader(
                width: (width ?? 150) * 0.5,
                height: 12,
                borderRadius: BorderRadius.circular(4),
              ),
          ],
        ],
      ),
    );
  }
}

class MovieListSkeleton extends StatelessWidget {
  final int itemCount;
  final bool showTitles;

  const MovieListSkeleton({
    super.key,
    this.itemCount = 6,
    this.showTitles = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: showTitles ? 320 : 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 200 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: MovieCardSkeleton(
                    showTitle: showTitles,
                    showRating: showTitles,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MovieGridSkeleton extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final bool showTitles;

  const MovieGridSkeleton({
    super.key,
    this.itemCount = 12,
    this.crossAxisCount = 2,
    this.showTitles = true,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: showTitles ? 0.6 : 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: MovieCardSkeleton(
                  showTitle: showTitles,
                  showRating: showTitles,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class HomeSectionSkeleton extends StatelessWidget {
  final bool showTitle;
  final int movieCount;

  const HomeSectionSkeleton({
    super.key,
    this.showTitle = true,
    this.movieCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          // Section title skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(-20 * (1 - value), 0),
                    child: const SkeletonLoader(
                      width: 150,
                      height: 24,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Movie list skeleton
        MovieListSkeleton(
          itemCount: movieCount,
          showTitles: false,
        ),
      ],
    );
  }
}

class MovieDetailSkeleton extends StatelessWidget {
  const MovieDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Backdrop skeleton
          const SkeletonLoader(
            width: double.infinity,
            height: 200,
            borderRadius: BorderRadius.zero,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                const SkeletonLoader(
                  width: double.infinity,
                  height: 28,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                const SizedBox(height: 8),
                // Rating and year skeleton
                Row(
                  children: [
                    const SkeletonLoader(
                      width: 60,
                      height: 16,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    const SizedBox(width: 16),
                    const SkeletonLoader(
                      width: 40,
                      height: 16,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Overview skeleton
                Column(
                  children: List.generate(4, (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SkeletonLoader(
                      width: index == 3 ? 200 : double.infinity,
                      height: 16,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                  )),
                ),
                const SizedBox(height: 24),
                // Cast section skeleton
                const SkeletonLoader(
                  width: 80,
                  height: 20,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) => Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      child: const Column(
                        children: [
                          SkeletonLoader(
                            width: 60,
                            height: 60,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          SizedBox(height: 8),
                          SkeletonLoader(
                            width: double.infinity,
                            height: 12,
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          SizedBox(height: 4),
                          SkeletonLoader(
                            width: 50,
                            height: 10,
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SearchResultSkeleton extends StatelessWidget {
  final int itemCount;

  const SearchResultSkeleton({
    super.key,
    this.itemCount = 8,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: AppInsets.screenPadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.6,
        crossAxisSpacing: AppInsets.sm ,
        mainAxisSpacing:AppInsets.sm,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => AnimatedContainer(
        duration: Duration(milliseconds: 100 * index),
        margin: const EdgeInsets.only(bottom: 16),
        child: SkeletonLoader(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          period: Duration(milliseconds: 1500 + (index * 100)),
        ),
      ),
    );
  }
}

// Advanced skeleton components with better animations
class StaggeredSkeletonList extends StatelessWidget {
  final int itemCount;
  final Widget Function(int index) itemBuilder;
  final Duration staggerDelay;
  final ScrollPhysics? physics;

  const StaggeredSkeletonList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: physics,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * staggerDelay.inMilliseconds)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: itemBuilder(index),
              ),
            );
          },
        );
      },
    );
  }
}

class PulsingSkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Duration duration;

  const PulsingSkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<PulsingSkeletonLoader> createState() => _PulsingSkeletonLoaderState();
}

class _PulsingSkeletonLoaderState extends State<PulsingSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: (isDark ? Colors.grey[800]! : Colors.grey[300]!)
                .withValues(alpha: _animation.value),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}

class WaveSkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final int waveCount;

  const WaveSkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.waveCount = 3,
  });

  @override
  State<WaveSkeletonLoader> createState() => _WaveSkeletonLoaderState();
}

class _WaveSkeletonLoaderState extends State<WaveSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: WavePainter(
              animation: _controller,
              waveCount: widget.waveCount,
              baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
              highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
            ),
            size: Size(widget.width ?? double.infinity, widget.height ?? 20),
          );
        },
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final Animation<double> animation;
  final int waveCount;
  final Color baseColor;
  final Color highlightColor;

  WavePainter({
    required this.animation,
    required this.waveCount,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Draw base
    paint.color = baseColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw waves
    final waveWidth = size.width / waveCount;
    final animationValue = animation.value;

    for (int i = 0; i < waveCount; i++) {
      final waveOffset = (animationValue + (i * 0.3)) % 1.0;
      final waveX = waveOffset * size.width;
      
      final gradient = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          baseColor,
          highlightColor,
          baseColor,
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      final rect = Rect.fromLTWH(
        waveX - waveWidth / 2,
        0,
        waveWidth,
        size.height,
      );

      paint.shader = gradient.createShader(rect);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}