import 'package:flutter/material.dart';
import 'package:door_to_programming/Services/firebaseAuthService.dart';
import 'login_page.dart'; // Import to navigate back after reset


class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _emailController = TextEditingController(); // New email controller
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isPasswordObscure = true;
  bool _isConfirmObscure = true;

  static const Color blue = Color(0xFF1976D2);
  static const Color lightBlue = Color(0xFFE8EFFF);

  void _resetPassword() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }
    
    // 1. Use Firebase to send a reset email
    final isSuccess = await FirebaseAuthService().sendPasswordResetEmail(
      _emailController.text,
    );

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset link sent to your email!')),
      );
      // 2. Navigate back to the login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send reset email. User not found.')),
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
        // Default back button pops to the previous screen (LoginPage)
        leading: const BackButton(color: blue),
        title: const Text(
          "Нууц Үг Сэргээх",
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
              // NEW: Email Field (required for password reset flow)
              TextField(
                controller: _emailController,
                style: const TextStyle(color: blue),
                decoration: InputDecoration(
                  hintText: 'Email', // Placeholder text
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

              // New Password Field (Нууц Үг)
              TextField(
                controller: _passwordController,
                obscureText: _isPasswordObscure,
                style: const TextStyle(color: blue),
                decoration: InputDecoration(
                  hintText: 'Шинэ Нууц Үг',
                  hintStyle: TextStyle(color: blue.withOpacity(0.6)),
                  filled: true,
                  fillColor: lightBlue,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordObscure ? Icons.visibility_off : Icons.visibility,
                      color: blue,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordObscure = !_isPasswordObscure;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Confirm Password Field (Нууц Үгээ Дахин Давтах)
              TextField(
                controller: _confirmController,
                obscureText: _isConfirmObscure,
                style: const TextStyle(color: blue),
                decoration: InputDecoration(
                  hintText: 'Нууц Үгээ Дахин Давтах',
                  hintStyle: TextStyle(color: blue.withOpacity(0.6)),
                  filled: true,
                  fillColor: lightBlue,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmObscure ? Icons.visibility_off : Icons.visibility,
                      color: blue,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmObscure = !_isConfirmObscure;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Confirm Button (Баталгаажуулах)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Баталгаажуулах',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
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
