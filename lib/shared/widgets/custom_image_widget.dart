import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';

class CustomImageWidget extends StatefulWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool isCircular;
  final int maxRetries;
  final Duration retryDelay;

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
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  State<CustomImageWidget> createState() => _CustomImageWidgetState();
}

class _CustomImageWidgetState extends State<CustomImageWidget> {
  int _retryCount = 0;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.imageUrl;
  }

  @override
  void didUpdateWidget(CustomImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _retryCount = 0;
      _currentImageUrl = widget.imageUrl;
    }
  }

  void _retryLoadImage() {
    if (_retryCount < widget.maxRetries) {
      setState(() {
        _retryCount++;
        // Force cache refresh by adding a timestamp parameter
        _currentImageUrl = widget.imageUrl != null 
            ? '${widget.imageUrl}?retry=$_retryCount'
            : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Default placeholder
    final defaultPlaceholder = widget.placeholder ?? Container(
      color: theme.brightness == Brightness.dark
          ? AppColors.darkSurfaceVariant
          : AppColors.lightSurfaceVariant,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Default error widget with retry option
    final defaultErrorWidget = widget.errorWidget ?? Container(
      color: theme.brightness == Brightness.dark
          ? AppColors.darkSurfaceVariant
          : AppColors.lightSurfaceVariant,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, size: 30),
            if (_retryCount < widget.maxRetries) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Future.delayed(widget.retryDelay, _retryLoadImage);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    Widget imageWidget;

    if (_currentImageUrl == null || _currentImageUrl!.isEmpty) {
      imageWidget = defaultErrorWidget;
    } else {
      imageWidget = CachedNetworkImage(
        imageUrl: _currentImageUrl!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        placeholder: (context, url) => defaultPlaceholder,
        errorWidget: (context, url, error) {
          // Auto-retry on error if retries are available
          if (_retryCount < widget.maxRetries) {
            Future.delayed(widget.retryDelay, _retryLoadImage);
            return defaultPlaceholder; // Show loading while retrying
          }
          return defaultErrorWidget;
        },
      );
    }

    // Apply circular clipping if needed
    if (widget.isCircular) {
      imageWidget = ClipOval(child: imageWidget);
    } else if (widget.borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}