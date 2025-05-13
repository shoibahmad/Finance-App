import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; 
import 'package:managment/data/model/add_date.dart';
import 'package:managment/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase FIRST (often recommended)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive for Flutter (handles web and mobile)
  await Hive.initFlutter(); // <-- CHANGE THIS

  Hive.registerAdapter(AdddataAdapter());

  // Open Box
  await Hive.openBox<Add_data>('data');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Management',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColor: const Color(0xff368983),
        scaffoldBackgroundColor: Colors.grey.shade100,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal).copyWith(
          secondary: const Color(0xff368983),
        ),
        fontFamily: 'f',
        inputDecorationTheme: InputDecorationTheme(
          prefixIconColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return const Color(0xff368983);
            }
            if (states.contains(WidgetState.error)) {
              return Colors.red;
            }
            return Colors.grey.shade600;
          }),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff368983),
            foregroundColor: Colors.white,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff368983),
          foregroundColor: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}