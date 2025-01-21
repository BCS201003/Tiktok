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

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  late Rx<model.User?> _user;
  late Rx<File?> _pickedImage;

  File? get profilePhoto => _pickedImage.value;
  model.User? get currentUser => _user.value;

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _user = Rx<model.User?>(null);
    _pickedImage = Rx<File?>(null);

    auth.authStateChanges().listen((User? user) {
      if (user != null) {
        DatabaseHelper().getUserById(user.uid).then((userData) {
          if (userData != null) {
            _user.value =
                model.User.fromMap(userData); // Use fromMap for local data
            _setInitialScreen(_user.value);
          }
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

  Future<void> pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      Get.snackbar(
        'Profile Picture',
        'You have successfully selected your profile picture!',
        snackPosition: SnackPosition.BOTTOM,
      );
      _pickedImage.value = File(pickedImage.path);
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
    }

    final savedImage = await image.copy(newPath);
    return savedImage.path;
  }

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

        model.User user = model.User(
          name: username,
          email: email,
          uid: cred.user!.uid,
          profilePhoto: imagePath,
        );

        await DatabaseHelper().insertUser(user.toJson());

        _user.value = user;
        _setInitialScreen(user);
      } else {
        Get.snackbar(
          'Error Creating Account',
          'Please enter all the fields.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error Creating Account',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loginUser(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential cred = await auth.signInWithEmailAndPassword(
            email: email, password: password);

        final userData = await DatabaseHelper().getUserById(cred.user!.uid);
        if (userData != null) {
          model.User user =
              model.User.fromMap(userData); // Use fromMap for local data
          _user.value = user;
          _setInitialScreen(user);
        } else {
          Get.snackbar(
            'Error Logging In',
            'User data not found.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          'Error Logging In',
          'Please enter all the fields.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error Logging In',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

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
      );
    }
  }
}
