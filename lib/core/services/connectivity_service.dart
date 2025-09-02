import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

enum NetworkStatus {
  online,
  offline,
  unknown,
}

class ConnectivityService {
  static ConnectivityService? _instance;
  static ConnectivityService get instance => _instance ??= ConnectivityService._();
  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  final StreamController<NetworkStatus> _networkStatusController = 
      StreamController<NetworkStatus>.broadcast();
  
  NetworkStatus _currentStatus = NetworkStatus.unknown;
  
  Stream<NetworkStatus> get networkStatusStream => _networkStatusController.stream;
  NetworkStatus get currentStatus => _currentStatus;
  bool get isOnline => _currentStatus == NetworkStatus.online;
  bool get isOffline => _currentStatus == NetworkStatus.offline;

  Future<void> initialize() async {
    // Get initial connectivity status
    await _updateNetworkStatus();
    
    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _handleConnectivityChange(results);
      },
    );
  }

  Future<void> _updateNetworkStatus() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      _handleConnectivityChange(results);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
      _updateStatus(NetworkStatus.unknown);
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet)) {
      _updateStatus(NetworkStatus.online);
    } else if (results.contains(ConnectivityResult.none)) {
      _updateStatus(NetworkStatus.offline);
    } else {
      _updateStatus(NetworkStatus.unknown);
    }
  }

  void _updateStatus(NetworkStatus status) {
    if (_currentStatus != status) {
      final previousStatus = _currentStatus;
      _currentStatus = status;
      _networkStatusController.add(status);
      
      if (kDebugMode) {
        print('Network status changed: $previousStatus -> $status');
      }
      
      // Trigger background sync when coming back online
      if (previousStatus == NetworkStatus.offline && status == NetworkStatus.online) {
        _onNetworkRestored();
      }
    }
  }

  void _onNetworkRestored() {
    if (kDebugMode) {
      print('Network restored - triggering background sync');
    }
    // This will be used to trigger background sync
    // We'll implement this in the sync service
  }

  Future<bool> hasInternetConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.contains(ConnectivityResult.mobile) ||
             results.contains(ConnectivityResult.wifi) ||
             results.contains(ConnectivityResult.ethernet);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking internet connection: $e');
      }
      return false;
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _networkStatusController.close();
  }
}