import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Screens/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _moveUp;
  late Animation<double> _scaleImage;
  late Animation<double> _fadeInText;
  late Animation<double> _fadeInButtons;

  static const Color blue = Color(0xFF1976D2);
  static const Color lightGray = Color(0xFFE5E5E5);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 1. Move Up Animation: Move the image up slightly from the center
    _moveUp = Tween<double>(begin: 80, end: -100).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // 2. Image Scale/Opacity Animation (Image comes into focus/scales up slightly)
    _scaleImage = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // 3. Text Fade-In Animation (Tagline and Title)
    _fadeInText = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeIn),
      ),
    );

    // 4. Buttons Fade-In Animation (Starts later for the reveal effect)
    _fadeInButtons = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start animation and then check auth state
    _controller.forward().then((_) {
      _checkCurrentUser();
    });
  }

  // --- NEW: Firebase Auth Check ---
  void _checkCurrentUser() {
    // Check if a user is already signed in (persisted session)
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      // User is logged in, navigate immediately to the home page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(user: user)),
        );
      }
    }
    // If user is null, the animation is done, and the buttons remain visible.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateTo(Widget page) {
    // Navigate using push instead of pushReplacement so the back button works
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          final tween = Tween(begin: begin, end: end);
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );

          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }

  // Helper for Primary Button styling (Blue fill, White text)
  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: blue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Slightly rounded corners
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Helper for Outline Button styling (Light Gray fill, Blue text)
  Widget _buildSecondaryButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: lightGray, // Light Gray fill
          foregroundColor: blue, // Blue text
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Animated image container (Image slides up)
                  Transform.translate(
                    offset: Offset(0, _moveUp.value),
                    child: Transform.scale(
                      scale: _scaleImage.value,
                      child: Opacity(
                        opacity: _scaleImage.value,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/lock.png', // Using existing asset path
                              height: 100,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 10),
                            Opacity(
                              opacity: _fadeInText.value,
                              child: const Text(
                                'Door To\nProgramming',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Buttons fade in (revealing the call to action)
                  Opacity(
                    opacity: _fadeInButtons.value,
                    child: Column(
                      children: [
                        // 1. Login Button (Нэвтрэх)
                        _buildPrimaryButton(
                          onPressed: () => _navigateTo(const LoginPage()),
                          label: 'Нэвтрэх',
                        ),
                        const SizedBox(height: 15),

                        // 2. Register Button (Бүртгүүлэх)
                        _buildSecondaryButton(
                          onPressed: () => _navigateTo(const RegisterPage()),
                          label: 'Бүртгүүлэх',
                        ),
                        const SizedBox(height: 30),

                        // Legal Disclaimer Text
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'Нэвтрэх, бүртгүүлэх товч дарснаар та манай үйлчилгээний нөхцөл болон нууцлалын бодлогыг зөвшөөрсөнд тооцно',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}