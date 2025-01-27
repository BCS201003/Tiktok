// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tiktok_tutorial/controllers/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  final String uid; // UID of the user to display

  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileController _controller;
  late String currentUid;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(ProfileController());
    currentUid = FirebaseAuth.instance.currentUser!.uid;
    _controller.loadUserData(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Obx(() {
        // Display loading indicator
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Display error message if any
        if (_controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              _controller.errorMessage.value,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        }

        // Display message if no user data is available
        if (_controller.user.isEmpty) {
          return const Center(
            child: Text('No user data available'),
          );
        }

        // Determine if the current user is following the target user
        bool isFollowing =
        (_controller.user['followers'] ?? []).contains(currentUid);

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Picture
                _controller.user['profilePictureUrl'] != null &&
                    _controller.user['profilePictureUrl'].isNotEmpty
                    ? CircleAvatar(
                  backgroundImage:
                  NetworkImage(_controller.user['profilePictureUrl']),
                  radius: 50,
                )
                    : const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 20),

                // User Name
                Text(
                  _controller.user['name'] ?? 'Unknown',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),

                // User Email
                Text(
                  _controller.user['email'] ?? 'Unknown',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 20),

                // Follow/Unfollow Button
                ElevatedButton(
                  onPressed: () => _controller.followUser(widget.uid),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing ? Colors.red : Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: Text(
                    isFollowing ? 'Unfollow' : 'Follow',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 30),

                // Additional Profile Information (Optional)
                // You can add more widgets here to display more user info
                // For example: Number of followers, following, posts, etc.
              ],
            ),
          ),
        );
      }),
    );
  }
}
