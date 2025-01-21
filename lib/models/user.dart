import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String name;
  final String profilePhoto;
  final String email;
  final String uid;

  User({
    required this.name,
    required this.email,
    required this.uid,
    required this.profilePhoto,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "profilePhoto": profilePhoto,
      "email": email,
      "uid": uid,
    };
  }

  factory User.fromSnap(DocumentSnapshot snap) {
    final Map<String, dynamic> snapshot = snap.data() as Map<String, dynamic>;
    return User(
      name: snapshot['name'] ?? '',
      email: snapshot['email'] ?? '',
      uid: snapshot['uid'] ?? '',
      profilePhoto: snapshot['profilePhoto'] ?? '',
    );
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      uid: map['uid'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
    );
  }
}