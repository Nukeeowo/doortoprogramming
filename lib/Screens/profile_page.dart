import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:door_to_programming/Registry/login_page.dart';

class ProfilePage extends StatelessWidget {
  // We added 'required this.user' back to match what home_page.dart is sending
  final User user;
  
  const ProfilePage({super.key, required this.user});

  // Function to handle the logout process
  void _logout(BuildContext context) async {
    try {
      // 1. Sign the user out of Firebase
      await FirebaseAuth.instance.signOut();
      
      // 2. Navigate back to the Login Page
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Гарах үед алдаа гарлаа: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Профайл',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text(
              'Гарах', 
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_pin, size: 80, color: Colors.blueGrey),
            const SizedBox(height: 20),
            // Use the passed 'user' object to show the user's email
            Text(
              user.email ?? 'Нэргүй хэрэглэгч', // Display user's email
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Профайл мэдээлэл энд байх болно.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}