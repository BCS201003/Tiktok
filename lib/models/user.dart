import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String name;
  final String profilePhoto;
  final String email;
  final String uid;
  final String uuid;

  User({
    required this.name,
    required this.email,
    required this.uid,
    required this.profilePhoto,
    required this.uuid,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "profilePhoto": profilePhoto,
      "email": email,
      "uid": uid,
      "uuid": uuid,
    };
  }

  factory User.fromSnap(DocumentSnapshot snap) {
    final Map<String, dynamic> snapshot = snap.data() as Map<String, dynamic>;
    return User(
      name: snapshot['name'] ?? '',
      email: snapshot['email'] ?? '',
      uid: snapshot['uid'] ?? '',
      profilePhoto: snapshot['profilePhoto'] ?? '',
      uuid: snapshot['uuid'] ?? '',
    );
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      uid: map['uid'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
      uuid: map['uuid'] ?? '',
    );
  }
}
