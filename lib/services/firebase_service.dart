// lib/services/firebase_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:get/get.dart';

class FirebaseService extends GetxService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  /// Uploads the profile picture to Firebase Storage and returns the download URL
  /// Uploads profile picture to Firebase Storage and returns the download URL
  Future<String> uploadProfilePicture({
    required String uid,
    required File imageFile,
  }) async {
    try {
      Reference ref = storage.ref().child('profile_pictures').child('$uid.jpg');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Profile picture uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      return '';
    }
  }
  /// Optional: Uploads a video and returns the download URL
  Future<String> uploadVideo(String uid, File video) async {
    try {
      // Define the storage reference
      Reference ref = storage.ref().child('videos').child(uid).child('${DateTime.now().millisecondsSinceEpoch}.mp4');

      // Upload the video file to Firebase Storage
      UploadTask uploadTask = ref.putFile(video);

      // Await the upload task completion
      TaskSnapshot snapshot = await uploadTask;

      // Retrieve the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading video: $e");
      }
      throw Exception('Failed to upload video: $e');
    }
  }
}
