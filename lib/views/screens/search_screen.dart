import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUser(String username) async {
    if (username.isEmpty) {
      Get.snackbar('Error', 'Please enter a username to search',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _users = [];
    });

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _users = snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      } else {
        Get.snackbar('No Results', 'No user found with that username',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orangeAccent,
            colorText: Colors.white);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error searching user: $error');
      }
      Get.snackbar('Error', 'Something went wrong while searching',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildUserList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasSearched) {
      return const Center(
        child: Text(
          'Search for users by username',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(
        child: Text(
          'No users found.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: user['profileImageUrl'] != null &&
              user['profileImageUrl'].isNotEmpty
              ? NetworkImage(user['profileImageUrl'])
              : const AssetImage('assets/default_profile.png') as ImageProvider,
        ),
        title: Text(
          user['username'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(user['email'] ?? ''),
        trailing: ElevatedButton(
          onPressed: () {
            // Implement follow functionality
            if (kDebugMode) {
              print('Followed user: ${user['username']}');
            }
            Get.snackbar('Success', 'You followed ${user['username']}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text('Follow'),
        ),
        onTap: () {
          // Navigate to user's profile or perform another action
          if (kDebugMode) {
            print('User ID: ${user['uid']}');
          }
          Get.to(() => UserProfileScreen(userId: user['uid']));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a gradient background for a modern look
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced AppBar with a back button and title
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Search',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // Enhanced Search Bar
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: _searchUser,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by username',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white12,
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white70),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _users = [];
                          _hasSearched = false;
                        });
                      },
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                      const BorderSide(color: Colors.transparent, width: 0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                      const BorderSide(color: Colors.redAccent, width: 2),
                    ),
                  ),
                ),
              ),
              // User List
              Expanded(
                child: _buildUserList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dummy UserProfileScreen for navigation
class UserProfileScreen extends StatelessWidget {
  final String userId;

  const UserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implement user profile details here
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Center(
        child: Text('Profile of User ID: $userId'),
      ),
    );
  }
}
