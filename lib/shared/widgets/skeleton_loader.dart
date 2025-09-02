import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: baseColor ?? (isDark ? Colors.grey[800]! : Colors.grey[300]!),
      highlightColor: highlightColor ?? (isDark ? Colors.grey[700]! : Colors.grey[100]!),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class MovieCardSkeleton extends StatelessWidget {
  final double? width;
  final double? height;

  const MovieCardSkeleton({
    super.key,
    this.width,
    this.height,
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
          const SizedBox(height: 8),
          // Title skeleton
          const SkeletonLoader(
            width: double.infinity,
            height: 16,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          const SizedBox(height: 4),
          // Rating skeleton
          const SkeletonLoader(
            width: 80,
            height: 14,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ],
      ),
    );
  }
}

class MovieListSkeleton extends StatelessWidget {
  final int itemCount;

  const MovieListSkeleton({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: itemCount,
        itemBuilder: (context, index) => const MovieCardSkeleton(),
      ),
    );
  }
}

class MovieGridSkeleton extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const MovieGridSkeleton({
    super.key,
    this.itemCount = 12,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const MovieCardSkeleton(),
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster skeleton
            const SkeletonLoader(
              width: 80,
              height: 120,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            const SizedBox(width: 12),
            // Content skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title skeleton
                  const SkeletonLoader(
                    width: double.infinity,
                    height: 18,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  const SizedBox(height: 8),
                  // Rating skeleton
                  const SkeletonLoader(
                    width: 100,
                    height: 14,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  const SizedBox(height: 8),
                  // Description skeleton
                  Column(
                    children: List.generate(3, (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: SkeletonLoader(
                        width: index == 2 ? 150 : double.infinity,
                        height: 12,
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}