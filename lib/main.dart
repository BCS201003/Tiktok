import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_tutorial/constants.dart';
import 'package:tiktok_tutorial/controllers/auth_controller.dart';
import 'package:tiktok_tutorial/services/firebase_service.dart';
import 'package:tiktok_tutorial/views/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put<AuthController>(AuthController());
        Get.put<FirebaseService>(FirebaseService());
      }),
      home: const HomeScreen(),
    );
  }
}