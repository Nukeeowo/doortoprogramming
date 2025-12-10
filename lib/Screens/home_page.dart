import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:door_to_programming/Services/firestoreService.dart';
import 'package:door_to_programming/Models/app_models.dart';
import 'package:door_to_programming/Lessons/lesson_data.dart';
import 'package:door_to_programming/Widgets/skeleton.dart'; // Ensure you created this file
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
  
  int _selectedIndex = 1; 
  final PageController _pageController = PageController(initialPage: 1);
  final TextEditingController _searchController = TextEditingController();
  
  bool _showFavoritesOnly = false;
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
    final String displayName = widget.user.email != null 
        ? widget.user.email!.split('@')[0] 
        : 'User';
    
    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return StreamBuilder<UserModel>(
      stream: _firestoreService.streamUserProfile(widget.user.uid),
      builder: (context, userSnapshot) {
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
                  backgroundColor: Colors.blue.shade50,
                  child: Text(initial, style: const TextStyle(color: Colors.blue)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // UPDATED: Text is now blue
                    const Text('Тавтай морил,', style: TextStyle(color: Colors.blue, fontSize: 12)),
                    Text(displayName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),

          body: PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _selectedIndex = index),
            children: [
              const ProfilePage(),             
              _buildHomeBody(userModel), // Uses CustomScrollView now
              const NotificationsPage(),       
            ],
          ),

          bottomNavigationBar: SafeArea(
            child: Container(
              height: 70,
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                // UPDATED: Nav bar is Blue
                color: Colors.blue, 
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCustomNavItem(0, Icons.person_outline, Icons.person, "Хэрэглэгч"),
                  _buildCustomNavItem(1, Icons.home_outlined, Icons.home, "Нүүр"),
                  _buildCustomNavItem(2, Icons.notifications_outlined, Icons.notifications, "Мэдэгдэл"),
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
            ? BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(25))
            : null,
        child: Row(
          children: [
            // UPDATED: Icons are black
            Icon(isSelected ? iconFilled : iconOutlined, color: Colors.black, size: 26),
            if (isSelected) ...[
              const SizedBox(width: 8),
              // UPDATED: Text is black
              Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
            ]
          ],
        ),
      ),
    );
  }

  // --- REFACTORED BODY: Uses CustomScrollView (Slivers) ---
  Widget _buildHomeBody(UserModel userModel) {
    return StreamBuilder<List<ProgrammingLanguage>>(
      stream: _firestoreService.streamLanguages(),
      builder: (context, snapshot) {
        // Prepare Data
        List<ProgrammingLanguage> filteredList = [];
        bool isLoading = snapshot.connectionState == ConnectionState.waiting;

        if (!isLoading) {
          final allLanguages = snapshot.data ?? [];
          filteredList = allLanguages.where((lang) {
            final matchesSearch = lang.title.toLowerCase().contains(_searchQuery);
            final matchesFav = _showFavoritesOnly ? userModel.favorites.contains(lang.title) : true;
            return matchesSearch && matchesFav;
          }).toList();
        }

        return CustomScrollView(
          slivers: [
            // 1. Header & Search Bar (Non-scrollable content turned into a Sliver)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Filter Button
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
                            onPressed: () => setState(() => _showFavoritesOnly = !_showFavoritesOnly),
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Search Bar
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              // UPDATED: Search bar is light blue
                              color: Colors.lightBlue.shade50, 
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Хайлт хийх...',
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
                      _showFavoritesOnly ? 'Хадгалсан хичээлүүд' : 'Программын хэлнүүүд',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),

            // 2. The Grid (SliverGrid)
            if (isLoading)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const LanguageCardSkeleton(),
                    childCount: 6,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 1.6,
                  ),
                ),
              )
            else if (filteredList.isEmpty)
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: Center(child: Text("Хичээл олдсонгүй.")),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildLanguageCard(filteredList[index], userModel),
                    childCount: filteredList.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 1.6,
                  ),
                ),
              ),

            // 3. Bottom Padding for Navigation Bar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  Widget _buildLanguageCard(ProgrammingLanguage lang, UserModel userModel) {

    return Card(
      elevation: 2,
      // UPDATED: Card background matches language color
      color: lang.color.withOpacity(0.2), 
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
                lesson: lang.lessons.isNotEmpty ? lang.lessons.first : 
                        const Lesson(id: 0, title: 'Хичээл алга', sections: [], quiz: Quiz(title: '', questions: [])),
                languageColor: lang.color,
                languageTitle: lang.title,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                            fontSize: 16, 
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${lang.lessons.length} хичээл',
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    // Use errorBuilder to prevent crashes if image path is wrong
                    child: Image.asset(
                      lang.imagePath, 
                      // UPDATED: Images are a tiny bit bigger
                      height: 40, 
                      width: 40,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.code),
                    ),
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