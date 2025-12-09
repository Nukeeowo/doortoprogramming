import 'package:flutter/material.dart';
import 'register_page.dart';
import 'reset_password_page.dart';
import '../Screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Services/firebaseAuthService.dart'; // <--- FIX: Add this import!

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  static const Color blue = Color(0xFF1976D2);
  static const Color lightBlue = Color(0xFFE8EFFF);

  void _login() async {
      // Now this call will work because we imported the file
      final User? user = await FirebaseAuthService().loginUser(
        _emailController.text,
        _passwordController.text,
      );
      
      if (user != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage(user: user)),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password')),
          );
        }
      }
    }

  @override
  Widget build(BuildContext context) {
    // ... (Your existing UI code is fine, keep it as is) ...
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Тавтай Морил!", style: TextStyle(color: blue, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.vpn_key_rounded, size: 120, color: Colors.amber[800]),
              const SizedBox(height: 50),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: blue),
                decoration: InputDecoration(
                  hintText: 'И-мэйл хаяг',
                  hintStyle: TextStyle(color: blue.withOpacity(0.6)),
                  filled: true,
                  fillColor: lightBlue,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: blue),
                decoration: InputDecoration(
                  hintText: 'Нууц үг',
                  hintStyle: TextStyle(color: blue.withOpacity(0.6)),
                  filled: true,
                  fillColor: lightBlue,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordPage())),
                  child: const Text("Нууц үг сэргээх", style: TextStyle(color: blue, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text('Нэвтрэх', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                child: RichText(
                  text: TextSpan(
                    text: 'Хэрэв аккоунт байхгүй бол? ',
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                    children: [TextSpan(text: 'Бүртгүүлэх', style: TextStyle(color: blue, fontWeight: FontWeight.bold))],
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