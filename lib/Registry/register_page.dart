import 'package:flutter/material.dart';
import '../Services/auth_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  static const Color blue = Color(0xFF1976D2);
  static const Color lightBlue = Color(0xFFE8EFFF);

  void _register() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    // Call the new Firebase Service
    final user = await AuthService().registerUser(
      _emailController.text,
      _passwordController.text,
    );
    
    // Check if the user object was returned (registration was successful)
    if (user == null) {
      // Registration failed (e.g., email already in use, weak password)
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Registration failed. Check email format or password strength.')));
    } else {
      // Registration successful, navigate to Login
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Registration successful! Please log in.')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
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
        // Default back button pops to the previous screen (SplashScreen)
        leading: const BackButton(color: blue),
        title: const Text(
          "Бүртгүүлэх",
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
              const SizedBox(height: 50),

              // 1. Identifier Field (Нэвтрэх нэр)
              TextField(
                controller: _emailController,
                style: const TextStyle(color: blue),
                decoration: InputDecoration(
                  hintText: 'Нэвтрэх нэр', 
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
                  hintText: 'Нууц үг', 
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

              // Register Button (Бүртгүүлэх)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Бүртгүүлэх',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Login Link
              TextButton(
                // Changed from pushReplacement to standard push to allow back navigation
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ),
                child: const Text(
                  'Бүртгэлтэй юу? Нэвтрэх',
                  style: TextStyle(color: blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}