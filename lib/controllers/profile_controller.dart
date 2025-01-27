// lib/controllers/profile_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable map to hold user data
  final RxMap<String, dynamic> _user = <String, dynamic>{}.obs;
  Map<String, dynamic> get user => _user.value;

  // Observable boolean to track loading state
  final RxBool isLoading = true.obs;

  // Observable string for error messages
  final RxString errorMessage = ''.obs;

  /// Loads user data based on the provided UID
  Future<void> loadUserData(String uid) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      DocumentSnapshot snapshot =
      await _firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
        _user.value = snapshot.data() as Map<String, dynamic>;
      } else {
        _user.value = {};
        errorMessage.value = 'User does not exist.';
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading user data: $e");
      }
      errorMessage.value = 'Failed to load user data.';
      _user.value = {};
    } finally {
      isLoading.value = false;
    }
  }

  /// Follows or unfollows the target user based on current state
  Future<void> followUser(String targetUid) async {
    try {
      String currentUid = _auth.currentUser!.uid;

      // Prevent users from following themselves
      if (currentUid == targetUid) {
        if (kDebugMode) {
          print("Cannot follow/unfollow yourself.");
        }
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

        List<dynamic> followers =
            userSnapshot.get('followers') ?? <String>[];
        List<dynamic> following =
            currentUserSnapshot.get('following') ?? <String>[];

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
    } catch (e) {
      if (kDebugMode) {
        print("Error following/unfollowing user: $e");
      }
      Get.snackbar(
        'Error',
        'Could not update follow status. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
