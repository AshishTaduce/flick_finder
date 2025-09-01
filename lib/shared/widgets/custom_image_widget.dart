import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';

class CustomImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool isCircular;

  const CustomImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.isCircular = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Default placeholder
    final defaultPlaceholder = placeholder ?? Container(
      color: theme.brightness == Brightness.dark
          ? AppColors.darkSurfaceVariant
          : AppColors.lightSurfaceVariant,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Default error widget
    final defaultErrorWidget = errorWidget ?? Container(
      color: theme.brightness == Brightness.dark
          ? AppColors.darkSurfaceVariant
          : AppColors.lightSurfaceVariant,
      child: const Center(
        child: Icon(Icons.error, size: 30),
      ),
    );

    Widget imageWidget;

    if (imageUrl == null || imageUrl!.isEmpty) {
      imageWidget = defaultErrorWidget;
    } else {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => defaultPlaceholder,
        errorWidget: (context, url, error) => defaultErrorWidget,
      );
    }

    // Apply circular clipping if needed
    if (isCircular) {
      imageWidget = ClipOval(child: imageWidget);
    } else if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}