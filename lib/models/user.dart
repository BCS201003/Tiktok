// lib/models/user.dart

import 'dart:convert'; // For JSON encoding/decoding
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel { // Renamed to UserModel to avoid confusion with FirebaseAuth's User
  final String name;
  final String profilePhoto;
  final String email;
  final String uid;
  final String uuid;
  final String bio; // Added bio field
  final List<String> followers; // Added followers field
  final List<String> following; // Added following field

  UserModel({
    required this.name,
    required this.email,
    required this.uid,
    required this.profilePhoto,
    required this.uuid,
    this.bio = '',
    List<String>? followers,
    List<String>? following,
  })  : followers = followers ?? [],
        following = following ?? [];

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "profilePhoto": profilePhoto,
      "email": email,
      "uid": uid,
      "uuid": uuid,
      "bio": bio,
      "followers": followers,
      "following": following,
    };
  }

  factory UserModel.fromSnap(DocumentSnapshot snap) {
    final Map<String, dynamic> snapshot = snap.data() as Map<String, dynamic>;
    return UserModel(
      name: snapshot['name'] ?? '',
      email: snapshot['email'] ?? '',
      uid: snapshot['uid'] ?? '',
      profilePhoto: snapshot['profilePhoto'] ?? '',
      uuid: snapshot['uuid'] ?? '',
      bio: snapshot['bio'] ?? '',
      followers: List<String>.from(snapshot['followers'] ?? []),
      following: List<String>.from(snapshot['following'] ?? []),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      uid: map['uid'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
      uuid: map['uuid'] ?? '',
      bio: map['bio'] ?? '',
      followers: map['followers'] != null
          ? List<String>.from(jsonDecode(map['followers']))
          : [],
      following: map['following'] != null
          ? List<String>.from(jsonDecode(map['following']))
          : [],
    );
  }
}
