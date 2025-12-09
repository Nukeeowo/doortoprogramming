import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:door_to_programming/Services/firestoreService.dart';
import 'package:door_to_programming/Lessons/lesson_data.dart';
import 'change_password_page.dart'; // Import the new page

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isProgressExpanded = false;

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text("Please sign in to view your profile."));
    }

    String userName = currentUser.displayName ?? currentUser.email?.split('@').first ?? 'User';
    if (userName.trim().isEmpty) userName = 'User';
    final String userEmail = currentUser.email ?? 'No Email Provided';

    return Scaffold(
      // Background color adapts to theme automatically now
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            // --- Header Section ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, // Adapts to theme
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.deepPurple.shade50,
                    child: Text(
                      userName[0].toUpperCase(),
                      style: TextStyle(fontSize: 40, color: Colors.deepPurple.shade700, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // --- Interactive Progress Bar ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildInteractiveProgressCard(currentUser.uid),
            ),
            
            const SizedBox(height: 30),

            // --- Settings Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Settings",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  
                  // 1. Change Password
                  _buildSettingTile(
                    icon: Icons.lock_outline,
                    title: "Change Password",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                      );
                    },
                  ),

                  // 3. About App
                   _buildSettingTile(
                    icon: Icons.info_outline,
                    title: "About App",
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: "Door to Programming",
                        applicationVersion: "1.0.0",
                        applicationIcon: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.code, color: Colors.white),
                        ),
                        children: [
                          const Text("This app helps you learn programming languages like Java, Python, and more with interactive lessons and quizzes."),
                          const SizedBox(height: 10),
                          const Text("© 2024 Door to Programming Inc."),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildInteractiveProgressCard(String uid) {
    final totalLessons = allLanguagesWithLessons.fold<int>(0, (sum, lang) => sum + lang.lessons.length);
    
    return StreamBuilder<int>(
      stream: _firestoreService.streamCompletedLessonCount(uid),
      builder: (context, snapshot) {
        final completedCount = snapshot.data ?? 0;
        final progressPercent = totalLessons > 0 ? completedCount / totalLessons : 0.0;
        final percentageString = (progressPercent * 100).toStringAsFixed(1);

        return GestureDetector(
          onTap: () {
            setState(() {
              _isProgressExpanded = !_isProgressExpanded;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1976D2).withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Learning Progress', 
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Icon(
                      _isProgressExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.white,
                    )
                  ],
                ),
                
                const SizedBox(height: 15),
                
                LinearProgressIndicator(
                  value: progressPercent,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation(Colors.amber),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(10),
                ),
                
                AnimatedCrossFade(
                  firstChild: Container(height: 0),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      children: [
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn(
                              count: completedCount.toString(),
                              label: "Completed",
                              icon: Icons.check_circle_outline,
                            ),
                            Container(width: 1, height: 40, color: Colors.white24),
                            _buildStatColumn(
                              count: "$percentageString%",
                              label: "Progress",
                              icon: Icons.trending_up,
                            ),
                            Container(width: 1, height: 40, color: Colors.white24),
                             _buildStatColumn(
                              count: totalLessons.toString(),
                              label: "Total Goals",
                              icon: Icons.flag_outlined,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: _isProgressExpanded 
                      ? CrossFadeState.showSecond 
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatColumn({required String count, required String label, required IconData icon}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 5),
        Text(
          count,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildSettingTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor, // Adapts to theme
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(10)
          ),
          child: Icon(icon, color: Colors.deepPurple),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}