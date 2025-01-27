// Corrected constants.dart with Fix for UID Error

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color primaryColor = Colors.blue;
const Color backgroundColor = Colors.black;
const Color buttonColor = Colors.red;

// Firebase References
final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

// User-specific function that accepts UID as a parameter
void displayUserDetails({required String uid}) {
  firebaseFirestore.collection('users').doc(uid).get().then((snapshot) {
    if (snapshot.exists) {
      final userData = snapshot.data();
      if (kDebugMode) {
        print('User Data: $userData');
      }
    } else {
      if (kDebugMode) {
        print('No user found with UID: $uid');
      }
    }
  }).catchError((error) {
    if (kDebugMode) {
      print('Error fetching user data: $error');
    }
  });
}

// Example Usage
void exampleUsage() {
  final currentUser = firebaseAuth.currentUser;
  if (currentUser != null) {
    displayUserDetails(uid: currentUser.uid);
  } else {
    if (kDebugMode) {
      print('No user is currently logged in');
    }
  }
}
