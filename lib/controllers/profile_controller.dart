// lib/controllers/profile_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Changed Rx<Map<String, dynamic>> to RxMap<String, dynamic>
  final RxMap<String, dynamic> _user = <String, dynamic>{}.obs;
  Map<String, dynamic> get user => _user.value;

  final RxBool isLoading = true.obs;

  Future<void> loadUserData(String uid) async {
    try {
      isLoading.value = true;
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
        _user.value = snapshot.data() as Map<String, dynamic>;
      } else {
        _user.value = {};
      }
    } catch (e) {
      print("Error loading user data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> followUser(String uid) async {
    try {
      String currentUid = _auth.currentUser!.uid;
      DocumentReference userRef = _firestore.collection('users').doc(uid);

      DocumentSnapshot userSnapshot = await userRef.get();
      if (userSnapshot.exists) {
        List<dynamic> followers = userSnapshot.get('followers') ?? [];
        if (followers.contains(currentUid)) {
          await userRef.update({
            'followers': FieldValue.arrayRemove([currentUid]),
          });
        } else {
          await userRef.update({
            'followers': FieldValue.arrayUnion([currentUid]),
          });
        }
      }
    } catch (e) {
      print("Error following/unfollowing user: $e");
    }
  }
}
