import 'package:flutter/material.dart';
import '../Services/db_helper.dart';
import 'register_page.dart';
import 'reset_password_page.dart';
import '../Screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add for User type

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // New color constants
  static const Color blue = Color(0xFF1976D2);
  static const Color lightBlue = Color(0xFFE8EFFF);

  void _login() async {
      // Call the new Firebase Service
      final User? user = await FirebaseAuthService().loginUser(
        _emailController.text,
        _passwordController.text,
      );
      
      // user is now a Firebase User object
      if (user != null) {
        // Use pushReplacement here as login is the end of the authentication flow
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(user: user)), // Pass the Firebase User
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // The default back button handles popping back to the SplashScreen
        leading: const BackButton(color: blue),
        title: const Text(
          "Тавтай Морил!",
          style: TextStyle(
            color: blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Placeholder for the golden lock/key image (using an Icon as a substitute)
              Icon(
                Icons.vpn_key_rounded,
                size: 120,
                color: Colors.amber[800], // Golden color approximation
              ),
              const SizedBox(height: 50),

              // 1. Username/Email Field (Нэвтрэх нэр)
              TextField(
                controller: _emailController,
                style: const TextStyle(color: blue),
                decoration: InputDecoration(
                  hintText: 'Нэвтрэх нэр', // Placeholder text matching the image
                  hintStyle: TextStyle(color: blue.withOpacity(0.6)),
                  filled: true,
                  fillColor: lightBlue,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Password Field (Нууц үг)
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: blue),
                decoration: InputDecoration(
                  hintText: 'Нууц үг', // Placeholder text matching the image
                  hintStyle: TextStyle(color: blue.withOpacity(0.6)),
                  filled: true,
                  fillColor: lightBlue,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              const SizedBox(height: 10),

              // Forgot Password Link (right-aligned)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    "Нууц үг сэргээх",
                    style: TextStyle(
                      color: blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Login Button (Нэвтрэх)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Нэвтрэх',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Registration Link (at the bottom)
              TextButton(
                // Changed from pushReplacement to standard push to allow back navigation
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: RichText(
                  text: TextSpan(
                    text: 'Хэрэв аккоунт байхгүй бол? ', // Text matching the image
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Бүртгүүлэх',
                        style: TextStyle(color: blue, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}