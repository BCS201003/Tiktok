// lib/controllers/my_search_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tiktok_tutorial/models/user.dart'; // Ensure correct import

class MySearchController extends GetxController {
  // FirebaseFirestore instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final Rx<List<UserModel>> _searchedUsers = Rx<List<UserModel>>([]);
  List<UserModel> get searchedUsers => _searchedUsers.value;

  // Search users by name
  void searchUser(String typedUser) {
    if (typedUser.isEmpty) {
      _searchedUsers.value = [];
      return;
    }

    _searchedUsers.bindStream(
      firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: typedUser)
          .where('name', isLessThan: '${typedUser}z')
          .snapshots()
          .map((QuerySnapshot query) {
        List<UserModel> retVal = [];
        for (var elem in query.docs) {
          retVal.add(UserModel.fromSnap(elem));
        }
        return retVal;
      }),
    );
  }
}
