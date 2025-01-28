// lib/controllers/auth_controller.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tiktok_tutorial/helpers/database_helper.dart';
import 'package:tiktok_tutorial/models/user.dart' as model;
import 'package:tiktok_tutorial/services/firebase_service.dart';
import 'package:tiktok_tutorial/views/screens/auth/login_screen.dart';
import 'package:tiktok_tutorial/views/screens/home_screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final Uuid _uuid = const Uuid();

  late Rx<model.UserModel?> _user;
  late Rx<File?> pickedImage;

  // Getter for current user
  model.UserModel? get currentUser => _user.value;
  // Getter for profile photo
  File? get profilePhoto => pickedImage.value;

  @override
  void onInit() {
    super.onInit();
    _user = Rx<model.UserModel?>(null);
    pickedImage = Rx<File?>(null);

    // Listen for authentication state changes
    auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        // Check local SQLite for user data
        final userData = await DatabaseHelper().getUserById(firebaseUser.uid);
        if (userData != null) {
          // User exists locally
          _user.value = model.UserModel.fromMap(userData);
          _navigateToInitialScreen(_user.value);
        } else {
          // User not found locally, create user document
          await _createUserDocument(firebaseUser);
        }
      } else {
        // No user is signed in
        _user.value = null;
        _navigateToInitialScreen(null);
      }
    });
  }

  /// Navigates to the appropriate screen based on user authentication
  void _navigateToInitialScreen(model.UserModel? user) {
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

  /// Creates a user entry locally and in Firestore if missing
  Future<void> _createUserDocument(User firebaseUser) async {
    try {
      String imagePath = '';
      if (pickedImage.value != null) {
        imagePath = await _saveToLocalStorage(pickedImage.value!);
      }

      String userUUID = _uuid.v4();

      model.UserModel newUser = model.UserModel(
        name: '', // Handle user name setting later
        email: firebaseUser.email ?? '',
        uid: firebaseUser.uid,
        profilePhoto: imagePath,
        uuid: userUUID,
      );

      // Insert user into local SQLite
      await DatabaseHelper().insertUser(newUser.toJson());

      // Insert user into Firestore
      await _firebaseService.firestore.collection('users').doc(newUser.uid).set({
        'uid': newUser.uid,
        'email': newUser.email,
        'name': newUser.name,
        'profilePhoto': newUser.profilePhoto,
        'uuid': newUser.uuid,
        'followers': [],
        'following': [],
      });

      _user.value = newUser;
      _navigateToInitialScreen(newUser);
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
          email: email,
          password: password,
        );

        // Save image locally
        String imagePath = await _saveToLocalStorage(image);

        // Generate a UUID
        String userUUID = _uuid.v4();

        model.UserModel user = model.UserModel(
          name: username,
          email: email,
          uid: cred.user!.uid,
          profilePhoto: imagePath,
          uuid: userUUID,
        );

        // Insert user into local SQLite
        await DatabaseHelper().insertUser(user.toJson());

        // Insert user into Firestore
        await _firebaseService.firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'name': user.name,
          'profilePhoto': user.profilePhoto,
          'uuid': user.uuid,
          'followers': [],
          'following': [],
        });

        _user.value = user;
        _navigateToInitialScreen(user);
      } else {
        Get.snackbar(
          'Error Creating Account',
          'Please enter all the fields (and pick an image).',
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
          email: email,
          password: password,
        );

        // Check local SQLite for user data
        final userData = await DatabaseHelper().getUserById(cred.user!.uid);
        if (userData != null) {
          model.UserModel user = model.UserModel.fromMap(userData);

          // Generate UUID if missing
          if (user.uuid.isEmpty) {
            String newUUID = _uuid.v4();
            await DatabaseHelper()
                .updateUser(cred.user!.uid, {'uuid': newUUID});
            user = model.UserModel(
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

          // Check Firestore for user document
          final docSnap = await _firebaseService.firestore
              .collection('users')
              .doc(user.uid)
              .get();
          if (!docSnap.exists) {
            await _firebaseService.firestore
                .collection('users')
                .doc(user.uid)
                .set({
              'uid': user.uid,
              'email': user.email,
              'name': user.name,
              'profilePhoto': user.profilePhoto,
              'uuid': user.uuid,
              'followers': [],
              'following': [],
            });
          }

          _user.value = user;
          _navigateToInitialScreen(user);
        } else {
          // User not found locally, create user document
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
      Map<String, dynamic>? userData =
      await DatabaseHelper().getUserById(user.uid);
      return userData?['uuid'];
    }
    return null;
  }

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      await auth.signOut();
      _user.value = null;
      _navigateToInitialScreen(null);
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

  /// Signs in the user using Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      // Initiate Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return;
      }

      // Obtain authentication details from Google
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Create a new credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      UserCredential userCredential =
      await auth.signInWithCredential(credential);

      // Check if user exists in local SQLite
      final userInDB =
      await DatabaseHelper().getUserById(userCredential.user!.uid);
      if (userInDB == null) {
        // User not found locally, create user document
        final displayName = userCredential.user?.displayName ?? 'Unknown';
        final email = userCredential.user?.email ?? '';
        final uid = userCredential.user!.uid;
        final profilePic = userCredential.user?.photoURL ?? '';
        final userUUID = _uuid.v4();

        // Create local user
        final model.UserModel newUser = model.UserModel(
          name: displayName,
          email: email,
          uid: uid,
          profilePhoto: profilePic,
          uuid: userUUID,
        );
        await DatabaseHelper().insertUser(newUser.toJson());

        // Create Firestore user document
        await _firebaseService.firestore.collection('users').doc(uid).set({
          'uid': uid,
          'email': email,
          'name': displayName,
          'profilePhoto': profilePic,
          'uuid': userUUID,
          'followers': [],
          'following': [],
        });

        _user.value = newUser;
      } else {
        // User exists locally, set as current user
        final existingUser = model.UserModel.fromMap(userInDB);
        _user.value = existingUser;
      }

      // Navigate to Home Screen
      _navigateToInitialScreen(_user.value);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Google sign-in failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
