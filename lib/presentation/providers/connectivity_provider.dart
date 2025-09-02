import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/connectivity_service.dart';

// Provider for connectivity service
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService.instance;
});

// Provider for network status stream
final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.networkStatusStream;
});

// Provider for current network status
final currentNetworkStatusProvider = Provider<NetworkStatus>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.currentStatus;
});

// Provider for online status
final isOnlineProvider = Provider<bool>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.isOnline;
});

// Provider for offline status
final isOfflineProvider = Provider<bool>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.isOffline;
});