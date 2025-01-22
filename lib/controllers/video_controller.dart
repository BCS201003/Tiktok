// lib/controllers/video_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:tiktok_tutorial/models/video.dart';
import 'package:tiktok_tutorial/controllers/auth_controller.dart';

class VideoController extends GetxController {
  final RxList<Video> _videoList = <Video>[].obs;

  RxList<Video> get videoList => _videoList;

  final AuthController authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    loadVideos();
  }

  void loadVideos() {
    try {
      _videoList.assignAll([
        Video(
          id: '1',
          username: 'Muhammad Saad Hussain',
          caption: 'Hello.',
          songName: 'World Songs',
          videoUrl: 'https://raw.githubusercontent.com/BCS201003/Tiktok/main/assets/videos/video1.mp4',
          profilePhoto: 'https://via.placeholder.com/150',
          thumbnail: 'https://via.placeholder.com/150',
          uid: 'user1Uid',
          likes: [],
          commentCount: 10,
          shareCount: 5,
        ),
        Video(
          id: '2',
          username: 'Hello',
          caption: 'Check out this amazing clip!',
          songName: 'Hello Songs Songs',
          videoUrl: 'https://raw.githubusercontent.com/BCS201003/Tiktok/main/assets/videos/video2.mp4',
          profilePhoto: 'https://via.placeholder.com/150',
          thumbnail: 'https://via.placeholder.com/150',
          uid: 'user2Uid',
          likes: [],
          commentCount: 20,
          shareCount: 15,
        ),
        Video(
          id: '3',
          username: 'Hello',
          caption: 'Check out this amazing clip!',
          songName: 'Hello Songs Songs',
          videoUrl: 'https://raw.githubusercontent.com/BCS201003/Tiktok/main/assets/videos/video3.mp4',
          profilePhoto: 'https://via.placeholder.com/150',
          thumbnail: 'https://via.placeholder.com/150',
          uid: 'user2Uid',
          likes: [],
          commentCount: 20,
          shareCount: 15,
        ),
        Video(
          id: '4',
          username: 'Hello',
          caption: 'Check out this amazing clip!',
          songName: 'Hello Songs Songs',
          videoUrl: 'https://raw.githubusercontent.com/BCS201003/Tiktok/main/assets/videos/video4.mp4',
          profilePhoto: 'https://via.placeholder.com/150',
          thumbnail: 'https://via.placeholder.com/150',
          uid: 'user2Uid',
          likes: [],
          commentCount: 20,
          shareCount: 15,
        ),
        Video(
          id: '5',
          username: 'Hello',
          caption: 'Check out this amazing clip!',
          songName: 'Hello Songs Songs',
          videoUrl: 'https://raw.githubusercontent.com/BCS201003/Tiktok/main/assets/videos/video5.mp4',
          profilePhoto: 'https://via.placeholder.com/150',
          thumbnail: 'https://via.placeholder.com/150',
          uid: 'user2Uid',
          likes: [],
          commentCount: 20,
          shareCount: 15,
        ),
      ]);
      if (kDebugMode) {
        print('Videos successfully loaded.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading videos: $e');
      }
      Get.snackbar('Error', 'Failed to load videos: $e');
    }
  }

  /// Like or unlike a video
  void likeVideo(String id) {
    try {
      int index = _videoList.indexWhere((video) => video.id == id);

      if (index != -1) {
        Video video = _videoList[index];
        String uid = authController.currentUser?.uid ?? ''; // Get current user ID

        if (uid.isEmpty) {
          Get.snackbar('Error', 'User not logged in.');
          return;
        }

        if (video.likes.contains(uid)) {
          // If already liked, remove the like
          video.likes.remove(uid);
        } else {
          // If not liked, add the like
          video.likes.add(uid);
        }

        _videoList[index] = video;
        _videoList.refresh(); // Notify GetX about the update
        print('Video liked status updated for video ID: $id');
      } else {
        print('Video with ID $id not found.');
      }
    } catch (e) {
      print('Error liking video: $e');
      Get.snackbar('Error', 'Failed to like video: $e');
    }
  }
}
