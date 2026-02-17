import 'package:flutter/material.dart';
import 'package:otakuverse/core/widgets/bottom_nav_bar.dart';
import 'package:otakuverse/screens/home_screen.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0;

  // Tes écrans
  final List<Widget> _screens = [
    const HomeScreen(),
    // const SearchScreen(),
    // const CreatePostScreen(),
    // const ActivityScreen(),
    // const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Bouton + ouvre une modale au lieu de changer d'écran
          if (index == 2) {
            _showCreatePostModal();
            return;
          }
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  void _showCreatePostModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _createOption(Icons.image_outlined, 'Publier une photo', () {}),
            _createOption(Icons.video_camera_back_outlined, 'Publier une vidéo', () {}),
            _createOption(Icons.auto_stories_outlined, 'Ajouter une story', () {}),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _createOption(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF).withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF6C63FF)),
      ),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}