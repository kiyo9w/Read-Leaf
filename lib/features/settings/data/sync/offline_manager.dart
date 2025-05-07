import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:logging/logging.dart';
import 'package:read_leaf/core/services/connectivity_service.dart';
import 'package:read_leaf/injection/injection.dart';
import 'sync_types.dart';
import 'sync_queue.dart';

class OfflineManager {
  final _log = Logger('OfflineManager');
  final SyncQueue _offlineQueue;
  final ConnectivityService _connectivityService;
  final _connectivityController = BehaviorSubject<bool>();
  StreamSubscription? _connectivitySubscription;

  OfflineManager(this._offlineQueue)
      : _connectivityService = getIt<ConnectivityService>() {
    _initConnectivity();
  }

  Stream<bool> get connectivityStatus => _connectivityController.stream;
  bool get isOnline => _connectivityController.value;

  void _initConnectivity() {
    // Add a listener to the ValueNotifier
    _connectivityService.status.addListener(_onConnectivityChanged);

    // Set initial value based on current connectivity status
    final initialIsOnline =
        _connectivityService.status.value == NetworkStatus.online;
    _connectivityController.add(initialIsOnline);
  }

  void _onConnectivityChanged() {
    final isOnline = _connectivityService.status.value == NetworkStatus.online;
    _connectivityController.add(isOnline);

    if (isOnline) {
      syncOfflineChanges();
    }
  }

  Future<void> queueOfflineChanges(SyncTask task) async {
    try {
      // Add task to offline queue with lower priority
      await _offlineQueue.addTask(task.copyWith(
        priority: SyncPriority.low,
        timestamp: DateTime.now(),
      ));
      _log.fine('Task queued for offline sync: ${task.type}');
    } catch (e, stackTrace) {
      _log.severe('Error queueing offline task: ${task.type}', e, stackTrace);
      rethrow;
    }
  }

  Future<void> syncOfflineChanges() async {
    if (!isOnline || _offlineQueue.isEmpty) return;

    try {
      _log.info('Starting offline changes sync...');
      await _offlineQueue.processPendingTasks();
      _log.info('Offline changes sync completed');
    } catch (e, stackTrace) {
      _log.severe('Error syncing offline changes', e, stackTrace);
      rethrow;
    }
  }

  Future<void> resolveOfflineConflicts() async {
    try {
      _log.info('Starting offline conflict resolution...');
      // TODO: Implement conflict resolution strategy
      // This will be called when online sync detects conflicts
      // with changes made while offline
    } catch (e, stackTrace) {
      _log.severe('Error resolving offline conflicts', e, stackTrace);
      rethrow;
    }
  }

  void dispose() {
    _connectivityService.status.removeListener(_onConnectivityChanged);
    _connectivityController.close();
  }
}
