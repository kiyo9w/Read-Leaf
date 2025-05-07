import 'package:flutter/material.dart';
import 'package:read_leaf/core/services/connectivity_service.dart';
import 'package:read_leaf/injection/injection.dart';
import 'package:read_leaf/nav_screen.dart';
import 'package:read_leaf/generated/l10n.dart';

/// Widget that shows pill-shaped notifications for connectivity changes:
/// - Offline: Black pill at the top
/// - Online: Green pill at the bottom
class ConnectionRestoredNotification extends StatefulWidget {
  final Widget child;

  const ConnectionRestoredNotification({
    super.key,
    required this.child,
  });

  @override
  State<ConnectionRestoredNotification> createState() =>
      _ConnectionRestoredNotificationState();
}

class _ConnectionRestoredNotificationState
    extends State<ConnectionRestoredNotification>
    with SingleTickerProviderStateMixin {
  late final ConnectivityService _connectivityService;
  late final AnimationController _controller;
  late final Animation<double> _animation;
  NetworkStatus? _previousStatus;
  bool _showNotification = false;
  bool _showOnlineBar = false;
  OverlayEntry? _offlineOverlay;

  @override
  void initState() {
    super.initState();
    _connectivityService = getIt<ConnectivityService>();
    _previousStatus = _connectivityService.status.value;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _connectivityService.status.addListener(_handleStatusChange);
  }

  void _handleStatusChange() {
    final currentStatus = _connectivityService.status.value;

    // Show notification when status changes from offline to online
    if (_previousStatus == NetworkStatus.offline &&
        currentStatus == NetworkStatus.online) {
      setState(() {
        _showNotification = true;
        _showOnlineBar = true;
      });

      // Remove offline overlay if it exists
      _offlineOverlay?.remove();
      _offlineOverlay = null;

      _controller.forward();

      // Hide notification after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _controller.reverse().then((_) {
            if (mounted) {
              setState(() {
                _showNotification = false;
                _showOnlineBar = false;
              });;
            }
          });
        }
      });
    }
    // Show offline notification when going offline
    else if (currentStatus == NetworkStatus.offline && mounted) {
      // Remove any existing overlay
      _offlineOverlay?.remove();

      // Create a new overlay for offline notification
      _offlineOverlay = OverlayEntry(builder: (overlayContext) {
        final mediaQuery = MediaQuery.of(context);
        final topPadding = mediaQuery.padding.top;

        return Positioned(
          top: topPadding + 8,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            child: FadeTransition(
              opacity: _animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1),
                  end: Offset.zero,
                ).animate(_animation),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wifi_off,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        S.of(context).offline,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });

      // Insert the overlay and animate
      if (mounted) {
        Overlay.of(context).insert(_offlineOverlay!);
        _controller.forward();
      }

      // Auto-dismiss after 4 seconds
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted && _offlineOverlay != null) {
          _controller.reverse().then((_) {
            _offlineOverlay?.remove();
            _offlineOverlay = null;
          });
        }
      });
    }

    _previousStatus = currentStatus;
  }

  @override
  void dispose() {
    _connectivityService.status.removeListener(_handleStatusChange);
    _controller.dispose();
    _offlineOverlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showNotification && _showOnlineBar)
          Positioned(
            left: 16,
            right: 16,
            top: 55,
            child: FadeTransition(
              opacity: _animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(_animation),
                child: Material(
                  color: Colors.transparent,
                  elevation: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.wifi,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          S.of(context).backOnline,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
