import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_leaf/features/reader/presentation/blocs/reader_bloc.dart';

class ThumbnailsView extends StatelessWidget {
  const ThumbnailsView({
    super.key,
    required this.documentRef,
    required this.controller,
  });

  final PdfDocumentRef? documentRef;
  final PdfViewerController controller;

  @override
  Widget build(BuildContext context) {
    if (documentRef == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading pages...',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return PdfDocumentViewBuilder(
      documentRef: documentRef!,
      builder: (context, document) {
        if (document == null || document.pages.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return BlocBuilder<ReaderBloc, ReaderState>(
          builder: (context, state) {
            final currentPage = state is ReaderLoaded ? state.currentPage : 1;

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: document.pages.length,
              itemBuilder: (context, index) {
                final pageNumber = index + 1;
                final isCurrentPage = pageNumber == currentPage;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Update both controller and bloc
                      controller.goToPage(
                        pageNumber: pageNumber,
                        anchor: PdfPageAnchor.top,
                      );
                      context.read<ReaderBloc>().add(JumpToPage(pageNumber));
                      // Close the side nav after jumping to the page
                      context.read<ReaderBloc>().add(ToggleSideNav());
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isCurrentPage
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2.5,
                              )
                            : Border.all(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                                width: 1,
                              ),
                        boxShadow: isCurrentPage
                            ? [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: PdfPageView(
                                document: document,
                                pageNumber: pageNumber,
                                alignment: Alignment.center,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Page $pageNumber',
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white70
                                    : Colors.black87,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
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
      },
    );
  }
}
