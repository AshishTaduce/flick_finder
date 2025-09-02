import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/watch_provider.dart';
import '../../shared/theme/app_insets.dart';
import '../../shared/widgets/custom_image_widget.dart';

class WatchProvidersDialog extends StatelessWidget {
  final String movieTitle;
  final WatchProviders? watchProviders;

  const WatchProvidersDialog({
    super.key,
    required this.movieTitle,
    required this.watchProviders,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Watch "$movieTitle"'),
      content: watchProviders == null || !watchProviders!.hasAnyProviders
          ? _buildNoProvidersContent(context)
          : _buildProvidersContent(context),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildNoProvidersContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.tv_off,
          size: 48,
          color: Theme.of(context).disabledColor,
        ),
        const SizedBox(height: AppInsets.md),
        Text(
          'No streaming options available in your region.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppInsets.sm),
        Text(
          'Check back later or try changing your region in settings.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildProvidersContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (watchProviders!.flatrate.isNotEmpty) ...[
            _buildProviderSection(
              context,
              'Stream',
              watchProviders!.flatrate,
              Icons.play_circle_filled,
              Colors.green,
            ),
            const SizedBox(height: AppInsets.md),
          ],
          if (watchProviders!.rent.isNotEmpty) ...[
            _buildProviderSection(
              context,
              'Rent',
              watchProviders!.rent,
              Icons.attach_money,
              Colors.orange,
            ),
            const SizedBox(height: AppInsets.md),
          ],
          if (watchProviders!.buy.isNotEmpty) ...[
            _buildProviderSection(
              context,
              'Buy',
              watchProviders!.buy,
              Icons.shopping_cart,
              Colors.blue,
            ),
          ],
          if (watchProviders!.link != null) ...[
            const SizedBox(height: AppInsets.md),
            const Divider(),
            const SizedBox(height: AppInsets.sm),
            Text(
              'Powered by JustWatch',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProviderSection(
    BuildContext context,
    String title,
    List<WatchProvider> providers,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppInsets.sm),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppInsets.sm),
        Wrap(
          spacing: AppInsets.sm,
          runSpacing: AppInsets.sm,
          children: providers.map((provider) => _buildProviderChip(context, provider)).toList(),
        ),
      ],
    );
  }

  Widget _buildProviderChip(BuildContext context, WatchProvider provider) {
    return GestureDetector(
      onTap: () async {
        if (watchProviders?.link != null) {
          final uri = Uri.parse(watchProviders!.link!);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppInsets.sm,
          vertical: AppInsets.xs,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppInsets.radiusSm),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CustomImageWidget(
                imageUrl: provider.fullLogoUrl,
                width: 24,
                height: 24,
                fit: BoxFit.cover,
                errorWidget: Icon(
                  Icons.tv,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: AppInsets.xs),
            Text(
              provider.providerName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}