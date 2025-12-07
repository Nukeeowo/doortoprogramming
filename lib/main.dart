import 'package:flutter/material.dart';
import 'Registry/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core

// NOTE: You must have run 'flutter pub add firebase_core'

void main() async {
  // Ensure the native bindings are initialized before calling Firebase Core
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Initialize Firebase
  await Firebase.initializeApp(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Door to Programming',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}