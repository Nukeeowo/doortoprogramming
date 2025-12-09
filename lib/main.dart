import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Registry/splash_screen.dart';
import 'Services/firebase_options.dart';

// Global Theme Notifier
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
        return MaterialApp(
           // Listens to the switch
          home: const SplashScreen(),
        );
      }
  }