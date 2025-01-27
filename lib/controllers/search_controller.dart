// lib/controllers/my_search_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tiktok_tutorial/models/user.dart'; // Ensure correct import

class MySearchController extends GetxController {
  // FirebaseFirestore instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final Rx<List<User>> _searchedUsers = Rx<List<User>>([]);
  List<User> get searchedUsers => _searchedUsers.value;

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
          .where('name', isLessThan: typedUser + 'z') // To limit the query
          .snapshots()
          .map((QuerySnapshot query) {
        List<User> retVal = [];
        for (var elem in query.docs) {
          retVal.add(User.fromSnap(elem)); // Now correctly defined
        }
        return retVal;
      }),
    );
  }
}
