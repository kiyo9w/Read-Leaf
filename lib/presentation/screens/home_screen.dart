import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder for the document library
    return Scaffold(
      appBar: AppBar(
        title: Text('My Library'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'epub'],
              );

              if (result != null) {
                String? filePath = result.files.single.path;
                if (filePath != null) {
                  // Handle the selected file
                  // Save it to the app's local storage or database
                }
              } else {
                // User canceled the picker
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'No documents added yet.',
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        tooltip: 'Add Document',
        child: Icon(Icons.add),
      ),
    );
  }
}
