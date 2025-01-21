// lib/controllers/video_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tiktok_tutorial/constants.dart';
import 'package:tiktok_tutorial/models/video.dart';

class VideoController extends GetxController {
  final Rx<List<Video>> _videoList = Rx<List<Video>>([]);
  List<Video> get videoList => _videoList.value;

  @override
  void onInit() {
    super.onInit();
    _videoList.bindStream(
      firestore
          .collection('videos')
          .orderBy('datePublished', descending: true)
          .snapshots()
          .map((QuerySnapshot query) {
        List<Video> retVal = [];
        for (var element in query.docs) {
          retVal.add(Video.fromSnap(element));
        }
        return retVal;
      }),
    );
  }

  Future<void> likeVideo(String id) async {
    try {
      if (authController.currentUser == null) {
        Get.snackbar(
          'Error ',
          'You need to be logged in to like videos.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      DocumentReference videoRef = firestore.collection('videos').doc(id);
      DocumentSnapshot doc = await videoRef.get();
      var uid = authController.currentUser!.uid;

      if ((doc.data()! as dynamic)['likes'].contains(uid)) {
        await videoRef.update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await videoRef.update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to like video: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
