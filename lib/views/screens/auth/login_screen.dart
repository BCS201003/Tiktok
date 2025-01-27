// lib/views/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:tiktok_tutorial/constants.dart';
import 'package:tiktok_tutorial/views/screens/auth/signup_screen.dart';
import 'package:tiktok_tutorial/views/widgets/text_input_field.dart';
import 'package:tiktok_tutorial/controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  // Instantiate AuthController using Get.find()
  final AuthController authController = Get.find<AuthController>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView( // Added to prevent overflow on smaller screens
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Tiktok',
                style: TextStyle(
                  fontSize: 35,
                  color: buttonColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9, // Adjusted for better layout
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: TextInputField(
                  controller: _emailController,
                  labelText: 'Email',
                  icon: Icons.email,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9, // Adjusted for better layout
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: TextInputField(
                  controller: _passwordController,
                  labelText: 'Password',
                  icon: Icons.lock,
                  isObscure: true,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9, // Adjusted for better layout
                height: 50,
                decoration: const BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                child: InkWell(
                  onTap: () => authController.loginUser(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                  ),
                  child: const Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t have an account? ',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SignupScreen(),
                      ),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(fontSize: 20, color: buttonColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
