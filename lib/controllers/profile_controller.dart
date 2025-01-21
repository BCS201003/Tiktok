// lib/controllers/profile_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tiktok_tutorial/constants.dart';

class ProfileController extends GetxController {
  final Rx<Map<String, dynamic>> _user = Rx<Map<String, dynamic>>({});
  Map<String, dynamic> get user => _user.value;

  Rx<String> _uid = "".obs;

  void updateUserId(String uid) {
    _uid.value = uid;
    getUserData();
  }

  Future<void> getUserData() async {
    try {
      List<String> thumbnails = [];
      var myVideos = await firestore
          .collection('videos')
          .where('uid', isEqualTo: _uid.value)
          .get();

      for (var videoDoc in myVideos.docs) {
        thumbnails.add((videoDoc.data() as dynamic)['thumbnail']);
      }

      DocumentSnapshot userDoc =
      await firestore.collection('users').doc(_uid.value).get();
      final userData = userDoc.data()! as dynamic;
      String name = userData['name'];
      String profilePhoto = userData['profilePhoto'];
      int likes = 0;
      int followers = 0;
      int following = 0;
      bool isFollowing = false;

      for (var item in myVideos.docs) {
        likes += (item.data()['likes'] as List).length;
      }

      var followerDoc = await firestore
          .collection('users')
          .doc(_uid.value)
          .collection('followers')
          .get();
      var followingDoc = await firestore
          .collection('users')
          .doc(_uid.value)
          .collection('following')
          .get();
      followers = followerDoc.docs.length;
      following = followingDoc.docs.length;

      DocumentSnapshot followDoc = await firestore
          .collection('users')
          .doc(_uid.value)
          .collection('followers')
          .doc(authController.currentUser!.uid)
          .get();
      isFollowing = followDoc.exists;

      _user.value = {
        'followers': followers.toString(),
        'following': following.toString(),
        'isFollowing': isFollowing,
        'likes': likes.toString(),
        'profilePhoto': profilePhoto,
        'name': name,
        'thumbnails': thumbnails,
      };
      update();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load profile data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> followUser() async {
    try {
      var doc = await firestore
          .collection('users')
          .doc(_uid.value)
          .collection('followers')
          .doc(authController.currentUser!.uid)
          .get();

      if (!doc.exists) {
        await firestore
            .collection('users')
            .doc(_uid.value)
            .collection('followers')
            .doc(authController.currentUser!.uid)
            .set({});
        await firestore
            .collection('users')
            .doc(authController.currentUser!.uid)
            .collection('following')
            .doc(_uid.value)
            .set({});
        _user.value.update(
          'followers',
              (value) => (int.parse(value) + 1).toString(),
        );
      } else {
        await firestore
            .collection('users')
            .doc(_uid.value)
            .collection('followers')
            .doc(authController.currentUser!.uid)
            .delete();
        await firestore
            .collection('users')
            .doc(authController.currentUser!.uid)
            .collection('following')
            .doc(_uid.value)
            .delete();
        _user.value.update(
          'followers',
              (value) => (int.parse(value) - 1).toString(),
        );
      }
      _user.value.update('isFollowing', (value) => !value);
      update();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to follow/unfollow: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
