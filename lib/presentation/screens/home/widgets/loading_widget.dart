import 'package:flutter/material.dart';
import '../../../../shared/widgets/skeleton_loader.dart';

class HomeLoadingWidget extends StatelessWidget {
  const HomeLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured carousel skeleton - handled by MovieCarousel itself
          
          const SizedBox(height: 24),
          
          // Section skeletons with staggered animations
          ...List.generate(3, (sectionIndex) => TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 400 + (sectionIndex * 200)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Column(
                    children: [
                      HomeSectionSkeleton(
                        movieCount: 6,
                        showTitle: true,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          )),
        ],
      ),
    );
  }
}