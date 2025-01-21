// lib/controllers/comment_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tiktok_tutorial/constants.dart';
import 'package:tiktok_tutorial/models/comment.dart';

class CommentController extends GetxController {
  final Rx<List<Comment>> _comments = Rx<List<Comment>>([]);
  List<Comment> get comments => _comments.value;

  String _postId = "";

  // Update the current post ID and fetch comments
  void updatePostId(String id) {
    _postId = id;
    getComment();
  }

  // Fetch comments for the current post
  void getComment() {
    _comments.bindStream(
      firestore
          .collection('videos')
          .doc(_postId)
          .collection('comments')
          .orderBy('datePublished', descending: true)
          .snapshots()
          .map(
            (QuerySnapshot query) {
          List<Comment> retValue = [];
          for (var element in query.docs) {
            retValue.add(Comment.fromSnap(element));
          }
          return retValue;
        },
      ),
    );
  }

  // Post a new comment
  Future<void> postComment(String commentText) async {
    try {
      if (commentText.isNotEmpty) {
        // Ensure user is logged in
        if (authController.currentUser == null) {
          Get.snackbar(
            'Error',
            'You need to be logged in to comment',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        DocumentSnapshot userDoc = await firestore
            .collection('users')
            .doc(authController.currentUser!.uid)
            .get();

        // Use Firestore auto-generated ID for the comment
        DocumentReference commentRef = firestore
            .collection('videos')
            .doc(_postId)
            .collection('comments')
            .doc();

        Comment comment = Comment(
          username: (userDoc.data()! as dynamic)['name'],
          comment: commentText.trim(),
          datePublished: DateTime.now(),
          likes: [],
          profilePhoto: (userDoc.data()! as dynamic)['profilePhoto'],
          uid: authController.currentUser!.uid,
          id: commentRef.id,
        );

        await commentRef.set(comment.toJson());

        // Update comment count atomically
        DocumentReference videoRef = firestore.collection('videos').doc(_postId);
        await firestore.runTransaction((transaction) async {
          DocumentSnapshot videoSnap = await transaction.get(videoRef);
          if (videoSnap.exists) {
            int currentCount = (videoSnap.data()! as dynamic)['commentCount'] ?? 0;
            transaction.update(videoRef, {'commentCount': currentCount + 1});
          }
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error While Commenting',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Like or unlike a comment
  Future<void> likeComment(String id) async {
    try {
      var uid = authController.currentUser!.uid;
      DocumentReference commentRef = firestore
          .collection('videos')
          .doc(_postId)
          .collection('comments')
          .doc(id);
      DocumentSnapshot doc = await commentRef.get();

      if ((doc.data()! as dynamic)['likes'].contains(uid)) {
        await commentRef.update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await commentRef.update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error While Liking Comment',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
