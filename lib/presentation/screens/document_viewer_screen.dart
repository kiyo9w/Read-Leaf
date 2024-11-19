import 'dart:io';

import 'package:flutter/material.dart';
import '../../data/models/document_model.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:epub_view/epub_view.dart';

class DocumentViewerScreen extends StatefulWidget {
  final DocumentModel document;

  DocumentViewerScreen({required this.document});

  @override
  _DocumentViewerScreenState createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  late EpubController _epubController;

  @override
  void initState() {
    super.initState();
    if (widget.document.type == 'epub') {
      _epubController = EpubController(
        document: EpubDocument.openFile(widget.document.path),
      );
    }
  }

  @override
  void dispose() {
    if (widget.document.type == 'epub') {
      _epubController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.document.type == 'pdf') {
      return PDFViewer(document: widget.document);
    } else if (widget.document.type == 'epub') {
      return EPUBViewer(controller: _epubController, document: widget.document);
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.document.name),
        ),
        body: Center(
          child: Text('Unsupported file type'),
        ),
      );
    }
  }
}

class PDFViewer extends StatelessWidget {
  final DocumentModel document;

  PDFViewer({required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.name),
      ),
      body: PDFView(
        filePath: document.path,
      ),
    );
  }
}

class EPUBViewer extends StatefulWidget {
  final EpubController controller;
  final DocumentModel document;

  EPUBViewer({required this.controller, required this.document});

  @override
  _EPUBViewerState createState() => _EPUBViewerState();
}

class _EPUBViewerState extends State<EPUBViewer> {
  @override
  void initState() {
    super.initState();
    // Load the last position if available
    final lastPosition = _getLastPosition();
    if (lastPosition != null) {
      widget.controller.gotoEpubCfi(lastPosition);
    }
  }

  @override
  void dispose() {
    // Save the current position
    final currentPosition = widget.controller.generateEpubCfi();
    _saveLastPosition(currentPosition!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: EpubViewActualChapter(
          controller: widget.controller,
          builder: (chapterValue) => Text(
            chapterValue?.chapter?.Title?.trim() ?? widget.document.name,
            textAlign: TextAlign.start,
          ),
        ),
      ),
      drawer: Drawer(
        child: EpubViewTableOfContents(
          controller: widget.controller,
        ),
      ),
      body: EpubView(
        controller: widget.controller,
      ),
    );
  }

  String? _getLastPosition() {
    // Retrieve the last position from persistent storage (e.g., Hive, SharedPreferences)
    // For example:
    // return Hive.box('positions').get(widget.document.id);
    return null;
  }

  void _saveLastPosition(String cfi) {
    // Save the current position to persistent storage
    // For example:
    // Hive.box('positions').put(widget.document.id, cfi);
  }
}

