import 'package:flutter/material.dart';
import 'presentation/screens/home_screen.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(BookReaderApp());
}

class BookReaderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Reader App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Define other theme properties if needed
      ),
      home: HomeScreen(),
    );
  }
}
