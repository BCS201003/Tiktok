// lib/constants.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tiktok_tutorial/controllers/auth_controller.dart';
import 'package:tiktok_tutorial/views/screens/add_video_screen.dart';
import 'package:tiktok_tutorial/views/screens/profile_screen.dart';
import 'package:tiktok_tutorial/views/screens/search_screen.dart';
import 'package:tiktok_tutorial/views/screens/video_screen.dart';
import 'package:get/get.dart';

const backgroundColor = Colors.black;
var buttonColor = Colors.red[400];
const borderColor = Colors.grey;

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

final AuthController authController = Get.put(AuthController());

List<Widget> pages = [
  VideoScreen(),
  SearchScreen(),
  const AddVideoScreen(),
  const Text(
    'Messages Screen',
    style: TextStyle(color: Colors.white),
  ),
  Obx(() => authController.currentUser != null
      ? ProfileScreen(uid: authController.currentUser!.uid)
      : const Text(
    'Login Screen',
    style: TextStyle(color: Colors.white),
  )
  ),
];