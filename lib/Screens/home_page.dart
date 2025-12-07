import 'package:flutter/material.dart';
import 'package:door_to_programming/Registry/login_page.dart'; 
import 'notifications_page.dart'; 
import 'profile_page.dart'; 
import 'package:door_to_programming/Lessons/lesson_data.dart'; // Import lesson data (including ProgrammingLanguage model and allLanguagesWithLessons)
import 'language_lesson_screen.dart'; // Import lesson screen
import 'package:door_to_programming/Services/db_helper.dart'; // Import DB helper for progress

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user; 
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static const Color blue = Color(0xFF1976D2);

  late final List<Widget> _screens;
  
  // State to hold the number of completed lessons for display
  int _completedLessonsCount = 0;

  @override
  void initState() {
    super.initState();
    // Initialize screens, passing user data to ProfilePage
    _screens = [
      _buildHomeScreenContent(),
      const NotificationsPage(),
      // Pass the user map object to the Profile Page
      ProfilePage(user: widget.user), 
    ];
    // Fetch initial progress data
    _fetchCompletedLessons();
  }

  // Function to fetch completed lesson count across all languages
  void _fetchCompletedLessons() async {
    final userId = widget.user['id'] as int;
    final count = await DBHelper.getCompletedLessonCount(userId);
    if (mounted) {
      setState(() {
        _completedLessonsCount = count;
      });
    }
  }

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  void _signOut() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()), 
        (Route<dynamic> route) => false,
      );
    }
  }

  // Helper method for the main content view (first tab)
  Widget _buildHomeScreenContent() {
    final userEmail = widget.user['email'] ?? 'Хэрэглэгч';
    // Calculate total available lessons based on the data in lesson_data.dart
    final totalAvailableLessons = allLanguagesWithLessons.fold<int>(
      0, (sum, lang) => sum + lang.lessons.length
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Logout Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Сайн байна уу, ${userEmail.split('@').first}!', // Use first part of email for greeting
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: blue,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                onPressed: _signOut, 
                tooltip: 'Гарах',
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Progress Card
          _buildProgressCard(totalAvailableLessons),
          const SizedBox(height: 30),

          // Title for Languages
          const Text(
            'Програмчлалын хэлнүүд',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),

          // Grid View for Programming Languages (using new data)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15.0,
              mainAxisSpacing: 15.0,
              childAspectRatio: 0.9, // Adjust ratio slightly for more content
            ),
            itemCount: allLanguagesWithLessons.length,
            itemBuilder: (context, index) {
              final lang = allLanguagesWithLessons[index];
              return _buildLanguageCard(context, lang);
            },
          ),
        ],
      ),
    );
  }
  
  // Overall Progress Card
  Widget _buildProgressCard(int totalAvailableLessons) {
    final progressPercentage = totalAvailableLessons > 0 
      ? (_completedLessonsCount / totalAvailableLessons).clamp(0.0, 1.0) 
      : 0.0;
    
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [blue, blue.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Нийт явц',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 5),
            Text(
              '${(_completedLessonsCount)} / $totalAvailableLessons хичээл дууссан',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            
            // Progress Bar
            Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progressPercentage,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade400,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(progressPercentage * 100).toInt()}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card Widget for a single language
  Widget _buildLanguageCard(BuildContext context, ProgrammingLanguage lang) {
    final lessonCount = lang.lessons.length;

    return Container(
      decoration: BoxDecoration(
        color: lang.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lang.color.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: lang.color.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: lang.lessons.isNotEmpty
              ? () async {
                  // Navigate to the first lesson screen (simplified entry point)
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LanguageLessonScreen(
                        user: widget.user,
                        lesson: lang.lessons.first,
                        languageColor: lang.color,
                      ),
                    ),
                  );
                  _fetchCompletedLessons(); // Refresh overall progress when returning
                }
              : null, // Disable tap if no lessons
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    lang.imagePath,
                    height: 80,
                    width: 80,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 80,
                      width: 80,
                      color: Colors.grey,
                      child: const Center(child: Text('Logo', style: TextStyle(color: Colors.white))),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  lang.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: lang.color,
                  ),
                ),
                Text(
                  '$lessonCount хичээл | 2 цаг', 
                  style: TextStyle(
                    fontSize: 14,
                    color: lang.color.withOpacity(0.8),
                  ),
                ),
                
                // Lesson Status Indicator (using FutureBuilder to asynchronously check progress)
                FutureBuilder<int>(
                  // We only check progress if there are lessons available
                  future: lang.lessons.isNotEmpty 
                      ? _getCompletedLessonsInLanguage(lang.lessons.map((l) => l.id).toList()) 
                      : Future.value(0),
                  builder: (context, snapshot) {
                    final completedCount = snapshot.data ?? 0;
                    final totalCount = lang.lessons.length;
                    
                    if (!snapshot.hasData || totalCount == 0) {
                      return const SizedBox(height: 5);
                    }

                    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          '$completedCount / $totalCount дууссан',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: lang.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: lang.color.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(lang.color),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Helper to get completed lesson count for a specific language
  Future<int> _getCompletedLessonsInLanguage(List<int> lessonIds) async {
    final userId = widget.user['id'] as int;
    int completedCount = 0;
    // Iterate through all lesson IDs for this language and check completion status
    for (var lessonId in lessonIds) {
      if (await DBHelper.isLessonCompleted(userId, lessonId)) {
        completedCount++;
      }
    }
    return completedCount;
  }


  // Helper method for bottom navigation bar items
  Widget _buildBottomNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onBottomNavItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  // Helper to determine which screen to show based on selected index
  Widget _getCurrentScreen() {
    // Re-build the home content whenever selected index is 0 to refresh progress
    if (_selectedIndex == 0) {
      return _buildHomeScreenContent();
    }
    return _screens[_selectedIndex];
  }

  // --- Final Build Method using Positioned for fixed bottom placement ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // 1. Main Content Area (Fill the entire screen)
          Positioned.fill(
            child: SafeArea(
              child: _getCurrentScreen(), // Use the selected screen
            ),
          ),
          
          // 2. Floating Bottom Navigation Bar (Fixed to the bottom)
          Positioned(
            bottom: 12.0, // A small lift from the absolute bottom edge for the 'floating' effect
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: blue,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: blue.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomNavItem(Icons.home, 0),
                    const SizedBox(width: 20),
                    _buildBottomNavItem(Icons.notifications, 1),
                    const SizedBox(width: 20),
                    _buildBottomNavItem(Icons.person, 2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}