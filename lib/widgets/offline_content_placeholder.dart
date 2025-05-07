import 'package:flutter/material.dart';
import 'package:read_leaf/generated/l10n.dart';

class OfflineContentPlaceholder extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;
  final String? submessage;
  final IconData icon;

  const OfflineContentPlaceholder({
    super.key,
    this.onRetry,
    this.message,
    this.submessage,
    this.icon = Icons.wifi_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message ?? S.of(context).noInternetConnection,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              submessage ?? S.of(context).checkYourConnection,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh, color: theme.brightness == Brightness.dark ? Colors.black : Colors.white),
                label: Text(S.of(context).retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
