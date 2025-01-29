// lib/controllers/auth_controller.dart

import 'dart:io';
import 'dart:convert'; // For JSON encoding/decoding
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

  var isLoading = false.obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  model.UserModel? get currentUser => _user.value;
  File? get profilePhoto => pickedImage.value;

  @override
  void onInit() {
    super.onInit();
    _user = Rx<model.UserModel?>(null);
    pickedImage = Rx<File?>(null);

    auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        print('Auth state changed: User is signed in.');
        final userData = await DatabaseHelper().getUserById(firebaseUser.uid);
        if (userData != null) {
          _user.value = model.UserModel.fromMap(userData);
          _navigateToInitialScreen(_user.value);
        } else {
          await _createUserDocument(firebaseUser);
        }
      } else {
        print('Auth state changed: No user is signed in.');
        _user.value = null;
        _navigateToInitialScreen(null);
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
  }

  void _navigateToInitialScreen(model.UserModel? user) {
    if (user == null) {
      Get.offAll(() => LoginScreen());
    } else {
      Get.offAll(() => const HomeScreen());
    }
  }

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
        print('Image picked: ${selectedImage.path}');
      } else {
        print('No image selected.');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      print('Error picking image: $e');
    }
  }

  Future<String> _saveToLocalStorage(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final String userId = _user.value?.uid ?? 'default';
    final String fileName = path.basename(image.path);
    final String newPath =
    path.join(directory.path, 'profilePics', userId, fileName);

    final newDir = Directory(path.dirname(newPath));
    if (!await newDir.exists()) {
      await newDir.create(recursive: true);
      print('Created directory: ${newDir.path}');
    }

    final savedImage = await image.copy(newPath);
    print('Image saved to: ${savedImage.path}');
    return savedImage.path;
  }

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
        bio: '', // Initialize bio as empty string
        followers: [], // Initialize followers as empty list
        following: [], // Initialize following as empty list
      );

      Map<String, dynamic> userMap = newUser.toJson();
      userMap['followers'] = jsonEncode(newUser.followers);
      userMap['following'] = jsonEncode(newUser.following);

      await DatabaseHelper().insertUser(userMap);
      print('Inserted user into SQLite: $userMap');

      await _firebaseService.firestore.collection('users').doc(newUser.uid).set({
        'uid': newUser.uid,
        'email': newUser.email,
        'name': newUser.name,
        'profilePhoto': newUser.profilePhoto,
        'uuid': newUser.uuid,
        'bio': newUser.bio,
        'followers': newUser.followers,
        'following': newUser.following,
      });
      print('Inserted user into Firestore: ${newUser.uid}');

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
      print('Error creating user document: $e');
    }
  }

  Future<void> registerUser(
      String username, String email, String password, File? image) async {
    try {
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        isLoading.value = true;

        UserCredential cred = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String imagePath = await _saveToLocalStorage(image);
        String userUUID = _uuid.v4();

        model.UserModel user = model.UserModel(
          name: username,
          email: email,
          uid: cred.user!.uid,
          profilePhoto: imagePath,
          uuid: userUUID,
          bio: '',
          followers: [],
          following: [],
        );

        Map<String, dynamic> userMap = user.toJson();
        userMap['followers'] = jsonEncode(user.followers);
        userMap['following'] = jsonEncode(user.following);

        await DatabaseHelper().insertUser(userMap);
        print('Registered user inserted into SQLite: $userMap');

        await _firebaseService.firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'name': user.name,
          'profilePhoto': user.profilePhoto,
          'uuid': user.uuid,
          'bio': user.bio,
          'followers': user.followers,
          'following': user.following,
        });
        print('Registered user inserted into Firestore: ${user.uid}');

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
        print('Registration failed: Incomplete fields.');
      }
    } catch (e) {
      Get.snackbar(
        'Error Creating Account',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      print('Error registering user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginUser(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        isLoading.value = true;

        UserCredential cred = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final userData = await DatabaseHelper().getUserById(cred.user!.uid);
        if (userData != null) {
          model.UserModel user = model.UserModel.fromMap(userData);
          print('User data retrieved from SQLite: $userData');

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
              bio: user.bio,
              followers: user.followers,
              following: user.following,
            );
            Get.snackbar(
              'Success',
              'UUID generated successfully.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            print('UUID generated and updated: $newUUID');
          }

          final docSnap = await _firebaseService.firestore
              .collection('users')
              .doc(user.uid)
              .get();
          if (!docSnap.exists) {
            await _firebaseService.firestore.collection('users').doc(user.uid).set({
              'uid': user.uid,
              'email': user.email,
              'name': user.name,
              'profilePhoto': user.profilePhoto,
              'uuid': user.uuid,
              'bio': user.bio,
              'followers': user.followers,
              'following': user.following,
            });
            print('User document created in Firestore: ${user.uid}');
          }

          _user.value = user;
          _navigateToInitialScreen(user);
        } else {
          print('User not found in SQLite. Creating user document.');
          await _createUserDocument(cred.user!);
        }
      } else {
        Get.snackbar(
          'Error Logging In',
          'Please enter all the fields.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        print('Login failed: Incomplete fields.');
      }
    } catch (e) {
      Get.snackbar(
        'Error Logging In',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      print('Error logging in user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> getCurrentUserUUID() async {
    User? user = auth.currentUser;
    if (user != null) {
      Map<String, dynamic>? userData =
      await DatabaseHelper().getUserById(user.uid);
      print('Retrieved UUID: ${userData?['uuid']}');
      return userData?['uuid'];
    }
    print('No user is currently signed in.');
    return null;
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await auth.signOut();
      _user.value = null;
      _navigateToInitialScreen(null);
      print('User signed out successfully.');
    } catch (e) {
      Get.snackbar(
        'Error Signing Out',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      print('Error signing out user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        isLoading.value = false;
        print('Google sign-in aborted by user.');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
      await auth.signInWithCredential(credential);

      final userInDB =
      await DatabaseHelper().getUserById(userCredential.user!.uid);
      if (userInDB == null) {
        final displayName = userCredential.user?.displayName ?? 'Unknown';
        final email = userCredential.user?.email ?? '';
        final uid = userCredential.user!.uid;
        final profilePic = userCredential.user?.photoURL ?? '';
        final userUUID = _uuid.v4();

        final model.UserModel newUser = model.UserModel(
          name: displayName,
          email: email,
          uid: uid,
          profilePhoto: profilePic,
          uuid: userUUID,
          bio: '',
          followers: [],
          following: [],
        );

        Map<String, dynamic> userMap = newUser.toJson();
        userMap['followers'] = jsonEncode(newUser.followers);
        userMap['following'] = jsonEncode(newUser.following);

        await DatabaseHelper().insertUser(userMap);
        print('Google user inserted into SQLite: $userMap');

        await _firebaseService.firestore.collection('users').doc(uid).set({
          'uid': uid,
          'email': email,
          'name': displayName,
          'profilePhoto': profilePic,
          'uuid': userUUID,
          'bio': newUser.bio,
          'followers': newUser.followers,
          'following': newUser.following,
        });
        print('Google user inserted into Firestore: $uid');

        _user.value = newUser;
      } else {
        final existingUser = model.UserModel.fromMap(userInDB);
        _user.value = existingUser;
        print('Google user retrieved from SQLite: $existingUser');
      }

      _navigateToInitialScreen(_user.value);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Google sign-in failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      print('Error during Google sign-in: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
