import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:door_to_programming/Services/firestoreService.dart';
import 'package:door_to_programming/Models/app_models.dart';
import 'package:door_to_programming/Lessons/lesson_data.dart';
import 'package:door_to_programming/Registry/login_page.dart'; // Import Login Page
import 'language_lesson_screen.dart';
import 'profile_page.dart';
import 'notifications_page.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  
  // Navigation State
  int _selectedIndex = 1; 
  final PageController _pageController = PageController(initialPage: 1);
  
  // Search & Filter State
  final TextEditingController _searchController = TextEditingController();
  bool _showFavoritesOnly = false; // Toggle for favorites filter
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    // 1. UPDATED: Get Email Name only (before @)
    final String displayName = widget.user.email != null 
        ? widget.user.email!.split('@')[0] 
        : 'User';
    
    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return StreamBuilder<UserModel>(
      stream: _firestoreService.streamUserProfile(widget.user.uid),
      builder: (context, userSnapshot) {
        // Prepare User Data
        final userModel = userSnapshot.data ?? 
            UserModel(uid: widget.user.uid, email: widget.user.email ?? '', points: 0, favorites: []);

        return Scaffold(
          backgroundColor: Colors.grey[50],
          extendBody: true,
          
          // --- TOP BAR ---
          appBar: AppBar(
            automaticallyImplyLeading: false, 
            backgroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade50,
                  child: Text(initial, style: const TextStyle(color: Colors.deepPurple)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back,', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    // Display name without domain
                    Text(displayName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
            actions: [
               IconButton(
                 icon: const Icon(Icons.logout, color: Colors.black54),
                 onPressed: () async {
                   // 2. UPDATED: Logout Logic
                   await FirebaseAuth.instance.signOut();
                   if (mounted) {
                     Navigator.of(context).pushReplacement(
                       MaterialPageRoute(builder: (_) => const LoginPage()),
                     );
                   }
                 },
               )
            ],
          ),

          body: PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _selectedIndex = index),
            children: [
              const ProfilePage(),             
              _buildHomeBody(userModel),       
              const NotificationsPage(),       
            ],
          ),

          bottomNavigationBar: SafeArea(
            child: Container(
              height: 70,
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCustomNavItem(0, Icons.person_outline, Icons.person, "Profile"),
                  _buildCustomNavItem(1, Icons.home_outlined, Icons.home, "Home"),
                  _buildCustomNavItem(2, Icons.notifications_outlined, Icons.notifications, "Notifs"),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomNavItem(int index, IconData iconOutlined, IconData iconFilled, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 20 : 10, vertical: 10),
        decoration: isSelected 
            ? BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(25))
            : null,
        child: Row(
          children: [
            Icon(isSelected ? iconFilled : iconOutlined, color: isSelected ? Colors.deepPurple : Colors.grey, size: 26),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 14)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildHomeBody(UserModel userModel) {
    // 3. UPDATED: Filter Logic (Search + Favorites)
    final filteredList = allLanguagesWithLessons.where((lang) {
      final matchesSearch = lang.title.toLowerCase().contains(_searchQuery);
      final matchesFav = _showFavoritesOnly ? userModel.favorites.contains(lang.title) : true;
      return matchesSearch && matchesFav;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // --- FAVORITES FILTER BUTTON ---
              Container(
                decoration: BoxDecoration(
                  color: _showFavoritesOnly ? Colors.red.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                  border: _showFavoritesOnly ? Border.all(color: Colors.red.shade200) : null,
                ),
                child: IconButton(
                  icon: Icon(
                    _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                    color: _showFavoritesOnly ? Colors.red : Colors.deepPurple,
                  ),
                  onPressed: () {
                    setState(() {
                      _showFavoritesOnly = !_showFavoritesOnly;
                    });
                  },
                ),
              ),
              
              const SizedBox(width: 15),

              // Search Bar
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search languages...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 25),

          Text(
            _showFavoritesOnly ? 'Your Favorites' : 'Learning Paths',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          filteredList.isEmpty
              ? const SizedBox(
                  height: 200,
                  child: Center(child: Text("No languages found", style: TextStyle(color: Colors.grey))),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.6, 
                  ),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final lang = filteredList[index];
                    return _buildLanguageCard(lang, userModel);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(ProgrammingLanguage lang, UserModel userModel) {

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (lang.lessons.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This lesson is coming soon!')),
            );
            return;
          }

           Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LanguageLessonScreen(
                user: widget.user,
                lesson: lang.lessons.first,
                languageColor: lang.color,
                languageTitle: lang.title, // <--- PASS THE TITLE HERE
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18, 
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${lang.lessons.length} lessons',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: lang.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(lang.imagePath, height: 30, width: 30),
                  ),
                ],
              ),
            
            ],
          ),
        ),
      ),
    );
  }
}