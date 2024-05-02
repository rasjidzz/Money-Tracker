import 'package:flutter/material.dart';
import 'package:money_tracker/page/homepage.dart';
import 'package:money_tracker/helper/sql_helper.dart';

void main() async {
  // Inisialisasi database sebelum menjalankan aplikasi
  WidgetsFlutterBinding.ensureInitialized();
  await sqlHelper().initializeDatabase();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}
