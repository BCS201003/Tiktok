// lib/controllers/upload_video_controller.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:tiktok_tutorial/constants.dart';
import 'package:tiktok_tutorial/models/video.dart';
import 'package:video_compress/video_compress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tiktok_tutorial/services/firebase_service.dart';

class UploadVideoController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final AuthController _authController = Get.find<AuthController>();

  // Compress the video
  Future<File> _compressVideo(String videoPath) async {
    final compressedVideo = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.MediumQuality,
    );
    if (compressedVideo == null || compressedVideo.file == null) {
      throw Exception('Video compression failed.');
    }
    return compressedVideo.file!;
  }

  // Upload file to Firebase Storage and return the download URL
  Future<String> _uploadFileToStorage(File file, String id, String type) async {
    // type can be 'videos' or 'thumbnails'
    Reference ref = _firebaseService.storage
        .ref()
        .child('$type/$id/${path.basename(file.path)}');

    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

    if (snapshot.state == TaskState.success) {
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } else {
      throw Exception('Failed to upload $type.');
    }
  }

  // Compress and upload video to Firebase Storage
  Future<String> _processAndUploadVideo(String id, String videoPath) async {
    final compressedVideo = await _compressVideo(videoPath);
    String videoUrl = await _uploadFileToStorage(compressedVideo, id, 'videos');
    return videoUrl;
  }

  // Generate thumbnail and upload to Firebase Storage
  Future<String> _processAndUploadThumbnail(String id, String videoPath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoPath);
    File thumbnailFile = File(thumbnail.path);
    String thumbnailUrl = await _uploadFileToStorage(thumbnailFile, id, 'thumbnails');
    return thumbnailUrl;
  }

  // Upload video metadata to Firestore
  Future<void> uploadVideo(
      String songName, String caption, String videoPath) async {
    try {
      if (_authController.currentUser == null) {
        Get.snackbar(
          'Error',
          'You need to be logged in to upload videos.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      String uid = _authController.currentUser!.uid;
      DocumentSnapshot userDoc =
      await _firebaseService.firestore.collection('users').doc(uid).get();

      DocumentReference videoRef = _firebaseService.firestore.collection('videos').doc();
      String videoId = videoRef.id;

      // Upload video and thumbnail to Firebase Storage
      String videoUrl = await _processAndUploadVideo(videoId, videoPath);
      String thumbnailUrl = await _processAndUploadThumbnail(videoId, videoPath);

      // Create Video model instance
      Video video = Video(
        username: (userDoc.data()! as Map<String, dynamic>)['name'],
        uid: uid,
        id: videoId,
        likes: [],
        commentCount: 0,
        shareCount: 0,
        songName: songName,
        caption: caption,
        videoUrl: videoUrl,
        profilePhoto: (userDoc.data()! as Map<String, dynamic>)['profilePhoto'],
        thumbnail: thumbnailUrl,
      );

      // Save video metadata to Firestore
      await videoRef.set(
        video.toJson(),
      );

      Get.back(); // Navigate back after successful upload

      Get.snackbar(
        'Success',
        'Video uploaded successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error Uploading Video',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
