import 'package:flutter/material.dart';
import 'package:read_leaf/core/services/connectivity_service.dart';
import 'package:read_leaf/injection/injection.dart';

/// Debug widget to manually test connectivity status
class TestConnectivityWidget extends StatelessWidget {
  const TestConnectivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityService = getIt<ConnectivityService>();

    return Positioned(
      top: 100,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ValueListenableBuilder<NetworkStatus>(
              valueListenable: connectivityService.status,
              builder: (context, status, child) {
                return Row(
                  children: [
                    Icon(
                      status == NetworkStatus.online
                          ? Icons.wifi
                          : Icons.wifi_off,
                      color: status == NetworkStatus.online
                          ? Colors.green
                          : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status == NetworkStatus.online ? 'Online' : 'Offline',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    connectivityService.status.value = NetworkStatus.online;
                    print('Manual override: Set to ONLINE');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(30, 30),
                    padding: const EdgeInsets.all(4),
                  ),
                  child: const Text('Force Online',
                      style: TextStyle(fontSize: 10)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    connectivityService.status.value = NetworkStatus.offline;
                    print('Manual override: Set to OFFLINE');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(30, 30),
                    padding: const EdgeInsets.all(4),
                  ),
                  child: const Text('Force Offline',
                      style: TextStyle(fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final status = await connectivityService.checkConnectivity();
                print('Manual check result: $status');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(30, 30),
                padding: const EdgeInsets.all(4),
              ),
              child: const Text('Check Real Internet',
                  style: TextStyle(fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }
}
