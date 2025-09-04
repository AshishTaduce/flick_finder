import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flick_finder/shared/widgets/skeleton_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/image_cache_service.dart';
import '../../presentation/providers/connectivity_provider.dart';
import '../../core/services/connectivity_service.dart';

class CachedImage extends ConsumerStatefulWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool preloadWhenOffline;

  const CachedImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.preloadWhenOffline = false,
  });

  @override
  ConsumerState<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends ConsumerState<CachedImage> {
  String? _cachedImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.imagePath == null || widget.imagePath!.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // First check if we have a cached version
    final cachedPath = await ImageCacheService.instance.getCachedImagePath(widget.imagePath!);
    
    if (cachedPath != null) {
      setState(() {
        _cachedImagePath = cachedPath;
        _isLoading = false;
      });
      return;
    }

    // If we're offline and should preload, try to cache the image
    final isOnline = ref.read(isOnlineProvider);
    if (!isOnline && widget.preloadWhenOffline) {
      final newCachedPath = await ImageCacheService.instance.cacheImage(widget.imagePath!);
      if (newCachedPath != null) {
        setState(() {
          _cachedImagePath = newCachedPath;
          _isLoading = false;
        });
        return;
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagePath == null || widget.imagePath!.isEmpty) {
      return _buildErrorWidget();
    }

    // If we have a cached image, use it
    if (_cachedImagePath != null) {
      return Image.file(
        File(_cachedImagePath!),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          // If cached image fails, fall back to network
          return _buildNetworkImage();
        },
      );
    }

    // Check if we're offline
    final networkStatus = ref.watch(networkStatusProvider);
    
    return networkStatus.when(
      data: (status) {
        if (status == NetworkStatus.offline) {
          return _buildOfflineWidget();
        }
        return _buildNetworkImage();
      },
      loading: () => _buildNetworkImage(),
      error: (_, __) => _buildNetworkImage(),
    );
  }

  Widget _buildNetworkImage() {
    final imageUrl = '${ApiConstants.imageBaseUrl}${widget.imagePath}';

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: (context, url) => widget.placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) => widget.errorWidget ?? _buildErrorWidget(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[300],
      child: _isLoading 
        ? const SkeletonLoader()
        : const Center(
            child: Icon(
              Icons.image,
              color: Colors.grey,
              size: 32,
            ),
          ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildOfflineWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[300],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              color: Colors.grey,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              'Offline',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}