// lib/views/screens/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_tutorial/constants.dart';
import 'package:tiktok_tutorial/views/screens/auth/login_screen.dart';
import 'package:tiktok_tutorial/views/widgets/text_input_field.dart';
import 'package:tiktok_tutorial/controllers/auth_controller.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({Key? key}) : super(key: key);

  // Define a GlobalKey for the form
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    // Retrieve AuthController instance
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.yellow[600],
      body: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Assign the GlobalKey
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
                  'Register',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 25),
                Stack(
                  children: [
                    Obx(() {
                      return authController.pickedImage.value != null
                          ? CircleAvatar(
                        radius: 64,
                        backgroundImage:
                        FileImage(authController.pickedImage.value!),
                        backgroundColor: Colors.black,
                      )
                          : const CircleAvatar(
                        radius: 64,
                        backgroundImage: NetworkImage(
                            'https://www.pngitem.com/pimgs/m/150-1503945_transparent-user-png-default-user-image-png-png.png'),
                        backgroundColor: Colors.black,
                      );
                    }),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: () => authController.pickImage(),
                        icon: const Icon(
                          Icons.add_a_photo,
                          color: buttonColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Username Input Field with Validation
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInputField(
                    controller: authController.usernameController,
                    labelText: 'Username',
                    prefixIcon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      if (value.length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),
                // Email Input Field with Validation
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInputField(
                    controller: authController.emailController,
                    labelText: 'Email',
                    prefixIcon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),
                // Password Input Field with Validation
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInputField(
                    controller: authController.passwordController,
                    labelText: 'Password',
                    prefixIcon: Icons.lock,
                    isObscure: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 30),
                // Register Button with Form Validation and Loading Indicator
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: Obx(() {
                    return authController.isLoading.value
                        ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                        : InkWell(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          if (authController.pickedImage.value != null) {
                            authController.registerUser(
                              authController.usernameController.text.trim(),
                              authController.emailController.text.trim(),
                              authController.passwordController.text.trim(),
                              authController.pickedImage.value,
                            );
                          } else {
                            Get.snackbar(
                              'Error',
                              'Please pick a profile image.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                          }
                        }
                      },
                      child: const Center(
                        child: Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 15),
                // Registration Prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 20, color: buttonColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
