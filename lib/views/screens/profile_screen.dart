import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tiktok_tutorial/controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileController _controller = Get.put(ProfileController());

  ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String currentUid = FirebaseAuth.instance.currentUser!.uid;
    _controller.loadUserData(currentUid);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (_controller.user.isEmpty) {
          return Center(
            child: Text('No user data available'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _controller.user['profilePictureUrl'] != null
                  ? CircleAvatar(
                backgroundImage:
                NetworkImage(_controller.user['profilePictureUrl']),
                radius: 50,
              )
                  : CircleAvatar(
                child: Icon(Icons.person, size: 50),
                radius: 50,
              ),
              SizedBox(height: 20),
              Text(
                'Name: ${_controller.user['name'] ?? 'Unknown'}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Email: ${_controller.user['email'] ?? 'Unknown'}',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _controller.followUser(currentUid),
                child: Text('Follow / Unfollow'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
