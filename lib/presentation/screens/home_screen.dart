import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../data/models/document_model.dart';
import '../providers/document_provider.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatelessWidget {
  final uuid = Uuid(); // To generate unique IDs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Library'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Consumer<DocumentProvider>(
        builder: (context, documentProvider, child) {
          if (documentProvider.documents.isEmpty) {
            return Center(
              child: Text(
                'No documents added yet.',
                style: TextStyle(fontSize: 18),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: documentProvider.documents.length,
              itemBuilder: (context, index) {
                final document = documentProvider.documents[index];
                return ListTile(
                  title: Text(document.name),
                  leading: Icon(
                    document.type == 'pdf' ? Icons.picture_as_pdf : Icons.book,
                  ),
                  onTap: () {
                    // Open the document
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var status = await Permission.storage.status;
          if (!status.isGranted) {
            await Permission.storage.request();
          }
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf', 'epub'],
          );

          if (result != null) {
            String? filePath = result.files.single.path;
            if (filePath != null) {
              File file = File(filePath);
              String fileName = file.uri.pathSegments.last;
              String fileExtension = fileName.split('.').last;

              // Create a DocumentModel
              DocumentModel newDocument = DocumentModel(
                id: uuid.v4(),
                name: fileName,
                path: filePath,
                type: fileExtension,
              );

              // Add the document to the provider
              Provider.of<DocumentProvider>(context, listen: false)
                  .addDocument(newDocument);
            }
          } else {
            // User canceled the picker
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Add Document',
      ),
    );
  }
}
