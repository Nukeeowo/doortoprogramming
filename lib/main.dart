import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Registry/splash_screen.dart';
import 'Services/firebase_options.dart'; // <--- IMPORT THIS

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // FIX: Pass the correct options using DefaultFirebaseOptions.currentPlatform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Assuming MyApp is your main widget that starts the application
  runApp(const MyApp()); 
}

// If your MyApp class was missing after the incomplete main() function, add this basic structure:
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Door to Programming',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(), // Starts with your splash screen
    );
  }
}