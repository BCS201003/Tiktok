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

  late Rx<model.User?> _user;
  late Rx<File?> pickedImage;

  // Keep track of the user in local DB form
  model.User? get currentUser => _user.value;
  File? get profilePhoto => pickedImage.value;

  @override
  void onInit() {
    super.onInit();
    _user = Rx<model.User?>(null);
    pickedImage = Rx<File?>(null);

    // Listen for auth state changes
    auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        // 1) Fetch from local SQLite
        final userData = await DatabaseHelper().getUserById(firebaseUser.uid);
        if (userData != null) {
          // Found user in local DB
          _user.value = model.User.fromMap(userData);
          _setInitialScreen(_user.value);
        } else {
          // Not found in local DB => create local DB entry
          await _createUserDocument(firebaseUser);
        }
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

  /// Creates a user *locally* and also in Firestore (if missing)
  Future<void> _createUserDocument(User firebaseUser) async {
    try {
      String imagePath = '';
      if (pickedImage.value != null) {
        imagePath = await _saveToLocalStorage(pickedImage.value!);
      }

      String userUUID = _uuid.v4();

      model.User newUser = model.User(
        name: '', // Prompt user to set name later or handle accordingly
        email: firebaseUser.email ?? '',
        uid: firebaseUser.uid,
        profilePhoto: imagePath,
        uuid: userUUID,
      );

      // Store in local SQLite
      await DatabaseHelper().insertUser(newUser.toJson());

      // Also store in Firestore to avoid permission or data-missing issues
      await _firebaseService.firestore
          .collection('users')
          .doc(newUser.uid)
          .set({
        'uid': newUser.uid,
        'email': newUser.email,
        'name': newUser.name,
        'profilePhoto': newUser.profilePhoto,
        'uuid': newUser.uuid,
        'followers': [],
        'following': [],
      });

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
          email: email,
          password: password,
        );

        // Save image locally
        String imagePath = await _saveToLocalStorage(image);

        // Generate a UUID
        String userUUID = _uuid.v4();

        model.User user = model.User(
          name: username,
          email: email,
          uid: cred.user!.uid,
          profilePhoto: imagePath,
          uuid: userUUID,
        );

        // 1) Store user in local SQLite
        await DatabaseHelper().insertUser(user.toJson());

        // 2) Also store user in Firestore
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

        _user.value = user;
        _setInitialScreen(user);
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

        // 1) Check local DB
        final userData = await DatabaseHelper().getUserById(cred.user!.uid);
        if (userData != null) {
          // Found in local DB
          model.User user = model.User.fromMap(userData);

          // Check if user.uuid is empty; if so, generate and update in local DB
          if (user.uuid.isEmpty) {
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

          // 2) Check if Firestore doc exists; if not, create one
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
          _setInitialScreen(user);
        } else {
          // Not in local DB => create user doc in local DB and Firestore
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
  Future<void> signInWithGoogle() async {
    try {
      // 1) Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return;
      }

      // 2) Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3) Create a new credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4) Sign in to Firebase with this credential
      UserCredential userCredential =
      await auth.signInWithCredential(credential);

      // 5) Check if user record already exists in Firestore & local DB
      final userInDB = await DatabaseHelper().getUserById(userCredential.user!.uid);
      if (userInDB == null) {
        // Not in local DB => create doc with name, email, etc.
        // The user’s displayName and photoURL come from Google if available
        final displayName = userCredential.user?.displayName ?? 'Unknown';
        final email = userCredential.user?.email ?? '';
        final uid = userCredential.user!.uid;
        final profilePic = userCredential.user?.photoURL ?? '';
        final userUUID = _uuid.v4();

        // Create local DB user
        final model.User newUser = model.User(
          name: displayName,
          email: email,
          uid: uid,
          profilePhoto: profilePic,
          uuid: userUUID,
        );
        await DatabaseHelper().insertUser(newUser.toJson());

        // Create Firestore doc
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
        // Already in local DB => convert, set _user
        final existingUser = model.User.fromMap(userInDB);
        _user.value = existingUser;
      }

      // Navigate to home screen
      _setInitialScreen(_user.value);
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
