// lib/controllers/auth_controller.dart
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:tiktok_tutorial/helpers/database_helper.dart';
import 'package:tiktok_tutorial/models/user.dart' as model;
import 'package:tiktok_tutorial/views/screens/auth/login_screen.dart';
import 'package:tiktok_tutorial/views/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart'; // Added import for Colors

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  late Rx<model.User?> _user;
  late Rx<File?> pickedImage;
  final Uuid _uuid = const Uuid();

  // Observable Firebase user
  Rxn<User> firebaseUser = Rxn<User>();

  File? get profilePhoto => pickedImage.value;
  model.User? get currentUser => _user.value;

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _user = Rx<model.User?>(null);
    pickedImage = Rx<File?>(null);

    auth.authStateChanges().listen((User? user) {
      if (user != null) {
        DatabaseHelper().getUserById(user.uid).then((userData) {
          if (userData != null) {
            _user.value =
                model.User.fromMap(userData); // Use fromMap for local data
            _setInitialScreen(_user.value);
          } else {
            // If user data doesn't exist, create it with a new UUID
            _createUserDocument(user);
          }
        }).catchError((error) {
          Get.snackbar(
            'Error',
            'Failed to fetch user data: $error',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        });
      } else {
        _user.value = null;
        _setInitialScreen(null);
      }
    });
  }

  void _setInitialScreen(model.User? user) {
    if (user == null) {
      Get.offAll(() => LoginScreen());
    } else {
      Get.offAll(() => const HomeScreen());
    }
  }

  /// Allows the user to pick an image from the gallery
  Future<void> pickImage() async {
    try {
      final XFile? selectedImage =
      await ImagePicker().pickImage(source: ImageSource.gallery);
      if (selectedImage != null) {
        Get.snackbar(
          'Profile Picture',
          'You have successfully selected your profile picture!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        pickedImage.value = File(selectedImage.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  /// Saves the picked image to local storage and returns the new path
  Future<String> _saveToLocalStorage(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final String userId = _user.value?.uid ?? 'default';
    final String fileName = path.basename(image.path);
    final String newPath =
    path.join(directory.path, 'profilePics', userId, fileName);

    final newDir = Directory(path.dirname(newPath));
    if (!await newDir.exists()) {
      await newDir.create(recursive: true);
    }

    final savedImage = await image.copy(newPath);
    return savedImage.path;
  }

  /// Creates a user document in Firestore with a generated UUID
  Future<void> _createUserDocument(User user) async {
    try {
      String imagePath = '';
      if (pickedImage.value != null) {
        imagePath = await _saveToLocalStorage(pickedImage.value!);
      }

      String userUUID = _uuid.v4();

      model.User newUser = model.User(
        name: '', // Prompt user to set name later or handle accordingly
        email: user.email ?? '',
        uid: user.uid,
        profilePhoto: imagePath,
        uuid: userUUID, // Assign generated UUID
      );

      await DatabaseHelper().insertUser(newUser.toJson());

      _user.value = newUser;
      _setInitialScreen(newUser);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create user data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  /// Registers a new user with email, password, username, and profile image
  Future<void> registerUser(
      String username, String email, String password, File? image) async {
    try {
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        UserCredential cred = await auth.createUserWithEmailAndPassword(
            email: email, password: password);

        String imagePath = await _saveToLocalStorage(image);

        String userUUID = _uuid.v4(); // Generate UUID during registration

        model.User user = model.User(
          name: username,
          email: email,
          uid: cred.user!.uid,
          profilePhoto: imagePath,
          uuid: userUUID, // Assign generated UUID
        );

        await DatabaseHelper().insertUser(user.toJson());

        _user.value = user;
        _setInitialScreen(user);
      } else {
        Get.snackbar(
          'Error Creating Account',
          'Please enter all the fields.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error Creating Account',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  /// Logs in an existing user and ensures a UUID is present
  Future<void> loginUser(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential cred = await auth.signInWithEmailAndPassword(
            email: email, password: password);

        final userData = await DatabaseHelper().getUserById(cred.user!.uid);
        if (userData != null) {
          model.User user = model.User.fromMap(userData); // Use fromMap for local data

          // Check if UUID exists
          if (user.uuid.isEmpty) {
            // Generate and assign new UUID
            String newUUID = _uuid.v4();
            await DatabaseHelper().updateUser(cred.user!.uid, {'uuid': newUUID});
            user = model.User(
              name: user.name,
              email: user.email,
              uid: user.uid,
              profilePhoto: user.profilePhoto,
              uuid: newUUID,
            );
            Get.snackbar(
              'Success',
              'UUID generated successfully.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }

          _user.value = user;
          _setInitialScreen(user);
        } else {
          // If user data doesn't exist, create it with a new UUID
          _createUserDocument(cred.user!);
        }
      } else {
        Get.snackbar(
          'Error Logging In',
          'Please enter all the fields.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error Logging In',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  /// Retrieves the UUID of the currently authenticated user
  Future<String?> getCurrentUserUUID() async {
    User? user = auth.currentUser;
    if (user != null) {
      Map<String, dynamic>? userData = await DatabaseHelper().getUserById(user.uid);
      return userData?['uuid'];
    }
    return null;
  }

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      await auth.signOut();
      _user.value = null;
      _setInitialScreen(null);
    } catch (e) {
      Get.snackbar(
        'Error Signing Out',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
