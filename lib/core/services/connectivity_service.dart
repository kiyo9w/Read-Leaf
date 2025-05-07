import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

enum NetworkStatus { online, offline }

@singleton
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final ValueNotifier<NetworkStatus> status =
      ValueNotifier(NetworkStatus.online);
  StreamSubscription? _subscription;
  bool _initialized = false;
  Timer? _periodicCheckTimer;

  ConnectivityService() {
    print('ConnectivityService: Constructor called');
    _initConnectivity();
    _setupListener();

    // Start periodic check every 30 seconds
    _periodicCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      checkConnectivity();
    });
  }

  void _setupListener() {
    print('ConnectivityService: Setting up listener');
    _subscription = _connectivity.onConnectivityChanged.listen((result) async {
      print('ConnectivityService: Connectivity changed to $result');
      if (result.contains(ConnectivityResult.none)) {
        print('ConnectivityService: Changed to Offline');
        status.value = NetworkStatus.offline;
      } else {
        // Don't immediately assume we're online - verify with a network request
        final hasInternet = await _checkRealConnectivity();
        print('ConnectivityService: Internet check after change: $hasInternet');
        status.value =
            hasInternet ? NetworkStatus.online : NetworkStatus.offline;
      }
    });
  }

  // Initialize connectivity and set initial status
  Future<void> _initConnectivity() async {
    if (_initialized) return;

    print('ConnectivityService: Initializing connectivity check');
    try {
      final result = await _connectivity.checkConnectivity();
      print('ConnectivityService: Initial connectivity result: $result');

      if (result.contains(ConnectivityResult.none)) {
        print('ConnectivityService: Initial state is Offline');
        status.value = NetworkStatus.offline;
      } else {
        // Verify with a real connectivity check
        final hasInternet = await _checkRealConnectivity();
        print('ConnectivityService: Initial internet check: $hasInternet');
        status.value =
            hasInternet ? NetworkStatus.online : NetworkStatus.offline;
      }
      _initialized = true;
    } catch (e) {
      print('ConnectivityService: Initialization error: $e');
      status.value = NetworkStatus.offline;
    }
  }

  // Check real internet connectivity by making a network request
  Future<bool> _checkRealConnectivity() async {
    try {
      print('ConnectivityService: Performing real connectivity check');
      // Try to connect to a reliable server
      final List<String> lookupAddresses = [
        'google.com',
        'cloudflare.com',
        'apple.com',
        '1.1.1.1'
      ];

      for (final address in lookupAddresses) {
        try {
          // Lookup is more reliable than HTTP request in most cases
          await InternetAddress.lookup(address);
          print('ConnectivityService: Successfully connected to $address');
          return true;
        } catch (e) {
          print('ConnectivityService: Failed to connect to $address: $e');
          // Continue to the next address
        }
      }

      // If all lookups fail, we're offline
      return false;
    } catch (e) {
      print('ConnectivityService: Real connectivity check error: $e');
      return false;
    }
  }

  // Force check connectivity now
  Future<NetworkStatus> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      print('ConnectivityService: Manual connectivity check result: $result');

      if (result.contains(ConnectivityResult.none)) {
        status.value = NetworkStatus.offline;
      } else {
        // Verify with a real connectivity check
        final hasInternet = await _checkRealConnectivity();
        print('ConnectivityService: Manual internet check: $hasInternet');
        status.value =
            hasInternet ? NetworkStatus.online : NetworkStatus.offline;
      }
      return status.value;
    } catch (e) {
      print('ConnectivityService: Manual check error: $e');
      return NetworkStatus.offline;
    }
  }

  // Check if currently connected
  bool get isConnected => status.value == NetworkStatus.online;

  // Dispose of resources
  void dispose() {
    print('ConnectivityService: Disposing resources');
    _subscription?.cancel();
    _periodicCheckTimer?.cancel();
  }
}
