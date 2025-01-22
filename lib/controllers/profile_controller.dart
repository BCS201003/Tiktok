// lib/controllers/profile_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiktok_tutorial/constants.dart';
import 'package:tiktok_tutorial/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  Map<String, dynamic> user = {};

  @override
  void onInit() {
    super.onInit();
    // Optional: Initialize with current user's UID if needed
    // updateUserId(authController.currentUser!.uid);
  }

  void updateUserId(String uid) async {
    try {
      print('Fetching user data for UID: $uid'); // Debug print
      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        user = userDoc.data() as Map<String, dynamic>;
        print('User data fetched: $user'); // Debug print

        // Check if current user is following this user
        if (authController.currentUser != null) {
          String currentUserId = authController.currentUser!.uid;
          List followers = user['followers'] ?? [];
          user['isFollowing'] = followers.contains(currentUserId);
        } else {
          user['isFollowing'] = false;
        }

        update(); // Notify GetBuilder to rebuild UI
      } else {
        print('User not found'); // Debug print
        Get.snackbar('Error', 'User not found');
      }
    } catch (e) {
      print('Error fetching user data: $e'); // Debug print
      Get.snackbar('Error', 'Failed to fetch user data: $e');
    }
  }

  void followUser() async {
    try {
      String currentUserId = authController.currentUser!.uid;
      String targetUserId = user['uid'];

      // Update followers of target user
      await FirebaseFirestore.instance.collection('users').doc(targetUserId).update({
        'followers': FieldValue.arrayUnion([currentUserId]),
      });

      // Update following list of current user
      await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
        'following': FieldValue.arrayUnion([targetUserId]),
      });

      // Update local user data
      user['isFollowing'] = true;
      user['followers'] = (user['followers'] as List).length + 1;

      update(); // Notify GetBuilder to rebuild UI
    } catch (e) {
      print('Error following user: $e'); // Debug print
      Get.snackbar('Error', 'Failed to follow user: $e');
    }
  }

  void unfollowUser() async {
    try {
      String currentUserId = authController.currentUser!.uid;
      String targetUserId = user['uid'];

      // Update followers of target user
      await FirebaseFirestore.instance.collection('users').doc(targetUserId).update({
        'followers': FieldValue.arrayRemove([currentUserId]),
      });

      // Update following list of current user
      await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
        'following': FieldValue.arrayRemove([targetUserId]),
      });

      // Update local user data
      user['isFollowing'] = false;
      user['followers'] = (user['followers'] as List).length - 1;

      update(); // Notify GetBuilder to rebuild UI
    } catch (e) {
      print('Error unfollowing user: $e'); // Debug print
      Get.snackbar('Error', 'Failed to unfollow user: $e');
    }
  }
}
