// Updated comment_controller.dart with Fixes for Undefined Names

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Observable list for comments
  var comments = <Map<String, dynamic>>[].obs;

  // Fetch comments for a specific video
  Future<void> fetchComments(String videoId) async {
    try {
      var snapshot = await firestore
          .collection('videos')
          .doc(videoId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      comments.value = snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  // Add a new comment
  Future<void> addComment(String videoId, String content) async {
    try {
      String? uid = auth.currentUser?.uid;
      if (uid == null) {
        throw Exception('User is not logged in');
      }

      DocumentSnapshot userDoc = await firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      await firestore.collection('videos').doc(videoId).collection('comments').add({
        'uid': uid,
        'username': userData['username'],
        'profilePic': userData['profilePictureUrl'],
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });

      fetchComments(videoId); // Refresh comments after adding
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  // Like or unlike a comment
  Future<void> toggleLike(String videoId, String commentId) async {
    try {
      String? uid = auth.currentUser?.uid;
      if (uid == null) {
        throw Exception('User is not logged in');
      }

      DocumentReference commentRef = firestore
          .collection('videos')
          .doc(videoId)
          .collection('comments')
          .doc(commentId);

      DocumentSnapshot commentSnapshot = await commentRef.get();

      if (commentSnapshot.exists) {
        List<dynamic> likes = commentSnapshot.get('likes') ?? [];

        if (likes.contains(uid)) {
          // Unlike the comment
          await commentRef.update({
            'likes': FieldValue.arrayRemove([uid]),
          });
        } else {
          // Like the comment
          await commentRef.update({
            'likes': FieldValue.arrayUnion([uid]),
          });
        }

        fetchComments(videoId); // Refresh comments to update UI
      } else {
        throw Exception('Comment not found');
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }
}
