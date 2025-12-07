import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профайл'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text(
          'Хэрэглэгчийн мэдээлэл энд харагдана.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
