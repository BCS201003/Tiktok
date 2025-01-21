// lib/controllers/upload_video_controller.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:tiktok_tutorial/constants.dart';
import 'package:tiktok_tutorial/models/video.dart';
import 'package:video_compress/video_compress.dart';

class UploadVideoController extends GetxController {
  // Compress video
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

  // Save video to local storage
  Future<String> _saveVideoToLocal(String id, String videoPath) async {
    final compressedVideo = await _compressVideo(videoPath);
    final directory = await getApplicationDocumentsDirectory();
    final String newPath = path.join(directory.path, 'videos', id, path.basename(compressedVideo.path));

    // Ensure the directory exists
    final newDir = Directory(path.dirname(newPath));
    if (!await newDir.exists()) {
      await newDir.create(recursive: true);
    }

    // Copy the compressed video to the new path
    final savedVideo = await compressedVideo.copy(newPath);
    return savedVideo.path;
  }

  // Generate and save thumbnail locally
  Future<String> _saveThumbnailToLocal(String id, String videoPath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoPath);
    final directory = await getApplicationDocumentsDirectory();
    final String thumbnailPath = path.join(directory.path, 'thumbnails', id, path.basename(thumbnail.path));

    // Ensure the directory exists
    final thumbnailDir = Directory(path.dirname(thumbnailPath));
    if (!await thumbnailDir.exists()) {
      await thumbnailDir.create(recursive: true);
    }

    // Save the thumbnail
    final savedThumbnail = await thumbnail.copy(thumbnailPath);
    return savedThumbnail.path;
  }

  // Upload video (save locally)
  Future<void> uploadVideo(String songName, String caption, String videoPath) async {
    try {
      // Ensure user is logged in
      if (authController.currentUser == null) {
        Get.snackbar(
          'Error',
          'You need to be logged in to upload videos.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      String uid = authController.currentUser!.uid;
      DocumentSnapshot userDoc =
      await firestore.collection('users').doc(uid).get();

      // Use Firestore auto-generated ID
      DocumentReference videoRef = firestore.collection('videos').doc();
      String videoId = videoRef.id;

      // Save video and thumbnail locally
      String localVideoPath = await _saveVideoToLocal(videoId, videoPath);
      String localThumbnailPath = await _saveThumbnailToLocal(videoId, videoPath);

      // Create video model
      Video video = Video(
        username: (userDoc.data()! as Map<String, dynamic>)['name'],
        uid: uid,
        id: videoId,
        likes: [],
        commentCount: 0,
        shareCount: 0,
        songName: songName,
        caption: caption,
        videoUrl: localVideoPath, // Local path
        profilePhoto: (userDoc.data()! as Map<String, dynamic>)['profilePhoto'],
        thumbnail: localThumbnailPath, // Local thumbnail path
      );

      // Save video to Firestore
      await videoRef.set(
        video.toJson(),
      );
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error Uploading Video',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
