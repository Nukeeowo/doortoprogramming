import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:door_to_programming/Services/firestoreService.dart';
import 'package:door_to_programming/Models/app_models.dart';
import 'package:door_to_programming/Lessons/lesson_data.dart';
import 'language_lesson_screen.dart';
import 'profile_page.dart'; // Ensure you have this file from the previous step
import 'notifications_page.dart'; // Assuming you have this, otherwise I can provide a placeholder

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  
  // Navigation State
  int _selectedIndex = 0;
  
  // Search State
  final TextEditingController _searchController = TextEditingController();
  List<ProgrammingLanguage> _filteredLanguages = [];

  @override
  void initState() {
    super.initState();
    _filteredLanguages = allLanguagesWithLessons;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter the list based on search text
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLanguages = allLanguagesWithLessons.where((lang) {
        return lang.title.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Handle Bottom Nav Taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // We wrap everything in the StreamBuilder so we have User Data everywhere if needed
    return StreamBuilder<UserModel>(
      stream: _firestoreService.streamUserProfile(widget.user.uid),
      builder: (context, userSnapshot) {
        // Default to a basic user if data is loading/error
        final userModel = userSnapshot.data ?? 
            UserModel(uid: widget.user.uid, email: widget.user.email ?? '', points: 0);

        // Define the screens here to pass the data easily
        final List<Widget> screens = [
          _buildHomeBody(userModel),       // Index 0: Home
          NotificationsPage(),             // Index 1: Notifications (Placeholder)
          ProfilePage(user: widget.user),  // Index 2: Profile
        ];

        return Scaffold(
          backgroundColor: Colors.grey[50], // Light background for modern feel
          body: SafeArea(
            child: IndexedStack( // Keeps the state of pages when switching
              index: _selectedIndex,
              children: screens,
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF1976D2),
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Нүүр',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_rounded),
                  label: 'Мэдэгдэл',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  label: 'Профайл',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Home Tab Content ---
  Widget _buildHomeBody(UserModel userModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Сайн байна уу,',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  Text(
                    userModel.displayName ?? 'Хэрэглэгч',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                child: IconButton(
                  icon: const Icon(Icons.search, color: Color(0xFF1976D2)),
                  onPressed: () {
                    // Optional: Focus search bar or open search page
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Хэл сурах...',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 25),

          // 3. Gamification / Progress Card
          _buildGamificationCard(userModel),
          
          const SizedBox(height: 25),

          // 4. Grid Title
          const Text(
            'Сургалтын хөтөлбөр',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          // 5. Languages Grid (Filtered)
          _filteredLanguages.isEmpty
              ? const Center(child: Text("Хайлт олдсонгүй"))
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _filteredLanguages.length,
                  itemBuilder: (context, index) {
                    final lang = _filteredLanguages[index];
                    return _buildLanguageCard(lang);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildGamificationCard(UserModel userModel) {
    final totalLessons = allLanguagesWithLessons.fold<int>(0, (sum, lang) => sum + lang.lessons.length);
    
    return StreamBuilder<int>(
      stream: _firestoreService.streamCompletedLessonCount(widget.user.uid),
      builder: (context, snapshot) {
        final completedCount = snapshot.data ?? 0;
        final progress = totalLessons > 0 ? completedCount / totalLessons : 0.0;

        return Container(
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
                    'Таны явц', 
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 5),
                        Text(
                          '${userModel.points} XP',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation(Colors.amber),
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 10),
              Text(
                'Нийт $completedCount / $totalLessons хичээл дууссан',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageCard(ProgrammingLanguage lang) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
           Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LanguageLessonScreen(
                user: widget.user,
                lesson: lang.lessons.first,
                languageColor: lang.color,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: lang.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(lang.imagePath, height: 40),
              ),
              const SizedBox(height: 15),
              Text(
                lang.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              // Optional: You could fetch specific language progress here if desired
              Text(
                '${lang.lessons.length} хичээл',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}