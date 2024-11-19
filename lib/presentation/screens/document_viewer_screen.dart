import 'package:flutter/material.dart';
import 'dart:io';
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
  EpubController? _epubController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.document.type == 'epub') {
      _initializeEpubController();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _initializeEpubController() async {
    try {
      final file = File(widget.document.path);
      final document = EpubDocument.openFile(file);

      setState(() {
        _epubController = EpubController(document: document);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      print('Error opening EPUB file: $e');
    }
  }

  @override
  void dispose() {
    _epubController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.document.name),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (widget.document.type == 'pdf') {
      return PDFViewer(document: widget.document);
    } else if (widget.document.type == 'epub' && _epubController != null) {
      return EPUBViewer(controller: _epubController!, document: widget.document);
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

class EPUBViewer extends StatelessWidget {
  final EpubController controller;
  final DocumentModel document;

  EPUBViewer({required this.controller, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: EpubViewActualChapter(
          controller: controller,
          builder: (chapterValue) => Text(
            chapterValue?.chapter?.Title?.trim() ?? document.name,
            textAlign: TextAlign.start,
          ),
        ),
      ),
      drawer: Drawer(
        child: EpubViewTableOfContents(
          controller: controller,
        ),
      ),
      body: EpubView(
        controller: controller,
      ),
    );
  }
}
