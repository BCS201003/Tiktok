import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_tutorial/controllers/auth_controller.dart';
import 'package:tiktok_tutorial/services/firebase_service.dart';
import 'package:tiktok_tutorial/views/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart'; // Ensure this import is present

Future<void> main() async {
  // Ensures that plugin services are initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase asynchronously
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    // Handle Firebase initialization errors
    print('Firebase initialization failed: $e');
  }

  // Run the Flutter application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        // Initialize your controllers and services
        Get.put<AuthController>(AuthController());
        Get.put<FirebaseService>(FirebaseService());
      }),
      home: const HomeScreen(),
    );
  }
}
