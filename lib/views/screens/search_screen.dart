// Corrected SearchScreen Implementation from Your Existing Project

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchScreen extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by username',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchUser(_searchController.text.trim()),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _firestore.collection('users').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(user['username'] ?? 'Unknown'),
                      subtitle: Text(user['email'] ?? ''),
                      onTap: () {
                        if (kDebugMode) {
                          print('User ID: ${user['uid']}');
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _searchUser(String username) {
    if (username.isEmpty) {
      Get.snackbar('Error', 'Please enter a username to search');
      return;
    }

    // Example: Implement search functionality (adjust query as needed)
    _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final user = snapshot.docs.first.data();
        if (kDebugMode) {
          print('User found: ${user['username']} with UID: ${user['uid']}');
        }
      } else {
        Get.snackbar('No Results', 'No user found with that username');
      }
    }).catchError((error) {
      if (kDebugMode) {
        print('Error searching user: $error');
      }
      Get.snackbar('Error', 'Something went wrong while searching');
    });
  }
}
