// lib/views/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth import
import 'package:get/get.dart'; // Import GetX
import 'package:tiktok_tutorial/constants.dart';
import 'package:tiktok_tutorial/views/screens/message_screen.dart';
import 'package:tiktok_tutorial/views/widgets/custom_icon.dart';
import 'package:tiktok_tutorial/views/screens/video_screen.dart';
import 'package:tiktok_tutorial/views/screens/search_screen.dart';
import 'package:tiktok_tutorial/views/screens/add_video_screen.dart';
import 'package:tiktok_tutorial/views/screens/profile_screen.dart';
import 'package:tiktok_tutorial/controllers/auth_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int pageIdx = 0;
  late String _uid; // Define _uid
  late List<Widget> pages; // Initialize after _uid

  // Access AuthController
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _uid = currentUser.uid;
      pages = [
        VideoScreen(), // Home
        const SearchScreen(),
        const AddVideoScreen(),
        const MessagesScreen(),
        ProfileScreen(uid: _uid), // Pass the _uid here
      ];
    } else {
      _uid = '';
      pages = [
        VideoScreen(), // Home
        const SearchScreen(),
        const AddVideoScreen(),
        const MessagesScreen(),
        const Center(child: Text('Please log in')),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Added AppBar with Logout button
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // Confirm logout action with the user
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        authController.signOut();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (idx) {
          setState(() {
            pageIdx = idx;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: backgroundColor,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.white,
        currentIndex: pageIdx,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 30),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: CustomIcon(),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message, size: 30),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30),
            label: 'Profile',
          ),
        ],
      ),
      body: pages[pageIdx],
    );
  }
}
