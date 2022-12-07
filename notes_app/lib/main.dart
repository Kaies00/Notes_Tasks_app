import 'package:flutter/material.dart';
import 'package:notes_app/sql_database/sql_db_1/pages/notebooks_pages/notebooks_page.dart';
import 'package:notes_app/sql_database/sql_db_1/pages/notes_pages/notes_page.dart';
import 'package:notes_app/values.dart';
import 'screens/my_home_page.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: plumColor,
          background: backgroundColor,
        ),
      ),
      home: NoteBooksPages(),
    );
  }
}
