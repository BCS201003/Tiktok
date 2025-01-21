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

// Styling Constants
const backgroundColor = Colors.black;
var buttonColor = Colors.red[400];
const borderColor = Colors.grey;

// Firebase Instances
final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

// Initialize AuthController using GetX dependency injection
final AuthController authController = Get.put(AuthController());

// Navigation Pages
List<Widget> pages = [
  VideoScreen(),
  SearchScreen(),
  const AddVideoScreen(),
  const Text(
    'Messages Screen',
    style: TextStyle(color: Colors.white),
  ), // Replace with actual MessagesScreen when available
  Obx(() => authController.currentUser != null
      ? ProfileScreen(uid: authController.currentUser!.uid)
      : const Text(
    'Login Screen',
    style: TextStyle(color: Colors.white),
  )), // Replace with LoginScreen if needed
];
