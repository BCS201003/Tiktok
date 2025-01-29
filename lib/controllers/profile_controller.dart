// lib/controllers/profile_controller.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tiktok_tutorial/services/firebase_service.dart';
import 'package:tiktok_tutorial/models/user.dart'; // Ensure correct import
import 'dart:io';

class ProfileController extends GetxController {
  // Dependencies
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  // Observable user model
  final Rx<UserModel?> _user = Rx<UserModel?>(null);
  UserModel? get user => _user.value;

  // Observable list to hold user's videos
  final RxList<Map<String, dynamic>> _userVideos = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get userVideos => _userVideos;

  // Observable boolean to track loading state
  final RxBool isLoading = true.obs;

  // Observable string for error messages
  final RxString errorMessage = ''.obs;

  /// Loads user data and their videos based on the provided UID
  Future<void> loadUserData(String uid) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('Loading user data for UID: $uid');

      // Fetch user data from Firestore
      DocumentSnapshot userSnapshot =
      await _firestore.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        print('User snapshot exists. Mapping to UserModel.');
        _user.value = UserModel.fromSnap(userSnapshot);
        print('User data: ${_user.value}');
      } else {
        print('User snapshot does not exist.');
        _user.value = null;
        errorMessage.value = 'User does not exist.';
        return;
      }

      // Fetch user's videos from Firestore
      print('Fetching videos for UID: $uid');
      QuerySnapshot videosSnapshot = await _firestore
          .collection('videos')
          .where('uid', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .get();

      _userVideos.value =
          videosSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      print('Fetched ${_userVideos.value.length} videos.');
    } catch (e) {
      if (kDebugMode) {
        print("Error loading user data: $e");
      }
      errorMessage.value = 'Failed to load user data.';
      _user.value = null;
      _userVideos.value = [];
    } finally {
      isLoading.value = false;
      print('Finished loading user data.');
    }
  }

  /// Follows or unfollows the target user based on current state
  Future<void> followUser(String targetUid) async {
    try {
      String currentUid = _auth.currentUser!.uid;

      // Prevent users from following/unfollowing themselves
      if (currentUid == targetUid) {
        if (kDebugMode) {
          print("Cannot follow/unfollow yourself.");
        }
        Get.snackbar(
          'Action Denied',
          'You cannot follow yourself.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      DocumentReference userRef = _firestore.collection('users').doc(targetUid);
      DocumentReference currentUserRef =
      _firestore.collection('users').doc(currentUid);

      // Use a transaction to ensure both updates succeed or fail together
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot userSnapshot = await transaction.get(userRef);
        DocumentSnapshot currentUserSnapshot =
        await transaction.get(currentUserRef);

        if (!userSnapshot.exists || !currentUserSnapshot.exists) {
          if (kDebugMode) {
            print("User does not exist.");
          }
          throw Exception("User does not exist.");
        }

        List<dynamic> followers = userSnapshot.get('followers') ?? <String>[];

        if (followers.contains(currentUid)) {
          // If already following, perform unfollow
          transaction.update(userRef, {
            'followers': FieldValue.arrayRemove([currentUid]),
          });
          transaction.update(currentUserRef, {
            'following': FieldValue.arrayRemove([targetUid]),
          });
        } else {
          // If not following, perform follow
          transaction.update(userRef, {
            'followers': FieldValue.arrayUnion([currentUid]),
          });
          transaction.update(currentUserRef, {
            'following': FieldValue.arrayUnion([targetUid]),
          });
        }
      });

      // Reload user data to reflect changes
      await loadUserData(targetUid);

      // Determine the updated follow state
      bool isNowFollowing = user?.followers.contains(currentUid) ?? false;

      // Show success message
      Get.snackbar(
        'Success',
        isNowFollowing ? 'Followed successfully.' : 'Unfollowed successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor:
        isNowFollowing ? Colors.green : Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error following/unfollowing user: $e");
      }
      Get.snackbar(
        'Error',
        'Could not update follow status. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Updates the user's profile information
  Future<void> updateProfile({
    required String name,
    required String bio,
    File? profilePicture,
  }) async {
    try {
      String uid = _auth.currentUser!.uid;
      Map<String, dynamic> updateData = {
        'name': name,
        'bio': bio,
      };
      if (profilePicture != null) {
        // Upload the new profile picture to Firebase Storage and get the URL
        String photoUrl =
        await _firebaseService.uploadProfilePicture(uid: uid, imageFile: profilePicture);
        updateData['profilePhoto'] = photoUrl;
      }
      // Update user data in Firestore
      await _firestore.collection('users').doc(uid).update(updateData);
      // Reload user data to reflect changes
      await loadUserData(uid);
      // Show success message
      Get.snackbar(
        'Success',
        'Profile updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error updating profile: $e");
      }
      Get.snackbar(
        'Error',
        'Failed to update profile. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Checks if the current user is following the target user
  bool isFollowing(String targetUid) {
    if (user?.followers != null) {
      return user!.followers.contains(_auth.currentUser!.uid);
    }
    return false;
  }

  /// Retrieves the current user's following list
  List<String> getFollowing() {
    return user?.following ?? [];
  }

  /// Retrieves the current user's followers list
  List<String> getFollowers() {
    return user?.followers ?? [];
  }

  /// Retrieves the current user's bio
  String getBio() {
    return user?.bio ?? 'No bio available.';
  }

  /// Retrieves the current user's profile picture URL
  String getProfilePictureUrl() {
    return user?.profilePhoto ?? '';
  }
}
