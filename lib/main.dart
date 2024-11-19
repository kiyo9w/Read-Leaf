import 'package:flutter/material.dart';
import 'presentation/screens/home_screen.dart';
import 'injection_container.dart' as di;
import 'package:provider/provider.dart';
import 'presentation/providers/document_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/document_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await Hive.initFlutter();
  Hive.registerAdapter(DocumentModelAdapter());
  runApp(BookReaderApp());
}

class BookReaderApp extends StatelessWidget {
  const BookReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
      ],
      child: MaterialApp(
        title: 'Book Reader App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
