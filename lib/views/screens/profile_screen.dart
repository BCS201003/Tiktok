// lib/views/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tiktok_tutorial/controllers/profile_controller.dart';
import 'package:tiktok_tutorial/views/screens/edit_profile_screen.dart';
import 'package:tiktok_tutorial/views/widgets/video_thumbnail.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  late ProfileController _controller;
  late String currentUid;

  @override
  void initState() {
    super.initState();
    // Initialize the ProfileController using GetX
    _controller = Get.put(ProfileController());
    currentUid = FirebaseAuth.instance.currentUser!.uid;
    // Load user data based on the provided UID
    _controller.loadUserData(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a dark theme to mimic TikTok's aesthetic
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // Show Edit Profile button only if it's the current user's profile
          if (widget.uid == currentUid)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => Get.to(() => const EditProfileScreen()),
            ),
        ],
      ),
      body: Obx(() {
        // Display loading indicator while fetching data
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
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
        if (_controller.user == null) {
          return const Center(
            child: Text(
              'No user data available',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        }

        // Extract user data
        final userData = _controller.user!;
        final isCurrentUser = widget.uid == currentUid;
        final isFollowing = _controller.isFollowing(widget.uid);

        return SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header Section
              Stack(
                alignment: Alignment.center,
                children: [
                  // Cover Image or Default Color
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[900],
                    child: userData.profilePhoto.isNotEmpty
                        ? Image.network(
                      userData.profilePhoto,
                      fit: BoxFit.cover,
                    )
                        : const Icon(
                      Icons.image,
                      color: Colors.white54,
                      size: 100,
                    ),
                  ),
                  // Profile Picture
                  Positioned(
                    bottom: -50,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 50,
                      backgroundImage: userData.profilePhoto.isNotEmpty
                          ? Image.network(userData.profilePhoto).image
                          : Image.asset('assets/default_avatar.png').image,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60), // Space for profile picture

              // User Information Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // User Name
                    Text(
                      userData.name,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // User Bio
                    Text(
                      userData.bio.isNotEmpty ? userData.bio : 'No bio available.',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Followers, Following, and Likes Count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildStatColumn(
                          count: _controller.getFollowers().length,
                          label: 'Followers',
                        ),
                        buildStatColumn(
                          count: _controller.getFollowing().length,
                          label: 'Following',
                        ),
                        buildStatColumn(
                          count: 0, // Placeholder for Likes
                          label: 'Likes',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Follow/Unfollow Button for Other Users
                    if (!isCurrentUser)
                      ElevatedButton(
                        onPressed: () => _controller.followUser(widget.uid),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFollowing ? Colors.red : Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isFollowing ? 'Unfollow' : 'Follow',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // User's Videos Section
                    _controller.userVideos.isEmpty
                        ? const Text(
                      'No videos posted yet.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    )
                        : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        childAspectRatio: 1,
                      ),
                      itemCount: _controller.userVideos.length,
                      itemBuilder: (context, index) {
                        final video = _controller.userVideos[index];
                        return VideoThumbnail(
                          videoUrl: video['videoUrl'] ?? '',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Builds a column widget for user statistics
  Widget buildStatColumn({required int count, required String label}) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
