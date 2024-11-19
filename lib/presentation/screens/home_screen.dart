import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Placeholder for the document library
    return Scaffold(
      appBar: AppBar(
        title: Text('My Library'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings screen (to be implemented)
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
        child: Icon(Icons.add),
        tooltip: 'Add Document',
      ),
    );
  }
}
