import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/connectivity_service.dart';
import '../../presentation/providers/connectivity_provider.dart';

import '../theme/app_insets.dart';

class NetworkStatusIndicator extends ConsumerWidget {
  final bool showWhenOnline;
  final EdgeInsets? padding;
  final bool compact;

  const NetworkStatusIndicator({
    super.key,
    this.showWhenOnline = false,
    this.padding,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkStatusProvider);

    return networkStatus.when(
      data: (status) {
        if (status == NetworkStatus.online && !showWhenOnline) {
          return const SizedBox.shrink();
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: padding ?? EdgeInsets.all(compact ? AppInsets.xs : AppInsets.sm),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            borderRadius: BorderRadius.circular(AppInsets.radiusSm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(status),
                size: compact ? 16 : 20,
                color: Colors.white,
              ),
              if (!compact) ...[
                const SizedBox(width: AppInsets.xs),
                Text(
                  _getStatusText(status),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Color _getStatusColor(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.online:
        return Colors.green;
      case NetworkStatus.offline:
        return Colors.red;
      case NetworkStatus.unknown:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.online:
        return Icons.wifi;
      case NetworkStatus.offline:
        return Icons.wifi_off;
      case NetworkStatus.unknown:
        return Icons.signal_wifi_statusbar_null;
    }
  }

  String _getStatusText(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.online:
        return 'Online';
      case NetworkStatus.offline:
        return 'Offline';
      case NetworkStatus.unknown:
        return 'Unknown';
    }
  }
}

class NetworkStatusBanner extends ConsumerWidget {
  final Widget child;

  const NetworkStatusBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkStatusProvider);

    return Column(
      children: [
        networkStatus.when(
          data: (status) {
            if (status == NetworkStatus.offline) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppInsets.md,
                  vertical: AppInsets.sm,
                ),
                decoration: const BoxDecoration(
                  color: Colors.red,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: AppInsets.sm),
                    const Expanded(
                      child: Text(
                        'You\'re offline. Showing cached content.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        Expanded(child: child),
      ],
    );
  }
}