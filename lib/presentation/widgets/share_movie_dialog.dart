import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../shared/theme/app_insets.dart';

class ShareMovieDialog extends StatelessWidget {
  final int movieId;
  final String movieTitle;
  final String? posterPath;

  const ShareMovieDialog({
    super.key,
    required this.movieId,
    required this.movieTitle,
    this.posterPath,
  });

  static const String baseUrl = 'https://flickfinder.app'; // Replace with your actual app URL

  String get movieUrl => '$baseUrl/movie/$movieId';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Share Movie'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share "$movieTitle" with friends',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppInsets.md),
          Container(
            padding: const EdgeInsets.all(AppInsets.sm),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppInsets.radiusSm),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    movieUrl,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(Icons.copy, size: 20),
                  tooltip: 'Copy link',
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () => _shareMovie(context),
          icon: const Icon(Icons.share, size: 18),
          label: const Text('Share'),
        ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: movieUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareMovie(BuildContext context) {
    final shareText = 'Check out "$movieTitle" on FlickFinder!\n\n$movieUrl';
    
    Share.share(
      shareText,
      subject: 'Movie Recommendation: $movieTitle',
    );
    
    Navigator.of(context).pop();
  }
}