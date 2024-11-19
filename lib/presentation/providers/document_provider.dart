import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../data/models/document_model.dart';

class DocumentProvider with ChangeNotifier {
  late Box<DocumentModel> _documentBox;
  List<DocumentModel> _documents = [];

  List<DocumentModel> get documents => _documents;

  DocumentProvider() {
    _init();
  }

  void _init() async {
    _documentBox = await Hive.openBox<DocumentModel>('documents');
    _documents = _documentBox.values.toList();
    notifyListeners();
  }

  void addDocument(DocumentModel document) {
    _documentBox.put(document.id, document);
    _documents = _documentBox.values.toList();
    notifyListeners();
  }

  void removeDocument(String id) {
    _documentBox.delete(id);
    _documents = _documentBox.values.toList();
    notifyListeners();
  }
}
