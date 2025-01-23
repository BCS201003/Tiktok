// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  FirebaseService({
    FirebaseFirestore? firestoreInstance,
    FirebaseStorage? storageInstance,
  })  : firestore = firestoreInstance ?? FirebaseFirestore.instance,
        storage = storageInstance ?? FirebaseStorage.instance;
}
