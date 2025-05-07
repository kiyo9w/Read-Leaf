import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

enum NetworkStatus { online, offline }

@lazySingleton
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final ValueNotifier<NetworkStatus> status =
      ValueNotifier(NetworkStatus.online);
  StreamSubscription? _subscription;

  ConnectivityService() {
    _initConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        status.value = NetworkStatus.offline;
      } else {
        status.value = NetworkStatus.online;
      }
    });
  }

  // Initialize connectivity and set initial status
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        status.value = NetworkStatus.offline;
      } else {
        status.value = NetworkStatus.online;
      }
    } catch (e) {
      debugPrint('Connectivity initialization error: $e');
      status.value = NetworkStatus.offline;
    }
  }

  // Check if currently connected
  bool get isConnected => status.value == NetworkStatus.online;

  // Dispose of resources
  void dispose() {
    _subscription?.cancel();
  }
}
