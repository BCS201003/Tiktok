// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_tutorial/controllers/auth_controller.dart';
import 'package:tiktok_tutorial/services/firebase_service.dart';
import 'package:tiktok_tutorial/views/screens/home_screen.dart';
// Import other necessary packages and screens

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Initialize controllers using initialBinding
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put<AuthController>(AuthController());
        Get.put<FirebaseService>(FirebaseService());
        // Initialize other controllers as needed
      }),
      home: HomeScreen(),
    );
  }
}
