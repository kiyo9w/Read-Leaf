import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_leaf/features/reader/presentation/blocs/reader_bloc.dart';

class Marker {
  final Color color;
  final PdfTextRanges ranges;

  Marker(this.color, this.ranges);
}

class MarkerManager {
  Map<int, List<Marker>> _markers = {};

  /// Get a defensive copy of markers for a given page.
  List<Marker> getMarkersForPage(int pageNumber) =>
      _markers.containsKey(pageNumber)
          ? List<Marker>.from(_markers[pageNumber]!)
          : [];

  /// Replace the markers map entirely.
  void setMarkers(Map<int, List<Marker>> newMarkers) {
    _markers = newMarkers;
  }

  /// Immutable add: create a new list with the new marker.
  void addMarker(int pageNumber, Marker marker) {
    final currentList = _markers[pageNumber] != null
        ? List<Marker>.from(_markers[pageNumber]!)
        : <Marker>[];
    currentList.add(marker);
    _markers[pageNumber] = currentList;
  }

  /// Immutable remove: remove the marker and update the list.
  void removeMarker(int pageNumber, Marker marker) {
    if (_markers.containsKey(pageNumber)) {
      final newList = List<Marker>.from(_markers[pageNumber]!);
      newList.remove(marker);
      _markers[pageNumber] = newList;
    }
  }

  /// Clear all markers.
  void clearMarkers() {
    _markers.clear();
  }

  /// Get all markers as a flat list.
  List<Marker> getMarkers() {
    return _markers.values.expand((list) => list).toList();
  }

  /// Retrieve the entire markers map (a defensive copy).
  Map<int, List<Marker>> get markers =>
      _markers.map((key, value) => MapEntry(key, List<Marker>.from(value)));
}

class MarkersView extends StatelessWidget {
  const MarkersView({
    super.key,
    required this.markers,
    this.onTap,
    this.onDeleteTap,
  });

  final List<Marker> markers;
  final void Function(Marker ranges)? onTap;
  final void Function(Marker ranges)? onDeleteTap;

  @override
  Widget build(BuildContext context) {
    if (markers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 48,
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF8E8E93)
                  : const Color(0xFF6E6E73),
            ),
            const SizedBox(height: 16),
            Text(
              'No highlights or notes',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFF2F2F7)
                    : const Color(0xFF1C1C1E),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select text and tap the highlight button to add',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF8E8E93)
                    : const Color(0xFF6E6E73),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Sort markers by page number
    final sortedMarkers = List<Marker>.from(markers)
      ..sort((a, b) => a.ranges.pageNumber.compareTo(b.ranges.pageNumber));

    return BlocBuilder<ReaderBloc, ReaderState>(
      builder: (context, state) {
        final currentPage = state is ReaderLoaded ? state.currentPage : 1;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: sortedMarkers.length,
          itemBuilder: (context, index) {
            final marker = sortedMarkers[index];
            final isCurrentPage = marker.ranges.pageNumber == currentPage;

            // Find the closest marker to current page for highlighting
            final closestMarkerToCurrentPage = sortedMarkers
                .where((m) => m.ranges.pageNumber <= currentPage)
                .lastOrNull;
            final shouldHighlight = marker == closestMarkerToCurrentPage;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  onTap?.call(marker);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: shouldHighlight
                        ? (Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.08))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left indicator for highlighted markers
                      Container(
                        width: 4,
                        height: 40,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: shouldHighlight
                              ? Theme.of(context).colorScheme.primary
                              : marker.color.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: shouldHighlight
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? const Color(0xFF2C2C2E)
                                            : const Color(0xFFF8F1F1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Page ${marker.ranges.pageNumber}',
                                    style: TextStyle(
                                      color: shouldHighlight
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? const Color(0xFFAA96B6)
                                              : const Color(0xFF6E6E73),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => onDeleteTap?.call(marker),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.delete_outline,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? const Color(0xFF8E8E93)
                                            : const Color(0xFF6E6E73),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              marker.ranges.text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: shouldHighlight
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFFF2F2F7)
                                        : const Color(0xFF1C1C1E),
                                fontSize: 14,
                                height: 1.4,
                                fontWeight: shouldHighlight
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
