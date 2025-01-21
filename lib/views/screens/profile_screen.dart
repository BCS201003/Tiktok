// lib/views/screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_tutorial/constants.dart';
import 'package:tiktok_tutorial/controllers/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController profileController = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    profileController.updateUserId(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) {
        if (controller.user.isEmpty) {
          return const Scaffold(
            backgroundColor: backgroundColor,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.black12,
            leading: const Icon(
              Icons.person_add_alt_1_outlined,
              color: Colors.white,
            ),
            actions: const [
              Icon(
                Icons.more_horiz,
                color: Colors.white,
              ),
            ],
            title: Text(
              controller.user['name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Profile Photo
                ClipOval(
                  child: controller.user['profilePhoto'] != null &&
                      File(controller.user['profilePhoto']).existsSync()
                      ? Image.file(
                    File(controller.user['profilePhoto']),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                      : const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Followers, Following, Likes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatColumn('Following', controller.user['following']),
                    _buildDivider(),
                    _buildStatColumn('Followers', controller.user['followers']),
                    _buildDivider(),
                    _buildStatColumn('Likes', controller.user['likes']),
                  ],
                ),
                const SizedBox(height: 15),
                // Follow/Unfollow or Sign Out button
                Container(
                  width: 140,
                  height: 47,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: borderColor,
                    ),
                  ),
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        if (widget.uid == authController.currentUser!.uid) {
                          authController.signOut();
                        } else {
                          controller.followUser();
                        }
                      },
                      child: Text(
                        widget.uid == authController.currentUser!.uid
                            ? 'Sign Out'
                            : controller.user['isFollowing']
                            ? 'Unfollow'
                            : 'Follow',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                // Video Thumbnails Grid
                Expanded(
                  child: controller.user['thumbnails'].isNotEmpty
                      ? GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    itemCount: controller.user['thumbnails'].length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemBuilder: (context, index) {
                      String thumbnailPath =
                      controller.user['thumbnails'][index];
                      return thumbnailPath != null &&
                          File(thumbnailPath).existsSync()
                          ? Image.file(
                        File(thumbnailPath),
                        fit: BoxFit.cover,
                      )
                          : Container(
                        color: Colors.grey,
                        child: const Icon(
                          Icons.video_collection,
                          color: Colors.white,
                        ),
                      );
                    },
                  )
                      : const Center(
                    child: Text(
                      'No videos yet.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to build stat columns (Following, Followers, Likes)
  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // Helper method to build dividers between stat columns
  Widget _buildDivider() {
    return Container(
      color: Colors.black54,
      width: 1,
      height: 15,
      margin: const EdgeInsets.symmetric(horizontal: 15),
    );
  }
}
